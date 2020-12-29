/**
 * Created with IntelliJ IDEA.
 * User: garyyang
 * Date: 5/15/13
 * Time: 3:57 PM
 * To change this template use File | Settings | File Templates.
 */
package com.flashflexpro.as3lib.utils {
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class ExecutableItemMenuLink extends ExecutableMenuItem {

    public function ExecutableItemMenuLink( url:String, label:String ){
        this.label = label;
        _url = url;
    }

    private var _url:String;

    override protected function onExecute():void{
        navigateToURL( new URLRequest( _url ), "_blank" );
    }
}
}
