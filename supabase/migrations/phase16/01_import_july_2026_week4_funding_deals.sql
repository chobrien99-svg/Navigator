-- =============================================================================
-- July 2026 Funding Deals Import (week ending July 24 / week of July 20-24)
-- =============================================================================
-- Imports 7 funding deals from the week ending July 24, 2026.
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links.
-- Amounts stored in millions (DB convention). Organizations that already exist
-- (matched by slug: Ascendance Flight Technologies, Carsup, Brenus Pharma, Womed,
-- Recupere Metals, hekat fluidics) get the new round attached rather than being
-- duplicated. Only Arrakis Technologies is a brand-new organization.
--
-- Special cases:
--  * Arrakis Technologies is headquartered in London (primary city) with a second
--    office in Paris (secondary city). London is created as a UK city; the org's
--    coarse country is kept as 'France' to remain in the French-tech dataset,
--    consistent with every other org in these imports (a French SIREN and Paris
--    office back this). It has a French SIREN (101352367).
--  * Recupere Metals' EUR 5M seed is ALREADY in the database (source 'ftj',
--    seed EUR 5.0M) -- this week's coverage re-reports that same raise. To avoid
--    double-counting, NO new funding round or investor links are created for
--    Recupere Metals here; only its two founders (previously missing) are added.
--    That is why the verification below counts 6 new rounds, not 7.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (idempotent). London is a UK city.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "London", "country": "United Kingdom" },
      { "name": "Paris", "country": "France" },
      { "name": "Toulouse", "country": "France" },
      { "name": "Orléans", "country": "France" },
      { "name": "Lyon", "country": "France" },
      { "name": "Montpellier", "country": "France" },
      { "name": "Pessac", "country": "France" }
]$json$
  ) AS (name TEXT, country TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.country,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Arrakis Technologies",
            "website": "http://arrakistechnologies.ai/",
            "description": "Arrakis Technologies helps industrial companies design, deploy, and scale custom AI agents across core operational workflows. Its model-agnostic platform combines forward-deployed engineers with applied AI research tailored to sectors including aerospace, energy, logistics, manufacturing, construction, and telecommunications."
      },
      {
            "name": "Ascendance Flight Technologies",
            "website": "https://www.ascendance-ft.com",
            "description": "Ascendance Flight Technologies develops hybrid-electric vertical take-off and landing aircraft designed to provide a more environmentally friendly, cost-effective, and efficient alternative for regional air mobility."
      },
      {
            "name": "Carsup",
            "website": "https://www.carsup.io/",
            "description": "Carsup operates a concierge platform for collector and exceptional vehicles, covering secure storage, maintenance and restoration, transport, buying and resale support, and owner experiences. The company also uses AI to analyze vehicle data and generate personalized maintenance recommendations."
      },
      {
            "name": "Brenus Pharma",
            "website": "https://www.brenus-pharma.com",
            "description": "Brenus Pharma develops off-the-shelf immuno-oncology therapies for hard-to-treat solid tumors. Its proprietary platform is designed to mimic tumor protein expression, expose tumors to the immune system, and trigger a multi-specific in vivo immune response that adapts as the cancer evolves."
      },
      {
            "name": "Womed",
            "website": "https://www.womedtech.com/",
            "description": "Womed develops biodegradable intrauterine treatments for uterine conditions including adhesions, fibroids and acute bleeding. Its polymer platform can function as a temporary mechanical barrier or deliver therapies locally inside the uterus, with the aim of reducing reliance on invasive surgery and systemic hormonal treatments."
      },
      {
            "name": "Recupere Metals",
            "website": "https://www.recupere-metals.com",
            "description": "Produces high-performance electrical wire from 100% recycled copper using a patented mechanical process that eliminates energy-intensive smelting and refining. Its products target electric motors, wind turbines, data centers, electrical equipment, and other industrial applications."
      },
      {
            "name": "Hekat Fluidics",
            "website": "https://hekat.com",
            "description": "Develops optofluidic instruments for detecting, counting, and sorting biological nano-objects. Its NanoSorter isolates exosomes and other nanoparticles, enabling researchers to study biomarkers that could support earlier cancer detection and personalized treatments."
      }
]$json$
  ) AS (name TEXT, website TEXT, description TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  'funding_deals_july_2026_week4',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 1b: Link organizations to primary and secondary cities
-- (COALESCE preserves any city link an existing org already has)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Arrakis Technologies", "city": "London", "secondary_city": "Paris" },
      { "org_name": "Ascendance Flight Technologies", "city": "Toulouse", "secondary_city": null },
      { "org_name": "Carsup", "city": "Orléans", "secondary_city": null },
      { "org_name": "Brenus Pharma", "city": "Lyon", "secondary_city": null },
      { "org_name": "Womed", "city": "Montpellier", "secondary_city": null },
      { "org_name": "Recupere Metals", "city": "Paris", "secondary_city": null },
      { "org_name": "Hekat Fluidics", "city": "Pessac", "secondary_city": null }
]$json$
  ) AS (org_name TEXT, city TEXT, secondary_city TEXT)
)
UPDATE organizations o SET
  city_id = COALESCE(o.city_id, c1.id),
  secondary_city_id = COALESCE(o.secondary_city_id, c2.id),
  updated_at = NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
