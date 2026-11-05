-- Phase 37: Zefir funding rounds -- editor-confirmed corrections (2026-11-05).
--
-- Additive only (editor chose not to remove existing investors):
--   * Seed 2021-04: add Xavier Niel
--   * Sept 2025 EUR15M round: stage series_b -> growth (it was showing as a
--     second Series B); add Fintech Collective, FJ Labs, Zigg Capital,
--     TX Ventures; re-point "Heartcore" row to the main "Heartcore Capital" record.
-- Series A (2022-02) and Series B (2024-04) already contained the confirmed investors.
--
-- Applied to production via Supabase MCP on 2026-11-05.

BEGIN;
INSERT INTO funding_round_investors (funding_round_id, investor_id, investor_name, is_lead) VALUES
 ('8cddc95b-a24d-475c-af98-c13d0dcb94a8','332530f8-1a52-4071-a333-dc9f209d3850','Xavier Niel',false),
 ('9ea743ea-30ad-481a-b11a-273c605febec','2913e539-e883-435d-98d4-d4c7942b763f','Fintech Collective',false),
 ('9ea743ea-30ad-481a-b11a-273c605febec','c177f783-e6c1-47c5-9eaa-54c68a253319','FJ Labs',false),
 ('9ea743ea-30ad-481a-b11a-273c605febec','f93345c7-bbf5-43a7-807f-71b51bb50311','Zigg Capital',false),
 ('9ea743ea-30ad-481a-b11a-273c605febec','c2ad5823-51d9-46cc-99e3-6dd72ca5eec7','TX Ventures',false);

UPDATE funding_round_investors
   SET investor_id = '927ef9cc-9f8e-4ddf-8578-f20d7db14247', investor_name = 'Heartcore Capital'
 WHERE id = '3833e13d-8ab7-4dc0-af73-8a7887af290e';

UPDATE funding_rounds SET stage = 'growth', updated_at = now()
 WHERE id = '9ea743ea-30ad-481a-b11a-273c605febec';
COMMIT;
