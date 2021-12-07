import 'http://www.yakindu.org/sct/statechart/SText' 
import 'http://www.yakindu.org/base/expressions/Expressions' 
import 'http://www.yakindu.org/sct/sgraph/2.0.0'
import 'http://www.yakindu.org/base/types/2.0.0'

import _'http://www.eclipse.org/emf/2002/Ecore'



ECLimport "platform:/plugin/fr.inria.aoste.timesquare.ccslkernel.model/ccsllibrary/kernel.ccslLib"
ECLimport "platform:/plugin/fr.inria.aoste.timesquare.ccslkernel.model/ccsllibrary/CCSL.ccslLib"
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

  	context Statechart
     def: ticks : Event = self.ticks() --if(self.oclAsType(ecore::EObject).eAllContents()->select(eo| eo.oclIsTypeOf(Transition)).oclAsType(Transition)->exists(t | t.specification.indexOf('after') <> 0 ))
     def: start : Event = self

  	context Transition 
     def: fire : Event = self.fire()
     def: reset : Event = self

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
     def if (self.oclAsType(State).specification<> null and self.oclAsType(State).specification.matches('.*every.*') and self.oclAsType(State).specification.replaceAll('.*every[^/]*/','').replaceAll('(enter|exit).*','').matches('.*raise.*')): fireRaiseOfEveryStatement : Event = self

--TODO: manage fireRaiseOfEveryStatement

	context Region
	  def : starting : Event = self
      def : stopping : Event = self
	
endpackage

package types	-- The user should be allowed to inject events whenever needed.
	
	context _Event
     def: occurring : Event = self
 
