/**
 * Generated by com.customshow.codegen
 *
 */
package com.customshow.solr.query.web.common{

import mx.events.PropertyChangeEvent;
import com.flashflexpro.as3lib.data.PropertyDesc;
import flash.events.EventDispatcher;

[Bindable]
[RemoteClass(alias="com.customshow.solr.query.web.common.DtoFacetResult")]
public class DtoFacetResult extends EventDispatcher {
    public function DtoFacetResult(){
    }

    private static var _allProperties:Vector.<PropertyDesc> = null;
    public static function get allProperties():Vector.<PropertyDesc>{
        if( _allProperties == null ){
            _allProperties = properties;
        }
        return _allProperties;
    }
    private static var _properties:Vector.<PropertyDesc> = null;
    public static function get properties():Vector.<PropertyDesc>{
        if( _properties == null ){
            _properties = new <PropertyDesc>[ PROP_DESC_queryStr, 
                PROP_DESC_qStartRow, 
                PROP_DESC_qRowNum, 
                PROP_DESC_qMaxFacetTermNum, 
                PROP_DESC_qFacetFields, 
                PROP_DESC_rStartRow, 
                PROP_DESC_rNumFound, 
                PROP_DESC_rQueryRecords, 
                PROP_DESC_rFacetsRecords
            ];
        }
        return _properties;
    }
    public static const PROP_DESC_queryStr:PropertyDesc = new PropertyDesc( "queryStr" );
    public var queryStr:String;

    public static const PROP_DESC_qStartRow:PropertyDesc = new PropertyDesc( "qStartRow" );
    public var qStartRow:Number;

    public static const PROP_DESC_qRowNum:PropertyDesc = new PropertyDesc( "qRowNum" );
    public var qRowNum:Number;

    public static const PROP_DESC_qMaxFacetTermNum:PropertyDesc = new PropertyDesc( "qMaxFacetTermNum" );
    public var qMaxFacetTermNum:int;

    public static const PROP_DESC_qFacetFields:PropertyDesc = new PropertyDesc( "qFacetFields" );
    public var qFacetFields:Array;

    public static const PROP_DESC_rStartRow:PropertyDesc = new PropertyDesc( "rStartRow" );
    public var rStartRow:Number;

    public static const PROP_DESC_rNumFound:PropertyDesc = new PropertyDesc( "rNumFound" );
    public var rNumFound:Number;

    public static const PROP_DESC_rQueryRecords:PropertyDesc = new PropertyDesc( "rQueryRecords" );
    public var rQueryRecords:Array;

    public static const PROP_DESC_rFacetsRecords:PropertyDesc = new PropertyDesc( "rFacetsRecords" );
    public var rFacetsRecords:Object;

}
}