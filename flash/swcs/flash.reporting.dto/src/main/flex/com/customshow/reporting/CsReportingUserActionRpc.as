/**
 * Created by gary.yang.customshow on 2/20/2015.
 */
package com.customshow.reporting {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;

import mx.utils.Base64Encoder;

public class CsReportingUserActionRpc {

    public function CsReportingUserActionRpc( fullUrl:String, payload:Object, awsGatewayApiKey:String = null, inTxt:Boolean = true ){
        _fullUrl = fullUrl;
        _payload = payload;
        _awsGatewayApiKey = awsGatewayApiKey;
        _inTxt = inTxt;
    }

    protected var _awsGatewayApiKey:String;
    public function get awsGatewayApiKey():String{
        return _awsGatewayApiKey;
    }

    protected var _inTxt:Boolean;
    public function get inTxt():Boolean{
        return _inTxt;
    }

    protected var _fullUrl:String;
    protected var _payload:Object;
    public function get payload():Object{
        return _payload;
    }

    protected var _urlRequest:URLRequest;
    protected var _urlLoader:URLLoader;

    protected var _bytesPayLoad:ByteArray;

    public function send():Boolean{
        _urlRequest = new URLRequest( _fullUrl );
        if( _payload is ByteArray ){
            _bytesPayLoad = _payload as ByteArray;
        }
        else{
            _bytesPayLoad = payloadToBytes();
        }
        if( _bytesPayLoad == null ){
            return false;
        }

        _urlRequest.method = URLRequestMethod.POST;
        _urlLoader = new URLLoader();

        if( _inTxt ){
            var cdr:Base64Encoder = new Base64Encoder();
            cdr.insertNewLines = false;
            cdr.encodeBytes( _bytesPayLoad );
            _urlRequest.data = cdr.toString();
            _urlRequest.contentType = "text/plain";

            if( _awsGatewayApiKey != null && _awsGatewayApiKey.length > 0 ){
                _urlRequest.requestHeaders = [ new URLRequestHeader( "x-api-key", _awsGatewayApiKey ) ];
            }
        }
        else{
            _urlRequest.data = _bytesPayLoad;
            _urlRequest.contentType = "application/x-amf";
        }
        _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

        _urlLoader.addEventListener( Event.COMPLETE, onDone );
        _urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onDone );
        _urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDone );

        _urlLoader.load( _urlRequest );
        return true;
    }

    protected function payloadToBytes():ByteArray{
        if( _payload != null ){
            var bar:ByteArray = new ByteArray();
            bar.writeObject( _payload );
            return bar;
        }
        return null;
    }

    public var callBackOnDone:Function;

    protected function onDone( event:Event ):void{
        if( callBackOnDone != null ){
            try{
                callBackOnDone.apply( null, [ event ] );
            }
            catch( e:Error ){
                CONFIG::debugging{
                    throw e;
                }
            }
        }
        _urlLoader.removeEventListener( Event.COMPLETE, onDone );
        _urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onDone );
        _urlLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onDone );
        _urlLoader = null;
        _payload = null;
        _urlRequest = null;
        _bytesPayLoad = null;


        CONFIG::debugging{
            if( event is IOErrorEvent || event is SecurityErrorEvent ){
                trace( event );
            }
        }//debug
    }

}
}
