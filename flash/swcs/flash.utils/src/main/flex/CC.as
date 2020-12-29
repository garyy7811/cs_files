/**
 * @author flashflexpro@gmail.com
 * Date: 12/3/12
 * Time: 10:25 AM
 */
package {


import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.FileReference;
import flash.net.ObjectEncoding;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.getClassByAlias;
import flash.system.Security;
import flash.system.Worker;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import mx.collections.IList;
import mx.utils.Base64Encoder;

import mx.utils.ObjectUtil;

public class CC {

    CONFIG::debugging{
        public function CC(){
        }

        public static function checkPropertyExist( obj:Object, property:String ):Boolean{
            var parr:Array = ObjectUtil.getClassInfo( obj, null, {includeReadOnly: false} ).properties as Array;
            for( var i:int = parr.length - 1; i >= 0; i -- ){
                if( parr[i] as String == property ){
                    return true;
                }
                else if( ( parr[i] as QName ).localName == property ){
                    return true;
                }
            }
            return false;
        }

        public static function dumpObj( obj:Object ):void{
            var b:ByteArray = new ByteArray();
            b.objectEncoding = ObjectEncoding.AMF3;
            b.writeObject( obj );
            var fr:FileReference = new FileReference();
            fr.save( b );
        }


        private static var _fr:FileReference = new FileReference();

        public static function readDump():void{
            _fr.addEventListener( Event.SELECT, onSelected );
            _fr.browse()
        }

        private static function onSelected( event:Event ):void{
            var b:ByteArray = _fr.data;
            b.objectEncoding = ObjectEncoding.AMF3;
            var dump:* = b.readObject();
        }

        public static const SERVER_TYPE_SERVLET_WITH_PATHS:uint = 1;
        public static const SERVER_TYPE_AWS_API_GATEWAY_JSON:uint = 2;
        public static var serverType:uint = 1;

        public static var logServiceUrl:String = null;
        public static var logName:String;
        public static var envConfig:String;
        public static var csVersion:String;
        public static var buildStr:String;

        public static var logLevel:int = 0;
        public static var traceToo:Boolean = false;

        public static var logLoader:URLLoader;

        private static var logRequest:URLRequest;
        private static var logRequestQue:Array = [];


        //static final String[] LOG_LEVELS = new String[]{ "debug", "info", "warn", "error", "fatal" };
        public static function log( toLog:Object, level:uint = 0, fatal:Boolean = false ):void{
            if( ! fatal && level < logLevel ){
                return;
            }
            var logStr:String;
            var tl:String = typeof toLog;
            if( tl == "object" || tl == "movieclip" || tl == "function" ){
                logStr = JSON.stringify(toLog );
            }
            else{
                logStr = toLog as String;
            }
            if( logStr == null || logStr.length == 0 ){
                logStr = "(*-*)";
            }
            if( logServiceUrl == null ){
                trace( logStr );
                return;
            }
            if( level > 4 ){
                level = 4;
            }

            try{
                if( logLoader == null && logServiceUrl != null ){

                    var u:String = logServiceUrl;
                    var arr:Array = u.split( "/" );

                    while( arr.length > 4 ){
                        arr.pop();
                    }

                    var url:String = arr.join( "/" ) + "/crossdomain.xml";
                    Security.loadPolicyFile( url );
                    trace( "loading security file from:" + url );

                    logLoader = new URLLoader();
                    logLoader.addEventListener( Event.COMPLETE, onLogSent );
                    logLoader.addEventListener( IOErrorEvent.IO_ERROR, onLogSent );
                }
                if( logStr.length > 5000 ){
                    logStr = logStr.substr( 0, 5000 )
                }

                logRequestQue.push(
                        new <Object>[logName, envConfig, csVersion, buildStr, new Date(), Worker.current.isPrimordial,
                            level, logStr, new Error().getStackTrace()] );
                if( traceToo ){
                    trace( logStr )
                }
                sendLogQue();
            }
            catch( e:Error ){
                trace( logStr );
                trace( "\n\n" );
                trace( e.getStackTrace() );
            }

            if( fatal ){
                var error:Error = new Error( logStr );
                trace( error.getStackTrace() );
                throw error;
            }
        }

        private static function sendLogQue():void{
            if( logRequest == null ){
                if( logRequestQue.length > 0 ){
                    if( logServiceUrl != null ){
                        logRequest = new URLRequest( logServiceUrl );
                        var ba:ByteArray = new ByteArray();
                        ba.writeObject( [logRequestQue] );
                        if( serverType == SERVER_TYPE_SERVLET_WITH_PATHS ){
                            logRequest.contentType = "application/x-amf";
                            logLoader.dataFormat = URLLoaderDataFormat.BINARY;

                            logRequest.data = ba;
                        }
                        else if( serverType == SERVER_TYPE_AWS_API_GATEWAY_JSON ){
                            logRequest.contentType = "text/plain";
                            logLoader.dataFormat = URLLoaderDataFormat.TEXT;

                            var cdr:Base64Encoder = new Base64Encoder();
                            cdr.insertNewLines = false;
                            cdr.encodeBytes( ba );
                            logRequest.data = cdr.toString();
                        }
                        else{
                            throw new Error( "Unknown server type." );
                        }
                        logRequest.method = URLRequestMethod.POST;
                        logLoader.load( logRequest );
                    }
                    else if( logRequestQue.length > 20 ){
                        trace( "!!!!!!!!CC.sendLogQue logServiceUrl still null after 20!!!!!!!!" );
                    }
                }
            }
        }

        private static var errorCount:uint = 0;

        private static function onLogSent( event:Event ):void{
            logRequest = null;
            if( event is IOErrorEvent ){
                errorCount ++;
                trace( ( event as IOErrorEvent ).toString() );
                if( errorCount > 5 ){
                    throw new Error( logLoader.data )
                }
            }
            else{
                errorCount = 0;
                if( logLoader.data != "retryInSecsPlz" ){
                    logRequestQue = [];
                }
            }
            sendLogQue();
        }

    }
}
}
