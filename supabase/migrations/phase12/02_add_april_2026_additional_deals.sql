-- =============================================================================
-- April 2026 Funding Deals — additional batch (11 records)
-- =============================================================================
-- source_name: 'funding_deals_april_2026'
-- announced_date: '2026-04-01' (stand-in; user-supplied payload had no per-deal dates)
-- Existing organizations are upserted (no duplicate row created); new
-- funding_rounds are inserted regardless.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: Cities (9)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "Aubagne"}, {"name": "Castres-Gironde"}, {"name": "Clermont-Ferrand"}, {"name": "Lyon"}, {"name": "Montreuil"}, {"name": "Nièvre"}, {"name": "Paris"}, {"name": "Seyssins"}, {"name": "Vénissieux"}]$json$
  ) AS (name TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  'France',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 2: Sectors (21)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "AdTech"}, {"name": "AgriTech"}, {"name": "Artificial Intelligence"}, {"name": "BioTech"}, {"name": "Circular Economy"}, {"name": "CleanTech"}, {"name": "ClimateTech"}, {"name": "DeepTech"}, {"name": "Digital Health"}, {"name": "Energy"}, {"name": "Entertainment"}, {"name": "FinTech"}, {"name": "Gaming"}, {"name": "Hardware"}, {"name": "HealthTech"}, {"name": "MarTech"}, {"name": "MedTech"}, {"name": "Mobility"}, {"name": "Recycling"}, {"name": "Robotics"}, {"name": "SportsTech"}]$json$
  ) AS (name TEXT)
)
INSERT INTO sectors (id, name, slug, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 3: Organizations (upsert by slug; enrich missing fields)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "EVA", "website": "http://eva.gg/", "description": "EVA operates immersive esports arenas combining virtual reality and physical movement, enabling players to compete in large-scale free-roam VR environments that blend gaming and sport.", "siren": "890142995", "city": "Montreuil"}, {"name": "Rosi", "website": "https://www.rosi-solar.com", "description": "ROSI develops high-value recycling technology for end-of-life solar panels, recovering strategic raw materials such as silicon, silver, copper, aluminum, and glass to build a circular supply chain for the photovoltaic industry.", "siren": "833310204", "city": "Seyssins"}, {"name": "SquareMind", "website": "https://www.squaremind.com/", "description": "SquareMind develops AI-powered imaging solutions and robotic systems to assist dermatologists in detecting skin cancers. Its flagship robot, Swan, scans and maps the entire skin surface to identify anomalies and improve diagnostic accuracy and follow-up.", "siren": "845228303", "city": "Paris"}, {"name": "Audion", "website": "https://www.audion.ai/", "description": "Audion provides technology and services for advertisers and media agencies to run and optimize digital audio advertising campaigns across platforms. Its AI suite enables automated campaign creation, targeting, and distribution based on real-time signals and trends.", "siren": "834462061", "city": "Paris"}, {"name": "Losanje", "website": "https://www.losanje.com", "description": "Losanje industrializes textile upcycling by collecting production offcuts from manufacturers, sorting and transforming them into high-value secondary raw materials, enabling a circular supply chain without degrading material quality.", "siren": "887845485", "city": "Nièvre"}, {"name": "Virvolt", "website": "https://virvolt.fr/", "description": "Virvolt designs and industrializes electric motor systems for bicycles, focusing on open, repairable, and durable motorization to reduce dependence on proprietary and imported systems.", "siren": "845358332", "city": "Paris"}, {"name": "Tolergyx", "website": "https://tolergyx.com/", "description": "Tolergyx develops oral immunotherapy solutions for peanut allergies, leveraging its GIDOIT® technology to deliver allergens directly to the intestine, aiming to improve tolerance, safety, and patient adherence compared to traditional oral approaches.", "siren": "999106412", "city": "Clermont-Ferrand"}, {"name": "Askleia", "website": "https://askleia.tech/", "description": "Askleia develops technologies to optimize the extraction and purification of biomolecules from culture media, a critical and cost-intensive step in biopharmaceutical manufacturing.", "siren": "900474842", "city": "Aubagne"}, {"name": "Faactopi", "website": "https://www.faactopi.com", "description": "Faactopi develops reconfigurable manufacturing systems combining software and modular production lines, enabling industrial players to adapt production in real time to constraints and demand. Its Aarms software designs and optimizes flexible production lines using digital twins.", "siren": "918208828", "city": "Vénissieux"}, {"name": "Hectarea", "website": "https://www.hectarea.io/", "description": "Hectarea is an investment platform that enables individuals to invest in agricultural land and projects, supporting farmers while democratizing access to farmland as an asset class.", "siren": "921590279", "city": "Castres-Gironde"}, {"name": "Novaleum", "website": "https://www.novaleum.com/", "description": "Novaleum develops a patented technology to convert fat waste from wastewater treatment into valuable resources, including biogas, biofuels, and recycled water, through a compact, containerized industrial process.", "siren": "941816951", "city": "Lyon"}]$json$
  ) AS (name TEXT, website TEXT, description TEXT, siren TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  'funding_deals_april_2026',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  legacy_id = COALESCE(organizations.legacy_id, EXCLUDED.legacy_id),
  updated_at = NOW();

-- Step 4: Legal entities for orgs with SIREN (11)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "EVA", "siren": "890142995"}, {"name": "Rosi", "siren": "833310204"}, {"name": "SquareMind", "siren": "845228303"}, {"name": "Audion", "siren": "834462061"}, {"name": "Losanje", "siren": "887845485"}, {"name": "Virvolt", "siren": "845358332"}, {"name": "Tolergyx", "siren": "999106412"}, {"name": "Askleia", "siren": "900474842"}, {"name": "Faactopi", "siren": "918208828"}, {"name": "Hectarea", "siren": "921590279"}, {"name": "Novaleum", "siren": "941816951"}]$json$
  ) AS (name TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  o.id,
  s.name,
  s.siren,
  'France',
  TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);

