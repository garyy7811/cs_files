/**
 * Created with IntelliJ IDEA.
 * User: garyyang
 * Date: 4/11/13
 * Time: 3:59 PM
 * To change this template use File | Settings | File Templates.
 */
package com.customshow.solr {


import com.flashflexpro.as3lib.utils.ExecutableMenuItem;

public class OperationAddRemoveColumn extends ExecutableMenuItem {

    public function OperationAddRemoveColumn( result:Result, field:QueryField ){
        super();
        label = field.label;
        target = result;
        type = ExecutableMenuItem.TYPE_CHECK;
        toggled = ( result.columnFields.getItemIndex( field ) >= 0 );

        _field = field;
        toolTip = "#t(searchResultLiteField_" + field.toolTip + ")p#";
    }

    [Bindable(event="targetChanged")]
    public function get result():Result{
        return target as Result;
    }

    private var _field:QueryField;

    override protected function onExecute():void{
        if( result.columnFields.getItemIndex( _field ) >= 0 ){
            result.columnFields.removeItem( _field );
        }
        else{
            result.columnFields.addItem( _field );
        }
    }
}
}
