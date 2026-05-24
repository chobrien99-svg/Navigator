-- =============================================================================
-- Cleanup: trim leading/trailing whitespace from text identity fields
-- =============================================================================
-- Idempotent — only updates rows whose value differs after TRIM().
-- Triggered by the "  Laclaree Vision" finding (two leading spaces) but
-- applies the same fix across other identity fields where the value is
-- almost certainly a defect, not intentional.
-- =============================================================================

-- Organizations
UPDATE organizations
SET name = TRIM(name), updated_at = NOW()
WHERE name <> TRIM(name);

-- Legal entities
UPDATE legal_entities
SET legal_name = TRIM(legal_name), updated_at = NOW()
WHERE legal_name <> TRIM(legal_name);

-- People
UPDATE people
SET full_name = TRIM(full_name), updated_at = NOW()
WHERE full_name <> TRIM(full_name);

UPDATE people
SET first_name = TRIM(first_name), updated_at = NOW()
WHERE first_name IS NOT NULL AND first_name <> TRIM(first_name);

UPDATE people
SET last_name = TRIM(last_name), updated_at = NOW()
WHERE last_name IS NOT NULL AND last_name <> TRIM(last_name);

-- Cities
UPDATE cities
SET name = TRIM(name), updated_at = NOW()
WHERE name <> TRIM(name);

-- Sectors
UPDATE sectors
SET name = TRIM(name), updated_at = NOW()
WHERE name <> TRIM(name);

-- Programs (parent + editions)
UPDATE programs
SET name = TRIM(name), updated_at = NOW()
WHERE name <> TRIM(name);

UPDATE program_editions
SET name = TRIM(name), updated_at = NOW()
WHERE name IS NOT NULL AND name <> TRIM(name);
