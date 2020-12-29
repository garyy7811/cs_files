/**
 * Created by Gary on 12/15/2014.
 */
package com.customshow.reporting {


import com.customshow.reporting.dto.DtoReportingActivity;
import com.customshow.reporting.dto.DtoReportingShowEnd;
import com.customshow.reporting.dto.DtoReportingShowStart;

import flash.system.Security;

public class CsReportingUserAction {

    public function CsReportingUserAction(){
        if( _inst == null ){
            _inst = this;
        }
        //else{ This is a dummy to pass the values}

        if( reportingAppType != null ){
            _inst.reportingAppType = reportingAppType;
        }
        if( reportingAppVersion != null ){
            _inst.reportingAppVersion = reportingAppVersion;
        }
        if( reportingUserActUrl != null ){
            _inst.reportingUserActUrl = reportingUserActUrl;
        }

    }

    private static var _inst:CsReportingUserAction;
    private static var _inJsonTxt:Boolean = false;
    private static var _awsGatewayApiKey:String = null;

    public static function userActStart( start:DtoReportingShowStart, url:String, awsGatewayApiKey:String = null,
                                         inJsonTxt:Boolean = false, appType:String = null,
                                         appVersion:String = null ):void{
        if( _inst == null ){
            var arr:Array = url.split( "/" );
            while( arr.length > 4 ){
                arr.pop();
            }
            Security.loadPolicyFile( arr.join( "/" ) + "/crossdomain.xml" );
            _inst = new CsReportingUserAction();
        }

        if( url != null ){
            CONFIG::debugging{
                if( _inst.reportingUserActUrl != null && _inst.reportingUserActUrl != url ){
                    throw new Error( " why a 2nd different reportingUserActUrl ??!!" )
                }
            }
            _inst.reportingUserActUrl = url;
        }

        if( appType != null ){
            CONFIG::debugging{
                if( _inst.reportingAppType != null && appType != _inst.reportingAppType ){
                    throw new Error( " why a 2nd different reporting app type ??!!" )
                }
            }
            _inst.reportingAppType = appType;
        }
        if( appVersion != null ){
            CONFIG::debugging{
                if( _inst.reportingAppVersion != null && appVersion != _inst.reportingAppVersion ){
                    throw new Error( " why a 2nd different reporting app version ??!!" )
                }
            }
            _inst.reportingAppVersion = appVersion;
        }
        _pause = null;
        _previousAct = null;

        _inJsonTxt = inJsonTxt;
        _awsGatewayApiKey = awsGatewayApiKey;

        start.appVersion = _inst.reportingAppVersion;
        start.appType = _inst.reportingAppType;
        _inst._startAct = start;
        sendObj( start );
    }

    public static function userActEnd( termination:Boolean = false ):void{
        if( _inst != null && _inst._startAct != null ){
            var cloned:DtoReportingShowEnd = getCloned( DtoReportingShowEnd ) as DtoReportingShowEnd;
            cloned.termination = termination;
            sendObj( cloned );
            _inst._startAct = null;
        }
        else{
            CONFIG::debugging{
                trace( "not even started ...." );
            }
        }
    }

    private static var _pause:DtoReportingActivity;

    public static function userPauseStart( reason:String ):void{
        CONFIG::debugging{
            if( _pause != null || _previousAct == null ){
                throw new Error( ".userPauseStart if( _pause != null || _previousAct == null )" );
            }//debug
        }
        _pause = getCloned();

        _pause.fromSlideRefId = _previousAct.fromSlideRefId;
        _pause.fromSlideIndexOfPres = _previousAct.fromSlideIndexOfPres;
        _pause.fromSlideName = _previousAct.fromSlideName;
        _pause.toSlideRefId = _previousAct.toSlideRefId;
        _pause.toSlideIndexOfPres = _previousAct.toSlideIndexOfPres;
        _pause.toSlideName = _previousAct.toSlideName;

        _pause.pauseBeginOrEnd = 1;
        _pause.pauseReason = reason;
        sendObj( _pause );
    }

    public static function userPauseEnd():void{
        CONFIG::debugging{
            if( _pause == null ){
                throw new Error( ".userPauseEnd " );
            }//debug
        }
        _pause.pauseBeginOrEnd = - 1;
        sendObj( _pause );
        _pause = null;
    }

    public static function userActNav( record:DtoReportingActivity ):void{
        sendObj( record );
    }

    private static var _previousAct:DtoReportingActivity;

    private static function sendObj( record:DtoReportingActivity ):void{
        _previousAct = record;
        new CsReportingUserActionRpcOffline( _inst.reportingUserActUrl, reportingUserActPath, reportingUserOfflinePath, record, _awsGatewayApiKey, _inJsonTxt ).send();
    }

    /*****************************************/

    public static function getCloned( clazz:Class = null ):DtoReportingActivity{
        if( clazz == null ){
            clazz = DtoReportingActivity;
        }
        var record:DtoReportingActivity = new clazz();

        record.flexClientId = _inst._startAct.flexClientId;
        record.showSessionId = _inst._startAct.showSessionId;
        record.clientSessionId = _inst._startAct.clientSessionId;
        record.clientTime = new Date().getTime();

        return record;
    }

    [Bindable]
    private var _startAct:DtoReportingShowStart;
    public static function get startAct():DtoReportingShowStart{
        return _inst._startAct;
    }

    [Bindable]
    public var reportingUserActUrl:String;

    [Bindable]
    public var reportingAppVersion:String;

    [Bindable]
    public var reportingAppType:String;

    public static const reportingUserActPath:String = "/useract";
    public static const reportingUserOfflinePath:String = "/offline";
}
}
