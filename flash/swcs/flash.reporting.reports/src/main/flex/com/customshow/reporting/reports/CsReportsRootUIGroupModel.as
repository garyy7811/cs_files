/**
 * Created by gary.yang.customshow on 7/6/2015.
 */
package com.customshow.reporting.reports {
import flash.events.EventDispatcher;

[Bindable]
public class CsReportsRootUIGroupModel extends EventDispatcher {
    public function CsReportsRootUIGroupModel(){
    }

    public var id:Number;
    public var parentId:Number;
    public var parent:CsReportsRootUIGroupModel;
    public var name:String;
    public var selected:Boolean;
    public var depth:uint;

    public static function compare( a:CsReportsRootUIGroupModel, b:CsReportsRootUIGroupModel ):int{
        if( a == null ){
            return 1;
        }
        if( b == null ){
            return -1;
        }
        if( b.parent == a ){
            return 1;
        }
        if( a.parent == b ){
            return - 1;
        }
        if( a.depth == b.depth ){
            return a.parent == b.parent ? (a.id > b.id ? -1 : 1) : compare( a.parent, b.parent );
        }
        return a.depth > b.depth ? compare( a.parent, b ) : compare( a, b.parent );
    }
}
}
