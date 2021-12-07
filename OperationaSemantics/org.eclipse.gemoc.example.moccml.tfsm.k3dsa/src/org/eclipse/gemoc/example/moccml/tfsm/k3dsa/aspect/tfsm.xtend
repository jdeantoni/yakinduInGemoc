package org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect

import com.yakindu.base.base.NamedElement
import com.yakindu.base.types.Event
import com.yakindu.base.types.Property
import com.yakindu.sct.model.sgraph.Entry
import com.yakindu.sct.model.sgraph.Region
import com.yakindu.sct.model.sgraph.Statechart
import com.yakindu.sct.model.sgraph.Transition
import com.yakindu.sct.model.sgraph.Vertex
import fr.inria.diverse.k3.al.annotationprocessor.Aspect
import fr.inria.diverse.k3.al.annotationprocessor.InitializeModel
import groovy.lang.Binding
import groovy.lang.GroovyShell
import org.codehaus.groovy.control.MultipleCompilationErrorsException
import org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.api.extensions.languages.NotInStateSpace

import static org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.StatechartHelper.*

import static extension org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.RegionAspect.*
import static extension org.eclipse.gemoc.example.moccml.tfsm.k3dsa.aspect.PropertyAspect.*
import com.yakindu.base.expressions.expressions.PrimitiveValueExpression
import com.yakindu.base.expressions.expressions.IntLiteral
import java.util.ArrayList
import org.eclipse.gemoc.execution.concurrent.ccsljavaengine.extensions.k3.rtd.api.Containment
import com.yakindu.sct.model.sgraph.State
import com.yakindu.sct.model.stext.stext.EventDefinition

//import org.eclipse.gemoc.execution.concurrent.ccsljavaengine.extensions.k3.rtd.api.Containment


class StatechartHelper{
	static public Statechart statechart;
	
	static def GroovyShell getShellWithVars(Object _self) {
		val binding = new Binding
		binding.setVariable("_self", _self)
		binding.setVariable("_this", _self)	
		
		for (p  : statechart.scopes.flatMap[s | s.variables]){
			println("    put in groovy scope "+p.name+" == "+p.currentValue)
			binding.setVariable(p.name, p.currentValue)		
		}
		
		val ucl = TransitionAspect.classLoader
		val shell = new GroovyShell(ucl, binding)
		return shell
	}
}

@Aspect(className=Region)
class RegionAspect extends NamedElementAspect {
	@Containment(Containment.ContainmentStrategy.REFERENCE)
	public Vertex currentState;

	def String initialize() {
		if (_self.currentState === null) { 

			_self.currentState = _self.vertices.findFirst[s | s instanceof Entry];
		}
		println("  [" + _self.getClass().getSimpleName() + ":" + _self.getName() + ".Init()]Initialized " + _self.name);
	}
	
	def void changeCurrentState(Vertex newState)
	{
		_self.currentState = newState
	}
		
}

@Aspect(className=Vertex)
class VertexAspect extends NamedElementAspect {
	def String onEnter() {
		if (_self instanceof State){ //not for inital states
			_self.parentRegion.currentState = _self;
			println("  [" + _self.getClass().getSimpleName() + ":" + _self.getName() + ".onEnter()]Entering " + _self.name);
		}
		
	}

	def String onExit() {
		if((_self instanceof State) && (_self as State).regions.size() > 0){
			for (Region r : (_self as State).regions){
				r.currentState = null
			}
		}
		if (_self instanceof State){ //not for inital states
			println("  [" + _self.getClass().getSimpleName() + ":" + _self.getName() + ".onLeave()]Leaving " + _self.name);
		}
	}
}

@Aspect(className=Transition)
class TransitionAspect extends NamedElementAspect {
	def String fire() {
		var ArrayList<Object> res = null
//		println("  [" + _self.getClass().getSimpleName() + ":" + _self.source.name+"_to_"+_self.target.name + ".fire()]Fired")
		if(_self.specification!== null && _self.specification.split('/').size() > 1){		
			//GroovyRunner.executeScript(_self.action, _self);
			try {	
				// add variables _self and _this for use in the expression
				val shell = StatechartHelper.getShellWithVars(_self)
				var returnStatement = '\n return ['
					var String sep = ""	
					var Binding binding
					for (p  : StatechartHelper.statechart.scopes.flatMap[s | s.variables]){
						returnStatement = returnStatement + sep + p.name
						sep=","
					}
					returnStatement = returnStatement + ']'
				
				println('    eval: '+_self.specification.split('/').last.replaceAll(' *raise [^;]*(;)?',''))
				res = shell.evaluate(_self.specification.split('/').last.replaceAll(' *raise [^;]*(;)?','')+ returnStatement) as ArrayList<Object>
				var i = 0

				for (p  : StatechartHelper.statechart.scopes.flatMap[s | s.variables]){
					p.currentValue = res.get(i++) as Integer 
				}
				
				
			} catch (MultipleCompilationErrorsException cnfe) {
				println("Failed to call Groovy script" + cnfe.message)
				cnfe.printStackTrace
			}	
		}
		_self.source.parentRegion.currentState = null
		println("  [" + _self.getClass().getSimpleName() + ":" + _self.source.name+"_to_"+_self.target.name + ".fire()]Fired  -> " + ((_self.specification !== null)?_self.specification.split('/').last:""))
	}
	

	
	
