-- =============================================================================
-- Projet      : DentalSoft V1.0 - Cabinet Dentaire YOU SMILE
-- Script      : schema.sql
-- SGBD        : MySQL 8.0+ (Moteur InnoDB, encodage utf8mb4)
-- Description : Creation du schema relationnel, des contraintes d'integrite
--               referentielle, des contraintes de domaine (RG) et des index.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS dentalSoftDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE dentalSoftDB;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS charge;
DROP TABLE IF EXISTS paiement;
DROP TABLE IF EXISTS facture;
DROP TABLE IF EXISTS certificat;
DROP TABLE IF EXISTS prescription;
DROP TABLE IF EXISTS ordonnance;
DROP TABLE IF EXISTS medicament;
DROP TABLE IF EXISTS intervention;
DROP TABLE IF EXISTS consultation;
DROP TABLE IF EXISTS indisponibilite;
DROP TABLE IF EXISTS rdv;
DROP TABLE IF EXISTS acte;
DROP TABLE IF EXISTS dossier_antecedent;
DROP TABLE IF EXISTS antecedent;
DROP TABLE IF EXISTS dossier_medical;
DROP TABLE IF EXISTS patient;
DROP TABLE IF EXISTS utilisateur_role;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS cabinet;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- 1. Table : cabinet
-- Role : Configuration du cabinet unique (BF-07)
-- -----------------------------------------------------------------------------
CREATE TABLE cabinet (
    id          BIGINT          NOT NULL,
    nom         VARCHAR(120)    NOT NULL,
    adresse     VARCHAR(255)    NULL,
    telephone   VARCHAR(30)     NULL,
    email       VARCHAR(150)    NULL,
    logo_path   VARCHAR(255)    NULL,
    CONSTRAINT pk_cabinet PRIMARY KEY (id),
    CONSTRAINT chk_cabinet_unique_row CHECK (id = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Table : utilisateur
-- Role : Compte de connexion des acteurs du cabinet (BF-01 a BF-05)
-- -----------------------------------------------------------------------------
CREATE TABLE utilisateur (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    login           VARCHAR(80)     NOT NULL,
    password_hash   VARCHAR(512)    NOT NULL,
    nom             VARCHAR(100)    NOT NULL,
    prenom          VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NULL,
    telephone       VARCHAR(30)     NULL,
    adresse         VARCHAR(255)    NULL,
    specialite      VARCHAR(100)    NULL,
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_utilisateur PRIMARY KEY (id),
    CONSTRAINT uq_utilisateur_login UNIQUE (login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Table : role
-- Role : Referentiel des roles d'acces (BF-06)
-- -----------------------------------------------------------------------------
CREATE TABLE role (
    code    VARCHAR(20)     NOT NULL,
    libelle VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_role PRIMARY KEY (code),
    CONSTRAINT chk_role_code CHECK (code IN ('ADMIN', 'MEDECIN', 'SECRETAIRE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. Table : utilisateur_role
-- Role : Association compte-role (BF-06)
-- -----------------------------------------------------------------------------
CREATE TABLE utilisateur_role (
    utilisateur_id  BIGINT          NOT NULL,
    role_code       VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_utilisateur_role PRIMARY KEY (utilisateur_id, role_code),
    CONSTRAINT fk_ur_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES utilisateur (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_code)
        REFERENCES role (code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. Table : patient
-- Role : Fiche administrative du patient (BF-08 a BF-10, RG-04)
-- -----------------------------------------------------------------------------
CREATE TABLE patient (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    nom             VARCHAR(100)    NOT NULL,
    prenom          VARCHAR(100)    NOT NULL,
    date_naissance  DATE            NOT NULL,
    sexe            VARCHAR(20)     NULL,
    cin             VARCHAR(30)     NULL,
    passeport       VARCHAR(30)     NULL,
    email           VARCHAR(150)    NULL,
    telephone       VARCHAR(30)     NULL,
    adresse         VARCHAR(255)    NULL,
    assurance       VARCHAR(80)     NULL,
    archive         BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_patient PRIMARY KEY (id),
    CONSTRAINT uq_patient_cin UNIQUE (cin),
    CONSTRAINT uq_patient_passeport UNIQUE (passeport),
    CONSTRAINT chk_patient_sexe CHECK (sexe IS NULL OR sexe IN ('HOMME', 'FEMME', 'H', 'F'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. Table : dossier_medical
-- Role : Dossier medical unique associe a chaque patient (BF-11, BF-12, RG-01)
-- -----------------------------------------------------------------------------
CREATE TABLE dossier_medical (
    id              BIGINT      NOT NULL AUTO_INCREMENT,
    patient_id      BIGINT      NOT NULL,
    date_creation   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    medecin_id      BIGINT      NOT NULL,
    CONSTRAINT pk_dossier_medical PRIMARY KEY (id),
    CONSTRAINT uq_dossier_patient UNIQUE (patient_id),
    CONSTRAINT fk_dossier_patient FOREIGN KEY (patient_id)
        REFERENCES patient (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_dossier_medecin FOREIGN KEY (medecin_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. Table : antecedent
-- Role : Catalogue d'antecedents medicaux (BF-13)
-- -----------------------------------------------------------------------------
CREATE TABLE antecedent (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    libelle     VARCHAR(150)    NOT NULL,
    categorie   VARCHAR(60)     NOT NULL,
    actif       BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_antecedent PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. Table : dossier_antecedent
-- Role : Risque et commentaire propres au dossier (BF-13, CA-13)
-- -----------------------------------------------------------------------------
CREATE TABLE dossier_antecedent (
    dossier_id      BIGINT          NOT NULL,
    antecedent_id   BIGINT          NOT NULL,
    niveau_risque   VARCHAR(20)     NULL,
    commentaire     TEXT            NULL,
    actif           BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_dossier_antecedent PRIMARY KEY (dossier_id, antecedent_id),
    CONSTRAINT fk_da_dossier FOREIGN KEY (dossier_id)
        REFERENCES dossier_medical (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_da_antecedent FOREIGN KEY (antecedent_id)
        REFERENCES antecedent (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_da_niveau_risque CHECK (
        niveau_risque IS NULL OR niveau_risque IN ('FAIBLE', 'MOYEN', 'ELEVE', 'CRITIQUE')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. Table : acte
-- Role : Catalogue des actes dentaires et tarifs de reference (BF-22)
-- -----------------------------------------------------------------------------
CREATE TABLE acte (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    libelle     VARCHAR(150)    NOT NULL,
    categorie   VARCHAR(60)     NULL,
    prix_base   DECIMAL(12,2)   NOT NULL,
    actif       BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_acte PRIMARY KEY (id),
    CONSTRAINT chk_acte_prix_base CHECK (prix_base >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. Table : rdv
-- Role : Creneau de rendez-vous et file d'attente (BF-17 a BF-19, RG-05)
-- -----------------------------------------------------------------------------
CREATE TABLE rdv (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    dossier_id  BIGINT          NOT NULL,
    medecin_id  BIGINT          NOT NULL,
    debut       DATETIME        NOT NULL,
    fin         DATETIME        NOT NULL,
    motif       VARCHAR(255)    NULL,
    statut      VARCHAR(20)     NOT NULL,
    arrivee_at  DATETIME        NULL,
    CONSTRAINT pk_rdv PRIMARY KEY (id),
    CONSTRAINT fk_rdv_dossier FOREIGN KEY (dossier_id)
        REFERENCES dossier_medical (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rdv_medecin FOREIGN KEY (medecin_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_rdv_periode CHECK (fin > debut),
    CONSTRAINT chk_rdv_statut CHECK (
        statut IN ('PLANIFIE', 'CONFIRME', 'ARRIVE', 'EN_COURS', 'TERMINE', 'ANNULE', 'ABSENT')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. Table : indisponibilite
-- Role : Plage bloquante dans l'agenda du medecin (BF-16)
-- -----------------------------------------------------------------------------
CREATE TABLE indisponibilite (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    medecin_id  BIGINT          NOT NULL,
    debut       DATETIME        NOT NULL,
    fin         DATETIME        NOT NULL,
    motif       VARCHAR(150)    NULL,
    CONSTRAINT pk_indisponibilite PRIMARY KEY (id),
    CONSTRAINT fk_indispo_medecin FOREIGN KEY (medecin_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_indispo_periode CHECK (fin > debut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 12. Table : consultation
-- Role : Rencontre clinique (BF-14, BF-20, BF-21, RG-06)
-- -----------------------------------------------------------------------------
CREATE TABLE consultation (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    dossier_id          BIGINT          NOT NULL,
    medecin_id          BIGINT          NOT NULL,
    rdv_id              BIGINT          NULL,
    date_consultation   DATETIME        NOT NULL,
    observation         TEXT            NULL,
    statut              VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_consultation PRIMARY KEY (id),
    CONSTRAINT uq_consultation_rdv UNIQUE (rdv_id),
    CONSTRAINT fk_consultation_dossier FOREIGN KEY (dossier_id)
        REFERENCES dossier_medical (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consultation_medecin FOREIGN KEY (medecin_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consultation_rdv FOREIGN KEY (rdv_id)
        REFERENCES rdv (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_consultation_statut CHECK (statut IN ('BROUILLON', 'VALIDEE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 13. Table : intervention
-- Role : Acte effectue pendant une consultation (BF-23, BF-24, RG-07)
-- -----------------------------------------------------------------------------
CREATE TABLE intervention (
    id                      BIGINT          NOT NULL AUTO_INCREMENT,
    consultation_id         BIGINT          NOT NULL,
    acte_id                 BIGINT          NOT NULL,
    libelle_acte_snapshot   VARCHAR(150)    NOT NULL,
    dent                    VARCHAR(10)     NULL,
    quantite                INT             NOT NULL,
    prix_unitaire           DECIMAL(12,2)   NOT NULL,
    CONSTRAINT pk_intervention PRIMARY KEY (id),
    CONSTRAINT fk_intervention_consultation FOREIGN KEY (consultation_id)
        REFERENCES consultation (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_intervention_acte FOREIGN KEY (acte_id)
        REFERENCES acte (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_intervention_quantite CHECK (quantite > 0),
    CONSTRAINT chk_intervention_prix CHECK (prix_unitaire >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 14. Table : medicament
-- Role : Referentiel des medicaments utilisables dans les prescriptions (BF-25)
-- -----------------------------------------------------------------------------
CREATE TABLE medicament (
    id      BIGINT          NOT NULL AUTO_INCREMENT,
    nom     VARCHAR(150)    NOT NULL,
    forme   VARCHAR(80)     NULL,
    actif   BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_medicament PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 15. Table : ordonnance
-- Role : Document clinique de prescription (BF-26, RG-11)
-- -----------------------------------------------------------------------------
CREATE TABLE ordonnance (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    consultation_id BIGINT          NOT NULL,
    date_emission   DATETIME        NULL,
    statut          VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_ordonnance PRIMARY KEY (id),
    CONSTRAINT fk_ordonnance_consultation FOREIGN KEY (consultation_id)
        REFERENCES consultation (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ordonnance_statut CHECK (statut IN ('BROUILLON', 'EMISE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 16. Table : prescription
-- Role : Ligne d'ordonnance (BF-26, RG-11)
-- -----------------------------------------------------------------------------
CREATE TABLE prescription (
    id                          BIGINT          NOT NULL AUTO_INCREMENT,
    ordonnance_id               BIGINT          NOT NULL,
    medicament_id               BIGINT          NOT NULL,
    nom_medicament_snapshot     VARCHAR(150)    NOT NULL,
    quantite                    INT             NOT NULL,
    frequence                   VARCHAR(150)    NOT NULL,
    duree_jours                 INT             NOT NULL,
    CONSTRAINT pk_prescription PRIMARY KEY (id),
    CONSTRAINT fk_prescription_ordonnance FOREIGN KEY (ordonnance_id)
        REFERENCES ordonnance (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_medicament FOREIGN KEY (medicament_id)
        REFERENCES medicament (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_prescription_quantite CHECK (quantite > 0),
    CONSTRAINT chk_prescription_duree CHECK (duree_jours > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 17. Table : certificat
-- Role : Certificat medical lie a une consultation (BF-27, RG-11)
-- -----------------------------------------------------------------------------
CREATE TABLE certificat (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    consultation_id BIGINT          NOT NULL,
    date_debut      DATE            NOT NULL,
    date_fin        DATE            NOT NULL,
    motif           TEXT            NULL,
    date_emission   DATETIME        NULL,
    statut          VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_certificat PRIMARY KEY (id),
    CONSTRAINT fk_certificat_consultation FOREIGN KEY (consultation_id)
        REFERENCES consultation (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_certificat_dates CHECK (date_fin >= date_debut),
    CONSTRAINT chk_certificat_statut CHECK (statut IN ('BROUILLON', 'EMIS'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 18. Table : facture
-- Role : Facture generee a partir d'une consultation validee (BF-28, BF-29, RG-09)
-- -----------------------------------------------------------------------------
CREATE TABLE facture (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    consultation_id     BIGINT          NOT NULL,
    numero              VARCHAR(40)     NOT NULL,
    date_facture        DATETIME        NOT NULL,
    total               DECIMAL(12,2)   NOT NULL,
    statut              VARCHAR(20)     NOT NULL,
    motif_annulation    VARCHAR(255)    NULL,
    CONSTRAINT pk_facture PRIMARY KEY (id),
    CONSTRAINT uq_facture_consultation UNIQUE (consultation_id),
    CONSTRAINT uq_facture_numero UNIQUE (numero),
    CONSTRAINT fk_facture_consultation FOREIGN KEY (consultation_id)
        REFERENCES consultation (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_facture_total CHECK (total >= 0),
    CONSTRAINT chk_facture_statut CHECK (statut IN ('BROUILLON', 'VALIDEE', 'ANNULEE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 19. Table : paiement
-- Role : Historique des encaissements sur facture (BF-30, BF-31, RG-10)
-- -----------------------------------------------------------------------------
CREATE TABLE paiement (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    facture_id      BIGINT          NOT NULL,
    auteur_id       BIGINT          NOT NULL,
    reference       CHAR(36)        NOT NULL,
    date_paiement   DATETIME        NOT NULL,
    montant         DECIMAL(12,2)   NOT NULL,
    mode            VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_paiement PRIMARY KEY (id),
    CONSTRAINT uq_paiement_reference UNIQUE (reference),
    CONSTRAINT fk_paiement_facture FOREIGN KEY (facture_id)
        REFERENCES facture (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_paiement_auteur FOREIGN KEY (auteur_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_paiement_montant CHECK (montant > 0),
    CONSTRAINT chk_paiement_mode CHECK (
        mode IN ('ESPECES', 'CARTE', 'CHEQUE', 'VIREMENT', 'AUTRE')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 20. Table : charge
-- Role : Depense du cabinet (BF-32, RG-12)
-- -----------------------------------------------------------------------------
CREATE TABLE charge (
    id          BIGINT          NOT NULL AUTO_INCREMENT,
    auteur_id   BIGINT          NOT NULL,
    titre       VARCHAR(150)    NOT NULL,
    description VARCHAR(255)    NULL,
    montant     DECIMAL(12,2)   NOT NULL,
    date_charge DATETIME        NOT NULL,
    CONSTRAINT pk_charge PRIMARY KEY (id),
    CONSTRAINT fk_charge_auteur FOREIGN KEY (auteur_id)
        REFERENCES utilisateur (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_charge_montant CHECK (montant > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Index d'optimisation des performances (BNF-05, BF-09, BF-15, BF-19, BF-33, BF-34, BF-36)
-- =============================================================================
CREATE INDEX idx_patient_nom_prenom      ON patient (nom, prenom);
CREATE INDEX idx_patient_telephone       ON patient (telephone);
CREATE INDEX idx_patient_archive         ON patient (archive, created_at);

CREATE INDEX idx_rdv_medecin_periode     ON rdv (medecin_id, debut, fin);
CREATE INDEX idx_rdv_dossier             ON rdv (dossier_id, debut);
CREATE INDEX idx_rdv_file_attente        ON rdv (statut, arrivee_at);

CREATE INDEX idx_indispo_medecin_periode ON indisponibilite (medecin_id, debut, fin);

CREATE INDEX idx_consultation_dossier    ON consultation (dossier_id, date_consultation);
CREATE INDEX idx_consultation_periode    ON consultation (date_consultation, statut);

CREATE INDEX idx_facture_periode_statut  ON facture (date_facture, statut);
CREATE INDEX idx_paiement_periode        ON paiement (date_paiement);
CREATE INDEX idx_charge_periode          ON charge (date_charge);
