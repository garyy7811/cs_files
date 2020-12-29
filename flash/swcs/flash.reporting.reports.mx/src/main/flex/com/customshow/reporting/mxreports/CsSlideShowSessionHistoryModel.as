/**
 * Created by Gary on 1/14/2015.
 */
package com.customshow.reporting.mxreports {


import com.customshow.solr.query.web.common.DtoFacetResult;
import com.customshow.solr.query.web.common.DtoFacetResultRecord;

import mx.collections.ArrayCollection;
import mx.messaging.FlexClient;

[Bindable]
public class CsSlideShowSessionHistoryModel {

    public function CsSlideShowSessionHistoryModel(csSessionId:String, queryUrl:String, showId:Number, includePreview:Boolean = false) {
        CONFIG::debugging{
            if (queryUrl == null || queryUrl.length < 3) {
                throw new Error(this + ".CsReportingSlideShowSession illegal queryUrl");
            }//debug
            if (isNaN(showId)) {
                throw new Error(this + ".CsReportingSlideShowSession illegal slideshowId");
            }
        }

        this.csSessionId = csSessionId;
        this.queryUrl = queryUrl;
        this.slideShowId = showId;
        this.includePreview = includePreview;
        loadShowSessionsCounts();
    }

    private function loadShowSessionsCounts():void {
        var getShowSessionHistory:MxCsQuickRpc = new MxCsQuickRpc();
        getShowSessionHistory.queryUrl = queryUrl;
        getShowSessionHistory.serviceName = "slideduration";
        getShowSessionHistory.remoteMethodName = "facetQuery";
        getShowSessionHistory.csSessionId = csSessionId;
        getShowSessionHistory.callBackOnObjResult = this.onSessionCountsLoaded;

        var fq:Object = {};
        fq[MxCsQuickRpc.schemaSlideduration.showSessionId__si_t_t_f.id] = [0, -1];
        getShowSessionHistory.args =
                [MxCsQuickRpc.schemaSlideduration.slideShowId__l_t_t_f.id + ":" + slideShowId, 0, 0, fq, "", false];
        getShowSessionHistory.callRemote();
    }

    private var csSessionId:String;
    private var queryUrl:String;
    private var slideShowId:Number;
    private var includePreview:Boolean;

    private var _showSessionId2counts:Object;

    public function onSessionCountsLoaded(rslt:DtoFacetResult):Boolean {
        CONFIG::debugging{
            CC.log(rslt);
        }//debug
        _showSessionId2counts = rslt.rFacetsRecords[MxCsQuickRpc.schemaSlideduration.showSessionId__si_t_t_f.id];
        loadShowSessionDetails();
        return true
    }

    private function loadShowSessionDetails():void {
        var getEachShowSessionDetails:MxCsQuickRpc = new MxCsQuickRpc();
        getEachShowSessionDetails.queryUrl = queryUrl;
        getEachShowSessionDetails.serviceName = "showduration";
        getEachShowSessionDetails.remoteMethodName = "facetQuery";
        getEachShowSessionDetails.csSessionId = csSessionId;
        getEachShowSessionDetails.callBackOnObjResult = this.onShowSessionDetailsReady;

        var s:String = MxCsQuickRpc.schemaShowduration.slideShowId__l_t_t_f.id + ":" + slideShowId +
                ( includePreview ? "" : " AND " + MxCsQuickRpc.schemaShowduration.preview__b_t_t_f.id + ":false" );
        getEachShowSessionDetails.args = [s, 0, 99999, {}, "", false];
        getEachShowSessionDetails.callRemote();
    }

    private function onShowSessionDetailsReady(rslt:DtoFacetResult):Boolean {

        CONFIG::debugging{
            CC.log(rslt);
        }//debug

        var arr:Array = [];
        for (var i:int = rslt.rQueryRecords.length - 1; i >= 0; i--) {
            var dtoShowSession:DtoFacetResultRecord = rslt.rQueryRecords[i] as DtoFacetResultRecord;
            arr.push(new CsSlideShowSessionModel(csSessionId, queryUrl, dtoShowSession, _showSessionId2counts[dtoShowSession.p(
                    MxCsQuickRpc.schemaSlideduration.showSessionId__si_t_t_f)]));
        }

        arr.sortOn("counts", Array.NUMERIC | Array.DESCENDING);

        sessionList = new ArrayCollection(arr);
        return true;
    }

    public var sessionList:ArrayCollection;

}
}
