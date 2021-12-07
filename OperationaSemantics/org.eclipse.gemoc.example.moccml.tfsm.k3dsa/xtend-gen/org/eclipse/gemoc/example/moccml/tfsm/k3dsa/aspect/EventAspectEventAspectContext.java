package org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect;

import com.yakindu.base.types.Event;
import java.util.Map;

@SuppressWarnings("all")
public class EventAspectEventAspectContext {
  public static final EventAspectEventAspectContext INSTANCE = new EventAspectEventAspectContext();
  
  public static EventAspectEventAspectProperties getSelf(final Event _self) {
    		if (!INSTANCE.map.containsKey(_self))
    			INSTANCE.map.put(_self, new org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.EventAspectEventAspectProperties());
    		return INSTANCE.map.get(_self);
  }
  
  private Map<Event, EventAspectEventAspectProperties> map = new java.util.WeakHashMap<com.yakindu.base.types.Event, org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.EventAspectEventAspectProperties>();
  
  public Map<Event, EventAspectEventAspectProperties> getMap() {
    return map;
  }
}
