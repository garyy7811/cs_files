/**
 * Created by gary.y on 4/28/2016.
 */
package com.flashflexpro.as3lib.utils {
import com.flashflexpro.as3lib.IByModel;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import mx.core.DragSource;


[Bindable]
public class CtxDragSource extends DragSource implements IByModel {
    public function CtxDragSource(){
    }

    import com.flashflexpro.as3lib.IWithContext;


    private var _model:IWithContext;

    public function set model( m:IWithContext ):void{
        _model = m;
    }

    public function get model():IWithContext{
        return _model;
    }

    private var _mouseDragging:MouseEvent;
    [Bindable(event="mouseDraggingChanged")]
    public function get mouseDragging():MouseEvent{
        return _mouseDragging;
    }

    public function drag( value:MouseEvent ):void{
        if( value != _mouseDragging ){
            _mouseDragging = value;
            dispatchEvent( new Event( "mouseDraggingChanged" ) );
            _model.context.drag( this );
        }
    }
}
}
