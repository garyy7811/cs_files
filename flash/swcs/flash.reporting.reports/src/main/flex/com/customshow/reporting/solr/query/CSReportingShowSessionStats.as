/**
 * Generated by com.customshow.codegen
 *
 */
package com.customshow.reporting.solr.query{

import com.flashflexpro.as3lib.utils.RootContextModule;
import com.flashflexpro.as3lib.rpc.RpcSpringMvcPost;
import com.flashflexpro.as3lib.rpc.RpcService;


//@see com.customshow.reporting.solr.query.CSReportingShowSessionStats
public class CSReportingShowSessionStats extends RpcService{
    public function CSReportingShowSessionStats( context:RootContextModule ){
        super( context );
    }

    public static const RPC_queryTotal:String = "queryTotal";
    public function queryTotal( result:Function, fault:Function, arg1:Array, arg2:Number, arg3:Number ):RpcSpringMvcPost{
        return createRpcPost( RPC_queryTotal, arguments );
    }

    public static const RPC_queryGrid:String = "queryGrid";
    public function queryGrid( result:Function, fault:Function, arg1:Array, arg2:Number, arg3:Number, arg4:String, arg5:Boolean, arg6:int, arg7:int, arg8:Vector.<String> ):RpcSpringMvcPost{
        return createRpcPost( RPC_queryGrid, arguments );
    }
}}