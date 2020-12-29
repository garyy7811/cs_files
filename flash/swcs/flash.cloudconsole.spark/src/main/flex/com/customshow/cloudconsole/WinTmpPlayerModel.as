/**
 * Created by Gary on 9/12/2016.
 */
package com.customshow.cloudconsole {
import com.customshow.awsS3Download.AwsS3DownloadService;
import com.customshow.awsS3Download.RootContextDownload;
import com.customshow.configPerClient.DynaTableClientConfigTranscodeFormat;
import com.customshow.videotranscoding.TranscodingFormatGrid;
import com.flashflexpro.as3lib.IWithContext;
import com.flashflexpro.as3lib.rpc.RpcSpringMvcPost;
import com.flashflexpro.as3lib.utils.RootContextModule;

import spark.components.mediaClasses.DynamicStreamingVideoItem;

import spark.components.mediaClasses.DynamicStreamingVideoSource;

[Bindable]
public class WinTmpPlayerModel implements IWithContext {
    private var _rpcSpringMvcPost:RpcSpringMvcPost;


    public function WinTmpPlayerModel( downloadCtx:com.customshow.awsS3Download.RootContextDownload,
                                       formGrid:com.customshow.videotranscoding.TranscodingFormatGrid,
                                       format:com.customshow.configPerClient.DynaTableClientConfigTranscodeFormat ){
        _downloadCtx = downloadCtx;
        _formGrid = formGrid;
        _format = format;


        _rpcSpringMvcPost =
                new AwsS3DownloadService( downloadCtx ).signAll( onSigh3CookiesResult, onSigh3CookiesError );
        _rpcSpringMvcPost.callRemote();
    }

    private function onSigh3CookiesError( e:* ):void{
        throw new Error( e );
    }

    private function onSigh3CookiesResult( arr:Array ):void{
        var strvsrc:DynamicStreamingVideoSource = new DynamicStreamingVideoSource();
        strvsrc.host = _downloadCtx.awsS3RTMPUrl;

        if( _format != null ){
            strvsrc.streamItems = new <DynamicStreamingVideoItem>[fmtToStrmItem( _format, arr )];
        }
        else{
            strvsrc.streamItems = new <DynamicStreamingVideoItem>[fmtToStrmItem( _format, arr )];
        }
        streamingVideoSource = strvsrc;
    }

    private function fmtToStrmItem( fmt:DynaTableClientConfigTranscodeFormat, arr:Array ):DynamicStreamingVideoItem{
        var tmpS3Domain:String = "s3.amazonaws.com";
        var tsdIdx:int = _format.destination.indexOf( tmpS3Domain );

        var rt:DynamicStreamingVideoItem = new DynamicStreamingVideoItem();
        rt.bitrate = Number( fmt.bitrate.substring( 0, fmt.bitrate.length - 1 ) );
        var s:String = _format.destination.substring( tsdIdx + tmpS3Domain.length + 1 );
        s = s.substring( 0, s.length - 4 );
        rt.streamName = "mp4:" + s + "?Key-Pair-Id=" + arr[2] + "&Signature=" + arr[1] + "&Policy=" + arr[0];
        return rt;
    }

    public var streamingVideoSource:DynamicStreamingVideoSource;

    private var _downloadCtx:RootContextDownload;
    private var _formGrid:TranscodingFormatGrid;
    private var _format:DynaTableClientConfigTranscodeFormat;


    public function get downloadCtx():RootContextDownload{
        return _downloadCtx;
    }

    public function get formGrid():TranscodingFormatGrid{
        return _formGrid;
    }

    public function get format():DynaTableClientConfigTranscodeFormat{
        return _format;
    }

    public function set context( m:RootContextModule ):void{
    }

    public function get context():RootContextModule{
        return _downloadCtx;
    }
}
}
