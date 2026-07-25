-- =============================================================================
-- July 2026 Funding Deals Import
-- =============================================================================
-- Imports 8 funding deals from July 2026.
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links
-- (city_id + secondary_city_id). Amounts stored in millions (DB convention).
-- Organizations that already exist (matched by slug) get the new round attached
-- rather than being duplicated.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Ensure the secondary_city_id column exists. It is present on the live
-- database (added out-of-band) but is not created by any committed migration,
-- so this guard lets the import also succeed on a fresh database build.
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
            "name": "La Rochelle",
            "country": "France"
      },
      {
            "name": "Saint-Herblain",
            "country": "France"
      },
      {
            "name": "Paris",
            "country": "France"
      },
      {
            "name": "Lille",
            "country": "France"
      },
      {
            "name": "Meudon",
            "country": "France"
      },
      {
            "name": "Massy",
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
VALUES (uuid_generate_v4(), 'Semiconductors', 'semiconductors', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (8 startups; existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Elixir Aircraft",
            "website": "https://www.elixir-aircraft.com",
            "description": "Elixir Aircraft is a French aircraft manufacturer developing next-generation carbon-fiber training aircraft. Its flagship Elixir aircraft is certified in Europe and the U.S., offering lower operating costs, improved safety, and significantly lower emissions for pilot training."
      },
      {
            "name": "Amarris",
            "website": "https://www.amarris.fr",
            "description": "Amarris is a French accounting group that develops its own digital technologies to support accounting firms, helping them modernize operations while maintaining technological independence."
      },
      {
            "name": "Tallano",
            "website": "https://www.tallano.eu",
            "description": "Tallano Technologies develops TAMIC\u00ae, a patented brake particle capture system that reduces fine particulate emissions from automotive and rail braking systems, helping manufacturers comply with future Euro 7 emissions standards."
      },
      {
            "name": "Loumo",
            "website": "https://www.loumo.fr",
            "description": "Loumo develops an AI-powered examination platform that manages the entire assessment lifecycle, from exam design and logistics to secure online testing, automated grading and performance analytics."
      },
      {
            "name": "My Hospitel",
            "website": "https://www.myhospitel.com",
            "description": "My Hospitel develops the first digital platform for managing France's h\u00e9bergement temporaire non m\u00e9dicalis\u00e9 (HTNM), enabling hospitals to book hotel accommodation for eligible patients while reducing administrative burden, improving bed utilization, and streamlining reimbursement."
      },
      {
            "name": "VSORA",
            "website": "https://www.vsora.com",
            "description": "VSORA is a French fabless semiconductor company developing AI inference accelerators for data centers. Its flagship processor, Jotunn8, is designed to overcome the memory wall bottleneck, improving AI inference performance, latency, power efficiency, and total cost of ownership. The company taped out Jotunn8 in 2025 and has entered manufacturing with partners including TSMC and Global Unichip (GUC)."
      },
      {
            "name": "DESTIA Group",
            "website": "https://www.destia.fr",
            "description": "Destia is a leading French provider of home care services for seniors and people with disabilities, operating a network of 180 agencies across France and Europe. The group also offers inclusive housing solutions and professional training for home care workers."
      },
      {
            "name": "HTDS",
            "website": "https://www.htds.fr",
            "description": "HTDS (Hi-Tech Detection Systems Group) is a French distributor and service provider of high-tech detection, inspection and safety systems, supplying X-ray scanners, explosive and metal detectors, laboratory instruments and radiation protection solutions to governments and industrial customers across Europe, Africa and the Middle East."
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
  'funding_deals_july_2026',
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
            "org_name": "Elixir Aircraft",
            "city": "La Rochelle",
            "secondary_city": null
      },
      {
            "org_name": "Amarris",
            "city": "Saint-Herblain",
            "secondary_city": null
      },
      {
            "org_name": "Tallano",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Loumo",
            "city": "Lille",
            "secondary_city": null
      },
      {
            "org_name": "My Hospitel",
            "city": null,
            "secondary_city": null
      },
      {
            "org_name": "VSORA",
            "city": "Meudon",
            "secondary_city": null
      },
      {
            "org_name": "DESTIA Group",
            "city": null,
            "secondary_city": null
      },
      {
            "org_name": "HTDS",
            "city": "Massy",
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
            "name": "Elixir Aircraft",
            "stage": "growth",
            "amount_eur": 45.0,
            "currency_original": "EUR",
            "amount_original": 45000000,
            "announced_date": "2026-07-01",
            "notes": "\u20ac45M growth round to consolidate production, expand in the US and Asia (India), and launch the Equinox program. Backlog exceeding 300 aircraft; ~250 employees. Source: Presse Citron."
      },
      {
            "name": "Amarris",
            "stage": "growth",
            "amount_eur": 39.0,
            "currency_original": "EUR",
            "amount_original": 39000000,
            "announced_date": "2026-07-01",
            "notes": "\u20ac39M (\u20ac15M equity + \u20ac24M unitranche debt from CIC Private Debt and Zencap) to fund acquisitions and its proprietary platform. 50,000+ clients. Source: FinYear."
      },
      {
            "name": "Tallano",
            "stage": "growth",
            "amount_eur": 10.0,
            "currency_original": "EUR",
            "amount_original": 10000000,
            "announced_date": "2026-07-01",
            "notes": "\u20ac10M from existing investors and European family offices to commercialize TAMIC ahead of Euro 7 (2030). 56+ patents across 12 countries. Attached to existing 'Tallano' organization. Source: LinkedIn."
      },
      {
            "name": "Loumo",
            "stage": "seed",
            "amount_eur": 1.0,
            "currency_original": "EUR",
            "amount_original": 1000000,
            "announced_date": "2026-07-01",
            "notes": "\u20ac1M seed to build a sovereign European alternative for AI-powered exam grading. Founded 2024; focused on French higher education first. Source: LinkedIn."
      },
      {
            "name": "My Hospitel",
            "stage": "seed",
            "amount_eur": 0.2,
            "currency_original": "EUR",
            "amount_original": 200000,
            "announced_date": "2026-07-01",
            "notes": "\u20ac200K+ raised (66% of target) via Angels Sant\u00e9, INSA Angels and a Tudigo crowdfunding campaign. Platform for non-medical patient hotel stays. Sources: Tudigo, France Angels."
      },
      {
            "name": "VSORA",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-07-01",
            "notes": "Undisclosed minority investment led by Ardian Semiconductor alongside management, existing shareholders and new strategic investors. Amount and valuation not disclosed. Source: Ardian."
      },
      {
            "name": "DESTIA Group",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-07-01",
            "notes": "Undisclosed growth round with new investors and reinvesting shareholders. Revenue grew from \u20ac100M to \u20ac250M+ since 2021; 180 agencies across France, Spain, Ireland, Germany, Switzerland. Attached to existing 'DESTIA Group' organization. Source: Investors In Healthcare."
      },
      {
            "name": "HTDS",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-07-01",
            "notes": "Investment round led by AfricInvest Europe's French-African Fund 3 with Trocadero, Bpifrance and SGCP; Abenex reinvesting. Present in 14 countries; Africa is 50%+ of revenue. Source: Africinvest."
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
  'funding_deals_july_2026',
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
            "name": "Abenex"
      },
      {
            "name": "AfricInvest Europe"
      },
      {
            "name": "Angels Sant\u00e9"
      },
      {
            "name": "Apr\u00e8s demain"
      },
      {
            "name": "Ardian"
      },
      {
            "name": "Ark\u00e9a Capital"
      },
      {
            "name": "Azulis"
      },
      {
            "name": "BNP Paribas D\u00e9veloppement"
      },
      {
            "name": "Bpifrance"
      },
      {
            "name": "CIC Private Debt"
      },
      {
            "name": "CloudHQ"
      },
      {
            "name": "Cr\u00e9dit Agricole"
      },
      {
            "name": "European Innovation Council"
      },
      {
            "name": "France 2030"
      },
      {
            "name": "Innovacom"
      },
      {
            "name": "INSA Angels"
      },
      {
            "name": "MACSF"
      },
      {
            "name": "MEAC"
      },
      {
            "name": "Naxicap Partners"
      },
      {
            "name": "NJJ Capital"
      },
      {
            "name": "Odyss\u00e9e Venture"
      },
      {
            "name": "Omnes Capital"
      },
      {
            "name": "Otium Capital"
      },
      {
            "name": "Ouest Croissance"
      },
      {
            "name": "PRVF"
      },
      {
            "name": "Siparex ETI"
      },
      {
            "name": "Soci\u00e9t\u00e9 G\u00e9n\u00e9rale Capital Partenaires"
      },
      {
            "name": "Three Hills"
      },
      {
            "name": "Trocadero Capital Partners"
      },
      {
            "name": "Tudigo"
      },
      {
            "name": "Turenne Sant\u00e9"
      },
      {
            "name": "VYV"
      },
      {
            "name": "XAnge"
      },
      {
            "name": "Zencap"
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
  'funding_deals_july_2026',
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
            "org_name": "Elixir Aircraft",
            "announced_date": "2026-07-01",
            "amount_eur": 45.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Elixir Aircraft",
            "announced_date": "2026-07-01",
            "amount_eur": 45.0,
            "investor_name": "Odyss\u00e9e Venture",
            "is_lead": false
      },
      {
            "org_name": "Elixir Aircraft",
            "announced_date": "2026-07-01",
            "amount_eur": 45.0,
            "investor_name": "Innovacom",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "Naxicap Partners",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "BNP Paribas D\u00e9veloppement",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "Ark\u00e9a Capital",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "Ouest Croissance",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "CIC Private Debt",
            "is_lead": false
      },
      {
            "org_name": "Amarris",
            "announced_date": "2026-07-01",
            "amount_eur": 39.0,
            "investor_name": "Zencap",
            "is_lead": false
      },
      {
            "org_name": "Tallano",
            "announced_date": "2026-07-01",
            "amount_eur": 10.0,
            "investor_name": "MEAC",
            "is_lead": false
      },
      {
            "org_name": "Tallano",
            "announced_date": "2026-07-01",
            "amount_eur": 10.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Tallano",
            "announced_date": "2026-07-01",
            "amount_eur": 10.0,
            "investor_name": "France 2030",
            "is_lead": false
      },
      {
            "org_name": "Tallano",
            "announced_date": "2026-07-01",
            "amount_eur": 10.0,
            "investor_name": "PRVF",
            "is_lead": false
      },
      {
            "org_name": "My Hospitel",
            "announced_date": "2026-07-01",
            "amount_eur": 0.2,
            "investor_name": "Angels Sant\u00e9",
            "is_lead": false
      },
      {
            "org_name": "My Hospitel",
            "announced_date": "2026-07-01",
            "amount_eur": 0.2,
            "investor_name": "INSA Angels",
            "is_lead": false
      },
      {
            "org_name": "My Hospitel",
            "announced_date": "2026-07-01",
            "amount_eur": 0.2,
            "investor_name": "Tudigo",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Ardian",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "XAnge",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Omnes Capital",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "European Innovation Council",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Otium Capital",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "NJJ Capital",
            "is_lead": false
      },
      {
            "org_name": "VSORA",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "CloudHQ",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Three Hills",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Turenne Sant\u00e9",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "VYV",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Siparex ETI",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "BNP Paribas D\u00e9veloppement",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "MACSF",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Azulis",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Apr\u00e8s demain",
            "is_lead": false
      },
      {
            "org_name": "DESTIA Group",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Cr\u00e9dit Agricole",
            "is_lead": false
      },
      {
            "org_name": "HTDS",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "AfricInvest Europe",
            "is_lead": true
      },
      {
            "org_name": "HTDS",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Trocadero Capital Partners",
            "is_lead": false
      },
      {
            "org_name": "HTDS",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "HTDS",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Soci\u00e9t\u00e9 G\u00e9n\u00e9rale Capital Partenaires",
            "is_lead": false
      },
      {
            "org_name": "HTDS",
            "announced_date": "2026-07-01",
            "amount_eur": null,
            "investor_name": "Abenex",
            "is_lead": false
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
  AND fr.source_name = 'funding_deals_july_2026'
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
            "org": "elixir-aircraft",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "amarris",
            "sec": "fintech"
      },
      {
            "org": "tallano",
            "sec": "cleantech"
      },
      {
            "org": "tallano",
            "sec": "mobility"
      },
      {
            "org": "loumo",
            "sec": "edtech"
      },
      {
            "org": "loumo",
            "sec": "artificial-intelligence"
      },
      {
            "org": "my-hospitel",
            "sec": "healthtech"
      },
      {
            "org": "my-hospitel",
            "sec": "digital-health"
      },
      {
            "org": "vsora",
            "sec": "artificial-intelligence"
      },
      {
            "org": "vsora",
            "sec": "semiconductors"
      },
      {
            "org": "destia-group",
            "sec": "healthtech"
      },
      {
            "org": "htds",
            "sec": "defensetech"
      },
      {
            "org": "htds",
            "sec": "deeptech"
      },
      {
            "org": "htds",
            "sec": "hardware"
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
            "org": "elixir-aircraft",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "amarris",
            "sec": "fintech"
      },
      {
            "org": "tallano",
            "sec": "cleantech"
      },
      {
            "org": "loumo",
            "sec": "edtech"
      },
      {
            "org": "my-hospitel",
            "sec": "healthtech"
      },
      {
            "org": "vsora",
            "sec": "artificial-intelligence"
      },
      {
            "org": "destia-group",
            "sec": "healthtech"
      },
      {
            "org": "htds",
            "sec": "defensetech"
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
            "full_name": "Arthur L\u00e9opold-L\u00e9ger",
            "first_name": "Arthur",
            "last_name": "L\u00e9opold-L\u00e9ger"
      },
      {
            "full_name": "Cyril Champenois",
            "first_name": "Cyril",
            "last_name": "Champenois"
      },
      {
            "full_name": "Nicolas Migault",
            "first_name": "Nicolas",
            "last_name": "Migault"
      },
      {
            "full_name": "Claude Robin",
            "first_name": "Claude",
            "last_name": "Robin"
      },
      {
            "full_name": "Jean-Louis Juchault",
            "first_name": "Jean-Louis",
            "last_name": "Juchault"
      },
      {
            "full_name": "Louis Desry",
            "first_name": "Louis",
            "last_name": "Desry"
      },
      {
            "full_name": "Vincent Boisset",
            "first_name": "Vincent",
            "last_name": "Boisset"
      },
      {
            "full_name": "Khaled Maalej",
            "first_name": "Khaled",
            "last_name": "Maalej"
      },
      {
            "full_name": "Xavier Mura",
            "first_name": "Xavier",
            "last_name": "Mura"
      },
      {
            "full_name": "Louaye Moudarres",
            "first_name": "Louaye",
            "last_name": "Moudarres"
      },
      {
            "full_name": "Farice Moudarres",
            "first_name": "Farice",
            "last_name": "Moudarres"
      },
      {
            "full_name": "Etienne Moudarres",
            "first_name": "Etienne",
            "last_name": "Moudarres"
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
  'funding_deals_july_2026',
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
            "org_name": "Elixir Aircraft",
            "founder_name": "Arthur L\u00e9opold-L\u00e9ger"
      },
      {
            "org_name": "Elixir Aircraft",
            "founder_name": "Cyril Champenois"
      },
      {
            "org_name": "Elixir Aircraft",
            "founder_name": "Nicolas Migault"
      },
      {
            "org_name": "Amarris",
            "founder_name": "Claude Robin"
      },
      {
            "org_name": "Tallano",
            "founder_name": "Jean-Louis Juchault"
      },
      {
            "org_name": "Loumo",
            "founder_name": "Louis Desry"
      },
      {
            "org_name": "My Hospitel",
            "founder_name": "Vincent Boisset"
      },
      {
            "org_name": "VSORA",
            "founder_name": "Khaled Maalej"
      },
      {
            "org_name": "DESTIA Group",
            "founder_name": "Xavier Mura"
      },
      {
            "org_name": "HTDS",
            "founder_name": "Louaye Moudarres"
      },
      {
            "org_name": "HTDS",
            "founder_name": "Farice Moudarres"
      },
      {
            "org_name": "HTDS",
            "founder_name": "Etienne Moudarres"
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
-- Step 7: Attach SIREN legal entities to companies
-- =============================================================================
-- Inserts one legal_entities row per company that has a SIREN, but only when
-- that company does not already carry that exact SIREN (idempotent). is_primary
-- is set only when the organization has no other legal entity yet.
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org": "amarris",
            "siren": "791428766"
      },
      {
            "org": "tallano",
            "siren": "753991728"
      },
      {
            "org": "loumo",
            "siren": "933177255"
      },
      {
            "org": "my-hospitel",
            "siren": "880973813"
      },
      {
            "org": "vsora",
            "siren": "811657519"
      },
      {
            "org": "destia-group",
            "siren": "818520017"
      },
      {
            "org": "htds",
            "siren": "922396890"
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
-- Verification queries
-- =============================================================================
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count
FROM funding_rounds WHERE source_name = 'funding_deals_july_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_july_2026'
UNION ALL
SELECT 'Founder Links (new people)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_july_2026';
