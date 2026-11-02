-- =====================================================================
-- Phase 35 - Dedup: collapse exact-duplicate legal_entities.
--
-- 379 (organization_id, siren) pairs had the row stored twice (each a
-- 2-row group; both rows share is_primary and enrichment level, so the
-- pair represents one entity recorded twice). Keep one row per pair,
-- delete the other. This also clears most of the "multiple primary"
-- noise, since those duplicates were the cause.
--
-- Survivor per group = most-complete, then primary, then earliest:
--   verification_status present, then siret, then naf_code, then
--   incorporation_date, then is_primary, then earliest created_at, then id.
-- (Within these pairs the first rows are equal, so this reduces to
--  "keep the earliest-created row".)
--
-- Only non-null SIRENs are touched; no table has a foreign key to
-- legal_entities, so no children are orphaned. Set-based and idempotent:
-- re-running finds no duplicates and deletes nothing.
-- Expected: 379 rows deleted (4269 -> 3890).
-- =====================================================================

BEGIN;

WITH ranked AS (
  SELECT id,
    row_number() OVER (
      PARTITION BY organization_id, siren
      ORDER BY (verification_status IS NOT NULL) DESC,
               (siret IS NOT NULL) DESC,
               (naf_code IS NOT NULL) DESC,
               (incorporation_date IS NOT NULL) DESC,
               is_primary DESC,
               created_at ASC,
               id ASC
    ) AS rn
  FROM legal_entities
  WHERE siren IS NOT NULL AND siren <> ''
)
DELETE FROM legal_entities le
USING ranked r
WHERE le.id = r.id AND r.rn > 1;

COMMIT;
