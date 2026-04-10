-- SIREN updates from recherche-entreprises API
-- 38 high-confidence matches (confidence >= 0.85)

-- Omniscient → OMNISCIENT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Omniscient', '985294396', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'omniscient'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '985294396');

-- Kervalion → KERVALION (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Kervalion', '940346729', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'kervalion'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '940346729');

-- Blify → BLIFY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Blify', '941613739', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'blify'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '941613739');

-- games2gether → GAMES2GETHER (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'games2gether', '988435442', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'games2gether'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '988435442');

-- Flotte → FLOTTE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Flotte', '830788311', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'flotte'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '830788311');

-- Jay&Joy → JAY & JOY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Jay&Joy', '809890510', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'jayjoy'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '809890510');

-- Lupin & Holmes → LUPIN & HOLMES (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Lupin & Holmes', '951639186', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lupin-holmes'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '951639186');

-- Nabu → NABU (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Nabu', '753402171', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'nabu'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '753402171');

-- Piston → PISTON (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Piston', '949092068', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'piston'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '949092068');

-- Novacium → NOVACIUM (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Novacium', '915142871', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'novacium'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '915142871');

-- Loamics → LOAMICS (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Loamics', '889707402', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'loamics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '889707402');

-- Bitstack → BITSTACK SAS (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Bitstack', '100244722', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'bitstack'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '100244722');

-- Meteoria → METEORIA (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Meteoria', '993360262', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'meteoria'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '993360262');

-- Advanced Machine Intelligence → ADVANCED MACHINE INTELLIGENCE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Advanced Machine Intelligence', '994675254', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'advanced-machine-intelligence'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '994675254');

-- Waiv → WAIV (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Waiv', '930879580', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'waiv'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '930879580');

-- EGIDE → EGIDE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'EGIDE', '522287689', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'egide'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '522287689');

-- MindDay → MINDDAY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'MindDay', '898335047', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'mindday'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '898335047');

-- Rivage → RIVAGE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Rivage', '940386303', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'rivage'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '940386303');

-- OOrion → OORION (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'OOrion', '888454212', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'oorion'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '888454212');

-- Opus Aerospace → OPUS AEROSPACE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Opus Aerospace', '880887583', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'opus-aerospace'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '880887583');

-- Formel AI → FORMEL AI (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Formel AI', '993939370', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'formel-ai'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '993939370');

-- Alpa → ALPA (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Alpa', '400989042', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'alpa'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '400989042');

-- Ocellus → OCELLUS (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Ocellus', '505149351', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'ocellus'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '505149351');

-- Atlas V Group → ATLAS (confidence: 0.93)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Atlas V Group', '838987758', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'atlas-v-group'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '838987758');

-- Twin → TWIN (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Twin', '381143775', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'twin'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '381143775');

-- ECAIR → ECAIR (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'ECAIR', '533087532', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'ecair'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '533087532');

-- Cube → CUBE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Cube', '751518168', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cube-formerly-cube3'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '751518168');

-- Basalt → BASALT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Basalt', '101150928', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'basalt'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '101150928');

-- CWS → CWS (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'CWS', '518891452', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cws-computed-wing-sails'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '518891452');

-- Diffusely → DIFFUSELY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Diffusely', '800523664', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'diffusely-ex-meero'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '800523664');

-- Vibe → VIBE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Vibe', '447490202', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'vibe'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '447490202');

-- Jint → JINT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Jint', '948651252', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'jint-formerly-mozzaik365'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '948651252');

-- Standing Ovation → STANDING OVATION (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Standing Ovation', '884522582', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'standing-ovation'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '884522582');

-- Lifebloom → LIFEBLOOM (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Lifebloom', '849823240', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lifebloom'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '849823240');

-- Dalma → DALMA (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Dalma', '430348482', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dalma'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '430348482');

-- Riot → RIOT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Riot', '818910168', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'riot'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '818910168');

-- Tomorro → TOMORRO (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Tomorro', '881239800', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'tomorro'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '881239800');

-- Grace → GRACE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Grace', '914099155', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'grace'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '914099155');

