-- Phase 37: Add Sequoia participations found in Dealroom profiles (editor-confirmed 2026-11-05).
--
--   Vocca     Seed 2025-09      add Sequoia Scout (editor: file under Scout programme)
--   Osol      Seed 2021-11      add Sequoia Capital
--   Destree   Series A 2022-04  add Sequoia Capital
--   Kovalee   Series A 2023-03  add Sequoia Capital
--   Gigi      remove Sequoia Capital from the Sept 2025 $3M extension (Khosla-led);
--             add the May 2023 $4.6M seed (Sequoia, DST Global, OpenAI, Monashees)
--   onibi     NEW company (onibi.gg, Bordeaux, founded 2023 -- NOT the existing
--             "Onibi" record, which is onibi.fr); Seed 2024-03 $6.5M
--             (Sequoia, Octopus Ventures)
--
-- Existing round amounts are left unchanged. USD amounts converted at 0.864
-- (same rate as other recent USD rounds) and flagged is_estimated.
--
-- Applied to production via Supabase MCP on 2026-11-05.

BEGIN;

-- Sequoia participations on existing rounds
INSERT INTO funding_round_investors (funding_round_id, investor_id, investor_name, is_lead) VALUES
 ('56095306-6c4f-4492-a66a-1222ae8011c4','62636cd2-0e72-4141-a395-466a2a4bdc90','Sequoia Scout',false),   -- Vocca seed
 ('f81988d7-693d-4b4d-8a6e-4adf19530895','91cf3f66-6ceb-4385-a910-51a2e232c934','Sequoia Capital',false), -- Osol seed
 ('78b913f2-52ac-40b5-81b9-96cac9e00e82','91cf3f66-6ceb-4385-a910-51a2e232c934','Sequoia Capital',false), -- Destree Series A
 ('a7e52cfc-cd04-44ca-9234-ad7e40ce0a51','91cf3f66-6ceb-4385-a910-51a2e232c934','Sequoia Capital',false); -- Kovalee Series A

-- Gigi: Sequoia off the 2025 extension
DELETE FROM funding_round_investors
 WHERE funding_round_id = '648d8305-2d25-4670-b32d-9e6193eaed67'
   AND investor_id = '91cf3f66-6ceb-4385-a910-51a2e232c934';

-- Gigi: May 2023 seed
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original,
                            announced_date, is_estimated, is_verified, source_name, notes)
SELECT 'a8d1a255-03ea-44a4-b759-d9f1656ce437', id, 'seed', 3.97, 'USD', 4600000,
       '2023-05-01', true, false, 'dealroom', 'Added from Dealroom profile; month-level date.'
  FROM organizations WHERE slug = 'gigi';

INSERT INTO funding_round_investors (funding_round_id, investor_id, investor_name, is_lead) VALUES
 ('a8d1a255-03ea-44a4-b759-d9f1656ce437','91cf3f66-6ceb-4385-a910-51a2e232c934','Sequoia Capital',false),
 ('a8d1a255-03ea-44a4-b759-d9f1656ce437','b4d02107-b53c-4f80-bcaf-758fb8f0197e','DST Global',false),
 ('a8d1a255-03ea-44a4-b759-d9f1656ce437','f7103020-7329-4594-a843-ee0e4d54d01d','OpenAI',false),
 ('a8d1a255-03ea-44a4-b759-d9f1656ce437','984beeda-44ee-4671-b6e3-a5560653872f','Monashees',false);

-- onibi (onibi.gg): new company + seed round
INSERT INTO organizations (id, name, slug, organization_type, short_description, website, linkedin_url,
                           status, country, city_id, founded_date, legacy_source)
VALUES ('1ff34e58-d9e3-4638-8442-32378a22e8f0', 'onibi', 'onibi-gg', 'startup',
        'Game studio behind Jamland, a UGC-driven MMO with block-based building in an oceanic world',
        'https://onibi.gg', 'https://www.linkedin.com/company/onibi-inc/',
        'active', 'France', 'f1a084b7-2c63-4375-8a0b-25ccc15d8bf8', '2023-08-01', 'dealroom');

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original,
                            announced_date, is_estimated, is_verified, source_name, notes)
VALUES ('8fa7ea15-be72-4cc1-885a-4124651a20b9', '1ff34e58-d9e3-4638-8442-32378a22e8f0', 'seed', 5.62, 'USD', 6500000,
        '2024-03-01', true, false, 'dealroom', 'Added from Dealroom profile; month-level date.');

INSERT INTO funding_round_investors (funding_round_id, investor_id, investor_name, is_lead) VALUES
 ('8fa7ea15-be72-4cc1-885a-4124651a20b9','91cf3f66-6ceb-4385-a910-51a2e232c934','Sequoia Capital',false),
 ('8fa7ea15-be72-4cc1-885a-4124651a20b9','c614fb1f-7fe0-4feb-a5c6-4e02ed644791','Octopus Ventures',false);

COMMIT;
