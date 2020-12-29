/**
 * Created by Gary on 1/14/2015.
 */
package com.customshow.reporting.mxreports {


[Bindable]
public class CsSlideShowSessionModelRow {
    public function CsSlideShowSessionModelRow( ){
    }

    public var presIndexInSS:int = -1;

    public var slidIndexInPr:int = -1;

    public var slidIndexInSS:int = -1;

    public var order:Vector.<uint>;

    public var presentationId:Number;
    public var presentationName:String;

    public var slideId:Number;

    public var rowSlideName:String;

    public var duration:uint;

    public var durationStr:String;

    /**
     * 0 - 1
     */
    public var durationPercent:Vector.<Number>;

    public var viewedTimes:uint;


}
}
