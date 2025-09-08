/**
 * @description Planifie l'exécution quotidienne du batch UpdateTripStatusBatch.
 */
public class ScheduleUpdateTripStatusBatch implements Schedulable {

    /**
     * @description Méthode execute qui est appelée par le planificateur de Salesforce.
     * @param sc Contexte de la planification.
     */
    public void execute(SchedulableContext sc) {
        // instance du batch
        UpdateTripStatusBatch batch = new UpdateTripStatusBatch();
        Database.executeBatch(batch);
    }
}