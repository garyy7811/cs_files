/**
 * Created by Gary on 8/16/2014.
 */
package com.flashflexpro.as3lib.utils {
import flash.net.getClassByAlias;
import flash.net.registerClassAlias;
import flash.utils.getQualifiedClassName;

import mx.utils.DescribeTypeCache;

public class RemoteClasses {

    public static function register( cls:Class ):void{
        CONFIG::debugging{
            CC.log( "RemoteClasses.register:" + cls + " >>>>>>" );
        }//debug

        var classPath:String = getQualifiedClassName( cls );

        var alias:String;

        if( cls != null ){
            var classInfo:XML = DescribeTypeCache.describeType( cls ).typeDescription;
            var metaArr:XMLList = ( classInfo.factory[0] ).metadata.( @name == "RemoteClass" );

            CONFIG::debugging{
                if( metaArr == null || metaArr.@name != "RemoteClass" ){
                    CC.log( "RemoteClasses.register error  class[" + classPath +
                            "] has no RemoteClass meta!! make sure you have keep-as3-metadata+=RemoteClass there!!!!", 2 );
                }
            }

            if( metaArr != null && metaArr.length() > 0 ){
                var children:XMLList = metaArr[0].children();
                if( children.length() == 0 ){
                    alias = ">" + classPath;
                }
                else{
                    alias = children[0].@value;
                }
            }
        }

        CONFIG::debugging{
            CC.log( "RemoteClasses.register: alias:" + alias );
        }//debug


        if( alias != null ){
            var classByAlias:Class;
            try{
                classByAlias = getClassByAlias( alias );
            }
            catch( e:Error ){
                CONFIG::debugging{
                    CC.log( "RemoteClasses.register: warning not found getClassByAlias( " + alias + ");" );
                }//debug
            }
            if( classByAlias != cls ){
                registerClassAlias( alias, cls );
                CONFIG::debugging{
                    CC.log( "RemoteClasses.register: registerClassAlias( " + alias + ", " + cls + " );" );
                }//debug
            }
        }
        CONFIG::debugging{
            CC.log( "RemoteClasses.register: cls:" + cls + " <<<<<<" );
        }//debug
    }

}
}
