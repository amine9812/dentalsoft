# DentalSoft V1.0 — Base de Données MySQL (`dentalSoftDB`)

Application de gestion du cabinet dentaire **YOU SMILE**  
Projet de module **Java Avancée** — EMSI Rabat  
Identifiant Maven (`groupId`) : `ma.dentalSoft`

---

## 1. Architecture des fichiers de persistance

Conformément au dossier de spécification (Chapitre 2, BNF-02, BNF-03, BNF-05 et BNF-08), la couche de données MySQL repose sur l'organisation suivante :

```text
javabd/
├── pom.xml                                    # Dépendances Maven (JDK 17+, MySQL Connector/J, Lombok, JUnit 5)
├── docker-compose.yml                         # Conteneurisation facultative (MySQL 8.0 + Adminer)
├── config/
│   └── application.properties.example         # Modèle de configuration JDBC externe (BNF-02 / BNF-08)
├── sql/
│   ├── schema.sql                             # Script DDL : création de la base dentalSoftDB, des 20 tables, contraintes et index
│   ├── seed.sql                               # Script DML : données initiales et jeu d'essai fictif complet
│   └── verification_queries.sql               # Requêtes SQL de validation des critères CA-01 à CA-36 et RG-01 à RG-12
└── src/
    └── main/
        ├── java/ma/dentalsoft/config/
        │   └── DatasourceFactory.java         # Fabrique de connexion JDBC lisant la configuration externe
        └── resources/
            ├── application.properties         # Configuration par défaut du classpath
            ├── schema.sql                     # Copie ressource du schéma
            └── seed.sql                       # Copie ressource des données initiales
```

---

## 2. Prérequis techniques (BNF-08)

- **JDK** : version 17 ou supérieure
- **Maven** : version 3.8+
- **SGBD** : MySQL Server 8.0 ou version ultérieure (Moteur `InnoDB`, jeu de caractères `utf8mb4`)
- **Pilote JDBC** : `com.mysql:mysql-connector-j:8.4.0`

---

## 3. Initialisation de la base de données MySQL

### Option A — Avec un serveur MySQL local (MySQL Server, XAMPP ou WAMP)

1. Démarrer le service MySQL sur le port `3306`.
2. Exécuter les scripts de création et d'alimentation en ligne de commande :

```powershell
mysql -u root -p --default-character-set=utf8mb4 < sql/schema.sql
mysql -u root -p --default-character-set=utf8mb4 < sql/seed.sql
```

### Option B — Avec Docker Desktop (automatique)

1. Lancer Docker Desktop.
2. À la racine du projet, exécuter :

```powershell
docker compose up -d
```

Le conteneur `dentalsoft-mysql` crée automatiquement la base `dentalSoftDB` et exécute dans l'ordre `sql/schema.sql` puis `sql/seed.sql`.

---

## 4. Ouverture et visualisation de la base de données

### 1. Via MySQL Workbench (Visualisation et Diagramme EER)
1. Ouvrir **MySQL Workbench** et créer une connexion vers `127.0.0.1:3306` (utilisateur `root` ou `dentalsoft_user`).
2. Dans l'onglet **Schemas**, déplier `dentalSoftDB` pour inspecter les 20 tables.
3. Pour générer et visualiser le schéma relationnel complet :
   - Menu **Database** > **Reverse Engineer...**
   - Sélectionner la connexion locale puis la base `dentalSoftDB`.
   - Cocher **Place imported objects on a diagram** puis valider : le diagramme entité-association des 20 tables et leurs clés étrangères s'affiche.

### 2. Via DBeaver ou l'outil Database d'IntelliJ IDEA
1. Créer une nouvelle source de données **MySQL**.
2. Renseigner :
   - **Host** : `localhost`
   - **Port** : `3306`
   - **Database** : `dentalSoftDB`
3. Cliquer sur **Test Connection** puis **Finish**. Double-cliquer sur la base `dentalSoftDB` et ouvrir l'onglet **ER Diagram** pour visualiser les relations entre les tables.

### 3. Via l'interface Web Adminer (si Docker est utilisé)
- Ouvrir `http://localhost:8080` dans le navigateur :
  - **Système** : `MySQL`
  - **Serveur** : `mysql`
  - **Utilisateur** : `dentalsoft_user`
  - **Base de données** : `dentalSoftDB`

---

## 5. Configuration JDBC dans l'application Java

1. Copier le fichier exemple vers un fichier local de configuration :

```powershell
Copy-Item config/application.properties.example config/application.properties
```

2. Adapter `db.username` et `db.password` dans `config/application.properties` selon votre environnement local.
3. Dans les classes DAO (`ma.dentalsoft.repository`), récupérer une connexion via `DatasourceFactory` :

```java
DatasourceFactory datasourceFactory = new DatasourceFactory();
try (Connection connection = datasourceFactory.getConnection()) {
    // Exécution des PreparedStatement et mapping explicite des ResultSet
}
```

