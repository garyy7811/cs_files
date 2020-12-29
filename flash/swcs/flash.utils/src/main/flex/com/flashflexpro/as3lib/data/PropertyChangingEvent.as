/**
 * Created by garyyang on 5/8/2014.
 */
package com.flashflexpro.as3lib.data {
import flash.events.Event;

import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

public class PropertyChangingEvent extends PropertyChangeEvent {

    public function PropertyChangingEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false, kind:String = null, property:Object = null, oldValue:Object = null, newValue:Object = null, source:Object = null ){
        super( type, bubbles, cancelable, kind, property, oldValue, newValue, source );
    }

    public static const PROPERTY_CHANGING:String = "propertyChanging";

    public static const PROPERTY_CHANGE_KIND_ADDING:String = "propertyChangeKindAdding";
    public static const PROPERTY_CHANGE_KIND_ADDED:String = "propertyChangeKindAdded";

    public static function createUpdateEvent( source:Object, property:Object, oldValue:Object, newValue:Object ):PropertyChangeEvent{
        var event:PropertyChangingEvent =
                new PropertyChangingEvent( PROPERTY_CHANGING );

        event.kind = PropertyChangeEventKind.UPDATE;
        event.oldValue = oldValue;
        event.newValue = newValue;
        event.source = source;
        event.property = property;

        return event;
    }


    override public function clone():Event{
        return new PropertyChangingEvent( type, bubbles, cancelable, kind,
                                          property, oldValue, newValue, source );
    }
}
}