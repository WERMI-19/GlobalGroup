@isTest
private class TripTriggerHandlerTest {

    @isTest
    static void testDateValidation_PositiveScenario() {
        // SCÉNARIO POSITIF : Les dates sont valides, la sauvegarde doit réussir.

        // Préparation des données
        Trip__c validTrip = new Trip__c(
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15) // Date de fin est bien après la date de début
        );

        Test.startTest();
        // Action : On essaie d'insérer le voyage
        Database.SaveResult result = Database.insert(validTrip, false); // false pour ne pas lever d'exception
        Test.stopTest();

        // Vérification : L'insertion a dû réussir
        System.assert(result.isSuccess(), 'L\'insertion aurait dû réussir avec des dates valides.');
    }

    @isTest
    static void testDateValidation_NegativeScenario() {
        // SCÉNARIO NÉGATIF : Les dates sont invalides, la sauvegarde doit échouer.

        // Préparation des données
        Trip__c invalidTrip = new Trip__c(
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(5) // Date de fin est AVANT la date de début
        );

        Test.startTest();
        // Action : essayer d'insérer le voyage,=> erreur
        try {
            insert invalidTrip;
            // Si le code arrive ici, le test a échoué car aucune erreur n'a été levée.
            System.assert(false, 'Une DmlException était attendue car les dates sont invalides.');
        } catch (DmlException e) {
            // Vérification : L'erreur a bien été attrapée !
            // vérifier si le message d'erreur est bien celui que nous avons défini.
            System.assert(e.getMessage().contains('La date de fin doit être postérieure à la date de début.'),
                'Le message d\'erreur ne correspond pas à celui attendu.');
        }
        Test.stopTest();
    }
}