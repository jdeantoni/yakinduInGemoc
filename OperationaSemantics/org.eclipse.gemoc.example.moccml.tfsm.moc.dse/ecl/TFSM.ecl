import 'http://www.yakindu.org/sct/statechart/SText' 
import 'http://www.yakindu.org/base/expressions/Expressions' 
import 'http://www.yakindu.org/sct/sgraph/2.0.0'
import 'http://www.yakindu.org/base/types/2.0.0'

import _'http://www.eclipse.org/emf/2002/Ecore'


 
ECLimport "platform:/plugin/fr.inria.aoste.timesquare.ccslkernel.model/ccsllibrary/kernel.ccslLib"
ECLimport "platform:/plugin/fr.inria.aoste.timesquare.ccslkernel.model/ccsllibrary/CCSL.ccslLib"
--ECLimport "platform:/plugin/org.gemoc.sample.tfsm.moc.lib/ccsl/TFSMMoC.ccslLib"
ECLimport "platform:/resource/org.eclipse.gemoc.example.moccml.tfsm.moc.lib/ccsl/TFSMMoC.ccslLib"
ECLimport "platform:/resource/org.eclipse.gemoc.example.moccml.tfsm.moc.lib/ccsl/TFSMMoCC.moccml"


package ecore
	context EObject
	 def : allSubobjects() : Collection(EObject) = null
endpackage

package stext
endpackage 
package expressions 
endpackage

package sgraph 
/** 
 * @Public DSE
 */
	/**
	 * DSE linked to specific DSA 
	 */
  	context Statechart
     def: ticks : Event = self.ticks() --if(self.oclAsType(ecore::EObject).eAllContents()->select(eo| eo.oclIsTypeOf(Transition)).oclAsType(Transition)->exists(t | t.specification.indexOf('after') <> 0 ))
     def: start : Event = self

  	context Transition 
     def: fire : Event = self.fire()

  	 def if(self.specification.indexOf('[') > 0): evaluatedTrue : Event  = self
	 def if(self.specification.indexOf('[') > 0): evaluatedFalse : Event = self
     def if(self.specification.indexOf('[') > 0): evaluate : Event = self.evaluate() [res] switch case (res = true) force evaluatedTrue; --evaluate()
     										    			 		 case (res = false) force evaluatedFalse;
  														 
     
	/**
	 * DSE with no associated DSA
	 */ 

    context Vertex
     -- these events are tracked by the debugger thanks to the reference to self
     def : entering : Event = self.onEnter()
     def : leaving : Event = self.onExit()
    

	context Region
	  def : starting : Event = self
      def : stopping : Event = self
	
endpackage

package types	-- The user should be allowed to inject events whenever needed.
	
	context _Event
     def: occurring : Event = self.occurs()


/**
 * MoC Constraints to AS association
 */
	context _Event
		inv occursWhenSolicitate:
		let raisingTransitions : Bag(sgraph::Transition) = self.oclAsType(ecore::EObject).eContainer().eContainer().allSubobjects()->select(eo | eo.oclIsTypeOf(sgraph::Transition)).oclAsType(sgraph::Transition)->select(t |t.specification<> null and t.specification.matches('.*raise '+self.name+'.*')) in
		(raisingTransitions->size() >0) implies  
			(let AllTriggeringOccurrences : Event = Expression Union(raisingTransitions.fire) in
			Relation FSMEventRendezVous(AllTriggeringOccurrences, self.occurring))
	
endpackage 



