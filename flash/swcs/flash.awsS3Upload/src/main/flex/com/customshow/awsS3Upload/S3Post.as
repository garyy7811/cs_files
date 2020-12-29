package com.customshow.awsS3Upload {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLRequestHeader;
import flash.utils.ByteArray;


public class S3Post extends EventDispatcher {

    public function S3Post( s3BucketUrl:String, awsAccessKeyId:String, acl:String, encodedPolicy:String,
                            signature:String, s3ObjectKey:String, fileName:String, fileContentType:String,
                            fileBytes:ByteArray ){

        _s3BucketUrl = s3BucketUrl;
        _awsAccessKeyId = awsAccessKeyId;
        _acl = acl;
        _encodedPolicy = encodedPolicy;
        _signature = signature;
        _s3ObjectKey = s3ObjectKey;
        _fileName = fileName;
        _fileContentType = fileContentType;
        _fileBytes = fileBytes;

    }


    private var _s3BucketUrl:String;
    private var _awsAccessKeyId:String;
    private var _acl:String;
    private var _encodedPolicy:String;
    private var _signature:String;
    private var _s3ObjectKey:String;
    private var _fileName:String;
    private var _fileContentType:String;
    private var _fileBytes:ByteArray;

    private var _data:ByteArray = new ByteArray();

    private function writeStringToData( value:String, encoding:String = 'URF-8' ):void{
        var b:ByteArray = new ByteArray();
        b.writeMultiByte( value, encoding );
        _data.writeBytes( b, 0, b.length );
    }

    private var _includeFilenameField:Boolean = false;


    public function get includeFilenameField():Boolean {
        return _includeFilenameField;
    }

    public function set includeFilenameField(value:Boolean):void {
        _includeFilenameField = value;
    }


    public function doPost():void{

        var t:Number = Math.random() * (new Date().getTime());
        var boundary:String = ">>>>boundary" + Math.round( t ).toString() + "boundary<<<<";

        var vars:Object = {
            "acl": _acl,
            "success_action_status": "201",
            "AWSAccessKeyId": _awsAccessKeyId,
            "key": _s3ObjectKey,
            "policy": _encodedPolicy,
            "signature": _signature
        };

        if (includeFilenameField) {
            vars['Filename'] = _fileName;
        }

        for( var name:String in vars ){
            writeStringToData(
                    '--' + boundary + '\r\n' + 'Content-Disposition: form-data; name="' + name + '"\r\n\r\n' );
            writeStringToData( vars[name] );
            writeStringToData( '\r\n' );
        }

        writeStringToData(
                '--' + boundary + '\r\n' + 'Content-Disposition: form-data; name="file"; filename="' + _fileName +
                '"\r\n' + 'Content-Type: ' + _fileContentType + '\r\n\r\n' );
        _fileBytes.position = 0;
        _data.writeBytes( _fileBytes, 0, _fileBytes.length );
        writeStringToData( '\r\n' );

        // end
        writeStringToData( '--' + boundary + '--\r\n' );

        var urlRequest:URLRequest = new URLRequest( _s3BucketUrl );
        urlRequest.data = _data;
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.requestHeaders.push(
                new URLRequestHeader( 'Content-type', 'multipart/form-data; boundary=' + boundary ) );

        if( _loader == null ){
            _loader = new URLLoader();
        }

        _loader.addEventListener( Event.COMPLETE, onComplete );
        _loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError);
        _loader.load( urlRequest );
    }

    private var _loader:URLLoader;


    private function onComplete( event:Event ):void{
        CONFIG::debugging{
            CC.log( "UploadByCsSessionIdByPost.onPosted->arguments:" + arguments.join( "," ) );
        }

        dispatchEvent(new Event(Event.COMPLETE));
    }


    private function onIOError(event:IOErrorEvent) : void {

        CONFIG::debugging{
            CC.log( "Error posting to S3: "+ event);
            CC.log( "Response: " + _loader.data.toString() );
        }

        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false,  "Unexpected error posting file: " + event.text));

    }

}
}
