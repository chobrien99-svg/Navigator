-- =============================================================================
-- Ksilink history correction + Endogene.bio founders and SIREN
-- =============================================================================
-- legacy_source 'techbio_founders_november_2026_b'. Editor-supplied (FTJ).
--
-- KSILINK
--   * Founders of the company: Antoine de Lacombe and Mona Boyé (investor
--     presentation). Ulf Nehrbass is NOT recorded as a company founder: he
--     started the earlier translational centre, the Ksilink Association (a
--     public-private initiative launched with backing from Inserm and Sanofi),
--     from which the business emerged; he remains a scientific & strategic
--     advisor. His link is changed from 'Founder' to 'Advisor'.
--   * Adds the Ksilink Association as an organisation (nonprofit); Ksilink
--     Services is its subsidiary (the association is the SAS's president in
--     the company registry), and the association is linked to Inserm and
--     Sanofi as backers.
-- ENDOGENE.BIO
--   * Legal entity ENDOGENE.BIO SAS, SIREN 910384999, Paris, created
--     2022-01-21, NAF 72.19Z; president María Teresa Pérez Zaballos
--     (verified in recherche-entreprises.api.gouv.fr).
--   * Founders per the company's team page: María Teresa Pérez Zaballos
--     (founder & CEO), Cristina Fernández Molina (co-founder & head of science).
-- =============================================================================

-- Ksilink: Nehrbass from Founder to Advisor
UPDATE organization_people op SET role='Advisor', is_founder=FALSE,
  title='Scientific & Strategic Advisor; started the Ksilink translational centre (Ksilink Association)', updated_at=NOW()
FROM organizations o, people p
WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='ksilink' AND p.slug='ulf-nehrbass' AND op.role='Founder';

UPDATE organizations SET description = description || ' The business emerged from the Ksilink Association, a public-private translational research initiative in Strasbourg launched with backing from Inserm and Sanofi and started by Ulf Nehrbass.', updated_at=NOW()
WHERE slug='ksilink' AND description NOT LIKE '%Ksilink Association, a public-private%';

-- Ksilink Association + Inserm (created if missing)
INSERT INTO organizations (id, name, slug, organization_type, description, status, country, city_id, legacy_source, created_at, updated_at) VALUES
  (uuid_generate_v4(), 'Ksilink Association', 'ksilink-association', 'nonprofit'::organization_type,
   'Strasbourg-based public-private translational research association launched with backing from Inserm and Sanofi, started by Ulf Nehrbass; controlling entity (president) of Ksilink Services SAS. Chaired by Alain Beretz.',
   'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='strasbourg'), 'techbio_founders_november_2026_b', NOW(), NOW()),
  (uuid_generate_v4(), 'Inserm', 'inserm', 'research_lab'::organization_type,
   'French national institute for health and medical research (Institut national de la santé et de la recherche médicale).',
   'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='paris'), 'techbio_founders_november_2026_b', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"src":"ksilink","tgt":"ksilink-association","type":"subsidiary_of","desc":"Ksilink Services SAS is controlled by the Ksilink Association, which is its president in the company registry; the business emerged from the association's translational centre."},
  {"src":"ksilink","tgt":"ksilink-association","type":"spun_out_from","desc":"The company emerged from the Ksilink Association, a public-private translational research initiative started by Ulf Nehrbass."},
  {"src":"ksilink-association","tgt":"inserm","type":"partnered_with","desc":"Ksilink Association launched as a public-private initiative with backing from Inserm."},
  {"src":"ksilink-association","tgt":"sanofi","type":"partnered_with","desc":"Ksilink Association launched as a public-private initiative with backing from Sanofi."}
]$json$) AS (src TEXT, tgt TEXT, type TEXT, "desc" TEXT))
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.type::relationship_type, s."desc", 'company_website', 'Ksilink (About us; team pages)', 'https://ksilink.com/', 'high', 'techbio_founders_november_2026_b', NOW(), NOW()
FROM source s JOIN organizations a ON a.slug=s.src JOIN organizations b ON b.slug=s.tgt
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.type::relationship_type);

-- Endogene.bio: legal entity, founding date, founders
INSERT INTO legal_entities (id, organization_id, legal_name, legal_form, siren, siret, incorporation_date, registered_city, naf_code, country, is_primary, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'ENDOGENE.BIO', 'SAS', '910384999', '91038499900017', '2022-01-21', 'Paris', '72.19Z', 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), 'techbio_founders_november_2026_b', NOW(), NOW()
FROM organizations o WHERE o.slug='endogenebio'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren='910384999');

UPDATE organizations SET founded_date=COALESCE(founded_date,'2022-01-21'), founded_year=COALESCE(founded_year,2022), updated_at=NOW()
WHERE slug='endogenebio';

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"María Teresa Pérez Zaballos","first_name":"María Teresa","last_name":"Pérez Zaballos","title":"Founder & CEO; Présidente"},
  {"full_name":"Cristina Fernández Molina","first_name":"Cristina","last_name":"Fernández Molina","title":"Co-founder & Head of Science"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT, title TEXT)),
ins AS (
  INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
  SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'techbio_founders_november_2026_b', NOW()
  FROM source s ON CONFLICT (slug) DO NOTHING RETURNING 1)
SELECT count(*) FROM ins;

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"person":"maria-teresa-perez-zaballos","title":"Founder & CEO; Présidente"},
  {"person":"cristina-fernandez-molina","title":"Co-founder & Head of Science"}
]$json$) AS (person TEXT, title TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', s.title, TRUE, TRUE, 'techbio_founders_november_2026_b', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug='endogenebio' JOIN people p ON p.slug=s.person
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

SELECT o.slug, p.full_name, op.role, op.is_founder FROM organization_people op JOIN people p ON p.id=op.person_id JOIN organizations o ON o.id=op.organization_id
WHERE o.slug IN ('ksilink','endogenebio') AND (op.is_founder OR p.slug='ulf-nehrbass') ORDER BY 1,2;

-- An unaccented record for Pérez Zaballos already existed (created 2026-04-08,
-- no other company links) and was reused; restore the accented name.
UPDATE people SET full_name='María Teresa Pérez Zaballos', first_name='María Teresa', last_name='Pérez Zaballos', updated_at=NOW()
WHERE slug='maria-teresa-perez-zaballos';
