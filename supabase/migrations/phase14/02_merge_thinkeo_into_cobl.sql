-- =============================================================================
-- Merge Thinkeo → Cobl.ai
-- =============================================================================
-- Cobl.ai is the renamed Thinkeo (confirmed by the April 2026 funding news:
-- "Originally launched as Thinkeo"). Thinkeo entered the DB via the 2023
-- funding-deals import; Cobl.ai via phase14/01 (April 2026 batch 2).
--
-- Keep the current name (cobl-ai) and fold Thinkeo's history (its 2023
-- round, sector/program/relationship links, etc.) into it, then delete the
-- Thinkeo org. Uses the merge_organizations() helper from
-- phase12/04_merge_duplicate_orgs.sql.
--
-- Idempotent: no-op if 'thinkeo' has already been merged/removed.
-- =============================================================================

SELECT merge_organizations('thinkeo', 'cobl-ai') AS result;
