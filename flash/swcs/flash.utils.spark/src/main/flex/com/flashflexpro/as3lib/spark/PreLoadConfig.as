/**
 * @author flashflexpro@gmail.com
 * Date: 3/27/13
 * Time: 10:00 AM
 */
package com.flashflexpro.as3lib.spark {

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getDefinitionByName;

import mx.core.Singleton;
import mx.preloaders.SparkDownloadProgressBar;

public class PreLoadConfig extends SparkDownloadProgressBar {

    public function PreLoadConfig(){
    }

    override public function set preloader( value:Sprite ):void{
        _prld = value;
        _prld.addEventListener( Event.COMPLETE, beforeSysMngrKickOff, false, int.MAX_VALUE );
        super.preloader = value;
    }

    private var _prld:Sprite;

    private function beforeSysMngrKickOff( event:Event ):void{
        var t:ToolTipManagerImplExt;
        Singleton.registerClass( "mx.managers::IToolTipManager2",
                                 Class( getDefinitionByName( "com.flashflexpro.as3lib.spark.ToolTipManagerImplExt" ) ) );

        _prld.removeEventListener( Event.COMPLETE, beforeSysMngrKickOff );
        _prld = null;
    }

}
}
