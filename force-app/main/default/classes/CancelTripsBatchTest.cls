@isTest
private class CancelTripsBatchTest {

    @testSetup
    static void setupTestData() {
        // Création d'un compte et d'une opportunité pour les relations lookup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id
        );
        insert testOpportunity;
    }

    @isTest
    static void testBatchLogic() {
        // Récupérer les enregistrements créés dans le setup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // === ARRANGE: Préparation des données de test ===

        // 1. Voyage qui DOIT être annulé
        Trip__c tripToCancel = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(14),
            Number_of_Participants__c = 5, // Moins de 10
            Total_Cost__c = 5000,
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id
        );

        // 2. Voyage à ignorer (trop de participants) - NOM CORRIGÉ
        Trip__c tripToIgnoreTooManyParticipants = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Londres',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(14),
            Number_of_Participants__c = 15, // Plus de 10
            Total_Cost__c = 15000,
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id
        );

        // 3. Voyage à ignorer (mauvaise date) - NOM CORRIGÉ
        Trip__c tripToIgnoreWrongDate = new Trip__c(
            Status__c = 'A venir',
            Destination__c = 'Berlin',
            Start_Date__c = Date.today().addDays(8), // Pas la bonne date
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 3,
            Total_Cost__c = 3000,
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id
        );

        // 4. Voyage à ignorer (déjà annulé) - NOM CORRIGÉ
        Trip__c tripToIgnoreAlreadyCancelled = new Trip__c(
            Status__c = 'Annulé', // Statut déjà correct
            Destination__c = 'Madrid',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(14),
            Number_of_Participants__c = 2,
            Total_Cost__c = 2000,
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id
        );

        insert new List<Trip__c>{
            tripToCancel, 
            tripToIgnoreTooManyParticipants, 
            tripToIgnoreWrongDate, 
            tripToIgnoreAlreadyCancelled
        };

        // === ACT: Exécution du Batch ===
        Test.startTest();
        Database.executeBatch(new CancelTripsBatch());
        Test.stopTest();

        // === ASSERT: Vérification des résultats ===

        // On vérifie le statut du premier voyage
        Trip__c resultTripToCancel = [SELECT Status__c, Name FROM Trip__c WHERE Id = :tripToCancel.Id];
        System.assertEquals('Annulé', resultTripToCancel.Status__c, 'Le voyage ' + resultTripToCancel.Name + ' aurait dû être annulé.');

        // On vérifie que les autres voyages n'ont pas été modifiés
        Trip__c resultTripToIgnore1 = [SELECT Status__c, Name FROM Trip__c WHERE Id = :tripToIgnoreTooManyParticipants.Id];
        System.assertEquals('A venir', resultTripToIgnore1.Status__c, 'Le voyage ' + resultTripToIgnore1.Name + ' ne devait pas changer de statut.');

        Trip__c resultTripToIgnore2 = [SELECT Status__c, Name FROM Trip__c WHERE Id = :tripToIgnoreWrongDate.Id];
        System.assertEquals('A venir', resultTripToIgnore2.Status__c, 'Le voyage ' + resultTripToIgnore2.Name + ' ne devait pas changer de statut.');

        Trip__c resultTripToIgnore3 = [SELECT Status__c, Name FROM Trip__c WHERE Id = :tripToIgnoreAlreadyCancelled.Id];
        System.assertEquals('Annulé', resultTripToIgnore3.Status__c, 'Le voyage ' + resultTripToIgnore3.Name + ' était déjà annulé et ne devait pas changer.');
    }

    @isTest
    static void testBatchCoverage() {
        // Test de la méthode start
        CancelTripsBatch batch = new CancelTripsBatch();
        Database.QueryLocator ql = batch.start(null);
        System.assertNotEquals(null, ql, 'Le QueryLocator ne devrait pas être null');
        
        // Test de la méthode execute avec une liste vide
        batch.execute(null, new List<Trip__c>());
        
        // Test de la méthode finish
        batch.finish(null);
    }
}