-- Step 5: Link organizations to cities (11)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"org_slug": "eva", "city": "Montreuil"}, {"org_slug": "rosi", "city": "Seyssins"}, {"org_slug": "squaremind", "city": "Paris"}, {"org_slug": "audion", "city": "Paris"}, {"org_slug": "losanje", "city": "Nièvre"}, {"org_slug": "virvolt", "city": "Paris"}, {"org_slug": "tolergyx", "city": "Clermont-Ferrand"}, {"org_slug": "askleia", "city": "Aubagne"}, {"org_slug": "faactopi", "city": "Vénissieux"}, {"org_slug": "hectarea", "city": "Castres-Gironde"}, {"org_slug": "novaleum", "city": "Lyon"}]$json$
  ) AS (org_slug TEXT, city TEXT)
)
UPDATE organizations o
SET city_id = c.id, updated_at = NOW()
FROM source s
JOIN cities c ON c.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = s.org_slug AND o.city_id IS NULL;

-- Step 6: Link organizations to sectors (30)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"org_slug": "eva", "sector": "Gaming", "is_primary": true}, {"org_slug": "eva", "sector": "Entertainment", "is_primary": false}, {"org_slug": "eva", "sector": "SportsTech", "is_primary": false}, {"org_slug": "rosi", "sector": "ClimateTech", "is_primary": true}, {"org_slug": "rosi", "sector": "CleanTech", "is_primary": false}, {"org_slug": "rosi", "sector": "Circular Economy", "is_primary": false}, {"org_slug": "rosi", "sector": "Energy", "is_primary": false}, {"org_slug": "rosi", "sector": "Recycling", "is_primary": false}, {"org_slug": "squaremind", "sector": "MedTech", "is_primary": true}, {"org_slug": "squaremind", "sector": "Artificial Intelligence", "is_primary": false}, {"org_slug": "squaremind", "sector": "Robotics", "is_primary": false}, {"org_slug": "squaremind", "sector": "Digital Health", "is_primary": false}, {"org_slug": "audion", "sector": "AdTech", "is_primary": true}, {"org_slug": "audion", "sector": "Artificial Intelligence", "is_primary": false}, {"org_slug": "audion", "sector": "MarTech", "is_primary": false}, {"org_slug": "losanje", "sector": "ClimateTech", "is_primary": true}, {"org_slug": "virvolt", "sector": "Mobility", "is_primary": true}, {"org_slug": "virvolt", "sector": "CleanTech", "is_primary": false}, {"org_slug": "virvolt", "sector": "Hardware", "is_primary": false}, {"org_slug": "tolergyx", "sector": "BioTech", "is_primary": true}, {"org_slug": "tolergyx", "sector": "HealthTech", "is_primary": false}, {"org_slug": "askleia", "sector": "BioTech", "is_primary": true}, {"org_slug": "askleia", "sector": "DeepTech", "is_primary": false}, {"org_slug": "faactopi", "sector": "Robotics", "is_primary": true}, {"org_slug": "faactopi", "sector": "DeepTech", "is_primary": false}, {"org_slug": "hectarea", "sector": "AgriTech", "is_primary": true}, {"org_slug": "hectarea", "sector": "FinTech", "is_primary": false}, {"org_slug": "hectarea", "sector": "ClimateTech", "is_primary": false}, {"org_slug": "novaleum", "sector": "ClimateTech", "is_primary": true}, {"org_slug": "novaleum", "sector": "Energy", "is_primary": false}]$json$
  ) AS (org_slug TEXT, sector TEXT, is_primary BOOLEAN)
)
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT
  uuid_generate_v4(),
  o.id,
  sec.id,
  CASE WHEN s.is_primary AND NOT EXISTS (SELECT 1 FROM organization_sectors os2 WHERE os2.organization_id = o.id AND os2.is_primary = TRUE) THEN TRUE ELSE FALSE END,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN sectors sec ON sec.slug = lower(regexp_replace(regexp_replace(unaccent(s.sector), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM organization_sectors os
  WHERE os.organization_id = o.id AND os.sector_id = sec.id
);

-- Step 7: Funding rounds (11)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"org_slug": "eva", "stage": "growth", "amount_eur": 35.0, "announced_date": "2026-04-01", "notes": "EVA raised €35M from Raise Invest to accelerate international expansion, strengthen its footprint in France, and expand its game portfolio. The company operates 70 VR arenas globally and plans further growth in Europe, the US, and Asia while launching new gaming formats to broaden its audience. (Source: Les Echos)"}, {"org_slug": "rosi", "stage": "series_b", "amount_eur": 20.0, "announced_date": "2026-04-01", "notes": "ROSI secured over €20M combining Series B equity and public grants to scale its solar panel recycling operations across Europe, including a new industrial plant in Spain with 10,000-ton annual capacity. The funding supports the rollout of standardized production lines and strengthens Europe's circular supply chain for photovoltaic materials. (Source: Rosi Solar)"}, {"org_slug": "squaremind", "stage": "series_a", "amount_eur": 15.3, "announced_date": "2026-04-01", "notes": "SquareMind raised $18M to commercialize its robotic imaging system, Swan, in Europe and the US. The solution enables full-body skin scanning in minutes, using AI to detect anomalies and support dermatologists amid growing demand and limited medical capacity. (Source: Tech Funding News)"}, {"org_slug": "audion", "stage": "series_b", "amount_eur": 11.9, "announced_date": "2026-04-01", "notes": "Audion raised $15M to accelerate its international expansion, particularly in the US, where it is opening a New York office. The company is scaling its AI-powered audio advertising platform, Audion AI, aiming to capitalize on the convergence of audio, video, and AI to become a global leader in digital audio advertising. (Source: Maddyness, Axios)"}, {"org_slug": "losanje", "stage": "seed", "amount_eur": 6.7, "announced_date": "2026-04-01", "notes": "Losanje raised €6.7M to scale its industrial upcycling platform, including expanding production capacity and structuring logistics to process textile manufacturing waste at scale. The funding reflects growing regulatory and industrial demand for circular solutions in the textile sector, as the company transitions from pilot phase to industrial deployment. (Source: Melles)"}, {"org_slug": "virvolt", "stage": "series_a", "amount_eur": 3.0, "announced_date": "2026-04-01", "notes": "Virvolt raised €3M to accelerate the industrialization of its electric bike motors in France and expand its European network of partner workshops. The company is scaling a locally manufactured, repairable motor standard as an alternative to dominant closed and imported systems, with production already underway at Renault's Flins Refactory. (Source: Le Journal des Entreprises)"}, {"org_slug": "tolergyx", "stage": "seed", "amount_eur": 3.0, "announced_date": "2026-04-01", "notes": "Tolergyx raised €6M (split between €3M equity and €3M non-dilutive financing) to advance its peanut allergy immunotherapy through regulatory, clinical, and industrial milestones. The funding will support preparation of a Phase IIb trial, regulatory interactions with the FDA and EMA, and GMP manufacturing scale-up as the biotech moves from academic research to clinical development. (Source: Infonet)"}, {"org_slug": "askleia", "stage": "pre_seed", "amount_eur": 2.3, "announced_date": "2026-04-01", "notes": "The company raised €2.3M, primarily from existing investors and iXcore, and rebranded as Askleia to reflect its strategic focus on biomanufacturing optimization. The funding will support its development in improving purification processes, a key cost driver in biologics production. (Source: Le Journal des Entreprises)"}, {"org_slug": "faactopi", "stage": "seed", "amount_eur": 3.0, "announced_date": "2026-04-01", "notes": "Faactopi raised €3M to scale its reconfigurable factory model and expand its industrial capabilities. The funding will support R&D, hiring, and equipment investments as the startup industrializes its adaptive manufacturing platform, which is already used in sectors such as space, defense, and IoT. (Source: Les Echos, Usine Nouvelle)"}, {"org_slug": "hectarea", "stage": "seed", "amount_eur": 1.5, "announced_date": "2026-04-01", "notes": "Hectarea raised €1.5M to scale its platform, democratizing investment in agricultural land, with a minimum ticket lowered to €100. The startup has already mobilized over €4.5M from its community and will use the funds to expand access to farmland investment, support new farmers, and finance sustainable agricultural projects across France. (Source: LinkedIn, Tridge, Le Journal des Entreprises)"}, {"org_slug": "novaleum", "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-04-01", "notes": "Novaleum raised over €1M in seed funding to build an industrial demonstrator at the Pierre-Bénite wastewater treatment plant in 2027. The startup's containerized 'NovaBox' system transforms fat waste into bioenergy and reusable materials, targeting large-scale deployment across wastewater facilities and industrial clients, with ambitions to deploy 300 units in France over the next decade. (Source: Mesinfos)"}]$json$
  ) AS (org_slug TEXT, stage TEXT, amount_eur NUMERIC, announced_date TEXT, notes TEXT)
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
  'EUR',
  s.amount_eur * 1000000,
  NULLIF(s.announced_date, '')::DATE,
  FALSE,
  FALSE,
  'funding_deals_april_2026',
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
WHERE NOT EXISTS (
  SELECT 1 FROM funding_rounds fr
  WHERE fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_april_2026'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
);

