-- =============================================================================
-- Atlas SMR: France 2030 Objectif 1 laureates (innovative small nuclear reactors
-- and better waste management) - organisations, projects and network links
-- =============================================================================
-- legacy_source 'f2030_obj1_smr_november_2026'.
-- Source: info.gouv.fr France 2030 laureates map, Objectif 1 filter, exported
-- manually by the editor (7 pages, 139 rows; Innowtech/PACH3 listed twice).
-- Parsed + resolved in data/atlas_smr/ (parse_f2030.py, resolve.py) against
-- recherche-entreprises.api.gouv.fr. Confidence carried in verification_status.
--  * 49 new organisations (48 with SIREN; Entreprise Auglans needs review).
--  * Existing CNRS, EDF, Blue Capsule Technology get their SIREN.
--  * Stellaria fix: the stored SIREN 837707512 belongs to an unrelated 2018
--    services firm in Saint-Pierre-la-Palud; the SMR developer is STELLARIA
--    DESIGN, SIREN 952843282 (Grenoble, 2023), which is the France 2030 laureate.
--  * 54 France 2030 projects in `projects`, linked to partners and to the
--    programme edition through `project_links` (role 'laureate').
--  * PALLAS appears on the list with no organisation (an IRSN-led project name);
--    it is linked to its four named partners only.
-- =============================================================================

