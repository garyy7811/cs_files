/**
 * Created by yanggang on 4/2/2016.
 */
package com.flashflexpro.as3lib.data {
public class PropertyDesc {

    public function PropertyDesc( name:String, notEmpty:Boolean = false, readOnly:Boolean = false,
                                  stringRegexp:String = "", enumStrings:Array = null ){
        _name = name;
        _notEmpty = notEmpty;
        _readOnly = readOnly;
        _stringRegexp = stringRegexp;
        _enumStrings = enumStrings;
    }

    private var _name:String;
    private var _notEmpty:Boolean;
    private var _readOnly:Boolean;
    private var _stringRegexp:String;
    private var _enumStrings:Array;

    public function get name():String{
        return _name;
    }

    public function get notEmpty():Boolean{
        return _notEmpty;
    }

    public function get readOnly():Boolean{
        return _readOnly;
    }

    public function get stringRegexp():String{
        return _stringRegexp;
    }

    public function get enumStrings():Array{
        return _enumStrings;
    }


    public function toString():String{
        return "PropertyDesc{_name=" + String( _name ) + ",_notEmpty=" + String( _notEmpty ) + ",_readOnly=" +
                String( _readOnly ) + ",_stringRegexp=" + String( _stringRegexp ) + ",_enumStrings=" +
                String( _enumStrings ) + "}";
    }
}
}
