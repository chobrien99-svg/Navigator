-- Atlas entity load: NVIDIA (nvidia)
-- Run: 2026-11-18; accepted findings by type: {"establishment": 10, "legal_entity": 1, "legal_notice": 15, "lobbying_client": 1, "research_paper": 1}
-- Idempotent: legacy_source 'atlas:entity:nvidia' / NOT EXISTS guards.
BEGIN;

-- registry:establishment:43210835500012
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2000-07-04'::date, 'Opens a site in Abroad', 'NVIDIA LTD: Opened 2000-07-04, open. Address: BERKHIRE RG7 5 AH 11 A 13 THEALE COURT ROYAUME-UNI', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500012', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500012');

-- registry:establishment:43210835500020
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2000-07-04'::date, 'Opens a site in Levallois-Perret', 'NVIDIA LTD: Opened 2000-07-04, closed 2002-10-01. Address: CHEZ ATEAC 24 RUE JACQUES IBERT 92300 LEVALLOIS-PERRET', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500020', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500020');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2002-10-01'::date, 'Closes its site in Levallois-Perret', 'NVIDIA LTD: site opened 2000-07-04, closed 2002-10-01.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500020:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500020:closed');

-- registry:establishment:43210835500038
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2002-10-01'::date, 'Opens a site in Levallois-Perret', 'NVIDIA LTD: Opened 2002-10-01, closed 2009-01-12. Address: 53 RUE BAUDIN 92300 LEVALLOIS-PERRET', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500038', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500038');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2009-01-12'::date, 'Closes its site in Levallois-Perret', 'NVIDIA LTD: site opened 2002-10-01, closed 2009-01-12.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500038:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500038:closed');

-- registry:establishment:47997345500013
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2004-12-02'::date, 'Opens a site in Mougins', 'NVIDIA DEVELOPPEMENT FRANCE SAS: Opened 2004-12-02, closed 2005-05-27. Address: ZAC L''ORME E.SPACE BT C 45 ALL DU FONT DE L ORME 06250 MOUGINS', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500013', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500013');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2005-05-27'::date, 'Closes its site in Mougins', 'NVIDIA DEVELOPPEMENT FRANCE SAS: site opened 2004-12-02, closed 2005-05-27.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500013:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500013:closed');

-- registry:establishment:47997345500021
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2005-05-27'::date, 'Opens a site in Valbonne', 'NVIDIA DEVELOPPEMENT FRANCE SAS: Opened 2005-05-27, closed 2006-09-01. Address: LES DEUX ARCS BAT B 1800 ROUTE DES CRETES 06560 VALBONNE', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500021', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500021');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2006-09-01'::date, 'Closes its site in Valbonne', 'NVIDIA DEVELOPPEMENT FRANCE SAS: site opened 2005-05-27, closed 2006-09-01.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500021:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500021:closed');

-- registry:establishment:47997345500039
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2006-09-01'::date, 'Opens a site in Valbonne', 'NVIDIA DEVELOPPEMENT FRANCE SAS: Opened 2006-09-01, closed 2016-03-25. Address: WTC4 1300 ROUTE DES CRETES 06560 VALBONNE', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500039', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500039');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2016-03-25'::date, 'Closes its site in Valbonne', 'NVIDIA DEVELOPPEMENT FRANCE SAS: site opened 2006-09-01, closed 2016-03-25.', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500039:closed', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500039:closed');

-- registry:establishment:43210835500046
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2009-01-12'::date, 'Opens a site in Courbevoie', 'NVIDIA LTD: Opened 2009-01-12, open. Address: 8 A 14 - ZAC DANTON 8 AVENUE DE L''ARCHE 92400 COURBEVOIE', 'https://annuaire-entreprises.data.gouv.fr/entreprise/432108355', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:43210835500046', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:43210835500046');

-- registry:establishment:47997345500047
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2016-03-25'::date, 'Opens a site in Biot', 'NVIDIA DEVELOPPEMENT FRANCE SAS: Opened 2016-03-25, open. Address: SOPHIA ANTIPOLIS 400 AVENUE ROUMANILLE 06410 BIOT', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500047', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500047');

-- registry:establishment:47997345500054
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2016-03-25'::date, 'Opens a site in Biot', 'NVIDIA DEVELOPPEMENT FRANCE SAS: Opened 2016-03-25, open. Address: VILLAGE ENTREPRISES GREENSIDE B7 E1 400 AVENUE ROUMANILLE 06410 BIOT', 'https://annuaire-entreprises.data.gouv.fr/entreprise/479973455', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:47997345500054', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:47997345500054');

-- registry:establishment:10911152600017
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'expansion'::event_type, '2026-08-01'::date, 'Opens a site in Abroad', 'NVIDIA SINGAPORE PTE. LTD.: Opened 2026-08-01, open. Address: 3/F HARBOUR VIEW I, SHATIN N.T. 12 SCIENCE PARK EAST AVENUE, HONG K 99  HONG-KONG CHINE', 'https://annuaire-entreprises.data.gouv.fr/entreprise/109111526', 'registry', 'Recherche d''entreprises (INSEE/INPI)', 'high', 'atlas:entity:nvidia', 'registry:establishment:10911152600017', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'registry:establishment:10911152600017');