INSERT INTO cities (id, name, slug, department_code, country, created_at, updated_at) VALUES
  (uuid_generate_v4(), 'Les Angles', 'les-angles', '30', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Les Sorinières', 'les-sorinieres', '44', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Codolet', 'codolet', '30', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Limay', 'limay', '78', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Arles', 'arles', '13', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Vaison-la-Romaine', 'vaison-la-romaine', '84', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Montagny', 'montagny', '69', 'France', NOW(), NOW()),
  (uuid_generate_v4(), 'Millau', 'millau', '12', 'France', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO organizations (id, name, slug, organization_type, description, status, country, city_id, founded_year, legacy_source, created_at, updated_at) VALUES
  (uuid_generate_v4(), 'Fonderie Lemer', 'fonderie-lemer', 'corporate'::organization_type, 'France 2030 Objectif 1 laureate (projects: MoMA, RPN2).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='carquefou'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'CEA (Commissariat à l''énergie atomique et aux énergies alternatives)', 'cea', 'research_lab'::organization_type, 'French public research body for nuclear and alternative energy, defence, health and digital technologies. France 2030 Objectif 1 laureate (projects: EPONA, REGAIN, NEWCLEO LFR 30 MWE, D-CLIC, BLUE CAPSULE, PACH3, HEXANA, ECCLOR, ANAIS, PROVIDENCE, SELF, KRYPTRAP, ESOP, TBATT - DIAMOND, MIRAGE, PREPAC, NAAREA FCE 2030, ISAC, SOLVERIS, STELLARIUM, RTG, PROXIMA, RF01, MOSARWASTE, ONE, PADAWANN, D-PERLE, TARANIS, ETIS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='paris'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Bernardaud', 'bernardaud', 'corporate'::organization_type, 'Limoges porcelain manufacturer. France 2030 Objectif 1 laureate (project: PROCER).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='limoges'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'TRAD Tests & Radiations', 'trad-tests-radiations', 'corporate'::organization_type, 'Radiation testing and radiation-effects engineering. France 2030 Objectif 1 laureate (project: SIMB-AD).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='labege'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'STMicroelectronics (Crolles 2) SAS', 'stmicroelectronics-crolles-2', 'corporate'::organization_type, 'Semiconductor fab subsidiary of STMicroelectronics at Crolles. France 2030 Objectif 1 laureate (project: TBATT - DIAMOND).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='crolles'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Laboratoire d''Étalons d''Activité (LEA)', 'laboratoire-detalons-dactivite-lea', 'corporate'::organization_type, 'Producer of radioactive reference sources and standards. France 2030 Objectif 1 laureate (project: DNAT).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chatillon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Nuward', 'nuward', 'corporate'::organization_type, 'EDF subsidiary developing the NUWARD small modular reactor. France 2030 Objectif 1 laureate (project: NUWARD).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='paris'), 2022, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Rousselet Centrifugation', 'rousselet-centrifugation', 'corporate'::organization_type, 'Industrial centrifuge manufacturer. France 2030 Objectif 1 laureate (project: MIRAGE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='annonay'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Veolia Nuclear Solutions France', 'veolia-nuclear-solutions-france', 'corporate'::organization_type, 'Nuclear decommissioning and waste-treatment arm of Veolia in France. France 2030 Objectif 1 laureate (project: SOLVERIS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chasse-sur-rhone'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Orano Démantèlement', 'orano-demantelement', 'corporate'::organization_type, 'Orano subsidiary for nuclear dismantling. France 2030 Objectif 1 laureate (projects: MoMA, ETIS, EcoLAS, CIMBOOST, RPN2, SELF, RTG, TRTAP, VAL''M2 TCN).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chatillon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Orano Recyclage', 'orano-recyclage', 'corporate'::organization_type, 'Orano subsidiary for spent-fuel recycling. France 2030 Objectif 1 laureate (projects: SMETANA, R2DS, PROVIDENCE, MRREP).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chatillon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Technetics Group France', 'technetics-group-france', 'corporate'::organization_type, 'Maker of high-performance seals and components. France 2030 Objectif 1 laureate (project: PACH3).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='saint-etienne'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Socotec Monitoring France', 'socotec-monitoring-france', 'corporate'::organization_type, 'Structural and environmental monitoring services. France 2030 Objectif 1 laureate (project: PALLAS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='guyancourt'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Innowtech', 'innowtech', 'startup'::organization_type, 'Registered as ceased in the company register. France 2030 Objectif 1 laureate (project: PACH3).', 'closed'::organization_status, 'France', (SELECT id FROM cities WHERE slug='les-angles'), 2017, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Meliad', 'meliad', 'corporate'::organization_type, 'France 2030 Objectif 1 laureate (project: EcoLAS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='les-sorinieres'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Orano Support', 'orano-support', 'corporate'::organization_type, 'Orano group support and R&D entity. France 2030 Objectif 1 laureate (projects: PORTHOS, PROXIMA, STELLARIUM, REGAIN, EPONA, ISAC, MOSARWASTE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chatillon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Toulouse INP (Institut national polytechnique de Toulouse)', 'toulouse-inp', 'university'::organization_type, 'France 2030 Objectif 1 laureate (projects: D-CLIC, MIRAGE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='toulouse'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Orano Chimie-Enrichissement', 'orano-chimie-enrichissement', 'corporate'::organization_type, 'Orano subsidiary for uranium conversion and enrichment. France 2030 Objectif 1 laureate (project: MAEVA2).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='chatillon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Orano DS – Démantèlement et Services', 'orano-ds-demantelement-et-services', 'corporate'::organization_type, 'Orano subsidiary for dismantling and nuclear services. France 2030 Objectif 1 laureate (projects: Dream scanner, D-PERLE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='massy'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Université de Limoges', 'universite-de-limoges', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: TRTAP).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='limoges'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'IRSN (Institut de radioprotection et de sûreté nucléaire)', 'irsn', 'research_lab'::organization_type, 'Public expert body on nuclear and radiation risk; merged with ASN into ASNR on 1 January 2025. France 2030 Objectif 1 laureate (project: PALLAS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='fontenay-aux-roses'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'ASNR (Autorité de sûreté nucléaire et de radioprotection)', 'asnr', 'public_agency'::organization_type, 'French nuclear safety and radiation protection authority, formed on 1 January 2025 from the merger of ASN and IRSN. France 2030 Objectif 1 laureate (project: Projet de développement d’une plateforme de recherche sur les performances en sûreté des systèmes passifs).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='montrouge'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Institut Mines-Télécom (IMT)', 'institut-mines-telecom', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: MAEVA2).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='palaiseau'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Framatome', 'framatome', 'corporate'::organization_type, 'Nuclear reactor equipment and fuel company, majority-owned by EDF. France 2030 Objectif 1 laureate (projects: ISAC, REGAIN, MRREP).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='courbevoie'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Oakridge (Orléans)', 'oakridge-orleans', 'corporate'::organization_type, 'Engineering firm in Orléans (not the US national laboratory). France 2030 Objectif 1 laureate (project: PROXIMA).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='orleans'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Aix-Marseille Université', 'aix-marseille-universite', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: MIRAGE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='marseille'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'W CE Process', 'w-ce-process', 'corporate'::organization_type, 'Registered as W CE PROCESS (Process and Wine). France 2030 Objectif 1 laureate (project: TRTAP).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='bordeaux'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Egis Nucléaire', 'egis-nucleaire', 'corporate'::organization_type, 'Nuclear engineering arm of Egis. France 2030 lists it as EGIS INDUSTRIES. France 2030 Objectif 1 laureate (project: BLUE CAPSULE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='montreuil'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Université de technologie de Troyes (UTT)', 'universite-de-technologie-de-troyes', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: Dream scanner).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='troyes'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Atlanchim Pharma', 'atlanchim-pharma', 'corporate'::organization_type, 'Contract chemistry research. France 2030 Objectif 1 laureate (project: ESOP).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='saint-herblain'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Cyclife France', 'cyclife-france', 'corporate'::organization_type, 'EDF group company for nuclear dismantling and waste treatment. France 2030 Objectif 1 laureate (project: ECCLOR).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='codolet'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Waste2Glass', 'waste2glass', 'startup'::organization_type, 'France 2030 Objectif 1 laureate (project: RAD2GLASS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='limay'), 2022, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'LERMAT (Laboratoire Études Recherche Matériaux)', 'lermat', 'corporate'::organization_type, 'France 2030 Objectif 1 laureate (project: CIMBOOST).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='arles'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'ECI Meca', 'eci-meca', 'corporate'::organization_type, 'Registered as ceased in the company register. France 2030 Objectif 1 laureate (project: SOLVERIS).', 'closed'::organization_status, 'France', (SELECT id FROM cities WHERE slug='vaison-la-romaine'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'GENF', 'genf', 'startup'::organization_type, 'France 2030 Objectif 1 laureate (project: TARANIS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='elancourt'), 2022, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Thorizon', 'thorizon', 'startup'::organization_type, 'French entity of Thorizon, a molten-salt reactor developer. France 2030 Objectif 1 laureate (project: PROXIMA).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='lyon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Université de Rouen Normandie', 'universite-de-rouen-normandie', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: PADAWANN).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='mont-saint-aignan'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'ECM Technologies', 'ecm-technologies', 'corporate'::organization_type, 'Industrial furnace maker. France 2030 Objectif 1 laureate (project: PROVIDENCE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='grenoble'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Curium', 'curium', 'corporate'::organization_type, 'Nuclear medicine and radiopharmaceuticals. France 2030 Objectif 1 laureate (projects: PACH3, RPN2).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='montagny'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Assystem Engineering and Operation Services', 'assystem-engineering-and-operation-services', 'corporate'::organization_type, 'Engineering subsidiary of Assystem, active in nuclear. France 2030 Objectif 1 laureate (project: SOLVERIS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='courbevoie'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Centrale Lille Institut', 'centrale-lille-institut', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: PROXIMA).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='villeneuve-dascq'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'BRGM', 'brgm', 'research_lab'::organization_type, 'France''s geological survey (Bureau de recherches géologiques et minières). France 2030 Objectif 1 laureate (project: SOLVERIS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='orleans'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Université Gustave Eiffel', 'universite-gustave-eiffel', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: PALLAS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='champs-sur-marne'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Naarea', 'naarea', 'startup'::organization_type, 'Developer of a molten-salt micro-reactor. France 2030 Objectif 1 laureate (project: NAAREA FCE 2030).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='nanterre'), 2020, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Rhodia Operations', 'rhodia-operations', 'corporate'::organization_type, 'Chemicals company (Solvay / Syensqo group). France 2030 Objectif 1 laureate (project: PORTHOS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='lyon'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'iTech Instruments', 'itech-instruments', 'corporate'::organization_type, 'France 2030 Objectif 1 laureate (project: DEMWASTE).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='vitrolles'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Nuvia Protection', 'nuvia-protection', 'corporate'::organization_type, 'Registered as NUVIA PROTECTION SERVICES. Nuclear protection services (Vinci group). France 2030 Objectif 1 laureate (project: TREFLE2).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='morestel'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Université de Lille', 'universite-de-lille', 'university'::organization_type, 'France 2030 Objectif 1 laureate (project: PROXIMA).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='lille'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'Entreprise Auglans', 'entreprise-auglans', 'corporate'::organization_type, 'Not found in the company register. France 2030 lists the town as Millau (69); Millau is in Aveyron (12). Needs review. France 2030 Objectif 1 laureate (project: PALLAS).', 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='millau'), NULL, 'f2030_obj1_smr_november_2026', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Stellaria: replace the wrong legal entity with STELLARIA DESIGN
DELETE FROM legal_entities le USING organizations o WHERE le.organization_id=o.id AND o.slug='stellaria' AND le.siren='837707512';

WITH source(slug, legal_name, siren, siren2, inc, city, naf, conf) AS (VALUES
  ('fonderie-lemer', 'FONDERIE LEMER', '812250231', '812250231', '2015-06-30', 'CARQUEFOU', '25.99B', 'high'),
  ('cea', 'COMMISSARIAT A L'' ENERGIE ATOMIQUE ET AUX ENERGIES ALTERNATIVES', '775685019', '775685019', NULL, 'PARIS', '72.19Z', 'high'),
  ('bernardaud', 'BERNARDAUD', '755501160', '755501160', NULL, 'LIMOGES', '23.41Z', 'high'),
  ('trad-tests-radiations', 'TRAD TESTS & RADIATIONS', '397862038', '397862038', '1994-07-11', 'LABEGE', '71.12B', 'high'),
  ('stmicroelectronics-crolles-2', 'STMICROELECTRONICS (CROLLES 2) SAS', '399395581', '399395581', '1994-12-28', 'CROLLES', '26.11Z', 'high'),
  ('laboratoire-detalons-dactivite-lea', 'LABORATOIRE D''ETALONS D''ACTIVITE', '538613613', '538613613', '2011-11-30', 'CHATILLON', '24.46Z', 'high'),
  ('nuward', 'NUWARD', '922039904', '922039904', '2022-11-30', 'PARIS', '71.12B', 'high'),
  ('rousselet-centrifugation', 'ROUSSELET CENTRIFUGATION', '324237254', '324237254', '1982-03-26', 'ANNONAY', '28.29B', 'high'),
  ('veolia-nuclear-solutions-france', 'VEOLIA NUCLEAR SOLUTIONS FRANCE', '500803390', '500803390', '2007-11-12', 'CHASSE-SUR-RHONE', '38.22Z', 'high'),
  ('orano-demantelement', 'ORANO DEMANTELEMENT', '305207169', '305207169', '1981-03-30', 'CHATILLON', '71.12B', 'high'),
  ('orano-recyclage', 'ORANO RECYCLAGE', '817439599', '817439599', '2015-12-17', 'CHATILLON', '20.13A', 'high'),
  ('technetics-group-france', 'TECHNETICS GROUP FRANCE SAS', '400072997', '400072997', '1995-01-18', 'SAINT-ETIENNE', '25.99B', 'high'),
  ('socotec-monitoring-france', 'SOCOTEC MONITORING FRANCE', '507759611', '507759611', '2008-08-01', 'GUYANCOURT', '71.12B', 'high'),
  ('innowtech', 'INNOWTECH', '832780225', '832780225', '2017-10-12', 'LES ANGLES', '71.12B', 'high'),
  ('meliad', 'MELIAD', '510035298', '510035298', '2009-01-21', 'LES SORINIERES', '71.20B', 'high'),
  ('orano-support', 'ORANO SUPPORT', '421356593', '421356593', '1998-12-18', 'CHATILLON', '70.10Z', 'high'),
  ('toulouse-inp', 'INSTITUT NATIONAL POLYTECHNIQUE DE TOULOUSE', '193113818', '193113818', NULL, 'TOULOUSE', '85.42Z', 'high'),
  ('orano-chimie-enrichissement', 'ORANO CHIMIE-ENRICHISSEMENT', '817439557', '817439557', '2015-12-17', 'CHATILLON', '20.13A', 'high'),
  ('orano-ds-demantelement-et-services', 'ORANO DS- DEMANTELEMENT ET SERVICES', '672008489', '672008489', NULL, 'MASSY', '38.22Z', 'high'),
  ('universite-de-limoges', 'UNIVERSITE DE LIMOGES', '198706699', '198706699', '1970-06-10', 'LIMOGES', '85.42Z', 'high'),
  ('irsn', 'INSTIT RADIOPROTECTION SURETE NUCLEAIRE', '440546018', '440546018', '2001-05-09', 'FONTENAY-AUX-ROSES', '72.19Z', 'high'),
  ('asnr', 'AUTORITE DE SURETE NUCLEAIRE ET DE RADIOPROTECTION', '130001803', '130001803', '2006-06-14', 'MONTROUGE', '71.20B', 'high'),
  ('institut-mines-telecom', 'INSTITUT MINES-TELECOM', '180092025', '180092025', '1996-12-29', 'PALAISEAU', '85.42Z', 'high'),
  ('framatome', 'FRAMATOME', '379041395', '379041395', '1990-07-16', 'COURBEVOIE', '25.30Z', 'high'),
  ('oakridge-orleans', 'OAKRIDGE', '443647144', '443647144', '2002-10-02', 'ORLEANS', '71.12B', 'high'),
  ('aix-marseille-universite', 'UNIVERSITE D''AIX MARSEILLE', '130015332', '130015332', NULL, 'MARSEILLE', '85.42Z', 'high'),
  ('w-ce-process', 'W CE PROCESS', '902610443', '902610443', '2021-09-15', 'BORDEAUX', '71.12B', 'high'),
  ('egis-nucleaire', 'EGIS NUCLEAIRE', '652030677', '652030677', NULL, 'MONTREUIL', '71.12B', 'medium'),
  ('universite-de-technologie-de-troyes', 'UNIVERSITE DE TECHNOLOGIE DE TROYES', '191010602', '191010602', '1994-09-21', 'TROYES', '85.42Z', 'high'),
  ('atlanchim-pharma', 'ATLANCHIM PHARMA', '504005612', '504005612', '2008-04-18', 'SAINT-HERBLAIN', '72.19Z', 'high'),
  ('cyclife-france', 'CYCLIFE FRANCE SA', '380303107', '380303107', '1990-10-11', 'CODOLET', '38.22Z', 'medium'),
  ('waste2glass', 'WASTE2GLASS', '909910630', '909910630', '2022-02-01', 'LIMAY', '71.12B', 'high'),
  ('lermat', 'LABORATOIRE ETUDES RECHERCHE MATERIAUX', '344297775', '344297775', '1988-03-23', 'ARLES', '71.12B', 'high'),
  ('eci-meca', 'ECI MECA', '403523525', '403523525', '1995-12-31', 'VAISON-LA-ROMAINE', '71.12B', 'high'),
  ('genf', 'GENF', '913080941', '913080941', '2022-04-20', 'ELANCOURT', '46.69A', 'high'),
  ('thorizon', 'THORIZON', '950900720', '950900720', '2023-03-23', 'LYON', '35.11Z', 'high'),
  ('universite-de-rouen-normandie', 'UNIVERSITE DE ROUEN-NORMANDIE', '197619042', '197619042', '1983-03-01', 'MONT-SAINT-AIGNAN', '85.42Z', 'high'),
  ('ecm-technologies', 'ECM TECHNOLOGIES', '478969173', '478969173', '2004-09-15', 'GRENOBLE', '28.21Z', 'high'),
  ('curium', 'CURIUM', '398750653', '398750653', '1994-10-11', 'MONTAGNY', '39.00Z', 'high'),
  ('assystem-engineering-and-operation-services', 'ASSYSTEM ENGINEERING AND OPERATION SERVICES', '444159164', '444159164', '2002-10-22', 'COURBEVOIE', '71.12B', 'high'),
  ('centrale-lille-institut', 'CENTRALE LILLE INSTITUT', '195903497', '195903497', NULL, 'VILLENEUVE D''ASCQ', '85.42Z', 'high'),
  ('brgm', 'BRGM', '582056149', '582056149', NULL, 'ORLEANS', '72.19Z', 'high'),
  ('universite-gustave-eiffel', 'UNIVERSITE GUSTAVE EIFFEL', '130026123', '130026123', NULL, 'CHAMPS-SUR-MARNE', '85.42Z', 'high'),
  ('naarea', 'NAAREA', '882949506', '882949506', '2020-03-27', 'NANTERRE', '25.30Z', 'high'),
  ('rhodia-operations', 'RHODIA OPERATIONS', '622037083', '622037083', NULL, 'LYON', '20.14Z', 'high'),
  ('itech-instruments', 'ITECH INSTRUMENTS', '488453283', '488453283', '2006-02-01', 'VITROLLES', '62.01Z', 'high'),
  ('nuvia-protection', 'NUVIA PROTECTION SERVICES', '918349796', '918349796', '2022-06-01', 'MORESTEL', '43.22B', 'medium'),
  ('universite-de-lille', 'UNIVERSITE DE LILLE', '130029754', '130029754', '2021-09-22', 'LILLE', '85.42Z', 'high'),
  ('cnrs', 'CENTRE NATIONAL DE LA RECHERCHE SCIENTIFIQUE', '180089013', '180089013', '1965-02-17', 'PARIS', '72.19Z', 'high'),
  ('edf', 'ELECTRICITE DE FRANCE', '552081317', '552081317', NULL, 'PARIS', '35.11Z', 'high'),
  ('stellaria', 'STELLARIA DESIGN', '952843282', '952843282', '2023-05-16', 'GRENOBLE', '35.11Z', 'high'),
  ('blue-capsule-technology', 'BLUE CAPSULE', '921792404', '921792404', '2022-11-22', 'AIX-EN-PROVENCE', '28.99B', 'high'))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, registered_city, naf_code, country, is_primary, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, s.inc::date, s.city, s.naf, 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.organization_id=o.id), s.conf, 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.siren=s.siren);

-- Sector: Nuclear for nuclear-industry organisations
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, (SELECT id FROM sectors WHERE slug='nuclear'), NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id), NOW()
FROM organizations o WHERE o.slug IN ('cea','trad-tests-radiations','laboratoire-detalons-dactivite-lea','nuward','veolia-nuclear-solutions-france','orano-demantelement','orano-recyclage','innowtech','orano-support','orano-chimie-enrichissement','orano-ds-demantelement-et-services','irsn','asnr','framatome','egis-nucleaire','cyclife-france','waste2glass','genf','thorizon','curium','assystem-engineering-and-operation-services','naarea','nuvia-protection')
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.sector_id=(SELECT id FROM sectors WHERE slug='nuclear'));

