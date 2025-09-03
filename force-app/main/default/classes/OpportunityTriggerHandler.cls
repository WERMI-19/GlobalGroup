/**
 * @description Classe de logique pour le trigger sur Opportunity.
 */
public with sharing class OpportunityTriggerHandler {

    /**
     * @description NOUVELLE MÉTHODE - Valide que la date de fin est postérieure à la date de début.
     * @param newOpportunities La liste des opportunités en cours de traitement.
     */
    public static void handleDateValidation(List<Opportunity> newOpportunities) {
        for (Opportunity opp : newOpportunities) {
            // On vérifie que les deux dates sont renseignées
            if (opp.Start_Date__c != null && opp.End_Date__c != null) {
                // Si la date de fin n'est pas strictement après la date de début...
                if (opp.End_Date__c <= opp.Start_Date__c) {
                    // ... on ajoute une erreur. Cela empêchera la sauvegarde.
                    opp.End_Date__c.addError('La date de fin doit être postérieure à la date de début.');
                }
            }
        }
    }

    /**
     * @description Gère la création de Voyages après qu'une Opportunité est gagnée.
     * @param newOpportunities La liste des nouvelles versions des opportunités.
     * @param oldOpportunityMap La map des anciennes versions des opportunités.
     */
    public static void handleTripCreation(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        
        List<Trip__c> tripsToCreate = new List<Trip__c>();

        for (Opportunity opp : newOpportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);

            // On vérifie si l'opportunité vient de passer en "Closed Won"
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                
                Trip__c newTrip = new Trip__c();
                
                // Mappage complet des champs
                newTrip.Account__c = opp.AccountId;
                newTrip.Opportunity__c = opp.Id;
                newTrip.Status__c = 'A venir';
                newTrip.Destination__c = opp.Destination__c;
                newTrip.Start_Date__c = opp.Start_Date__c;
                newTrip.End_Date__c = opp.End_Date__c;
                newTrip.Number_of_Participants__c = opp.Number_of_Participants__c;
                newTrip.Total_Cost__c = opp.Amount;
                
                tripsToCreate.add(newTrip);
            }
        }

        if (!tripsToCreate.isEmpty()) {
            try {
                insert tripsToCreate;
            } catch (DmlException e) {
                System.debug('Erreur lors de la création des voyages : ' + e.getMessage());
            }
        }
    }
}