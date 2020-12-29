/**
 * Created by gary.y on 4/25/2016.
 */
package com.flashflexpro.as3lib {
import com.flashflexpro.as3lib.utils.RootContextModule;

public interface IWithContext {

    function set context( m:RootContextModule ):void;

    function get context():RootContextModule;
    
}
}
