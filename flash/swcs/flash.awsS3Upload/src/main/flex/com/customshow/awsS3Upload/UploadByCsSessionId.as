/**
 * Created by gary.y on 2/11/2016.
 */
package com.customshow.awsS3Upload {

import com.flashflexpro.as3lib.utils.RootContextApp;

import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;

import flash.events.IOErrorEvent;

import flash.events.SecurityErrorEvent;

import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class UploadByCsSessionId {


    [Bindable]
    public var rpcServiceName:String = "awsS3UploadService";

    [Bindable]
    public var rpcMethodUploadResult:String = "uploadResult";

    [Bindable]
    public var rpcMethodUploadAuth:String = "authenticateUploading";

    public function UploadByCsSessionId( csSessionId:String, url:String ){
        _csSessionId = csSessionId;
        _url = url;
    }

    public function upload( file:FileReference, extraInfo:String = null ):void{
        if( _fileReference != null ){
            throw new Error( "Rpc call is in progress!" );
        }
        _fileReference = file;

        /*
         var getUploadAuth:RpcSpringMvcPost = new RpcSpringMvcPost();
         getUploadAuth.restUrl = _url;
         getUploadAuth.urlExtra = _csSessionId;
         getUploadAuth.callBackOnObjResult = onMetaReady;
         getUploadAuth.callBackOnError = onMetaReady;
         getUploadAuth.serviceName = rpcServiceName;
         getUploadAuth.remoteMethodName = rpcMethodUploadAuth;


         //directly call rpc without context support
         getUploadAuth.args = [_fileReference.creationDate, _fileReference.modificationDate, _fileReference.creator,
         _fileReference.name, fz, _fileReference.type, extraInfo];
         getUploadAuth.callRemote();
         */

        //use generated API with context support
        new AwsS3UploadService( RootContextApp.inst ).authenticateUploading( onMetaReady, onMetaReady,
                _fileReference.creationDate, _fileReference.modificationDate, _fileReference.creator,
                _fileReference.name, _fileReference.size, _fileReference.type, extraInfo ).callRemote();
    }

    [Bindable]
    public var applyRegisteredTime:Number = - 1;

    private var _fileType:String;

    private function onMetaReady( rt:Object ):Boolean{
        if( ! ( rt is Array ) ){
            error = ( rt is ErrorEvent ) ? rt.text : String( rt );
            _fileReference = null;
            return true;
        }
        var rtDt:Array = rt as Array;

        var vars:URLVariables = new URLVariables();
        vars.acl = "private";
        vars.success_action_status = "201";

        vars.AWSAccessKeyId = rtDt[1];
        vars.key = rtDt[2];
        vars.policy = rtDt[3];
        vars.signature = rtDt[4];//"ASIAJOXAFBNVKUEEHALQ"

        var urlOrBucketName:String = rtDt[0];
        var urlRequest:URLRequest = new URLRequest();
        if( urlOrBucketName.indexOf( "http" ) == 0 ){
            urlRequest.url = urlOrBucketName;
        }
        else{
            urlRequest.url = "https://" + urlOrBucketName + ".s3.amazonaws.com/";
        }
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = vars;

        _fileReference.addEventListener( IOErrorEvent.IO_ERROR, onUpload );
        _fileReference.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onUpload );
        _fileReference.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onUpload );
        _fileReference.upload( urlRequest, "file" );

        applyRegisteredTime = rtDt[5];
        _fileType = rtDt[6];
        return true;
    }

    private function onUpload( event:Event ):void{
        _fileReference.removeEventListener( IOErrorEvent.IO_ERROR, onUpload );
        _fileReference.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onUpload );
        _fileReference.removeEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onUpload );
        var rslt:Array;
        if( event is ErrorEvent ){
            var errorEvent:ErrorEvent = event as ErrorEvent;
            rslt = [applyRegisteredTime, errorEvent.errorID, errorEvent.toString(), errorEvent.text];
            error = event;
        }
        else{
            rslt = [applyRegisteredTime];
        }
        /*
         //directly call rpc without context support
         var postUploadRslt:RpcSpringMvcPost = new RpcSpringMvcPost();
         postUploadRslt.restUrl = _url;
         postUploadRslt.urlExtra = _csSessionId;
         postUploadRslt.serviceName = rpcServiceName;
         postUploadRslt.remoteMethodName = rpcMethodUploadResult;
         postUploadRslt.args = rslt;
         postUploadRslt.callRemote();
         */

        //use generated API with context support
        new AwsS3UploadService( RootContextApp.inst ).uploadResult( null, null, applyRegisteredTime,
                rslt.length > 1 ? rslt[1] : null, rslt.length > 2 ? rslt[2] : null,
                rslt.length > 3 ? rslt[3] : null ).callRemote();

        _fileReference = null;
    }

    [Bindable]
    public var error:* = null;

    private var _url:String;
    private var _csSessionId:String;
    private var _fileReference:FileReference;

    public function get fileReference():FileReference{
        return _fileReference;
    }
}
}