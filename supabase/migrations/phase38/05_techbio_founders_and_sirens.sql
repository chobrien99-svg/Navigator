-- =============================================================================
-- TechBio list: fill missing founders (9 companies) + 2 missing SIRENs
-- =============================================================================
-- legacy_source 'techbio_france_founders_november_2026'.
-- Founders taken from the company registry (recherche-entreprises.api.gouv.fr
-- directors) cross-checked against press/company sources. Existing person
-- records are reused (ON CONFLICT on slug).
--
--   DNA Script   Thomas Ybert, Sylvain Gariel, Xavier Godron (2014; ex-Total).
--                Labiotech, FrenchWeb, L'ADN; all three on the registry.
--   Eligo        Xavier Duportet (CEO), David Bikard (CSO; Institut Pasteur),
--                Timothy Lu (MIT) and Luciano Marraffini (Rockefeller) as
--                academic co-founders. Benchling, Labiotech, MarketScreener.
--   Iktos        Yann Gaston-Mathé (CEO), Quentin Perron (CSO), Nicolas Do Huu
--                (CTO). Company/TheOrg/MarketScreener.
--   Owkin        Thomas Clozel (CEO), Gilles Wainrib. Wikipedia, FrenchWeb.
--   Cure51       Nicolas Wolikow (CEO), Simon Istolainen. PR Newswire etc.
--                (one source also names researcher Paloma Cejas; not added.)
--   Scienta Lab  Camille Bouget (CEO), Vincent Bouget, Julien Duquesne.
--                Univ. Paris-Saclay, FrenchWeb, ActuIA; SIREN 900344748.
--   DeepLife     Jonathan Baptista (CEO), Jean-Baptiste Morlot (CTO). Company
--                press kit; registry SIREN 852661230 (created 2019, Caen) has
--                both as officers.
--   MAbSilico    Thomas Bourquard, Anne Poupon, Vincent Puard, Astrid Musnier
--                per Seedtable/Craft/Bechtle. NB a Feb 2020 release mentions 3
--                co-founders, so the founder list is medium-confidence.
--   Ariana       Mohammad Afshar (founder, 2003 Institut Pasteur spin-off).
--                Single source (MarketScreener); the registry lists an
--                "Adam Abas Afshar" (b. 1962) as board member. Medium-confidence.
-- Not filled: Ksilink (association-founded), Tebuna (founders not public),
-- Endogene.bio (no founder names or SIREN found yet).
-- =============================================================================

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Thomas Ybert","first_name":"Thomas","last_name":"Ybert"},
  {"full_name":"Sylvain Gariel","first_name":"Sylvain","last_name":"Gariel"},
  {"full_name":"Xavier Godron","first_name":"Xavier","last_name":"Godron"},
  {"full_name":"Xavier Duportet","first_name":"Xavier","last_name":"Duportet"},
  {"full_name":"David Bikard","first_name":"David","last_name":"Bikard"},
  {"full_name":"Timothy Lu","first_name":"Timothy","last_name":"Lu"},
  {"full_name":"Luciano Marraffini","first_name":"Luciano","last_name":"Marraffini"},
  {"full_name":"Yann Gaston-Mathé","first_name":"Yann","last_name":"Gaston-Mathé"},
  {"full_name":"Quentin Perron","first_name":"Quentin","last_name":"Perron"},
  {"full_name":"Nicolas Do Huu","first_name":"Nicolas","last_name":"Do Huu"},
  {"full_name":"Thomas Clozel","first_name":"Thomas","last_name":"Clozel"},
  {"full_name":"Gilles Wainrib","first_name":"Gilles","last_name":"Wainrib"},
  {"full_name":"Nicolas Wolikow","first_name":"Nicolas","last_name":"Wolikow"},
  {"full_name":"Simon Istolainen","first_name":"Simon","last_name":"Istolainen"},
  {"full_name":"Camille Bouget","first_name":"Camille","last_name":"Bouget"},
  {"full_name":"Vincent Bouget","first_name":"Vincent","last_name":"Bouget"},
  {"full_name":"Julien Duquesne","first_name":"Julien","last_name":"Duquesne"},
  {"full_name":"Jonathan Baptista","first_name":"Jonathan","last_name":"Baptista"},
  {"full_name":"Jean-Baptiste Morlot","first_name":"Jean-Baptiste","last_name":"Morlot"},
  {"full_name":"Thomas Bourquard","first_name":"Thomas","last_name":"Bourquard"},
  {"full_name":"Anne Poupon","first_name":"Anne","last_name":"Poupon"},
  {"full_name":"Vincent Puard","first_name":"Vincent","last_name":"Puard"},
  {"full_name":"Astrid Musnier","first_name":"Astrid","last_name":"Musnier"},
  {"full_name":"Mohammad Afshar","first_name":"Mohammad","last_name":"Afshar"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'techbio_france_founders_november_2026', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"dna-script","person":"thomas-ybert","title":"Co-founder; former CEO"},
  {"org":"dna-script","person":"sylvain-gariel","title":"Co-founder"},
  {"org":"dna-script","person":"xavier-godron","title":"Co-founder; Président"},
  {"org":"eligo-bioscience","person":"xavier-duportet","title":"Co-founder & CEO"},
  {"org":"eligo-bioscience","person":"david-bikard","title":"Co-founder & CSO"},
  {"org":"eligo-bioscience","person":"timothy-lu","title":"Academic co-founder (MIT)"},
  {"org":"eligo-bioscience","person":"luciano-marraffini","title":"Academic co-founder (Rockefeller University)"},
  {"org":"iktos","person":"yann-gaston-mathe","title":"Co-founder & CEO"},
  {"org":"iktos","person":"quentin-perron","title":"Co-founder & CSO"},
  {"org":"iktos","person":"nicolas-do-huu","title":"Co-founder & CTO"},
  {"org":"owkin","person":"thomas-clozel","title":"Co-founder & CEO"},
  {"org":"owkin","person":"gilles-wainrib","title":"Co-founder"},
  {"org":"cure51","person":"nicolas-wolikow","title":"Co-founder & CEO"},
  {"org":"cure51","person":"simon-istolainen","title":"Co-founder"},
  {"org":"scienta-lab","person":"camille-bouget","title":"Co-founder & CEO"},
  {"org":"scienta-lab","person":"vincent-bouget","title":"Co-founder & CSO"},
  {"org":"scienta-lab","person":"julien-duquesne","title":"Co-founder & CTO"},
  {"org":"deeplife","person":"jonathan-baptista","title":"Co-founder & CEO"},
  {"org":"deeplife","person":"jean-baptiste-morlot","title":"Co-founder & CTO"},
  {"org":"mabsilico-sas","person":"thomas-bourquard","title":"Co-founder & CSO"},
  {"org":"mabsilico-sas","person":"anne-poupon","title":"Co-founder"},
  {"org":"mabsilico-sas","person":"vincent-puard","title":"Co-founder & CEO"},
  {"org":"mabsilico-sas","person":"astrid-musnier","title":"Co-founder; Directeur Général"},
  {"org":"ariana-pharmaceuticals","person":"mohammad-afshar","title":"Founder (single-source)"}
]$json$) AS (org TEXT, person TEXT, title TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', s.title, TRUE, TRUE, 'techbio_france_founders_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people p ON p.slug=s.person
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Missing SIRENs
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"scienta-lab","legal_name":"SCIENTA LAB","siren":"900344748","inc":"2021-06-11","city":"Gif-sur-Yvette","naf":"62.01Z"},
  {"org":"deeplife","legal_name":"DEEPLIFE","siren":"852661230","inc":"2019-07-14","city":"Caen","naf":"58.29C"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT, inc TEXT, city TEXT, naf TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, legal_form, siren, incorporation_date, registered_city, naf_code, country, is_primary, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, 'SAS', s.siren, s.inc::DATE, s.city, s.naf, 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), 'techbio_france_founders_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren=s.siren);

SELECT o.slug, count(*) FILTER (WHERE op.is_founder) founders
FROM organizations o LEFT JOIN organization_people op ON op.organization_id=o.id
WHERE o.slug IN ('dna-script','eligo-bioscience','iktos','owkin','cure51','scienta-lab','deeplife','mabsilico-sas','ariana-pharmaceuticals')
GROUP BY 1 ORDER BY 1;
