-- Phase 28: De-duplicate the Jay&Joy EUR2M round
--
-- After the phase-27 merge, Jay&Joy (org 9f462d5a-fb0d-4f72-beaf-cc34bdacb93d)
-- carried two EUR2M rounds that represent the same raise:
--   KEEP  54a51326 - stage seed,  2026-03-20 (4 investors, no lead)
--   DROP  ca4fdb3f - stage other, 2025-01-01 (3 investors incl. the only lead)
-- Their investor sets were disjoint, so the 3 links (incl. the lead) are moved
-- onto the kept round first, then the duplicate round is deleted. Result: one
-- EUR2M seed round with all 7 investors and the lead flag preserved.
--
-- NOTE: the DELETE is run manually in the Supabase SQL editor (times out over MCP).

BEGIN;

UPDATE funding_round_investors fi
   SET funding_round_id = '54a51326-e494-4da8-be76-34e245638ea5'
 WHERE fi.funding_round_id = 'ca4fdb3f-da10-4a02-b51b-cc4a4d2e43df'
   AND NOT EXISTS (SELECT 1 FROM funding_round_investors f2
                    WHERE f2.funding_round_id = '54a51326-e494-4da8-be76-34e245638ea5'
                      AND f2.investor_id = fi.investor_id);

COMMIT;

-- Run in the Supabase SQL editor:
DELETE FROM funding_rounds WHERE id = 'ca4fdb3f-da10-4a02-b51b-cc4a4d2e43df'; -- duplicate Jay&Joy EUR2M round
