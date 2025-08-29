@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void testTripCreationOnOpportunityClosedWon() {
        // ================= ARRANGE: Préparation des données de test =================
        Account testAccount = new Account(Name = 'Test Account for Trigger');
        insert testAccount;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp - Tokyo Trip',
            AccountId = testAccount.Id,
            StageName = 'Prospecting', // Étape initiale avant la mise à jour
            CloseDate = Date.today().addMonths(1),
            Amount = 75000,
            Destination__c = 'Tokyo',
            Number_of_Participants__c = 20,
            Start_Date__c = Date.today().addMonths(2),
            End_Date__c = Date.today().addMonths(2).addDays(10)
        );
        insert testOpp;

        // Début du contexte de test pour isoler les limites de gouverneur
        Test.startTest();

        // ================= ACT: Action qui déclenche le code à tester =================
        // On met à jour l'opportunité, ce qui va faire réagir notre trigger
        testOpp.StageName = 'Closed Won';
        update testOpp;

        // Fin du contexte de test
        Test.stopTest();

        // ================= ASSERT: Vérification des résultats =================
        // On récupère le voyage qui a (normalement) été créé par le trigger
        List<Trip__c> createdTrips = [
            SELECT Id, Destination__c, Total_Cost__c, Number_of_Participants__c, Account__c 
            FROM Trip__c 
            WHERE Opportunity__c = :testOpp.Id
        ];
        
        // 1. On vérifie qu'un seul et unique voyage a été créé
        System.assertEquals(1, createdTrips.size(), 'Un seul voyage aurait dû être créé après la clôture de l\'opportunité.');
        
        // On stocke le voyage créé dans une variable pour plus de lisibilité
        Trip__c createdTrip = createdTrips[0];

        // 2. On vérifie que les champs ont été correctement mappés
        System.assertEquals(testOpp.AccountId, createdTrip.Account__c, 'L\'Account du voyage ne correspond pas à celui de l\'opportunité.');
        System.assertEquals('Tokyo', createdTrip.Destination__c, 'La destination du voyage ne correspond pas à celle de l\'opportunité.');
        System.assertEquals(75000, createdTrip.Total_Cost__c, 'Le coût total du voyage ne correspond pas au montant de l\'opportunité.');
        System.assertEquals(20, createdTrip.Number_of_Participants__c, 'Le nombre de participants ne correspond pas.');
    }
}