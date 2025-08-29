# Projet GlobalGroup Travel - Documentation Système

## 1. Présentation du Projet

Ce projet a pour but de développer une solution CRM personnalisée sur la plateforme Salesforce pour l'entreprise **GlobalGroup Travel**, spécialisée dans les voyages de groupe à l'international. L'objectif est d'optimiser les processus de vente et le suivi client en automatisant la gestion des voyages (`Trips`) liés aux opportunités commerciales.

Le système utilise des objets Salesforce standards et un objet personnalisé (`Trip__c`) pour modéliser le processus métier. Plusieurs automatisations Apex (triggers et batchs) ont été développées pour assurer la cohérence et l'intégrité des données, et un modèle de sécurité a été mis en place pour contrôler l'accès à l'information.

---


## 2. Modèle de Données (ERD)

Le modèle de données est au cœur de l'application. Il définit les objets et leurs relations.

* **Account (Compte)** : Représente les entreprises clientes.
* **Opportunity (Opportunité)** : Suit une vente potentielle. Une opportunité gagnée déclenche la création d'un voyage.
* **Trip__c (Voyage)** : Objet personnalisé central qui contient tous les détails d'un voyage organisé (destination, dates, participants, coût). Il est lié à un `Account` et à une `Opportunity`.
* **User, Contract, Task** : Objets standards utilisés pour la gestion des commerciaux, des contrats et des interactions clients.



---

## 3. Fonctionnalités Essentielles (Automatisations Apex)

Le système intègre quatre logiques métier automatisées pour garantir l'efficacité et la cohérence des données.

### GGT-02 : Création Automatique des Voyages
* **Objectif** : Lorsqu'une opportunité passe au statut "Fermé Gagné" (Closed Won), un nouvel enregistrement `Trip__c` est automatiquement créé.
* **Solution Technique** :
    * **Trigger** : `OpportunityTrigger` (`after update`)
    * **Handler** : `OpportunityTriggerHandler`

### GGT-03 : Cohérence des Dates des Voyages
* **Objectif** : Empêcher la sauvegarde d'un voyage si sa date de fin est antérieure ou égale à sa date de début.
* **Solution Technique** :
    * **Trigger** : `TripTrigger` (`before insert`, `before update`)
    * **Handler** : `TripTriggerHandler` (utilise `.addError()` pour la validation)

### GGT-04 : Annulation Automatique (J-7)
* **Objectif** : Annuler automatiquement les voyages qui commencent dans 7 jours et qui ont moins de 10 participants.
* **Solution Technique** :
    * **Batch Apex** : `CancelTripsBatch`, conçu pour une exécution quotidienne.

### GGT-05 : Mise à Jour Quotidienne des Statuts
* **Objectif** : S'assurer que le statut de chaque voyage (`A venir`, `En cours`, `Terminé`) est toujours correct par rapport à la date du jour.
* **Solution Technique** :
    * **Batch Apex** : `UpdateTripStatusBatch`, conçu pour une exécution quotidienne.

---

## 4. Modèle de Sécurité

Un modèle de sécurité a été configuré pour s'assurer que les utilisateurs n'ont accès qu'aux données pertinentes.

* **Profil "Commercial"** : Un profil personnalisé a été créé pour les commerciaux, leur donnant les droits de créer, lire et modifier les voyages, mais pas de les supprimer.
* **OWD (Paramètres de Partage par Défaut)** : L'accès par défaut pour l'objet `Trip__c` est réglé sur **Privé**. Par défaut, un utilisateur ne peut voir que les enregistrements qu'il possède.
* **Hiérarchie des Rôles** : Une hiérarchie simple (`Directeur des Ventes` > `Commercial`) a été mise en place. Elle permet aux managers de voir et de modifier les enregistrements de voyage des membres de leur équipe, même si l'OWD est privé.

---

## 5. Exemples de Requêtes SOQL et DML

### SOQL (Lire les données)

**1. Trouver tous les voyages "En cours" pour un client spécifique :**
```sql
Account client = [SELECT Id FROM Account WHERE Name = 'Innovatech Solutions' LIMIT 1];
List<Trip__c> voyagesEnCours = [
    SELECT Name, Destination__c, Start_Date__c, End_Date__c
    FROM Trip__c
    WHERE Account__c = :client.Id AND Status__c = 'En cours'
];

**2. Obtenir le montant total des opportunités gagnées ce mois-ci :

SQL

AggregateResult[] results = [
    SELECT SUM(Amount) totalAmount
    FROM Opportunity
    WHERE StageName = 'Closed Won' AND CloseDate = THIS_MONTH
];
Decimal total = (Decimal)results[0].get('totalAmount');
DML (Modifier les données)
1. Créer un nouveau voyage manuellement avec Apex :

Java

Trip__c nouveauVoyage = new Trip__c(
    Destination__c = 'Sydney',
    Start_Date__c = Date.newInstance(2026, 9, 10),
    End_Date__c = Date.newInstance(2026, 9, 20),
    Number_of_Participants__c = 35,
    Status__c = 'A venir'
);
insert nouveauVoyage;
2. Mettre à jour le nombre de participants sur plusieurs voyages :

Java

List<Trip__c> voyagesAModifier = [SELECT Id, Number_of_Participants__c FROM Trip__c WHERE Destination__c = 'Tokyo'];
for (Trip__c trip : voyagesAModifier) {
    trip.Number_of_Participants__c += 5;
}
update voyagesAModifier;
