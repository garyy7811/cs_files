/**
 * Created by gary.y on 8/24/2016.
 */
package com.flashflexpro.as3lib.utils {
import flash.events.Event;

public class EscalateFromContextEvent extends Event {
    private const TYPE:String = "escalateFromInside";

    public function EscalateFromContextEvent( args:Array ){
        super( TYPE );
        _args = args;
    }

    private var _args:Array;


    public function get args():Array{
        return _args;
    }

    override public function clone():Event{
        return new EscalateFromContextEvent( _args );
    }
}
}
