#!/usr/bin/env python3
"""
Generate a one-off migration that adds 11 additional April 2026 funding deals
provided as a structured payload (no CSV intermediary).

Output: supabase/migrations/phase12/02_add_april_2026_additional_deals.sql

Mirrors the phase10/phase12 pattern:
  cities → sectors → orgs (upsert) → legal entities → org-city / org-sector
  → funding rounds → investor orgs → round-investor links (DISTINCT ON safety)

Existing orgs are enriched (no duplicate row); the new round is appended.
source_name = 'funding_deals_april_2026' (matches the prior batch).
"""

import json
import re
import unicodedata
from pathlib import Path

OUT = Path('supabase/migrations/phase12/02_add_april_2026_additional_deals.sql')
SOURCE_NAME = 'funding_deals_april_2026'
ANNOUNCED_DATE = '2026-04-01'  # stand-in (no per-deal dates provided)


def slugify(name: str) -> str:
    s = unicodedata.normalize('NFKD', name)
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


# Each deal: org info + sectors (first = primary) + round + investors (first = lead)
DEALS = [
    {
        "name": "EVA",
        "website": "http://eva.gg/",
        "description": "EVA operates immersive esports arenas combining virtual reality and physical movement, enabling players to compete in large-scale free-roam VR environments that blend gaming and sport.",
        "siren": "890142995",
        "city": "Montreuil",
        "sectors": ["Gaming", "Entertainment", "SportsTech"],
        "stage": "growth",
        "amount_eur": 35.0,
        "investors": ["Raise Invest"],
        "notes": "EVA raised €35M from Raise Invest to accelerate international expansion, strengthen its footprint in France, and expand its game portfolio. The company operates 70 VR arenas globally and plans further growth in Europe, the US, and Asia while launching new gaming formats to broaden its audience. (Source: Les Echos)",
    },
    {
        "name": "Rosi",
        "website": "https://www.rosi-solar.com",
        "description": "ROSI develops high-value recycling technology for end-of-life solar panels, recovering strategic raw materials such as silicon, silver, copper, aluminum, and glass to build a circular supply chain for the photovoltaic industry.",
        "siren": "833310204",
        "city": "Seyssins",
        "sectors": ["ClimateTech", "CleanTech", "Circular Economy", "Energy", "Recycling"],
        "stage": "series_b",
        "amount_eur": 20.0,
        "investors": ["InnoEnergy", "CMA CGM", "European Innovation Council", "G3T", "Finadvice"],
        "notes": "ROSI secured over €20M combining Series B equity and public grants to scale its solar panel recycling operations across Europe, including a new industrial plant in Spain with 10,000-ton annual capacity. The funding supports the rollout of standardized production lines and strengthens Europe's circular supply chain for photovoltaic materials. (Source: Rosi Solar)",
    },
    {
        "name": "SquareMind",
        "website": "https://www.squaremind.com/",
        "description": "SquareMind develops AI-powered imaging solutions and robotic systems to assist dermatologists in detecting skin cancers. Its flagship robot, Swan, scans and maps the entire skin surface to identify anomalies and improve diagnostic accuracy and follow-up.",
        "siren": "845228303",
        "city": "Paris",
        "sectors": ["MedTech", "Artificial Intelligence", "Robotics", "Digital Health"],
        "stage": "series_a",
        "amount_eur": 15.3,
        "investors": ["Deeptech 2030", "Bpifrance", "Sonder Capital", "Adamed", "Calm/Storm Ventures", "Teampact Ventures"],
        "notes": "SquareMind raised $18M to commercialize its robotic imaging system, Swan, in Europe and the US. The solution enables full-body skin scanning in minutes, using AI to detect anomalies and support dermatologists amid growing demand and limited medical capacity. (Source: Tech Funding News)",
    },
    {
        "name": "Audion",
        "website": "https://www.audion.ai/",
        "description": "Audion provides technology and services for advertisers and media agencies to run and optimize digital audio advertising campaigns across platforms. Its AI suite enables automated campaign creation, targeting, and distribution based on real-time signals and trends.",
        "siren": "834462061",
        "city": "Paris",
        "sectors": ["AdTech", "Artificial Intelligence", "MarTech"],
        "stage": "series_b",
        "amount_eur": 11.9,
        "investors": ["Elevation Capital Partners", "Founders Future", "Bpifrance"],
        "notes": "Audion raised $15M to accelerate its international expansion, particularly in the US, where it is opening a New York office. The company is scaling its AI-powered audio advertising platform, Audion AI, aiming to capitalize on the convergence of audio, video, and AI to become a global leader in digital audio advertising. (Source: Maddyness, Axios)",
    },
    {
        "name": "Losanje",
        "website": "https://www.losanje.com",
        "description": "Losanje industrializes textile upcycling by collecting production offcuts from manufacturers, sorting and transforming them into high-value secondary raw materials, enabling a circular supply chain without degrading material quality.",
        "siren": "887845485",
        "city": "Nièvre",
        "sectors": ["ClimateTech"],
        "stage": "seed",
        "amount_eur": 6.7,
        "investors": ["UI Investissement", "Crédit Agricole", "Lita", "Evolem", "Albo", "ADEME"],
        "notes": "Losanje raised €6.7M to scale its industrial upcycling platform, including expanding production capacity and structuring logistics to process textile manufacturing waste at scale. The funding reflects growing regulatory and industrial demand for circular solutions in the textile sector, as the company transitions from pilot phase to industrial deployment. (Source: Melles)",
    },
    {
        "name": "Virvolt",
        "website": "https://virvolt.fr/",
        "description": "Virvolt designs and industrializes electric motor systems for bicycles, focusing on open, repairable, and durable motorization to reduce dependence on proprietary and imported systems.",
        "siren": "845358332",
        "city": "Paris",
        "sectors": ["Mobility", "CleanTech", "Hardware"],
        "stage": "series_a",
        "amount_eur": 3.0,
        "investors": ["CoopVenture", "AfriMobility", "Business Angels", "ADEME", "France 2030"],
        "notes": "Virvolt raised €3M to accelerate the industrialization of its electric bike motors in France and expand its European network of partner workshops. The company is scaling a locally manufactured, repairable motor standard as an alternative to dominant closed and imported systems, with production already underway at Renault's Flins Refactory. (Source: Le Journal des Entreprises)",
    },
    {
        "name": "Tolergyx",
        "website": "https://tolergyx.com/",
        "description": "Tolergyx develops oral immunotherapy solutions for peanut allergies, leveraging its GIDOIT® technology to deliver allergens directly to the intestine, aiming to improve tolerance, safety, and patient adherence compared to traditional oral approaches.",
        "siren": "999106412",
        "city": "Clermont-Ferrand",
        "sectors": ["BioTech", "HealthTech"],
        "stage": "seed",
        "amount_eur": 3.0,
        "investors": ["Business Angels"],
        "notes": "Tolergyx raised €6M (split between €3M equity and €3M non-dilutive financing) to advance its peanut allergy immunotherapy through regulatory, clinical, and industrial milestones. The funding will support preparation of a Phase IIb trial, regulatory interactions with the FDA and EMA, and GMP manufacturing scale-up as the biotech moves from academic research to clinical development. (Source: Infonet)",
    },
    {
        "name": "Askleia",
        "website": "https://askleia.tech/",
        "description": "Askleia develops technologies to optimize the extraction and purification of biomolecules from culture media, a critical and cost-intensive step in biopharmaceutical manufacturing.",
        "siren": "900474842",
        "city": "Aubagne",
        "sectors": ["BioTech", "DeepTech"],
        "stage": "pre_seed",
        "amount_eur": 2.3,
        "investors": ["iXcore"],
        "notes": "The company raised €2.3M, primarily from existing investors and iXcore, and rebranded as Askleia to reflect its strategic focus on biomanufacturing optimization. The funding will support its development in improving purification processes, a key cost driver in biologics production. (Source: Le Journal des Entreprises)",
    },
    {
        "name": "Faactopi",
        "website": "https://www.faactopi.com",
        "description": "Faactopi develops reconfigurable manufacturing systems combining software and modular production lines, enabling industrial players to adapt production in real time to constraints and demand. Its Aarms software designs and optimizes flexible production lines using digital twins.",
        "siren": "918208828",
        "city": "Vénissieux",
        "sectors": ["Robotics", "DeepTech"],
        "stage": "seed",
        "amount_eur": 3.0,
        "investors": ["Innovacom"],
        "notes": "Faactopi raised €3M to scale its reconfigurable factory model and expand its industrial capabilities. The funding will support R&D, hiring, and equipment investments as the startup industrializes its adaptive manufacturing platform, which is already used in sectors such as space, defense, and IoT. (Source: Les Echos, Usine Nouvelle)",
    },
    {
        "name": "Hectarea",
        "website": "https://www.hectarea.io/",
        "description": "Hectarea is an investment platform that enables individuals to invest in agricultural land and projects, supporting farmers while democratizing access to farmland as an asset class.",
        "siren": "921590279",
        "city": "Castres-Gironde",
        "sectors": ["AgriTech", "FinTech", "ClimateTech"],
        "stage": "seed",
        "amount_eur": 1.5,
        "investors": ["Invess Île-de-France Amorçage", "KissKissBankBank Studio", "Albo", "Business Angels"],
        "notes": "Hectarea raised €1.5M to scale its platform, democratizing investment in agricultural land, with a minimum ticket lowered to €100. The startup has already mobilized over €4.5M from its community and will use the funds to expand access to farmland investment, support new farmers, and finance sustainable agricultural projects across France. (Source: LinkedIn, Tridge, Le Journal des Entreprises)",
    },
    {
        "name": "Novaleum",
        "website": "https://www.novaleum.com/",
        "description": "Novaleum develops a patented technology to convert fat waste from wastewater treatment into valuable resources, including biogas, biofuels, and recycled water, through a compact, containerized industrial process.",
        "siren": "941816951",
        "city": "Lyon",
        "sectors": ["ClimateTech", "Energy"],
        "stage": "seed",
        "amount_eur": 1.0,
        "investors": ["Business Angels", "Bpifrance"],
        "notes": "Novaleum raised over €1M in seed funding to build an industrial demonstrator at the Pierre-Bénite wastewater treatment plant in 2027. The startup's containerized 'NovaBox' system transforms fat waste into bioenergy and reusable materials, targeting large-scale deployment across wastewater facilities and industrial clients, with ambitions to deploy 300 units in France over the next decade. (Source: Mesinfos)",
    },
]