package sgraph
 

	context Transition
	    inv fireWhenRestrueOccursTransition: 
	    	(self.specification <> null and self.specification.indexOf('[') > 0 and self.source.outgoingTransitions->select(t | (t) <> self)->size() = 0) implies
	    	let restrueOccursAfterOrWhileStateEntering :Event = Expression SampledOn(self.source.entering,self.evaluatedTrue) in
	    	Relation Coincides(restrueOccursAfterOrWhileStateEntering, self.fire) 
	    
	    inv fireWhenRestrueOccursVariousTransition:
			(self.specification <> null and self.specification.indexOf('[') > 0 and self.source.outgoingTransitions->select(t | (t) <> self)->size() > 0) implies
			let otherFireFromTheSameState3: Event = Expression Union (self.source.outgoingTransitions->select(t | (t) <> self).fire) in
		 	Relation EventGuardedTransition(self.source.entering,
		 							self.evaluatedTrue,
		 							otherFireFromTheSameState3,
		 							self.fire
		 	)
	    
		inv fireWhenEventOccursOneTransition:
			--let specEvent : Sequence(types::_Event) = self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().eAllContents()->select(eo | eo.oclIsTypeOf(types::_Event)).oclAsType(types::_Event)->select(e | e.name = self.specification.tokenize('/')->at(0).trim())->asSequence() in
			let specEvent : Sequence(types::_Event) = self.trigger.oclAsType(stext::ReactionTrigger).triggers.oclAsType(stext::RegularEventSpec).event.oclAsType(expressions::ElementReferenceExpression).reference.oclAsType(types::_Event) in
			(self.specification <> null and self.specification.indexOf('[') = 0 and self.specification.indexOf('after') =0 and specEvent->size() > 0 and self.source.outgoingTransitions->select(t| (t) <> self)->size() = 0) implies
			let eventOccursAfterOrWhileStateEntering :Event = Expression SampledOn(self.source.entering,specEvent->first().occurring) in
			Relation Coincides(eventOccursAfterOrWhileStateEntering, self.fire)  
		
		inv fireWhenEventOccursVariousTransition: 
			let specEvent : Sequence(types::_Event) = self.trigger.oclAsType(stext::ReactionTrigger).triggers.oclAsType(stext::RegularEventSpec).event.oclAsType(expressions::ElementReferenceExpression).reference.oclAsType(types::_Event) in
			(self.specification <> null and self.specification.indexOf('[') = 0 and self.specification.indexOf('after') = 0 and specEvent->size() > 0 and self.source.outgoingTransitions->select(t| (t) <> self)->size() > 0) implies
			let otherFireFromTheSameState2: Event = Expression Union (self.source.outgoingTransitions->select(t| (t) <> self).fire) in
		 	Relation EventGuardedTransition(self.source.entering,
		 							specEvent->first().occurring,
		 							otherFireFromTheSameState2,
		 							self.fire
		 	) 
		
		inv fireWhenTemporalGuardHoldsVariousTransition:
			(self.specification <> null and self.specification.indexOf('after') > 0 and self.source.outgoingTransitions->select(t| (t) <> self)->size() > 0) implies
			let guardDelay : Integer = self.specification.tokenize('/')->at(1).substituteFirst('after','').substituteFirst('ms','').trim().toInteger() in
			let otherFireFromTheSameState: Event = Expression Union (self.source.outgoingTransitions->select(t| (t) <> self).fire) in
			Relation TemporalGuardedTransition(self.source.entering,
									   self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart).ticks,
									   otherFireFromTheSameState,
									   guardDelay,
									   self.fire
			) 

		inv fireWhenTemporalGuardHoldsOneTransition:
			(self.specification <> null and self.specification.indexOf('after') > 0 and self.source.outgoingTransitions->select(t| (t) <> self)->size() = 0) implies
			let delay : Integer = self.specification.tokenize('/')->at(1).substituteFirst('after','').substituteFirst('ms','').trim().toInteger() in
			let delayIsExpired_wrt_StateEntering :Event = Expression DelayFor(
															self.source.entering,
															self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart).ticks,
															delay
			) in
			Relation Coincides(delayIsExpired_wrt_StateEntering, self.fire) 

		-- Evaluate guards is checked at the entering of the state if with no event
		-- warning the event should be specified before the guard
		inv EvaluateGuardWhenEnteringSourceState:
			(self.specification <> null and self.specification.indexOf('[') > 0 and self.specification.indexOf('[') = 1) implies
			(Relation Coincides(self.evaluate, self.source.entering)) 
			
		-- Evaluate guards is checked when associated event occurs
		-- warning the event should be specified before the guard
		inv EvaluateGuardWhenEventOccurs:
		let specEvent2 : Sequence(types::_Event) = self.trigger.oclAsType(stext::ReactionTrigger).triggers.oclAsType(stext::RegularEventSpec).event.oclAsType(expressions::ElementReferenceExpression).reference.oclAsType(types::_Event) in
			(self.specification <> null and self.specification.indexOf('[') > 0 and self.specification.indexOf('[') > 1 and specEvent2->size() > 0) implies
			(Relation GuardEvaluationWhenEvent(self.source.entering, specEvent2->first().occurring, self.evaluate, self.source.leaving)) 
			
