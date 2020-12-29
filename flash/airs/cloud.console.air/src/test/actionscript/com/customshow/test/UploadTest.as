package com.customshow.test {
import com.customshow.awsS3Upload.UploadByCsSessionId;
import com.customshow.cloudconsole.UIRootCloudDesktop;
import com.flashflexpro.as3lib.spark.RootDesktop;

import flash.events.DataEvent;
import flash.filesystem.File;

import mx.core.FlexGlobals;

import org.flexunit.Assert;

import org.flexunit.async.Async;

public class UploadTest {
    [Test(async)]
    public function test1():void{

        var tmp:AppCompiledTestConfig = new AppCompiledTestConfig();

        var rootdesktop:UIRootCloudDesktop = RootDesktop.inst as UIRootCloudDesktop;

        var uploadByCsSessionId:UploadByCsSessionId = rootdesktop.uploadButton.upload;
        uploadByCsSessionId.upload( new File( tmp.testSwfFile ) );
        uploadByCsSessionId.fileReference.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA,
                Async.asyncHandler( this, onFileUploaded, 25000, ["passing through"],
                        function timeout( passedIn:Object = null ):void{
                            Assert.fail( "upload time out" )
                        } ), false, - 1, true );
    }

    private function onFileUploaded( ev:Object = null, passedIn:Object = null ):void{
        var rootdesktop:UIRootCloudDesktop = RootDesktop.inst as UIRootCloudDesktop;
        Assert.assertNull( rootdesktop.uploadButton.upload.error );
        Assert.assertNull( rootdesktop.uploadButton.upload.fileReference );

    }

}
}