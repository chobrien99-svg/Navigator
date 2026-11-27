-- Iktos: Synsight acquisition (July 2024) and an unexplained January 2018 capital increase.
-- Found by comparing BODACC share-capital changes with Navigator's funding rounds (27 Nov 2026).
-- Idempotent: legacy_source 'iktos_capital_check_november_2026' / NOT EXISTS guards.
BEGIN;

-- 1. Acquisition event on Iktos
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'acquisition'::event_type, '2024-07-08'::date,
  'Iktos acquires Synsight',
  'Iktos bought Synsight, a biology start-up at Genopole in Évry, to bring in-house the testing of compounds that act on protein-protein and RNA-protein interactions (Synsight''s MT Bench platform), which Iktos had outsourced until then. Price not disclosed. Iktos opened a site in Évry on 28 June 2024, and BODACC published a 15% increase in its share capital (to €64,913) on 14 June 2024, consistent with the deal being paid at least partly in Iktos shares (not confirmed).',
  'https://debiopharm.com/?p=15604', 'press_release', 'Debiopharm (Iktos investor) press release', 'high',
  'iktos_capital_check_november_2026', 'iktos:acquisition:synsight', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = 'iktos:acquisition:synsight');

-- 2. Relationship Iktos -> Synsight
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, source_url, verification_status, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), (SELECT id FROM organizations WHERE slug = 'synsight'),
  'acquired'::relationship_type, 'Iktos acquired Synsight (Évry) in July 2024 to internalise biological testing. Price not disclosed.',
  '2024-07-08'::date, 'press_release', 'Debiopharm (Iktos investor) press release', 'https://debiopharm.com/?p=15604', 'high',
  'iktos_capital_check_november_2026', 'iktos:relationship:acquired:synsight', NOW(), NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND (SELECT id FROM organizations WHERE slug = 'synsight') IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM organization_relationships WHERE legacy_id = 'iktos:relationship:acquired:synsight');

-- 3. Unconfirmed lead for the Radar review queue: January 2018 share issue with no recorded round
INSERT INTO signal_candidates (id, organization_id, source, source_url, source_name, source_published_at, raw_title, raw_excerpt, signal_type, title, description, signal_date, strength, confidence, ai_reasoning, status, created_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'bodacc',
  'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211136', 'BODACC', '2018-01-31'::timestamptz,
  'BODACC: Modifications diverses – Avis initial – Iktos',
  'modification survenue sur le capital (augmentation); capital €14,449 → €16,352',
  'fundraising'::signal_type,
  'Possible unannounced share issue: Iktos share capital up 13% (January 2018)',
  'BODACC published an increase in Iktos''s share capital from €14,449 to €16,352 (+13%) on 31 January 2018, the same day as its conversion from SARL to SAS. Navigator has no funding round between the June 2017 seed and the 2019 seed. Possibly a small round with business angels or an accelerator; PitchBook lists only accelerator and grant money in early 2018. Needs the filed deed (INPI) or the company to confirm.',
  '2018-01-31'::date, 2, 0.4,
  'A 13% rise in share capital means new shares worth about an eighth of the company were issued. Rises of this size line up with announced rounds elsewhere in Iktos''s history (2017 seed, 2019 seed, 2023 Series A), so this one probably reflects a raise that was never announced. Amount raised is unknown: BODACC gives only the nominal capital.',
  'pending', NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM signal_candidates WHERE source_url = 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211136'
                  AND organization_id = (SELECT id FROM organizations WHERE slug = 'iktos'));

COMMIT;
