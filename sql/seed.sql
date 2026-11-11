-- =============================================================================
-- Projet      : DentalSoft V1.0 - Cabinet Dentaire YOU SMILE
-- Script      : seed.sql
-- SGBD        : MySQL 8.0+
-- Description : Jeu de donnees fictives d'initialisation et de demonstration
--               couvrant les exigences BF-01 a BF-36 et les regles RG-01 a RG-13.
-- =============================================================================

USE dentalSoftDB;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE charge;
TRUNCATE TABLE paiement;
TRUNCATE TABLE facture;
TRUNCATE TABLE certificat;
TRUNCATE TABLE prescription;
TRUNCATE TABLE ordonnance;
TRUNCATE TABLE medicament;
TRUNCATE TABLE intervention;
TRUNCATE TABLE consultation;
TRUNCATE TABLE indisponibilite;
TRUNCATE TABLE rdv;
TRUNCATE TABLE acte;
TRUNCATE TABLE dossier_antecedent;
TRUNCATE TABLE antecedent;
TRUNCATE TABLE dossier_medical;
TRUNCATE TABLE patient;
TRUNCATE TABLE utilisateur_role;
TRUNCATE TABLE role;
TRUNCATE TABLE utilisateur;
TRUNCATE TABLE cabinet;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- 1. Configuration du cabinet unique (BF-07)
-- -----------------------------------------------------------------------------
INSERT INTO cabinet (id, nom, adresse, telephone, email, logo_path) VALUES
(1, 'Cabinet Dentaire YOU SMILE', 'Avenue Mohammed VI, Villa Souissi, Rabat', '+212537654321', 'contact@yousmile-dentalsoft.ma', '/assets/logo_yousmile.png');

-- -----------------------------------------------------------------------------
-- 2. Referentiel des roles (BF-06)
-- -----------------------------------------------------------------------------
INSERT INTO role (code, libelle) VALUES
('ADMIN',      'Administrateur'),
('MEDECIN',    'Medecin Dentiste'),
('SECRETAIRE', 'Secretaire Medicale');

-- -----------------------------------------------------------------------------
-- 3. Comptes utilisateurs avec empreintes hachees PBKDF2 (BF-01, BF-04, BF-05, BNF-02)
-- -----------------------------------------------------------------------------
INSERT INTO utilisateur (id, login, password_hash, nom, prenom, email, telephone, adresse, specialite, actif, created_at) VALUES
(1, 'admin',        'PBKDF2WithHmacSHA256:65536:a1b2c3d4e5f60718293a4b5c6d7e8f90:a0cf66b3cded65f4510c8d13aa7e7e491fbb3f9a263097350808adc7a371e3cb', 'El Idrissi', 'Youssef', 'admin@dentalsoft.ma',        '+212661102030', 'Quartier Hassan, Rabat',                     NULL,                               '1', '2026-10-26 08:30:00'),
(2, 'dr.alami',     'PBKDF2WithHmacSHA256:65536:11223344556677889900aabbccddeeff:4f3248485c2e97ba9003cc2fb508c4c32b24c6e33aaf02f5ed4ceb837c1bbf92', 'El Alami',   'Karim',   'k.alami@dentalsoft.ma',      '+212661223333', 'Avenue Mohammed VI, Villa Souissi, Rabat',   'Chirurgien Dentiste',              '1', '2026-10-26 08:35:00'),
(3, 'dr.bennani',   'PBKDF2WithHmacSHA256:65536:ffeeddccbbaa00998877665544332211:afeed4d785966607ddd09d6fd09cc4fa5519bfc1ffaba00f3ed702b6d2e680ff', 'Bennani',    'Salma',   's.bennani@dentalsoft.ma',    '+212662445566', 'Rue Oukaimeden, Agdal, Rabat',               'Orthodontie et Chirurgie Dentaire','1', '2026-10-26 08:40:00'),
(4, 'sec.mansouri', 'PBKDF2WithHmacSHA256:65536:0123456789abcdef0123456789abcdef:c429ed8d6a8d8f1d1306045f9f5c204fecff8016d40d21604cefdb15159870ae', 'Mansouri',   'Nadia',   'n.mansouri@dentalsoft.ma',   '+212663778899', 'Avenue Fal Ould Oumeir, Agdal, Rabat',       NULL,                               '1', '2026-10-26 08:45:00'),
(5, 'sec.archive',  'PBKDF2WithHmacSHA256:65536:fedcba9876543210fedcba9876543210:4c7d8237131a38d91f851f952efac74abdb08de29f1bfda5fe0f6e889a066fbb', 'Tazi',       'Mouna',   'm.tazi@dentalsoft.ma',       '+212664001122', 'Hay Riad, Rabat',                            NULL,                               '0', '2026-10-26 08:50:00');

