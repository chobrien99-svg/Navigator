-- =============================================================================
-- Attach extra Hekat Fluidics angels to its existing seed round
-- =============================================================================
-- The August 14, 2026 coverage of Hekat Fluidics (Journal des entreprises)
-- named a fuller list of business angels than the original week-4 import
-- (funding_deals_july_2026_week4). Hervé Ariditty and Nicolas Kompalitch were
-- already linked; this migration adds the four additional named angels to the
-- SAME existing EUR 2.4M seed round (it does NOT create a new round -- that
-- would double-count the raise).
--
-- Added angels (recorded as individual investors, matching the week-4
-- convention of plain personal names):
--   Stéphane Guinet (Kamet), Stéphane Ifker (Batigram Invest),
--   Eric Mestre, Myriam Mestre.
-- Idempotent: existing investor orgs and links are left untouched.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: Ensure the four angel investor organizations exist
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Stéphane Guinet" },
      { "name": "Stéphane Ifker" },
      { "name": "Eric Mestre" },
      { "name": "Myriam Mestre" }
]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  'funding_deals_august_2026',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 2: Link them to Hekat Fluidics' existing week-4 seed round (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "investor_name": "Stéphane Guinet" },
      { "investor_name": "Stéphane Ifker" },
      { "investor_name": "Eric Mestre" },
      { "investor_name": "Myriam Mestre" }
]$json$
  ) AS (investor_name TEXT)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  fr.id,
  inv.id,
  FALSE,
  s.investor_name,
  NOW()
FROM source s
JOIN organizations o ON o.slug = 'hekat-fluidics'
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_july_2026_week4'
JOIN organizations inv ON inv.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
WHERE NOT EXISTS (
  SELECT 1 FROM funding_round_investors fri
  WHERE fri.funding_round_id = fr.id AND fri.investor_id = inv.id
);

-- =============================================================================
-- Verification
-- =============================================================================
SELECT string_agg(fri.investor_name, ' | ' ORDER BY fri.investor_name) AS investors, COUNT(*) AS count
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
JOIN organizations o ON o.id = fr.organization_id
WHERE o.slug = 'hekat-fluidics' AND fr.source_name = 'funding_deals_july_2026_week4';
