-- =============================================================================
-- TechBio list: full INPI patent check (2026-11-07)
-- =============================================================================
-- Source: INPI "API PI" (api-gateway.inpi.fr, data.inpi.fr patent base: FR, EP
-- and WO publications), logged in with the project's INPI account.
-- Method: every TechBio company (52) searched by applicant name variants
-- ([DENM=...]); 461 hits; full ST36 notice fetched for each hit.
-- Accepted when the applicant SIREN (INPI "iid") matches the company, or the
-- exact applicant name matches with a French address. Look-alikes rejected:
-- Nebula Inc (US), Opsin Biotherapeutics Inc (US), Endogene Ltd / Endogene Pty
-- (AU), Helix Research Institute (JP) and other "Helix" hits, a 1930
-- "Generare des plans indicateurs" patent.
-- Judgement call: Owkin Inc (US parent of Owkin) counted as Owkin, as file 09
-- already does for 2 families.
-- Dedup: on DOCDB family number (INPI notices carry family-id) against the
-- 156 families already loaded (files 09 and 10).
--
-- 1) 41 new patent families
-- 2) placeholder titles ("title not in open data") replaced with INPI titles
-- 3) co-owner links for the new families
-- Idempotent.
-- =============================================================================
BEGIN;
INSERT INTO organizations (id,name,slug,organization_type,description,status,country,legacy_source,created_at,updated_at) VALUES
(uuid_generate_v4(),'Université Paris-Saclay','universite-paris-saclay','university'::organization_type,'Université Paris-Saclay, research university south of Paris.','active'::organization_status,'France','techbio_inpi_patents_november_2026',NOW(),NOW()),
(uuid_generate_v4(),'Centre d''étude des cellules souches (CECS / I-Stem)','cecs-i-stem','nonprofit'::organization_type,'Centre d''étude des cellules souches, the AFM-Téléthon stem-cell research centre behind the I-Stem institute (Évry).','active'::organization_status,'France','techbio_inpi_patents_november_2026',NOW(),NOW())
ON CONFLICT (slug) DO NOTHING;
WITH src(org,pn,title,abstract,fd,office,url) AS (VALUES
('aqemia','WO2025065398WEP','DÉRIVÉS DE 3-(1H-INDAZOL-3-YL) ISOQUINOLINE UTILISÉS EN TANT QU''INHIBITEURS DE MAP4K1 (HPK1) ET LEUR UTILISATION EN THÉRAPIE','[Patent family record] DOCDB family 91530156; 1 publication(s) in INPI: WO2025252767; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-06-03','WO','family:91530156'),
('cherry-biotech','WO2025072796WEP','PROCÉDÉ DE RÉGULATION DE LA PRESSION ET DE LA CONCENTRATION EN GAZ DISSOUS ET/OU DU PH D''UN VOLUME DE MILIEU DE CULTURE CELLULAIRE LIQUIDE CONTENU DANS AU MOINS UNE CHAMBRE FERMÉE QUI COMPREND UNE ENTITÉ BIOLOGIQUE CULTIVÉE','[Patent family record] DOCDB family 92302557; 2 publication(s) in INPI: WO2026033087, EP4692305; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-08-07','WO','family:92302557'),
('cherry-biotech','WO2026052653WEP','SYSTÈME DE CULTURE CELLULAIRE COMPRENANT UNE PLAQUE DE CULTURE MULTI-PUITS ET UN DISPOSITIF MICROFLUIDIQUE','[Patent family record] DOCDB family 94870687; 2 publication(s) in INPI: WO2026166916, EP4790129; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-02-02','WO','family:94870687'),
('deeplife','WO2025061066WEP','PROCÉDÉ DE TRAITEMENT DE GRAPHE','[Patent family record] DOCDB family 91027149; 1 publication(s) in INPI: WO2025224171; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-04-23','WO','family:91027149'),
('dna-script','WO2025068860WEP','PROCÉDÉ DE SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES','[Patent family record] DOCDB family 91966730; 1 publication(s) in INPI: WO2026008717; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-07-02','WO','family:91966730'),
('dna-script','WO2025068852WEP','DISPOSITIF DE FILTRAGE ET PROCÉDÉ DE SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES','[Patent family record] DOCDB family 91966676; 1 publication(s) in INPI: WO2026008711; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-07-02','WO','family:91966676'),
('dna-script','WO2025070586WEP','SYNTHÈSE ET CLIVAGE D''ACIDE NUCLÉIQUE ENZYMATIQUE ASSISTÉ PAR JET D''ENCRE','[Patent family record] DOCDB family 92503533; 1 publication(s) in INPI: WO2026017834; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-07-18','WO','family:92503533'),
('endogenebio','WO2025060771WEP','Kit pour collecter un échantillon de sang menstruel','[Patent family record] DOCDB family 92926407; 3 publication(s) in INPI: WO2025219589, WO2025219592, FR3161348; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-04-18','WO','family:92926407'),
('endogenebio','WO2026056796WEP','MÉTHODES DE DIAGNOSTIC DE L''ENDOMÉTRIOSE BASÉES SUR DES BIOMARQUEURS ÉPIGÉNÉTIQUES ET MÉTHODES D''IDENTIFICATION DE CES BIOMARQUEURS','[Patent family record] DOCDB family 96060716; 2 publication(s) in INPI: WO2026190192, FR3173023; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2026-03-11','WO','family:96060716'),
('iktos','WO2025000524WIB','COUPLAGE D''UN MODÈLE GÉNÉRATIF 3D À UN MODULE D''OPTIMISATION DE CONFORMATION SOUS CONTRAINTES DANS UNE BOUCLE DE RENFORCEMENT MONDIALE','[Patent family record] DOCDB family 98011602; 1 publication(s) in INPI: WO2026083123; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-10-17','WO','family:98011602'),
('iktos','WO2025088398WEP','INHIBITEURS DE MTHFD2 POLYCYCLIQUES ET LEURS UTILISATIONS','[Patent family record] DOCDB family 94382488; 1 publication(s) in INPI: WO2026132447; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-12-19','WO','family:94382488'),
('inspek','WO2025073028WEP','DISPOSITIF PHOTONIQUE POUR L’ACQUISITION SIMULTANÉE DE DONNÉES SPECTROSCOPIQUES ET PHYSICO-CHIMIQUES D’UN ANALYTE, SYSTÈME ET PROCÉDÉ ASSOCIÉS','[Patent family record] DOCDB family 94383254; 2 publication(s) in INPI: WO2026082323, FR3167714; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-08-11','WO','family:94383254'),
('ksilink','WO2025059739WEP','INHIBITEURS SÉLECTIFS DE HDAC6 DESTINÉS À ÊTRE UTILISÉS DANS LE TRAITEMENT DE LA DYSTROPHIE MYOTONIQUE DE TYPE 1','[Patent family record] DOCDB family 91027189; 1 publication(s) in INPI: WO2025215092; offices: WO. Co-applicants: UNIV SORBONNE; SORBONNE UNIVERSITÉ; CENTRE NAT RECH SCIENT; UNIV DEVRY VAL DESSONNE; INST NAT SANTE RECH MED; UNIVERSITÉ D''EVRY-VAL-D''ESSONNE. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-04-09','WO','family:91027189'),
('netri','WO2026055007WEP','PROCEDE D’EVALUATION DES EFFETS D’UN STIMULUS SUR UNE REPRODUCTION D’UN ORGANE CIBLE ET ORGANE-SUR-PUCE MULTICOMPARTIMENTE PERMETTANT SA MISE EN OEUVRE','[Patent family record] DOCDB family 96230492; 2 publication(s) in INPI: WO2026176125, FR3172510; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2026-02-24','WO','family:96230492'),
('netri','WO2025082308WEP','ORGANE-SUR-PUCE MULTICOMPARTIMENTE POUR REPRODUIRE ET FONCTIONNALISER UN ORGANE DU SYSTEME DIGESTIF','[Patent family record] DOCDB family 94173261; 2 publication(s) in INPI: WO2026099441, FR3168402; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-11-07','WO','family:94173261'),
('netri','WO2025082307WEP','ORGANE-SUR-PUCE MULTICOMPARTIMENTE POUR REPRODUIRE ET FONCTIONNALISER UN MODELE DE PEAU','[Patent family record] DOCDB family 94173623; 2 publication(s) in INPI: WO2026099440, FR3168403; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-11-07','WO','family:94173623'),
('netri','WO2025082306WEP','ORGANE-SUR-PUCE MULTICOMPARTIMENTE POUR REPRODUIRE ET FONCTIONNALISER UNE MUQUEUSE','[Patent family record] DOCDB family 94173133; 2 publication(s) in INPI: WO2026099439, FR3168404; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-11-07','WO','family:94173133'),
('netri','WO2025082305WEP','ORGANE-SUR-PUCE MULTICOMPARTIMENTE POUR REPRODUIRE ET FONCTIONNALISER UN ORGANE CIBLE','[Patent family record] DOCDB family 94173440; 2 publication(s) in INPI: WO2026099438, FR3168405; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-11-07','WO','family:94173440'),
('one-biosciences','WO2026058410WEP','SIGNATURES POUR CANCER UROTHÉLIAL MÉTASTATIQUE','[Patent family record] DOCDB family 95205538; 1 publication(s) in INPI: WO2026202067; offices: WO. Co-applicants: UNIV PARIS SACLAY; ROUSSY INST GUSTAVE; INSTITUT GUSTAVE ROUSSY; UNIVERSITE PARIS-SACLAY. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-03-24','WO','family:95205538'),
('orakl-oncology','WO2025075355WEP','PROCÉDÉ ET DISPOSITIF DE PRÉDICTION DE RÉPONSE DE PATIENT','[Patent family record] DOCDB family 92843187; 1 publication(s) in INPI: WO2026052800; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-09-05','WO','family:92843187'),
('orakl-oncology','WO2026051712WEP','PROCÉDÉ ET DISPOSITIFS DE CRIBLAGE D''IMMUNOCONJUGUÉS','[Patent family record] DOCDB family 95205515; 1 publication(s) in INPI: WO2026201342; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-01-23','WO','family:95205515'),
('owkin','WO2023014623WUS','SYSTÈMES ET PROCÉDÉS DE CONCEPTION D''ÉTUDES CONTRÔLÉES RANDOMISÉES','[Patent family record] DOCDB family 80937195; 2 publication(s) in INPI: WO2023168115, EP4487337; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name (applicant: Owkin Inc, the company's US parent).','2023-03-06','WO','family:80937195'),
('owkin','WO2024051768WUS','PROCÉDÉ DE BRAS DE COMMANDE EXTERNES FÉDÉRÉS POUR INFÉRENCE CAUSALE AMÉLIORÉE PAR LA CONFIDENTIALITÉ SUR DES DONNÉES DISTRIBUÉES','[Patent family record] DOCDB family 88697746; 1 publication(s) in INPI: WO2025085632; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name (applicant: Owkin Inc, the company's US parent).','2024-10-17','WO','family:88697746'),
('owkin','WO2022028140WUS','SYSTÈMES ET PROCÉDÉS D''IDENTIFICATION DE SOUS-TYPES MOLÉCULAIRES D''UN ADÉNOCARCINOME CANALAIRE DU PANCRÉAS','[Patent family record] DOCDB family 81941110; 2 publication(s) in INPI: WO2022236100, EP4334908; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name (applicant: Owkin Inc, the company's US parent).','2022-05-06','WO','family:81941110'),
('owkin','WO2026050367WEP','PROCÉDÉ ET SYSTÈME POUR GÉNÉRER UN ENSEMBLE D''ENTRAÎNEMENT POUR ENTRAÎNER UN MODÈLE ANALYSANT DES IMAGES HISTOLOGIQUES','[Patent family record] DOCDB family 94393471; 2 publication(s) in INPI: WO2026150032, EP4776240; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-01-09','WO','family:94393471'),
('owkin','WO2023081687WUS','SYSTÈMES ET PROCÉDÉS DE DÉTECTION DE STRUCTURES LYMPHOÏDES TERTIAIRES','[Patent family record] DOCDB family 84462434; 2 publication(s) in INPI: WO2024118842, EP4627523; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name (applicant: Owkin Inc, the company's US parent).','2023-11-29','WO','family:84462434'),
('owkin','WO2026055088WEP','PROCÉDÉ ET SYSTÈME DE CLASSIFICATION D''IMAGES HISTOLOGIQUES','[Patent family record] DOCDB family 94824114; 2 publication(s) in INPI: WO2026180490, EP4800579; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-02-25','WO','family:94824114'),
('owkin','WO2021061891WUS','SYSTÈMES ET PROCÉDÉS DE DÉTERMINATION DE RÉGIONS D''INTÉRÊT DANS DES IMAGES D''HISTOLOGIE','[Patent family record] DOCDB family 74141301; 2 publication(s) in INPI: WO2022120230, EP4256533; offices: EP, WO. Source: INPI API PI (data.inpi.fr), verified by applicant name (applicant: Owkin Inc, the company's US parent).','2021-12-03','WO','family:74141301'),
('qubit-pharmaceuticals','WO2025063730WEP','PROCÉDÉ ET SYSTÈME DE CALCUL QUANTIQUE CHIMIQUEMENT PRÉCIS','[Patent family record] DOCDB family 91738155; 1 publication(s) in INPI: WO2025238271; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-05-19','WO','family:91738155'),
('qubit-pharmaceuticals','WO2025079829WEP','NOUVEAUX DÉRIVÉS D''ACYLSULFONAMIDE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 97444472; 1 publication(s) in INPI: WO2026082829; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-10-15','WO','family:97444472'),
('qubit-pharmaceuticals','WO2025082226WEP','DÉRIVÉS DE SULFONYLURÉE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 97636203; 1 publication(s) in INPI: WO2026099404; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-11-06','WO','family:97636203'),
('qubit-pharmaceuticals','WO2025087499WEP','PROCÉDÉ ET SYSTÈME D''ÉCHANTILLONNAGE QUANTIQUE DANS DES CHAÎNES DE MARKOV NON RÉVERSIBLES À L''AIDE DE TECHNIQUES QUANTIQUES','[Patent family record] DOCDB family 94685885; 1 publication(s) in INPI: WO2026131906; offices: WO. Co-applicants: UNIV SORBONNE; SORBONNE UNIVERSITÉ; CENTRE NAT RECH SCIENT; CENTRE NATIONAL DE LA RECHERCHE SCIENTIFIQUE. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-12-16','WO','family:94685885'),
('qubit-pharmaceuticals','WO2026054897WEP','PROCÉDÉS MIS EN ŒUVRE PAR ORDINATEUR, SYSTÈMES ET SUPPORTS LISIBLES PAR ORDINATEUR','[Patent family record] DOCDB family 96014545; 1 publication(s) in INPI: WO2026176104; offices: WO. Co-applicants: UNIV SORBONNE; SORBONNE UNIVERSITÉ; CENTRE NAT RECH SCIENT; CENTRE NATIONAL DE LA RECHERCHE SCIENTIFIQUE. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-02-23','WO','family:96014545'),
('qubit-pharmaceuticals','WO2026057520WEP','NOUVEAUX DÉRIVÉS D''ACYLSULFONAMIDE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 99396967; 1 publication(s) in INPI: WO2026195684; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-03-17','WO','family:99396967'),
('qubit-pharmaceuticals','EP24306869A','DÉRIVÉS DE SULFONYLURÉE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 93562810; 1 publication(s) in INPI: EP4741375; offices: EP. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2024-11-06','EP','family:93562810'),
('qubit-pharmaceuticals','EP24306696A','NOUVEAUX DÉRIVÉS D''ACYLSULFONAMIDE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 93291894; 1 publication(s) in INPI: EP4729515; offices: EP. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2024-10-15','EP','family:93291894'),
('qubit-pharmaceuticals','EP25315083A','NOUVEAUX DÉRIVÉS D''ACYLSULFONAMIDE ET LEUR UTILISATION POUR LE TRAITEMENT DU CANCER','[Patent family record] DOCDB family 95254911; 1 publication(s) in INPI: EP4810485; offices: EP. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-03-17','EP','family:95254911'),
('scienta-lab','WO2026050323WEP','DISPOSITIF DE GÉNÉRATION DE SYSTÈME D''INTELLIGENCE ARTIFICIELLE DE PRÉDICTION D''EFFET DE MÉDICAMENT SUR UN PATIENT, DISPOSITIF DE PRÉDICTION D''EFFET DE MÉDICAMENT SUR UN PATIENT','[Patent family record] DOCDB family 96230351; 1 publication(s) in INPI: WO2026150007; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2026-01-08','WO','family:96230351'),
('spore-biotechnologies','WO2025071548WEP','Dispositif de détection de bactéries dans un échantillon','[Patent family record] DOCDB family 93923584; 2 publication(s) in INPI: WO2026022384, FR3165073; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2025-07-25','WO','family:93923584'),
('spore-biotechnologies','WO2026058445WEP','Dispositif de filtrage d’un échantillon en solution aqueuse et système de détection associé','[Patent family record] DOCDB family 96342905; 2 publication(s) in INPI: WO2026202086, FR3173585; offices: FR, WO. Source: INPI API PI (data.inpi.fr), verified by SIREN.','2026-03-24','WO','family:96342905'),
('whitelab-genomics','WO2025060892WEP','PROCÉDÉ D''IDENTIFICATION DE PROTÉINE DE SURFACE CELLULAIRE','[Patent family record] DOCDB family 91027381; 1 publication(s) in INPI: WO2025224083; offices: WO. Source: INPI API PI (data.inpi.fr), verified by applicant name.','2025-04-22','WO','family:91027381'))
INSERT INTO patents (id,organization_id,patent_number,title,abstract,filing_date,patent_office,url,created_at,updated_at)
SELECT uuid_generate_v4(),o.id,s.pn,s.title,s.abstract,s.fd::date,s.office,NULL,NOW(),NOW() FROM src s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM patents x WHERE x.organization_id=o.id AND x.abstract LIKE '%DOCDB family '||split_part(s.url,':',2)||';%');
WITH t(org,fam,title) AS (VALUES
('ai-biopharma','68296040','MÉDICAMENTS ANTIVIRAUX ET CIBLÉS SUR LE FOIE'),
('aqemia','86226464','NOUVEAUX INHIBITEURS DE METTL3 ET LEUR UTILISATION EN THÉRAPIE'),
('ariana-pharmaceuticals','44992977','COMBINAISON DE BIOMARQUEURS POUR LA DETECTION ET L''EVALUATION D''UNE FIBROSE HEPATIQUE'),
('ariana-pharmaceuticals','44992978','COMBINAISON DE BIOMARQUEURS POUR LE PRONOSTIC D''UNE REPONSE OU NON-REPONSE A UN TRAITEMENT ANTI-VHC'),
('ariana-pharmaceuticals','45524644','COMBINAISON DE BIOMARQUEURS POUR LE PRONOSTIC D''UNE REPONSE OU NON-REPONSE A UN TRAITEMENT ANTI-VHC'),
('cherry-biotech','67262662','Procédé d''enrichissement en gaz et simultanément de déplacement d’un fluide et dispositif pour le contrôle de l''environnement cellulaire sur une plaque de culture cellulaire multipuits correspondant.'),
('cherry-biotech','56464803','DISPOSITIF MICROFLUIDIQUE PERMETTANT DE MODIFIER LA GAMME DE PRESSION D''UN SYSTEME DE REGULATION POUR AUGMENTER LA STABILITE FINALE D''UN FLUX DANS UNE PUCE MICROFLUIDIQUE'),
('cherry-biotech','87377935','PROCÉDÉ DE COMMANDE DE DÉPLACEMENT DE FLUIDE ET DE COMPOSITION ET/OU DE PH DE GAZ DANS UN DISPOSITIF DE CULTURE CELLULAIRE ET SYSTÈME DE CULTURE CELLULAIRE CORRESPONDANT'),
('cherry-biotech','95201513','APPAREIL À ÉLECTRODES INTÉGRÉES POUR SURVEILLANCE ÉLECTRIQUE DE CULTURES CELLULAIRES'),
('cherry-biotech','73039775','PROCÉDÉ ET APPAREIL POUR LA SURVEILLANCE ÉLECTRONIQUE DE CONDITIONS METTANT POTENTIELLEMENT LA VIE EN DANGER'),
('cherry-biotech','65724141','PROCÉDÉS ET APPAREIL POUR FOURNIR UN CONTRÔLE ENVIRONNEMENTAL DANS DES ÉCHANTILLONS BIOLOGIQUES CONTENUS DANS DES RÉCIPIENTS DE CULTURE CELLULAIRE'),
('deeplife','69845291','JUMEAU NUMÉRIQUE GÉNÉRATIF DE SYSTÈMES COMPLEXES'),
('dna-script','76807570','SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES EN UTILISANT DES MONOMÈRES DE 3’-O-AMINO-2’-DÉSOXYRIBONUCLÉOSIDE TRIPHOSPHATE'),
('dna-script','75588160','PROCÉDÉS ET TROUSSES POUR LA SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES POUVANT FORMER DES G4'),
('dna-script','52102784','NUCLEOTIDES MODIFIES POUR LA SYNTHESE D''ACIDES NUCLEIQUES, UN KIT RENFERMANT DE TELS NUCLEOTIDES ET LEUR UTILISATION POUR LA PRODUCTION DE GENES OU SEQUENCES D''ACIDES NUCLEIQUES SYNTHETIQUES'),
('dna-script','56263809','INSTALLATION POUR LA MISE EN ŒUVRE D''UN PROCEDE DE SYNTHESE ENZYMATIQUE D''ACIDES NUCLEIQUES'),
('dna-script','51610191','PROCEDE DE SYNTHESE D''ACIDES NUCLEIQUES, NOTAMMENT D''ACIDES NUCLEIQUES DE GRANDE LONGUEUR, UTILISATION DU PROCEDE ET KIT POUR LA MISE EN ŒUVRE DU PROCEDE'),
('dna-script','57348782','VARIANTS D''UNE ADN POLYMERASE DE LA FAMILLE POLX'),
('dna-script','82319792','SUPPORT D''ACCESSOIRE MODULAIRE'),
('dna-script','82482550','APPAREIL DE SYNTHÈSE ENZYMATIQUE D''UNE PLURALITÉ DE POLYNUCLÉOTIDES COMPRENANT UN PIÈGE À CONDENSATION'),
('dna-script','83438904','PLATEFORME DE SUPPORT D''UNE PLAQUE DE SUBSTRAT POUR UN APPAREIL DE SYNTHÈSE ENZYMATIQUE DE BIOMOLÉCULES'),
('dna-script','83505715','CACHE POUR TETE DE DISPOSITIF D''IMPRESSION POUR LA SYNTHESE DE BIOMOLECULES'),
('dna-script','84331075','COUVERCLE POUR PLAQUE DE SUBSTRAT D''UN APPAREIL DE SYNTHÈSE ENZYMATIQUE'),
('dna-script','85505528','MONTANT D''ALIGNEMENT ET MÉCANISME SÉCURISÉ POUR SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','85175743','PROCÉDÉ DE SYNTHÈSE DE POLYNUCLÉOTIDES À L''AIDE D''UNE IMPRIMANTE MOUVEMENT-ARRÊT'),
('dna-script','65657408','PROCÉDÉ DE PRÉPARATION DE 3''-O-AMINO-RIBONUCLÉOTIDE'),
('dna-script','71741810','AUGMENTATION DES RENDEMENTS DE SÉQUENCE LONGUE DANS LA SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES'),
('dna-script','67902356','SYNTHÈSE DE POLYNUCLÉOTIDES ENZYMATIQUES SANS MATRICE À L''AIDE DE LIAISONS PHOTOCLIVABLES'),
('dna-script','68581348','SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES À EFFICACITÉ ÉLEVÉE'),
('dna-script','68917622','SYNTHÈSE DE POLYNUCLÉOTIDES ENZYMATIQUES SANS MATRICE À L''AIDE DE VARIANTS DE DÉSOXYNUCLÉOTIDYLTRANSFÉRASES TERMINALES SANS DISMUTATION'),
('dna-script','63528670','PROCÉDÉ DE PRÉPARATION DE 3''-O-AMINO-2''-DÉOXYRIBONUCLÉOSIDE-5''-TRIPHOSPHATE'),
('dna-script','76744848','SYNTHÈSE ENZYMATIQUE MASSIVEMENT PARALLÈLE DE POLYNUCLÉOTIDES'),
('dna-script','73554345','SYNTHÈSE ENZYMATIQUE DE SONDES POLYNUCLÉOTIDIQUES'),
('dna-script','88779367','DISPOSITIF ÉLECTROCHIMIQUE POUR SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','79601564','NOUVELLES VARIANTES DE LA DÉSOXYNUCLÉOTIDYL TRANSFÉRASE TERMINALE (TDT)'),
('dna-script','87280956','ADDITION DE SELS PENDANT LA SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','68766789','SYNTHÈSE D''OLIGONUCLÉOTIDES DIRECTE SUR DES CELLULES ET DES BIOMOLÉCULES'),
('dna-script','70802875','VARIANTS DE LA DÉSOXYNUCLÉOTIDYLE TRANSFÉRASE TERMINALE ET LEURS UTILISATIONS'),
('dna-script','79601951','NOUVEAU DÉSOXYNUCLÉOTIDYL TERMINAL'),
('dna-script','70294935','PROCÉDÉ DE PRÉPARATION DE 3''-O-AMINO-2''-DEOXYRIBONUCLEOSIDE-5''-TRIPHOSPHATES'),
('dna-script','89573933','VARIANTS STABILISÉS D''ENDONUCLÉASE V HAUTEMENT ACTIVE POUR LE CLIVAGE D''ADN MARQUÉ'),
('dna-script','77989821','VARIANTS STABILISÉS DE DÉSOXYNUCLÉOTIDYL TRANSFÉRASE TERMINALE TRONQUÉS À L''EXTRÉMITÉ N-TERMINALE ET UTILISATIONS ASSOCIÉES'),
('dna-script','89767162','SYNTHÈSE ENZYMATIQUE DE SONDES POLYNUCLÉOTIDIQUES'),
('dna-script','85076492','ENCRES À VISCOSITÉ VARIABLE POUR L''ADMINISTRATION PAR JET D''ENCRE DE RÉACTIFS ENZYMATIQUES'),
('dna-script','65200741','SYNTHÈSE MONOTOPE D''ENSEMBLES D''OLIGONUCLÉOTIDES'),
('dna-script','59761887','VARIANTS DE L''ADN POLYMÉRASE DE LA FAMILLE A ET LEURS UTILISATIONS'),
('dna-script','68887331','DÉSOXYNUCLÉOTIDYLTRANSFÉRASES TERMINALES CHIMÉRIQUES POUR LA SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES'),
('dna-script','84359035','PROCÉDÉS ET PRODUITS POUR L''ÉLIMINATION DE POLYNUCLÉOTIDES CONTENANT DE L''URACILE'),
('dna-script','91030388','RÉACTIF UTILISÉ DANS LA DÉPROTECTION DE POLYNUCLÉOTIDES 3''-O-AMINO'),
('dna-script','68062833','AUGMENTATION DE RENDEMENTS DE SÉQUENCE LONGUE DANS LA SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES'),
('dna-script','69845811','PROCÉDÉ ET APPAREIL DE SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','84568871','PROCÉDÉ DE PURIFICATION D''UNE SOLUTION COMPRENANT DES POLYNUCLÉOTIDES'),
('dna-script','71741809','SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES À L''AIDE DE POLY(A) ET POLY(U) POLYMÉRASES'),
('dna-script','85283720','SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES SANS CICATRICE'),
('dna-script','73554343','NOUVEAUX VARIANTS D''ENDONUCLÉASE V ET LEURS UTILISATIONS'),
('dna-script','88778293','NOUVEAUX VARIANTS DE DÉSOXYNUCLÉOTIDYL TRANSFÉRASE TERMINALE (TDT) ET LEURS UTILISATIONS'),
('dna-script','77447767','PROCÉDÉ DE GÉNÉRATION D''ACIDE NUCLÉIQUE DOUBLE BRIN'),
('dna-script','85505698','STATION D''AUTOMATISATION POUR LA SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','89073124','NUCLÉOTIDES BLOQUÉS EN 3''-O-AMINOOXYMÉTHYLE ET LEUR UTILISATION DANS LA SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','87429412','SYNTHÈSE D''ACIDE NUCLÉIQUE SUR UN SUPPORT RÉUTILISABLE'),
('dna-script','85685592','MOYEN DE TRAITEMENT THERMIQUE POUR DISPOSITIF D''IMPRESSION D''UN APPAREIL DE SYNTHÈSE ENZYMATIQUE'),
('dna-script','65635610','CLIVAGE EFFICACE DE PRODUIT DANS LA SYNTHÈSE ENZYMATIQUE SANS MATRICE DE POLYNUCLÉOTIDES'),
('dna-script','89076177','VARIANTS DE POLY (A) POLYMÉRASE ET LEURS UTILISATIONS'),
('dna-script','88017973','PROCÉDÉ DE GÉNÉRATION D''UNE PLURALITÉ DE POLYNUCLÉOTIDES'),
('dna-script','70390759','VARIANTS DE DÉSOXYNUCLÉOTIDYL TRANSFÉRASE ET UTILISATIONS CORRESPONDANTES'),
('dna-script','89662175','SYNTHÈSE ENZYMATIQUE D''ACIDES NUCLÉIQUES ASSISTÉE PAR JET D''ENCRE'),
('dna-script','71103283','SYSTÈMES, APPAREIL ET KITS POUR LA SYNTHÈSE ENZYMATIQUE DE POLYNUCLÉOTIDES'),
('dna-script','85199053','PROCÉDÉS D''OBTENTION D''ACIDES NUCLÉIQUES CORRECTEMENT ASSEMBLÉS'),
('dna-script','67436809','SYNTHÈSE ENZYMATIQUE MASSIVEMENT PARALLÈLE DE BRINS D''ACIDES NUCLÉIQUES'),
('dna-script','68536875','VARIANTS DE DÉSOXYNUCLÉOTIDYLTRANSFÉRASE ET UTILISATIONS CORRESPONDANTES'),
('dna-script','84785146','SYNTHÈSE ENZYMATIQUE IN VITRO D''ARN'),
('dna-script','61027613','VARIANTS DE LA DÉSOXYNUCLÉOTIDYLE TRANSFÉRASE TERMINALE ET LEURS UTILISATIONS'),
('dna-script','89573453','NOUVEAUX VARIANTS D''ENDONUCLÉASE V POUR LE CLIVAGE D''ADN MARQUÉ'),
('dna-script','66668842','VARIANTS DE DÉSOXYNUCLÉOTIDYLE TRANSFÉRASE TERMINALE ET LEURS UTILISATIONS'),
('eligo-bioscience','71101098','PROTÉINES CHIMÈRES DE LIAISON AU RÉCEPTEUR DESTINÉES À ÊTRE UTILISÉES DANS DES VECTEURS POUR DÉLIVRER DES BACTÉRIES'),
('eligo-bioscience','84332370','PROCÉDÉS IMPLIQUANT UN REMPLACEMENT DE SOUCHE BACTÉRIENNE'),
('eligo-bioscience','84331744','MÉTHODES IMPLIQUANT LE REMPLACEMENT D''UNE SOUCHE BACTEROIDES'),
('eligo-bioscience','82021095','CELLULES BACTÉRIENNES DE PRODUCTION ET LEUR UTILISATION DANS DES PROCÉDÉS DE PRODUCTION'),
('eligo-bioscience','75441923','MODULATION DE LA FONCTION DU MICROBIOTE PAR THÉRAPIE GÉNIQUE DU MICROBIOME POUR PRÉVENIR, TRAITER OU SOIGNER DES MALADIES OU DES TROUBLES ASSOCIÉS AU MICROBIOME'),
('eligo-bioscience','58428223','VECTEUR OPTIMISÉ POUR UNE ADMINISTRATION À DES POPULATIONS MICROBIENNES'),
('eligo-bioscience','81344298','UTILISATION COSMÉTIQUE DE POSTBIOTIQUES MODIFIÉS COMPRENANT DES BACTÉRIOCINES ET/OU DES ENDOLYSINES'),
('eligo-bioscience','76305847','DÉCOLONISATION SPÉCIFIQUE DE BACTÉRIES RÉSISTANTES AUX ANTIBIOTIQUES À DES FINS PROPHYLACTIQUES'),
('eligo-bioscience','81325167','UTILISATION THÉRAPEUTIQUE DE POST-BIOTIQUES MODIFIÉS COMPRENANT DES BACTÉRIOCINES ET/OU DES ENDOLYSINES'),
('eligo-bioscience','56511555','AMÉLIORATION DES AGENTS ANTIMICROBIENS SPÉCIFIQUES À UNE SÉQUENCE PAR LE BLOCAGE DE LA RÉPARATION DE L''ADN'),
('eligo-bioscience','71111434','VECTEURS D''ADMINISTRATION BACTÉRIENS COMPRENANT DES SÉQUENCES D''ACIDES NUCLÉIQUES TRACEURS'),
('eligo-bioscience','92108410','DÉTECTION ET TRAITEMENT DE MALADIES ASSOCIÉES AUX BACTÉRIES C. ACNES'),
('eligo-bioscience','87424019','MODULATION DU MICROBIOME D''UN HÔTE PAR ADMINISTRATION DE CHARGES UTILES D''ADN À ÉTALEMENT RÉDUIT À UN MINIMUM'),
('eligo-bioscience','74186654','VÉHICULES D''ADMINISTRATION DE BACTÉRIES POUR L''ADMINISTRATION IN VIVO D''UNE CHARGE UTILE D''ADN'),
('eligo-bioscience','78621842','PARTICULES DÉRIVÉES DE PHAGES POUR L''ADMINISTRATION IN SITU DE CHARGE UTILE D''ADN DANS UNE POPULATION DE C. ACNES'),
('eligo-bioscience','62909472','VÉHICULE D''ADMINISTRATION BACTÉRIEN, SON PROCÉDÉ DE PRODUCTION ET SES UTILISATIONS'),
('eligo-bioscience','76845232','PROCÉDÉ DE CONFINEMENT DE VECTEURS D''ACIDE NUCLÉIQUE INTRODUITS DANS UNE POPULATION DE MICROBIOME'),
('eligo-bioscience','69845429','RÉGULATION TRANSCRIPTIONNELLE DANS DES CELLULES PROCARYOTES À L''AIDE DE RÉPRESSEURS DE LIAISON À L''ADN'),
('eligo-bioscience','68731980','PROTÉINES CHIMÈRES DE LIAISON AU RÉCEPTEUR DESTINÉES À ÊTRE UTILISÉES DANS DES VECTEURS POUR DÉLIVRER DES BACTÉRIES'),
('eligo-bioscience','82309488','VÉHICULES D''ADMINISTRATION DE BACTÉRIES POUR L''ADMINISTRATION IN VIVO D''UNE CHARGE UTILE D''ADN'),
('endogenebio','90971431','Procédé pour l’isolement de cellules souches menstruelles'),
('eukarys','42358243','ENZYMES ARN-POLYMÉRASES SUJETTES AU COIFFAGE ET LEURS APPLICATIONS'),
('eukarys','59772551','NOUVELLES ENZYMES CHIMÉRIQUES ET LEURS APPLICATIONS'),
('eukarys','72292480','SYSTÈME D''EXPRESSION EUCARYOTE ARTIFICIEL À PERFORMANCES AMÉLIORÉES'),
('generare','90122974','PROCÉDÉS À HAUT DÉBIT POUR IDENTIFIER ET RÉCUPÉRER DES GROUPES DE GÈNES D''INTÉRÊT'),
('hyprview','84982264','PROCÉDÉ DE COMBINAISON D''IMAGES D''UN ÉCHANTILLON PROVENANT DE DIFFÉRENTS DISPOSITIFS D''IMAGERIE NUMÉRIQUE ET SYSTÈME ASSOCIÉ'),
('hyprview','84982284','SYSTÈME POUR COMBINER DES IMAGES D''UN ÉCHANTILLON PROVENANT DE DIFFÉRENTS DISPOSITIFS D''IMAGERIE NUMÉRIQUE'),
('iktos','86330318','PROCÉDÉS ET OUTILS POUR DÉTECTER L''IMPACT DE COMPOSÉS SUR DES INTERACTIONS PROTÉINE, ARN OU ADN'),
('inspek','86604649','SYSTÈMES, DISPOSITIFS ET PROCÉDÉS DE CORRECTION DE LA LIGNE DE BASE D’UN SPECTRE RAMAN GÉNÉRÉ PAR UNE TECHNOLOGIE DE SPECTROSCOPIE RAMAN AMPLIFIÉE PAR GUIDE D’ONDE'),
('netri','82594685','Procédé in vitro ou ex vivo de détermination de l’effet d’un échantillon biologique sur un modèle biologique utilisant l’activité neuronale large échelle.'),
('netri','67107735','Procédé assisté par ordinateur de détermination d’une architecture de circuit microfluidique reproduisant un circuit neuronal'),
('netri','67107691','Procédé de fabrication de dispositifs microfluidiques 3D'),
('netri','82319771','Dispositif de cultures cellulaires présentant une construction modulaire'),
('netri','82385469','Dispositif humidificateur pour un dispositif de culture cellulaire'),
('netri','73013619','Dispositif de positionnement et de fixation de dispositifs microfluidiques'),
('netri','86657253','Dispositif et procédé pour la connexion fluidique de contenants microfluidiques'),
('okomera','87473825','DISPOSITIF ET PROCÉDÉ DE GÉNÉRATION ET DE COLLECTE DE GOUTTELETTES'),
('one-biosciences','91968983','PROCÉDÉ ET DISPOSITIF DE DÉTERMINATION ET DE QUANTIFICATION DE MODES D''ACTIVATION DE VOIES BIOLOGIQUES DANS DES CELLULES INDIVIDUELLES'),
('owkin','67988947','SYSTÈMES ET PROCÉDÉS DE PRÉTRAITEMENT D''IMAGE'),
('owkin','67997544','SYSTÈMES ET PROCÉDÉS DE DÉTECTION DE CARACTÉRISTIQUES DE MÉSOTHÉLIOME ET PRONOSTIC OU RÉPONSE AMÉLIORÉ(E) À UN TRAITEMENT'),
('owkin','74141298','SYSTÈMES ET PROCÉDÉS D''ADMINISTRATION D''UN RÉSEAU D''APPRENTISSAGE FÉDÉRÉ'),
('owkin','78073870','SYSTÈMES ET PROCÉDÉS POUR DÉTERMINER UN PRONOSTIC DU CANCER DU SEIN ET CARACTÉRISTIQUES ASSOCIÉES'),
('peaccel','63103878','PROCÉDÉ ET SYSTÈME ÉLECTRONIQUE DE PRÉDICTION D''AU MOINS UN DEGRÉ DE COMPATIBILITÉ D''UNE PROTÉINE PAR L''INTERMÉDIAIRE D''UNE SÉQUENCE NUMÉRIQUE ÉTENDUE ET PRODUIT DE PROGRAMME INFORMATIQUE CORRESPONDANT'),
('peaccel','86383148','VARIANTS DE PROTÉASES DE SUBTILISINE'),
('poietis','58707847','EQUIPEMENT POUR LE TRANSFERT DE BIO-ENCRE'),
('poietis','58707848','PROCEDE DE BIOIMPRESSION'),
('poietis','59520986','EQUIPEMENT ET PROCEDE D''IMPRESSION ADDITIVE'),
('poietis','63312081','PANSEMENT CELLULARISE ET SON PROCEDE DE FABRICATION'),
('poietis','78827881','EQUIPEMENT D’IMPRESSION ADDITIVE PAR LASER MID IR'),
('poietis','67185439','CARTOUCHE POUR BIOIMPRESSION'),
('poietis','74347199','PROCEDE DE FABRICATION D’UNE VALVE BIOLOGIQUE PAR BIO-IMPRESSION'),
('poietis','65763556','DISPOSITIF DE BIO-IMPRESSION ISOLE'),
('poietis','66166052','SYSTEME DE BIO-IMPRESSION ROBOTISE'),
('poietis','87035965','IMPRESSION D’OBJETS A PARTIR D’UN PUITS'),
('poietis','85222017','MANIPULATION ET TRANSFERT D’OBJETS PAR PROPULSION'),
('poietis','82308492','IMPRESSION D''AGRÉGATS CELLULAIRES'),
('qubit-pharmaceuticals','78483228','NOUVEAUX INHIBITEURS DE LA PROTÉASE DE TYPE 3-CHYMOTRYPSINE DE CORONAVIRUS'),
('qubit-pharmaceuticals','94283874','PROCÉDÉS ET SYSTÈMES POUR PORTE NON COMMANDÉE EN PROFONDEUR POLYLOGARITHMIQUE'),
('qubit-pharmaceuticals','85873751','PROCÉDÉ PERMETTANT DE GÉNÉRER DE L''ANSATZ COMPACT GUIDÉ PAR CHEVAUCHEMENT POUR LA CHIMIE QUANTIQUE PRATIQUE, SES UTILISATIONS ET SYSTÈMES INFORMATIQUES ASSOCIÉS'),
('qubit-pharmaceuticals','87933776','PROCÉDÉ ET SYSTÈME DE CONFIGURATION DE CIRCUIT QUANTIQUE ÉVOLUTIVE DANS DES DISPOSITIFS QUANTIQUES À ÉCHELLE INTERMÉDIAIRE BRUYANTS'),
('qubit-pharmaceuticals','87202030','APPROXIMATION D''UNE FONCTION DE DENSITÉ SUR LA BASE D''UN MÉLANGE GAUSSIEN À L''AIDE D''UN ORDINATEUR QUANTIQUE'),
('qubit-pharmaceuticals','87201930','DÉTERMINATION D''UN EMPLACEMENT D''UNE ENTITÉ MOLÉCULAIRE AU NIVEAU D''UN SITE D''INTERACTION D''UNE MACROMOLÉCULE À L''AIDE D''UN ORDINATEUR QUANTIQUE'),
('qubit-pharmaceuticals','94278613','PROCÉDÉS ET SYSTÈMES POUR CIRCUIT À PROFONDEUR RÉGLABLE POUR PORTE NON COMMANDÉE'),
('qynapse','60382248','PREDICTION DE L''EVOLUTION DE MARQUEURS CLINIQUES ET D''IMAGERIE POUR LES PATHOLOGIES DU SYSTEME NERVEUX CENTRAL'),
('qynapse','64316567','PROCEDE DE DETERMINATION D''UN MODELE DE PREDICTION, PROCEDE DE PREDICTION DE L''EVOLUTION D''UN K-UPLET DE MARQUEURS MK ET DISPOSITIF ASSOCIE'),
('scienta-lab','88965607','METHODE ET DISPOSITIF POUR STRATIFIER DES SUJETS POUR LE DIAGNOSTIC, PRONOSTIC ET LA REPONSE AU TRAITEMENT'),
('spore-biotechnologies','91620988','Dispositif de détection de bactéries dans un échantillon'),
('spore-biotechnologies','94476410','DISPOSITIF DE DÉTECTION DE BACTÉRIES DANS UN ÉCHANTILLON'),
('whitelab-genomics','86469413','PROCÉDÉ D''APPRENTISSAGE AUTOMATIQUE POUR PRÉDICTION DE PHÉNOTYPE'))
UPDATE patents p SET title=t.title, updated_at=NOW()
FROM t JOIN organizations o ON o.slug=t.org
WHERE p.organization_id=o.id AND p.abstract LIKE '%DOCDB family '||t.fam||';%'
  AND p.title LIKE 'Patent family % (title not in open data)';