-- registry:legal_entity:109111526
INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, naf_code, country, is_primary, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'NVIDIA SINGAPORE PTE. LTD.', '109111526', '2026-08-01'::date, '62.01Z', 'France', FALSE, 'high', 'atlas:entity:nvidia', 'registry:legal_entity:109111526', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM legal_entities WHERE siren = '109111526');

-- bodacc:legal_notice:B2011020677
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'rebrand'::event_type, '2011-10-23'::date, 'Modifications diverses: NVIDIA Developpement France SAS', 'Modification de l''adresse du siège. Modification de la forme juridique. Modification de la dénomination. Modification de représentant.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B2011020677', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B2011020677', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B2011020677');

-- bodacc:legal_notice:A20160090122
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2016-05-06'::date, 'Immatriculations: NVIDIA Development France SAS', 'Immatriculation suite à transfert de son siège social hors ressort.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:A20160090122', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:A20160090122', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:A20160090122');

-- bodacc:legal_notice:B20160090107
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2016-05-06'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Transfert de l''établissement principal', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20160090107', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20160090107', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20160090107');

-- bodacc:legal_notice:B201601612192
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2016-08-18'::date, 'Modifications diverses: NVIDIA LTD', 'Modification de représentant..', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201601612192', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B201601612192', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B201601612192');

-- bodacc:legal_notice:B201800293684
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2018-02-11'::date, 'Modifications diverses: NVIDIA LTD', 'Modification de représentant.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800293684', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B201800293684', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B201800293684');

-- bodacc:legal_notice:B2019004388
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2019-03-01'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B2019004388', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B2019004388', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B2019004388');

-- bodacc:legal_notice:B202100075812
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2021-01-12'::date, 'Modifications diverses: NVIDIA LTD', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202100075812', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B202100075812', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202100075812');

-- bodacc:legal_notice:B20210013201
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2021-01-20'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20210013201', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20210013201', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20210013201');

-- bodacc:legal_notice:B20220034216
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2022-02-17'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20220034216', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20220034216', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20220034216');

-- bodacc:legal_notice:B20220043155
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2022-03-02'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20220043155', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20220043155', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20220043155');

-- bodacc:legal_notice:B20220066161
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2022-04-03'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20220066161', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20220066161', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20220066161');

-- bodacc:legal_notice:B20240045185
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2024-03-05'::date, 'Modifications diverses: NVIDIA Development France SAS', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B20240045185', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B20240045185', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B20240045185');

-- bodacc:legal_notice:B202600678278
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2026-04-07'::date, 'Modifications diverses: NVIDIA LTD', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202600678278', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B202600678278', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202600678278');

-- bodacc:legal_notice:B202600882626
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2026-05-09'::date, 'Modifications diverses: NVIDIA LTD', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202600882626', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B202600882626', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202600882626');

-- bodacc:legal_notice:B202601642337
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2026-08-28'::date, 'Modifications diverses: NVIDIA LTD', 'Modification survenue sur l''administration.', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B202601642337', 'official_gazette', 'BODACC (Bulletin officiel des annonces civiles et commerciales)', 'high', 'atlas:entity:nvidia', 'bodacc:legal_notice:B202601642337', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'bodacc:legal_notice:B202601642337');

-- lobbying:lobbying_client:client:2015:432108355
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'nvidia'), 'other'::event_type, '2022-02-25'::date, 'AMERICAIN CHAMBER OF COMMERC lists NVIDIA LTD as a client or member', 'Association; added 25-02-2022 18:19.', 'https://www.hatvp.fr/fiche-organisation/?organisation=784357329', 'registry', 'HATVP lobbying register (répertoire des représentants d''intérêts)', 'high', 'atlas:entity:nvidia', 'lobbying:lobbying_client:client:2015:432108355', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'lobbying:lobbying_client:client:2015:432108355');

-- hal:research_paper:hal-05869841
INSERT INTO articles (id, title, url, source_name, published_date, summary, language, created_at, updated_at)
SELECT uuid_generate_v4(), 'Validating traces of distributed programs against TLA+ specifications', 'https://inria.hal.science/hal-05869841v1', 'HAL (research paper)', '2026-01-01'::date, 'journal article by Horatiu Cirstea, Markus A Kuppe, Benjamin Loillier, Stephan Merz. With: Nvidia Corporation [Santa Clara].', 'en', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE url = 'https://inria.hal.science/hal-05869841v1');
INSERT INTO article_organizations (id, article_id, organization_id, created_at)
SELECT uuid_generate_v4(), a.id, (SELECT id FROM organizations WHERE slug = 'nvidia'), NOW() FROM articles a WHERE a.url = 'https://inria.hal.science/hal-05869841v1' AND (SELECT id FROM organizations WHERE slug = 'nvidia') IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM article_organizations x WHERE x.article_id = a.id AND x.organization_id = (SELECT id FROM organizations WHERE slug = 'nvidia'));

COMMIT;