-- Step 8: Investor organizations (28)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"name": "ADEME"}, {"name": "Adamed"}, {"name": "AfriMobility"}, {"name": "Albo"}, {"name": "Bpifrance"}, {"name": "Business Angels"}, {"name": "CMA CGM"}, {"name": "Calm/Storm Ventures"}, {"name": "CoopVenture"}, {"name": "Crédit Agricole"}, {"name": "Deeptech 2030"}, {"name": "Elevation Capital Partners"}, {"name": "European Innovation Council"}, {"name": "Evolem"}, {"name": "Finadvice"}, {"name": "Founders Future"}, {"name": "France 2030"}, {"name": "G3T"}, {"name": "InnoEnergy"}, {"name": "Innovacom"}, {"name": "Invess Île-de-France Amorçage"}, {"name": "KissKissBankBank Studio"}, {"name": "Lita"}, {"name": "Raise Invest"}, {"name": "Sonder Capital"}, {"name": "Teampact Ventures"}, {"name": "UI Investissement"}, {"name": "iXcore"}]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  'funding_deals_april_2026',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 9: Round-investor links (35)
-- DISTINCT ON guards against any within-batch (round, investor) collisions.
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[{"org_slug": "eva", "announced_date": "2026-04-01", "amount_eur": 35.0, "investor_name": "Raise Invest", "is_lead": true}, {"org_slug": "rosi", "announced_date": "2026-04-01", "amount_eur": 20.0, "investor_name": "InnoEnergy", "is_lead": true}, {"org_slug": "rosi", "announced_date": "2026-04-01", "amount_eur": 20.0, "investor_name": "CMA CGM", "is_lead": false}, {"org_slug": "rosi", "announced_date": "2026-04-01", "amount_eur": 20.0, "investor_name": "European Innovation Council", "is_lead": false}, {"org_slug": "rosi", "announced_date": "2026-04-01", "amount_eur": 20.0, "investor_name": "G3T", "is_lead": false}, {"org_slug": "rosi", "announced_date": "2026-04-01", "amount_eur": 20.0, "investor_name": "Finadvice", "is_lead": false}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Deeptech 2030", "is_lead": true}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Bpifrance", "is_lead": false}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Sonder Capital", "is_lead": false}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Adamed", "is_lead": false}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Calm/Storm Ventures", "is_lead": false}, {"org_slug": "squaremind", "announced_date": "2026-04-01", "amount_eur": 15.3, "investor_name": "Teampact Ventures", "is_lead": false}, {"org_slug": "audion", "announced_date": "2026-04-01", "amount_eur": 11.9, "investor_name": "Elevation Capital Partners", "is_lead": true}, {"org_slug": "audion", "announced_date": "2026-04-01", "amount_eur": 11.9, "investor_name": "Founders Future", "is_lead": false}, {"org_slug": "audion", "announced_date": "2026-04-01", "amount_eur": 11.9, "investor_name": "Bpifrance", "is_lead": false}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "UI Investissement", "is_lead": true}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "Crédit Agricole", "is_lead": false}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "Lita", "is_lead": false}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "Evolem", "is_lead": false}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "Albo", "is_lead": false}, {"org_slug": "losanje", "announced_date": "2026-04-01", "amount_eur": 6.7, "investor_name": "ADEME", "is_lead": false}, {"org_slug": "virvolt", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "CoopVenture", "is_lead": true}, {"org_slug": "virvolt", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "AfriMobility", "is_lead": false}, {"org_slug": "virvolt", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "Business Angels", "is_lead": false}, {"org_slug": "virvolt", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "ADEME", "is_lead": false}, {"org_slug": "virvolt", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "France 2030", "is_lead": false}, {"org_slug": "tolergyx", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "Business Angels", "is_lead": true}, {"org_slug": "askleia", "announced_date": "2026-04-01", "amount_eur": 2.3, "investor_name": "iXcore", "is_lead": true}, {"org_slug": "faactopi", "announced_date": "2026-04-01", "amount_eur": 3.0, "investor_name": "Innovacom", "is_lead": true}, {"org_slug": "hectarea", "announced_date": "2026-04-01", "amount_eur": 1.5, "investor_name": "Invess Île-de-France Amorçage", "is_lead": true}, {"org_slug": "hectarea", "announced_date": "2026-04-01", "amount_eur": 1.5, "investor_name": "KissKissBankBank Studio", "is_lead": false}, {"org_slug": "hectarea", "announced_date": "2026-04-01", "amount_eur": 1.5, "investor_name": "Albo", "is_lead": false}, {"org_slug": "hectarea", "announced_date": "2026-04-01", "amount_eur": 1.5, "investor_name": "Business Angels", "is_lead": false}, {"org_slug": "novaleum", "announced_date": "2026-04-01", "amount_eur": 1.0, "investor_name": "Business Angels", "is_lead": true}, {"org_slug": "novaleum", "announced_date": "2026-04-01", "amount_eur": 1.0, "investor_name": "Bpifrance", "is_lead": false}]$json$
  ) AS (org_slug TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
),
joined AS (
  SELECT DISTINCT ON (fr.id, inv_org.id)
    fr.id          AS funding_round_id,
    inv_org.id     AS investor_id,
    s.is_lead,
    s.investor_name
  FROM source s
  JOIN organizations o ON o.slug = s.org_slug
  JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
  JOIN funding_rounds fr ON fr.organization_id = o.id
    AND fr.source_name = 'funding_deals_april_2026'
    AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
    AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
  ORDER BY fr.id, inv_org.id, s.is_lead DESC
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  funding_round_id,
  investor_id,
  is_lead,
  investor_name,
  NOW()
FROM joined
ON CONFLICT (funding_round_id, investor_id) DO NOTHING;
