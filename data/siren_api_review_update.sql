-- SIREN updates from manually reviewed siren_api_review.csv
-- 9 confirmed matches from medium-confidence API results

-- May Health → MAY HEALTH (MAY HEALTH) (confidence: 0.6)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'May Health', '831705751', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'may-health'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '831705751');

-- Revox → REVOX GMBH (confidence: 0.66)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Revox', '994346021', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'revox'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '994346021');

-- Aviwell → AVIWELL 3000 (confidence: 0.64)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Aviwell', '813632247', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'aviwell'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '813632247');

-- LaFraise → LES LAFRAISE (confidence: 0.78)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'LaFraise', '934850561', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lafraise'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '934850561');

-- UP&CHARGE → UP CHARGES DOWM (confidence: 0.62)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'UP&CHARGE', '902281823', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'upcharge'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '902281823');

-- Lifeaz → LIFEAZ (LIFE) (confidence: 0.7)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Lifeaz', '814042958, 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'lifeaz'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '814042958');

-- Cellura → MARC CELLURA (confidence: 0.69)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Cellura', '917498362', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cellura-formerly-softcell-therapeutics'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '917498362');

-- Skyld AI → SKYLD (confidence: 0.81)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Skyld AI', '977899020', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'skyld-ai'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '977899020');