WITH src(org,tgt,n) AS (VALUES
('ksilink','cecs-i-stem',1),('ksilink','cnrs',1),('ksilink','inserm',1),('ksilink','sorbonne-universite',1),('ksilink','universite-evry-paris-saclay',1),
('one-biosciences','institut-gustave-roussy',1),('one-biosciences','universite-paris-saclay',1))
INSERT INTO organization_relationships (id,source_org_id,target_org_id,relationship_type,description,source_type,source_name,verification_status,legacy_source,created_at,updated_at)
SELECT uuid_generate_v4(),a.id,b.id,'partnered_with'::relationship_type,'Patent co-applicant on '||s.n||' patent famil'||CASE WHEN s.n=1 THEN 'y' ELSE 'ies' END||'.','open_data','INPI patent database (data.inpi.fr)','high','techbio_inpi_patents_november_2026',NOW(),NOW()
FROM src s JOIN organizations a ON a.slug=s.org JOIN organizations b ON b.slug=s.tgt
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='partnered_with' AND x.description LIKE 'Patent co-applicant%');
-- Qubit: 2 more families co-filed with CNRS and Sorbonne Université (3 -> 5)
UPDATE organization_relationships r SET description='Patent co-applicant on 5 patent families.', updated_at=NOW()
FROM organizations a, organizations b
WHERE r.source_org_id=a.id AND r.target_org_id=b.id AND a.slug='qubit-pharmaceuticals' AND b.slug IN ('cnrs','sorbonne-universite')
  AND r.legacy_source='techbio_patents_november_2026' AND r.description='Patent co-applicant on 3 patent families.';
COMMIT;
