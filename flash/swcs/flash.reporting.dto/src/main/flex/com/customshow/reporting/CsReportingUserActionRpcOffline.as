/**
 * Created by gary.yang.customshow on 2/20/2015.
 */
package com.customshow.reporting {
import com.customshow.reporting.dto.DtoReportingActivity;

import flash.events.Event;
import flash.net.SharedObject;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;

public class CsReportingUserActionRpcOffline extends CsReportingUserActionRpc {

    public static const SHARED_OBJECT_NAME:String = "customshow.reporting.offline.message";
    public static const MAX_NUM_OFFLINE_MSG_PER_RPC:uint = 100;

    public function CsReportingUserActionRpcOffline( url:String, actPath:String, offlinePath:String,
                                                     payload:DtoReportingActivity, awsGatewayApiKey:String=null, inTxt:Boolean = false ){
        super( url + actPath, payload, awsGatewayApiKey, inTxt );
        _url = url;
        _offlinePath = offlinePath;
        _payloadAct = payload;
        if( _localSharedObj == null ){
            try {
                _localSharedObj = SharedObject.getLocal(SHARED_OBJECT_NAME);
            } catch (e:Error) {
                //user disabled shared object
                CONFIG::debugging{
                    throw e;
                }//debug
            }
        }
    }

    private static var _url:String;
    private static var _offlinePath:String;

    private static var _localSharedObj:SharedObject;

    private var _payloadAct:DtoReportingActivity;

    private static const TWO_MONTH:int = 60 * 24 * 3600 * 1000;

    override protected function payloadToBytes():ByteArray{
        var saving:ByteArray = super.payloadToBytes();
        if( _localSharedObj != null ){
            var sending:ByteArray = new ByteArray();
            sending.writeBytes( saving, 0, saving.length );
            saving.compress( CompressionAlgorithm.LZMA );

            _localSharedObj.data[ getActSOKey( _payloadAct ) ] = saving;
            try{
                _localSharedObj.flush();
            }
            catch( e:Error ){
                CONFIG::debugging{
                    throw e;
                }//debug
            }
        }
        return sending;
    }

    override protected function onDone( event:Event ):void{
        if( event.type == Event.COMPLETE ){
            if( _localSharedObj != null ){
                delete _localSharedObj.data[ getActSOKey( _payloadAct ) ];
                _localSharedObj.flush();
                sendOfflineMsgs( _awsGatewayApiKey, _inTxt );
            }
        }
        super.onDone( event );
        _payloadAct = null;
    }

    public static function sendOfflineMsgs( awsGatewayApiKey:String, inTxt:Boolean = false ):void{
        if( _offlineRpc != null ){
            return;
        }

        var needToFlush:Boolean = false;
        var offLineDtoArr:Array = [];
        var epicNow:Number = new Date().getTime();
        for( var tmpName:String in _localSharedObj.data ){
            try{
                var tmpSaveTime:Number = Number( tmpName.split( SPLIT_TIME )[ 1 ] );
                if( tmpSaveTime - epicNow > TWO_MONTH ){
                    throw new Error( "Session[ " + tmpName.split( SPLIT_TIME )[ 0 ] + " ] TOO OLD:" +
                            new Date( tmpSaveTime ) );
                }
                var ba:ByteArray = _localSharedObj.data[ tmpName ];
                ba.position = 0;
                ba.uncompress( CompressionAlgorithm.LZMA );
                offLineDtoArr.push( ba.readObject() );
            }
            catch( e:Error ){
                delete _localSharedObj.data[ tmpName ];
                needToFlush = true;
                CONFIG::debugging{
                    trace( e.getStackTrace() );
                }//debug
            }
            if( offLineDtoArr.length >= MAX_NUM_OFFLINE_MSG_PER_RPC ){
                break;
            }
        }
        if( offLineDtoArr.length > 0 ){
            offLineDtoArr.unshift( epicNow + "" );
            _offlineRpc = new CsReportingUserActionRpc( _url + _offlinePath, offLineDtoArr, awsGatewayApiKey, inTxt );
            _offlineRpc.callBackOnDone = onOfflineMsgDone;
            _offlineRpc.send();
        }
        if( needToFlush ){
            _localSharedObj.flush();
        }
    }

    private static var _offlineRpc:CsReportingUserActionRpc;

    private static function onOfflineMsgDone( ev:Event ):void{
        if( ev.type == Event.COMPLETE ){
            var offLineDtoArr:Array = _offlineRpc.payload as Array;
            for( var i:int = offLineDtoArr.length - 1; i > 0; i -- ){
                var activity:DtoReportingActivity = offLineDtoArr[ i ] as DtoReportingActivity;
                delete _localSharedObj.data[ getActSOKey( activity ) ];
            }
            try{
                _localSharedObj.flush();
            }
            catch( e:Error ){
                CONFIG::debugging{
                    throw e;
                }//debug
            }
        }
        var it:Boolean = _offlineRpc.inTxt;
        var ga:String = _offlineRpc.awsGatewayApiKey;
        _offlineRpc.callBackOnDone = null;
        _offlineRpc = null;
        sendOfflineMsgs( ga, it );
    }

    private static const SPLIT_TIME:String = "☆";

    private static function getActSOKey( activity:DtoReportingActivity ):String{
        return activity.flexClientId + SPLIT_TIME + activity.clientTime;
    }
}
}
