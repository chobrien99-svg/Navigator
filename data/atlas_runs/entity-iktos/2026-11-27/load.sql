-- Atlas entity load: Iktos (iktos)
-- Run: 2026-11-27; accepted findings by type: {"capital_increase": 1}
-- Idempotent: legacy_source 'atlas:entity:iktos' / NOT EXISTS guards.
BEGIN;

-- capital_check:capital_increase:B201800211136
INSERT INTO signal_candidates (id, organization_id, source, source_url, source_name, source_published_at, raw_title, raw_excerpt, signal_type, title, description, signal_date, strength, confidence, ai_reasoning, status, created_at)
SELECT uuid_generate_v4(), (SELECT id FROM organizations WHERE slug = 'iktos'), 'bodacc', 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211136', 'BODACC', '2018-01-31'::timestamptz, 'BODACC: Modifications diverses – Iktos', 'modification survenue sur le capital (augmentation); capital €14,449 → €16,352', 'fundraising'::signal_type, 'Possible unannounced share issue: Iktos: share capital up 13% (€14,449 → €16,352)', 'BODACC shows new shares were issued (share capital +13%), but Navigator has no funding round or deal that explains it. Could be an unannounced round, shares used to pay for a deal, or a note conversion. The amount raised is unknown: BODACC gives only the nominal capital.', '2018-01-31'::date, 2, 0.4, 'Atlas capital check: increases of 5% or more are compared one-to-one with recorded rounds (up to 30 days before to 300 days after the notice) and with acquisitions or mergers (120 days).', 'pending', NOW()
WHERE (SELECT id FROM organizations WHERE slug = 'iktos') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM signal_candidates WHERE source_url = 'https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:B201800211136' AND organization_id = (SELECT id FROM organizations WHERE slug = 'iktos'));

COMMIT;