/**
 * MoC Constraints to AS association
 */
	context _Event
		def: raisingTransitions : Bag(sgraph::Transition) = self.oclAsType(ecore::EObject).eContainer().eContainer().allSubobjects()->select(eo | eo.oclIsTypeOf(sgraph::Transition)).oclAsType(sgraph::Transition)->select(t |t.specification<> null and t.specification.matches('.*raise '+self.name+'.*'))
		def: raisingOnEntry : Bag(sgraph::State) = self.oclAsType(ecore::EObject).eContainer().eContainer().allSubobjects()->select(eo | eo.oclIsTypeOf(sgraph::State)).oclAsType(sgraph::State)->select(s |s.specification<> null and s.specification.matches('.*entry.*') and s.specification.replaceAll(' *entry[^/]*/','').replaceAll('(every|exit).*','').matches('.*raise '+self.name+'.*'))
		def: raisingOnExit : Bag(sgraph::State) = self.oclAsType(ecore::EObject).eContainer().eContainer().allSubobjects()->select(eo | eo.oclIsTypeOf(sgraph::State)).oclAsType(sgraph::State)->select(s |s.specification<> null and s.specification.matches('.*exit.*') and s.specification.replaceAll('.*exit[^/]*/','').replaceAll('(every).*','').matches('.*raise '+self.name+'.*'))
		def: raisingOnEvery : Bag(sgraph::State) = self.oclAsType(ecore::EObject).eContainer().eContainer().allSubobjects()->select(eo | eo.oclIsTypeOf(sgraph::State)).oclAsType(sgraph::State)->select(s |s.specification<> null and s.specification.matches('.*every.*') and s.specification.replaceAll('.*every[^/]*/','').replaceAll('(enter|exit).*','').matches('.*raise '+self.name+'.*'))
		
		inv occursWhenSolicitate1:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() >0 and raisingOnEvery->size() = 0) implies 
		  ( let allTriggeringStateEntry1 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringTransitions1 : Event = Expression Union(raisingTransitions.fire) in
		    let allTriggeringStateExit1 : Event = Expression Union(raisingOnExit.leaving) in
		    let entryUnionFire1 : Event = Expression Union(allTriggeringStateEntry1, allTriggeringTransitions1) in
		    let entryUnionFireUnionExit1 : Event = Expression Union(allTriggeringStateExit1,entryUnionFire1) in
			Relation FSMEventRendezVous(entryUnionFireUnionExit1, self.occurring))
			
		inv occursWhenSolicitate2:
		(raisingOnExit->size()=0 and raisingOnEntry->size() > 0 and raisingTransitions->size() >0 and raisingOnEvery->size() = 0) implies
		  ( let allTriggeringStateEntry2 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringTransitions2 : Event = Expression Union(raisingTransitions.fire) in
		    let entryUnionFire2 : Event = Expression Union(allTriggeringStateEntry2, allTriggeringTransitions2) in
			Relation FSMEventRendezVous(entryUnionFire2, self.occurring))
			
		inv occursWhenSolicitate3:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() >0 and raisingOnEvery->size() = 0) implies
		  ( let allTriggeringTransitions3 : Event = Expression Union(raisingTransitions.fire) in
		    let allTriggeringStateExit3 : Event = Expression Union(raisingOnExit.leaving) in
		    let exitUnionFire3 : Event = Expression Union(allTriggeringStateExit3, allTriggeringTransitions3) in
			Relation FSMEventRendezVous(exitUnionFire3, self.occurring))
			
		inv occursWhenSolicitate4:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() =0 and raisingOnEvery->size() = 0) implies
		  ( let allTriggeringStateEntry4 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringStateExit4 : Event = Expression Union(raisingOnExit.leaving) in
		    let entryUnionExit4 : Event = Expression Union(allTriggeringStateExit4,allTriggeringStateEntry4) in
			Relation FSMEventRendezVous(entryUnionExit4, self.occurring))
			
		inv occursWhenSolicitate5:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() >0 and raisingOnEvery->size() = 0) implies
		  ( let allTriggeringTransitions5 : Event = Expression Union(raisingTransitions.fire) in
			Relation FSMEventRendezVous(allTriggeringTransitions5, self.occurring))
			
		inv occursWhenSolicitate6:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() =0 and raisingOnEvery->size() = 0) implies
		  ( let allTriggeringStateEntry6 : Event = Expression Union(raisingOnEntry.entering) in
			Relation FSMEventRendezVous(allTriggeringStateEntry6, self.occurring))
		
		inv occursWhenSolicitate7:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() =0 and raisingOnEvery->size() = 0) implies
		  (let allTriggeringStateExit7 : Event = Expression Union(raisingOnExit.leaving) in
			Relation FSMEventRendezVous(allTriggeringStateExit7, self.occurring))
	
		inv occursWhenSolicitate8:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() >0 and raisingOnEvery->size() > 0) implies 
		  ( let allTriggeringStateEntry8 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringTransitions8 : Event = Expression Union(raisingTransitions.fire) in
		    let allTriggeringStateExit8 : Event = Expression Union(raisingOnExit.leaving) in
		    let allTriggeringEvery8 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		    let entryUnionFire8 : Event = Expression Union(allTriggeringStateEntry8, allTriggeringTransitions8) in
		    let entryUnionFireUnionExit8 : Event = Expression Union(allTriggeringStateExit8,entryUnionFire8) in
		    let entryUnionFireUnionExit1UnionEvery8 : Event = Expression Union(allTriggeringEvery8, entryUnionFireUnionExit8) in
			Relation FSMEventRendezVous(entryUnionFireUnionExit1UnionEvery8, self.occurring))
			
		inv occursWhenSolicitate9:
		(raisingOnExit->size()=0 and raisingOnEntry->size() > 0 and raisingTransitions->size() >0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringStateEntry9 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringTransitions9 : Event = Expression Union(raisingTransitions.fire) in
		    let allTriggeringEvery9 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		    let entryUnionFire9 : Event = Expression Union(allTriggeringStateEntry9, allTriggeringTransitions9) in
		    let entryUnionFire2UnionEvery9 : Event = Expression Union(entryUnionFire9, allTriggeringEvery9) in
			Relation FSMEventRendezVous(entryUnionFire2UnionEvery9, self.occurring))
			
		inv occursWhenSolicitate10:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() >0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringTransitions10 : Event = Expression Union(raisingTransitions.fire) in
		    let allTriggeringStateExit10 : Event = Expression Union(raisingOnExit.leaving) in
		    let allTriggeringEvery10 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		    let exitUnionFire10 : Event = Expression Union(allTriggeringStateExit10, allTriggeringTransitions10) in
		    let exitUnionFire3UnionEvery10 : Event = Expression Union(allTriggeringEvery10, exitUnionFire10) in
			Relation FSMEventRendezVous(exitUnionFire3UnionEvery10, self.occurring))
			
		inv occursWhenSolicitate11:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() =0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringStateEntry11 : Event = Expression Union(raisingOnEntry.entering) in
		    let allTriggeringStateExit11 : Event = Expression Union(raisingOnExit.leaving) in
		    let allTriggeringEvery11 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		    let entryUnionExit11 : Event = Expression Union(allTriggeringStateExit11,allTriggeringStateEntry11) in
		    let entryUnionExit4UnionEvery11 : Event = Expression Union(entryUnionExit11,allTriggeringEvery11) in
			Relation FSMEventRendezVous(entryUnionExit4UnionEvery11, self.occurring))
			
		inv occursWhenSolicitate12:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() >0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringTransitions12 : Event = Expression Union(raisingTransitions.fire) in
		  	let allTriggeringEvery12 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		  	let trigUnionEvery12 : Event = Expression Union(allTriggeringEvery12,allTriggeringEvery12) in
			Relation FSMEventRendezVous(trigUnionEvery12, self.occurring))
			
		inv occursWhenSolicitate13:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() > 0 and raisingTransitions->size() =0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringStateEntry13 : Event = Expression Union(raisingOnEntry.entering) in
		  	let allTriggeringEvery13 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		  	let entryUnionEvery13 : Event = Expression Union(allTriggeringEvery13,allTriggeringStateEntry13) in
			Relation FSMEventRendezVous(entryUnionEvery13, self.occurring))
		
		inv occursWhenSolicitate14:
		(raisingOnExit->size() > 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() =0 and raisingOnEvery->size() > 0) implies
		  ( let allTriggeringStateExit14 : Event = Expression Union(raisingOnExit.leaving) in
		  	let allTriggeringEvery14 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
		  	let trigUnionExit14 : Event = Expression Union(allTriggeringEvery14,allTriggeringStateExit14) in
			Relation FSMEventRendezVous(trigUnionExit14, self.occurring))
	
		inv occursWhenSolicitate15:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() =0 and raisingOnEvery->size() > 0) implies
		  (let allTriggeringEvery15 : Event = Expression Union(raisingOnEvery.fireRaiseOfEveryStatement) in
			Relation FSMEventRendezVous(allTriggeringEvery15, self.occurring))
			
		inv occursWhenSolicitate15bis:
		(raisingOnExit->size() = 0 and raisingOnEntry->size() = 0 and raisingTransitions->size() =0 and raisingOnEvery->size() > 0 and raisingOnEvery->size() = 1) implies
		  Relation AllowedInBetween(raisingOnEvery->asSequence()->first().entering, self.occurring, raisingOnEvery->asSequence()->first().leaving) 
	