-- Programme and edition
INSERT INTO programs (id, name, slug, program_type, description, country, source_url, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'France 2030', 'france-2030', 'france_2030', 'French state investment plan (€54bn) run by the SGPI with four operators: ANR, ADEME, Bpifrance and Caisse des Dépôts. Organised around 10 objectives.', 'France', 'https://www.info.gouv.fr/france-2030', 'f2030_obj1_smr_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM programs WHERE slug='france-2030');
INSERT INTO program_editions (id, program_id, name, slug, description, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'France 2030 — Objectif 1: small innovative nuclear reactors & better waste management', 'france-2030-objectif-1-nucleaire',
  'Laureates of France 2030 Objectif 1: « Faire émerger en France d''ici 2030 des réacteurs nucléaires de petite taille, innovants et avec une meilleure gestion des déchets ». 139 laureate rows (138 unique) as listed on the official map in November 2026.',
  'https://www.info.gouv.fr/france-2030/laureats', 'high', 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM programs p WHERE p.slug='france-2030' AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='france-2030-objectif-1-nucleaire');

WITH source(slug, notes, conf) AS (VALUES
  ('fonderie-lemer', 'Projects: MoMA, RPN2', 'high'),
  ('damavan-imaging', 'Projects: Dream scanner', 'high'),
  ('cea', 'Projects: EPONA, REGAIN, NEWCLEO LFR 30 MWE, D-CLIC, BLUE CAPSULE, PACH3, HEXANA, ECCLOR, ANAIS, PROVIDENCE, SELF, KRYPTRAP, ESOP, TBATT - DIAMOND, MIRAGE, PREPAC, NAAREA FCE 2030, ISAC, SOLVERIS, STELLARIUM, RTG, PROXIMA, RF01, MOSARWASTE, ONE, PADAWANN, D-PERLE, TARANIS, ETIS', 'high'),
  ('renaissance-fusion', 'Projects: RF01', 'high'),
  ('bernardaud', 'Projects: PROCER', 'high'),
  ('trad-tests-radiations', 'Projects: SIMB-AD', 'high'),
  ('amplitude-systemes', 'Projects: EPONA', 'medium'),
  ('stmicroelectronics-crolles-2', 'Projects: TBATT - DIAMOND', 'high'),
  ('laboratoire-detalons-dactivite-lea', 'Projects: DNAT', 'high'),
  ('demboost', 'Projects: DEMWASTE', 'high'),
  ('nuward', 'Projects: NUWARD', 'high'),
  ('rousselet-centrifugation', 'Projects: MIRAGE', 'high'),
  ('veolia-nuclear-solutions-france', 'Projects: SOLVERIS', 'high'),
  ('orano-demantelement', 'Projects: MoMA, ETIS, EcoLAS, CIMBOOST, RPN2, SELF, RTG, TRTAP, VAL''M2 TCN', 'high'),
  ('orano-recyclage', 'Projects: SMETANA, R2DS, PROVIDENCE, MRREP', 'high'),
  ('technetics-group-france', 'Projects: PACH3', 'high'),
  ('socotec-monitoring-france', 'Projects: PALLAS', 'high'),
  ('innowtech', 'Projects: PACH3', 'high'),
  ('meliad', 'Projects: EcoLAS', 'high'),
  ('orano-support', 'Projects: PORTHOS, PROXIMA, STELLARIUM, REGAIN, EPONA, ISAC, MOSARWASTE', 'high'),
  ('edf', 'Projects: VAL''M2 TCN, SMETANA, ISAC, MRREP, Nuward', 'high'),
  ('tx-4000', 'Projects: ETIS, MoMA', 'high'),
  ('sileane', 'Projects: R2DS', 'high'),
  ('entreprise-auglans', 'Projects: PALLAS', 'review'),
  ('probayes', 'Projects: ETIS', 'high'),
  ('toulouse-inp', 'Projects: D-CLIC, MIRAGE', 'high'),
  ('cnrs', 'Projects: MIRAGE, MAEVA2, PREPAC, SPATIAL, D-CLIC, SIMB-AD, KRYPTRAP, ISAC, MOSARWASTE, PORTHOS, SELF, TARANIS, REGAIN, PALLAS', 'high'),
  ('cesigma-signals-systems', 'Projects: ANAIS', 'high'),
  ('orano-chimie-enrichissement', 'Projects: MAEVA2', 'high'),
  ('orano-ds-demantelement-et-services', 'Projects: Dream scanner, D-PERLE', 'high'),
  ('universite-de-limoges', 'Projects: TRTAP', 'high'),
  ('irsn', 'Projects: PALLAS', 'high'),
  ('triskem-international', 'Projects: RTG', 'high'),
  ('asnr', 'Projects: Projet de développement d’une plateforme de recherche sur les performances en sûreté des systèmes passifs', 'high'),
  ('stellaria', 'Projects: STELLARIUM', 'high'),
  ('institut-mines-telecom', 'Projects: MAEVA2', 'high'),
  ('newcleo', 'Projects: NEWCLEO LFR 30 MWE', 'high'),
  ('framatome', 'Projects: ISAC, REGAIN, MRREP', 'high'),
  ('oakridge-orleans', 'Projects: PROXIMA', 'high'),
  ('aix-marseille-universite', 'Projects: MIRAGE', 'high'),
  ('w-ce-process', 'Projects: TRTAP', 'high'),
  ('egis-nucleaire', 'Projects: BLUE CAPSULE', 'medium'),
  ('universite-de-technologie-de-troyes', 'Projects: Dream scanner', 'high'),
  ('atlanchim-pharma', 'Projects: ESOP', 'high'),
  ('cyclife-france', 'Projects: ECCLOR', 'medium'),
  ('waste2glass', 'Projects: RAD2GLASS', 'high'),
  ('lermat', 'Projects: CIMBOOST', 'high'),
  ('eci-meca', 'Projects: SOLVERIS', 'high'),
  ('genf', 'Projects: TARANIS', 'high'),
  ('blue-capsule-technology', 'Projects: BLUE CAPSULE', 'high'),
  ('diamfab', 'Projects: TBATT - DIAMOND', 'high'),
  ('thorizon', 'Projects: PROXIMA', 'high'),
  ('universite-de-rouen-normandie', 'Projects: PADAWANN', 'high'),
  ('ecm-technologies', 'Projects: PROVIDENCE', 'high'),
  ('curium', 'Projects: PACH3, RPN2', 'high'),
  ('hexana', 'Projects: HEXANA', 'high'),
  ('assystem-engineering-and-operation-services', 'Projects: SOLVERIS', 'high'),
  ('centrale-lille-institut', 'Projects: PROXIMA', 'high'),
  ('brgm', 'Projects: SOLVERIS', 'high'),
  ('universite-gustave-eiffel', 'Projects: PALLAS', 'high'),
  ('naarea', 'Projects: NAAREA FCE 2030', 'high'),
  ('rhodia-operations', 'Projects: PORTHOS', 'high'),
  ('itech-instruments', 'Projects: DEMWASTE', 'high'),
  ('calogena', 'Projects: CALOGENA', 'high'),
  ('nuvia-protection', 'Projects: TREFLE2', 'medium'),
  ('universite-de-lille', 'Projects: PROXIMA', 'high'),
  ('otrera', 'Projects: ONE', 'high'),
  ('jimmy-energy', 'Projects: GTA', 'high'))
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Laureate', s.notes, s.conf, 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.slug JOIN program_editions pe ON pe.slug='france-2030-objectif-1-nucleaire'
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;

WITH source(name, slug, summary) AS (VALUES
  ('MoMA', 'france-2030-obj1-moma', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('Dream scanner', 'france-2030-obj1-dream-scanner', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('EPONA', 'france-2030-obj1-epona', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('REGAIN', 'france-2030-obj1-regain', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 4 named partners.'),
  ('RPN2', 'france-2030-obj1-rpn2', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('RF01', 'france-2030-obj1-rf01', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('NEWCLEO LFR 30 MWE', 'france-2030-obj1-newcleo-lfr-30-mwe', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('PROCER', 'france-2030-obj1-procer', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('SIMB-AD', 'france-2030-obj1-simb-ad', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('D-CLIC', 'france-2030-obj1-d-clic', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('TBATT - DIAMOND', 'france-2030-obj1-tbatt-diamond', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('DNAT', 'france-2030-obj1-dnat', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('DEMWASTE', 'france-2030-obj1-demwaste', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('NUWARD', 'france-2030-obj1-nuward', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('MIRAGE', 'france-2030-obj1-mirage', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 5 named partners.'),
  ('BLUE CAPSULE', 'france-2030-obj1-blue-capsule', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('PACH3', 'france-2030-obj1-pach3', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 4 named partners.'),
  ('HEXANA', 'france-2030-obj1-hexana', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('ECCLOR', 'france-2030-obj1-ecclor', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('SOLVERIS', 'france-2030-obj1-solveris', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 5 named partners.'),
  ('SMETANA', 'france-2030-obj1-smetana', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('ANAIS', 'france-2030-obj1-anais', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('PROVIDENCE', 'france-2030-obj1-providence', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('PALLAS', 'france-2030-obj1-pallas', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 5 named partners. The official list also shows PALLAS as an entry with no organisation.'),
  ('EcoLAS', 'france-2030-obj1-ecolas', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('PORTHOS', 'france-2030-obj1-porthos', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('ETIS', 'france-2030-obj1-etis', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 4 named partners.'),
  ('SELF', 'france-2030-obj1-self', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('VAL''M2 TCN', 'france-2030-obj1-val-m2-tcn', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('KRYPTRAP', 'france-2030-obj1-kryptrap', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('R2DS', 'france-2030-obj1-r2ds', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('ESOP', 'france-2030-obj1-esop', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('PROXIMA', 'france-2030-obj1-proxima', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 6 named partners.'),
  ('MAEVA2', 'france-2030-obj1-maeva2', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('TRTAP', 'france-2030-obj1-trtap', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('CIMBOOST', 'france-2030-obj1-cimboost', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('D-PERLE', 'france-2030-obj1-d-perle', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('RTG', 'france-2030-obj1-rtg', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('Projet de développement d’une plateforme de recherche sur les performances en sûreté des systèmes passifs', 'france-2030-obj1-projet-de-developpement-dune-plateforme-de-recherche-sur-les-performances-en-surete-des-systemes-passifs', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('STELLARIUM', 'france-2030-obj1-stellarium', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('PREPAC', 'france-2030-obj1-prepac', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('ISAC', 'france-2030-obj1-isac', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 5 named partners.'),
  ('MRREP', 'france-2030-obj1-mrrep', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('NAAREA FCE 2030', 'france-2030-obj1-naarea-fce-2030', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('SPATIAL', 'france-2030-obj1-spatial', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('RAD2GLASS', 'france-2030-obj1-rad2glass', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('TARANIS', 'france-2030-obj1-taranis', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('MOSARWASTE', 'france-2030-obj1-mosarwaste', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 3 named partners.'),
  ('PADAWANN', 'france-2030-obj1-padawann', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('Nuward', 'france-2030-obj1-nuward', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('ONE', 'france-2030-obj1-one', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 2 named partners.'),
  ('CALOGENA', 'france-2030-obj1-calogena', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('TREFLE2', 'france-2030-obj1-trefle2', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'),
  ('GTA', 'france-2030-obj1-gta', 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). 1 named partner.'))
INSERT INTO projects (id, name, slug, summary, technical_focus, sector, commercialization_status, is_public, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, s.summary, ARRAY['nuclear'], 'Nucléaire', 'awarded', FALSE, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

INSERT INTO project_links (id, project_id, program_edition_id, role, status, created_at)
SELECT uuid_generate_v4(), p.id, pe.id, 'laureate', 'verified', NOW()
FROM projects p JOIN program_editions pe ON pe.slug='france-2030-objectif-1-nucleaire'
WHERE p.slug LIKE 'france-2030-obj1-%' AND NOT EXISTS (SELECT 1 FROM project_links x WHERE x.project_id=p.id AND x.program_edition_id=pe.id);

WITH source(pslug, oslug, st) AS (VALUES
  ('france-2030-obj1-moma', 'fonderie-lemer', 'verified'),
  ('france-2030-obj1-moma', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-moma', 'tx-4000', 'verified'),
  ('france-2030-obj1-dream-scanner', 'damavan-imaging', 'verified'),
  ('france-2030-obj1-dream-scanner', 'orano-ds-demantelement-et-services', 'verified'),
  ('france-2030-obj1-dream-scanner', 'universite-de-technologie-de-troyes', 'verified'),
  ('france-2030-obj1-epona', 'cea', 'verified'),
  ('france-2030-obj1-epona', 'amplitude-systemes', 'proposed'),
  ('france-2030-obj1-epona', 'orano-support', 'verified'),
  ('france-2030-obj1-regain', 'cea', 'verified'),
  ('france-2030-obj1-regain', 'orano-support', 'verified'),
  ('france-2030-obj1-regain', 'framatome', 'verified'),
  ('france-2030-obj1-regain', 'cnrs', 'verified'),
  ('france-2030-obj1-rpn2', 'fonderie-lemer', 'verified'),
  ('france-2030-obj1-rpn2', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-rpn2', 'curium', 'verified'),
  ('france-2030-obj1-rf01', 'renaissance-fusion', 'verified'),
  ('france-2030-obj1-rf01', 'cea', 'verified'),
  ('france-2030-obj1-newcleo-lfr-30-mwe', 'cea', 'verified'),
  ('france-2030-obj1-newcleo-lfr-30-mwe', 'newcleo', 'verified'),
  ('france-2030-obj1-procer', 'bernardaud', 'verified'),
  ('france-2030-obj1-simb-ad', 'trad-tests-radiations', 'verified'),
  ('france-2030-obj1-simb-ad', 'cnrs', 'verified'),
  ('france-2030-obj1-d-clic', 'cea', 'verified'),
  ('france-2030-obj1-d-clic', 'toulouse-inp', 'verified'),
  ('france-2030-obj1-d-clic', 'cnrs', 'verified'),
  ('france-2030-obj1-tbatt-diamond', 'stmicroelectronics-crolles-2', 'verified'),
  ('france-2030-obj1-tbatt-diamond', 'cea', 'verified'),
  ('france-2030-obj1-tbatt-diamond', 'diamfab', 'verified'),
  ('france-2030-obj1-dnat', 'laboratoire-detalons-dactivite-lea', 'verified'),
  ('france-2030-obj1-demwaste', 'demboost', 'verified'),
  ('france-2030-obj1-demwaste', 'itech-instruments', 'verified'),
  ('france-2030-obj1-nuward', 'nuward', 'verified'),
  ('france-2030-obj1-mirage', 'rousselet-centrifugation', 'verified'),
  ('france-2030-obj1-mirage', 'cnrs', 'verified'),
  ('france-2030-obj1-mirage', 'cea', 'verified'),
  ('france-2030-obj1-mirage', 'aix-marseille-universite', 'verified'),
  ('france-2030-obj1-mirage', 'toulouse-inp', 'verified'),
  ('france-2030-obj1-blue-capsule', 'cea', 'verified'),
  ('france-2030-obj1-blue-capsule', 'egis-nucleaire', 'proposed'),
  ('france-2030-obj1-blue-capsule', 'blue-capsule-technology', 'verified'),
  ('france-2030-obj1-pach3', 'cea', 'verified'),
  ('france-2030-obj1-pach3', 'technetics-group-france', 'verified'),
  ('france-2030-obj1-pach3', 'innowtech', 'verified'),
  ('france-2030-obj1-pach3', 'curium', 'verified'),
  ('france-2030-obj1-hexana', 'cea', 'verified'),
  ('france-2030-obj1-hexana', 'hexana', 'verified'),
  ('france-2030-obj1-ecclor', 'cea', 'verified'),
  ('france-2030-obj1-ecclor', 'cyclife-france', 'proposed'),
  ('france-2030-obj1-solveris', 'veolia-nuclear-solutions-france', 'verified'),
  ('france-2030-obj1-solveris', 'cea', 'verified'),
  ('france-2030-obj1-solveris', 'eci-meca', 'verified'),
  ('france-2030-obj1-solveris', 'assystem-engineering-and-operation-services', 'verified'),
  ('france-2030-obj1-solveris', 'brgm', 'verified'),
  ('france-2030-obj1-smetana', 'orano-recyclage', 'verified'),
  ('france-2030-obj1-smetana', 'edf', 'verified'),
  ('france-2030-obj1-anais', 'cea', 'verified'),
  ('france-2030-obj1-anais', 'cesigma-signals-systems', 'verified'),
  ('france-2030-obj1-providence', 'cea', 'verified'),
  ('france-2030-obj1-providence', 'orano-recyclage', 'verified'),
  ('france-2030-obj1-providence', 'ecm-technologies', 'verified'),
  ('france-2030-obj1-pallas', 'socotec-monitoring-france', 'verified'),
  ('france-2030-obj1-pallas', 'entreprise-auglans', 'proposed'),
  ('france-2030-obj1-pallas', 'irsn', 'verified'),
  ('france-2030-obj1-pallas', 'universite-gustave-eiffel', 'verified'),
  ('france-2030-obj1-pallas', 'cnrs', 'verified'),
  ('france-2030-obj1-ecolas', 'meliad', 'verified'),
  ('france-2030-obj1-ecolas', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-porthos', 'orano-support', 'verified'),
  ('france-2030-obj1-porthos', 'cnrs', 'verified'),
  ('france-2030-obj1-porthos', 'rhodia-operations', 'verified'),
  ('france-2030-obj1-etis', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-etis', 'tx-4000', 'verified'),
  ('france-2030-obj1-etis', 'probayes', 'verified'),
  ('france-2030-obj1-etis', 'cea', 'verified'),
  ('france-2030-obj1-self', 'cea', 'verified'),
  ('france-2030-obj1-self', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-self', 'cnrs', 'verified'),
  ('france-2030-obj1-val-m2-tcn', 'edf', 'verified'),
  ('france-2030-obj1-val-m2-tcn', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-kryptrap', 'cea', 'verified'),
  ('france-2030-obj1-kryptrap', 'cnrs', 'verified'),
  ('france-2030-obj1-r2ds', 'orano-recyclage', 'verified'),
  ('france-2030-obj1-r2ds', 'sileane', 'verified'),
  ('france-2030-obj1-esop', 'cea', 'verified'),
  ('france-2030-obj1-esop', 'atlanchim-pharma', 'verified'),
  ('france-2030-obj1-proxima', 'orano-support', 'verified'),
  ('france-2030-obj1-proxima', 'oakridge-orleans', 'verified'),
  ('france-2030-obj1-proxima', 'cea', 'verified'),
  ('france-2030-obj1-proxima', 'thorizon', 'verified'),
  ('france-2030-obj1-proxima', 'centrale-lille-institut', 'verified'),
  ('france-2030-obj1-proxima', 'universite-de-lille', 'verified'),
  ('france-2030-obj1-maeva2', 'orano-chimie-enrichissement', 'verified'),
  ('france-2030-obj1-maeva2', 'institut-mines-telecom', 'verified'),
  ('france-2030-obj1-maeva2', 'cnrs', 'verified'),
  ('france-2030-obj1-trtap', 'universite-de-limoges', 'verified'),
  ('france-2030-obj1-trtap', 'w-ce-process', 'verified'),
  ('france-2030-obj1-trtap', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-cimboost', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-cimboost', 'lermat', 'verified'),
  ('france-2030-obj1-d-perle', 'orano-ds-demantelement-et-services', 'verified'),
  ('france-2030-obj1-d-perle', 'cea', 'verified'),
  ('france-2030-obj1-rtg', 'triskem-international', 'verified'),
  ('france-2030-obj1-rtg', 'cea', 'verified'),
  ('france-2030-obj1-rtg', 'orano-demantelement', 'verified'),
  ('france-2030-obj1-projet-de-developpement-dune-plateforme-de-recherche-sur-les-performances-en-surete-des-systemes-passifs', 'asnr', 'verified'),
  ('france-2030-obj1-stellarium', 'stellaria', 'verified'),
  ('france-2030-obj1-stellarium', 'orano-support', 'verified'),
  ('france-2030-obj1-stellarium', 'cea', 'verified'),
  ('france-2030-obj1-prepac', 'cea', 'verified'),
  ('france-2030-obj1-prepac', 'cnrs', 'verified'),
  ('france-2030-obj1-isac', 'framatome', 'verified'),
  ('france-2030-obj1-isac', 'edf', 'verified'),
  ('france-2030-obj1-isac', 'cea', 'verified'),
  ('france-2030-obj1-isac', 'cnrs', 'verified'),
  ('france-2030-obj1-isac', 'orano-support', 'verified'),
  ('france-2030-obj1-mrrep', 'orano-recyclage', 'verified'),
  ('france-2030-obj1-mrrep', 'edf', 'verified'),
  ('france-2030-obj1-mrrep', 'framatome', 'verified'),
  ('france-2030-obj1-naarea-fce-2030', 'cea', 'verified'),
  ('france-2030-obj1-naarea-fce-2030', 'naarea', 'verified'),
  ('france-2030-obj1-spatial', 'cnrs', 'verified'),
  ('france-2030-obj1-rad2glass', 'waste2glass', 'verified'),
  ('france-2030-obj1-taranis', 'genf', 'verified'),
  ('france-2030-obj1-taranis', 'cnrs', 'verified'),
  ('france-2030-obj1-taranis', 'cea', 'verified'),
  ('france-2030-obj1-mosarwaste', 'cea', 'verified'),
  ('france-2030-obj1-mosarwaste', 'cnrs', 'verified'),
  ('france-2030-obj1-mosarwaste', 'orano-support', 'verified'),
  ('france-2030-obj1-padawann', 'universite-de-rouen-normandie', 'verified'),
  ('france-2030-obj1-padawann', 'cea', 'verified'),
  ('france-2030-obj1-nuward', 'edf', 'verified'),
  ('france-2030-obj1-one', 'cea', 'verified'),
  ('france-2030-obj1-one', 'otrera', 'verified'),
  ('france-2030-obj1-calogena', 'calogena', 'verified'),
  ('france-2030-obj1-trefle2', 'nuvia-protection', 'proposed'),
  ('france-2030-obj1-gta', 'jimmy-energy', 'verified'))
INSERT INTO project_links (id, project_id, organization_id, role, status, created_at)
SELECT uuid_generate_v4(), p.id, o.id, 'laureate', s.st, NOW()
FROM source s JOIN projects p ON p.slug=s.pslug JOIN organizations o ON o.slug=s.oslug
WHERE NOT EXISTS (SELECT 1 FROM project_links x WHERE x.project_id=p.id AND x.organization_id=o.id);

WITH source(a, b, t, d) AS (VALUES
  ('orano-demantelement', 'orano', 'subsidiary_of', 'Orano group subsidiary.'),
  ('orano-recyclage', 'orano', 'subsidiary_of', 'Orano group subsidiary.'),
  ('orano-support', 'orano', 'subsidiary_of', 'Orano group subsidiary.'),
  ('orano-chimie-enrichissement', 'orano', 'subsidiary_of', 'Orano group subsidiary.'),
  ('orano-ds-demantelement-et-services', 'orano', 'subsidiary_of', 'Orano group subsidiary.'),
  ('nuward', 'edf', 'subsidiary_of', 'EDF subsidiary developing the NUWARD SMR.'),
  ('framatome', 'edf', 'subsidiary_of', 'Majority-owned by EDF.'),
  ('cyclife-france', 'edf', 'subsidiary_of', 'EDF group company.'),
  ('stmicroelectronics-crolles-2', 'stmicroelectronics', 'subsidiary_of', 'STMicroelectronics fab subsidiary.'),
  ('cea-investissement', 'cea', 'subsidiary_of', 'Investment arm of CEA.'),
  ('irsn', 'asnr', 'other', 'IRSN merged with ASN to form ASNR on 1 January 2025.'))
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.d, 'open_data', 'Company register / public sources', 'high', 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations a ON a.slug=s.a JOIN organizations b ON b.slug=s.b
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type);

-- Tags
INSERT INTO organization_tags (id, organization_id, tag, created_at)
SELECT uuid_generate_v4(), o.id, t.tag, NOW() FROM organizations o CROSS JOIN (VALUES ('France 2030 laureate'),('Atlas: SMR & nuclear innovation')) t(tag)
WHERE o.slug IN ('fonderie-lemer','damavan-imaging','cea','renaissance-fusion','bernardaud','trad-tests-radiations','amplitude-systemes','stmicroelectronics-crolles-2','laboratoire-detalons-dactivite-lea','demboost','nuward','rousselet-centrifugation','veolia-nuclear-solutions-france','orano-demantelement','orano-recyclage','technetics-group-france','socotec-monitoring-france','innowtech','meliad','orano-support','edf','tx-4000','sileane','entreprise-auglans','probayes','toulouse-inp','cnrs','cesigma-signals-systems','orano-chimie-enrichissement','orano-ds-demantelement-et-services','universite-de-limoges','irsn','triskem-international','asnr','stellaria','institut-mines-telecom','newcleo','framatome','oakridge-orleans','aix-marseille-universite','w-ce-process','egis-nucleaire','universite-de-technologie-de-troyes','atlanchim-pharma','cyclife-france','waste2glass','lermat','eci-meca','genf','blue-capsule-technology','diamfab','thorizon','universite-de-rouen-normandie','ecm-technologies','curium','hexana','assystem-engineering-and-operation-services','centrale-lille-institut','brgm','universite-gustave-eiffel','naarea','rhodia-operations','itech-instruments','calogena','nuvia-protection','universite-de-lille','otrera','jimmy-energy')
ON CONFLICT (organization_id, tag) DO NOTHING;

-- Recount partners per project (the EDF row spells the project 'Nuward', merged into NUWARD)
UPDATE projects p SET summary = 'France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). '
  || c.n || ' named partner' || CASE WHEN c.n>1 THEN 's' ELSE '' END || '.'
  || CASE WHEN p.slug='france-2030-obj1-pallas' THEN ' The official list also shows PALLAS as an entry with no organisation.' ELSE '' END, updated_at=NOW()
FROM (SELECT project_id, count(*) n FROM project_links WHERE organization_id IS NOT NULL GROUP BY 1) c
WHERE c.project_id=p.id AND p.slug LIKE 'france-2030-obj1-%';

SELECT (SELECT count(*) FROM organizations WHERE legacy_source='f2030_obj1_smr_november_2026') new_orgs,
 (SELECT count(*) FROM program_organizations po JOIN program_editions pe ON pe.id=po.program_edition_id WHERE pe.slug='france-2030-objectif-1-nucleaire') laureates,
 (SELECT count(*) FROM projects WHERE slug LIKE 'france-2030-obj1-%') projects,
 (SELECT count(*) FROM project_links pl JOIN projects p ON p.id=pl.project_id WHERE p.slug LIKE 'france-2030-obj1-%' AND pl.organization_id IS NOT NULL) org_links;
