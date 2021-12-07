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