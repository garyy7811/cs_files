package com.flashflexpro.as3lib.data {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

[Event(name="crMapLengthChanged", type="flash.events.Event")]
[Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]
[Event(name="propertyChanging", type="com.flashflexpro.as3lib.data.PropertyChangingEvent")]

[RemoteClass(alias="com.flashflexpro.graniteds.CrMap")]
public class CrMap extends EventDispatcher implements IExternalizable {

    public function CrMap(){
        _key2valueCache = new Dictionary( true );
        _value2keyCache = new Dictionary( true );
    }

    public static const CRMAP_LENGTH_CHANGED:String = "crMapLengthChanged";

    private var _key2valueCache:Dictionary;
    private var _value2keyCache:Dictionary;

    private var _keys:Vector.<Object> = new Vector.<Object>();
    public function get keys():Vector.<Object>{
        return _keys;
    }

    private var _values:Vector.<Object> = new Vector.<Object>();
    public function get values():Vector.<Object>{
        return _values;
    }

    public function writeExternal( output:IDataOutput ):void{
        output.writeObject( _keys );
        output.writeObject( _values );
    }


    public function readExternal( input:IDataInput ):void{
        clear();
        _keys = input.readObject();
        _values = input.readObject();
        for( var i:int = _keys.length - 1; i >= 0; i -- ){
            var v:Object = _values[i];
            var k:Object = _keys[i];
            _key2valueCache[k] = v;
            _value2keyCache[v] = k;
        }
    }

    public function getValue( key:* ):*{
        return _key2valueCache[key];
        /*
         var index:int = _keys.indexOf( key );
         if( index < 0 ){
         return null;
         }
         return _values[ index ];*/
    }

    public function getKey( value:* ):*{
        return _value2keyCache[value];
        /*
         var index:int = _values.indexOf( value );
         if( index < 0 ){
         return null;
         }
         return _keys[ index ];*/
    }

    public function putValue( key:*, value:* ):*{
        CONFIG::debugging{
            if( key == null ){
                CC.log( this + ".putValue key can not be null!", 2, true );
            }//debug
        }

        if( _key2valueCache[key] == null ){
            if( value != null ){
                if( hasEventListener( PropertyChangingEvent.PROPERTY_CHANGING ) ){
                    dispatchEvent(
                            new PropertyChangingEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangingEvent.PROPERTY_CHANGE_KIND_ADDING, key, null, value, this ) );
                }

                _keys.push( key );
                _values.push( value );
                _key2valueCache[key] = value;
                _value2keyCache[value] = key;
                if( hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) ){
                    dispatchEvent(
                            new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangingEvent.PROPERTY_CHANGE_KIND_ADDED, key, null, value, this ) );
                }
                if( hasEventListener( CRMAP_LENGTH_CHANGED ) ){
                    dispatchEvent( new Event( CRMAP_LENGTH_CHANGED ) );
                }
                return true;
            }
        }
        else{
            var index:int = _keys.indexOf( key );
            var old:* = _values[index];
            if( old != value ){
                if( hasEventListener( PropertyChangingEvent.PROPERTY_CHANGING ) ){
                    dispatchEvent(
                            new PropertyChangingEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, key, old, value, this ) );
                }

                _values[index] = value;
                _key2valueCache[key] = value;
                _value2keyCache[value] = key;
                if( hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) ){
                    dispatchEvent(
                            new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, key, old, value, this ) );
                }
                return old;
            }
        }
        return null;
    }

    public function hasKey( key:* ):Boolean{
        return _keys.indexOf( key ) >= 0;
    }


    public function hasValue( val:* ):Boolean{
        return _values.indexOf( val ) >= 0;
    }


    public function deleteValue( name:* ):*{
        CONFIG::debugging{
            if( name == null || name == undefined ){
                CC.log( "unacceptable!", 2, true );
            }
        }
        var index:int = _keys.indexOf( name );
        if( index >= 0 ){
            var old:* = _values[index];
            if( hasEventListener( PropertyChangingEvent.PROPERTY_CHANGING ) ){
                dispatchEvent(
                        new PropertyChangingEvent( PropertyChangingEvent.PROPERTY_CHANGING, false, false, PropertyChangeEventKind.DELETE, name, old, null, this ) );
            }
            _keys.splice( index, 1 );
            delete  _key2valueCache[name];
            var deletingValue:Vector.<Object> = _values.splice( index, 1 );
            CONFIG::debugging{
                if( deletingValue.length == 0 ){
                    CC.log( this + ".deleteValue error, missing pair when deleting, key: " + name, 2, true );
                }//debug
            }
            delete _value2keyCache[deletingValue[0]];

            if( hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) ){
                dispatchEvent(
                        new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.DELETE, name, old, null, this ) );
            }
            if( hasEventListener( CRMAP_LENGTH_CHANGED ) ){
                dispatchEvent( new Event( CRMAP_LENGTH_CHANGED ) );
            }

            return old;
        }
        return null;
    }

    /**
     * PropertyChangeEvent.PROPERTY_CHANGE only works if the event.property is "length" !!
     */
    [Bindable(event="crMapLengthChanged")]
    public function get length():uint{
        return _keys.length;
    }

    public function clear():Boolean{
        if( _keys.length > 0 ){
            const len:int = _keys.length;
            var i:int = 0;
            if( hasEventListener( PropertyChangingEvent.PROPERTY_CHANGING ) ){
                for( i = 0; i < len; i ++ ){
                    dispatchEvent(
                            new PropertyChangingEvent( PropertyChangingEvent.PROPERTY_CHANGING, false, false, PropertyChangeEventKind.DELETE, _keys[i], _values[i], null, this ) );
                }
            }

            var tmpChangedEventLst:Vector.<PropertyChangeEvent>;
            if( hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) ){
                tmpChangedEventLst = new <PropertyChangeEvent>[];
                for( i = 0; i < len; i ++ ){
                    tmpChangedEventLst.push(
                            new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.DELETE, _keys[i], _values[i], null, this ) );
                }
            }
            _keys = new <Object>[];
            _values = new <Object>[];
            _key2valueCache = new Dictionary( true );
            _value2keyCache = new Dictionary( true );

            if( tmpChangedEventLst != null ){
                for( i = 0; i < len; i ++ ){
                    dispatchEvent( tmpChangedEventLst[i] );
                }
            }


            if( hasEventListener( CRMAP_LENGTH_CHANGED ) ){
                dispatchEvent( new Event( CRMAP_LENGTH_CHANGED ) );
            }
            return true;
        }
        return false;
    }
}
}
