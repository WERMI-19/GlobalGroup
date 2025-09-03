@isTest
private class OpportunityTriggerHandlerTest {

    // Test existant pour la création de voyage (GGT-02)
    @isTest
    static void testTripCreationOnOpportunityClosedWon() {
        // ARRANGE: Préparation des données
        Account testAccount = new Account(Name = 'Test Account for Trigger');
        insert testAccount;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp - Tokyo Trip',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Amount = 75000,
            Destination__c = 'Tokyo',
            Number_of_Participants__c = 20,
            Start_Date__c = Date.today().addMonths(2), // Dates valides
            End_Date__c = Date.today().addMonths(2).addDays(10)
        );
        insert testOpp;

        Test.startTest();
        // ACT: Action qui déclenche le trigger
        testOpp.StageName = 'Closed Won';
        update testOpp;
        Test.stopTest();

        // ASSERT: Vérifications
        List<Trip__c> createdTrips = [SELECT Id FROM Trip__c WHERE Opportunity__c = :testOpp.Id];
        System.assertEquals(1, createdTrips.size(), 'Un seul voyage aurait dû être créé.');
    }

    // ================= NOUVEAUX TESTS POUR LA VALIDATION (GGT-03 sur Opp) =================

    @isTest
    static void testDateValidation_PositiveScenario() {
        // ARRANGE: Créer une opportunité avec des dates valides
        Opportunity validOpp = new Opportunity(
            Name = 'Valid Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Start_Date__c = Date.today().addMonths(2), // Date de début
            End_Date__c = Date.today().addMonths(2).addDays(1) // Date de fin est bien après
        );

        Test.startTest();
        // ACT: Tenter d'insérer l'enregistrement
        Database.SaveResult result = Database.insert(validOpp, false); // On n'attend pas d'exception
        Test.stopTest();

        // ASSERT: L'insertion doit réussir
        System.assert(result.isSuccess(), 'L\'insertion aurait dû réussir avec des dates valides.');
    }

    @isTest
    static void testDateValidation_NegativeScenario() {
        // ARRANGE: Créer une opportunité avec des dates INvalides
        Opportunity invalidOpp = new Opportunity(
            Name = 'Invalid Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Start_Date__c = Date.today().addMonths(2), // Date de début
            End_Date__c = Date.today().addMonths(1) // Date de fin est AVANT la date de début
        );

        Test.startTest();
        // ACT & ASSERT: Tenter d'insérer l'enregistrement, on s'attend à une erreur
        try {
            insert invalidOpp;
            // Si on arrive ici, le test échoue car l'erreur attendue n'a pas eu lieu
            System.assert(false, 'Une DmlException était attendue car les dates sont invalides.');
        } catch (DmlException e) {
            // L'erreur a bien été attrapée !
            // On vérifie que le message d'erreur est celui que nous avons défini
            System.assert(e.getMessage().contains('La date de fin doit être postérieure à la date de début.'),
                'Le message d\'erreur ne correspond pas à celui attendu.');
        }
        Test.stopTest();
    }
}