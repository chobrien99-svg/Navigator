-- =============================================================================
-- TechBio list: research origins (spun_out_from) + missing i-Lab / i-PhD entries
-- =============================================================================
-- legacy_source 'techbio_research_origins_november_2026'.
-- Sources: MESR open data on data.gouv.fr —
--   * Lauréats i-Lab (resource 93162d25-…): matched by SIREN, or by founder
--     name where the row has no SIREN; "Unité de recherche liée au projet" /
--     "Structure liée au projet" give the research origin.
--   * Lauréats i-PhD (resource 4436b743-…): Orakl matched on project ORAKL.
--   * Ariana: Institut Pasteur spin-off per Institut Pasteur / company sources.
--   * DNA Script: i-Lab 2016 research unit "Biologie Structurale des Processus
--     Cellulaires et Maladies Infectieuses" (UPMC, Paris Diderot, CNRS) and
--     founding patents co-owned with Institut Pasteur (INPI FR1655475).
-- verification_status carries the match confidence (high / medium / low).
-- Peaccel: low confidence — the i-Lab row is founder Bernard Offmann's 2004
-- project at LBGM (Université de La Réunion), before Peaccel was registered.
-- =============================================================================

-- New i-Lab 2026 edition
INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'i-Lab — 2026', 'i-lab-2026', 2026, '2026', NOW(), NOW()
FROM programs p WHERE p.slug='i-lab'
  AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='i-lab-2026');

-- Research institutions / labs (created only if missing)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"ecole-normale-superieure-psl","name":"École normale supérieure - PSL","type":"university","city":"paris","desc":"Grande école and research university in Paris, part of Université PSL."},
  {"slug":"laboratoire-dhydrodynamique-ladhyx","name":"Laboratoire d'hydrodynamique (LadHyX)","type":"research_lab","city":"palaiseau","desc":"Fluid-mechanics research laboratory of École polytechnique and CNRS."},
  {"slug":"laboratoire-de-physique-de-lens-lpens","name":"Laboratoire de physique de l'ENS (LPENS)","type":"research_lab","city":"paris","desc":"Physics laboratory of École normale supérieure - PSL."},
  {"slug":"laboratoire-de-physique-et-chimie-theoriques-lpct","name":"Laboratoire de physique et chimie théoriques (LPCT)","type":"research_lab","city":null,"desc":"Theoretical physics and chemistry laboratory of Université de Lorraine and CNRS."},
  {"slug":"bioingenierie-tissulaire-biotis","name":"Bioingénierie tissulaire (BIOTIS)","type":"research_lab","city":"bordeaux","desc":"Tissue bioengineering research unit of Université de Bordeaux and INSERM."},
  {"slug":"laboratoire-de-chimie-theorique-lct","name":"Laboratoire de chimie théorique (LCT)","type":"research_lab","city":"paris","desc":"Theoretical chemistry laboratory of Sorbonne Université and CNRS."},
  {"slug":"institut-doncologie-de-bordeaux","name":"Institut d'oncologie de Bordeaux","type":"research_lab","city":"bordeaux","desc":"Bordeaux cancer research institute, listed as the research unit behind BeLiver's 2026 i-Lab project."},
  {"slug":"massachusetts-institute-of-technology","name":"Massachusetts Institute of Technology (MIT)","type":"university","city":null,"desc":"Research university in Cambridge, Massachusetts."},
  {"slug":"lbgm-universite-de-la-reunion","name":"Laboratoire de Biochimie et de Génétique Moléculaire (LBGM), Université de La Réunion","type":"research_lab","city":"saint-denis-la-reunion","desc":"Biochemistry and molecular genetics laboratory of Université de La Réunion."},
  {"slug":"biologie-structurale-processus-cellulaires-maladies-infectieuses","name":"Biologie structurale des processus cellulaires et maladies infectieuses","type":"research_lab","city":"paris","desc":"Structural biology research unit linked to UPMC, Université Paris Diderot and CNRS, listed on DNA Script's 2016 i-Lab project."}
]$json$) AS (slug TEXT, name TEXT, type TEXT, city TEXT, "desc" TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, status, country, city_id, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, s.type::organization_type, s."desc", 'active'::organization_status,
  CASE WHEN s.slug='massachusetts-institute-of-technology' THEN 'United States' ELSE 'France' END,
  (SELECT id FROM cities c WHERE c.slug=s.city), 'techbio_research_origins_november_2026', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- spun_out_from relationships (source = startup, target = research institution)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"aqemia","target":"ecole-normale-superieure-psl","conf":"high","desc":"i-Lab 2020 laureate (Maximilien Levesque); structure linked to the project: École normale supérieure PSL.","src":"i-Lab laureates (MESR)"},
  {"org":"okomera","target":"laboratoire-dhydrodynamique-ladhyx","conf":"high","desc":"i-Lab 2019 laureate (Aimée Wessel); research unit: LadHyX (École polytechnique / CNRS).","src":"i-Lab laureates (MESR)"},
  {"org":"orakl-oncology","target":"institut-gustave-roussy","conf":"high","desc":"i-Lab 2024 Grand Prix (Fanny Jaulin), structure: Institut Gustave Roussy; i-PhD 2022 Grand Prix (Diane-Laure Pagès), lab 'Dynamique des cellules tumorales', tech transfer: Gustave Roussy Transfert.","src":"i-Lab and i-PhD laureates (MESR)"},
  {"org":"oria-bioscience","target":"laboratoire-de-physique-de-lens-lpens","conf":"high","desc":"i-Lab 2024 laureate (Alexandre Satinho); research unit: LPENS. Company describes itself as an ENS-PSL spin-off.","src":"i-Lab laureates (MESR)"},
  {"org":"nebula","target":"laboratoire-de-physique-et-chimie-theoriques-lpct","conf":"high","desc":"i-Lab 2025 laureate (Mounir Tarek); research unit: LPCT (Université de Lorraine / CNRS).","src":"i-Lab laureates (MESR)"},
  {"org":"poietis","target":"bioingenierie-tissulaire-biotis","conf":"high","desc":"i-Lab 2012 and 2014 laureate (Fabien Guillemot); research unit: BIOTIS (Université de Bordeaux / INSERM).","src":"i-Lab laureates (MESR)"},
  {"org":"qubit-pharmaceuticals","target":"laboratoire-de-chimie-theorique-lct","conf":"high","desc":"i-Lab 2020 laureate (Jean-Philip Piquemal); research unit: Laboratoire de chimie théorique (Sorbonne Université / CNRS).","src":"i-Lab laureates (MESR)"},
  {"org":"beliver","target":"institut-doncologie-de-bordeaux","conf":"high","desc":"i-Lab 2026 Grand Prix (Madeleine Moscatelli); research unit: Institut d'oncologie de Bordeaux.","src":"i-Lab laureates (MESR)"},
  {"org":"dna-script","target":"institut-pasteur","conf":"medium","desc":"Founding patents (DNA polymerase variants, filed 2016-17) co-owned with Institut Pasteur, inventors Thomas Ybert and Marc Delarue; i-Lab 2016 research unit 'Biologie structurale des processus cellulaires et maladies infectieuses'.","src":"INPI patent data; i-Lab laureates (MESR)"},
  {"org":"dna-script","target":"biologie-structurale-processus-cellulaires-maladies-infectieuses","conf":"high","desc":"i-Lab 2016 laureate (Thomas Ybert); research unit linked to the project (UPMC, Université Paris Diderot, CNRS).","src":"i-Lab laureates (MESR)"},
  {"org":"eligo-bioscience","target":"massachusetts-institute-of-technology","conf":"medium","desc":"i-Lab 2014 'en émergence' laureate Xavier Duportet (project PhageX), structure: MIT. Academic co-founder Timothy Lu is an MIT professor.","src":"i-Lab laureates (MESR); press"},
  {"org":"ariana-pharmaceuticals","target":"institut-pasteur","conf":"high","desc":"Founded in 2003 as a spin-off of Institut Pasteur, Paris.","src":"Institut Pasteur startup ecosystem; company profile"},
  {"org":"peaccel","target":"lbgm-universite-de-la-reunion","conf":"low","desc":"Co-founder Bernard Offmann was an i-Lab 2004 'en émergence' laureate (project mutaGeniX, protein engineering) at LBGM, Université de La Réunion, before Peaccel was registered.","src":"i-Lab laureates (MESR)"}
]$json$) AS (org TEXT, target TEXT, conf TEXT, "desc" TEXT, src TEXT))
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'spun_out_from'::relationship_type, s."desc", 'open_data', s.src, s.conf, 'techbio_research_origins_november_2026', NOW(), NOW()
FROM source s JOIN organizations a ON a.slug=s.org JOIN organizations b ON b.slug=s.target
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='spun_out_from');

