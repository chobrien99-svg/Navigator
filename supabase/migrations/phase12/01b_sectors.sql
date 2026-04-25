CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 2: Create sectors that don't exist yet (29)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "AgriTech"}, {"name": "Artificial Intelligence"}, {"name": "BioTech"}, {"name": "CleanTech"}, {"name": "ClimateTech"}, {"name": "Cybersecurity"}, {"name": "DeepTech"}, {"name": "DefenseTech"}, {"name": "Drones"}, {"name": "E-commerce & Retail"}, {"name": "Energy"}, {"name": "Entertainment"}, {"name": "FinTech"}, {"name": "FoodTech"}, {"name": "Gaming"}, {"name": "Hardware"}, {"name": "HealthTech"}, {"name": "InsurTech"}, {"name": "LegalTech"}, {"name": "MarTech"}, {"name": "MedTech"}, {"name": "Mobility"}, {"name": "Other"}, {"name": "PropTech"}, {"name": "Robotics"}, {"name": "SaaS"}, {"name": "SpaceTech & Aerospace"}, {"name": "TravelTech"}, {"name": "Web3"}]$json$
  ) AS (name TEXT)
)
INSERT INTO sectors (id, name, slug, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
