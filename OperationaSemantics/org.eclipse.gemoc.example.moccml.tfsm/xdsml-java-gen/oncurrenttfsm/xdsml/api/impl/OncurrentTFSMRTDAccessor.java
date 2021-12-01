/* GENERATED FILE, do not modify manually                                                    *
 * If you need to modify it, copy it first */
package oncurrenttfsm.xdsml.api.impl;
import org.eclipse.emf.ecore.EObject;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.lang.reflect.Method;
import org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.utils.Copier;
import org.eclipse.gemoc.executionframework.engine.commons.K3DslHelper;


public class OncurrentTFSMRTDAccessor {
  public static java.lang.Integer getnumberOfTicks(com.yakindu.sct.model.sgraph.Statechart eObject) {
     java.lang.Integer theProperty = (java.lang.Integer)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.StatechartAspect", "numberOfTicks");
		return theProperty;
}
  public static java.lang.Integer saveProperty_numberOfTicks(com.yakindu.sct.model.sgraph.Statechart eObject) {
		java.lang.Integer propertyValue = (java.lang.Integer)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.StatechartAspect", "numberOfTicks");
		propertyValue = propertyValue == null ? null : (java.lang.Integer)Copier.clone(propertyValue);
		return propertyValue;
}
	public static boolean setnumberOfTicks(com.yakindu.sct.model.sgraph.Statechart eObject, java.lang.Integer newValue) {
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.StatechartAspect", "numberOfTicks", newValue);
	}
	public static boolean restoreProperty_numberOfTicks(com.yakindu.sct.model.sgraph.Statechart eObject, java.lang.Integer newValue) {
		java.lang.Integer propertyValue = newValue;
		propertyValue = propertyValue == null ? null : (java.lang.Integer)Copier.clone(propertyValue);
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.StatechartAspect", "numberOfTicks", propertyValue);
	}
  public static com.yakindu.sct.model.sgraph.Vertex getcurrentState(com.yakindu.sct.model.sgraph.Region eObject) {
     com.yakindu.sct.model.sgraph.Vertex theProperty = (com.yakindu.sct.model.sgraph.Vertex)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.RegionAspect", "currentState");
		return theProperty;
}
  public static com.yakindu.sct.model.sgraph.Vertex saveProperty_currentState(com.yakindu.sct.model.sgraph.Region eObject) {
		com.yakindu.sct.model.sgraph.Vertex propertyValue = (com.yakindu.sct.model.sgraph.Vertex)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.RegionAspect", "currentState");
		// Reference property
		return propertyValue;
}
	public static boolean setcurrentState(com.yakindu.sct.model.sgraph.Region eObject, com.yakindu.sct.model.sgraph.Vertex newValue) {
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.RegionAspect", "currentState", newValue);
	}
	public static boolean restoreProperty_currentState(com.yakindu.sct.model.sgraph.Region eObject, com.yakindu.sct.model.sgraph.Vertex newValue) {
		com.yakindu.sct.model.sgraph.Vertex propertyValue = newValue;
		// Reference property
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.RegionAspect", "currentState", propertyValue);
	}
  public static java.lang.Integer getcurrentValue(com.yakindu.base.types.Property eObject) {
     java.lang.Integer theProperty = (java.lang.Integer)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.PropertyAspect", "currentValue");
		return theProperty;
}
  public static java.lang.Integer saveProperty_currentValue(com.yakindu.base.types.Property eObject) {
		java.lang.Integer propertyValue = (java.lang.Integer)getAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.PropertyAspect", "currentValue");
		propertyValue = propertyValue == null ? null : (java.lang.Integer)Copier.clone(propertyValue);
		return propertyValue;
}
	public static boolean setcurrentValue(com.yakindu.base.types.Property eObject, java.lang.Integer newValue) {
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.PropertyAspect", "currentValue", newValue);
	}
	public static boolean restoreProperty_currentValue(com.yakindu.base.types.Property eObject, java.lang.Integer newValue) {
		java.lang.Integer propertyValue = newValue;
		propertyValue = propertyValue == null ? null : (java.lang.Integer)Copier.clone(propertyValue);
		return setAspectProperty(eObject, "ConcurrentTFSM", "org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.PropertyAspect", "currentValue", propertyValue);
	}

	public static Object getAspectProperty(EObject eObject, String languageName, String aspectName, String propertyName) {
		List<Class<?>> aspects = K3DslHelper.getAspectsOn(languageName, eObject.getClass());
		Class<?> aspect = null;
		for (Class<?> a : aspects) {
			try {
				if (Class.forName(aspectName).isAssignableFrom(a)) {
					aspect = a;
				}
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		if (aspect == null) {
			return null;
		}
		Object res = null;
		 try {
			res = aspect.getDeclaredMethod(propertyName, ((fr.inria.diverse.k3.al.annotationprocessor.Aspect)aspect.getAnnotations()[0]).className()).invoke(eObject, eObject);
			return res;
		} catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException
					| NoSuchMethodException | SecurityException e) {
			e.printStackTrace();
		}

		return null;
	}
	
	
public static boolean setAspectProperty(EObject eObject, String languageName, String aspectName, String propertyName, Object newValue) {
		List<Class<?>> aspects = K3DslHelper.getAspectsOn(languageName, eObject.getClass());
		Class<?> aspect = null;
		for (Class<?> a : aspects) {
			try {
				if (Class.forName(aspectName).isAssignableFrom(a)) {
					aspect = a;
				}
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
				return false;
			}
		}
		if (aspect == null) {
			return false;
		}
		 Method m = getSetter(propertyName,newValue,aspect);
		 try {
			m.invoke(eObject, eObject, newValue);
			return true;
		} catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
			e.printStackTrace();
		}			
		return false;
}
	
	private static Method getSetter(String propertyName, Object value, Class<?> aspect) {
		Method setter = null;
		try {
			if(value != null) {
				setter = aspect.getMethod(propertyName, ((fr.inria.diverse.k3.al.annotationprocessor.Aspect)aspect.getAnnotations()[0]).className(), value.getClass());
			}else {
				for (Method m : aspect.getMethods()) {
					if (m.getName().compareTo(propertyName) ==0 && m.getParameterCount() == 2) {
						setter= m;
						return setter;
					}
				}
				throw new NoSuchMethodException();
			}
			return setter;
		} catch (NoSuchMethodException | SecurityException | IllegalArgumentException e) {
			
				for(Class<?> c : ((fr.inria.diverse.k3.al.annotationprocessor.Aspect)aspect.getAnnotations()[0]).getClass().getInterfaces()) {
					try {
						if(value != null) {
							setter = aspect.getMethod(propertyName, c, value.getClass());
							return setter;
						}
					} catch (NoSuchMethodException | SecurityException | IllegalArgumentException e1) {
					}
					for (Method m : aspect.getMethods()) {
						if (m.getName().compareTo(propertyName) ==0 && m.getParameterCount() == 2) {
							setter= m;
							return setter;
						}
					}
					
				}
				if (setter == null) {
					throw new RuntimeException("no method found for "+value.getClass().getName()+"::set"+propertyName);
				}
			}
		return setter;
	}};