	def boolean evaluate() {
		var Boolean res;
		val shell = StatechartHelper.getShellWithVars(_self)
		res = shell.evaluate(_self.specification.replaceAll('.*\\[','').replaceAll('\\].*','')) as Boolean
	  return res;
	}
	
	
	
	
	
}

@Aspect(className=NamedElement)
class NamedElementAspect {
}

@Aspect(className=Event)
class EventAspect extends NamedElementAspect {
	def public String occurs() {
		println("->[" + _self.getClass().getSimpleName() + ":" + _self.getName() + ".occurs()]Occured " )
	}
}

@Aspect(className=Statechart)
class StatechartAspect extends NamedElementAspect {
	
	@NotInStateSpace 
	public Integer numberOfTicks = 0 //MUST be initialized for coordination

	// Clock tick
	def public String ticks() {
		_self.numberOfTicks = _self.numberOfTicks + 1
		println("@" +// _self.getClass().getSimpleName() + ":" + _self.getName() + ".ticks()]New number of ticks : " +
		_self.numberOfTicks.toString())
	}
	
	@InitializeModel
	def public String initialize(String[] params) {
		StatechartHelper.statechart = _self
		_self.regions.forEach[tfsm | tfsm.currentState = null]
		_self.numberOfTicks = 0
		_self.scopes.forEach[ s | s.variables.forEach[_var | _var.init()]]
		println("[" + _self.getClass().getSimpleName() + ":" + _self.getName() + ".Init()]Initialized " + _self.name);
	}
}











//@Aspect(className=Expression)
//class ExpressionAspect {
//	def int execute() {
//		return 0
//	}
//	
//	def boolean evaluate() {
//		return true
//	}
//	
//}

@Aspect(className=Property)
class PropertyAspect {
	//@Containment(Containment.ContainmentStrategy.CONTAINER)
	public Integer currentValue = 0
	
	def void init() {
		var GroovyShell shell = StatechartHelper.getShellWithVars(_self)
		println("init "+_self.name+" with "+((_self.initialValue as PrimitiveValueExpression).value as IntLiteral).value.toString())
		_self.currentValue = shell.evaluate(((_self.initialValue as PrimitiveValueExpression).value as IntLiteral).value.toString()) as Integer
	}
	
	def String print() {
		var text = new StringBuffer();
		text.append(_self.getName());
		text.append(" = ");
		text.append(_self.currentValue);
		return text.toString();
	}
}

//@Aspect(className=IntegerVariable)
//class IntegerVariableAspect extends VariableAspect {
//	
////	@Input(cond="true")
////	@Output(cond="true")
////	@Containment(Containment.ContainmentStrategy.CONTAINER)
//	public Integer currentValue = 0
//	
//	@OverrideAspectMethod
//	def void init() {
//		_self.currentValue = _self.initialValue
//	}
//	
//	@OverrideAspectMethod
//	def String print() {
//		var text = new StringBuffer();
//		text.append(_self.getName());
//		text.append(" = ");
//		text.append(_self.currentValue);
//		return text.toString();
//	}
//}
//
//@Aspect(className=BooleanVariable)
//class BooleanVariableAspect extends VariableAspect {
//
////	@Input(cond="true")
////	@Output(cond="true")
//	@Containment(Containment.ContainmentStrategy.CONTAINER)
//	public Boolean currentValue = false;
//	
//	@OverrideAspectMethod
//	def void init() {
//		_self.currentValue = _self.initialValue
//	}
//	
//	@OverrideAspectMethod
//	def String print() {
//		var text = new StringBuffer();
//		text.append(_self.getName());
//		text.append(" = ");
//		text.append(_self.currentValue);
//		return text.toString();
//	}
//
//}



