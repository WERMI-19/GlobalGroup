/**
 * @description Planifie l'exécution quotidienne du batch CancelTripsBatch.
 * Cron : Tous les jours à 2h du matin => 0 0 2 * * ?
 */
public class ScheduleCancelTripsBatch implements Schedulable {

    /**
     * @description Méthode execute qui est appelée par le planificateur de Salesforce.
     * @param sc Contexte de la planification.
     */
    public void execute(SchedulableContext sc) {
        //  instance du batch
        CancelTripsBatch batch = new CancelTripsBatch();
        Database.executeBatch(batch);
    }
}