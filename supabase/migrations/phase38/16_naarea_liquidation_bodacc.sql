-- =============================================================================
-- Naarea: receivership, liquidation and sale plan confirmed in BODACC
-- =============================================================================
-- legacy_source 'naarea_bodacc_november_2026'. Source: BODACC notices for SIREN
-- 882949506 (retrieved via Pappers, 8 Nov 2026):
--   * BODACC A n°20250175 annonce 3378 (12 Sep 2025): receivership opened by the
--     Nanterre economic-activities court on 3 Sep 2025 (case 2025J00848);
--     cessation of payments 20 Mar 2025.
--   * BODACC A n°20260017 annonce 6135 (27 Jan 2026): converted to judicial
--     liquidation on 15 Jan 2026; liquidator SELARL C. Basse.
--   * BODACC A n°20260017 annonce 6140 (27 Jan 2026): sale plan approved on
--     15 Jan 2026 in favour of ENERIS FUELS SA (RCS Luxembourg B218188).
-- The company is not struck off the register (statut RCS: inscrit). Status set
-- to 'inactive', as for Ksilink.
-- =============================================================================

UPDATE organizations SET status='inactive'::organization_status,
  description = description || ' In judicial liquidation since 15 January 2026; the court approved a sale plan to Eneris Fuels SA (Luxembourg) the same day.',
  updated_at=NOW()
WHERE slug='naarea' AND description NOT LIKE '%judicial liquidation since 15 January 2026%';

UPDATE organization_events e SET
  title='Naarea placed in receivership (redressement judiciaire)',
  description='The Nanterre economic-activities court opened receivership proceedings on 3 September 2025 (case 2025J00848); cessation of payments dated 20 March 2025. Administrator SELARL FHB (Me Théophile Fornacciari); creditors'' representative SELARL C. Basse (Me Christophe Basse). BODACC A n°20250175, annonce 3378, 12 September 2025.',
  source_url='https://www.bodacc.fr/annonce/detail-annonce/A/20250175/3378', source_type='official_gazette', source_name='BODACC', verification_status='high', updated_at=NOW()
FROM organizations o WHERE e.organization_id=o.id AND o.slug='naarea' AND e.event_date='2025-09-03';

UPDATE organization_events e SET
  title='Court approves sale plan for Naarea to Eneris Fuels',
  description='On 15 January 2026 the Nanterre court approved a sale plan (plan de cession) in favour of ENERIS FUELS SA (RCS Luxembourg B218188), although Eneris had announced it was withdrawing its offer. BODACC A n°20260017, annonce 6140, 27 January 2026.',
  source_url='https://www.bodacc.fr/annonce/detail-annonce/A/20260017/6140', source_type='official_gazette', source_name='BODACC', verification_status='high', event_date='2026-01-15', updated_at=NOW()
FROM organizations o WHERE e.organization_id=o.id AND o.slug='naarea' AND e.title='Court orders sale of Naarea to Eneris';

INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'shutdown'::event_type, '2026-01-15', 'Naarea placed in judicial liquidation',
  'The Nanterre court converted the receivership into judicial liquidation on 15 January 2026 (case 2025J00848). Liquidator: SELARL C. Basse (Me Christophe Basse). BODACC A n°20260017, annonce 6135, 27 January 2026. The company is still listed on the register (not struck off).',
  'https://www.bodacc.fr/annonce/detail-annonce/A/20260017/6135', 'official_gazette', 'BODACC', 'high', 'naarea_bodacc_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='naarea'
  AND NOT EXISTS (SELECT 1 FROM organization_events x WHERE x.organization_id=o.id AND x.title='Naarea placed in judicial liquidation');

SELECT o.status, e.event_date, e.title, e.verification_status FROM organizations o JOIN organization_events e ON e.organization_id=o.id WHERE o.slug='naarea' ORDER BY e.event_date;
