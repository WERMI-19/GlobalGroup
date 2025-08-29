/**
 * @description Trigger pour l'objet Opportunity.
 * Il délègue toute la logique à la classe OpportunityTriggerHandler.
 */
trigger OpportunityTrigger on Opportunity (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}