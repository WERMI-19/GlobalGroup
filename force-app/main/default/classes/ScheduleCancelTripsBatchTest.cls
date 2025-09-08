@isTest
private class ScheduleCancelTripsBatchTest {

    @isTest
    static void testSchedulerExecution() {
        // === 1. PRÉPARATION DES DONNÉES ===
        Trip__c tripToCancel = new Trip__c(
            Start_Date__c = Date.today().addDays(7),
            Number_of_Participants__c = 5,
            Status__c = 'A venir'
        );
        insert tripToCancel;

        // === 2. EXÉCUTION DU SCHEDULER ===
        Test.startTest();
        
        // Créer et exécuter DIRECTEMENT le scheduler
        ScheduleCancelTripsBatch scheduler = new ScheduleCancelTripsBatch();
        scheduler.execute(null);
        
        Test.stopTest();

        // === 3. VÉRIFICATIONS ===
        Trip__c updatedTrip = [SELECT Status__c FROM Trip__c WHERE Id = :tripToCancel.Id];
        System.assertEquals('Annulé', updatedTrip.Status__c, 
                          'Le voyage devrait être annulé par le batch');
    }

    @isTest
    static void testJobScheduling() {
        // === TEST DE LA PLANIFICATION ===
        Test.startTest();
        
        String jobName = 'Daily Cancel Trips Test';
        String cronExpr = '0 0 2 * * ?'; // Tous les jours à 2h du matin
        
        // Planifier le job
        System.schedule(jobName, cronExpr, new ScheduleCancelTripsBatch());
        
        Test.stopTest();

        // Vérifier que le job est bien planifié
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression 
                                         FROM CronTrigger 
                                         WHERE CronJobDetail.Name = :jobName];
        
        System.assertEquals(1, scheduledJobs.size(), 'Le job devrait être planifié');
        System.assertEquals(cronExpr, scheduledJobs[0].CronExpression, 
                          'L\'expression cron doit correspondre');
    }

    @isTest
    static void testBatchIntegration() {
        // === TEST D'INTÉGRATION COMPLET ===
        
        // Créer des données de test variées SANS le champ Name
        List<Trip__c> testTrips = new List<Trip__c>{
            new Trip__c( // À annuler
                Start_Date__c = Date.today().addDays(7),
                Number_of_Participants__c = 3,
                Status__c = 'A venir'
            ),
            new Trip__c( // Ne pas annuler (trop de participants)
                Start_Date__c = Date.today().addDays(7),
                Number_of_Participants__c = 15,
                Status__c = 'A venir'
            ),
            new Trip__c( // Ne pas annuler (déjà annulé)
                Start_Date__c = Date.today().addDays(7),
                Number_of_Participants__c = 2,
                Status__c = 'Annulé'
            )
        };
        insert testTrips;

        Test.startTest();
        
        // Exécuter le scheduler directement
        ScheduleCancelTripsBatch scheduler = new ScheduleCancelTripsBatch();
        scheduler.execute(null);
        
        Test.stopTest();

        // Vérifier les résultats
        List<Trip__c> results = [SELECT Id, Status__c, Number_of_Participants__c 
                                FROM Trip__c 
                                WHERE Id IN :testTrips
                                ORDER BY CreatedDate];

        // Vérifications basées sur le nombre de participants et le statut
        for (Trip__c trip : results) {
            if (trip.Number_of_Participants__c < 10 && trip.Status__c != 'Annulé') {
                // Ceux avec moins de 10 participants qui n'étaient pas déjà annulés
                System.assertEquals('Annulé', trip.Status__c, 
                                  'Les voyages avec moins de 10 participants devraient être annulés');
            } else if (trip.Number_of_Participants__c >= 10) {
                // Ceux avec 10 participants ou plus
                System.assertEquals('A venir', trip.Status__c, 
                                  'Les voyages avec 10+ participants ne devraient pas être annulés');
            } else {
                // Ceux déjà annulés
                System.assertEquals('Annulé', trip.Status__c, 
                                  'Les voyages déjà annulés devraient garder leur statut');
            }
        }
    }

    @isTest
    static void testEmptyBatchExecution() {
        // === TEST AVEC AUCUNE DONNÉE ===
        // S'assurer que le batch ne plante pas quand il n'y a rien à traiter
        
        Test.startTest();
        
        ScheduleCancelTripsBatch scheduler = new ScheduleCancelTripsBatch();
        scheduler.execute(null);
        
        Test.stopTest();

        // Aucune exception ne devrait être levée
        System.assert(true, 'Le batch devrait s\'exécuter sans erreur même avec aucune donnée');
    }
}