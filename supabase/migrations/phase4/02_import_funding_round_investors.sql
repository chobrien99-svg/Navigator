-- =============================================================================
-- PHASE 4 - IMPORT: Funding Round Investors
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
-- Same process: export from Funding Tracker, strip wrapper, paste with $$...$$.
--
-- IMPORTANT: Run AFTER funding_rounds have been imported.
--
-- Mapping: investor_id → maps to organizations (type=investor) via legacy_id
-- Since investor IDs from the Funding Tracker were NOT preserved as
-- organization IDs (investors got new UUIDs), we need to look them up
-- via the organization_merge_map.
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                   UUID,
    funding_round_id     UUID,
    investor_id          UUID,
    is_lead              BOOLEAN,
    investment_amount_eur NUMERIC,
    created_at           TIMESTAMPTZ
  )
),
mapped AS (
  SELECT
    s.id,
    s.funding_round_id,
    omm.organization_id AS investor_org_id,
    s.is_lead,
    s.investment_amount_eur,
    s.created_at
  FROM source_data s
  JOIN organization_merge_map omm
    ON omm.source_db = 'funding_tracker'
    AND omm.source_table = 'investors'
    AND omm.source_id = s.investor_id::TEXT
)
INSERT INTO funding_round_investors (
  funding_round_id,
  investor_id,
  is_lead,
  investment_amount_eur,
  created_at
)
SELECT
  m.funding_round_id,
  m.investor_org_id,
  COALESCE(m.is_lead, FALSE),
  m.investment_amount_eur,
  COALESCE(m.created_at, NOW())
FROM mapped m
WHERE EXISTS (SELECT 1 FROM funding_rounds WHERE id = m.funding_round_id)
ON CONFLICT (funding_round_id, investor_id) DO NOTHING;

-- Verify
SELECT COUNT(*) AS funding_round_investors_imported FROM funding_round_investors;
