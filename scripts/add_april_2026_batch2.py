#!/usr/bin/env python3
"""
Second April 2026 batch (~29 deals across three announcement windows).
Modeled on scripts/add_april_2026_additional.py.

Output: supabase/migrations/phase14/01_add_april_2026_batch2.sql
source_name = 'funding_deals_april_2026'

Notes:
  * Novaleum omitted — already imported in phase12/02.
  * Cobl.ai imported as its own org; flag a later merge with 'thinkeo'.
  * HrFlow.ai $7M converted to EUR at 0.92 → 6.44 ; 'Pre-Series A' → seed.
  * Amounts are pre-converted to EUR millions in this file.
"""

import json
import re
import unicodedata
from pathlib import Path

OUT = Path('supabase/migrations/phase14/01_add_april_2026_batch2.sql')
SOURCE_NAME = 'funding_deals_april_2026'


def slugify(name: str) -> str:
    s = unicodedata.normalize('NFKD', name)
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


# stage: our funding_stage enum value. amount_eur: millions EUR (or None).
DEALS = [
    # ── Group 1: 2026-04-21 ──────────────────────────────────────────────────
    {"name": "Univity", "city": "Paris", "website": "https://www.univity.global/",
     "stage": "series_a", "amount_eur": 27.0, "announced_date": "2026-04-21",
     "sectors": ["SpaceTech & Aerospace", "DeepTech"],
     "investors": ["Blast", "France 2030", "Bpifrance"],
     "notes": "UNIVITY raised €27M to accelerate deployment of its space-based telecom infrastructure (uniShape VLEO 5G demonstrator). 17 LOIs signed; plans a satellite manufacturing facility near Toulouse. (Source: TechEU)"},
    {"name": "Ouidrop", "city": "Bordeaux", "website": "https://ouidrop.fr/",
     "stage": "series_a", "amount_eur": 7.0, "announced_date": "2026-04-21",
     "sectors": ["E-commerce & Retail", "Robotics", "FoodTech"],
     "investors": ["Xplore", "SWEN Capital Partners", "GSO Innovation", "Crédit Agricole", "Spring Invest"],
     "notes": "Ouidrop raised €7M to industrialize its autonomous 'Dropper' grocery pickup system near Bordeaux (up to 20 units/month), targeting 500 Droppers by 2030. (Source: French Tech Bordeaux)"},
    {"name": "Decade Energy", "city": "Paris", "website": "https://decade.energy/",
     "stage": "growth", "amount_eur": 5.0, "announced_date": "2026-04-21",
     "sectors": ["ClimateTech", "CleanTech", "Energy", "Mobility"],
     "investors": ["SET Ventures", "Eiffel Investment Group", "Ananda Impact Ventures", "Contrarian Ventures"],
     "notes": "Decade Energy raised €22M total (€5.5M equity led by SET Ventures + €16M infra capital from Eiffel) to scale electrification infrastructure for logistics depots across France and into Germany, the Nordics, and Poland. (Source: EU Startups, Eiffel, SET Ventures)"},
    {"name": "Bubble Robotics", "city": "Paris", "website": "https://www.bubble-robotics.com/",
     "stage": "seed", "amount_eur": 4.5, "announced_date": "2026-04-21",
     "sectors": ["Robotics", "DefenseTech", "ClimateTech", "Drones"],
     "investors": ["Episode 1", "Asterion Ventures", "Norrsken Evolve"],
     "notes": "Bubble Robotics raised €4.5M for autonomous ocean data collection (offshore wind, biodiversity, seabed mapping). Testing with Ifremer in Brest; first commercial product next year. (Source: Les Echos)"},
    {"name": "Axomove", "city": "Lille", "website": "https://www.axomove.com/",
     "stage": "series_a", "amount_eur": 4.0, "announced_date": "2026-04-21",
     "sectors": ["HealthTech", "MedTech", "SaaS"],
     "investors": ["Fonds Prévention Numérique", "Go Capital", "Inco Ventures", "Faraday Venture Partners"],
     "notes": "Axomove raised €4M to scale its reimbursed digital rehabilitation device. Serves 150 B2B clients and 75,000 users; extending reimbursement to musculoskeletal and metabolic conditions. (Source: Les Echos)"},
    {"name": "Five Lives", "city": "Paris", "website": "https://www.fivelives.health",
     "stage": "seed", "amount_eur": 1.9, "announced_date": "2026-04-21",
     "sectors": ["HealthTech", "Artificial Intelligence"],
     "investors": ["Open CNP", "50 Partners", "Family Ventures", "Sowefund"],
     "notes": "Five Lives raised €1.7M (plus crowdfunding up to €2.2M) for its digital therapeutic platform for Alzheimer's prevention, expanding across Europe and the US. (Source: Maddyness, Les Echos)"},
    {"name": "Sillage", "city": "Paris", "website": "https://www.getsillage.com/",
     "stage": "pre_seed", "amount_eur": 1.7, "announced_date": "2026-04-21",
     "sectors": ["Artificial Intelligence", "SaaS", "MarTech"],
     "investors": ["Super Capital", "Backfuture"],
     "notes": "Sillage raised $2M pre-seed at launch to build its sales-signal engine; part of Station F's F/ai accelerator. Early users report >50% higher reply rates. (Source: LinkedIn)"},
    {"name": "Biotech One", "city": "Marseille", "website": "https://www.biotech-one.com",
     "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-04-21",
     "sectors": ["BioTech", "HealthTech", "DeepTech"],
     "investors": ["Région Sud Investissement", "Crédit Agricole"],
     "notes": "Biotech One raised €1M to industrialize RNA-into-lipid-nanoparticle encapsulation machines (supercritical CO₂), targeting ~10 machine sales before a €5-10M Series A. (Source: LinkedIn)"},
    {"name": "minimiil", "city": "Clermont-Ferrand", "website": "https://minimiil.com/",
     "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-04-21",
     "sectors": ["FoodTech", "Artificial Intelligence"],
     "investors": ["Newfund"],
     "notes": "minimiil raised €1M to expand in France, launch in the UK, and scale production of its fermented plant-based nutritional shots, using data/AI for supply-chain forecasting. (Source: LinkedIn)"},

    # ── Group 2: 2026-04-15 ──────────────────────────────────────────────────
    {"name": "Agriodor", "city": "Rennes", "website": "https://www.agriodor.com/",
     "stage": "series_a", "amount_eur": 15.0, "announced_date": "2026-04-15",
     "sectors": ["AgriTech", "ClimateTech", "BioTech", "FoodTech"],
     "investors": ["Environmental and Solidarity Revolution Fund", "Région Sud Investissement", "CAAP Création", "Capagro", "Ambra Capital", "SWEN Capital Partners"],
     "notes": "Agriodor raised €15M to deploy its olfactory (semiochemical) biocontrol technology globally, expanding to additional crops/pests; partners include Syngenta. (Source: World Agritech Innovation)"},
    {"name": "Donecle", "city": "Toulouse", "website": "https://www.donecle.com/",
     "stage": "growth", "amount_eur": 10.0, "announced_date": "2026-04-15",
     "sectors": ["SpaceTech & Aerospace", "Artificial Intelligence", "Robotics", "Drones"],
     "investors": ["IRDI Capital Investissement", "SWEN Capital Partners", "GSO Innovation", "ARIS Occitanie"],
     "notes": "Donecle raised €10M to expand its autonomous drone aircraft-inspection platform across Europe and the US (customers incl. Lufthansa, United, DHL); predictive maintenance software due 2027. (Source: Maddyness, EU Startups)"},
    {"name": "HrFlow.ai", "city": "Paris", "website": "https://www.hrflow.ai/",
     "stage": "seed", "amount_eur": 6.44, "announced_date": "2026-04-15",
     "sectors": ["SaaS", "Artificial Intelligence"],
     "investors": ["115K", "EmergingTech Ventures", "Xavier Niel", "Jean-Baptiste Rudelle", "Thibaud Elzière", "Romain Niccoli", "Franck Le Ouay", "Flavien Kulawik", "Allen Penn", "Dominique Vidal", "Business Angels"],
     "notes": "HrFlow.ai raised $7M (~€6.44M) to scale its AI HR-data orchestration platform in the US and Europe; has processed 50M+ candidate profiles. Round labeled Pre-Series A. (Source: Maddyness, HrFlow)"},
    {"name": "Mirabelle", "city": "Paris", "website": "https://www.mirabelle.fr/",
     "stage": "seed", "amount_eur": 6.0, "announced_date": "2026-04-15",
     "sectors": ["FinTech", "InsurTech"],
     "investors": ["Groupe Renée Costes", "OCIRP", "Groupe Intériale", "Groupe Elvest", "Christophe Eberlé", "Groupe Edgide", "Eric Viet", "Business Angels"],
     "notes": "Mirabelle raised €6M and secured ACPR approval as a financing company, launching reverse-mortgage (prêt viager hypothécaire) lending for French seniors. (Source: Finyear)"},
    {"name": "Cosmyx", "city": "Épinay-sous-Sénart", "website": "https://www.cosmyx3d.com/",
     "stage": "seed", "amount_eur": 1.3, "announced_date": "2026-04-15",
     "sectors": ["DeepTech", "DefenseTech"],
     "investors": ["Paris Business Angels"],
     "notes": "Cosmyx raised €1.3M (Paris Business Angels) to accelerate commercial development of its high-speed industrial 3D printers for defense, aerospace, medical, and nuclear; holds defense contracts."},
    {"name": "Cap Atlas", "city": "Ganzeville", "website": "https://capatlas.fr/",
     "stage": "seed", "amount_eur": 0.8, "announced_date": "2026-04-15",
     "sectors": ["Drones", "SaaS"],
     "investors": ["Normandie Participations", "Normandie Littoral", "Normandie Business Angels", "Crédit Agricole Innove en Normandie", "Groupe Lhotellier"],
     "notes": "Cap Atlas raised €1.1M (incl. €300K debt) to develop its drone-based geospatial data and collaborative mapping platform for industrial and surveying use. (Source: Ouest France)"},
    {"name": "Glimpact", "city": "Paris", "website": "https://www.glimpact.com/",
     "stage": "seed", "amount_eur": 2.6, "announced_date": "2026-04-15",
     "sectors": ["ClimateTech", "SaaS", "FoodTech"],
     "investors": ["Sparkalis"],
     "notes": "Glimpact raised €2.6M from Sparkalis (Puratos), expanding its science-based environmental-impact measurement platform across food and textiles in Europe and the US. (Source: LinkedIn)"},
    {"name": "Proclus", "city": "Vitry-sur-Seine", "website": "https://proclus.eco/",
     "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-04-15",
     "sectors": ["ClimateTech", "DeepTech"],
     "investors": ["SMABTP", "Invess Île-de-France Amorçage"],
     "notes": "Proclus raised €1M to scale reuse of building equipment (circuit breakers, lighting, boilers) from tertiary buildings, addressing 200,000-300,000 tons of annual waste in France. (Source: Les Echos)"},
    {"name": "Hymalaia", "city": "Paris", "website": "https://www.hymalaia.com/",
     "stage": "seed", "amount_eur": 0.85, "announced_date": "2026-04-15",
     "sectors": ["Artificial Intelligence", "SaaS", "Cybersecurity"],
     "investors": ["Akka", "BNP Paribas", "Bpifrance"],
     "notes": "Hymalaia raised $1M to deploy its secure, governed enterprise-AI agent platform aligned with the EU AI Act, for regulated and data-sensitive industries."},
    {"name": "Oligo+", "city": "Nancy", "website": "https://www.oligoplus.com/",
     "stage": "pre_seed", "amount_eur": 0.5, "announced_date": "2026-04-15",
     "sectors": ["AgriTech", "Drones"],
     "investors": ["Hexa Sprint"],
     "notes": "Oligo+ joined the Hexa Sprint program (€500K) to scale its drone-based precision foliar-fertilization model; €1.5M bootstrapped revenue in 2025, targeting €5M by 2026. (Source: LinkedIn)"},
    {"name": "Convelio", "city": "Paris", "website": "https://www.convelio.com/",
     "stage": "series_c", "amount_eur": None, "announced_date": "2026-04-15",
     "sectors": ["Mobility", "Artificial Intelligence", "SaaS"],
     "investors": ["Forestay", "Mundi Ventures", "Acton Capital"],
     "notes": "Convelio secured a Series C (amount undisclosed) to expand its AI-powered fine-art logistics/storage in the $60B art market, launching a New York warehouse; partnered with Phillips. Shipped $1.84B of art in 2025."},

    # ── Group 3: 2026-04-08 ──────────────────────────────────────────────────
    {"name": "Aura Aero", "city": "Toulouse", "website": "https://www.aura-aero.com/",
     "stage": "series_b", "amount_eur": 50.0, "announced_date": "2026-04-08",
     "sectors": ["SpaceTech & Aerospace", "Mobility", "ClimateTech", "DefenseTech"],
     "investors": ["Safran Corporate Ventures", "EDF", "European Innovation Council", "Innovacom", "Florida Opportunity Fund", "Bpifrance", "Blast Club"],
     "notes": "Aura Aero secured €340M total (€50M Series B equity + €120M subsidies + €170M debt) to scale electric/hybrid aircraft production in France and the US; flagship ERA targets entry into service by 2030 (~700 LOIs). (Source: Maddyness)"},
    {"name": "NeuroClues", "city": "Paris", "website": "https://neuroclues.com/",
     "stage": "series_a", "amount_eur": 10.0, "announced_date": "2026-04-08",
     "sectors": ["HealthTech", "MedTech", "Artificial Intelligence"],
     "investors": ["Teampact Ventures", "White Fund", "European Innovation Council", "Invest BW", "Leansquare", "Wallonie Entreprendre", "LITA"],
     "notes": "NeuroClues raised €10M Series A to roll out its eye-movement brain-diagnostics device across Europe and into the US. CE-certified, ~30 devices deployed in 7 countries. Franco-Belgian (Brussels/Paris). (Source: Maddyness)"},
    {"name": "Cobl.ai", "city": None, "website": "https://www.cobl.ai/",
     "stage": "seed", "amount_eur": 6.0, "announced_date": "2026-04-08",
     "sectors": ["Artificial Intelligence", "SaaS"],
     "investors": ["Eurazeo", "SuperCapital-Side Angels", "Apok Invest", "Station F"],
     "notes": "Cobl.ai (formerly Thinkeo) raised €6M led by Eurazeo to scale its multi-agent AI platform for sales documents; integrates with Salesforce, Teams, Notion. Clients incl. Orano, Free, Econocom. (Source: Maddyness)"},
    {"name": "Hepta Medical", "city": "Suresnes", "website": "https://www.heptamed.com/",
     "stage": "series_a", "amount_eur": 10.0, "announced_date": "2026-04-08",
     "sectors": ["MedTech", "HealthTech"],
     "investors": ["UI Investissement", "Supernova Invest", "Bpifrance", "M&L", "Cléry", "MD Start"],
     "notes": "Hepta Medical raised an oversubscribed €10M Series A for its minimally invasive thermal-ablation platform for early-stage lung cancer, funding clinical trials and regulatory milestones. (Source: LinkedIn)"},
    {"name": "Luniwave", "city": "Paris", "website": "https://www.luniwave.com/",
     "stage": "seed", "amount_eur": 3.6, "announced_date": "2026-04-08",
     "sectors": ["ClimateTech", "TravelTech"],
     "investors": ["Banque des Territoires", "Good Only Ventures", "Lita", "SideAngels", "Inovexus"],
     "notes": "Luniwave raised €3.6M to scale its gamified hotel-sustainability platform (GreenMiles), aiming to equip 800 properties by 2027 (already ~100, incl. Accor, Marriott). (Source: LinkedIn)"},
    {"name": "Plume", "city": None, "website": "https://www.plumefinder.com/",
     "stage": "seed", "amount_eur": 3.3, "announced_date": "2026-04-08",
     "sectors": ["ClimateTech", "Artificial Intelligence"],
     "investors": ["AENU", "Y Combinator", "Kima Ventures", "Raise Sherpa", "Collab Fund"],
     "notes": "Plume raised €3.3M (led by AENU) for its AI geospatial platform helping renewable developers evaluate solar/wind/battery sites across 150+ data sources; expanding to Italy and the US. (Source: Journal du Net, Maddyness)"},
    {"name": "Playruo", "city": "Paris", "website": "https://playruo.com/",
     "stage": "seed", "amount_eur": 2.1, "announced_date": "2026-04-08",
     "sectors": ["Gaming", "SaaS"],
     "investors": ["Blast", "Kameha Ventures", "Ventech", "Maxime Demeure", "Nicolas Beraud"],
     "notes": "Playruo raised €2.1M to scale its browser-based cloud gaming platform for studios (playtesting, QA, playable ads). Partners incl. Ubisoft, Webedia, PulluP Entertainment. (Source: Pocket Gamer)"},
    {"name": "Hairdex", "city": "Marseille", "website": "https://www.hairdex.fr/",
     "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-04-08",
     "sectors": ["HealthTech"],
     "investors": ["Business Angels", "Hervest Club", "Bpifrance"],
     "notes": "Hairdex, a telehealth platform for male hair loss (androgenetic alopecia), raised €1M. (Source: LinkedIn)"},
    {"name": "Easley", "city": "Venansault", "website": "https://easley-impact.com/",
     "stage": "seed", "amount_eur": 0.5, "announced_date": "2026-04-08",
     "sectors": ["Mobility", "ClimateTech", "SaaS"],
     "investors": ["Banque Populaire Grand Ouest", "Bpifrance", "CCI Vendée", "Business Angels"],
     "notes": "Easley raised €500K to scale its Oriway EV-mobility SaaS (unified charging access, fleet cost optimization); 15,000+ users, 500,000 charging points across Europe. (Source: LinkedIn)"},
]


