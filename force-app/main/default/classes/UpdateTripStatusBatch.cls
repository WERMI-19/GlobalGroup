/**
 * @description Batch qui met à jour quotidiennement le statut des voyages
 * en fonction de la date du jour.
 */
public class UpdateTripStatusBatch implements Database.Batchable<sObject> {

    /**
     * @description Récupère tous les voyages dont le statut n'est pas final (Terminé ou Annulé).
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status__c, Start_Date__c, End_Date__c FROM Trip__c ' +
                       'WHERE Status__c NOT IN (\'Terminé\', \'Annulé\')';
        return Database.getQueryLocator(query);
    }

    /**
     * @description Met à jour le statut de chaque voyage en fonction de sa date.
     */
    public void execute(Database.BatchableContext bc, List<Trip__c> scope) {
        List<Trip__c> tripsToUpdate = new List<Trip__c>();
        Date today = Date.today();

        for (Trip__c trip : scope) {
            String newStatus = trip.Status__c; // On part du statut actuel

            if (today < trip.Start_Date__c) {
                newStatus = 'A venir';
            } else if (today >= trip.Start_Date__c && today <= trip.End_Date__c) {
                newStatus = 'En cours';
            } else if (today > trip.End_Date__c) {
                newStatus = 'Terminé';
            }

            // Optimisation : on ajoute à la liste de mise à jour uniquement si le statut a changé.
            if (newStatus != trip.Status__c) {
                trip.Status__c = newStatus;
                tripsToUpdate.add(trip);
            }
        }

        if (!tripsToUpdate.isEmpty()) {
            update tripsToUpdate;
        }
    }

    /**
     * @description Méthode Finish exécutée à la fin du batch.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch UpdateTripStatusBatch terminé.');
    }
}