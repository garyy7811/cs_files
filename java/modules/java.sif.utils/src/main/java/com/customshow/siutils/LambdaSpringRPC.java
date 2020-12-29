package com.customshow.siutils;

import com.amazonaws.util.Base64;
import com.customshow.awsutils.RPCServiceInvoker;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flashflexpro.graniteamf.SimpleGraniteConfig;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

/**
 * User: flashflexpro@gmail.com
 * Date: 3/1/2016
 * Time: 3:30 PM
 */
public abstract class LambdaSpringRPC<T> extends LambdaSpringBase{

    public LambdaSpringRPC(){

        try{
            rpcServiceInvoker = getAppContext().getBean( RPCServiceInvoker.class );
        }
        catch( BeansException e ){
            init_logger.error( "NO RPCServiceInvoker FOUND!" );
            e.printStackTrace();
        }
        try{
            simpleGraniteConfig = getAppContext().getBean( SimpleGraniteConfig.class );
        }
        catch( BeansException e ){
            init_logger.error( "NO SimpleGraniteConfig FOUND!" );
            e.printStackTrace();
        }
    }

    protected static RPCServiceInvoker   rpcServiceInvoker;
    protected static SimpleGraniteConfig simpleGraniteConfig;

    /**
     * allows for consistent use of RPC-via-spring implementation in subclasses that
     * implement a handleRequest taking a ProxyInput
     *
     * @param input
     * @return
     */
    public Map<String, Object> handleRpcInvokerRequest( ProxyInput input ){

        final HashMap<String, Object> rt = new HashMap<>();

        if( input.isWarmup() ){
            logger.info( "handling warmup!" );
            rt.put( "warmup", "ok" );
            return rt;
        }

        try{
            String[] pathArr = input.getPath().split( "/" );

            final String csSessionId = pathArr[ pathArr.length - 1 ];
            final String methodName = pathArr[ pathArr.length - 2 ];
            final String serviceName = pathArr[ pathArr.length - 3 ];

            ThreadContext.put( "CsSessionId", csSessionId );

            rt.put( "body", rpcInvoker( csSessionId, serviceName, methodName, input.getBody() ) );
            rt.put( "statusCode", 200 );
        }
        catch( Throwable e ){
            try{
                logger.error( "Error:{} \nCaused by:{}" + ExceptionUtils.getStackTrace( e ),
                        new ObjectMapper().writeValueAsString( input ) );
            }
            catch( JsonProcessingException e1 ){
                throw new Error( e1 );
            }

            rt.put( "body", e.getMessage() );
            rt.put( "statusCode", 500 );
        }

        return rt;
    }




    public String rpcInvoker( String csSessionId, String serviceName, String methodName, String input64 ) throws Throwable{
        //todo: verify sessionId

        long rpcStart = System.currentTimeMillis();

        final byte[] decode = Base64.decode( input64.getBytes( "UTF-8" ) );
        final Object[] args = ( Object[] )simpleGraniteConfig.decode( ByteBuffer.wrap( decode ) );


        Object rpcRt = rpcServiceInvoker.callServiceMethod( csSessionId, serviceName, methodName, args );

        String rt;
        if( rpcRt == null ){
            rt = null;
        }
        else{
            rt = new String( Base64.encode( simpleGraniteConfig.encode( rpcRt ).array() ) );
        }

        init_logger.debug( "RPC exe cost:{}", System.currentTimeMillis() - rpcStart );
        return rt;
    }

}