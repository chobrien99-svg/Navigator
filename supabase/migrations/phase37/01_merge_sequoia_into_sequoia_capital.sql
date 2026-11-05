-- Phase 37: Merge duplicate investor "Sequoia" (slug: sequoia) into "Sequoia Capital"
-- (slug: sequoia-capital).
--
-- The "Sequoia" record held 5 funding_round_investors rows (Dust Series B 2026,
-- Wilgo pre-seed 2025, Grace seed 2025, Pennylane growth 2025 [lead], HELICEO
-- seed 2016 -- HELICEO confirmed by editor) and 1 organization_merge_map row.
-- No round listed both records, so no duplicate investor rows are created.
-- Sequoia Arc and the Sequoia Scout records are intentionally left separate.
--
-- Applied to production via Supabase MCP on 2026-11-05.

BEGIN;
UPDATE funding_round_investors
   SET investor_id = '91cf3f66-6ceb-4385-a910-51a2e232c934', investor_name = 'Sequoia Capital'
 WHERE investor_id = '7053536b-6763-4134-a184-6514e784e8ca';

UPDATE organization_merge_map
   SET organization_id = '91cf3f66-6ceb-4385-a910-51a2e232c934'
 WHERE organization_id = '7053536b-6763-4134-a184-6514e784e8ca';

DELETE FROM organizations WHERE id = '7053536b-6763-4134-a184-6514e784e8ca'; -- Sequoia
COMMIT;