-- -----------------------------------------------------------------------------
-- 4. Attribution des roles aux utilisateurs (BF-06)
-- -----------------------------------------------------------------------------
INSERT INTO utilisateur_role (utilisateur_id, role_code) VALUES
(1, 'ADMIN'),
(2, 'MEDECIN'),
(3, 'MEDECIN'),
(4, 'SECRETAIRE'),
(5, 'SECRETAIRE');

-- -----------------------------------------------------------------------------
-- 5. Fiches administratives des patients (BF-08 a BF-10, RG-04)
-- -----------------------------------------------------------------------------
INSERT INTO patient (id, nom, prenom, date_naissance, sexe, cin, passeport, email, telephone, adresse, assurance, archive, created_at) VALUES
(1, 'El Alaoui', 'Amine',    '2002-05-12', 'H', 'AB443322', NULL,       'amine.alaoui@gmail.com',  '+212663445577', 'Rue Daraa 45, Agdal, Rabat',            'CNOPS',  0, '2026-10-27 09:00:00'),
(2, 'El Alami',  'Sara',     '2000-08-21', 'F', 'AA198234', NULL,       'sara.alami@gmail.com',    '+212661889900', 'Rue Babel Imb 5, Hassan, Rabat',        'CNSS',   0, '2026-10-27 09:30:00'),
(3, 'El Ghali',  'Tanae',    '1995-11-04', 'F', 'AE776655', NULL,       'tanae.elghali@gmail.com', '+212664112233', 'Avenue Mohammed VI, Souissi, Rabat',    'AXA',    0, '2026-10-27 10:00:00'),
(4, 'El Fassi',  'Aymane',   '1988-03-17', 'H', 'AD334411', NULL,       'aymane.elfassi@gmail.com','+212665223344', 'Quartier Bettana, Sale',                'CNOPS',  0, '2026-10-28 11:15:00'),
(5, 'Yazami',    'Aniss',    '1992-07-29', 'H', 'AC998877', 'MA882190', 'aniss.yazami@gmail.com',  '+212667334455', 'Avenue Moulay Idriss, Temara',          'SANLAM', 0, '2026-10-28 14:20:00'),
(6, 'Chraibi',   'Yasmine',  '2017-04-10', 'F', NULL,       NULL,       'parent.chraibi@gmail.com','+212668445566', 'Hay Riad Secteur 16, Rabat',            'CNOPS',  0, '2026-10-29 10:00:00'),
(7, 'Jorio',     'Mohammed', '1979-12-02', 'H', 'AA554433', NULL,       'm.jorio@gmail.com',       '+212669556677', 'Avenue Annakhil, Hay Riad, Rabat',      'RMA',    0, '2026-10-30 15:00:00'),
(8, 'Khaled',    'Amal',     '1985-06-19', 'F', 'AB112299', NULL,       'amal.khaled@gmail.com',   '+212660667788', 'Quartier L''Ocean, Rabat',              'CNSS',   1, '2026-10-26 16:00:00');