endpackage 



package sgraph
 
	context Transition
    
	    inv resetDefinitionOneTransitionsNoSuperState: --never ticks
	    	(self.source.outgoingTransitions->select(t | (t) <> self)->size() = 0
	    		and 
	    	 (not self.source.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex))
	    	) implies
	    	(Relation Precedes(self.reset, self.reset))
	    
	    inv resetDefinitionVariousTransitionsNoSuperState:
	    	(self.source.outgoingTransitions->select(t | (t) <> self)->size() > 0
	    		and 
	    	 (not self.source.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex))
	    	) implies
	    	(let otherFireFromTheSameState: Event = Expression Union (self.source.outgoingTransitions->select(t | (t) <> self).fire) in
	    	Relation Coincides(self.reset, otherFireFromTheSameState))
	   
	    inv resetDefinitionOneTransitionsSuperState: 
	    	(self.source.outgoingTransitions->select(t | (t) <> self)->size() = 0
	    		and 
	    	 (self.source.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex))
	    	) implies
	    	 (let anyUpperLeave2 : Event = Expression Union(self.source.oclAsType(ecore::EObject)->closure(eo | eo.eContainer().eContainer())->select(eo | eo.oclIsKindOf(Vertex)).oclAsType(Vertex).leaving) in
	    	  Relation Coincides(self.reset, anyUpperLeave2)) 
	    
	    inv resetDefinitionVariousTransitionsSuperState:
	    	(self.source.outgoingTransitions->select(t | (t) <> self)->size() > 0
	    		and 
	    	 (self.source.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex))
	    	) implies
	    	(let otherFireFromTheSameState2: Event = Expression Union (self.source.outgoingTransitions->select(t | (t) <> self).fire) in
			 let anyUpperLeave1 : Event = Expression Union(self.source.oclAsType(ecore::EObject)->closure(eo | eo.eContainer().eContainer())->select(eo | eo.oclIsKindOf(Vertex)).oclAsType(Vertex).leaving) in
	    	 let allReset : Event = Expression Union(otherFireFromTheSameState2, anyUpperLeave1) in	
	    	Relation Coincides(self.reset, allReset))
	   
	    
	    inv fireWhenResTrueOccurs:
			(self.specification <> null and self.specification.indexOf('[') > 0) implies
		 	Relation EventGuardedTransition(self.source.entering,
		 							self.evaluatedTrue,
		 							self.reset,
		 							self.fire
		 	)
		
		inv fireWhenEventOccurs: 
			let specEvent : Sequence(types::_Event) = self.trigger.oclAsType(stext::ReactionTrigger).triggers.oclAsType(stext::RegularEventSpec).event.oclAsType(expressions::ElementReferenceExpression).reference.oclAsType(types::_Event) in
			(self.specification <> null and self.specification.indexOf('[') = 0 and self.specification.indexOf('after') = 0 and specEvent->size() > 0) implies
		 	Relation EventGuardedTransition(self.source.entering,
		 							specEvent->first().occurring,
		 							self.reset,
		 							self.fire
		 	) 
		
		inv fireWhenTemporalGuardHolds:
			(self.specification <> null and self.specification.indexOf('after') > 0) implies
			let guardDelay : Integer = self.specification.tokenize('/')->at(1).substituteFirst('after','').substituteFirst('ms','').trim().toInteger() in
			Relation TemporalGuardedTransition(self.source.entering,
									   self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart).ticks,
									   self.reset,
									   guardDelay,
									   self.fire
			) 


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
		
		inv leavingStateWhenTransitionfireNoSuperState:
			(not self.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex))
			implies
			(let allFiredoutgoingTransition3 : Event = Expression Union(self.outgoingTransitions.fire) in
			Relation Coincides(allFiredoutgoingTransition3, self.leaving))
		
		inv leavingStateWhenTransitionFireOrSuperStateLeaves:
			(self.oclAsType(ecore::EObject).eContainer().eContainer().oclIsKindOf(Vertex)
			and (not (self.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry)))->exists(v | v =self))
			)
			implies
			(let allFiredoutgoingTransition4 : Event = Expression Union(self.outgoingTransitions.fire) in
			let anyUpperLeave : Event = Expression Union(self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer().eContainer())->select(eo | eo.oclIsKindOf(Vertex)).oclAsType(Vertex).leaving) in
			Relation InternalStateLeaving(self.entering, self.leaving, allFiredoutgoingTransition4, anyUpperLeave))
		
		
		
		inv stateEntering1:
			(not (self.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry)))->exists(v | v =self)) implies
			let allInputTransition : Event = Expression Union(self.incomingTransitions.fire) in
			Relation AlternatesFSM(allInputTransition,self.entering)
			
		--no time elapsed between the fire and the entering (micro step) (also no other events, kind of RTC)
		inv stateEntering2:
			let theStateChart : Statechart = self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart) in
			(not (self.parentRegion.vertices->select(v |v.oclIsTypeOf(Entry))->exists(v | v =self))) implies 
			let allInputTransitionFire : Event = Expression Union(self.incomingTransitions.fire) in
