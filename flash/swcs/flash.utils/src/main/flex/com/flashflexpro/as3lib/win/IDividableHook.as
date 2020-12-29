/**
 * Created by yanggang on 5/7/2016.
 */
package com.flashflexpro.as3lib.win {
import com.flashflexpro.as3lib.IWithContext;

import mx.events.DragEvent;

public interface IDividableHook extends IFloatWindowHook{


    function getDraggingModel( ev:DragEvent ):IWithContext;

    function get floatingWindows():WinFloatingContainer;

}
}