-- -----------------------------------------------------------------------------
-- 6. Dossiers medicaux uniques (BF-11, BF-12, RG-01)
-- -----------------------------------------------------------------------------
INSERT INTO dossier_medical (id, patient_id, date_creation, medecin_id) VALUES
(1, 1, '2026-10-27 09:00:00', 2),
(2, 2, '2026-10-27 09:30:00', 2),
(3, 3, '2026-10-27 10:00:00', 2),
(4, 4, '2026-10-28 11:15:00', 2),
(5, 5, '2026-10-28 14:20:00', 3),
(6, 6, '2026-10-29 10:00:00', 3),
(7, 7, '2026-10-30 15:00:00', 2),
(8, 8, '2026-10-26 16:00:00', 2);

-- -----------------------------------------------------------------------------
-- 7. Catalogue des antecedents medicaux (BF-13)
-- -----------------------------------------------------------------------------
INSERT INTO antecedent (id, libelle, categorie, actif) VALUES
(1, 'Allergie a la penicilline',       'ALLERGIE',             1),
(2, 'Allergie au latex',               'ALLERGIE',             1),
(3, 'Diabete de type 2',               'MALADIE_CHRONIQUE',    1),
(4, 'Hypertension arterielle',         'CARDIOVASCULAIRE',     1),
(5, 'Asthme bronchique',               'RESPIRATOIRE',         1),
(6, 'Traitement anticoagulant oral',   'TRAITEMENT_EN_COURS',  1),
(7, 'Risque d''endocardite infectieuse','CARDIOVASCULAIRE',     1);

-- -----------------------------------------------------------------------------
-- 8. Association dossiers - antecedents (BF-13, CA-13)
-- Le meme antecedent (id=1 et id=3) est associe a plusieurs dossiers avec
-- des commentaires cliniques distincts propres a chaque patient.
-- -----------------------------------------------------------------------------
INSERT INTO dossier_antecedent (dossier_id, antecedent_id, niveau_risque, commentaire, actif) VALUES
(1, 1, 'ELEVE',    'Reaction cutanee documentee en 2023. Prescrire des macrolides en cas d''antibiotherapie.', 1),
(2, 1, 'CRITIQUE', 'Oedeme de Quincke signale par la patiente. Proscrire toute beta-lactamine.',               1),
(3, 3, 'MOYEN',    'Diabete equilibre sous metformine (HbA1c a 6.7%).Privilegier les seances matinales.',      1),
(4, 4, 'MOYEN',    'Tension stabilisee sous inhibiteur calcique. Surveiller avant anesthesie locale.',          1),
(7, 3, 'ELEVE',    'Diabete ancien necessitant une antibioprophylaxie avant tout acte chirurgical invasif.',   1),
(7, 6, 'ELEVE',    'Sous anti-vitamine K. Verifier l''INR (< 3) avant extraction dentaire.',                   1);

-- -----------------------------------------------------------------------------
-- 9. Catalogue des actes dentaires et tarifs de reference (BF-22, CA-22)
-- -----------------------------------------------------------------------------
INSERT INTO acte (id, libelle, categorie, prix_base, actif) VALUES
(1, 'Consultation et bilan bucco-dentaire', 'DIAGNOSTIC',   200.00, 1),
(2, 'Soin de carie',                        'SOINS',        400.00, 1),
(3, 'Detartrage et polissage complet',      'PARODONTIE',   450.00, 1),
(4, 'Traitement canalaire (Endodontie)',    'ENDODONTIE',   650.00, 1),
(5, 'Extraction dentaire simple',           'CHIRURGIE',    350.00, 1),
(6, 'Extraction de dent de sagesse incluse','CHIRURGIE',   1200.00, 1),
(7, 'Blanchiment dentaire au fauteuil',     'ESTHETIQUE',  2500.00, 1),
(8, 'Couronne ceramo-metallique',           'PROTHESE',    2200.00, 1),
(9, 'Scellement des sillons (Enfant)',      'PEDODONTIE',   300.00, 1),
(10,'Ancien acte radiologique hors tarif',  'DIAGNOSTIC',   150.00, 0);

