
-----

# Projet GlobalGroup Travel - Documentation Système

> **Auteur** : WERMI ADAMA  
> **Date** : Septembre 2025  
> **Contact** : adamalivres19@gmail.com
>**Organisme** : Openclassrooms.com

## 1\. Présentation du Projet

Ce projet a pour but de développer une solution CRM personnalisée sur la plateforme Salesforce pour l'entreprise **GlobalGroup Travel**. L'objectif est d'optimiser les processus de vente et le suivi client en automatisant la gestion des voyages (`Trips`) et en sécurisant l'accès aux données.

-----

## 2\. Modèle de Données (ERD) ==> voir GGT.PNG

Le modèle de données est au cœur de l'application. Il définit les objets et leurs relations.

  * **Account (Compte)** : Représente les entreprises clientes.
  * **Opportunity (Opportunité)** : Suit une vente potentielle. Une opportunité gagnée déclenche la création d'un voyage.
  * **Trip\_\_c (Voyages)** : Objet personnalisé central qui contient tous les détails d'un voyage organisé.
  * **User, Contract, Task(historiques)** : Objets standards utilisés pour la gestion des commerciaux et des interactions.

-----

## 3\. Architecture du Code Apex

Le backend de l'application est structuré en plusieurs types de composants pour respecter les bonnes pratiques de développement Salesforce.

  * **Triggers** : `OpportunityTrigger`, `TripTrigger`
  * **Classes de Logique (Handlers)** : `OpportunityTriggerHandler`, `TripTriggerHandler`
  * **Classes Batch (Batchable)** : `CancelTripsBatch`, `UpdateTripStatusBatch`
  * **Classes Planifiées (Schedulable)** : `ScheduleCancelTripsBatch`, `ScheduleUpdateTripStatusBatch`
  * **Classes de Tests** : Chaque classe ci-dessus est accompagnée de sa propre classe de test .

-----

## 4\. Fonctionnalités Essentielles

Le système intègre quatre logiques métier automatisées.

  * **GGT-02 : Création Automatique des Voyages** : Un trigger (`OpportunityTrigger`) crée un `Trip__c` lorsqu'une opportunité est gagnée.
  * **GGT-03 : Cohérence des Dates** : Des triggers (`OpportunityTrigger`, `TripTrigger`) valident que la date de fin est toujours postérieure à la date de début.
  * **GGT-04 : Annulation Automatique (J-7)** : Un batch (`CancelTripsBatch`) annule chaque nuit les voyages peu fréquentés qui commencent dans 7 jours.
  * **GGT-05 : Mise à Jour Quotidienne des Statuts** : Un batch (`UpdateTripStatusBatch`) met à jour chaque nuit le statut des voyages (`A venir`, `En cours`, `Terminé`).

-----

## 5\. Modèle de Sécurité

Un modèle de sécurité a été configuré pour contrôler l'accès aux données.

  * **Profil "Commercial"** : Gère les permissions au niveau des objets et des champs (Créer, Lire, Modifier mais pas Supprimer).
  * **OWD "Privé"** : Restreint la visibilité des enregistrements à leur propriétaire par défaut.
  * **Hiérarchie des Rôles** : Permet aux managers de voir et modifier les enregistrements de leur équipe.

-----

## 6\. Outils Avancés

### Salesforce Shield

Salesforce Shield est une suite de sécurité avancée pour chiffrer les données (Platform Encryption), surveiller en détail les actions des utilisateurs (Event Monitoring), et conserver un historique de modifications sur une longue durée (Field Audit Trail) pour les entreprises avec de fortes exigences de conformité.

-----

## 7\. Exemples de Requêtes et Commandes

### Requêtes SOQL

**Lister les Voyages avec le Nom du Compte Associé**

```soql
SELECT Name, Destination__c, Account__r.Name 
FROM Trip__c 
WHERE Account__r.Name != null
```

**Compter le Nombre de Voyages par Statut**

```soql
SELECT Status__c, COUNT(Id) 
FROM Trip__c 
GROUP BY Status__c
```

**Voir le Statut des Derniers Jobs par Lot (Batch Apex)**

```soql
SELECT Id, Status, ApexClass.Name, NumberOfErrors
FROM AsyncApexJob
WHERE JobType = 'BatchApex'
ORDER BY CreatedDate DESC
LIMIT 10
```

**Lister Tous les Jobs Planifiés Actuellement**

```soql
SELECT Id, NextFireTime, State, CronJobDetail.Name
FROM CronTrigger
```

### Exécution Manuelle de Batches (Execute Anonymous)

**Lancer le batch d'annulation des voyages**

```apex
Database.executeBatch(new CancelTripsBatch());
```

**Lancer le batch de mise à jour des statuts**

```apex
Database.executeBatch(new UpdateTripStatusBatch());
```

-----

### 1\. Créer un Nouvel Enregistrement (`insert`)

  * **Objectif** : Créer un nouvel enregistrement de Voyage (`Trip__c`) manuellement en utilisant Apex. C'est utile pour les tests ou pour des créations de données par script.

  * **Exemple de Code** :

    ```apex dml
    // On prépare le nouvel enregistrement en mémoire
    Trip__c nouveauVoyage = new Trip__c(
        Destination__c = 'Sydney',
        Start_Date__c = Date.newInstance(2026, 9, 10),
        End_Date__c = Date.newInstance(2026, 9, 20),
        Number_of_Participants__c = 35,
        Status__c = 'A venir'
    );

    // On utilise 'insert' pour sauvegarder l'enregistrement dans la base de données
    insert nouveauVoyage;
    ```

-----

### 2\. Mettre à Jour des Enregistrements en Masse (`update`)

  * **Objectif** : Augmenter le nombre de participants pour tous les voyages prévus à Tokyo. C'est un exemple de mise à jour en masse (bulk update).

  * **Exemple de Code** :

    ```apex dml
    // Étape 1: On récupère la liste des enregistrements à modifier avec une requête SOQL
    List<Trip__c> voyagesAModifier = [
        SELECT Id, Number_of_Participants__c 
        FROM Trip__c 
        WHERE Destination__c = 'Tokyo' AND Status__c = 'A venir'
    ];

    // Étape 2: On modifie les valeurs en mémoire
    for (Trip__c trip : voyagesAModifier) {
        trip.Number_of_Participants__c += 5; // Ajoute 5 nouveaux participants
    }

    // Étape 3: On utilise 'update' pour sauvegarder toutes les modifications en une seule fois
    update voyagesAModifier;
    ```