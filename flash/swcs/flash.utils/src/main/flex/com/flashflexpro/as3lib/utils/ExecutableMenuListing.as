/**
 * Created with IntelliJ IDEA.
 * User: garyyang
 * Date: 10/18/13
 * Time: 10:04 AM
 * To change this template use File | Settings | File Templates.
 */
package com.flashflexpro.as3lib.utils {

import mx.collections.ArrayCollection;


public class ExecutableMenuListing extends ExecutableMenuItem {
    public function ExecutableMenuListing( children:Array, target:Object = null, label:String = "More" ){
        this.target = target;
        this.label = label;

        children.forEach( function ( i:ExecutableMenuItem, index:int, a:Array ):void{
            i._parent = this;
            if( i.moduleContext == null ){
                i.moduleContext = moduleContext;
            }
        }, this );

        _children = new ArrayCollection( children );

    }

    private var _children:ArrayCollection;

    public function get children():ArrayCollection{
        return _children;
    }

    override public function destroy():void{
        if( children != null ){
            for( var i:int = children.length - 1; i >= 0; i -- ){
                ( children.getItemAt( i ) as ExecutableMenuItem ).destroy();
            }
            children.removeAll();
            _children = null;
        }
        super.destroy();
    }
}
}