--			let allEvents2 : Event = Expression Union(theStateChart.scopes.events.oclAsType(types::_Event).occurring ) in
--			let eventsOrLocalTime : Event = Expression Union(theStateChart.ticks, allEvents) in
			Relation NoTimeBetweenFireAndEntering(allInputTransitionFire,self.entering, theStateChart.ticks) 
 
 
 		inv everyManagement:
 		(self.oclAsType(State).specification<> null and self.oclAsType(State).specification.matches('.*every.*') and self.oclAsType(State).specification.replaceAll('.*every[^/]*/','').replaceAll('(enter|exit).*','').matches('.*raise.*')) implies
 		(let guardDelay : Integer = self.oclAsType(State).specification.replaceAll('.*every([^/]*)/.*','$1').substituteFirst('ms','').trim().toInteger() in
			Relation StateEveryClause(self.entering,
									   self.oclAsType(ecore::EObject)->closure(eo | eo.eContainer())->select(eo|eo.oclIsTypeOf(Statechart))->asSequence()->first().oclAsType(sgraph::Statechart).ticks,
									   self.leaving,
									   guardDelay,
									   self.fireRaiseOfEveryStatement
			) ) 
 			
 
 
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
			(Relation Coincides(self.oclAsType(ecore::EObject).eContainer().oclAsType(Vertex).entering, self.starting))
		inv stoppingWhenLeavingCompositeStateIfAny:
			(self.oclAsType(ecore::EObject).eContainer().oclIsKindOf(Vertex)) implies
			(Relation Coincides(self.oclAsType(ecore::EObject).eContainer().oclAsType(Vertex).leaving, self.stopping))
			
			
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
			
		inv noTicksIfUntimed:
			(self.oclAsType(ecore::EObject).allSubobjects()->select(eo | eo.oclIsKindOf(Transition)).oclAsType(Transition)->select(t | (t.specification <> null and t.specification.indexOf('after') > 0)) ->size() = 0) implies
			(Relation Precedes(self.ticks, self.ticks))
		inv oneEventAtATime:
			Relation Exclusion(self.scopes.events.oclAsType(types::_Event).occurring)
			
endpackage