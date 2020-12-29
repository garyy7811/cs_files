/**
 * Created by gary.y on 5/6/2016.
 */
package com.flashflexpro.as3lib.win {

import com.flashflexpro.as3lib.IWithContext;
import com.flashflexpro.as3lib.utils.RootContextModule;

import flash.errors.StackOverflowError;
import flash.events.Event;


[Bindable]
public class Dividable implements IDividable {

    public function Dividable( parent:IDividable, sModel:IWithContext = null, child1:Dividable = null, child2:Dividable = null, isVer:Boolean = false ){
        if( sModel == null && ( child1 == null || child2 == null ) ){
            throw  new ArgumentError();
        }

        this._parent = parent;/*
        if( _parent != null ){
            _root = ( _parent is IDividableHook ? _parent as IDividableHook : (_parent as Dividable).root );
        }
        //else  only happens on the very initial of the root;*/

        this._sModel = sModel;
        this._child1 = child1;
        this._child2 = child2;
        this._isVer = isVer;

        if( sModel == null ){
//            child1._root = _root;
//            child2._root = _root;
            child1.setParent( this );
            child2.setParent( this );
        }
    }


    private var _parent:IDividable;

    [Bindable(event="parentChanged")]
    public function get parent():IDividable{
        return _parent;
    }

    public function setParent( value:IDividable ):void{
        if( value != _parent ){
            _parent = value;
            dispatchEvent( new Event( "parentChanged" ) );
        }
    }


    private var _sModel:IWithContext;
    [Bindable(event="childrenChanged")]
    public function get sModel():IWithContext{
        return _sModel;
    }

    private var _child1:Dividable;
    [Bindable(event="childrenChanged")]
    public function get child1():Dividable{
        return _child1;
    }

    private var _child2:Dividable;
    [Bindable(event="childrenChanged")]
    public function get child2():Dividable{
        return _child2;
    }

    private var _isVer:Boolean;
    [Bindable(event="childrenChanged")]
    public function get isVer():Boolean{
        return _isVer;
    }

    public function setChildren( s:IWithContext, c1:Dividable, c2:Dividable = null, isv:Boolean = false ):void{
        if( c1 == null && c2 != null ){
            throw new Error();
        }
        if( c1 != null && c2 == null ){
            throw new Error();
        }
        if( s == null && c1 == null && c2 == null ){
            throw new Error();
        }
        var cgd:Boolean = false;

        if( s != _sModel ){
            _sModel = s;
            cgd = true;
        }

        if( c1 != _child1 ){
            _child1 = c1;
            if( _child1 != null ){
                _child1.setParent( this );
            }
            cgd = true;
        }
        if( c2 != _child2 ){
            _child2 = c2;
            if( _child2 != null ){
                _child2.setParent( this );
            }
            cgd = true;
        }
        if( isv != _isVer && _child1 != null && _child2 != null ){
            _isVer = isv;
            cgd = true;
        }
        if( cgd ){
            dispatchEvent( new Event( "childrenChanged" ) );
        }
    }


    public function divide( newChild:IWithContext, isVer:Boolean, newInFrontOfExist:Boolean ):void{
        CONFIG::debugging{
            if( sModel == null || newChild == null ){
                throw new StackOverflowError();
            }
        }

        /* if( newChild is Dividable ){
         child1 = newInFrontOfExist ? Dividable( newChild ) :
         new Dividable( this, newInFrontOfExist ? sModel : newChild );
         child2 = newInFrontOfExist ? new Dividable( this, newInFrontOfExist ? sModel : newChild ) :
         Dividable( newChild );

         }
         else{*/
        //        }


        setChildren( null, new Dividable( this, newInFrontOfExist ? newChild : sModel ), new Dividable( this, newInFrontOfExist ? sModel : newChild ), isVer );

        /*
         if( newChild is IDividableAware ){
         newChild.dividable = child1;
         }
         */

        CONFIG::debugging{
            CC.log( "Dividable.divide->arguments:" + arguments.join( "," ) + " divide[ " + child1 + "|" + child2 + "]" );
        }//debug
    }


    private function removeChild( target:Dividable ):void{
        CONFIG::debugging{
            if( target == null || ( target != child1 && target != child2 ) ){
                throw new ArgumentError();
            }
        }//debug
        var p:IDividable = _parent;
        var pdv:Dividable = p as Dividable;
        var left:Dividable = ( target == child1 ? child2 : child1);

        if( p.child1 == this ){
            p.setChildren( null, left, pdv != null ? pdv._child2 : null, pdv != null ? pdv._isVer : false );
        }
        else{
            CONFIG::debugging{
                if( p[ "child2" ] != this ){
                    throw new Error( "" );
                }//debug
            }
            p.setChildren( null, p.child1, left, pdv != null ? pdv._isVer : false );
        }

        destroy();
    }

    public function removeSelf():Boolean{
        if( _parent is Dividable ){
            ( _parent as Dividable ).removeChild( this );
            destroy();
            return true;
        }
        return false;
    }

    public function destroy():void{
        _parent = null;
        _sModel = null;
        _child1 = null;
        _child2 = null;
    }


    public function toString():String{
        var s:String = "";
        var tmp:Dividable = this;
        while( tmp != null ){
            var p:Dividable = tmp._parent as Dividable;
            if( p != null ){
                s = ( p.child1 == tmp ? "1/" : "2/" ) + s;
            }
            tmp = p;
        }
        return s;
    }


    private var _context:RootContextModule;
    [Bindable(event="contextChanged")]
    public function get context():RootContextModule{
        return _context == null ? _parent.context : _context;
    }

    public function set context( value:RootContextModule ):void{
        if( value != _context ){
            _context = value;
            dispatchEvent( new Event( "contextChanged" ) );
        }
    }

}
}