-- -----------------------------------------------------------------------------
-- 10. Referentiel des medicaments (BF-25, CA-25)
-- -----------------------------------------------------------------------------
INSERT INTO medicament (id, nom, forme, actif) VALUES
(1, 'Amoxicilline 1g',                      'Comprime dispersible', 1),
(2, 'Spiramycine 1.5 MUI / Metronidazole',  'Comprime pellicule',   1),
(3, 'Paracetamol 1000mg',                   'Comprime effervescent',1),
(4, 'Ibuprofene 400mg',                     'Comprime enrobe',      1),
(5, 'Chlorhexidine 0.12%',                  'Bain de bouche 250ml', 1),
(6, 'Amoxicilline / Acide clavulanique 1g', 'Sachet-dose',          1),
(7, 'Tetracycline 250mg (Retire)',          'Gelule',               0);

-- -----------------------------------------------------------------------------
-- 11. Indisponibilites dans l'agenda du medecin (BF-16, CA-16)
-- -----------------------------------------------------------------------------
INSERT INTO indisponibilite (id, medecin_id, debut, fin, motif) VALUES
(1, 2, '2026-11-12 14:00:00', '2026-11-12 18:00:00', 'Congres National d''Odontologie - Rabat'),
(2, 3, '2026-11-13 09:00:00', '2026-11-13 12:30:00', 'Formation continue en orthodontie pediatrique');

-- -----------------------------------------------------------------------------
-- 12. Rendez-vous et file d'attente journaliere (BF-15, BF-17 a BF-19, RG-05)
-- -----------------------------------------------------------------------------
INSERT INTO rdv (id, dossier_id, medecin_id, debut, fin, motif, statut, arrivee_at) VALUES
(1, 1, 2, '2026-11-05 09:00:00', '2026-11-05 10:00:00', 'Soin de carie et detartrage',           'TERMINE',  '2026-11-05 08:50:00'),
(2, 2, 2, '2026-11-06 10:00:00', '2026-11-06 11:00:00', 'Douleur molaire et soin conservateur',  'TERMINE',  '2026-11-06 09:52:00'),
(3, 7, 2, '2026-11-07 11:00:00', '2026-11-07 12:00:00', 'Traitement canalaire molaire',          'TERMINE',  '2026-11-07 10:48:00'),
(4, 3, 2, '2026-11-09 09:30:00', '2026-11-09 10:30:00', 'Consultation pre-extraction',           'TERMINE',  '2026-11-09 09:20:00'),
(5, 1, 2, '2026-11-10 10:00:00', '2026-11-10 10:35:00', 'Controle post-soin de carie',           'EN_COURS', '2026-11-10 09:45:00'),
(6, 2, 2, '2026-11-10 10:35:00', '2026-11-10 11:15:00', 'Traitement canalaire',                  'ARRIVE',   '2026-11-10 10:10:00'),
(7, 3, 2, '2026-11-10 11:25:00', '2026-11-10 12:15:00', 'Extraction de dent de sagesse',         'ARRIVE',   '2026-11-10 10:25:00'),
(8, 4, 2, '2026-11-10 14:30:00', '2026-11-10 15:15:00', 'Detartrage annuel',                     'ARRIVE',   '2026-11-10 10:40:00'),
(9, 5, 3, '2026-11-10 15:30:00', '2026-11-10 16:15:00', 'Bilan orthodontique',                   'CONFIRME', NULL),
(10,6, 3, '2026-11-11 09:30:00', '2026-11-11 10:15:00', 'Controle pedodontique et scellement',   'PLANIFIE', NULL),
(11,4, 2, '2026-11-03 16:00:00', '2026-11-03 16:45:00', 'Premiere consultation',                 'ANNULE',   NULL);

