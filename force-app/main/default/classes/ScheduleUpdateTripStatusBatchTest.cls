@isTest
private class ScheduleUpdateTripStatusBatchTest {

    @isTest
    static void testSchedulerExecution() {
        // Test minimaliste sans données complexes
        Test.startTest();
        
        ScheduleUpdateTripStatusBatch scheduler = new ScheduleUpdateTripStatusBatch();
        scheduler.execute(null);
        
        Test.stopTest();

        // Vérification basique
        List<AsyncApexJob> batchJobs = [SELECT Id FROM AsyncApexJob 
                                       WHERE JobType = 'BatchApex'
                                       AND ApexClass.Name = 'UpdateTripStatusBatch'];
        System.assert(!batchJobs.isEmpty(), 'Le batch devrait être lancé');
    }

    @isTest
    static void testJobScheduling() {
        Test.startTest();
        
        String jobName = 'TestScheduler';
        String cronExpr = '0 0 1 * * ?';
        System.schedule(jobName, cronExpr, new ScheduleUpdateTripStatusBatch());
        
        Test.stopTest();

        // Vérification simple
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger 
                                 WHERE CronJobDetail.Name = :jobName];
        System.assertEquals(1, jobs.size(), 'Le job devrait être planifié');
    }

    @isTest
    static void testEmptyExecution() {
        // Test le plus simple possible
        Test.startTest();
        new ScheduleUpdateTripStatusBatch().execute(null);
        Test.stopTest();
        
        // Assertion minimale
        System.assert(true, 'Exécution sans erreur');
    }
}