/**
 * @description Classe de logique pour le trigger sur Opportunity.
 * Contient les méthodes pour gérer les différentes logiques métier.
 */
public with sharing class OpportunityTriggerHandler {

    /**
     * @description Gère les actions à effectuer après la mise à jour d'une Opportunité.
     * @param newOpportunities La liste des nouvelles versions des opportunités.
     * @param oldOpportunityMap La map des anciennes versions des opportunités.
     */
    public static void handleAfterUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        
        List<Trip__c> tripsToCreate = new List<Trip__c>();

        // 1. On parcourt les opportunités qui ont été mises à jour
        for (Opportunity opp : newOpportunities) {
            
            // On récupère l'ancienne version de l'opportunité pour comparer les champs
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);

            // 2. On vérifie si l'opportunité vient de passer en "Closed Won"
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                
                Trip__c newTrip = new Trip__c();
                
                // 3. Mappage complet des champs de l'opportunité vers le voyage
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

        // 4. On insère la liste des nouveaux voyages en base de données
        if (!tripsToCreate.isEmpty()) {
            try {
                insert tripsToCreate;
            } catch (DmlException e) {
                // On logue l'erreur pour le débogage
                System.debug('Erreur lors de la création des voyages depuis le trigger Opportunity : ' + e.getMessage());
            }
        }
    }
}