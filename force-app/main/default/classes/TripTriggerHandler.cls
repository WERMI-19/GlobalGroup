/**
 * @description Classe de logique pour le trigger sur Trip__c.
 */
public with sharing class TripTriggerHandler {

    /**
     * @description Valide que la date de fin est postérieure à la date de début.
     * @param newTrips La liste des voyages en cours de traitement.
     */
    public static void handleDateValidation(List<Trip__c> newTrips) {
        // On parcourt chaque voyage avant qu'il ne soit sauvegardé
        for (Trip__c trip : newTrips) {
            // On vérifie que les deux dates sont renseignées pour éviter une erreur "null"
            if (trip.Start_Date__c != null && trip.End_Date__c != null) {
                // Si la date de fin n'est pas strictement après la date de début...
                if (trip.End_Date__c <= trip.Start_Date__c) {
                    // ... on ajoute une erreur sur le champ End_Date__c.
                    // Cela empêchera la sauvegarde de l'enregistrement et affichera le message à l'utilisateur.
                    trip.End_Date__c.addError('La date de fin doit être postérieure à la date de début.');
                }
            }
        }
    }
}