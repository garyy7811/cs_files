/**
 * Created by gary.y on 2/11/2016.
 */
package com.customshow.awsS3Upload {

import com.flashflexpro.as3lib.rpc.RpcSpringMvcPost;

import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

public class FileUploader extends EventDispatcher {


    // rpc service configuration
    private static var rpcUploadServiceName:String = "awsS3UploadService";
    private static var rpcProcessServiceName:String = "processImgFlaService";
    private static var rpcMethodUploadAuth:String = "authenticateUploading";
    private static var rpcMethodUploadResult:String = "uploadResult";
    private static var rpcMethodProcessImage:String = "processImage";
    private static var rpcMethodPostFlashThumbnail:String = "postFlashThumbnail";

    private var _url:String;
    private var _csSessionId:String;
    private var _fileReference:FileReference;

    private var _fileBytes:ByteArray;
    private var _fileName:String;
    private var _fileContentType:String;
    private var _lastS3Post:S3Post;


    private var _csCloudUploadKey:String = null;


    private var _flashThumbBytes:ByteArray;
    private var _flashThumbWidth:Number;
    private var _flashThumbHeight:Number;
    private var _flashWidth:Number;
    private var _flashHeight:Number;


    /**
     * timestamp from server forming unique id of uploaded file
     */
    private var _applyRegisteredTime:Number;

    private var _csCloudUploadFileType:String;

    private var _csCoreResourceType:String;

    public function FileUploader( csSessionId:String, url:String ){
        _csSessionId = csSessionId;
        _url = url;
    }


    public var authResult:Object;

    public var error:String = null;
    public var errorEvent:ErrorEvent = null;


    public function get fileReference():FileReference{
        return _fileReference;
    }

    public function get applyRegisteredTime():Number {
        return _applyRegisteredTime;
    }


    public function get csCloudUploadFileType():String {
        return _csCloudUploadFileType;
    }

    public function get csCloudUploadKey():String {
        return _csCloudUploadKey;
    }

    public function setFlashFields(thumbBytes:ByteArray, thumbWidth:Number, thumbHeight:Number, width:Number, height:Number) : void {
        _flashThumbBytes = thumbBytes;
        _flashThumbWidth = thumbWidth;
        _flashThumbHeight = thumbHeight;
        _flashWidth = width;
        _flashHeight = height;
    }

    public function upload( file:FileReference, extraInfo:String = null ):void{

        if( _fileReference != null  || _fileBytes != null){
            throw new Error( "upload may not be called twice!" );
        }

        _fileReference = file;

        doAuthRequest(_fileReference.creationDate, _fileReference.modificationDate, _fileReference.creator,
         _fileReference.name, fileReference.size, extraInfo);
    }

    public function uploadBytes(fileBytes:ByteArray,  modificationDate:Date, creator:String, fileName:String, fileSize:Number, fileContentType:String, extraInfo:String):void{

        if( _fileReference != null || _fileBytes != null){
            throw new Error( "upload may not be called twice!" );
        }

        _fileBytes = fileBytes;
        _fileName = fileName;
        _fileContentType = fileContentType;

        doAuthRequest(modificationDate, modificationDate, creator, fileName, fileSize, extraInfo);
    }

    protected function doAuthRequest(creationDate:Date, modificationDate:Date, creator:String, fileName:String, fileSize:Number, extraInfo:String) : void {

        var getUploadAuth:RpcSpringMvcPost = new RpcSpringMvcPost();
        getUploadAuth.restUrl = _url;
        getUploadAuth.urlExtra = _csSessionId;
        getUploadAuth.serviceName = rpcUploadServiceName;
        getUploadAuth.remoteMethodName = rpcMethodUploadAuth;
        getUploadAuth.serverHandleType = RpcSpringMvcPost.SERVER_TYPE_AWS_API_GATEWAY_JSON;
        getUploadAuth.callBackOnError = onAuthRequestError;
        getUploadAuth.callBackOnObjResult = onAuthRequestComplete;


        //directly call rpc without context support
        getUploadAuth.args = [creationDate, modificationDate, creator, fileName, fileSize, "", extraInfo];
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
    private function onAuthRequestComplete( result:Object ):Boolean{

        // always hold onto the actual result...
        authResult = result;

        if( ! ( result is Array ) ){
            // this is an unexpected error - cast result to a string, dispatch an ErrorEvent,
            // and return true to halt further processing
            error = String( result );
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false, false, "Unexpected authentication response"));

            // cleanup!
            _fileReference = null;
            _fileBytes = null;
            _lastS3Post = null;

            return true;
        }

        // item at index=2 is the S3 ObjectId, which is the unique id of the upload table
        _csCloudUploadKey = authResult[2];
        _applyRegisteredTime = authResult[5];
        _csCloudUploadFileType = authResult[6];

        // set the appropriate value for resourceType based on fileType
        switch (_csCloudUploadFileType.toLowerCase()) {
            case ".swf":
                _csCoreResourceType = "flash";
                break;
            case ".png":
            case ".gif":
            case ".jpg":
            case ".jpeg":
                _csCoreResourceType = "image";
                break;
            default:
                _csCoreResourceType = "video";
                break;
        }

        // at this point we need to check if we are uploading via FileRefernce or a ByteArray
        if (_fileReference) {
            doFileReferenceUpload();
        } else if (_fileBytes) {
            doS3PostUpload();
        } else {
            throw new Error("Can not locate fileReference or fileBytes to upload!");
        }

        return true;
    }


    private function doFileReferenceUpload() : void {

        var vars:URLVariables = new URLVariables();
        vars.acl = "private";
        vars.success_action_status = "201";

        vars.AWSAccessKeyId = authResult[1];
        vars.key = authResult[2];
        vars.policy = authResult[3];
        vars.signature = authResult[4];//"ASIAJOXAFBNVKUEEHALQ"

        var urlOrBucketName:String = authResult[0];
        var urlRequest:URLRequest = new URLRequest();
        if( urlOrBucketName.indexOf( "http" ) == 0 ){
            urlRequest.url = urlOrBucketName;
        }
        else{
            urlRequest.url = "https://" + urlOrBucketName + ".s3.amazonaws.com/";
        }
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = vars;

        _fileReference.addEventListener( ProgressEvent.PROGRESS, onUploadProgress );
        _fileReference.addEventListener( IOErrorEvent.IO_ERROR, onUploadError );
        _fileReference.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onUploadError );
        _fileReference.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete );

        _fileReference.upload( urlRequest, "file" );

    }

    private function onUploadProgress(event:ProgressEvent) : void {
        // re-dispatch to accomplish bubbling
        dispatchEvent(event);
    }

    private function onUploadError(event:ErrorEvent) : void {

        // cleanup listeners
        _fileReference.removeEventListener( ProgressEvent.PROGRESS, onUploadProgress );
        _fileReference.removeEventListener( IOErrorEvent.IO_ERROR, onUploadComplete );
        _fileReference.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onUploadComplete );
        _fileReference.removeEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete );

        // hold onto the event
        errorEvent = event;

        // get the error message
        error = event.text;

        // dispatch our own error event
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Upload error: " + error));
    }

    private function onUploadComplete( event:Event ):void{

        // cleanup listeners
        _fileReference.removeEventListener( ProgressEvent.PROGRESS, onUploadProgress );
        _fileReference.removeEventListener( IOErrorEvent.IO_ERROR, onUploadComplete );
        _fileReference.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onUploadComplete );
        _fileReference.removeEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete );

        // set up final call to mark upload complete

        if (_csCoreResourceType == "image") {
            callProcessImage(_applyRegisteredTime);
        } else {
            callUploadResult(_applyRegisteredTime);
        }

        _fileReference = null;
    }



    private function doS3PostUpload() : void {


        //Object[]{ url, awsAccessKeyId, acl, encodedPolicy, signature, ttl }
        _lastS3Post = new S3Post(
                authResult[0], // s3BucketUrl
                authResult[1], // awsS3AccessKeyId
                "private", // acl
                authResult[3], // encodedPolicy
                authResult[4], // signature
                authResult[2], // s3ObjectKey
                _fileName, // filename
                _fileContentType, // content-type
                _fileBytes // fileBytes
        );


        // need to include the 'Filename' form field parameter due to it's inclusion in the S3 Policy
        _lastS3Post.includeFilenameField = true;

        _lastS3Post.addEventListener(ErrorEvent.ERROR, onS3PostUploadError);
        _lastS3Post.addEventListener(Event.COMPLETE, onS3PostUploadComplete);

        _lastS3Post.doPost();
    }


    private function onS3PostUploadError(event:ErrorEvent) : void {

        // cleanup listeners
        _lastS3Post.removeEventListener(ErrorEvent.ERROR, onS3PostUploadError);
        _lastS3Post.removeEventListener(Event.COMPLETE, onS3PostUploadComplete);

        // hold onto the event
        errorEvent = event;

        // get the error message
        error = event.text;

        // dispatch our own error event
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Upload error: " + error));
    }

    private function onS3PostUploadComplete( event:Event ):void{

        // cleanup listeners
        _lastS3Post.removeEventListener(ErrorEvent.ERROR, onS3PostUploadError);
        _lastS3Post.removeEventListener(Event.COMPLETE, onS3PostUploadComplete);

        // set up final call to mark upload complete

        if (_csCoreResourceType == "image") {
            callProcessImage(_applyRegisteredTime);
        } else {
            callUploadResult(_applyRegisteredTime);
        }

        _lastS3Post = null;
        _fileBytes = null;
    }


    private function callProcessImage(applyRegisteredTime:Number) : void {

        // set up arguments using remote method signature:
        //String csSessionId, Long applyTimeStamp, String errorId, String error, String errorTxt
        var resultArgs:Array = [applyRegisteredTime];

        var processImage:RpcSpringMvcPost = new RpcSpringMvcPost();
        processImage.restUrl = _url;
        processImage.urlExtra = _csSessionId;
        processImage.serviceName = rpcProcessServiceName;
        processImage.remoteMethodName = rpcMethodProcessImage;
        processImage.args = resultArgs;
        processImage.serverHandleType = RpcSpringMvcPost.SERVER_TYPE_AWS_API_GATEWAY_JSON;
        processImage.callBackOnError = onUploadResultError;
        processImage.callBackOnObjResult = onUploadResultComplete;
        processImage.callRemote();

    }


    private function callUploadResult(applyRegisteredTime:Number, errorId:String = null, errorMsg:String = null, errorTxt:String=null) : void {


        // set up arguments using remote method signature:
        //String csSessionId, Long applyTimeStamp, String errorId, String error, String errorTxt
        var resultArgs:Array = [applyRegisteredTime, errorId, errorMsg, errorTxt];

        var postUploadRslt:RpcSpringMvcPost = new RpcSpringMvcPost();
        postUploadRslt.restUrl = _url;
        postUploadRslt.urlExtra = _csSessionId;
        postUploadRslt.serviceName = rpcUploadServiceName;
        postUploadRslt.remoteMethodName = rpcMethodUploadResult;
        postUploadRslt.args = resultArgs;
        postUploadRslt.serverHandleType = RpcSpringMvcPost.SERVER_TYPE_AWS_API_GATEWAY_JSON;
        postUploadRslt.callBackOnError = onUploadResultError;
        postUploadRslt.callBackOnObjResult = onUploadResultComplete;
        postUploadRslt.callRemote();

    }


    private function onUploadResultError(event:ErrorEvent) : void {
        // hold onto the event
        errorEvent = event;

        // get the error message
        error = event.text;

        // dispatch another event
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Upload result error: " + error));
    }

    private function onUploadResultComplete(result:Object) : Boolean {

        // if we do not have flash fields set, we are complete
        if (_flashThumbBytes == null) {
            dispatchEvent(new Event(Event.COMPLETE));
        } else {

            // we have flash fields, so invoke postFlashThumbnail


            // set up arguments using remote method signature:
            // String csSessionId, Long uploadApplyTime, byte[] thumbBytes,
            // Integer width, Integer height, Integer thumbWidth, Integer thumbHeight

            var resultArgs:Array = [_applyRegisteredTime, _flashThumbBytes, _flashWidth, _flashHeight, _flashThumbWidth, _flashThumbHeight];

            // build up the request
            var postFlashThumb:RpcSpringMvcPost = new RpcSpringMvcPost();
            postFlashThumb.restUrl = _url;
            postFlashThumb.urlExtra = _csSessionId;
            postFlashThumb.serviceName = rpcUploadServiceName;
            postFlashThumb.remoteMethodName = rpcMethodPostFlashThumbnail;
            postFlashThumb.args = resultArgs;
            postFlashThumb.serverHandleType = RpcSpringMvcPost.SERVER_TYPE_AWS_API_GATEWAY_JSON;
            postFlashThumb.callBackOnError = onPostFlashThumbError;
            postFlashThumb.callBackOnObjResult = onPostFlashThumbComplete;
            postFlashThumb.callRemote();

        }


        return true;
    }


    private function onPostFlashThumbError(event:ErrorEvent) : void {

        // hold onto the event
        errorEvent = event;

        // get the error message
        error = event.text;

        // dispatch another event
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Upload Flash Thumbnail error: " + error));
    }

    private function onPostFlashThumbComplete(result:Object) : Boolean {

        // at this point we are always complete
        dispatchEvent(new Event(Event.COMPLETE));

        return true;

    }
}
}