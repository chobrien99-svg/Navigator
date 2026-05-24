-- =============================================================================
-- Dedupe within-batch duplicate funding_rounds for the 2022 Crunchbase import
-- =============================================================================
-- The Crunchbase export contained ~20 rows duplicated on
-- (organization, announced_date, amount). The 01g insert's WHERE NOT EXISTS
-- guard only checks committed rows, so identical rows within the same
-- INSERT batch could both land. This keeps the earliest-created row per
-- (organization_id, source_name, announced_date, amount_eur) group and
-- deletes the rest. funding_round_investors rows cascade-delete with the
-- removed rounds; the surviving round retains its own investor links.
--
-- Scoped to source_name = 'funding_deals_2022_crunchbase' so it can't touch
-- any other batch. Idempotent — re-running finds nothing once clean.
-- =============================================================================

DELETE FROM funding_rounds fr
USING (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY organization_id, source_name, announced_date, amount_eur
           ORDER BY created_at, id
         ) AS rn
  FROM funding_rounds
  WHERE source_name = 'funding_deals_2022_crunchbase'
) d
WHERE fr.id = d.id
  AND d.rn > 1;