def main() -> None:
    cities = sorted({d["city"] for d in DEALS})
    sectors = sorted({s for d in DEALS for s in d["sectors"]})
    orgs = [
        {"name": d["name"], "website": d["website"], "description": d["description"],
         "siren": d["siren"], "city": d["city"]}
        for d in DEALS
    ]
    legal = [{"name": d["name"], "siren": d["siren"]} for d in DEALS if d["siren"]]
    org_city = [{"org_slug": slugify(d["name"]), "city": d["city"]} for d in DEALS]

    sector_links = []
    for d in DEALS:
        for i, s in enumerate(d["sectors"]):
            sector_links.append({
                "org_slug": slugify(d["name"]),
                "sector": s,
                "is_primary": i == 0,
            })

    rounds = [
        {"org_slug": slugify(d["name"]), "stage": d["stage"],
         "amount_eur": d["amount_eur"], "announced_date": ANNOUNCED_DATE,
         "notes": d["notes"]}
        for d in DEALS
    ]

    investors_set = sorted({inv for d in DEALS for inv in d["investors"]})
    investors_payload = [{"name": n} for n in investors_set]

    round_invs = []
    for d in DEALS:
        for i, inv in enumerate(d["investors"]):
            round_invs.append({
                "org_slug": slugify(d["name"]),
                "announced_date": ANNOUNCED_DATE,
                "amount_eur": d["amount_eur"],
                "investor_name": inv,
                "is_lead": i == 0,
            })

    def j(payload):
        return json.dumps(payload, ensure_ascii=False)

    sql = f"""-- =============================================================================
-- April 2026 Funding Deals — additional batch ({len(DEALS)} records)
-- =============================================================================
-- source_name: '{SOURCE_NAME}'
-- announced_date: '{ANNOUNCED_DATE}' (stand-in; user-supplied payload had no per-deal dates)
-- Existing organizations are upserted (no duplicate row created); new
-- funding_rounds are inserted regardless.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: Cities ({len(cities)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j([{"name": c} for c in cities])}$json$
  ) AS (name TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'France',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 2: Sectors ({len(sectors)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j([{"name": s} for s in sectors])}$json$
  ) AS (name TEXT)
)
INSERT INTO sectors (id, name, slug, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 3: Organizations (upsert by slug; enrich missing fields)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(orgs)}$json$
  ) AS (name TEXT, website TEXT, description TEXT, siren TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  '{SOURCE_NAME}',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  legacy_id = COALESCE(organizations.legacy_id, EXCLUDED.legacy_id),
  updated_at = NOW();

-- Step 4: Legal entities for orgs with SIREN ({len(legal)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(legal)}$json$
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
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);

-- Step 5: Link organizations to cities ({len(org_city)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(org_city)}$json$
  ) AS (org_slug TEXT, city TEXT)
)
UPDATE organizations o
SET city_id = c.id, updated_at = NOW()
FROM source s
JOIN cities c ON c.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE o.slug = s.org_slug AND o.city_id IS NULL;

-- Step 6: Link organizations to sectors ({len(sector_links)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(sector_links)}$json$
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
JOIN sectors sec ON sec.slug = lower(regexp_replace(regexp_replace(unaccent(s.sector), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM organization_sectors os
  WHERE os.organization_id = o.id AND os.sector_id = sec.id
);

-- Step 7: Funding rounds ({len(rounds)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(rounds)}$json$
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
  '{SOURCE_NAME}',
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
WHERE NOT EXISTS (
  SELECT 1 FROM funding_rounds fr
  WHERE fr.organization_id = o.id
  AND fr.source_name = '{SOURCE_NAME}'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
);

-- Step 8: Investor organizations ({len(investors_set)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(investors_payload)}$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  '{SOURCE_NAME}',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 9: Round-investor links ({len(round_invs)})
-- DISTINCT ON guards against any within-batch (round, investor) collisions.
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(round_invs)}$json$
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
  JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
  JOIN funding_rounds fr ON fr.organization_id = o.id
    AND fr.source_name = '{SOURCE_NAME}'
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
"""

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(sql, encoding='utf-8')
    print(f"Wrote {OUT} ({OUT.stat().st_size:,} bytes)")
    print(f"  cities: {len(cities)}  sectors: {len(sectors)}  orgs: {len(orgs)}")
    print(f"  legal entities: {len(legal)}  org-city: {len(org_city)}  org-sector: {len(sector_links)}")
    print(f"  rounds: {len(rounds)}  investor orgs: {len(investors_set)}  round-inv: {len(round_invs)}")


if __name__ == '__main__':
    main()
