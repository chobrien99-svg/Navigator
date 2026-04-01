-- =============================================================================
-- PEOPLE DATA CLEANUP - Run in the FUNDING TRACKER SQL Editor
-- =============================================================================
-- Run these in order. Review flagged records manually before proceeding.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 1: Strip trailing commas
-- e.g. "Adrien Plat," → "Adrien Plat"
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE people
SET full_name = rtrim(full_name, ','),
    updated_at = NOW()
WHERE full_name LIKE '%,';

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 2: Strip parenthetical suffixes (role/title info)
-- e.g. "Alex Haag (CEO, ex-Tesla Autopilot lead)" → "Alex Haag"
-- Only when the parenthetical is at the END and the part before it
-- looks like a real name (2-4 words, no commas).
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE people
SET full_name = trim(regexp_replace(full_name, '\s*\([^)]+\)\s*$', '')),
    updated_at = NOW()
WHERE full_name ~ '\([^)]+\)\s*$'
  AND trim(regexp_replace(full_name, '\s*\([^)]+\)\s*$', '')) !~ ','
  AND array_length(string_to_array(trim(regexp_replace(full_name, '\s*\([^)]+\)\s*$', '')), ' '), 1) BETWEEN 2 AND 5;

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 3: Strip trailing descriptive text after semicolons
-- e.g. "Bénédicte Astier (Founder & CEO; former Quality Manager at bioMérieux)."
-- Already handled by CLEANUP 2 for most cases, but catch trailing periods too
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE people
SET full_name = rtrim(trim(full_name), '.'),
    updated_at = NOW()
WHERE full_name LIKE '%.';

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 4: Delete non-person entities (orgs/institutions stored as people)
-- Review this list first — these are records that are clearly NOT individual
-- people. They will be DELETED from the people table.
-- ─────────────────────────────────────────────────────────────────────────────

-- First, REVIEW what will be deleted:
SELECT id, full_name FROM people
WHERE id IN (
  '2b22984d-61cf-499b-ac98-1bec728d5e59',  -- "Inria), and 12 co-founders from the scikit-learn community"
  'a3f2ee85-54b6-48a6-b575-72c7b16fd84f',  -- "Institut Imagine, and Sygnature Discovery"
  'a0df49e4-2550-4bc6-8f71-f5722ee5400b',  -- "Quable, deeptech startups)"
  'cfee338e-6b78-4308-bfff-e26ab2090465',  -- "Eliud Kipchoge, and the NN Running Team"
  '7874015e-cf70-4692-af2c-e6969581b59e',  -- "Team of eight robotics experts..."
  '87e2aa81-6b7a-4e1d-ac3d-c5c7a3302629'   -- "Universal Music) and Thomas Quenoil"
);

-- Uncomment to delete after reviewing:
-- DELETE FROM people WHERE id IN (
--   '2b22984d-61cf-499b-ac98-1bec728d5e59',
--   'a3f2ee85-54b6-48a6-b575-72c7b16fd84f',
--   'a0df49e4-2550-4bc6-8f71-f5722ee5400b',
--   'cfee338e-6b78-4308-bfff-e26ab2090465',
--   '7874015e-cf70-4692-af2c-e6969581b59e',
--   '87e2aa81-6b7a-4e1d-ac3d-c5c7a3302629'
-- );

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 5: Delete "PhD" placeholder records (no actual name)
-- ─────────────────────────────────────────────────────────────────────────────

-- First, REVIEW what will be deleted:
SELECT id, full_name FROM people
WHERE full_name LIKE 'PhD%'
  AND full_name NOT LIKE 'PhD%:%'  -- keep if there's a name after a colon
  AND length(regexp_replace(full_name, '\s*\(.*$', '')) <= 5;

-- Uncomment to delete after reviewing:
-- DELETE FROM people WHERE id IN (
--   '82660618-6289-4fbc-ab8b-7ddcb76c5f77',  -- "PhD (CEO & co-founder); based on research of Stéphane Bach"
--   '804825a5-2b07-4fe5-b7e1-8b9219f42543',  -- "PhD (Founder & CEO) — cryptography expert..."
--   'cbe2a04f-259e-40d9-9da6-737f97e4893f',  -- "PhD (Scientific Director & Partner)"
--   '6ac0756b-5609-44ff-a832-f92557d0ae4d'   -- "PhD; Marie-Thérèse Dimanche-Boitrel..."
-- );

-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP 6: Delete LinkedIn URL garbage records
-- These have LinkedIn URLs instead of names. The actual names are embedded
-- in the URLs but would need manual extraction.
-- ─────────────────────────────────────────────────────────────────────────────

-- First, REVIEW what will be deleted:
SELECT id, full_name FROM people
WHERE full_name LIKE 'https://%';

-- Uncomment to delete after reviewing:
-- DELETE FROM people WHERE full_name LIKE 'https://%';


-- =============================================================================
-- RECORDS THAT NEED MANUAL REVIEW
-- =============================================================================
-- The following records have MULTIPLE PEOPLE in one field. They need to be
-- split into separate records and linked to the correct company.
--
-- For now, we recommend migrating them as-is and cleaning up in the unified
-- DB later, OR cleaning them up here first if your team has bandwidth.
-- =============================================================================

SELECT id, full_name FROM people
WHERE full_name ~ ','
  AND id NOT IN (
    -- Exclude already-handled non-person records
    '2b22984d-61cf-499b-ac98-1bec728d5e59',
    'a3f2ee85-54b6-48a6-b575-72c7b16fd84f',
    'a0df49e4-2550-4bc6-8f71-f5722ee5400b',
    'cfee338e-6b78-4308-bfff-e26ab2090465'
  )
  AND full_name NOT LIKE 'https://%'
  AND full_name NOT LIKE 'PhD%'
ORDER BY full_name;
-- These ~40 records contain multiple people separated by commas.
-- Options:
--   A) Split each into separate people records now (cleanest)
--   B) Migrate as-is and split later in the unified DB
--   C) Leave the first name, strip everything after the first comma