--		-- answer Evaluate guards at least once before or when leaving source state 
--		inv AnswerEvaluateGuardBeforeLeavingSourceState:
--			(self.specification <> null and self.specification.indexOf('[') > 0) implies
--			let trueOrFalse2 : Event = Expression Union(self.evaluatedTrue, self.evaluatedFalse) in
--			let torFSampledOnFire : Event = Expression NonStrictSampledOn(trueOrFalse2, self.fire) in
--			(Relation Causes(torFSampledOnFire, self.source.leaving)) 
			
		inv evalGuardAnswerInNoTimeOrEvent:
			let theStateChart : Statechart = self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart) in
			
			(self.specification <> null and self.specification.indexOf('[') > 0) implies
			(let trueOrFalse : Event = Expression Union(self.evaluatedTrue, self.evaluatedFalse) in
			let allEvents : Event = Expression Union(theStateChart.scopes.events.oclAsType(types::_Event).occurring ) in
			let eventsOrLocalTime : Event = Expression Union(theStateChart.ticks, allEvents) in
			Relation MicroStepEnforcement(self.evaluate,eventsOrLocalTime, trueOrFalse))
			
		inv TransientInitTransition:
			(self.source.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry))->exists(v | v =self.source)) implies
			(Relation Coincides(self.source.entering, self.source.leaving))
		inv TransientInitTransition2: 
			(self.source.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry))->exists(v | v =self.source)) implies
			(Relation Coincides(self.source.leaving, self.fire))
			 
	context Vertex 
		inv enterOnceBeforeToLeave: 
			Relation WeakAlternatesFSM(self.entering, self.leaving)  
		
		inv firingATransitionAlternatesWithLeavingState:
			(self.outgoingTransitions->size() > 0) implies
			let allFiredoutgoingTransition : Event = Expression Union(self.outgoingTransitions.fire) in
			Relation Coincides(allFiredoutgoingTransition, self.leaving)
		
		inv stateEntering1:
			(not (self.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry)))->exists(v | v =self)) implies
			let allInputTransition : Event = Expression Union(self.incomingTransitions.fire) in
			Relation AlternatesFSM(allInputTransition,self.entering)
			
		--no time elapsed between the fire and the entering (micro step) (also no other events, kind of RTC)
		inv stateEntering2:
			let theStateChart : Statechart = self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart) in
			(not (self.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry))->exists(v | v =self))) implies 
			let allInputTransitionFire : Event = Expression Union(self.incomingTransitions.fire) in
			let allEvents : Event = Expression Union(theStateChart.scopes.events.oclAsType(types::_Event).occurring ) in
			let eventsOrLocalTime : Event = Expression Union(theStateChart.ticks, allEvents) in
			Relation NoTimeBetweenFireAndEntering(allInputTransitionFire,self.entering, eventsOrLocalTime) 
 
	context Transition 
		inv fireEvaluationAndResult:
			(self.specification <> null and self.specification.indexOf('[') > 0) implies
			Relation BooleanGuardedTransitionRule (self.evaluate, self.evaluatedTrue, self.evaluatedFalse)	
			
	context Region
-- not true for transient transitions
--		inv oneStateAtATime:
--			Relation Exclusion(self.ownedStates.entering)
			
		inv oneTransitionAtATime:
			(self.vertices.outgoingTransitions->size() > 1) implies
			(Relation Exclusion(self.vertices.outgoingTransitions.fire))
		
		inv startingWhenEnteringCompositeStateIfAny:
			(self.oclAsType(ecore::EObject).eContainer().oclIsKindOf(Vertex)) implies
			(Relation Precedes(self.oclAsType(ecore::EObject).eContainer().oclAsType(Vertex).entering, self.starting))
		inv stoppingWhenEnteringCompositeStateIfAny:
			(self.oclAsType(ecore::EObject).eContainer().oclIsKindOf(Vertex)) implies
			(Relation Precedes(self.oclAsType(ecore::EObject).eContainer().oclAsType(Vertex).leaving, self.stopping))
			
			
--		inv startingWhenSystemStateIfNoCompositeState:
--			(not self.oclAsType(ecore::EObject).eContainer().oclIsKindOf(Vertex)) implies
--			(Relation Precedes(self.oclAsType(ecore::EObject).eContainer().oclAsType(Statechart).start, self.starting))
		inv neverStoppingIfNoCompositeState:
			(not self.oclAsType(ecore::EObject).eContainer().oclIsKindOf(Vertex)) implies
			(Relation Precedes(self.stopping, self.stopping))
			
		inv firstIsInitialState:
			Relation Coincides(self.starting, self.vertices->select(v |v.oclIsTypeOf(Entry))->asSequence()->first().entering)
			
		
	
	context Statechart
		 
		inv startTimedSystemBeforeAllStartTFSM:
			let allStartTFSM : Event = Expression Union(self.regions.starting) in 
			Relation Precedes(self.start, allStartTFSM)
		inv allStartsTogether:
			Relation Coincides(self.regions.starting) 
		
		inv firstOnlyOnce:
			Relation OneTickAndNoMoreFSM(self.start)
endpackage