/**
 * Created by gary.y on 5/23/2016.
 */
package com.flashflexpro.as3lib.win {
public class TBPanelAlert {


    public function TBPanelAlert( message:String, title:String, flags:uint, overTitle:Boolean = false,
                                  closeHandler:Function = null, closeHandlerThis:Object = null ){
        _message = message;
        _title = title;
        _flags = flags;
        _overTitle = overTitle;
        _closeHandler = closeHandler;
        _closeHandlerThis = closeHandlerThis;
    }

    private var _message:String;
    private var _title:String;
    private var _flags:uint;
    private var _overTitle:Boolean = false;
    private var _closeHandler:Function;
    private var _closeHandlerThis:Object;


    public function get message():String{
        return _message;
    }

    public function get title():String{
        return _title;
    }

    public function get flags():uint{
        return _flags;
    }

    public function get closeHandler():Function{
        return _closeHandler;
    }

    public function get overTitle():Boolean{
        return _overTitle;
    }

    public function get closeHandlerThis():Object{
        return _closeHandlerThis;
    }

    public static const YES:uint = 0x0001;

    /**
     *  Value that enables a No button on the Alert control when passed
     *  as the <code>flags</code> parameter of the <code>show()</code> method.
     *  You can use the | operator to combine this bitflag
     *  with the <code>OK</code>, <code>CANCEL</code>,
     *  <code>YES</code>, and <code>NONMODAL</code> flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const NO:uint = 0x0002;

    /**
     *  Value that enables an OK button on the Alert control when passed
     *  as the <code>flags</code> parameter of the <code>show()</code> method.
     *  You can use the | operator to combine this bitflag
     *  with the <code>CANCEL</code>, <code>YES</code>,
     *  <code>NO</code>, and <code>NONMODAL</code> flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const OK:uint = 0x0004;

    /**
     *  Value that enables a Cancel button on the Alert control when passed
     *  as the <code>flags</code> parameter of the <code>show()</code> method.
     *  You can use the | operator to combine this bitflag
     *  with the <code>OK</code>, <code>YES</code>,
     *  <code>NO</code>, and <code>NONMODAL</code> flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CANCEL:uint = 0x0008;
}
}