-- Missing i-Lab / i-PhD memberships
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"beliver","ed":"i-lab-2026","group":"Biotechnologies et pharmacie","notes":"Grand Prix; laureate Madeleine Moscatelli; research unit Institut d'oncologie de Bordeaux","conf":"high"},
  {"org":"karavela","ed":"i-lab-2026","group":null,"notes":"Laureate Alexis Thual","conf":"high"},
  {"org":"scienta-lab","ed":"i-lab-2024","group":null,"notes":"Laureate Camille Bouget","conf":"high"},
  {"org":"dna-script","ed":"i-lab-2014","group":null,"notes":"'En émergence' category; laureate Thomas Ybert (matched by founder name; row SIREN 801575572 differs from DNA Script's)","conf":"high"},
  {"org":"dna-script","ed":"i-lab-2016","group":null,"notes":"'Création-développement' category; laureate Thomas Ybert; research unit Biologie structurale des processus cellulaires et maladies infectieuses","conf":"high"},
  {"org":"eligo-bioscience","ed":"i-lab-2014","group":null,"notes":"'En émergence' category; laureate Xavier Duportet, project PhageX; structure MIT (matched by founder name, no SIREN on row)","conf":"medium"},
  {"org":"orakl-oncology","ed":"i-phd-2022","group":null,"notes":"Grand Prix; laureate Diane-Laure Pagès, project ORAKL; lab Dynamique des cellules tumorales (Institut Gustave Roussy); tech transfer Gustave Roussy Transfert","conf":"high"}
]$json$) AS (org TEXT, ed TEXT, "group" TEXT, notes TEXT, conf TEXT))
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, group_label, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Laureate', s."group", s.notes, s.conf, 'techbio_research_origins_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN program_editions pe ON pe.slug=s.ed
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;

SELECT a.slug company, b.name origin, r.verification_status conf
FROM organization_relationships r JOIN organizations a ON a.id=r.source_org_id JOIN organizations b ON b.id=r.target_org_id
WHERE r.legacy_source='techbio_research_origins_november_2026' ORDER BY 1;
