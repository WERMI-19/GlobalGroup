/**
 * @description Planifie l'exécution quotidienne du batch CancelTripsBatch.
 */
public class ScheduleCancelTripsBatch implements Schedulable {

    /**
     * @description Méthode execute qui est appelée par le planificateur de Salesforce.
     * @param sc Contexte de la planification.
     */
    public void execute(SchedulableContext sc) {
        // On crée une instance de notre batch
        CancelTripsBatch batch = new CancelTripsBatch();

        // On exécute le batch
        Database.executeBatch(batch);
    }
}