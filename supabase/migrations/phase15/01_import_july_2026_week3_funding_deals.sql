-- =============================================================================
-- July 2026 Funding Deals Import (week of July 13-17)
-- =============================================================================
-- Imports 5 funding deals from July 2026 (week of July 13-17).
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links.
-- Amounts stored in millions (DB convention). Organizations that already exist
-- (matched by slug: Syntetica, NeoCem) get the new round attached rather than
-- being duplicated. Mio is a US corporation (Tools for Sovereignty, Inc.,
-- Delaware file 10174062) recorded in Step 7b; NeoCem's holding company
-- (NeoCem Holding, SIREN 948591300) is added alongside the operating company
-- (SIREN 900399908) in Step 7c.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Paris",
            "country": "France"
      },
      {
            "name": "Hallennes-lez-Haubourdin",
            "country": "France"
      },
      {
            "name": "Grenoble",
            "country": "France"
      }
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
-- Step 0c: Ensure new sectors exist (idempotent)
-- =============================================================================
INSERT INTO sectors (id, name, slug, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'Augmented Reality', 'augmented-reality', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Syntetica",
            "website": "https://syntetica.co/",
            "description": "Syntetica is a deeptech company developing a low-temperature chemical recycling process for mixed nylon textile waste. Its technology can recycle Nylon 6 and Nylon 6,6 together without separating them first, while preserving other materials such as elastane for potential reuse."
      },
      {
            "name": "NeoCem",
            "website": "https://www.neocem.com/",
            "description": "NeoCem develops and produces low-carbon binders for the cement, construction and public-works industries, designed to reduce the sector's carbon footprint."
      },
      {
            "name": "Engo",
            "website": "https://fr.engoeyewear.com",
            "description": "Engo is a smart-glasses company developing lightweight augmented-reality eyewear for runners, cyclists and triathletes. Its glasses use an integrated Micro OLED display to project real-time performance data directly into the athlete's field of vision."
      },
      {
            "name": "Stracker",
            "website": "https://www.stracker.tech/",
            "description": "Stracker is an AI-powered platform for managing time-critical freight shipments in sectors including aerospace, luxury and medtech. It coordinates transport providers, tracks shipments, and manages customs documentation for sensitive, urgent deliveries."
      },
      {
            "name": "Mio",
            "website": "https://www.mio.xyz/",
            "description": "Mio is an AI-powered workplace colleague embedded directly inside Slack. It connects with company tools and data to understand organizational context, automate recurring tasks, maintain information, and execute work across systems including Google Workspace, Notion, Linear, HubSpot and GitHub."
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
  'funding_deals_july_2026_week3',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 1b: Link organizations to primary and secondary cities
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org_name": "Syntetica",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "NeoCem",
            "city": "Hallennes-lez-Haubourdin",
            "secondary_city": null
      },
      {
            "org_name": "Engo",
            "city": "Grenoble",
            "secondary_city": null
      },
      {
            "org_name": "Stracker",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Mio",
            "city": "Paris",
            "secondary_city": null
      }
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
-- Step 2: Create funding rounds
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Syntetica",
            "stage": "series_a",
            "amount_eur": 25.8,
            "currency_original": "USD",
            "amount_original": 30000000,
            "announced_date": "2026-07-13",
            "notes": "$30M Series A to build its first commercial demonstration plant with Michelin at the Center for Sustainable Materials in Clermont-Ferrand, targeting commercial volumes within 18 months. Team growing from ~22 to 45 by end of 2027; expanding into automotive and specialty chemicals. Source: Tech Funding News."
      },
      {
            "name": "NeoCem",
            "stage": "series_b",
            "amount_eur": 17.0,
            "currency_original": "EUR",
            "amount_original": 17000000,
            "announced_date": "2026-07-13",
            "notes": "\u20ac17M Series B to accelerate industrial deployment of its low-carbon binder technology. Large-scale production has begun at its first operational facility near Chantilly (Oise), ramping toward 200,000 tonnes annual capacity. Attached to the existing 'NeoCem' organization. Source: FinYear."
      },
      {
            "name": "Engo",
            "stage": "series_a",
            "amount_eur": 5.1,
            "currency_original": "EUR",
            "amount_original": 5100000,
            "announced_date": "2026-07-13",
            "notes": "\u20ac5.1M Series A to accelerate international expansion and R&D in miniaturization and embedded displays. 90% of revenue comes from outside France (half from the US); plans ~20 new hires across optics, mechanical engineering, software and data. Registered as Engo Eyewear (SIREN 498198167). Source: Maddyness."
      },
      {
            "name": "Stracker",
            "stage": "seed",
            "amount_eur": 2.5,
            "currency_original": "EUR",
            "amount_original": 2500000,
            "announced_date": "2026-07-13",
            "notes": "\u20ac2.5M seed from Blast Club and Bpifrance to develop its Stracker360 platform, expand its AI capabilities and grow its team, alongside a build-up strategy to create a global network of critical-freight specialists across Europe and the US. Source: La Tribune."
      },
      {
            "name": "Mio",
            "stage": "pre_seed",
            "amount_eur": 1.9,
            "currency_original": "EUR",
            "amount_original": 1900000,
            "announced_date": "2026-07-13",
            "notes": "\u20ac1.9M ($2.2M) pre-Seed co-led by Fabric.vc and Topology.vc to expand its engineering team, accelerate product development and grow across Europe and the US. 100+ companies use it daily, with early customers reporting ~8.2 hours saved per week. Registered as a US corporation, Tools for Sovereignty, Inc. (Delaware file 10174062). Source: EU-Startups."
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
  'funding_deals_july_2026_week3',
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
      {
            "name": "Blast"
      },
      {
            "name": "Bpifrance"
      },
      {
            "name": "Cr\u00e9dit Mutuel Impact"
      },
      {
            "name": "EQT Ventures"
      },
      {
            "name": "Fabric.vc"
      },
      {
            "name": "Holnest"
      },
      {
            "name": "Lululemon"
      },
      {
            "name": "MAS Holdings"
      },
      {
            "name": "Odyss\u00e9e Venture"
      },
      {
            "name": "Side Capital"
      },
      {
            "name": "SWEN Capital Partners"
      },
      {
            "name": "Topology.vc"
      },
      {
            "name": "Ventech"
      }
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
  'funding_deals_july_2026_week3',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org_name": "Syntetica",
            "announced_date": "2026-07-13",
            "amount_eur": 25.8,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Syntetica",
            "announced_date": "2026-07-13",
            "amount_eur": 25.8,
            "investor_name": "SWEN Capital Partners",
            "is_lead": false
      },
      {
            "org_name": "Syntetica",
            "announced_date": "2026-07-13",
            "amount_eur": 25.8,
            "investor_name": "EQT Ventures",
            "is_lead": false
      },
      {
            "org_name": "Syntetica",
            "announced_date": "2026-07-13",
            "amount_eur": 25.8,
            "investor_name": "Lululemon",
            "is_lead": false
      },
      {
            "org_name": "Syntetica",
            "announced_date": "2026-07-13",
            "amount_eur": 25.8,
            "investor_name": "MAS Holdings",
            "is_lead": false
      },
      {
            "org_name": "NeoCem",
            "announced_date": "2026-07-13",
            "amount_eur": 17.0,
            "investor_name": "Cr\u00e9dit Mutuel Impact",
            "is_lead": true
      },
      {
            "org_name": "Engo",
            "announced_date": "2026-07-13",
            "amount_eur": 5.1,
            "investor_name": "Ventech",
            "is_lead": false
      },
      {
            "org_name": "Engo",
            "announced_date": "2026-07-13",
            "amount_eur": 5.1,
            "investor_name": "Odyss\u00e9e Venture",
            "is_lead": false
      },
      {
            "org_name": "Engo",
            "announced_date": "2026-07-13",
            "amount_eur": 5.1,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Stracker",
            "announced_date": "2026-07-13",
            "amount_eur": 2.5,
            "investor_name": "Blast",
            "is_lead": true
      },
      {
            "org_name": "Stracker",
            "announced_date": "2026-07-13",
            "amount_eur": 2.5,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Stracker",
            "announced_date": "2026-07-13",
            "amount_eur": 2.5,
            "investor_name": "Side Capital",
            "is_lead": false
      },
      {
            "org_name": "Stracker",
            "announced_date": "2026-07-13",
            "amount_eur": 2.5,
            "investor_name": "Holnest",
            "is_lead": false
      },
      {
            "org_name": "Mio",
            "announced_date": "2026-07-13",
            "amount_eur": 1.9,
            "investor_name": "Fabric.vc",
            "is_lead": true
      },
      {
            "org_name": "Mio",
            "announced_date": "2026-07-13",
            "amount_eur": 1.9,
            "investor_name": "Topology.vc",
            "is_lead": true
      }
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
  AND fr.source_name = 'funding_deals_july_2026_week3'
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
      {
            "org": "syntetica",
            "sec": "deeptech"
      },
      {
            "org": "syntetica",
            "sec": "circular-economy"
      },
      {
            "org": "neocem",
            "sec": "climatetech"
      },
      {
            "org": "neocem",
            "sec": "deeptech"
      },
      {
            "org": "engo",
            "sec": "sportstech"
      },
      {
            "org": "engo",
            "sec": "augmented-reality"
      },
      {
            "org": "stracker",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mio",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mio",
            "sec": "saas"
      }
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
      {
            "org": "syntetica",
            "sec": "deeptech"
      },
      {
            "org": "neocem",
            "sec": "climatetech"
      },
      {
            "org": "engo",
            "sec": "sportstech"
      },
      {
            "org": "stracker",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mio",
            "sec": "artificial-intelligence"
      }
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
      {
            "full_name": "Marco Bertone",
            "first_name": "Marco",
            "last_name": "Bertone"
      },
      {
            "full_name": "Louis Monsigny",
            "first_name": "Louis",
            "last_name": "Monsigny"
      },
      {
            "full_name": "Christophe Deboffe",
            "first_name": "Christophe",
            "last_name": "Deboffe"
      },
      {
            "full_name": "Benjamin Constant",
            "first_name": "Benjamin",
            "last_name": "Constant"
      },
      {
            "full_name": "\u00c9ric Marcellin-Dibon",
            "first_name": "\u00c9ric",
            "last_name": "Marcellin-Dibon"
      },
      {
            "full_name": "Fabrice Berger Duquene",
            "first_name": "Fabrice",
            "last_name": "Berger Duquene"
      },
      {
            "full_name": "Axel Bandiaky",
            "first_name": "Axel",
            "last_name": "Bandiaky"
      },
      {
            "full_name": "Augustin de Boisse",
            "first_name": "Augustin",
            "last_name": "de Boisse"
      },
      {
            "full_name": "Arthaud Mesnard",
            "first_name": "Arthaud",
            "last_name": "Mesnard"
      }
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
  'funding_deals_july_2026_week3',
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org_name": "Syntetica",
            "founder_name": "Marco Bertone"
      },
      {
            "org_name": "Syntetica",
            "founder_name": "Louis Monsigny"
      },
      {
            "org_name": "NeoCem",
            "founder_name": "Christophe Deboffe"
      },
      {
            "org_name": "NeoCem",
            "founder_name": "Benjamin Constant"
      },
      {
            "org_name": "Engo",
            "founder_name": "\u00c9ric Marcellin-Dibon"
      },
      {
            "org_name": "Engo",
            "founder_name": "Fabrice Berger Duquene"
      },
      {
            "org_name": "Stracker",
            "founder_name": "Axel Bandiaky"
      },
      {
            "org_name": "Stracker",
            "founder_name": "Augustin de Boisse"
      },
      {
            "org_name": "Mio",
            "founder_name": "Arthaud Mesnard"
      }
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
-- Step 7: Attach SIREN legal entities to companies (French)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org": "syntetica",
            "siren": "981347362"
      },
      {
            "org": "engo",
            "siren": "498198167"
      },
      {
            "org": "stracker",
            "siren": "831129531"
      }
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
-- Step 7b: Record Mio's US legal entity (Tools for Sovereignty, Inc.)
-- =============================================================================
-- Mio is registered as a US corporation in Delaware (file number 10174062), so it
-- has no French SIREN. The Delaware file number is stored in legacy_id (there is no
-- dedicated non-French registration-number column); legal_form/registered_city/country
-- capture the US registration.
INSERT INTO legal_entities (
  id, organization_id, legal_name, legal_form, registered_city, country,
  is_primary, legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  'Tools for Sovereignty, Inc.',
  'Corporation (Delaware)',
  'Delaware',
  'USA',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id = o.id),
  'funding_deals_july_2026_week3',
  'DE-10174062',
  NOW(), NOW()