def main() -> None:
    cities = sorted({d["city"] for d in DEALS if d["city"]})
    sectors = sorted({s for d in DEALS for s in d["sectors"]})
    orgs = [{"name": d["name"], "website": d["website"], "city": d["city"]} for d in DEALS]
    org_city = [{"org_slug": slugify(d["name"]), "city": d["city"]} for d in DEALS if d["city"]]

    sector_links = []
    for d in DEALS:
        for i, s in enumerate(d["sectors"]):
            sector_links.append({"org_slug": slugify(d["name"]), "sector": s, "is_primary": i == 0})

    rounds = [{"org_slug": slugify(d["name"]), "stage": d["stage"],
               "amount_eur": d["amount_eur"], "announced_date": d["announced_date"],
               "notes": d["notes"]} for d in DEALS]

    investors_set = sorted({inv for d in DEALS for inv in d["investors"]})
    investors_payload = [{"name": n} for n in investors_set]

    round_invs = []
    for d in DEALS:
        for i, inv in enumerate(d["investors"]):
            round_invs.append({"org_slug": slugify(d["name"]), "announced_date": d["announced_date"],
                               "amount_eur": d["amount_eur"], "investor_name": inv, "is_lead": i == 0})

    def j(p):
        return json.dumps(p, ensure_ascii=False)

    sql = f"""-- =============================================================================
-- April 2026 Funding Deals — batch 2 ({len(DEALS)} records)
-- =============================================================================
-- source_name: '{SOURCE_NAME}'  (same batch as phase12/02)
-- Dates are announcement-window midpoints: 2026-04-21 / 04-15 / 04-08.
-- Amounts pre-converted to EUR millions (HrFlow.ai $7M @ 0.92 = 6.44).
-- Novaleum omitted (already in phase12/02). Cobl.ai imported as its own
-- org — flag a later merge with 'thinkeo' (its former name).
-- Existing orgs (Agriodor, Donecle, Aura Aero, Hepta Medical, Hairdex,
-- Luniwave, Mirabelle, Convelio, Decade Energy, Ouidrop) are upserted;
-- the new 2026 round is appended.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: Cities ({len(cities)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j([{"name": c} for c in cities])}$json$) AS (name TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'France', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 2: Sectors ({len(sectors)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j([{"name": s} for s in sectors])}$json$) AS (name TEXT)
)
INSERT INTO sectors (id, name, slug, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 3: Organizations (upsert by slug; enrich website only)
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(orgs)}$json$) AS (name TEXT, website TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, website, status, country, legacy_source, created_at, updated_at
)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'startup'::organization_type, s.website, 'active'::organization_status, 'France',
  '{SOURCE_NAME}', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  updated_at = NOW();

-- Step 4: Link organizations to cities ({len(org_city)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(org_city)}$json$) AS (org_slug TEXT, city TEXT)
)
UPDATE organizations o
SET city_id = c.id, updated_at = NOW()
FROM source s
JOIN cities c ON c.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE o.slug = s.org_slug AND o.city_id IS NULL;

-- Step 5: Link organizations to sectors ({len(sector_links)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(sector_links)}$json$) AS (org_slug TEXT, sector TEXT, is_primary BOOLEAN)
)
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id,
  CASE WHEN s.is_primary AND NOT EXISTS (SELECT 1 FROM organization_sectors os2 WHERE os2.organization_id = o.id AND os2.is_primary = TRUE) THEN TRUE ELSE FALSE END,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN sectors sec ON sec.slug = lower(regexp_replace(regexp_replace(unaccent(s.sector), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM organization_sectors os WHERE os.organization_id = o.id AND os.sector_id = sec.id
);

-- Step 6: Funding rounds ({len(rounds)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(rounds)}$json$) AS (org_slug TEXT, stage TEXT, amount_eur NUMERIC, announced_date TEXT, notes TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, notes, created_at
)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, 'EUR',
  s.amount_eur * 1000000, NULLIF(s.announced_date, '')::DATE, FALSE, FALSE,
  '{SOURCE_NAME}', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
WHERE NOT EXISTS (
  SELECT 1 FROM funding_rounds fr
  WHERE fr.organization_id = o.id
  AND fr.source_name = '{SOURCE_NAME}'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
);

-- Step 7: Investor organizations ({len(investors_set)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(investors_payload)}$json$) AS (name TEXT)
)
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'investor'::organization_type, 'active'::organization_status, 'France', '{SOURCE_NAME}', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 8: Round-investor links ({len(round_invs)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record, $json${j(round_invs)}$json$) AS (org_slug TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
),
joined AS (
  SELECT DISTINCT ON (fr.id, inv_org.id)
    fr.id AS funding_round_id, inv_org.id AS investor_id, s.is_lead, s.investor_name
  FROM source s
  JOIN organizations o ON o.slug = s.org_slug
  JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
  JOIN funding_rounds fr ON fr.organization_id = o.id
    AND fr.source_name = '{SOURCE_NAME}'
    AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
    AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
  ORDER BY fr.id, inv_org.id, s.is_lead DESC
)
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), funding_round_id, investor_id, is_lead, investor_name, NOW()
FROM joined
ON CONFLICT (funding_round_id, investor_id) DO NOTHING;
"""

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(sql, encoding='utf-8')
    print(f"Wrote {OUT} ({OUT.stat().st_size:,} bytes)")
    print(f"  deals: {len(DEALS)}  cities: {len(cities)}  sectors: {len(sectors)}")
    print(f"  org-sector: {len(sector_links)}  rounds: {len(rounds)}  investors: {len(investors_set)}  round-inv: {len(round_invs)}")


if __name__ == '__main__':
    main()
