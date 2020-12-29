package com.customshow.awsS3Upload {
import com.flashflexpro.as3lib.rpc.RpcSpringMvcPost;

import flash.events.ErrorEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLRequestHeader;
import flash.utils.ByteArray;


public class SlideThumbnailUploader extends  EventDispatcher {


    private static var rpcServiceName:String = "awsS3UploadService";
    private static var  rpcMethodAuthSlideThumbnail:String = "authenticateSlideThumbnailUpload";

    private var _apiUrl:String;
    private var _csSessionId:String;
    private var _csSlideId:Number;
    private var _s3ObjectPattern:String = null;


    private var _lastAuthResult:Object;
    private var _lastAuthTtl:Number;
    private var _lastAuthResulTimestamp:Number;

    private var _pendingFileName:String;
    private var _pendingS3ObjectKey:String;
    private var _pendingContentType:String;
    private var _pendingFileBytes:ByteArray;

    private var _lastS3Post:S3Post;

    public var error:String = null;
    public var errorEvent:ErrorEvent = null;


    public function SlideThumbnailUploader(apiUrl:String, csSessionId:String, csSlideId:Number, s3ObjectPattern:String) {
        _apiUrl = apiUrl;
        _csSessionId = csSessionId;
        _csSlideId = csSlideId;
        _s3ObjectPattern = s3ObjectPattern;
    }


    public function uploadThumbnail(fileName:String, s3ObjectKey:String, contentType:String, fileBytes:ByteArray) : void {

        _pendingFileName = fileName;
        _pendingS3ObjectKey = s3ObjectKey;
        _pendingContentType = contentType;
        _pendingFileBytes = fileBytes;

        // if we haven't authenticated at all, do so now
        if (isNaN(_lastAuthResulTimestamp)) {
            doAuthentication();
            return;
        }

        // if previous authentication's ttl has passed the halfway mark, re-authenticate
        var currentTimestamp = new Date().getTime();
        var millisSinceLastAuthenticaiton:Number = currentTimestamp - _lastAuthResulTimestamp;
        if (millisSinceLastAuthenticaiton > (_lastAuthTtl / 2)) {
            doAuthentication();
            return;
        }

        // proceed with upload
        doUpload();

    }

    protected function doAuthentication() : void {


        var getUploadAuth:RpcSpringMvcPost = new RpcSpringMvcPost();
        getUploadAuth.restUrl = _apiUrl;
        getUploadAuth.urlExtra = _csSessionId;
        getUploadAuth.serviceName = rpcServiceName;
        getUploadAuth.remoteMethodName = rpcMethodAuthSlideThumbnail;
        getUploadAuth.serverHandleType = RpcSpringMvcPost.SERVER_TYPE_AWS_API_GATEWAY_JSON;
        getUploadAuth.callBackOnError = onAuthRequestError;
        getUploadAuth.callBackOnObjResult = onAuthRequestComplete;

        getUploadAuth.timeout

        getUploadAuth.args = [_csSlideId, _s3ObjectPattern];

        getUploadAuth.callRemote();

    }


    /**
     * callBackOnError - should only ever be passed an ErrorEvent passed on from rpc fault
     *
     * @param event
     */
    private function onAuthRequestError(event:ErrorEvent) : void {

        // hold onto the event
        errorEvent = event;

        // get the error message
        error = event.text;

        // dispatch another event
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Remote error: " + error));
    }


    /**
     * callBackOnObjResult - we expect  an Array passed on success, otherwise it is an unexpected error
     *
     * This call is intended to return true on successful processing.
     *
     * @param result
     * @return
     */
    private function onAuthRequestComplete( result:Object ):Boolean {

        if (!( result is Array )) {
            // this is an unexpected error - cast result to a string, dispatch an ErrorEvent,
            // and return true to halt further processing
            error = String(result);
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Unexpected authentication response"));
            return true;
        }

        // always hold onto the actual result...
        _lastAuthResult = result;

        //Object[]{ awsS3DownloadUrl, awsAccessKeyId, acl, encodedPolicy, signature, ttl }

        // get the ttl from the response
        _lastAuthTtl = _lastAuthResult[5] as Number;

        // get the current milliseconds
        _lastAuthResulTimestamp = new Date().getTime();

        doUpload();

        return true;
    }

    private function doUpload() : void {


        //Object[]{ awsS3DownloadUrl, awsAccessKeyId, acl, encodedPolicy, signature, ttl }
        _lastS3Post = new S3Post(
                _lastAuthResult[0],
                _lastAuthResult[1],
                _lastAuthResult[2],
                _lastAuthResult[3],
                _lastAuthResult[4],
                _pendingS3ObjectKey,
                _pendingFileName,
                _pendingContentType,
                _pendingFileBytes
        );


        _lastS3Post.addEventListener(ErrorEvent.ERROR, onUploadError);
        _lastS3Post.addEventListener(Event.COMPLETE, onUploadComplete);

        _lastS3Post.doPost();
    }

    private function  onUploadError(e:ErrorEvent) : void {

        errorEvent = e;
        error = e.text;

        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Unexpected error uploading thumbnail: " + e.text));

    }

    private function onUploadComplete(e:Event) : void {

        dispatchEvent(new Event(Event.COMPLETE));

    }





}
}