LEFT JOIN cities c2 ON c2.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.secondary_city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 2: Create funding rounds (6 -- Recupere Metals excluded, see header)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Arrakis Technologies",
            "stage": "series_a",
            "amount_eur": 25.8,
            "currency_original": "USD",
            "amount_original": 30000000,
            "announced_date": "2026-07-20",
            "notes": "$30M Series A led by Blossom Capital, six months after founding, bringing total funding to $38M. Model-agnostic platform that embeds forward-deployed engineers with industrial customers to deploy AI agents into procurement, logistics and other operational systems without replacing existing software. Says it has signed NYSE-listed customers across energy, logistics and industrial sectors, with one cutting procurement cycle times by 90%. Funding supports tripling headcount, platform/security development and new offices in New York and the Middle East. HQ in London with a Paris office. Founded January 2026. Source: Fortune, Tech EU."
      },
      {
            "name": "Ascendance Flight Technologies",
            "stage": "series_b",
            "amount_eur": 14.0,
            "currency_original": "EUR",
            "amount_original": 14000000,
            "announced_date": "2026-07-20",
            "notes": "€14M Series B extension to support development, testing and industrialization of its hybrid-electric VTOL aircraft for regional air mobility. Founded 2018. Investors include Bpifrance, Dassault, Expansion, Celeste Management, M Capital, Aris Occitane and Sowefund. Source: CFNews."
      },
      {
            "name": "Carsup",
            "stage": "series_b",
            "amount_eur": 12.0,
            "currency_original": "EUR",
            "amount_original": 12000000,
            "announced_date": "2026-07-20",
            "notes": "€12M from existing investors, including the Ferrari family which increased its participation. Founded 2019; manages the full lifecycle of collector and exceptional vehicles across 25 concierge locations in France and Europe, with 2,000+ vehicles representing over €400M in assets. Plans a new European market in Q4 2026, expects to double revenue to €30M this year and surpass 3,000 vehicles under management. Attached to the existing 'Carsup' organization. Source: Maddyness."
      },
      {
            "name": "Brenus Pharma",
            "stage": "series_a",
            "amount_eur": 11.0,
            "currency_original": "EUR",
            "amount_original": 11000000,
            "announced_date": "2026-07-20",
            "notes": "€11M Series A extension to advance its clinical-stage immuno-oncology pipeline; brings total raised since inception to €38M. New international investors Sambrinvest and Korea Omega Investment Corp (first Asia-Pacific backing). Funds completion of the Phase I program for STC-1010 (microsatellite-stable metastatic colorectal cancer) and a move toward a multi-asset pipeline. Recorded as a Series A extension (no dedicated extension stage). Attached to the existing 'Brenus Pharma' organization. Source: LinkedIn."
      },
      {
            "name": "Womed",
            "stage": "seed",
            "amount_eur": 7.1,
            "currency_original": "EUR",
            "amount_original": 7100000,
            "announced_date": "2026-07-20",
            "notes": "€7.1M (€5M from professional investors plus €2.1M crowdfunded via Lita and Capital Cell, more than double the €1M target) to expand commercialization of Womed Leaf and advance treatments for fibroids and acute uterine bleeding. Womed Leaf received FDA marketing authorization in September 2025 and has treated 3,000+ patients. Founded in Montpellier in 2018. Round labeled Seed per source. Attached to the existing 'Womed' organization. Source: J'aime les startups."
      },
      {
            "name": "Hekat Fluidics",
            "stage": "seed",
            "amount_eur": 2.4,
            "currency_original": "EUR",
            "amount_original": 2400000,
            "announced_date": "2026-07-20",
            "notes": "€2.4M to industrialize and commercialize its NanoSorter, described as the first fluorescence-activated nano-flow sorting system. Initially targeting research labs, with expansion into biopharma and eventually clinical diagnostics, and entry into the US and Japanese markets targeted from 2028. Attached to the existing 'hekat fluidics' organization (SIREN 948147293). Source: Sud Ouest."
      }
]$json$
  ) AS (name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT,
        amount_original NUMERIC, announced_date TEXT, notes TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, notes, created_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  s.stage::funding_stage,
  s.amount_eur,
  s.currency_original,
  s.amount_original,
  s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original != 'EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END,
  FALSE,
  'funding_deals_july_2026_week4',
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Blossom Capital" },
      { "name": "Accel" },
      { "name": "GFC" },
      { "name": "MainObject" },
      { "name": "Rerail" },
      { "name": "Olivier Pomel" },
      { "name": "Olivier Godement" },
      { "name": "Junaid Hussain" },
      { "name": "Business Angels" },
      { "name": "Bpifrance" },
      { "name": "Dassault" },
      { "name": "Expansion" },
      { "name": "Celeste Management" },
      { "name": "M Capital" },
      { "name": "Aris Occitane" },
      { "name": "Sowefund" },
      { "name": "Ferrari family" },
      { "name": "Sambrinvest" },
      { "name": "Korea Omega Investment Corp" },
      { "name": "Angelor" },
      { "name": "UI Investissement" },
      { "name": "Crédit Agricole" },
      { "name": "Noshaq" },
      { "name": "Orsa" },
      { "name": "BIO JAG" },
      { "name": "IRDI Capital Investissement" },
      { "name": "CEMAG" },
      { "name": "CANTRAK" },
      { "name": "Lita" },
      { "name": "Capital Cell" },
      { "name": "Hervé Ariditty" },
      { "name": "Nicolas Kompalitch" },
      { "name": "Région Nouvelle-Aquitaine" }
]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  'funding_deals_july_2026_week4',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors (Recupere Metals excluded)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Blossom Capital", "is_lead": true },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Accel", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "GFC", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "MainObject", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Rerail", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Olivier Pomel", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Olivier Godement", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Junaid Hussain", "is_lead": false },
      { "org_name": "Arrakis Technologies", "announced_date": "2026-07-20", "amount_eur": 25.8, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Bpifrance", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Dassault", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Expansion", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Celeste Management", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "M Capital", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Aris Occitane", "is_lead": false },
      { "org_name": "Ascendance Flight Technologies", "announced_date": "2026-07-20", "amount_eur": 14.0, "investor_name": "Sowefund", "is_lead": false },
      { "org_name": "Carsup", "announced_date": "2026-07-20", "amount_eur": 12.0, "investor_name": "Ferrari family", "is_lead": true },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Sambrinvest", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Korea Omega Investment Corp", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Angelor", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "UI Investissement", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Crédit Agricole", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Noshaq", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Orsa", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "BIO JAG", "is_lead": false },
      { "org_name": "Brenus Pharma", "announced_date": "2026-07-20", "amount_eur": 11.0, "investor_name": "Bpifrance", "is_lead": false },
      { "org_name": "Womed", "announced_date": "2026-07-20", "amount_eur": 7.1, "investor_name": "IRDI Capital Investissement", "is_lead": false },
      { "org_name": "Womed", "announced_date": "2026-07-20", "amount_eur": 7.1, "investor_name": "CEMAG", "is_lead": false },
      { "org_name": "Womed", "announced_date": "2026-07-20", "amount_eur": 7.1, "investor_name": "CANTRAK", "is_lead": false },
      { "org_name": "Womed", "announced_date": "2026-07-20", "amount_eur": 7.1, "investor_name": "Lita", "is_lead": false },
      { "org_name": "Womed", "announced_date": "2026-07-20", "amount_eur": 7.1, "investor_name": "Capital Cell", "is_lead": false },
      { "org_name": "Hekat Fluidics", "announced_date": "2026-07-20", "amount_eur": 2.4, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Hekat Fluidics", "announced_date": "2026-07-20", "amount_eur": 2.4, "investor_name": "Hervé Ariditty", "is_lead": false },
      { "org_name": "Hekat Fluidics", "announced_date": "2026-07-20", "amount_eur": 2.4, "investor_name": "Nicolas Kompalitch", "is_lead": false },
      { "org_name": "Hekat Fluidics", "announced_date": "2026-07-20", "amount_eur": 2.4, "investor_name": "Région Nouvelle-Aquitaine", "is_lead": false }
]$json$
  ) AS (org_name TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  fr.id,
  inv_org.id,
  s.is_lead,
  s.investor_name,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_july_2026_week4'
  AND (
    (fr.announced_date::TEXT = s.announced_date OR (fr.announced_date IS NULL AND s.announced_date IS NULL))
    AND (fr.amount_eur = s.amount_eur OR (fr.amount_eur IS NULL AND s.amount_eur IS NULL))
  );

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Step 4a: insert all org-sector links as non-primary (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "arrakis-technologies", "sec": "saas" },
      { "org": "arrakis-technologies", "sec": "artificial-intelligence" },
      { "org": "ascendance-flight-technologies", "sec": "spacetech-aerospace" },
      { "org": "ascendance-flight-technologies", "sec": "cleantech" },
      { "org": "carsup", "sec": "artificial-intelligence" },
      { "org": "carsup", "sec": "mobility" },
      { "org": "brenus-pharma", "sec": "biotech" },
      { "org": "womed", "sec": "medtech" },
      { "org": "recupere-metals", "sec": "deeptech" },
      { "org": "hekat-fluidics", "sec": "biotech" }
]$json$
  ) AS (org TEXT, sec TEXT)
)
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s
JOIN organizations o ON o.slug = s.org
JOIN sectors sec ON sec.slug = s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: promote the primary sector only for orgs that do not already have one
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "arrakis-technologies", "sec": "saas" },
      { "org": "ascendance-flight-technologies", "sec": "spacetech-aerospace" },
      { "org": "carsup", "sec": "artificial-intelligence" },
      { "org": "brenus-pharma", "sec": "biotech" },
      { "org": "womed", "sec": "medtech" },
      { "org": "hekat-fluidics", "sec": "biotech" }
]$json$
  ) AS (org TEXT, sec TEXT)
)
UPDATE organization_sectors os SET is_primary = TRUE
FROM source s
JOIN organizations o ON o.slug = s.org
JOIN sectors sec ON sec.slug = s.sec
WHERE os.organization_id = o.id AND os.sector_id = sec.id
  AND NOT EXISTS (
    SELECT 1 FROM organization_sectors x
    WHERE x.organization_id = o.id AND x.is_primary = TRUE
  );