//@Aspect(className=Expression)
//class IntegerCalculationExpressionAspect extends ExpressionAspect {
//	
//	@OverrideAspectMethod
//	def int execute() {
//		if (_self.operator.value == IntegerCalculationOperator.ADD_VALUE) {
//			return _self.operand1.currentValue + _self.operand2.currentValue
//		} else if (_self.operator.value == IntegerCalculationOperator.SUBRACT_VALUE) {
//			return _self.operand1.currentValue - _self.operand2.currentValue
//		}
//	return 0
//	}
//}
//
//@Aspect(className=IntegerComparisonExpression)
//class IntegerComparisonExpressionAspect extends ExpressionAspect {
//	
//	@OverrideAspectMethod
//	def boolean evaluate() {
//		if (_self.operator.value == IntegerComparisonOperator.EQUALS_VALUE) {
//			return _self.operand1.currentValue == _self.operand2.currentValue
//		} else if (_self.operator.value == IntegerComparisonOperator.GREATER_EQUALS_VALUE) {
//			return _self.operand1.currentValue >= _self.operand2.currentValue
//		} else if (_self.operator.value == IntegerComparisonOperator.GREATER_VALUE) {
//			return _self.operand1.currentValue > _self.operand2.currentValue
//		} else if (_self.operator.value == IntegerComparisonOperator.SMALLER_EQUALS_VALUE) {
//			return _self.operand1.currentValue <= _self.operand2.currentValue
//		} else if (_self.operator.value == IntegerComparisonOperator.SMALLER_VALUE) {
//			return _self.operand1.currentValue < _self.operand2.currentValue
//		}
//		return true
//	}
//}
//
//@Aspect(className=BooleanUnaryExpression)
//class BooleanUnaryExpressionAspect extends ExpressionAspect {
//	@OverrideAspectMethod
//	def boolean evaluate() {
//		if (_self.operator.value == BooleanUnaryOperator.NOT_VALUE) {
//			return !_self.operand.currentValue
//		}
//		return true
//	}
//}
// 
//@Aspect(className=BooleanBinaryExpression)
//class BooleanBinaryExpressionAspect extends ExpressionAspect {
//	@OverrideAspectMethod
//	def boolean evaluate() {
//		if (_self.operator.value == BooleanBinaryOperator.AND_VALUE) {
//			return _self.operand1.currentValue && _self.operand2.currentValue
//		} else if (_self.operator.value == BooleanBinaryOperator.OR_VALUE) {
//			return _self.operand1.currentValue || _self.operand2.currentValue
//		}
//	return true
//	}
//}
//
//@Aspect(className=OpaqueBooleanExpression)
//class OpaqueBooleanExpressionAspect extends ExpressionAspect {
//	@OverrideAspectMethod
//	def boolean evaluate() {
//		var Object res;
//		try {	
//			// add variables _self and _this for use in the expression
//			val binding = new Binding
//			binding.setVariable("_self", _self)
//			binding.setVariable("_this", _self)	
//			
//			for(Variable v : (_self.eContainer.eContainer as TimedSystem).ownedVars){
//				binding.setVariable(v.name, v)	
//			}
//				
//			val ucl = EvaluateGuardAspect.classLoader
//			val shell = new GroovyShell(ucl, binding)
//	
//			res = shell.evaluate(_self.value)
//		} catch (org.codehaus.groovy.control.MultipleCompilationErrorsException cnfe) {
//			println("Failed to call Groovy script" + cnfe.message)
//			cnfe.printStackTrace
//		}
//	return res as Boolean
//	}
//}
//
//@Aspect(className=OpaqueIntegerExpression)
//class OpaqueIntegerExpressionAspect extends ExpressionAspect {
//	@OverrideAspectMethod
//	def int execute() {
//		var Object res;
//		try {	
//			// add variables _self and _this for use in the expression
//			val binding = new Binding
//			binding.setVariable("_self", _self)
//			binding.setVariable("_this", _self)	
//			
//			for(Variable v : (_self.eContainer.eContainer as TimedSystem).ownedVars){
//				binding.setVariable(v.name, v)	
//			}
//				
//			val ucl = EvaluateGuardAspect.classLoader
//			val shell = new GroovyShell(ucl, binding)
//	
//			res = shell.evaluate(_self.value)
//		} catch (org.codehaus.groovy.control.MultipleCompilationErrorsException cnfe) {
//			println("Failed to call Groovy script" + cnfe.message)
//			cnfe.printStackTrace
//		}
//	return res as Integer
//	}
//}