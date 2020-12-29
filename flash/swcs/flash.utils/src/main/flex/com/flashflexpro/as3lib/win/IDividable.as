/**
 * Created by yanggang on 5/7/2016.
 */
package com.flashflexpro.as3lib.win {
import com.flashflexpro.as3lib.IWithContext;

public interface IDividable extends IWithContext{

    function get child1():Dividable;

    function setChildren( s:IWithContext, c1:Dividable, c2:Dividable = null, isv:Boolean = false ):void;
    
}
}
