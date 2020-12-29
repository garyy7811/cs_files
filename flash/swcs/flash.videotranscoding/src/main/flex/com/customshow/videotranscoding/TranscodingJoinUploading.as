/**
 * Created by garyy on 2/11/2017.
 */
package com.customshow.videotranscoding {
import com.flashflexpro.as3lib.data.PropertyDesc;

public class TranscodingJoinUploading extends DynaTableVideoTranscoding{
    public function TranscodingJoinUploading(){
    }

    public static const PROP_DESC_csSessionId:PropertyDesc = new PropertyDesc( "csSessionId" );
    public var csSessionId:String;

    public static const PROP_DESC_fileRefSizeBytes:PropertyDesc = new PropertyDesc( "fileRefSizeBytes" );
    public var fileRefSizeBytes:Number;

    public static const PROP_DESC_fileRefCreationDate:PropertyDesc = new PropertyDesc( "fileRefCreationDate" );
    public var fileRefCreationDate:Number;

    public static const PROP_DESC_fileRefModificationDate:PropertyDesc = new PropertyDesc( "fileRefModificationDate" );
    public var fileRefModificationDate:Number;

    public static const PROP_DESC_fileRefCreator:PropertyDesc = new PropertyDesc( "fileRefCreator" );
    public var fileRefCreator:String;

    public static const PROP_DESC_fileRefName:PropertyDesc = new PropertyDesc( "fileRefName" );
    public var fileRefName:String;

    public static const PROP_DESC_fileRefType:PropertyDesc = new PropertyDesc( "fileRefType" );
    public var fileRefType:String;

    public static const PROP_DESC_extraMsg:PropertyDesc = new PropertyDesc( "extraMsg" );
    public var extraMsg:String;


    public static const PROP_DESC_userId:PropertyDesc = new PropertyDesc( "userId" );
    public var userId:String;

    public static const PROP_DESC_clientId:PropertyDesc = new PropertyDesc( "clientId" );
    public var clientId:String;

    public static const PROP_DESC_s3Bucket:PropertyDesc = new PropertyDesc( "s3Bucket" );
    public var s3Bucket:String;

    public static const PROP_DESC_s3BucketKey:PropertyDesc = new PropertyDesc( "s3BucketKey" );
    public var s3BucketKey:String;

    public static const PROP_DESC_awSAccessKeyId:PropertyDesc = new PropertyDesc( "awSAccessKeyId" );
    public var awSAccessKeyId:String;

    public static const PROP_DESC_applyTimeStamp:PropertyDesc = new PropertyDesc( "applyTimeStamp" );
    public var applyTimeStamp:Number;

    public static const PROP_DESC_uploadedByClientTime:PropertyDesc = new PropertyDesc( "uploadedByClientTime" );
    public var uploadedByClientTime:Number;

    public static const PROP_DESC_uploadedConfirmTimeStamp:PropertyDesc = new PropertyDesc( "uploadedConfirmTimeStamp" );
    public var uploadedConfirmTimeStamp:Number;
}
}
