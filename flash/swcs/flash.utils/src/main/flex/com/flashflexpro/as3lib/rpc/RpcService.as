/**
 * Created by gary.y on 6/29/2016.
 */
package com.flashflexpro.as3lib.rpc {
import com.flashflexpro.as3lib.utils.RootContextModule;

import flash.utils.getQualifiedClassName;

public class RpcService {
    public function RpcService( context:RootContextModule ){
        this._context = context;
        var myclsName:String = getQualifiedClassName( this ).split( "::" )[1];
        serviceName = myclsName.charAt( 0 ).toLowerCase() + myclsName.substr( 1 );
    }

    private var _context:RootContextModule;
    public function get context():RootContextModule{
        return _context;
    }

    [Bindable]
    public var serviceName:String;

    public function createRpcPost( methodName:String, args:Array ):RpcSpringMvcPost{
        var rpcSpringPost:RpcSpringMvcPost = new RpcSpringMvcPost();
        rpcSpringPost.model = _context;
        rpcSpringPost.serviceName = serviceName;
        rpcSpringPost.remoteMethodName = methodName;
        rpcSpringPost.callBackOnObjResult = args.shift();
        rpcSpringPost.callBackOnError = args.shift();
        rpcSpringPost.args = args;
        return rpcSpringPost;
    }
}
}
