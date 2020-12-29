/**
 * Created by garyyang on 5/23/2014.
 */
package com.flashflexpro.as3lib.data {
import mx.events.CollectionEvent;

public class CollectionChangingEvent extends CollectionEvent {
    public function CollectionChangingEvent( kind:String = null, location:int = -1, oldLocation:int = -1, items:Array = null ){
        super( COLLECTION_CHANGING, false, false, kind, location, oldLocation, items );
    }


    public static const COLLECTION_CHANGING:String = "collectionChanging";
}
}
