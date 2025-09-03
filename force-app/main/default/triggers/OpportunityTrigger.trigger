/**
 * @description Trigger pour l'objet Opportunity.
 * Gère la validation des dates et la création automatique des voyages.
 */
trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    // Événement AVANT la sauvegarde : pour la validation
    if (Trigger.isBefore) {
        OpportunityTriggerHandler.handleDateValidation(Trigger.new);
    }
    
    // Événement APRÈS la sauvegarde : pour la création d'enregistrements liés
    if (Trigger.isAfter && Trigger.isUpdate) {
        // Renommée pour plus de clarté, mais fait la même chose qu'avant
        OpportunityTriggerHandler.handleTripCreation(Trigger.new, Trigger.oldMap);
    }
}