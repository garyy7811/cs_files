/**
 * Created by Gary on 1/14/2015.
 */
package com.customshow.reporting.mxreports {

import com.customshow.solr.query.web.common.DtoFacetResultRecord;

import mx.formatters.DateFormatter;
import mx.messaging.FlexClient;

[Bindable]
public class CsSlideShowSessionModel extends CsSlideShowSessionModelImpl {
    public var slideShowName:String;
    public var userName:String;
    public var startTime:Number;
    public var slideShowDuration:Number;

    public function CsSlideShowSessionModel( csSessionId:String, queryUrl:String, dto:DtoFacetResultRecord, counts:uint ){
        this.csSessionId = csSessionId;
        this.queryUrl = queryUrl;
        this.counts = counts;

        this.duration = MxCsQuickRpc.epicTimeToHMS( dto.p( MxCsQuickRpc.schemaShowduration.duration__l_t_t_f ) );
        this.viewer = dto.p( MxCsQuickRpc.schemaShowduration.userEmail__si_t_t_f );
        this.viewedTime =
                _dateFormatter.format( new Date( dto.p( MxCsQuickRpc.schemaShowduration.startTime__l_t_t_f ) ) );
        dtoShowDuration = dto;
        slideShowName = dto.p( MxCsQuickRpc.schemaShowduration.slideShowName__si_t_t_f );
        userName = dto.p( MxCsQuickRpc.schemaShowduration.userEmail__si_t_t_f );
        startTime = dto.p( MxCsQuickRpc.schemaShowduration.startTime__l_t_t_f );
        slideShowDuration = dto.p( MxCsQuickRpc.schemaShowduration.duration__l_t_t_f );
    }

    private static var _dateFormatter:DateFormatter = new DateFormatter( "EEE, MMM D, YYYY L:NN A" );

    private var csSessionId:String;
    private var queryUrl:String;

    public var counts:uint;
    public var duration:String;
    public var viewer:String;
    public var viewedTime:String;

    public var sssRpc:MxCsQuickRpc;

    public function loadSlideDurations():void{

        sssRpc = new MxCsQuickRpc();
        sssRpc.queryUrl = queryUrl;
        sssRpc.serviceName = "slideduration";
        sssRpc.remoteMethodName = "facetQuery";
        sssRpc.csSessionId = csSessionId;
        sssRpc.callBackOnObjResult = this.onSlideDuration;


        sssRpc.args = [MxCsQuickRpc.schemaSlideduration.showSessionId__si_t_t_f.id + ":((\"" +
        dtoShowDuration.p( MxCsQuickRpc.schemaShowduration.showSessionId__si_t_t_f ) + "\"))", 0, 20000, {},
            MxCsQuickRpc.schemaSlideduration.startTime__l_t_t_f.id, true];
        sssRpc.callRemote();
    }


}
}
