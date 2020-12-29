package com.flashflexpro.as3lib.data {
import com.flashflexpro.as3lib.*;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;
import flash.utils.getQualifiedClassName;

import mx.collections.IList;
import mx.core.IPropertyChangeNotifier;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.utils.ArrayUtil;
import mx.utils.UIDUtil;

[Event(name="collectionChange", type="mx.events.CollectionEvent")]

[Event(name="collectionChanging", type="com.flashflexpro.as3lib.data.CollectionChangingEvent")]

[RemoteClass(alias="com.flashflexpro.graniteds.CrList")]

[DefaultProperty("source")]
/**
 *  a list that have move, removeAll .. ....
 */ public class CrList extends EventDispatcher implements IList, IExternalizable, IPropertyChangeNotifier{

    public function CrList( source:Array = null, trackUpdate:Boolean = false ){
        super();
        this._trackUpdate = trackUpdate;
        _constructing = true;
        this.source = source;
        _constructing = false;
    }

    private var _trackUpdate:Boolean = false;
    public function get trackUpdate():Boolean{
        return _trackUpdate;
    }

    private var _constructing:Boolean = false;

    [Bindable("collectionChange")]
    public function get length():int{
        if( _source != null ){
            return _source.length;
        }
        else{
            return 0;
        }
    }

    private var _source:Array;
    public function get source():Array{
        return _source;
    }

    public function set source( s:Array ):void{
        if( ! _constructing && hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.RESET ) );
        }

        var i:int;
        var len:int;
        if( _source && _source.length ){
            len = _source.length;
            for( i = 0; i < len; i ++ ){
                stopTrackUpdates( _source[i] );
            }
        }

        _source = s ? s : [];

        len = _source.length;
        for( i = 0; i < len; i ++ ){
            startTrackUpdates( _source[i] );
        }

        if( ! _constructing && hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            var event:CollectionEvent = new CollectionEvent( CollectionEvent.COLLECTION_CHANGE );
            event.kind = CollectionEventKind.RESET;
            dispatchEvent( event );
        }
    }

    private var _uid:String;

    public function get uid():String{
        if( ! _uid ){
            _uid = UIDUtil.createUID();
        }
        return _uid;
    }

    public function set uid( value:String ):void{
        _uid = value;
    }

    public function getItemAt( index:int, prefetch:int = 0 ):Object{
        if( index < 0 || index >= length ){
            throw new RangeError( "collections", "outOfBounds" );
        }

        return _source[index];
    }

    public function setItemAt( item:Object, index:int ):Object{
        if( index < 0 || index >= length ){
            throw new RangeError( "collections", "outOfBounds" );
        }

        var oldItem:Object = _source[index];

        var updateInfo:PropertyChangeEvent;
        if( hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ||
                hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            updateInfo = new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE );
            updateInfo.kind = PropertyChangeEventKind.UPDATE;
            updateInfo.oldValue = oldItem;
            updateInfo.newValue = item;
            updateInfo.property = index;
        }

        if( updateInfo != null && hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.REPLACE, index, - 1, [ updateInfo ] ) );
        }

        stopTrackUpdates( oldItem );
        _source[index] = item;
        startTrackUpdates( item );

        //dispatch the appropriate events 
        if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){

            var event:CollectionEvent = new CollectionEvent( CollectionEvent.COLLECTION_CHANGE );
            event.kind = CollectionEventKind.REPLACE;
            event.location = index;
            event.items.push( updateInfo );

            dispatchEvent( event );
        }
        return oldItem;
    }

    public function addItem( item:Object ):void{
        addItemAt( item, length );
    }


    public function addItemAt( item:Object, index:int ):void{
        if( index < 0 || index > length ){
            throw new RangeError( "collections", "outOfBounds" );
        }

        if( ! _multiItems && ! _movingItem && hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.ADD, index, - 1, [ item ] ) )
        }

        _source.splice( index, 0, item );

        startTrackUpdates( item );

        if( ! _multiItems && ! _movingItem && hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.ADD, index, - 1, [ item ] ) )
        }
    }

    public function addAll( addList:IList ):void{
        addAllAt( addList, length );
    }

    private var _multiItems:Boolean = false;

    public function addAllAt( addList:IList, index:int ):void{
        var array:Array = addList.toArray();
        if( hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.ADD, index, - 1, array ) )
        }
        _multiItems = true;
        var length:int = addList.length;
        for( var i:int = 0; i < length; i ++ ){
            this.addItemAt( addList.getItemAt( i ), i + index );
        }
        _multiItems = false;
        if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.ADD, index, - 1, array ) )
        }
    }

    public function removeAllAt( index:uint, len:uint ):Array{
        var array:Array = [];
        if( hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.REMOVE, index, - 1, array ) )
        }
        _multiItems = true;
        for( var i:int = 0; i < len; i ++ ){
            array.push( removeItemAt( index ) );
        }
        _multiItems = false;
        if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.REMOVE, index, - 1, array ) )
        }
        return array;
    }


    private var _movingItem:Boolean = false;

    public function moveItem( fromIndex:uint, toIndex:uint ):void{
        _movingItem = true;

        if( hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.MOVE, toIndex, fromIndex ) );
        }

        addItemAt( removeItemAt( fromIndex ), toIndex );

        if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.MOVE, toIndex, fromIndex ) );
        }
        _movingItem = false;
    }

    public function getItemIndex( item:Object ):int{
        return ArrayUtil.getItemIndex( item, _source );
    }

    public function removeItem( item:Object ):Boolean{
        var index:int = getItemIndex( item );
        var result:Boolean = ( index >= 0 );
        if( result ){
            removeItemAt( index );
        }

        return result;
    }

    public function removeItemAt( index:int ):Object{
        CONFIG::debugging{
            if( index < 0 || index >= length ){
                CC.log( this + "outOfBounds index:" + index + ",len:" + length, 2, true );
            }
        }
        var item:Object = _source[ index ];

        if( ! _movingItem && !_multiItems && hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.REMOVE, index, - 1, [ item ] ) );
        }

        stopTrackUpdates( item );
        _source.splice( index, 1 );

        if( ! _movingItem && !_multiItems && hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.REMOVE, index, - 1, [ item ] ) );
        }
        return item;
    }

    public function removeAll():void{
        if( length > 0 ){
            if( hasEventListener( CollectionChangingEvent.COLLECTION_CHANGING ) ){
                dispatchEvent( new CollectionChangingEvent( CollectionEventKind.RESET ) );
            }

            var len:int = length;
            for( var i:int = 0; i < len; i ++ ){
                stopTrackUpdates( _source[i] );
            }
            _source.splice( 0, length );

            if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ){
                dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                        CollectionEventKind.RESET ) );
            }
        }
    }

    public function itemUpdated( item:Object, property:Object = null, oldValue:Object = null,
                                 newValue:Object = null ):void{

        CONFIG::debugging{
            CC.log( "HOW???", 2, true );
        }
    }

    public function toArray():Array{
        return _source.concat();
    }

    public function readExternal( input:IDataInput ):void{
        _constructing = true;
        source = input.readObject();
        _constructing = true;
    }

    public function writeExternal( output:IDataOutput ):void{
        output.writeObject( _source );
    }

    override public function toString():String{
        if( _source != null){
            return _source.toString();
        }
        else{
            return getQualifiedClassName( this );
        }
    }

    protected function startTrackUpdates( item:Object ):void{
        if( _trackUpdate && item && (item is IEventDispatcher) ){
            var d:IEventDispatcher = item as IEventDispatcher;
            d.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, itemUpdateHandler, false, 0, true );
            d.addEventListener( PropertyChangingEvent.PROPERTY_CHANGING, itemUpdateHandler, false, 0, true );
        }
    }

    protected function itemUpdateHandler( event:Event ):void{
        if( event is PropertyChangingEvent ){
            dispatchEvent( new CollectionChangingEvent( CollectionEventKind.UPDATE, - 1, - 1, [ event ] ) );
        }
        else if( event is PropertyChangeEvent ){
            dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false,
                    CollectionEventKind.UPDATE, - 1, - 1, [ event ] ) );
        }
    }

    protected function stopTrackUpdates( item:Object ):void{
        if( item && item is IEventDispatcher ){
            var d:IEventDispatcher = item as IEventDispatcher;
            d.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, itemUpdateHandler );
            d.removeEventListener( PropertyChangingEvent.PROPERTY_CHANGING, itemUpdateHandler );
        }
    }

}

}