-- -----------------------------------------------------------------------------
-- 13. Consultations cliniques (BF-14, BF-20, BF-21, RG-06)
-- -----------------------------------------------------------------------------
INSERT INTO consultation (id, dossier_id, medecin_id, rdv_id, date_consultation, observation, statut) VALUES
(1, 1, 2, 1, '2026-11-05 09:05:00', 'Carie dentinaire profonde sur la 18 traitee sous anesthesie locale sans vasoconstricteur, suivie d''un detartrage complet.', 'VALIDEE'),
(2, 2, 2, 2, '2026-11-06 10:05:00', 'Soin conservateur sur la 24 et detartrage complet. Rappel des consignes d''hygiene bucco-dentaire.',                        'VALIDEE'),
(3, 7, 2, 3, '2026-11-07 11:05:00', 'Pulpite aigue sur la 36. Biopulpectomie et obturation canalaire realisees sous digue.',                                     'VALIDEE'),
(4, 3, 2, 4, '2026-11-09 09:35:00', 'Bilan pre-operatoire avant avulsion de la 48. Verification de l''equilibre glycemique.',                                     'VALIDEE'),
(5, 1, 2, 5, '2026-11-10 10:05:00', 'Controle de la restauration sur la 18 : absence de sensibilite post-operatoire, occlusion normale.',                        'BROUILLON');

-- -----------------------------------------------------------------------------
-- 14. Interventions realisees pendant les consultations (BF-23, BF-24, CA-28, RG-07)
-- Consultation 1 et Consultation 2 illustrent exactement CA-28 :
-- deux interventions de 400.00 MAD et 450.00 MAD => total de 850.00 MAD.
-- -----------------------------------------------------------------------------
INSERT INTO intervention (id, consultation_id, acte_id, libelle_acte_snapshot, dent, quantite, prix_unitaire) VALUES
(1, 1, 2, 'Soin de carie',                        '18', 1, 400.00),
(2, 1, 3, 'Detartrage et polissage complet',      NULL, 1, 450.00),
(3, 2, 2, 'Soin de carie',                        '24', 1, 400.00),
(4, 2, 3, 'Detartrage et polissage complet',      NULL, 1, 450.00),
(5, 3, 4, 'Traitement canalaire (Endodontie)',    '36', 1, 650.00),
(6, 4, 1, 'Consultation et bilan bucco-dentaire', NULL, 1, 200.00),
(7, 5, 1, 'Consultation et bilan bucco-dentaire', NULL, 1, 200.00);

-- -----------------------------------------------------------------------------
-- 15. Ordonnances medicales (BF-26, CA-26, RG-11)
-- -----------------------------------------------------------------------------
INSERT INTO ordonnance (id, consultation_id, date_emission, statut) VALUES
(1, 1, '2026-11-05 09:50:00', 'EMISE'),
(2, 3, '2026-11-07 11:50:00', 'EMISE'),
(3, 5, NULL,                  'BROUILLON');

-- -----------------------------------------------------------------------------
-- 16. Prescriptions associees aux ordonnances (BF-26, CA-26, RG-11)
-- -----------------------------------------------------------------------------
INSERT INTO prescription (id, ordonnance_id, medicament_id, nom_medicament_snapshot, quantite, frequence, duree_jours) VALUES
(1, 1, 2, 'Spiramycine 1.5 MUI / Metronidazole', 2, '1 comprime matin et soir au cours des repas', 6),
(2, 1, 3, 'Paracetamol 1000mg',                  1, '1 comprime toutes les 6 heures si douleur',   4),
(3, 1, 5, 'Chlorhexidine 0.12%',                 1, 'Bain de bouche 3 fois par jour apres brossage',7),
(4, 2, 6, 'Amoxicilline / Acide clavulanique 1g',2, '1 sachet matin et soir',                      7),
(5, 2, 4, 'Ibuprofene 400mg',                    1, '1 comprime 3 fois par jour pendant les repas',3),
(6, 3, 5, 'Chlorhexidine 0.12%',                 1, 'Bain de bouche matin et soir',                5);

