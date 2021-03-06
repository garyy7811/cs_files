package com.customshow.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.customshow.awsutils.LambdaBase;
import com.customshow.siutils.RPCServiceInvoker;
import org.apache.logging.log4j.ThreadContext;

import java.util.HashMap;
import java.util.Map;

/**
 * User: flashflexpro@gmail.com
 * Date: 2/25/2016
 * Time: 2:24 PM
 */
public class OnReportQueryFromFlash extends LambdaBase<HashMap<String, Object>>
        implements RequestHandler<LambdaBase.ProxyInput, Map<String, Object>>{

    @Override
    public Map<String, Object> handleRequest( ProxyInput input, Context context ){

        // cache AWSRequestId for use in log4j
        ThreadContext.put("AWSRequestId", context.getAwsRequestId());

        // diagnostic logging
        reportHandlerInvocation();

        final Map<String, Object> rt = handleRpcInvokerRequest(input);

        return rt;
    }

    public static void main( String[] args ){
        long r = System.currentTimeMillis();
        new OnReportQueryFromFlash().getAppContext().getBean( RPCServiceInvoker.class );
        long t = System.currentTimeMillis() - r;
        //        System.out.println( ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + t );
    }
}