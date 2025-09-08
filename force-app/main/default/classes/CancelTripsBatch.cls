/**
 * @description Batch qui annule les voyages ayant moins de 10 participants 7 jours avant leur date de début.
 */
public class CancelTripsBatch implements Database.Batchable<sObject> {

    /**
     * @description Méthode Start : collecte les voyages à traiter.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date targetDate = Date.today().addDays(7);

        String query = 'SELECT Id, Status__c FROM Trip__c ' +
                       'WHERE Start_Date__c = :targetDate ' +
                       'AND Number_of_Participants__c < 10 ' +
                       'AND Status__c != \'Annulé\'';
        
        return Database.getQueryLocator(query);
    }

    /**
     * @description Méthode Execute : traite chaque lot de voyages.
     */
    public void execute(Database.BatchableContext bc, List<Trip__c> scope) {
        for (Trip__c trip : scope) {
            trip.Status__c = 'Annulé';
        }
        update scope;
    }

    /**
     * @description Méthode Finish : tous les lots sont terminés.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch CancelTripsBatch terminé avec succès.');
    }
}