@isTest
private class UpdateTripStatusBatchTest {

    @isTest
    static void testBatchStatusUpdates() {
        // === ARRANGE: Créer des voyages pour chaque scénario de date ===
        List<Trip__c> testTrips = new List<Trip__c>();

        // 1. Voyage dans le futur -> doit devenir "A venir"
        testTrips.add(new Trip__c(Start_Date__c = Date.today().addDays(10), End_Date__c = Date.today().addDays(20), Status__c = 'En cours')); // Statut incorrect exprès

        // 2. Voyage en cours -> doit devenir "En cours"
        testTrips.add(new Trip__c(Start_Date__c = Date.today().addDays(-2), End_Date__c = Date.today().addDays(5), Status__c = 'A venir')); // Statut incorrect exprès

        // 3. Voyage terminé -> doit devenir "Terminé"
        testTrips.add(new Trip__c(Start_Date__c = Date.today().addDays(-15), End_Date__c = Date.today().addDays(-10), Status__c = 'En cours')); // Statut incorrect exprès

        // 4. Voyage déjà terminé -> ne doit pas être traité par le batch
        testTrips.add(new Trip__c(Start_Date__c = Date.today().addDays(-30), End_Date__c = Date.today().addDays(-20), Status__c = 'Terminé'));

        insert testTrips;

        // === ACT: Exécution du Batch ===
        Test.startTest();
        Database.executeBatch(new UpdateTripStatusBatch());
        Test.stopTest();

        // === ASSERT: Vérification des nouveaux statuts ===
        Map<Id, Trip__c> updatedTrips = new Map<Id, Trip__c>([SELECT Id, Status__c FROM Trip__c]);

        System.assertEquals('A venir', updatedTrips.get(testTrips[0].Id).Status__c, 'Le statut du voyage futur devrait être "A venir".');
        System.assertEquals('En cours', updatedTrips.get(testTrips[1].Id).Status__c, 'Le statut du voyage actuel devrait être "En cours".');
        System.assertEquals('Terminé', updatedTrips.get(testTrips[2].Id).Status__c, 'Le statut du voyage passé devrait être "Terminé".');
        System.assertEquals('Terminé', updatedTrips.get(testTrips[3].Id).Status__c, 'Le statut de ce voyage ne devait pas changer.');
    }
}