FROM organizations o
WHERE o.slug = 'mio'
  AND NOT EXISTS (
    SELECT 1 FROM legal_entities le
    WHERE le.organization_id = o.id AND le.legal_name = 'Tools for Sovereignty, Inc.'
  );

-- =============================================================================
-- Step 7c: Add NeoCem Holding (SIREN 948591300) as a second legal entity
-- =============================================================================
-- NeoCem has two French legal entities: the operating company NeoCem
-- (SIREN 900399908, already present and primary) and its holding company
-- NeoCem Holding (SIREN 948591300). The holding is added as a non-primary
-- legal entity, keeping the operating company as primary. Idempotent.
INSERT INTO legal_entities (
  id, organization_id, legal_name, siren, country, is_primary, legacy_source, created_at, updated_at
)
SELECT uuid_generate_v4(), o.id, 'NeoCem Holding', '948591300', 'France', FALSE,
  'funding_deals_july_2026_week3', NOW(), NOW()
FROM organizations o
WHERE o.slug = 'neocem'
  AND NOT EXISTS (
    SELECT 1 FROM legal_entities le
    WHERE le.organization_id = o.id AND le.siren = '948591300'
  );

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count
FROM funding_rounds WHERE source_name = 'funding_deals_july_2026_week3'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_july_2026_week3'
UNION ALL
SELECT 'Founder Links (new people)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_july_2026_week3';
