-- Phase 37: Osol seed amount + Gigi records aligned with Dealroom (editor-confirmed 2026-11-05).
--
--   Osol   Seed 2021-11: EUR3.0M -> EUR4.0M (Dealroom figure).
--   Gigi   profile: LinkedIn, founded 2023 (year only; stored as 2023-01-01),
--          short description.
--          NEW Seed 2023-01: $1.2M (Marie Outtier, Monashees).
--          Seed 2025-09 extension: amount recorded as $3.0M (was stored as EUR3.0M),
--          post-money valuation $23.0M. Existing investors kept (editor's
--          additive-only policy); Dealroom lists only Khosla Ventures.
--
-- USD converted at 0.864 (same rate as other recent USD rounds), flagged is_estimated.
-- Applied to production via Supabase MCP on 2026-11-05.

BEGIN;

UPDATE funding_rounds SET amount_eur = 4.00, amount_original = 4000000, updated_at = now()
 WHERE id = 'f81988d7-693d-4b4d-8a6e-4adf19530895';  -- Osol seed

UPDATE organizations
   SET linkedin_url = COALESCE(linkedin_url, 'https://www.linkedin.com/company/gigi-ai/'),
       founded_date = COALESCE(founded_date, '2023-01-01'),
       short_description = COALESCE(short_description, 'AI-powered social network for professional connections'),
       updated_at = now()
 WHERE id = '094b694e-60c0-4a24-a6e7-3bbe7c8ea96f';

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original,
                            announced_date, is_estimated, is_verified, source_name, notes)
VALUES ('86ef8a80-de15-48dc-9e14-d4ce65501699', '094b694e-60c0-4a24-a6e7-3bbe7c8ea96f', 'seed', 1.04, 'USD', 1200000,
        '2023-01-01', true, false, 'dealroom', 'Added from Dealroom profile; month-level date.');

INSERT INTO funding_round_investors (funding_round_id, investor_id, investor_name, is_lead) VALUES
 ('86ef8a80-de15-48dc-9e14-d4ce65501699','7d2ac938-6787-47cf-8b91-143b5cdcdcb2','Marie Outtier',false),
 ('86ef8a80-de15-48dc-9e14-d4ce65501699','984beeda-44ee-4671-b6e3-a5560653872f','Monashees',false);

UPDATE funding_rounds
   SET amount_eur = 2.59, currency_original = 'USD', amount_original = 3000000,
       valuation_eur = 19.87, is_estimated = true, updated_at = now()
 WHERE id = '648d8305-2d25-4670-b32d-9e6193eaed67';  -- Gigi 2025 extension

COMMIT;
