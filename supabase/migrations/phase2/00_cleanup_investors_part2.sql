-- =============================================================================
-- INVESTOR CLEANUP PART 2: Merge name variants into canonical names
-- Run in the FUNDING TRACKER SQL Editor
-- Run AFTER Part 1.
-- =============================================================================
-- For each group: reassign funding_round_investors to the keeper, then delete dupes.
-- Uses a reusable pattern:
--   1. UPDATE funding_round_investors SET investor_id = <keeper> WHERE investor_id IN (<dupes>)
--      with ON CONFLICT handling (delete if the keeper already exists on that round)
--   2. DELETE remaining orphan funding_round_investors
--   3. DELETE the duplicate investor records
-- =============================================================================

-- Helper: For each merge, we first delete funding_round_investors that would
-- conflict (same round + keeper already linked), then update the rest.

-- ─────────────────────────────────────────────────────────────────────────────
-- Elaia: keep db1c7c8a, merge cc9c7b06 (Elaia Partners)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = 'cc9c7b06-32a1-4d41-bdef-50e7060392b4'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'db1c7c8a-b7cf-40dd-866c-e2e60c272ce2');
UPDATE funding_round_investors SET investor_id = 'db1c7c8a-b7cf-40dd-866c-e2e60c272ce2' WHERE investor_id = 'cc9c7b06-32a1-4d41-bdef-50e7060392b4';
DELETE FROM investors WHERE id = 'cc9c7b06-32a1-4d41-bdef-50e7060392b4';

-- ─────────────────────────────────────────────────────────────────────────────
-- Serena: keep 70688fda, merge 5d901bdc (Serena Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '5d901bdc-3e50-4c12-becb-76165954581f'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '70688fda-7d56-4d4f-8322-6ca25fe215b5');
UPDATE funding_round_investors SET investor_id = '70688fda-7d56-4d4f-8322-6ca25fe215b5' WHERE investor_id = '5d901bdc-3e50-4c12-becb-76165954581f';
DELETE FROM investors WHERE id = '5d901bdc-3e50-4c12-becb-76165954581f';

-- ─────────────────────────────────────────────────────────────────────────────
-- Sofinnova: keep a486d3ec, merge b2687eb4 (Sofinnova Partners)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = 'b2687eb4-37ab-41c3-9aa5-f05fba40cd42'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'a486d3ec-6d91-4c05-958c-8d243bdd670b');
UPDATE funding_round_investors SET investor_id = 'a486d3ec-6d91-4c05-958c-8d243bdd670b' WHERE investor_id = 'b2687eb4-37ab-41c3-9aa5-f05fba40cd42';
DELETE FROM investors WHERE id = 'b2687eb4-37ab-41c3-9aa5-f05fba40cd42';

-- ─────────────────────────────────────────────────────────────────────────────
-- ISAI: keep 98bc002a, merge f4b6a89c, 0b974bb0, d2e6671e
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id IN ('f4b6a89c-bbdf-4d6f-ba17-46ef52bd8b10','0b974bb0-522a-4209-bacc-677b72e92783','d2e6671e-204a-48ae-bd71-92b5a4a51d2c')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '98bc002a-308b-43d7-954a-fae7f3cfe3da');
UPDATE funding_round_investors SET investor_id = '98bc002a-308b-43d7-954a-fae7f3cfe3da' WHERE investor_id IN ('f4b6a89c-bbdf-4d6f-ba17-46ef52bd8b10','0b974bb0-522a-4209-bacc-677b72e92783','d2e6671e-204a-48ae-bd71-92b5a4a51d2c');
DELETE FROM investors WHERE id IN ('f4b6a89c-bbdf-4d6f-ba17-46ef52bd8b10','0b974bb0-522a-4209-bacc-677b72e92783','d2e6671e-204a-48ae-bd71-92b5a4a51d2c');

-- ─────────────────────────────────────────────────────────────────────────────
-- Demeter: keep 20ff219a, merge 455227db (Demeter Partners)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '455227db-4a34-4bee-935a-02aacf4b75f2'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '20ff219a-57eb-4fd3-85f4-dd9a666263c3');
UPDATE funding_round_investors SET investor_id = '20ff219a-57eb-4fd3-85f4-dd9a666263c3' WHERE investor_id = '455227db-4a34-4bee-935a-02aacf4b75f2';
DELETE FROM investors WHERE id = '455227db-4a34-4bee-935a-02aacf4b75f2';

-- ─────────────────────────────────────────────────────────────────────────────
-- Earlybird: keep f0c98a84, merge 246eb590 (Earlybird Venture Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '246eb590-9077-4a67-a837-e11e7b192149'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'f0c98a84-1ac3-43bc-98a1-f99855946b15');
UPDATE funding_round_investors SET investor_id = 'f0c98a84-1ac3-43bc-98a1-f99855946b15' WHERE investor_id = '246eb590-9077-4a67-a837-e11e7b192149';
DELETE FROM investors WHERE id = '246eb590-9077-4a67-a837-e11e7b192149';

