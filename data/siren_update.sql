-- SIREN updates from web scraping
-- Review before running!

-- DiappyMed (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DiappyMed', '893114405', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'diappymed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '893114405');

-- Cleavr (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Cleavr', '989360615', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cleavr'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '989360615');

-- Topograph (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Topograph', '932884117', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'topograph'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '932884117');

-- Drinkee (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Drinkee', '917500126', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'drinkee'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '917500126');

-- Aerix Systems (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Aerix Systems', '889844510', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'aerix-systems'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '889844510');

-- Leviathan Dynamics (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Leviathan Dynamics', '824215537', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'leviathan-dynamics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '824215537');

-- SCorp-io (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'SCorp-io', '904328234', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'scorp-io'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '904328234');

-- Metavonics (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Metavonics', '902658376', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'metavonics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '902658376');

-- Escape (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Escape', '888699584', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'escape'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '888699584');

-- Santexpat (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Santexpat', '788571834', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'santexpat'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '788571834');

-- Heliup (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Heliup', '919555938', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'heliup'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '919555938');

-- Calogena (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Calogena', '908713043', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'calogena'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '908713043');

-- Fairglow (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Fairglow', '953334455', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'fairglow'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '953334455');

-- K-Motors (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'K-Motors', '850505744', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'k-motors'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '850505744');

-- Solaya (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Solaya', '928050343', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'solaya'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '928050343');

-- 4Moving Biotech (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, '4Moving Biotech', '537407926', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = '4moving-biotech'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '537407926');

-- Vizzia (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Vizzia', '899832901', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'vizzia'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '899832901');

-- Skydrone Robotics (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Skydrone Robotics', '821433893', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'skydrone-robotics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '821433893');

-- hummingbirds (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'hummingbirds', '914539366', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'hummingbirds'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '914539366');

-- DentalMonitoring (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DentalMonitoring', '824001259', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dentalmonitoring'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '824001259');

-- Mecaware (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Mecaware', '892414566', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'mecaware'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '892414566');

-- Meelo (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Meelo', '829051317', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'meelo'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '829051317');

-- Desk (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Desk', '899774087', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'desk'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '899774087');

-- MadeForMed (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'MadeForMed', '419632286', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'madeformed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '419632286');

-- Newable (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Newable', '984815498', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'newable'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '984815498');

-- Bobine (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Bobine', '510909807', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'bobine'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '510909807');

-- Viti-Tunnel (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Viti-Tunnel', '931417489', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'viti-tunnel'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '931417489');

-- DermaScan (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DermaScan', '939721817', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'dermascan'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '939721817');

-- Sailiz (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Sailiz', '952461689', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'sailiz'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '952461689');

-- BW Ideol (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'BW Ideol', '524724820', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'bw-ideol'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '524724820');

-- checkDPE (from None)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'checkDPE', '938757325', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'checkdpe'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '938757325');

-- Geolinks Services (from https://geolinks-services.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Geolinks Services', '880788054', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'geolinks-services'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '880788054');

-- Lexip (from https://www.lexip.co/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Lexip', '425010451', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lexip-formerly-pixminds'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '425010451');

-- ROB OCC (from https://www.robocc.fr/politique-de-confidentialite)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'ROB OCC', '953653508', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'robocc'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '953653508');

-- Keria (from https://keria.tech/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Keria', '431303775', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'keria-formerly-cezam'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '431303775');

-- Ray Studios (from https://www.ray-studios.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Ray Studios', '901049767', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'ray-studios'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '901049767');

-- Drive Innov (from https://www.drive-innov.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Drive Innov', '808557797', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'drive-innov'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '808557797');

-- GetMint (from https://getmint.ai/privacy-policy)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'GetMint', '939664660', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'getmint'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '939664660');

-- Arcads.ai (from https://www.arcads.ai/terms)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Arcads.ai', '832905327', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'arcadsai'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '832905327');

-- Monomeris Chemicals (from https://monomeris-chemicals.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Monomeris Chemicals', '851618215', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'monomeris-chemicals'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '851618215');

-- Innerskin (from https://www.innerskin.com/cgu)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Innerskin', '913124368', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'innerskin'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '913124368');

-- ReGeneration (from https://regeneration.eu/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'ReGeneration', '901104463', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'regeneration'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '901104463');

-- Hoora (from https://www.hooragames.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Hoora', '883336216', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'hoora'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '883336216');

-- NOLT (from https://www.wearenolt.com/en/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'NOLT', '889027918', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'nolt'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '889027918');

-- Goud (from https://www.goudsante.fr/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Goud', '951670322', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'goud'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '951670322');

-- Komu (from https://www.komu.eu/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Komu', '978009017', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'komu-ex-contestio'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '978009017');

-- Kotcha (from https://www.kotcha.com/privacy-policy)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Kotcha', '943460865', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'kotcha'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '943460865');

-- vebo (from https://www.vebo.eco/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'vebo', '927854737', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'vebo'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '927854737');

-- MNGRS.AI (from https://www.mngrs.ai/cgu)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'MNGRS.AI', '921180402', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'mngrsai'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '921180402');

-- Ficha (from https://ficha.fr/en/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Ficha', '881734800', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'ficha'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '881734800');

-- MyFit Solutions (from https://myfit-solutions.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'MyFit Solutions', '837707769', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'myfit-solutions'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '837707769');

-- Carsup (from https://www.carsup.io/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Carsup', '851614594', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'carsup'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '851614594');

-- Elmut (from https://elmut.fr/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Elmut', '835009325', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'elmut'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '835009325');

-- HappyVore (from https://happyvore.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'HappyVore', '880710223', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'happyvore'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '880710223');

-- Nabla (from https://www.nabla.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Nabla', '838878155', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'nabla'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '838878155');

-- Epsor (from https://www.epsor.fr)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Epsor', '832966956', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'epsor'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '832966956');

-- Didask (from https://www.didask.com/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Didask', '808859276', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'didask'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '808859276');