Pour les opérations composées (ex. `RG-01` : création atomique d'un patient et de son dossier médical), désactiver l'auto-commit (`connection.setAutoCommit(false)`), exécuter les deux `PreparedStatement`, puis appeler `connection.commit()` ou `connection.rollback()` en cas d'exception (`BNF-03`).

---

## 6. Synthèse des 20 tables du modèle relationnel

| Domaine | Table | Clé primaire | Contraintes majeures |
| :--- | :--- | :--- | :--- |
| **Administration** | `cabinet` | `id` | `CHECK (id = 1)` — ligne unique de configuration |
| **Administration** | `utilisateur` | `id` (Auto) | `UNIQUE (login)` ; empreinte PBKDF2 |
| **Administration** | `role` | `code` | `ADMIN`, `MEDECIN`, `SECRETAIRE` |
| **Administration** | `utilisateur_role` | `(utilisateur_id, role_code)` | Clés étrangères vers `utilisateur` et `role` |
| **Accueil & Agenda** | `patient` | `id` (Auto) | `UNIQUE (cin)`, `UNIQUE (passeport)`, archivage logique (`archive`) |
| **Accueil & Agenda** | `dossier_medical` | `id` (Auto) | `UNIQUE (patient_id)` (`RG-01`), FK `medecin_id` |
| **Accueil & Agenda** | `rdv` | `id` (Auto) | `CHECK (fin > debut)` (`RG-05`), `arrivee_at` pour la file d'attente |
| **Accueil & Agenda** | `indisponibilite` | `id` (Auto) | `CHECK (fin > debut)` (`BF-16`) |
| **Clinique** | `antecedent` | `id` (Auto) | Catalogue des antécédents médicaux |
| **Clinique** | `dossier_antecedent` | `(dossier_id, antecedent_id)` | Niveau de risque et commentaire propre au dossier (`CA-13`) |
| **Clinique** | `acte` | `id` (Auto) | `DECIMAL(12,2)`, `CHECK (prix_base >= 0)` |
| **Clinique** | `consultation` | `id` (Auto) | `UNIQUE (rdv_id)` (`RG-06`), statut `BROUILLON` ou `VALIDEE` |
| **Clinique** | `intervention` | `id` (Auto) | Snapshot du libellé et du tarif appliqué, `CHECK (quantite > 0)` |
| **Clinique** | `medicament` | `id` (Auto) | Référentiel des médicaments actifs/inactifs |
| **Clinique** | `ordonnance` | `id` (Auto) | Statut `BROUILLON` ou `EMISE` |
| **Clinique** | `prescription` | `id` (Auto) | Snapshot du médicament, `CHECK (quantite > 0)`, `CHECK (duree_jours > 0)` |
| **Clinique** | `certificat` | `id` (Auto) | `CHECK (date_fin >= date_debut)` (`RG-11`) |
| **Caisse & Pilotage** | `facture` | `id` (Auto) | `UNIQUE (numero)`, `UNIQUE (consultation_id)` (`RG-09`) |
| **Caisse & Pilotage** | `paiement` | `id` (Auto) | `UNIQUE (reference)` (`RG-10`), `CHECK (montant > 0)` |
| **Caisse & Pilotage** | `charge` | `id` (Auto) | `CHECK (montant > 0)` (`RG-12`) |

---

## 7. Scénario de vérification des données initiales

Exécuter le script `sql/verification_queries.sql` pour contrôler les cas de référence du cahier des charges :

```powershell
mysql -u root -p --default-character-set=utf8mb4 < sql/verification_queries.sql
```

Résultats attendus sur le jeu d'essai fourni :
- **CA-11 / RG-01** : les 8 patients enregistrés possèdent chacun un unique `dossier_medical`.
- **CA-19** : la file d'attente du `2026-11-10` retourne uniquement les patients au statut `ARRIVE` (`Sara El Alami`, `Tanae El Ghali`, `Aymane El Fassi`) triés par `arrivee_at` ; le patient `Amine El Alaoui` passé à `EN_COURS` n'y figure plus.
- **CA-28 / CA-30** : la facture `FAC-2026-0001` d'un total de `850.00 MAD` (interventions de `400.00 MAD` + `450.00 MAD`) cumule `850.00 MAD` de paiements (`300.00 MAD` + `550.00 MAD`), soit un reste à payer de `0.00 MAD`.
- **CA-31** : la facture `FAC-2026-0002` d'un total de `850.00 MAD` avec un paiement de `300.00 MAD` affiche un reste à payer de `550.00 MAD`.
- **CA-32 / RG-12** : les recettes de la période (`1800.00 MAD` encaissés) diminuées des charges (`1000.00 MAD`, dont la charge de `200.00 MAD`) donnent un solde de trésorerie de `800.00 MAD`.

#   d e n t a l s o f t  
 