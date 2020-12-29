/**
 * Created with IntelliJ IDEA.
 * User: garyyang
 * Date: 4/11/13
 * Time: 3:59 PM
 * To change this template use File | Settings | File Templates.
 */
package com.customshow.solr {
import com.flashflexpro.as3lib.utils.ExecutableMenuItem;
import com.flashflexpro.as3lib.utils.RootContextModule;


public class OperationQueryAddTerm extends ExecutableMenuItem{

    public function OperationQueryAddTerm( result:QueryRelate2Terms, field:QueryField ){
        super( );
        _field = field;
        label = field.label;
        target = result;

    }

    private var _field:QueryField;

    [Bindable(event="targetChanged")]
    public function get targetTerms():QueryRelate2Terms{
        return target as QueryRelate2Terms;
    }

    override protected function onExecute():void{
        var tmp:RootContextModule = targetTerms.query.queryResult.searchModel.context;

        var nt:QueryTerm = targetTerms;
        if( targetTerms.queryStr != null && targetTerms.queryStr.length > 0 ){
            var rt:QueryRelate2Terms = tmp.instantiate( QueryRelate2Terms ) as QueryRelate2Terms;
            nt = tmp.instantiate( ( _field is QueryFieldT ) ? QueryTermT : QueryTermR ) as QueryTerm;
            nt.field = _field;
            rt.term = nt;
            targetTerms.query.setFocusedOnTerm( nt );
            targetTerms.addTerm( rt );
        }
        else{
            targetTerms.term.field = _field;
        }

    }
}
}
