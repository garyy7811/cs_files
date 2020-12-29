import com.customshow.siutils.FlashLogging;
import org.junit.Test;
import org.springframework.util.Assert;

import java.util.Arrays;
import java.util.Date;

/**
 * User: GaryY
 * Date: 1/10/2017
 */
public class TestFlashLogging{
    @Test
    public void testFlashLoggingNow(){

        String s = "Error\n" +
                "\tat CC$/log()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils\\src\\main\\flex\\CC.as:129]\n" +
                "\tat com.flashflexpro.as3lib.rpc::RpcSpringMVC/callRemote()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils\\src\\main\\flex\\com\\flashflexpro\\as3lib\\rpc\\RpcSpringMVC.mxml:65]\n" +
                "\tat com.flashflexpro.as3lib.rpc::RpcSpringMvcPost/callRemote()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils\\src\\main\\flex\\com\\flashflexpro\\as3lib\\rpc\\RpcSpringMvcPost.mxml:34]\n" +
                "\tat com.customshow.awsS3Upload::ListUploadsByUserId/loadMore()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.awsS3Upload\\src\\main\\flex\\com\\customshow\\awsS3Upload\\ListUploadsByUserId.mxml:57]\n" +
                "\tat com.flashflexpro.as3lib.rpc::RpcGrid/reloadGrid()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils\\src\\main\\flex\\com\\flashflexpro\\as3lib\\rpc\\RpcGrid.mxml:20]\n" +
                "\tat com.customshow.awsS3Upload::ListUploadsByUserId/reloadGrid()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.awsS3Upload\\src\\main\\flex\\com\\customshow\\awsS3Upload\\ListUploadsByUserId.mxml:23]\n" +
                "\tat Function/http://adobe.com/AS3/2006/builtin::apply()\n" +
                "\tat com.flashflexpro.as3lib.utils::CallOnceInNextFrame/onEnterFrame()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils\\src\\main\\flex\\com\\flashflexpro\\as3lib\\utils\\CallOnceInNextFrame.mxml:17]\n" +
                "\tat com.flashflexpro.as3lib.spark::RootDesktop/___RootDesktop_Group1_enterFrame()[J:\\cs\\svn\\cs_cloud\\trunk\\flash\\swcs\\flash.utils.spark\\src\\main\\flex\\com\\flashflexpro\\as3lib\\spark\\RootDesktop.mxml:5]";


        final String stack =
                "Error\n" + "\tat CC$/log()\n" + "\tat com.flashflexpro.as3lib.rpc::RpcSpringMVC/callRemote()\n" +
                        "\tat com.flashflexpro.as3lib.rpc::RpcSpringMvcPost/callRemote()\n" +
                        "\tat com.customshow.awsS3Upload::ListUploadsByUserId/loadMore()\n" +
                        "\tat com.flashflexpro.as3lib.rpc::RpcGrid/reloadGrid()\n" +
                        "\tat com.customshow.awsS3Upload::ListUploadsByUserId/reloadGrid()\n" +
                        "\tat com.flashflexpro.as3lib.utils::CallOnceInNextFrame/onEnterFrame()\n" +
                        "\tat com.flashflexpro.as3lib.spark::RootDesktop/___RootDesktop_Group1_enterFrame()";

        Assert.isTrue( new FlashLogging().log( "sessionId" + System.currentTimeMillis(), new Object[]{
                Arrays.asList( "000", "111", "222", "333", new Date(), new Boolean( false ), new Integer( 1 ), "777",
                        s ) } ) );
        Assert.isTrue( new FlashLogging().log( "sessionId" + System.currentTimeMillis(), new Object[]{
                Arrays.asList( "000", "111", "222", "333", new Date(), new Boolean( false ), new Integer( 1 ), "777",
                        stack ) } ) );

    }
}
