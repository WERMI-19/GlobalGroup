@isTest
private class ScheduleCancelTripsBatchTest {

    @isTest
    static void testScheduledBatchExecution() {
        // === ARRANGE: Préparation des données de test ===
        Trip__c tripToCancel = new Trip__c(
            Start_Date__c = Date.today().addDays(7),
            Number_of_Participants__c = 5,
            Status__c = 'A venir'
        );
        insert tripToCancel;

        // ===================================================================
        // === AJOUTER CE BLOC DE DÉBOGAGE ===
        // On simule la requête EXACTE du batch pour voir si elle trouve notre enregistrement
        Date debugTargetDate = Date.today().addDays(7);
        List<Trip__c> foundTrips = [
            SELECT Id FROM Trip__c
            WHERE Id = :tripToCancel.Id
            AND Start_Date__c = :debugTargetDate
            AND Number_of_Participants__c < 10
            AND Status__c = 'A venir'
        ];
        // Ce test va vérifier si nos données de test sont correctes AVANT de lancer le batch
        System.assertEquals(1, foundTrips.size(), 'DEBUG: L\'enregistrement de test ne correspond pas aux critères de la requête du batch.');
        // === FIN DU BLOC DE DÉBOGAGE ===
        // ===================================================================

        // === ACT: Planification et exécution du job ===
        Test.startTest();
        String cronExpression = '0 30 * * * ?';
        System.schedule('Test Annulation Quotidienne', cronExpression, new ScheduleCancelTripsBatch());
        Test.stopTest();

        // === ASSERT: Vérification des résultats ===
        Trip__c resultTrip = [SELECT Status__c FROM Trip__c WHERE Id = :tripToCancel.Id];
        System.assertEquals('Annulé', resultTrip.Status__c, 'Le statut du voyage aurait dû être mis à jour à "Annulé" par le batch planifié.');
    }
}