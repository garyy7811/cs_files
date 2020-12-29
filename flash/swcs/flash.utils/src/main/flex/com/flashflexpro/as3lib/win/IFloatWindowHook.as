/**
 * Created by yanggang on 5/7/2016.
 */
package com.flashflexpro.as3lib.win {
import com.flashflexpro.as3lib.IByModel;
import com.flashflexpro.as3lib.IWithContext;


public interface IFloatWindowHook {


    function getUiByModel( m:IWithContext, createNew:Boolean = true ):IByModel;

}
}