-- ─────────────────────────────────────────────────────────────────────────────
-- Point Nine: keep 9285512f, merge 10aed804 (Point Nine Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '10aed804-c476-4369-a745-f91e0bfa4c16'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '9285512f-ceec-4036-8b56-61260b041d93');
UPDATE funding_round_investors SET investor_id = '9285512f-ceec-4036-8b56-61260b041d93' WHERE investor_id = '10aed804-c476-4369-a745-f91e0bfa4c16';
DELETE FROM investors WHERE id = '10aed804-c476-4369-a745-f91e0bfa4c16';

-- ─────────────────────────────────────────────────────────────────────────────
-- Heartcore: keep 456ff616, merge c15bbb4b (Heartcore Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = 'c15bbb4b-54a9-458e-a6d5-b3d4970fad39'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '456ff616-2b8b-446c-b0bf-1d46ea5062d1');
UPDATE funding_round_investors SET investor_id = '456ff616-2b8b-446c-b0bf-1d46ea5062d1' WHERE investor_id = 'c15bbb4b-54a9-458e-a6d5-b3d4970fad39';
DELETE FROM investors WHERE id = 'c15bbb4b-54a9-458e-a6d5-b3d4970fad39';

-- ─────────────────────────────────────────────────────────────────────────────
-- Omnes: keep 0c95e3b4, merge 61775979 (Omnes Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '61775979-2939-4d9e-a31c-23edf7f8ef85'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '0c95e3b4-8726-426a-94ac-7ebf58b99bbf');
UPDATE funding_round_investors SET investor_id = '0c95e3b4-8726-426a-94ac-7ebf58b99bbf' WHERE investor_id = '61775979-2939-4d9e-a31c-23edf7f8ef85';
DELETE FROM investors WHERE id = '61775979-2939-4d9e-a31c-23edf7f8ef85';

-- ─────────────────────────────────────────────────────────────────────────────
-- Starquest: keep 38832266, merge fe7ef9ab (Starquest Capital)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = 'fe7ef9ab-6ae2-478d-a503-2f86e7dcbd03'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '38832266-3cfb-419d-8297-a4933011cee5');
UPDATE funding_round_investors SET investor_id = '38832266-3cfb-419d-8297-a4933011cee5' WHERE investor_id = 'fe7ef9ab-6ae2-478d-a503-2f86e7dcbd03';
DELETE FROM investors WHERE id = 'fe7ef9ab-6ae2-478d-a503-2f86e7dcbd03';

-- ─────────────────────────────────────────────────────────────────────────────
-- Swen Capital: keep da99440e, merge 1eb3546e (SWEN Capital Partners)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = '1eb3546e-0fb5-409a-afc3-f85f03a58f86'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'da99440e-df67-4762-adfc-4fd39d5e6b63');
UPDATE funding_round_investors SET investor_id = 'da99440e-df67-4762-adfc-4fd39d5e6b63' WHERE investor_id = '1eb3546e-0fb5-409a-afc3-f85f03a58f86';
DELETE FROM investors WHERE id = '1eb3546e-0fb5-409a-afc3-f85f03a58f86';

-- ─────────────────────────────────────────────────────────────────────────────
-- IXO: keep 3c36e8a5, merge fffb54be (IXO Private Equity)
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id = 'fffb54be-380a-4c7d-b09e-af5b3b296025'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '3c36e8a5-2142-48bb-bac4-d5526c24b779');
UPDATE funding_round_investors SET investor_id = '3c36e8a5-2142-48bb-bac4-d5526c24b779' WHERE investor_id = 'fffb54be-380a-4c7d-b09e-af5b3b296025';
DELETE FROM investors WHERE id = 'fffb54be-380a-4c7d-b09e-af5b3b296025';

-- ─────────────────────────────────────────────────────────────────────────────
-- IRDI Capital: keep 7a23b28b, merge 74513ddc, abdebe86, f5b8d4b5, f3397e62
-- ─────────────────────────────────────────────────────────────────────────────
DELETE FROM funding_round_investors WHERE investor_id IN ('74513ddc-30b0-4bb9-abb4-289cbdcf7360','abdebe86-130f-45af-863f-5c2b449dc305','f5b8d4b5-1758-4a66-844d-f7b872981283','f3397e62-ba5e-474d-9bf3-753ec3361bd9')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '7a23b28b-fb29-4ee7-9f25-a051e05d658b');
UPDATE funding_round_investors SET investor_id = '7a23b28b-fb29-4ee7-9f25-a051e05d658b' WHERE investor_id IN ('74513ddc-30b0-4bb9-abb4-289cbdcf7360','abdebe86-130f-45af-863f-5c2b449dc305','f5b8d4b5-1758-4a66-844d-f7b872981283','f3397e62-ba5e-474d-9bf3-753ec3361bd9');
DELETE FROM investors WHERE id IN ('74513ddc-30b0-4bb9-abb4-289cbdcf7360','abdebe86-130f-45af-863f-5c2b449dc305','f5b8d4b5-1758-4a66-844d-f7b872981283','f3397e62-ba5e-474d-9bf3-753ec3361bd9');

SELECT 'Part 2a complete' AS status;
