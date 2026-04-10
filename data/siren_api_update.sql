-- SIREN updates from recherche-entreprises API
-- 65 high-confidence matches (confidence >= 0.85)

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

-- Kestra → KESTRA TECHNOLOGIES (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Kestra', '900427873', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'kestra'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '900427873');

-- AI6 Technologies → AI6 TECHNOLOGIES (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'AI6 Technologies', '938439742', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'ai6-technologies'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '938439742');

-- Hynaero → HYNAERO (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Hynaero', '980145049', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'hynaero'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '980145049');

-- Homaio → HOMAIO (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Homaio', '923522338', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'homaio'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '923522338');

-- Parallel → PARALLEL (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Parallel', '914557103', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'parallel'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '914557103');

-- Lemrock → LEMROCK AI (confidence: 0.88)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Lemrock', '995358173', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lemrock'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '995358173');

-- Archimed → ARCHIMED (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Archimed', '519635999', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'archimed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '519635999');

-- THE 8 IMPACT → THE 8 IMPACT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'THE 8 IMPACT', '899646038', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'the-8-impact'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '899646038');

-- Getinside → GETINSIDE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Getinside', '913526877', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'getinside'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '913526877');

-- Linkeat → LINKEAT (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Linkeat', '821580990', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'linkeat'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '821580990');

-- Eclore → ECLORE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Eclore', '402529374', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'eclore'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '402529374');

-- PGP Farmer → PGP FARMER (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'PGP Farmer', '911033983', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'pgp-farmer'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '911033983');

-- Stairling → STAIRLING TECHNOLOGIES (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Stairling', '927854141', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'stairling'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '927854141');

-- PRESAGE → PRESAGE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'PRESAGE', '488353673', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'presage'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '488353673');

-- newcleo → NEWCLEO (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'newcleo', '929009140', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'newcleo'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '929009140');

-- Atlas V Group → ATLAS (confidence: 0.93)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Atlas V Group', '838987758', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'atlas-v-group'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '838987758');

-- Linkup → LINKUP (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Linkup', '512532482', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'linkup'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '512532482');

-- Annette → ANNETTE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Annette', '933867483', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'annette'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '933867483');

-- Upway → UPWAY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Upway', '904972536', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'upway'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '904972536');

-- Dialog → DIALOG (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Dialog', '437956485', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dialog'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '437956485');

-- Tsuga → TSUGA (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Tsuga', '750314429', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'tsuga'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '750314429');

-- Initiativ → INITIATIV (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Initiativ', '987788965', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'initiativ'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '987788965');

-- Loft Orbital → LOFT ORBITAL TECHNOLOGIES (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Loft Orbital', '878678051', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'loft-orbital'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '878678051');

-- ScorePlay → SCOREPLAY (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'ScorePlay', '841118375', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'scoreplay'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '841118375');

-- Formance → FORMANCE (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Formance', '409983756', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'formance'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '409983756');

-- Qomon → QOMONS (confidence: 0.93)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Qomon', '889601506', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'qomon'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '889601506');

-- Fabriq → FABRIQ (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Fabriq', '851998476', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'fabriq'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '851998476');

-- Underdog → UNDERDOG (confidence: 1.0)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Underdog', '849998646', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'underdog'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '849998646');