-- -----------------------------------------------------------------------------
-- 17. Certificats medicaux (BF-27, CA-27, RG-11)
-- -----------------------------------------------------------------------------
INSERT INTO certificat (id, consultation_id, date_debut, date_fin, motif, date_emission, statut) VALUES
(1, 1, '2026-11-05', '2026-11-06', 'Repos medical suite a une intervention de soins dentaires sous anesthesie locale.', '2026-11-05 09:55:00', 'EMIS'),
(2, 3, '2026-11-07', '2026-11-09', 'Repos medical suite a un traitement endodontique aigu.',                            '2026-11-07 11:55:00', 'EMIS');

-- -----------------------------------------------------------------------------
-- 18. Factures (BF-28, BF-29, CA-28, CA-29, RG-08, RG-09)
-- - Facture 1 (850.00 MAD) : validee et totalement soldee (CA-28, CA-30)
-- - Facture 2 (850.00 MAD) : validee et partiellement payee (CA-31 : reste 550.00 MAD)
-- - Facture 3 (650.00 MAD) : validee et payee
-- - Facture 4 (200.00 MAD) : annulee sans paiement (BF-06 matrice, page 28)
-- -----------------------------------------------------------------------------
INSERT INTO facture (id, consultation_id, numero, date_facture, total, statut, motif_annulation) VALUES
(1, 1, 'FAC-2026-0001', '2026-11-05 10:00:00', 850.00, 'VALIDEE', NULL),
(2, 2, 'FAC-2026-0002', '2026-11-06 11:00:00', 850.00, 'VALIDEE', NULL),
(3, 3, 'FAC-2026-0003', '2026-11-07 12:00:00', 650.00, 'VALIDEE', NULL),
(4, 4, 'FAC-2026-0004', '2026-11-09 10:30:00', 200.00, 'ANNULEE', 'Facture annulee avant encaissement : bilan inclus dans le forfait chirurgical.');

-- -----------------------------------------------------------------------------
-- 19. Paiements (BF-30, BF-31, CA-30, CA-31, RG-10)
-- - Sur Facture 1 (850.00 MAD) : 300.00 MAD puis 550.00 MAD => Soldee (CA-30)
-- - Sur Facture 2 (850.00 MAD) : 300.00 MAD => Reste a payer = 550.00 MAD (CA-31)
-- - Sur Facture 3 (650.00 MAD) : 650.00 MAD => Soldee
-- -----------------------------------------------------------------------------
INSERT INTO paiement (id, facture_id, auteur_id, reference, date_paiement, montant, mode) VALUES
(1, 1, 4, '550e8400-e29b-41d4-a716-446655440001', '2026-11-05 10:05:00', 300.00, 'ESPECES'),
(2, 1, 4, '550e8400-e29b-41d4-a716-446655440002', '2026-11-08 11:30:00', 550.00, 'CARTE'),
(3, 2, 4, '550e8400-e29b-41d4-a716-446655440003', '2026-11-06 11:10:00', 300.00, 'ESPECES'),
(4, 3, 4, '550e8400-e29b-41d4-a716-446655440004', '2026-11-07 12:10:00', 650.00, 'CHEQUE');

-- -----------------------------------------------------------------------------
-- 20. Charges du cabinet (BF-32, CA-32, RG-12)
-- Inclut la charge de 200.00 MAD du critere d'acceptation CA-32.
-- -----------------------------------------------------------------------------
INSERT INTO charge (id, auteur_id, titre, description, montant, date_charge) VALUES
(1, 2, 'Achat consommables dentaires',     'Gants steriles, anesthesiques et composites photopolymerisables', 200.00, '2026-11-05 17:00:00'),
(2, 2, 'Redevance eau et electricite',     'Facture mensuelle REDAL du cabinet YOU SMILE',                    450.00, '2026-11-07 18:00:00'),
(3, 2, 'Maintenance fauteuil dentaire',    'Entretien preventif de l''unite dentaire et du compresseur',      350.00, '2026-11-09 17:30:00');

