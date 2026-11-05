-- Phase 37: Merge duplicate investor "Heartcore" (slug: heartcore) into
-- "Heartcore Capital" (slug: heartcore-capital).
--
-- "Heartcore" held 2 funding_round_investors rows (after the Zefir fix moved its
-- third) and 1 organization_merge_map row; no other references. No round listed
-- both records, so no duplicate investor rows are created.
--
-- Applied to production via Supabase MCP on 2026-11-05.

BEGIN;
UPDATE funding_round_investors
   SET investor_id = '927ef9cc-9f8e-4ddf-8578-f20d7db14247', investor_name = 'Heartcore Capital'
 WHERE investor_id = 'e2116af2-7c5a-4823-a54c-649d36027170';

UPDATE organization_merge_map
   SET organization_id = '927ef9cc-9f8e-4ddf-8578-f20d7db14247'
 WHERE organization_id = 'e2116af2-7c5a-4823-a54c-649d36027170';

DELETE FROM organizations WHERE id = 'e2116af2-7c5a-4823-a54c-649d36027170'; -- Heartcore
COMMIT;
