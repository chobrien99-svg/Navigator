CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 4: Create legal_entities for orgs with SIREN (8)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "Dailyn", "siren": "450057732"}, {"name": "Wooskill", "siren": "890866338"}, {"name": "Thess", "siren": "892264672"}, {"name": "L3V3L", "siren": "890344708"}, {"name": "Artpoint", "siren": "878270537"}, {"name": "Delta Business School", "siren": "913685798"}, {"name": "JNPR Spirits", "siren": "880814033"}, {"name": "Superindep", "siren": "843747734"}]$json$
  ) AS (name TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  o.id,
  s.name,
  s.siren,
  'France',
  TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);