-- =============================================================================
-- Step 5: Create people records for founders
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "full_name": "Rafael Fernandez-Quintanilla Loeillet-Rouzier", "first_name": "Rafael", "last_name": "Fernandez-Quintanilla Loeillet-Rouzier" },
      { "full_name": "Haroun Beltaifa", "first_name": "Haroun", "last_name": "Beltaifa" },
      { "full_name": "Romain Fouilland", "first_name": "Romain", "last_name": "Fouilland" },
      { "full_name": "Mikhail Galkov", "first_name": "Mikhail", "last_name": "Galkov" },
      { "full_name": "Jean-Christophe Lambert", "first_name": "Jean-Christophe", "last_name": "Lambert" },
      { "full_name": "Thibault Baldivia", "first_name": "Thibault", "last_name": "Baldivia" },
      { "full_name": "Samuel Lelarge", "first_name": "Samuel", "last_name": "Lelarge" },
      { "full_name": "Benoit Pinteur", "first_name": "Benoit", "last_name": "Pinteur" },
      { "full_name": "Jacques Gardette", "first_name": "Jacques", "last_name": "Gardette" },
      { "full_name": "Gilles Devillers", "first_name": "Gilles", "last_name": "Devillers" },
      { "full_name": "Gonzague Issenmann", "first_name": "Gonzague", "last_name": "Issenmann" },
      { "full_name": "Xavier Garric", "first_name": "Xavier", "last_name": "Garric" },
      { "full_name": "Stéphanie Huberlant", "first_name": "Stéphanie", "last_name": "Huberlant" },
      { "full_name": "Katie Marsh", "first_name": "Katie", "last_name": "Marsh" },
      { "full_name": "Julien Vaïssette", "first_name": "Julien", "last_name": "Vaïssette" },
      { "full_name": "Sophie Bourzeix", "first_name": "Sophie", "last_name": "Bourzeix" },
      { "full_name": "Mathias Girault", "first_name": "Mathias", "last_name": "Girault" },
      { "full_name": "Philippe Graindorge", "first_name": "Philippe", "last_name": "Graindorge" }
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(),
  s.full_name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.first_name,
  s.last_name,
  'funding_deals_july_2026_week4',
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations (includes Recupere Metals founders)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Arrakis Technologies", "founder_name": "Rafael Fernandez-Quintanilla Loeillet-Rouzier" },
      { "org_name": "Arrakis Technologies", "founder_name": "Haroun Beltaifa" },
      { "org_name": "Arrakis Technologies", "founder_name": "Romain Fouilland" },
      { "org_name": "Arrakis Technologies", "founder_name": "Mikhail Galkov" },
      { "org_name": "Ascendance Flight Technologies", "founder_name": "Jean-Christophe Lambert" },
      { "org_name": "Ascendance Flight Technologies", "founder_name": "Thibault Baldivia" },
      { "org_name": "Carsup", "founder_name": "Samuel Lelarge" },
      { "org_name": "Brenus Pharma", "founder_name": "Benoit Pinteur" },
      { "org_name": "Brenus Pharma", "founder_name": "Jacques Gardette" },
      { "org_name": "Brenus Pharma", "founder_name": "Gilles Devillers" },
      { "org_name": "Womed", "founder_name": "Gonzague Issenmann" },
      { "org_name": "Womed", "founder_name": "Xavier Garric" },
      { "org_name": "Womed", "founder_name": "Stéphanie Huberlant" },
      { "org_name": "Recupere Metals", "founder_name": "Katie Marsh" },
      { "org_name": "Recupere Metals", "founder_name": "Julien Vaïssette" },
      { "org_name": "Hekat Fluidics", "founder_name": "Sophie Bourzeix" },
      { "org_name": "Hekat Fluidics", "founder_name": "Mathias Girault" },
      { "org_name": "Hekat Fluidics", "founder_name": "Philippe Graindorge" }
]$json$
  ) AS (org_name TEXT, founder_name TEXT)
)
INSERT INTO organization_people (
  id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  p.id,
  'Founder',
  TRUE, TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN people p ON p.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.founder_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- =============================================================================
-- Step 7: Attach SIREN legal entities to companies (French). Idempotent:
-- existing SIRENs (Ascendance, Carsup, Brenus, Womed, Recupere, Hekat) are
-- skipped; effectively only Arrakis Technologies gets a newly attached SIREN.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "arrakis-technologies", "siren": "101352367" },
      { "org": "ascendance-flight-technologies", "siren": "834577215" },
      { "org": "carsup", "siren": "851614594" },
      { "org": "brenus-pharma", "siren": "802549030" },
      { "org": "womed", "siren": "837961978" },
      { "org": "hekat-fluidics", "siren": "948147293" }
]$json$
  ) AS (org TEXT, siren TEXT)
)
INSERT INTO legal_entities (
  id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  o.name,
  s.siren,
  'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id = o.id),
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le
  WHERE le.organization_id = o.id AND le.siren = s.siren
);

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count
FROM funding_rounds WHERE source_name = 'funding_deals_july_2026_week4'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_july_2026_week4'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_july_2026_week4';
