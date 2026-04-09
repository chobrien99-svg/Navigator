-- SIREN updates from web scraping
-- Review before running!

-- DiappyMed (from https://diappymed.com/en/mentions-legales)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'DiappyMed', '893114405', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'diappymed'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '893114405');

-- Cleavr (from https://www.cleavr.fr/en)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'Cleavr', '989360615', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug = 'cleavr'
AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '989360615');

