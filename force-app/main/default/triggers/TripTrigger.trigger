/**
 * @description Trigger pour l'objet Trip__c. Gère la validation des dates.
 * S'exécute avant l'insertion et la mise à jour.
 */
trigger TripTrigger on Trip__c (before insert, before update) {
    if (Trigger.isBefore) {
        TripTriggerHandler.handleDateValidation(Trigger.new);
    }
}