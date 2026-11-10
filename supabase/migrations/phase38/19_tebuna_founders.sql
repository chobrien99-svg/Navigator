-- =============================================================================
-- Tebuna Bioscience founders (SIREN 993570498, Nice, registered 5 Nov 2025)
-- =============================================================================
-- legacy_source 'tebuna_founders_november_2026'. Editor-supplied (FTJ) from the
-- company's founding statutes: share capital €18,600 in 186,000 shares of €0.10.
--   Minyoung (Millie) Heo   178,000 shares (95.7%), President
--   Cyril Touffet             4,000 shares (2.2%)
--   Michel Popielarz          4,000 shares (2.2%)
-- Heo uses "Millie" professionally (LinkedIn). Home addresses in the statutes
-- are deliberately not stored.
-- =============================================================================
BEGIN;
UPDATE people SET full_name='Millie Heo', first_name='Millie', last_name='Heo', linkedin_url='https://www.linkedin.com/in/millieheo/',
  short_bio='Founder and president of Tebuna Bioscience (Nice). Registered name: Minyoung Heo; uses Millie.', updated_at=NOW()
WHERE slug='minyoung-heo';

INSERT INTO people (id, full_name, slug, first_name, last_name, linkedin_url, legacy_source, created_at) VALUES
 (uuid_generate_v4(),'Cyril Touffet','cyril-touffet','Cyril','Touffet','https://www.linkedin.com/in/cyril-touffet-25b9905b/','tebuna_founders_november_2026',NOW()),
 (uuid_generate_v4(),'Michel Popielarz','michel-popielarz','Michel','Popielarz','https://www.linkedin.com/in/mpopielarz/','tebuna_founders_november_2026',NOW())
ON CONFLICT (slug) DO NOTHING;

UPDATE organization_people op SET role='Founder', is_founder=TRUE,
  title='Founder & President; founding shareholder (178,000 of 186,000 shares, 95.7%)', updated_at=NOW()
FROM organizations o, people p WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='tebuna' AND p.slug='minyoung-heo';

INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', s.title, TRUE, TRUE, 'tebuna_founders_november_2026', NOW(), NOW()
FROM (VALUES ('cyril-touffet','Co-founder; founding shareholder (4,000 of 186,000 shares, 2.2%)'),
             ('michel-popielarz','Co-founder; founding shareholder (4,000 of 186,000 shares, 2.2%)')) s(person,title)
JOIN organizations o ON o.slug='tebuna' JOIN people p ON p.slug=s.person
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

UPDATE legal_entities le SET capital_eur=18600, incorporation_date=COALESCE(le.incorporation_date,'2025-11-05'), updated_at=NOW()
FROM organizations o WHERE le.organization_id=o.id AND o.slug='tebuna' AND le.siren='993570498';
UPDATE organizations SET founded_date=COALESCE(founded_date,'2025-11-05'), founded_year=COALESCE(founded_year,2025), updated_at=NOW() WHERE slug='tebuna';
COMMIT;
