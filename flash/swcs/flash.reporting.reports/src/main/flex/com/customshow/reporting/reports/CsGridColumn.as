/**
 * Created by flash on 5/11/2017.
 */
package com.customshow.reporting.reports {
import flash.net.SharedObject;

import spark.components.gridClasses.GridColumn;

public class CsGridColumn extends GridColumn {

    public function CsGridColumn( label:String, width:int = 0 ){
        this.headerText = label;
        if( _localSharedObj == null ){
            try{
                _localSharedObj = SharedObject.getLocal( SHARED_OBJECT_NAME );
            }
            catch( e:Error ){
                //user disabled shared object
                CONFIG::debugging{
                    throw e;
                }//debug
            }
        }

        if( _localSharedObj != null && _localSharedObj.data[headerText] > 0 ){
            this.width = _localSharedObj.data[headerText];
        }
        else if( width > 0 ){
            this.width = width;
        }
    }


    public static const SHARED_OBJECT_NAME:String = "customshow.reporting.console.grid.column.width";
    private static var _localSharedObj:SharedObject;

    override public function set width( value:Number ):void{
        if( _localSharedObj != null && _localSharedObj.data[headerText] != value ){
            _localSharedObj.data[headerText] = value;
            try{
                _localSharedObj.flush();
            }
            catch( e:Error ){
                CONFIG::debugging{
                    throw e;
                }//debug
            }
        }

        super.width = value;
    }
}
}
