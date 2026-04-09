-- SIREN updates from web scraping (mentions legales)
-- 28 valid Luhn-checked SIRENs found

-- 4Moving Biotech
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, '4Moving Biotech', '537407926', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = '4moving-biotech'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '537407926');

-- Aerix Systems
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Aerix Systems', '889844510', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'aerix-systems'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '889844510');

-- Bobine
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Bobine', '510909807', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'bobine'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '510909807');

-- Calogena
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Calogena', '908713043', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'calogena'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '908713043');

-- Cleavr
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Cleavr', '989360615', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cleavr'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '989360615');

-- DentalMonitoring
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DentalMonitoring', '824001259', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dentalmonitoring'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '824001259');

-- DermaScan
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DermaScan', '939721817', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dermascan'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '939721817');

-- Desk
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Desk', '899774087', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'desk'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '899774087');

-- DiappyMed
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DiappyMed', '893114405', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'diappymed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '893114405');

-- Drinkee
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Drinkee', '917500126', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'drinkee'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '917500126');

-- Escape
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Escape', '888699584', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'escape'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '888699584');

-- Fairglow
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Fairglow', '953334455', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'fairglow'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '953334455');

-- Heliup
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Heliup', '919555938', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'heliup'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '919555938');

-- K-Motors
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'K-Motors', '850505744', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'k-motors'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '850505744');

-- Leviathan Dynamics
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Leviathan Dynamics', '824215537', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'leviathan-dynamics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '824215537');

-- MadeForMed
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'MadeForMed', '419632286', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'madeformed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '419632286');

-- Mecaware
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Mecaware', '892414566', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'mecaware'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '892414566');

-- Meelo
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Meelo', '829051317', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'meelo'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '829051317');

-- Metavonics
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Metavonics', '902658376', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'metavonics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '902658376');

-- Newable
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Newable', '984815498', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'newable'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '984815498');

-- SCorp-io
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'SCorp-io', '904328234', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'scorp-io'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '904328234');

-- Santexpat
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Santexpat', '788571834', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'santexpat'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '788571834');

-- Skydrone Robotics
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Skydrone Robotics', '821433893', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'skydrone-robotics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '821433893');

-- Solaya
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Solaya', '928050343', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'solaya'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '928050343');

-- Topograph
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Topograph', '932884117', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'topograph'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '932884117');

-- Viti-Tunnel
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Viti-Tunnel', '931417489', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'viti-tunnel'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '931417489');

-- Vizzia
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Vizzia', '899832901', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'vizzia'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '899832901');

-- hummingbirds
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'hummingbirds', '914539366', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'hummingbirds'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '914539366');

