-- =============================================================================
-- Projet      : DentalSoft V1.0 - Cabinet Dentaire YOU SMILE
-- Script      : verification_queries.sql
-- Description : Requetes SQL de verification des regles metier (RG-01 a RG-12)
--               et des criteres d'acceptation (CA-01 a CA-36).
-- =============================================================================

USE dentalSoftDB;

-- -----------------------------------------------------------------------------
-- 1. Verification RG-01 / CA-11 : Chaque patient possede exactement un dossier
-- -----------------------------------------------------------------------------
SELECT
    p.id            AS patient_id,
    p.nom,
    p.prenom,
    p.cin,
    p.archive,
    dm.id           AS dossier_id,
    dm.date_creation,
    CONCAT(u.prenom, ' ', u.nom) AS medecin_referent
FROM patient p
INNER JOIN dossier_medical dm ON dm.patient_id = p.id
INNER JOIN utilisateur u      ON u.id = dm.medecin_id
ORDER BY p.id;

-- -----------------------------------------------------------------------------
-- 2. Verification Page 7 / CA-09 / CA-12 : Projection Secretaire vs Medecin
--    La requete destinee a la secretaire n'expose jamais la colonne observation.
-- -----------------------------------------------------------------------------
SELECT
    p.id,
    p.nom,
    p.prenom,
    p.date_naissance,
    TIMESTAMPDIFF(YEAR, p.date_naissance, CURDATE()) AS age,
    p.sexe,
    p.telephone,
    p.email,
    p.adresse,
    p.assurance,
    p.archive
FROM patient p
WHERE p.archive = FALSE
ORDER BY p.nom, p.prenom;

-- -----------------------------------------------------------------------------
-- 3. Verification CA-19 : File d'attente journaliere (statut = 'ARRIVE' triee
--    par heure d'arrivee arrivee_at croissante ; les patients EN_COURS sont retires)
-- -----------------------------------------------------------------------------
SELECT
    ROW_NUMBER() OVER (ORDER BY r.arrivee_at ASC) AS rang_file_attente,
    r.id            AS rdv_id,
    CONCAT(p.prenom, ' ', p.nom) AS patient,
    r.debut,
    r.arrivee_at,
    r.statut,
    r.motif
FROM rdv r
INNER JOIN dossier_medical dm ON dm.id = r.dossier_id
INNER JOIN patient p          ON p.id = dm.patient_id
WHERE DATE(r.debut) = '2026-11-10'
  AND r.statut = 'ARRIVE'
ORDER BY r.arrivee_at ASC;

-- -----------------------------------------------------------------------------
-- 4. Verification CA-28, CA-30, CA-31 : Calcul des factures, total paye et
--    reste a payer par facture et par patient
-- -----------------------------------------------------------------------------
SELECT
    f.id                                                AS facture_id,
    f.numero,
    CONCAT(p.prenom, ' ', p.nom)                        AS patient,
    f.date_facture,
    f.statut                                            AS statut_facture,
    f.total                                             AS total_facture,
    COALESCE(SUM(pa.montant), 0.00)                     AS total_paye,
    (f.total - COALESCE(SUM(pa.montant), 0.00))         AS reste_a_payer
FROM facture f
INNER JOIN consultation c     ON c.id = f.consultation_id
INNER JOIN dossier_medical dm ON dm.id = c.dossier_id
INNER JOIN patient p          ON p.id = dm.patient_id
LEFT JOIN paiement pa         ON pa.facture_id = f.id
GROUP BY f.id, f.numero, p.prenom, p.nom, f.date_facture, f.statut, f.total
ORDER BY f.id;

-- -----------------------------------------------------------------------------
-- 5. Verification CA-32, CA-34, RG-12 : Pilotage financier et solde de tresorerie
--    Recettes = somme des paiements encaisses sur la periode
--    Charges  = somme des depenses du cabinet sur la periode
--    Solde    = Recettes - Charges
-- -----------------------------------------------------------------------------
SELECT
    recettes.total_recettes,
    charges_cab.total_charges,
    (recettes.total_recettes - charges_cab.total_charges) AS solde_tresorerie
FROM
    (SELECT COALESCE(SUM(montant), 0.00) AS total_recettes
     FROM paiement
     WHERE date_paiement BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59') AS recettes,
    (SELECT COALESCE(SUM(montant), 0.00) AS total_charges
     FROM charge
     WHERE date_charge BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59') AS charges_cab;

-- -----------------------------------------------------------------------------
-- 6. Verification E-04 (Page 29) : Compteurs demographiques des patients
--    Distinction explicite entre Homme, Femme et Enfant (< 15 ans)
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_patients,
    SUM(CASE WHEN sexe = 'H' THEN 1 ELSE 0 END) AS nbr_patients_homme,
    SUM(CASE WHEN sexe = 'F' THEN 1 ELSE 0 END) AS nbr_patients_femme,
    SUM(CASE WHEN TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) < 15 THEN 1 ELSE 0 END) AS nbr_patients_enfant
FROM patient
WHERE archive = FALSE;

