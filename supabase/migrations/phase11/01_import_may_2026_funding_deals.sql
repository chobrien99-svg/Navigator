-- =============================================================================
-- May 2026 Funding Deals Import
-- =============================================================================
-- Imports 43 funding deals from May 2026.
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
            "name": "Paris",
            "country": "France"
      },
      {
            "name": "New York City",
            "country": "USA"
      },
      {
            "name": "Toulouse",
            "country": "France"
      },
      {
            "name": "Montpellier",
            "country": "France"
      },
      {
            "name": "San Francisco",
            "country": "USA"
      },
      {
            "name": "Nice",
            "country": "France"
      },
      {
            "name": "Mauguio",
            "country": "France"
      },
      {
            "name": "Moirans",
            "country": "France"
      },
      {
            "name": "Lyon",
            "country": "France"
      },
      {
            "name": "Lannion",
            "country": "France"
      },
      {
            "name": "Grenoble",
            "country": "France"
      },
      {
            "name": "Aix-en-Provence",
            "country": "France"
      },
      {
            "name": "Dijon",
            "country": "France"
      },
      {
            "name": "Valenciennes",
            "country": "France"
      },
      {
            "name": "Courbevoie",
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
-- Step 1: Create organizations (43 startups; existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "MokN",
            "website": "https://www.mokn.io/",
            "description": "MokN is a cybersecurity company specializing in protection against credential theft. It uses unique 'phish-back' technology to trap attackers and recover compromised credentials, and is building a multi-product platform for Active Identity Recovery."
      },
      {
            "name": "Opal",
            "website": "https://opalapp.com",
            "description": "Opal develops an \"operating system for attention\" that helps users reduce digital distractions, improve focus, sleep, and wellbeing through AI-powered attention management tools and behavioral interventions."
      },
      {
            "name": "Olyzon",
            "website": "https://olyzon.tv",
            "description": "Olyzon develops an AI-powered agentic decisioning platform for Connected TV (CTV) advertising, helping brands and agencies automate media planning, activation, optimization, and measurement across fragmented CTV ecosystems."
      },
      {
            "name": "VorteX-io",
            "website": "https://www.vortex-io.fr",
            "description": "VorteX-io develops hydrological monitoring solutions that combine autonomous river measurement stations, remote control centers, and analytics platforms to help governments and public organizations manage water resources, anticipate climate risks, and strengthen territorial resilience."
      },
      {
            "name": "ThIA Sant\u00e9 Mentale",
            "website": "https://www.thiasantementale.fr/",
            "description": "ThIA Sant\u00e9 Mentale develops coordinated psychiatric care solutions combining clinical protocols, digital tools, psychiatrists, and psychologists to improve access to mental healthcare and reduce treatment delays."
      },
      {
            "name": "Certo",
            "website": "https://www.certo.ai",
            "description": "Certo develops an AI-powered regulatory compliance platform for beauty and consumer goods companies, helping brands and retailers automate regulatory reviews, ingredient checks, labeling compliance, and market access across more than 40 global markets."
      },
      {
            "name": "Otomato",
            "website": "https://www.otomato.xyz",
            "description": "Otomato develops a portfolio-aware DeFi intelligence platform that monitors users' on-chain positions across multiple protocols and blockchains, providing real-time alerts on risks, costs, and opportunities."
      },
      {
            "name": "MySunBed",
            "website": "https://www.mysunbed.com",
            "description": "MySunBed operates a marketplace for booking private beach sunbeds and provides management software for beach clubs and seaside establishments. The company positions itself as the \"Booking.com of private beaches.\""
      },
      {
            "name": "Leedflow",
            "website": "https://leedflow.com/",
            "description": "Leedflow develops an AI-powered sales assistant that automates call summaries, CRM updates, contact records, and follow-up reminders for real estate professionals, helping agents improve lead management without changing their workflows."
      },
      {
            "name": "K-Ren",
            "website": "https://www.k-ren.fr",
            "description": "K-Ren develops antifouling covers that keep boat hulls clean without the use of biocides, helping recreational boat owners reduce marine pollution while maintaining vessel performance."
      },
      {
            "name": "Orakle Weather",
            "website": "https://www.orakleweather.com",
            "description": "Orakle Weather provides embedded weather insurance solutions for the tourism industry, automatically compensating customers when adverse weather conditions impact their travel or leisure experience."
      },
      {
            "name": "Jinka",
            "website": "https://www.jinka.fr",
            "description": "Jinka operates a real estate search platform that aggregates property listings and uses proprietary AI tools to help consumers find homes and assist real estate professionals with lead generation and performance optimization."
      },
      {
            "name": "LegalPlace",
            "website": "https://www.legalplace.fr",
            "description": "LegalPlace provides digital tools and administrative services for entrepreneurs and SMEs, covering company formation, legal management, accounting, and business administration through an all-in-one platform."
      },
      {
            "name": "Lithosquare",
            "website": "https://www.lithosquare.com/",
            "description": "Lithosquare develops AI-powered mineral exploration technology designed to accelerate the discovery of critical raw material deposits by combining geological reasoning models with large-scale geoscience data analysis."
      },
      {
            "name": "OpsMill",
            "website": "https://opsmill.com/",
            "description": "OpsMill develops AI-ready infrastructure data management software that helps enterprises centralize, structure, and govern IT infrastructure data for automation and AI-driven operations. Its flagship platform, Infrahub, uses graph databases and version control to create a trusted system of record for complex IT environments."
      },
      {
            "name": "Signadori Bio",
            "website": "https://www.signadoribio.com/",
            "description": "Signadori Bio is a preclinical-stage biotech developing an off-the-shelf in vivo engineered monocyte immunotherapy platform designed to treat solid tumors by reprogramming innate immune cells directly inside the body."
      },
      {
            "name": "Davis",
            "website": "https://meetdavis.com/",
            "description": "Davis is an AI-native real estate company accelerating early-stage real estate development and architectural design through proprietary generative AI models that produce architect-grade feasibility studies and building designs under real-world regulatory and financial constraints."
      },
      {
            "name": "OneFlash",
            "website": "https://www.oneflash.com",
            "description": "OneFlash operates a network of self-service portable battery charging stations that allow users to rent and return mobile power banks across high-traffic public locations."
      },
      {
            "name": "Nelson",
            "website": "https://nelson-mobility.com/",
            "description": "NELSON develops a data-driven platform for enterprise fleet electrification, using simulation algorithms and digital twins to help companies optimize EV transition planning, charging infrastructure, operational costs, and fleet management."
      },
      {
            "name": "Huelco",
            "website": "https://www.orioma.com/",
            "description": "Huelco is a French deeptech group integrating semiconductor design, embedded software, and IoT technologies through its subsidiaries Orioma, Xdigit, and Steepulse. Its flagship product, LOBX, is an energy-autonomous IoT sensor for smart buildings powered by ambient light and designed to optimize energy efficiency and security."
      },
      {
            "name": "Objow",
            "website": "https://objow.com",
            "description": "Objow develops a performance animation and incentive platform designed to engage employees and partners at scale through gamified rewards, commitment tracking, and daily performance stimulation."
      },
      {
            "name": "Kacentric Optics",
            "website": "https://www.kacentric.com/",
            "description": "Kacentric Optics develops next-generation test and measurement equipment for the photonics industry, targeting applications such as photonic integrated circuits (PICs), spectroscopy, and quantum technologies."
      },
      {
            "name": "UroMems",
            "website": "https://www.uromems.com",
            "description": "UroMems develops implantable mechatronic technologies for treating stress urinary incontinence, including UroActive\u00ae, a smart, automated artificial urinary sphincter powered by MEMS technology."
      },
      {
            "name": "Mantle8",
            "website": "https://mantle8.com",
            "description": "Mantle8 develops proprietary geological exploration technologies to identify and commercialize naturally occurring underground hydrogen reservoirs, aiming to provide low-cost, low-carbon energy at an industrial scale."
      },
      {
            "name": "S\u00eameia",
            "website": "https://www.semeia.io",
            "description": "S\u00eameia develops MedicWise, a data-driven remote patient monitoring platform that automates the collection and analysis of patient health data to support chronic disease management across multiple medical specialties."
      },
      {
            "name": "Sonomind",
            "website": "https://www.sonomind.com",
            "description": "Sonomind develops a non-invasive, painless ultrasound-based medical device designed to treat mental health disorders, starting with treatment-resistant depression, through low-intensity focused ultrasound stimulation of deep brain regions."
      },
      {
            "name": "White Circle",
            "website": "https://whitecircle.ai/",
            "description": "White Circle develops a real-time AI control and enforcement platform that monitors and governs AI model behavior inside enterprise applications, helping companies prevent jailbreaks, hallucinations, data leakage, and unsafe autonomous actions."
      },
      {
            "name": "Virtual Browser",
            "website": "https://virtualbrowser.com",
            "description": "Virtual Browser develops a remote browser isolation (RBI) cybersecurity platform that secures web navigation through a server-side zero trust architecture while preserving the native user experience through pixel streaming technology."
      },
      {
            "name": "Fakto",
            "website": "https://fakto.io/",
            "description": "Fakto develops an AI-powered platform that continuously analyzes supplier contracts, pricing grids, and invoices to detect billing discrepancies, contract deviations, and unclaimed procurement value for large enterprises."
      },
      {
            "name": "TwoWay",
            "website": "https://www.twoway.finance/",
            "description": "TwoWay develops institutional trading intelligence software that helps banks and asset managers process broker communications, pricing updates, and market signals across FX and fixed-income markets to improve price discovery and trading efficiency."
      },
      {
            "name": "Pivot",
            "website": "https://www.pivotapp.ai",
            "description": "Pivot develops an AI-powered procurement operating system that automates sourcing, invoicing, payments, budgeting, expense management, and reporting for enterprise finance and procurement teams."
      },
      {
            "name": "Dust",
            "website": "https://dust.tt",
            "description": "Dust develops a collaborative AI operating system that enables organizations to deploy AI agents across teams and workflows, allowing humans and agents to work together in shared workspaces with unified context, governance, and enterprise integrations."
      },
      {
            "name": "Prelude",
            "website": "https://www.prelude.so",
            "description": "Prelude develops onboarding and trust infrastructure for the AI age, combining telecom data, device intelligence, behavioral signals, and machine learning to help companies verify users, reduce fraud, and improve onboarding conversion."
      },
      {
            "name": "Otrera",
            "website": "https://otrera.fr",
            "description": "Otrera develops fourth-generation sodium-cooled fast neutron reactors (RNR-Na) designed to support sovereign, low-carbon energy production through advanced nuclear technologies and closed fuel cycle capabilities."
      },
      {
            "name": "Lucis",
            "website": "https://www.lucis.life/",
            "description": "Lucis is a preventive health platform combining blood biomarker testing with AI-powered analysis and physician-reviewed personalized recommendations to help users proactively monitor and improve their health."
      },
      {
            "name": "Crossject",
            "website": "https://www.crossject.com",
            "description": "CROSSJECT is a specialty pharmaceutical company developing emergency medicines using its proprietary ZENEO\u00ae needle-free auto-injector platform. Its lead product, ZEPIZURE\u00ae, is an injectable rescue therapy for epileptic seizures currently in advanced regulatory development."
      },
      {
            "name": "Mister IA",
            "website": "https://mister-ia.com",
            "description": "Mister IA is a French AI consultancy and training company helping enterprises and public organizations deploy generative AI through consulting, executive education, and operational implementation services."
      },
      {
            "name": "Dealinka",
            "website": "https://www.dealinka.com",
            "description": "Dealinka develops a digital platform helping companies redistribute unsold non-food inventory to charities instead of destroying products, optimizing allocation based on logistics, storage capacity, and product type."
      },
      {
            "name": "Leadbay",
            "website": "https://leadbay.ai",
            "description": "Leadbay develops an AI-powered prospecting platform designed to help sales teams identify SMBs and traditional businesses that generate few digital signals. Its AI agents analyze hundreds of weak signals to infer high-potential leads and automate prospect discovery workflows."
      },
      {
            "name": "Mediads",
            "website": "https://mediads.io/",
            "description": "Mediads develops a \"social publishing\" platform enabling brands to amplify social advertising campaigns through premium media publishers rather than solely through advertiser-owned social accounts."
      },
      {
            "name": "Ellipse",
            "website": "https://ellipsebikes.com",
            "description": "Ellipse is a French electric bike manufacturer developing turnkey corporate bike leasing solutions combining e-bikes, maintenance, insurance, and employee support to promote \"bike as a benefit\" mobility programs."
      },
      {
            "name": "Alice & Bob",
            "website": "https://alice-bob.com",
            "description": "Alice & Bob develops fault-tolerant quantum computers using proprietary \"cat qubit\" technology designed to dramatically reduce the hardware overhead required for scalable quantum computing."
      },
      {
            "name": "Eyst Technology",
            "website": "http://eyst.io/",
            "description": "EYST develops a SaaS platform enabling insurance companies to instantly settle claims through virtual bank cards loaded with compensation amounts, improving customer experience, payment speed, and fraud detection capabilities."
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
  'funding_deals_may_2026',
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
            "org_name": "MokN",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Opal",
            "city": "Paris",
            "secondary_city": "New York City"
      },
      {
            "org_name": "Olyzon",
            "city": "Paris",
            "secondary_city": "New York City"
      },
      {
            "org_name": "VorteX-io",
            "city": "Toulouse",
            "secondary_city": null
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "city": "Montpellier",
            "secondary_city": null
      },
      {
            "org_name": "Certo",
            "city": "Paris",
            "secondary_city": "San Francisco"
      },
      {
            "org_name": "Otomato",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "MySunBed",
            "city": "Nice",
            "secondary_city": null
      },
      {
            "org_name": "Leedflow",
            "city": "Nice",
            "secondary_city": null
      },
      {
            "org_name": "K-Ren",
            "city": "Mauguio",
            "secondary_city": null
      },
      {
            "org_name": "Orakle Weather",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Jinka",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "LegalPlace",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Lithosquare",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "OpsMill",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Signadori Bio",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Davis",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "OneFlash",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Nelson",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Huelco",
            "city": "Moirans",
            "secondary_city": null
      },
      {
            "org_name": "Objow",
            "city": "Lyon",
            "secondary_city": null
      },
      {
            "org_name": "Kacentric Optics",
            "city": "Lannion",
            "secondary_city": null
      },
      {
            "org_name": "UroMems",
            "city": "Grenoble",
            "secondary_city": null
      },
      {
            "org_name": "Mantle8",
            "city": "Grenoble",
            "secondary_city": null
      },
      {
            "org_name": "S\u00eameia",
            "city": "Toulouse",
            "secondary_city": null
      },
      {
            "org_name": "Sonomind",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "White Circle",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Virtual Browser",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Fakto",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "TwoWay",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Pivot",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Dust",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Prelude",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Otrera",
            "city": "Aix-en-Provence",
            "secondary_city": null
      },
      {
            "org_name": "Lucis",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Crossject",
            "city": "Dijon",
            "secondary_city": null
      },
      {
            "org_name": "Mister IA",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Dealinka",
            "city": "Valenciennes",
            "secondary_city": null
      },
      {
            "org_name": "Leadbay",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Mediads",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Ellipse",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Alice & Bob",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Eyst Technology",
            "city": "Courbevoie",
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
            "name": "MokN",
            "stage": "series_a",
            "amount_eur": 12.87,
            "currency_original": "USD",
            "amount_original": 15000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $15M Series A; GV's first investment in a French startup. Funds US & UK expansion and multi-product platform. Sources: Maddyness, L'Usine Digitale."
      },
      {
            "name": "Opal",
            "stage": "seed",
            "amount_eur": 8.58,
            "currency_original": "USD",
            "amount_original": 10000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $10M. 10M+ installs, 1M+ DAU. New Opal Score and Autofocus features. Source: Twitter."
      },
      {
            "name": "Olyzon",
            "stage": "series_a",
            "amount_eur": 8.58,
            "currency_original": "USD",
            "amount_original": 10000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $10M Series A led by S4S Ventures (Sir Martin Sorrell / Sanja Partalo). Funds product and US/London expansion. Source: The SaaS News."
      },
      {
            "name": "VorteX-io",
            "stage": "series_a",
            "amount_eur": 8.5,
            "currency_original": "EUR",
            "amount_original": 8500000,
            "announced_date": "2026-05-01",
            "notes": "Series A led by Seventure Partners' Blue Forward Fund. ~1,000 stations across four continents. Source: Banque des Territoires."
      },
      {
            "name": "ThIA Sant\u00e9 Mentale",
            "stage": "growth",
            "amount_eur": 5.0,
            "currency_original": "EUR",
            "amount_original": 5000000,
            "announced_date": "2026-05-01",
            "notes": "AviPsy care pathway cut access times from 67 to 9 days for 30,000+ patients. Source: Finyear."
      },
      {
            "name": "Certo",
            "stage": "seed",
            "amount_eur": 2.94,
            "currency_original": "USD",
            "amount_original": 3430000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $3.5M seed led by Daphni plus $500K loan ($4M total). Compliance across 40+ markets. Source: Maddyness."
      },
      {
            "name": "Otomato",
            "stage": "seed",
            "amount_eur": 1.72,
            "currency_original": "USD",
            "amount_original": 2000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $2M strategic investment from Improbable. 2,000+ users. Source: PR."
      },
      {
            "name": "MySunBed",
            "stage": "seed",
            "amount_eur": 1.6,
            "currency_original": "EUR",
            "amount_original": 1600000,
            "announced_date": "2026-05-01",
            "notes": "~100 beaches in France; expanding into Italy, Dubai, Morocco, Spain, Mexico. Source: Journal des entreprises."
      },
      {
            "name": "Leedflow",
            "stage": "seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-05-01",
            "notes": "Seed funding for AI commercial follow-up for real estate agents. Source: MySweetImmo."
      },
      {
            "name": "K-Ren",
            "stage": "seed",
            "amount_eur": 1.2,
            "currency_original": "EUR",
            "amount_original": 1200000,
            "announced_date": "2026-05-01",
            "notes": "Round led by Sud Mer Invest (Banque Populaire du Sud) with angels incl. Fr\u00e9d\u00e9ric Mazzella. Sources: LinkedIn, Boat Industry News."
      },
      {
            "name": "Orakle Weather",
            "stage": "seed",
            "amount_eur": 0.48,
            "currency_original": "USD",
            "amount_original": 550000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $550K. Automatic reimbursement within 48h; 10,000+ policies sold in 2025. Source: LinkedIn."
      },
      {
            "name": "Jinka",
            "stage": "debt",
            "amount_eur": 1.0,
            "currency_original": "EUR",
            "amount_original": 1000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac1M non-dilutive venture debt. Profitable 5 years; 4M+ users, 4,000 pros. Founded 2016 as LouerAgile."
      },
      {
            "name": "LegalPlace",
            "stage": "growth",
            "amount_eur": 70.0,
            "currency_original": "EUR",
            "amount_original": 70000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac70M to acquire rival Legalstart; ~20% of French company creations. 500 staff, \u20ac100M+ 2026 revenue target. Source: Maddyness."
      },
      {
            "name": "Lithosquare",
            "stage": "seed",
            "amount_eur": 22.2,
            "currency_original": "USD",
            "amount_original": 25000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $25M. AI compresses exploration from months to days, cuts costs up to 40%. Source: The French Tech Journal."
      },
      {
            "name": "OpsMill",
            "stage": "series_a",
            "amount_eur": 11.9,
            "currency_original": "EUR",
            "amount_original": 11900000,
            "announced_date": "2026-05-01",
            "notes": "Series A for data-centric AIOps platform Infrahub. Users incl. TikTok. Sources: EU Startups, Maddyness."
      },
      {
            "name": "Signadori Bio",
            "stage": "seed",
            "amount_eur": 11.1,
            "currency_original": "EUR",
            "amount_original": 11100000,
            "announced_date": "2026-05-01",
            "notes": "Seed extension to \u20ac11.1M total; advances lead candidate SiB-2101. Source: PR."
      },
      {
            "name": "Davis",
            "stage": "pre_seed",
            "amount_eur": 4.6,
            "currency_original": "EUR",
            "amount_original": 4600000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac4.6M pre-seed; launched Gaudi-1 generative model. Sources: EU Startups, FrenchWeb."
      },
      {
            "name": "OneFlash",
            "stage": "series_a",
            "amount_eur": 3.5,
            "currency_original": "EUR",
            "amount_original": 3500000,
            "announced_date": "2026-05-01",
            "notes": "Series A incl. \u20ac2.1M from Anthony Bourbon's Blast Club. ~2,000 stations in 11 countries. Source: Maddyness."
      },
      {
            "name": "Nelson",
            "stage": "seed",
            "amount_eur": 3.0,
            "currency_original": "EUR",
            "amount_original": 3000000,
            "announced_date": "2026-05-01",
            "notes": "Seed for AI fleet electrification. Clients incl. Orange, Dalkia (EDF), Schindler; ~50,000 vehicles. Source: Xange."
      },
      {
            "name": "Huelco",
            "stage": "seed",
            "amount_eur": 2.5,
            "currency_original": "EUR",
            "amount_original": 2500000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac2.5M to industrialize Orioma's LOBX ambient-light IoT sensor (\u20ac7.1M total raised). Source: Orioma."
      },
      {
            "name": "Objow",
            "stage": "other",
            "amount_eur": 2.0,
            "currency_original": "EUR",
            "amount_original": 2000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac2M+ for employee/partner engagement platform. 50+ enterprise customers, 40,000 users. Source: LinkedIn."
      },
      {
            "name": "Kacentric Optics",
            "stage": "seed",
            "amount_eur": 1.2,
            "currency_original": "EUR",
            "amount_original": 1200000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac1.2M seed (2/3 equity, 1/3 Bpifrance R&D loan). First product mid-2027. Source: Pic Magazine."
      },
      {
            "name": "UroMems",
            "stage": "growth",
            "amount_eur": 55.0,
            "currency_original": "USD",
            "amount_original": 60000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $60M strategic round from Ajax Health Fund I for SOPHIA2 trial. 200+ patents. Source: Ashland Town News."
      },
      {
            "name": "Mantle8",
            "stage": "series_a",
            "amount_eur": 31.0,
            "currency_original": "EUR",
            "amount_original": 31000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac31M Series A (\u20ac37M total) for natural hydrogen exploration; HOREX 4D imaging. Sources: EU-Startups, FrenchWeb."
      },
      {
            "name": "S\u00eameia",
            "stage": "growth",
            "amount_eur": 21.0,
            "currency_original": "EUR",
            "amount_original": 21000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac21M for multi-pathology telemonitoring (MedicWise). 35,000+ patients, 500 facilities. Sources: Acton Capital, FrenchWeb."
      },
      {
            "name": "Sonomind",
            "stage": "series_a",
            "amount_eur": 20.0,
            "currency_original": "EUR",
            "amount_original": 20000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac20M Series A for focused-ultrasound platform targeting treatment-resistant depression. 60%+ symptom reduction in early trials."
      },
      {
            "name": "White Circle",
            "stage": "seed",
            "amount_eur": 9.46,
            "currency_original": "USD",
            "amount_original": 11000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $11M seed. Real-time AI enforcement layer; 1B+ API requests. Clients incl. Lovable. Sources: Fortune, French Web."
      },
      {
            "name": "Virtual Browser",
            "stage": "seed",
            "amount_eur": 6.0,
            "currency_original": "EUR",
            "amount_original": 6000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac6M for RBI platform. Clients incl. Thales, Dassault, French MFA; 150,000+ users. Source: Le Monde Informatique."
      },
      {
            "name": "Fakto",
            "stage": "seed",
            "amount_eur": 3.6,
            "currency_original": "EUR",
            "amount_original": 3600000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac3.6M seed to automate supplier invoice verification. Targets enterprises >\u20ac500M revenue. Source: Maddyness."
      },
      {
            "name": "TwoWay",
            "stage": "pre_seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac1.5M pre-seed. Integrates with Bloomberg and Symphony; deployed at tier-1 banks. Source: Finance Magnates."
      },
      {
            "name": "Pivot",
            "stage": "series_b",
            "amount_eur": 34.56,
            "currency_original": "USD",
            "amount_original": 40000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $40M Series B. Founded 2023 by ex-Qonto/Swile; clients incl. DoorDash, Doctolib. Source: Maddyness."
      },
      {
            "name": "Dust",
            "stage": "series_b",
            "amount_eur": 34.56,
            "currency_original": "USD",
            "amount_original": 40000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $40M Series B for 'multiplayer AI' platform. 3,000+ orgs; 300,000+ agents deployed. Source: Dust."
      },
      {
            "name": "Prelude",
            "stage": "series_a",
            "amount_eur": 17.0,
            "currency_original": "USD",
            "amount_original": 20000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $20M Series A led by 20VC. Launched Prelude Auth and Intel API. Founded 2023 by ex-Zenly."
      },
      {
            "name": "Otrera",
            "stage": "growth",
            "amount_eur": 17.0,
            "currency_original": "EUR",
            "amount_original": 17000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac17M (equity + France 2030 subsidies) for Gen-IV sodium-cooled fast reactor; site near Cherbourg. Source: Le Figaro."
      },
      {
            "name": "Lucis",
            "stage": "series_a",
            "amount_eur": 17.23,
            "currency_original": "USD",
            "amount_original": 20000000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $20M Series A led by Singular ($28M total). 110+ biomarkers; formerly Zero Health. Sources: Tech EU, FrenchWeb."
      },
      {
            "name": "Crossject",
            "stage": "growth",
            "amount_eur": 15.0,
            "currency_original": "EUR",
            "amount_original": 15000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac15M equity + warrants for ZEPIZURE\u00ae regulatory work; up to \u20ac21.6M more if warrants exercised. Source: LinkedIn."
      },
      {
            "name": "Mister IA",
            "stage": "growth",
            "amount_eur": 10.0,
            "currency_original": "EUR",
            "amount_original": 10000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac10M led by Momentum Invest. 120 staff, \u20ac15M revenue, 1,000+ B2B clients. Source: Silicon.fr."
      },
      {
            "name": "Dealinka",
            "stage": "growth",
            "amount_eur": 6.5,
            "currency_original": "EUR",
            "amount_original": 6500000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac6.5M (Re-Sources fund + bank loans). \u20ac5.1M revenue in two years; redistributed \u20ac31M of goods in 2025. Source: Les Echos."
      },
      {
            "name": "Leadbay",
            "stage": "seed",
            "amount_eur": 3.7,
            "currency_original": "USD",
            "amount_original": 4300000,
            "announced_date": "2026-05-01",
            "notes": "Reported as $4.3M seed. AI agents analyze 500+ weak signals; 80%+ lead approval. Source: The French Tech Journal."
      },
      {
            "name": "Mediads",
            "stage": "seed",
            "amount_eur": 3.0,
            "currency_original": "EUR",
            "amount_original": 3000000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac3M seed for 'social publishing'. 250+ media partners; profitable, 100% YoY growth. Source: FrenchWeb."
      },
      {
            "name": "Ellipse",
            "stage": "seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-05-01",
            "notes": "\u20ac1.5M seed for corporate bike leasing. Clients incl. CMA CGM, Cr\u00e9dit Agricole, Dassault Syst\u00e8mes. Source: Journal des Entreprises."
      },
      {
            "name": "Alice & Bob",
            "stage": "series_b",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-05-01",
            "notes": "Undisclosed Series B extension from NVentures (NVIDIA), extending the \u20ac100M Series B. Cat-qubit architecture. Source: Les Echos."
      },
      {
            "name": "Eyst Technology",
            "stage": "seed",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-05-01",
            "notes": "Undisclosed six-figure investment from 216 Capital for instant insurance claim settlement. Source: Entarabi."
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
  'funding_deals_may_2026',
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
            "name": "199 Ventures"
      },
      {
            "name": "20VC"
      },
      {
            "name": "216 Capital"
      },
      {
            "name": "404 Ventures"
      },
      {
            "name": "Abstract"
      },
      {
            "name": "Acton Capital"
      },
      {
            "name": "Adjacent"
      },
      {
            "name": "AG2R La Mondiale"
      },
      {
            "name": "Ajax Health Fund I"
      },
      {
            "name": "Alain Dehaze"
      },
      {
            "name": "Alexis Mulliez"
      },
      {
            "name": "Antoine Le Nel"
      },
      {
            "name": "Aonia Ventures"
      },
      {
            "name": "Asterion Ventures"
      },
      {
            "name": "Auriga Cyber Ventures"
      },
      {
            "name": "AVP"
      },
      {
            "name": "Balderton Capital"
      },
      {
            "name": "Banque des Territoires"
      },
      {
            "name": "Banque Populaire du Sud"
      },
      {
            "name": "Barney Hussey-Yeo"
      },
      {
            "name": "BGV"
      },
      {
            "name": "Blast Club"
      },
      {
            "name": "BNP Paribas"
      },
      {
            "name": "BNP Paribas D\u00e9veloppement"
      },
      {
            "name": "Bpifrance"
      },
      {
            "name": "Breakthrough Energy Ventures"
      },
      {
            "name": "Caisse d'Epargne"
      },
      {
            "name": "Calderion"
      },
      {
            "name": "Citizen Capital"
      },
      {
            "name": "Climate Club"
      },
      {
            "name": "Critical Path Ventures"
      },
      {
            "name": "Cr\u00e9dit Agricole Cr\u00e9ation"
      },
      {
            "name": "Cr\u00e9dit Coop\u00e9ratif"
      },
      {
            "name": "Daphni"
      },
      {
            "name": "Darkmode"
      },
      {
            "name": "Datadog"
      },
      {
            "name": "Deel"
      },
      {
            "name": "Deel Ventures"
      },
      {
            "name": "Dominique Vidal"
      },
      {
            "name": "Durk Kingma"
      },
      {
            "name": "Ecotechnologies 2"
      },
      {
            "name": "Edenred Ventures"
      },
      {
            "name": "EDF"
      },
      {
            "name": "EIT Urban Mobility"
      },
      {
            "name": "Elad Gil"
      },
      {
            "name": "Emblem"
      },
      {
            "name": "Entrepreneurs First"
      },
      {
            "name": "Eurazeo"
      },
      {
            "name": "Evantic"
      },
      {
            "name": "Exergon"
      },
      {
            "name": "FDJ Ventures"
      },
      {
            "name": "Felix Blossier"
      },
      {
            "name": "Financi\u00e8re de Sorlin"
      },
      {
            "name": "Forestay Capital"
      },
      {
            "name": "Fortil Group"
      },
      {
            "name": "France 2030"
      },
      {
            "name": "Frst"
      },
      {
            "name": "Fr\u00e9d\u00e9ric Mazzella"
      },
      {
            "name": "Future French Champions"
      },
      {
            "name": "Gacherey Holding"
      },
      {
            "name": "General Catalyst"
      },
      {
            "name": "Generali"
      },
      {
            "name": "George Arison"
      },
      {
            "name": "Gestion Tourisme et Immobilier"
      },
      {
            "name": "GFC"
      },
      {
            "name": "GO Capital"
      },
      {
            "name": "Greyhound"
      },
      {
            "name": "Groupe ADF"
      },
      {
            "name": "Groupe REEL"
      },
      {
            "name": "Groupe SNEF"
      },
      {
            "name": "Guillaume Lample"
      },
      {
            "name": "GV (Google Ventures)"
      },
      {
            "name": "Heartcore Capital"
      },
      {
            "name": "Hedosophia"
      },
      {
            "name": "Holnest"
      },
      {
            "name": "HUB612 Caisse d'Epargne"
      },
      {
            "name": "Improbable"
      },
      {
            "name": "Ingerop"
      },
      {
            "name": "Invivo Partners"
      },
      {
            "name": "IP Group"
      },
      {
            "name": "IRDI Capital Investissement"
      },
      {
            "name": "IRIS"
      },
      {
            "name": "Jean-Marc Le Doussal"
      },
      {
            "name": "Jean-Paul Costes"
      },
      {
            "name": "Jean-St\u00e9phane Arcis"
      },
      {
            "name": "Kindred Capital"
      },
      {
            "name": "La Poste Ventures"
      },
      {
            "name": "LVMA"
      },
      {
            "name": "Mathilde Collin"
      },
      {
            "name": "Momentum Invest"
      },
      {
            "name": "Moonfire"
      },
      {
            "name": "Motier Ventures"
      },
      {
            "name": "Move Capital Fund I"
      },
      {
            "name": "Mutuelles Impact"
      },
      {
            "name": "Night Capital"
      },
      {
            "name": "Normandie Participations"
      },
      {
            "name": "Notion Capital"
      },
      {
            "name": "NVIDIA"
      },
      {
            "name": "Olivier Brourhant"
      },
      {
            "name": "Omnes Capital"
      },
      {
            "name": "Onet Technologies"
      },
      {
            "name": "Orange Ventures"
      },
      {
            "name": "OVNI Capital"
      },
      {
            "name": "Partech"
      },
      {
            "name": "Patrick Bertrand"
      },
      {
            "name": "Plug and Play"
      },
      {
            "name": "Rebel Ventures"
      },
      {
            "name": "Robin Rivaton"
      },
      {
            "name": "Romain Huet"
      },
      {
            "name": "S4S Ventures"
      },
      {
            "name": "Sandwater"
      },
      {
            "name": "Seedcamp"
      },
      {
            "name": "Sequoia"
      },
      {
            "name": "Serena"
      },
      {
            "name": "Seventure Partners"
      },
      {
            "name": "Severin Hacker"
      },
      {
            "name": "SideAngels"
      },
      {
            "name": "Singular"
      },
      {
            "name": "Snowflake Ventures"
      },
      {
            "name": "Soci\u00e9t\u00e9 G\u00e9n\u00e9rale"
      },
      {
            "name": "Sofilaro Innovation"
      },
      {
            "name": "Sofinnova Partners"
      },
      {
            "name": "Speedinvest"
      },
      {
            "name": "Steffen Tjerrild"
      },
      {
            "name": "St\u00e9phane Assuid"
      },
      {
            "name": "Sud Mer Invest"
      },
      {
            "name": "SuperCapital"
      },
      {
            "name": "S\u00e9bastien Lacaze"
      },
      {
            "name": "Taiho Ventures"
      },
      {
            "name": "Tenity"
      },
      {
            "name": "Thomas Wolf"
      },
      {
            "name": "Tiny VC"
      },
      {
            "name": "Tony Fadell"
      },
      {
            "name": "Transpose Platform"
      },
      {
            "name": "Unorthodox Partners"
      },
      {
            "name": "UT Invest"
      },
      {
            "name": "Vincent de Saint Sernin"
      },
      {
            "name": "Visionaries Club"
      },
      {
            "name": "welovefounders"
      },
      {
            "name": "Will Wu"
      },
      {
            "name": "Willem Delbare"
      },
      {
            "name": "Wind Capital"
      },
      {
            "name": "World Fund"
      },
      {
            "name": "XAnge"
      },
      {
            "name": "Xavier Roussillon"
      },
      {
            "name": "Y Combinator"
      },
      {
            "name": "Yellow"
      },
      {
            "name": "\u00c9douard Le Goff"
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
  'funding_deals_may_2026',
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
            "org_name": "MokN",
            "announced_date": "2026-05-01",
            "amount_eur": 12.87,
            "investor_name": "GV (Google Ventures)",
            "is_lead": true
      },
      {
            "org_name": "MokN",
            "announced_date": "2026-05-01",
            "amount_eur": 12.87,
            "investor_name": "Datadog",
            "is_lead": false
      },
      {
            "org_name": "MokN",
            "announced_date": "2026-05-01",
            "amount_eur": 12.87,
            "investor_name": "Moonfire",
            "is_lead": false
      },
      {
            "org_name": "MokN",
            "announced_date": "2026-05-01",
            "amount_eur": 12.87,
            "investor_name": "OVNI Capital",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Adjacent",
            "is_lead": true
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Speedinvest",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Night Capital",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Tony Fadell",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Severin Hacker",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Elad Gil",
            "is_lead": false
      },
      {
            "org_name": "Opal",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Mathilde Collin",
            "is_lead": false
      },
      {
            "org_name": "Olyzon",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "S4S Ventures",
            "is_lead": true
      },
      {
            "org_name": "Olyzon",
            "announced_date": "2026-05-01",
            "amount_eur": 8.58,
            "investor_name": "Eurazeo",
            "is_lead": false
      },
      {
            "org_name": "VorteX-io",
            "announced_date": "2026-05-01",
            "amount_eur": 8.5,
            "investor_name": "Seventure Partners",
            "is_lead": true
      },
      {
            "org_name": "VorteX-io",
            "announced_date": "2026-05-01",
            "amount_eur": 8.5,
            "investor_name": "Banque des Territoires",
            "is_lead": false
      },
      {
            "org_name": "VorteX-io",
            "announced_date": "2026-05-01",
            "amount_eur": 8.5,
            "investor_name": "Daphni",
            "is_lead": false
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "announced_date": "2026-05-01",
            "amount_eur": 5.0,
            "investor_name": "IRDI Capital Investissement",
            "is_lead": false
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "announced_date": "2026-05-01",
            "amount_eur": 5.0,
            "investor_name": "Sofilaro Innovation",
            "is_lead": false
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "announced_date": "2026-05-01",
            "amount_eur": 5.0,
            "investor_name": "Generali",
            "is_lead": false
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "announced_date": "2026-05-01",
            "amount_eur": 5.0,
            "investor_name": "AG2R La Mondiale",
            "is_lead": false
      },
      {
            "org_name": "Certo",
            "announced_date": "2026-05-01",
            "amount_eur": 2.94,
            "investor_name": "Daphni",
            "is_lead": true
      },
      {
            "org_name": "Certo",
            "announced_date": "2026-05-01",
            "amount_eur": 2.94,
            "investor_name": "Entrepreneurs First",
            "is_lead": false
      },
      {
            "org_name": "Certo",
            "announced_date": "2026-05-01",
            "amount_eur": 2.94,
            "investor_name": "Motier Ventures",
            "is_lead": false
      },
      {
            "org_name": "Certo",
            "announced_date": "2026-05-01",
            "amount_eur": 2.94,
            "investor_name": "Transpose Platform",
            "is_lead": false
      },
      {
            "org_name": "Otomato",
            "announced_date": "2026-05-01",
            "amount_eur": 1.72,
            "investor_name": "Improbable",
            "is_lead": true
      },
      {
            "org_name": "Leedflow",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "\u00c9douard Le Goff",
            "is_lead": false
      },
      {
            "org_name": "Leedflow",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Vincent de Saint Sernin",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Sud Mer Invest",
            "is_lead": true
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Fr\u00e9d\u00e9ric Mazzella",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Alexis Mulliez",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Jean-Paul Costes",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Jean-Marc Le Doussal",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "S\u00e9bastien Lacaze",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Banque Populaire du Sud",
            "is_lead": false
      },
      {
            "org_name": "K-Ren",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Caisse d'Epargne",
            "is_lead": false
      },
      {
            "org_name": "LegalPlace",
            "announced_date": "2026-05-01",
            "amount_eur": 70.0,
            "investor_name": "XAnge",
            "is_lead": false
      },
      {
            "org_name": "LegalPlace",
            "announced_date": "2026-05-01",
            "amount_eur": 70.0,
            "investor_name": "Eurazeo",
            "is_lead": false
      },
      {
            "org_name": "LegalPlace",
            "announced_date": "2026-05-01",
            "amount_eur": 70.0,
            "investor_name": "Move Capital Fund I",
            "is_lead": false
      },
      {
            "org_name": "Lithosquare",
            "announced_date": "2026-05-01",
            "amount_eur": 22.2,
            "investor_name": "World Fund",
            "is_lead": true
      },
      {
            "org_name": "Lithosquare",
            "announced_date": "2026-05-01",
            "amount_eur": 22.2,
            "investor_name": "Kindred Capital",
            "is_lead": false
      },
      {
            "org_name": "Lithosquare",
            "announced_date": "2026-05-01",
            "amount_eur": 22.2,
            "investor_name": "Daphni",
            "is_lead": false
      },
      {
            "org_name": "Lithosquare",
            "announced_date": "2026-05-01",
            "amount_eur": 22.2,
            "investor_name": "Omnes Capital",
            "is_lead": false
      },
      {
            "org_name": "OpsMill",
            "announced_date": "2026-05-01",
            "amount_eur": 11.9,
            "investor_name": "IRIS",
            "is_lead": false
      },
      {
            "org_name": "OpsMill",
            "announced_date": "2026-05-01",
            "amount_eur": 11.9,
            "investor_name": "BGV",
            "is_lead": false
      },
      {
            "org_name": "OpsMill",
            "announced_date": "2026-05-01",
            "amount_eur": 11.9,
            "investor_name": "Serena",
            "is_lead": false
      },
      {
            "org_name": "OpsMill",
            "announced_date": "2026-05-01",
            "amount_eur": 11.9,
            "investor_name": "Partech",
            "is_lead": false
      },
      {
            "org_name": "Signadori Bio",
            "announced_date": "2026-05-01",
            "amount_eur": 11.1,
            "investor_name": "Taiho Ventures",
            "is_lead": false
      },
      {
            "org_name": "Signadori Bio",
            "announced_date": "2026-05-01",
            "amount_eur": 11.1,
            "investor_name": "Sofinnova Partners",
            "is_lead": false
      },
      {
            "org_name": "Signadori Bio",
            "announced_date": "2026-05-01",
            "amount_eur": 11.1,
            "investor_name": "Invivo Partners",
            "is_lead": false
      },
      {
            "org_name": "Davis",
            "announced_date": "2026-05-01",
            "amount_eur": 4.6,
            "investor_name": "Heartcore Capital",
            "is_lead": true
      },
      {
            "org_name": "Davis",
            "announced_date": "2026-05-01",
            "amount_eur": 4.6,
            "investor_name": "Balderton Capital",
            "is_lead": false
      },
      {
            "org_name": "Davis",
            "announced_date": "2026-05-01",
            "amount_eur": 4.6,
            "investor_name": "Yellow",
            "is_lead": false
      },
      {
            "org_name": "Davis",
            "announced_date": "2026-05-01",
            "amount_eur": 4.6,
            "investor_name": "Evantic",
            "is_lead": false
      },
      {
            "org_name": "Davis",
            "announced_date": "2026-05-01",
            "amount_eur": 4.6,
            "investor_name": "Entrepreneurs First",
            "is_lead": false
      },
      {
            "org_name": "OneFlash",
            "announced_date": "2026-05-01",
            "amount_eur": 3.5,
            "investor_name": "Blast Club",
            "is_lead": false
      },
      {
            "org_name": "Nelson",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "Asterion Ventures",
            "is_lead": false
      },
      {
            "org_name": "Nelson",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "La Poste Ventures",
            "is_lead": false
      },
      {
            "org_name": "Nelson",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "EIT Urban Mobility",
            "is_lead": false
      },
      {
            "org_name": "Nelson",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "Climate Club",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Financi\u00e8re de Sorlin",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "LVMA",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Gestion Tourisme et Immobilier",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Gacherey Holding",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Soci\u00e9t\u00e9 G\u00e9n\u00e9rale",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "BNP Paribas",
            "is_lead": false
      },
      {
            "org_name": "Huelco",
            "announced_date": "2026-05-01",
            "amount_eur": 2.5,
            "investor_name": "Cr\u00e9dit Coop\u00e9ratif",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Edenred Ventures",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Cr\u00e9dit Agricole Cr\u00e9ation",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "HUB612 Caisse d'Epargne",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Holnest",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Aonia Ventures",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Patrick Bertrand",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Olivier Brourhant",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "St\u00e9phane Assuid",
            "is_lead": false
      },
      {
            "org_name": "Objow",
            "announced_date": "2026-05-01",
            "amount_eur": 2.0,
            "investor_name": "Xavier Roussillon",
            "is_lead": false
      },
      {
            "org_name": "Kacentric Optics",
            "announced_date": "2026-05-01",
            "amount_eur": 1.2,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "UroMems",
            "announced_date": "2026-05-01",
            "amount_eur": 55.0,
            "investor_name": "Ajax Health Fund I",
            "is_lead": true
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "Sandwater",
            "is_lead": true
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "Breakthrough Energy Ventures",
            "is_lead": false
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "Ecotechnologies 2",
            "is_lead": false
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "IP Group",
            "is_lead": false
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "Wind Capital",
            "is_lead": false
      },
      {
            "org_name": "Mantle8",
            "announced_date": "2026-05-01",
            "amount_eur": 31.0,
            "investor_name": "Calderion",
            "is_lead": false
      },
      {
            "org_name": "S\u00eameia",
            "announced_date": "2026-05-01",
            "amount_eur": 21.0,
            "investor_name": "Acton Capital",
            "is_lead": true
      },
      {
            "org_name": "S\u00eameia",
            "announced_date": "2026-05-01",
            "amount_eur": 21.0,
            "investor_name": "Mutuelles Impact",
            "is_lead": false
      },
      {
            "org_name": "S\u00eameia",
            "announced_date": "2026-05-01",
            "amount_eur": 21.0,
            "investor_name": "Citizen Capital",
            "is_lead": false
      },
      {
            "org_name": "S\u00eameia",
            "announced_date": "2026-05-01",
            "amount_eur": 21.0,
            "investor_name": "Banque des Territoires",
            "is_lead": false
      },
      {
            "org_name": "S\u00eameia",
            "announced_date": "2026-05-01",
            "amount_eur": 21.0,
            "investor_name": "Orange Ventures",
            "is_lead": false
      },
      {
            "org_name": "Sonomind",
            "announced_date": "2026-05-01",
            "amount_eur": 20.0,
            "investor_name": "Critical Path Ventures",
            "is_lead": true
      },
      {
            "org_name": "Sonomind",
            "announced_date": "2026-05-01",
            "amount_eur": 20.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "White Circle",
            "announced_date": "2026-05-01",
            "amount_eur": 9.46,
            "investor_name": "Tiny VC",
            "is_lead": false
      },
      {
            "org_name": "White Circle",
            "announced_date": "2026-05-01",
            "amount_eur": 9.46,
            "investor_name": "Romain Huet",
            "is_lead": false
      },
      {
            "org_name": "White Circle",
            "announced_date": "2026-05-01",
            "amount_eur": 9.46,
            "investor_name": "Durk Kingma",
            "is_lead": false
      },
      {
            "org_name": "White Circle",
            "announced_date": "2026-05-01",
            "amount_eur": 9.46,
            "investor_name": "Guillaume Lample",
            "is_lead": false
      },
      {
            "org_name": "White Circle",
            "announced_date": "2026-05-01",
            "amount_eur": 9.46,
            "investor_name": "Thomas Wolf",
            "is_lead": false
      },
      {
            "org_name": "Virtual Browser",
            "announced_date": "2026-05-01",
            "amount_eur": 6.0,
            "investor_name": "GO Capital",
            "is_lead": false
      },
      {
            "org_name": "Virtual Browser",
            "announced_date": "2026-05-01",
            "amount_eur": 6.0,
            "investor_name": "BNP Paribas D\u00e9veloppement",
            "is_lead": false
      },
      {
            "org_name": "Virtual Browser",
            "announced_date": "2026-05-01",
            "amount_eur": 6.0,
            "investor_name": "Auriga Cyber Ventures",
            "is_lead": false
      },
      {
            "org_name": "Virtual Browser",
            "announced_date": "2026-05-01",
            "amount_eur": 6.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "Frst",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "GFC",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "Darkmode",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "Alain Dehaze",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "Jean-St\u00e9phane Arcis",
            "is_lead": false
      },
      {
            "org_name": "Fakto",
            "announced_date": "2026-05-01",
            "amount_eur": 3.6,
            "investor_name": "Dominique Vidal",
            "is_lead": false
      },
      {
            "org_name": "TwoWay",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "welovefounders",
            "is_lead": false
      },
      {
            "org_name": "TwoWay",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Tenity",
            "is_lead": false
      },
      {
            "org_name": "TwoWay",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Plug and Play",
            "is_lead": false
      },
      {
            "org_name": "TwoWay",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "SuperCapital",
            "is_lead": false
      },
      {
            "org_name": "TwoWay",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Unorthodox Partners",
            "is_lead": false
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Forestay Capital",
            "is_lead": true
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Notion Capital",
            "is_lead": false
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Greyhound",
            "is_lead": false
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Hedosophia",
            "is_lead": false
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Visionaries Club",
            "is_lead": false
      },
      {
            "org_name": "Pivot",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Emblem",
            "is_lead": false
      },
      {
            "org_name": "Dust",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Abstract",
            "is_lead": false
      },
      {
            "org_name": "Dust",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Sequoia",
            "is_lead": false
      },
      {
            "org_name": "Dust",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Snowflake Ventures",
            "is_lead": false
      },
      {
            "org_name": "Dust",
            "announced_date": "2026-05-01",
            "amount_eur": 34.56,
            "investor_name": "Datadog",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "20VC",
            "is_lead": true
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Singular",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Seedcamp",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Deel",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "FDJ Ventures",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Steffen Tjerrild",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Willem Delbare",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Antoine Le Nel",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Felix Blossier",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "George Arison",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Barney Hussey-Yeo",
            "is_lead": false
      },
      {
            "org_name": "Prelude",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Will Wu",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "France 2030",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "EDF",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Groupe ADF",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Exergon",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Ingerop",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Fortil Group",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Normandie Participations",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Onet Technologies",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Groupe REEL",
            "is_lead": false
      },
      {
            "org_name": "Otrera",
            "announced_date": "2026-05-01",
            "amount_eur": 17.0,
            "investor_name": "Groupe SNEF",
            "is_lead": false
      },
      {
            "org_name": "Lucis",
            "announced_date": "2026-05-01",
            "amount_eur": 17.23,
            "investor_name": "Singular",
            "is_lead": true
      },
      {
            "org_name": "Lucis",
            "announced_date": "2026-05-01",
            "amount_eur": 17.23,
            "investor_name": "General Catalyst",
            "is_lead": false
      },
      {
            "org_name": "Lucis",
            "announced_date": "2026-05-01",
            "amount_eur": 17.23,
            "investor_name": "Y Combinator",
            "is_lead": false
      },
      {
            "org_name": "Mister IA",
            "announced_date": "2026-05-01",
            "amount_eur": 10.0,
            "investor_name": "Momentum Invest",
            "is_lead": true
      },
      {
            "org_name": "Mister IA",
            "announced_date": "2026-05-01",
            "amount_eur": 10.0,
            "investor_name": "199 Ventures",
            "is_lead": false
      },
      {
            "org_name": "Mister IA",
            "announced_date": "2026-05-01",
            "amount_eur": 10.0,
            "investor_name": "Robin Rivaton",
            "is_lead": false
      },
      {
            "org_name": "Leadbay",
            "announced_date": "2026-05-01",
            "amount_eur": 3.7,
            "investor_name": "Y Combinator",
            "is_lead": false
      },
      {
            "org_name": "Leadbay",
            "announced_date": "2026-05-01",
            "amount_eur": 3.7,
            "investor_name": "Rebel Ventures",
            "is_lead": false
      },
      {
            "org_name": "Leadbay",
            "announced_date": "2026-05-01",
            "amount_eur": 3.7,
            "investor_name": "Deel Ventures",
            "is_lead": false
      },
      {
            "org_name": "Mediads",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "Seventure Partners",
            "is_lead": false
      },
      {
            "org_name": "Mediads",
            "announced_date": "2026-05-01",
            "amount_eur": 3.0,
            "investor_name": "404 Ventures",
            "is_lead": false
      },
      {
            "org_name": "Ellipse",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "SideAngels",
            "is_lead": false
      },
      {
            "org_name": "Ellipse",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "UT Invest",
            "is_lead": false
      },
      {
            "org_name": "Ellipse",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Ellipse",
            "announced_date": "2026-05-01",
            "amount_eur": 1.5,
            "investor_name": "Caisse d'\u00c9pargne",
            "is_lead": false
      },
      {
            "org_name": "Alice & Bob",
            "announced_date": "2026-05-01",
            "amount_eur": null,
            "investor_name": "NVIDIA",
            "is_lead": false
      },
      {
            "org_name": "Alice & Bob",
            "announced_date": "2026-05-01",
            "amount_eur": null,
            "investor_name": "Future French Champions",
            "is_lead": false
      },
      {
            "org_name": "Alice & Bob",
            "announced_date": "2026-05-01",
            "amount_eur": null,
            "investor_name": "AVP",
            "is_lead": false
      },
      {
            "org_name": "Alice & Bob",
            "announced_date": "2026-05-01",
            "amount_eur": null,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Eyst Technology",
            "announced_date": "2026-05-01",
            "amount_eur": null,
            "investor_name": "216 Capital",
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
  AND fr.source_name = 'funding_deals_may_2026'
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
            "org": "mokn",
            "sec": "cybersecurity"
      },
      {
            "org": "mokn",
            "sec": "artificial-intelligence"
      },
      {
            "org": "opal",
            "sec": "artificial-intelligence"
      },
      {
            "org": "opal",
            "sec": "healthtech"
      },
      {
            "org": "olyzon",
            "sec": "martech"
      },
      {
            "org": "olyzon",
            "sec": "artificial-intelligence"
      },
      {
            "org": "vortex-io",
            "sec": "climatetech"
      },
      {
            "org": "vortex-io",
            "sec": "deeptech"
      },
      {
            "org": "thia-sante-mentale",
            "sec": "healthtech"
      },
      {
            "org": "thia-sante-mentale",
            "sec": "artificial-intelligence"
      },
      {
            "org": "certo",
            "sec": "artificial-intelligence"
      },
      {
            "org": "certo",
            "sec": "saas"
      },
      {
            "org": "otomato",
            "sec": "web3"
      },
      {
            "org": "otomato",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mysunbed",
            "sec": "traveltech"
      },
      {
            "org": "mysunbed",
            "sec": "saas"
      },
      {
            "org": "leedflow",
            "sec": "proptech"
      },
      {
            "org": "leedflow",
            "sec": "artificial-intelligence"
      },
      {
            "org": "k-ren",
            "sec": "cleantech"
      },
      {
            "org": "k-ren",
            "sec": "deeptech"
      },
      {
            "org": "orakle-weather",
            "sec": "insurtech"
      },
      {
            "org": "orakle-weather",
            "sec": "traveltech"
      },
      {
            "org": "jinka",
            "sec": "proptech"
      },
      {
            "org": "jinka",
            "sec": "artificial-intelligence"
      },
      {
            "org": "jinka",
            "sec": "saas"
      },
      {
            "org": "legalplace",
            "sec": "legaltech"
      },
      {
            "org": "legalplace",
            "sec": "fintech"
      },
      {
            "org": "legalplace",
            "sec": "artificial-intelligence"
      },
      {
            "org": "legalplace",
            "sec": "saas"
      },
      {
            "org": "lithosquare",
            "sec": "climatetech"
      },
      {
            "org": "lithosquare",
            "sec": "artificial-intelligence"
      },
      {
            "org": "lithosquare",
            "sec": "deeptech"
      },
      {
            "org": "opsmill",
            "sec": "saas"
      },
      {
            "org": "opsmill",
            "sec": "artificial-intelligence"
      },
      {
            "org": "signadori-bio",
            "sec": "biotech"
      },
      {
            "org": "davis",
            "sec": "proptech"
      },
      {
            "org": "davis",
            "sec": "artificial-intelligence"
      },
      {
            "org": "oneflash",
            "sec": "mobility"
      },
      {
            "org": "oneflash",
            "sec": "energy"
      },
      {
            "org": "nelson",
            "sec": "mobility"
      },
      {
            "org": "nelson",
            "sec": "climatetech"
      },
      {
            "org": "nelson",
            "sec": "saas"
      },
      {
            "org": "huelco",
            "sec": "proptech"
      },
      {
            "org": "huelco",
            "sec": "climatetech"
      },
      {
            "org": "huelco",
            "sec": "hardware"
      },
      {
            "org": "objow",
            "sec": "saas"
      },
      {
            "org": "kacentric-optics",
            "sec": "deeptech"
      },
      {
            "org": "uromems",
            "sec": "medtech"
      },
      {
            "org": "uromems",
            "sec": "hardware"
      },
      {
            "org": "mantle8",
            "sec": "climatetech"
      },
      {
            "org": "mantle8",
            "sec": "deeptech"
      },
      {
            "org": "mantle8",
            "sec": "energy"
      },
      {
            "org": "semeia",
            "sec": "healthtech"
      },
      {
            "org": "semeia",
            "sec": "artificial-intelligence"
      },
      {
            "org": "sonomind",
            "sec": "medtech"
      },
      {
            "org": "sonomind",
            "sec": "deeptech"
      },
      {
            "org": "sonomind",
            "sec": "hardware"
      },
      {
            "org": "white-circle",
            "sec": "artificial-intelligence"
      },
      {
            "org": "white-circle",
            "sec": "cybersecurity"
      },
      {
            "org": "virtual-browser",
            "sec": "cybersecurity"
      },
      {
            "org": "fakto",
            "sec": "fintech"
      },
      {
            "org": "fakto",
            "sec": "artificial-intelligence"
      },
      {
            "org": "fakto",
            "sec": "saas"
      },
      {
            "org": "twoway",
            "sec": "fintech"
      },
      {
            "org": "pivot",
            "sec": "fintech"
      },
      {
            "org": "pivot",
            "sec": "saas"
      },
      {
            "org": "pivot",
            "sec": "artificial-intelligence"
      },
      {
            "org": "dust",
            "sec": "saas"
      },
      {
            "org": "dust",
            "sec": "artificial-intelligence"
      },
      {
            "org": "prelude",
            "sec": "cybersecurity"
      },
      {
            "org": "prelude",
            "sec": "artificial-intelligence"
      },
      {
            "org": "otrera",
            "sec": "nuclear"
      },
      {
            "org": "otrera",
            "sec": "energy"
      },
      {
            "org": "otrera",
            "sec": "deeptech"
      },
      {
            "org": "lucis",
            "sec": "healthtech"
      },
      {
            "org": "lucis",
            "sec": "artificial-intelligence"
      },
      {
            "org": "crossject",
            "sec": "biotech"
      },
      {
            "org": "crossject",
            "sec": "medtech"
      },
      {
            "org": "mister-ia",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mister-ia",
            "sec": "edtech"
      },
      {
            "org": "dealinka",
            "sec": "cleantech"
      },
      {
            "org": "leadbay",
            "sec": "artificial-intelligence"
      },
      {
            "org": "leadbay",
            "sec": "saas"
      },
      {
            "org": "mediads",
            "sec": "martech"
      },
      {
            "org": "ellipse",
            "sec": "mobility"
      },
      {
            "org": "alice-bob",
            "sec": "quantum-computing"
      },
      {
            "org": "alice-bob",
            "sec": "deeptech"
      },
      {
            "org": "eyst-technology",
            "sec": "insurtech"
      },
      {
            "org": "eyst-technology",
            "sec": "fintech"
      },
      {
            "org": "eyst-technology",
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
            "org": "mokn",
            "sec": "cybersecurity"
      },
      {
            "org": "opal",
            "sec": "artificial-intelligence"
      },
      {
            "org": "olyzon",
            "sec": "martech"
      },
      {
            "org": "vortex-io",
            "sec": "climatetech"
      },
      {
            "org": "thia-sante-mentale",
            "sec": "healthtech"
      },
      {
            "org": "certo",
            "sec": "artificial-intelligence"
      },
      {
            "org": "otomato",
            "sec": "web3"
      },
      {
            "org": "mysunbed",
            "sec": "traveltech"
      },
      {
            "org": "leedflow",
            "sec": "proptech"
      },
      {
            "org": "k-ren",
            "sec": "cleantech"
      },
      {
            "org": "orakle-weather",
            "sec": "insurtech"
      },
      {
            "org": "jinka",
            "sec": "proptech"
      },
      {
            "org": "legalplace",
            "sec": "legaltech"
      },
      {
            "org": "lithosquare",
            "sec": "climatetech"
      },
      {
            "org": "opsmill",
            "sec": "saas"
      },
      {
            "org": "signadori-bio",
            "sec": "biotech"
      },
      {
            "org": "davis",
            "sec": "proptech"
      },
      {
            "org": "oneflash",
            "sec": "mobility"
      },
      {
            "org": "nelson",
            "sec": "mobility"
      },
      {
            "org": "huelco",
            "sec": "proptech"
      },
      {
            "org": "objow",
            "sec": "saas"
      },
      {
            "org": "kacentric-optics",
            "sec": "deeptech"
      },
      {
            "org": "uromems",
            "sec": "medtech"
      },
      {
            "org": "mantle8",
            "sec": "climatetech"
      },
      {
            "org": "semeia",
            "sec": "healthtech"
      },
      {
            "org": "sonomind",
            "sec": "medtech"
      },
      {
            "org": "white-circle",
            "sec": "artificial-intelligence"
      },
      {
            "org": "virtual-browser",
            "sec": "cybersecurity"
      },
      {
            "org": "fakto",
            "sec": "fintech"
      },
      {
            "org": "twoway",
            "sec": "fintech"
      },
      {
            "org": "pivot",
            "sec": "fintech"
      },
      {
            "org": "dust",
            "sec": "saas"
      },
      {
            "org": "prelude",
            "sec": "cybersecurity"
      },
      {
            "org": "otrera",
            "sec": "nuclear"
      },
      {
            "org": "lucis",
            "sec": "healthtech"
      },
      {
            "org": "crossject",
            "sec": "biotech"
      },
      {
            "org": "mister-ia",
            "sec": "artificial-intelligence"
      },
      {
            "org": "dealinka",
            "sec": "cleantech"
      },
      {
            "org": "leadbay",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mediads",
            "sec": "martech"
      },
      {
            "org": "ellipse",
            "sec": "mobility"
      },
      {
            "org": "alice-bob",
            "sec": "quantum-computing"
      },
      {
            "org": "eyst-technology",
            "sec": "insurtech"
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
            "full_name": "Gautier Bugeon",
            "first_name": "Gautier",
            "last_name": "Bugeon"
      },
      {
            "full_name": "Antoine Coudoux",
            "first_name": "Antoine",
            "last_name": "Coudoux"
      },
      {
            "full_name": "Kenneth Schlenker",
            "first_name": "Kenneth",
            "last_name": "Schlenker"
      },
      {
            "full_name": "Jules Minvielle",
            "first_name": "Jules",
            "last_name": "Minvielle"
      },
      {
            "full_name": "Guillaume Valladeau",
            "first_name": "Guillaume",
            "last_name": "Valladeau"
      },
      {
            "full_name": "Jean-Christophe Poisson",
            "first_name": "Jean-Christophe",
            "last_name": "Poisson"
      },
      {
            "full_name": "Yann Quintilla",
            "first_name": "Yann",
            "last_name": "Quintilla"
      },
      {
            "full_name": "Fr\u00e9d\u00e9rique Mozziconacci",
            "first_name": "Fr\u00e9d\u00e9rique",
            "last_name": "Mozziconacci"
      },
      {
            "full_name": "Bastien Deli\u00e8ge-Coste",
            "first_name": "Bastien",
            "last_name": "Deli\u00e8ge-Coste"
      },
      {
            "full_name": "Jean Duquenne",
            "first_name": "Jean",
            "last_name": "Duquenne"
      },
      {
            "full_name": "Clement Hecquet",
            "first_name": "Clement",
            "last_name": "Hecquet"
      },
      {
            "full_name": "Dylan Breugne",
            "first_name": "Dylan",
            "last_name": "Breugne"
      },
      {
            "full_name": "S\u00e9bastien Tomi",
            "first_name": "S\u00e9bastien",
            "last_name": "Tomi"
      },
      {
            "full_name": "Brice Sorgia",
            "first_name": "Brice",
            "last_name": "Sorgia"
      },
      {
            "full_name": "Cl\u00e9ment R\u00e9au",
            "first_name": "Cl\u00e9ment",
            "last_name": "R\u00e9au"
      },
      {
            "full_name": "Lucie Doriez",
            "first_name": "Lucie",
            "last_name": "Doriez"
      },
      {
            "full_name": "Fr\u00e9d\u00e9ric Planche",
            "first_name": "Fr\u00e9d\u00e9ric",
            "last_name": "Planche"
      },
      {
            "full_name": "Stella Jovet",
            "first_name": "Stella",
            "last_name": "Jovet"
      },
      {
            "full_name": "Rym Ben Hassine",
            "first_name": "Rym",
            "last_name": "Ben Hassine"
      },
      {
            "full_name": "Marc Lebel",
            "first_name": "Marc",
            "last_name": "Lebel"
      },
      {
            "full_name": "Racem Flazi",
            "first_name": "Racem",
            "last_name": "Flazi"
      },
      {
            "full_name": "Mehdi Ouchallal",
            "first_name": "Mehdi",
            "last_name": "Ouchallal"
      },
      {
            "full_name": "Samuel Goldstein",
            "first_name": "Samuel",
            "last_name": "Goldstein"
      },
      {
            "full_name": "Aym\u00e9ric Pr\u00e9veral-Etcheverry",
            "first_name": "Aym\u00e9ric",
            "last_name": "Pr\u00e9veral-Etcheverry"
      },
      {
            "full_name": "Simon Leclair",
            "first_name": "Simon",
            "last_name": "Leclair"
      },
      {
            "full_name": "Damien Garros",
            "first_name": "Damien",
            "last_name": "Garros"
      },
      {
            "full_name": "Raphael Maunier",
            "first_name": "Raphael",
            "last_name": "Maunier"
      },
      {
            "full_name": "Selwyn Ho",
            "first_name": "Selwyn",
            "last_name": "Ho"
      },
      {
            "full_name": "Mehdi Rais",
            "first_name": "Mehdi",
            "last_name": "Rais"
      },
      {
            "full_name": "Amine Chraibi",
            "first_name": "Amine",
            "last_name": "Chraibi"
      },
      {
            "full_name": "Lucas Di Franco",
            "first_name": "Lucas",
            "last_name": "Di Franco"
      },
      {
            "full_name": "Alfred Richard",
            "first_name": "Alfred",
            "last_name": "Richard"
      },
      {
            "full_name": "In\u00e8s Multrier",
            "first_name": "In\u00e8s",
            "last_name": "Multrier"
      },
      {
            "full_name": "Julien Bou Abboud",
            "first_name": "Julien",
            "last_name": "Bou Abboud"
      },
      {
            "full_name": "Octave Locqueville",
            "first_name": "Octave",
            "last_name": "Locqueville"
      },
      {
            "full_name": "Serdar Manakli",
            "first_name": "Serdar",
            "last_name": "Manakli"
      },
      {
            "full_name": "Jonathan Le Duc",
            "first_name": "Jonathan",
            "last_name": "Le Duc"
      },
      {
            "full_name": "Hadryen Chartier",
            "first_name": "Hadryen",
            "last_name": "Chartier"
      },
      {
            "full_name": "Michiel van der Keur",
            "first_name": "Michiel",
            "last_name": "van der Keur"
      },
      {
            "full_name": "Hamid Lamraoui",
            "first_name": "Hamid",
            "last_name": "Lamraoui"
      },
      {
            "full_name": "Emmanuel Masini",
            "first_name": "Emmanuel",
            "last_name": "Masini"
      },
      {
            "full_name": "Pierre Hornus",
            "first_name": "Pierre",
            "last_name": "Hornus"
      },
      {
            "full_name": "J\u00e9r\u00e9my Bercoff",
            "first_name": "J\u00e9r\u00e9my",
            "last_name": "Bercoff"
      },
      {
            "full_name": "Mickael Tanter",
            "first_name": "Mickael",
            "last_name": "Tanter"
      },
      {
            "full_name": "Jean-Fran\u00e7ois Aubry",
            "first_name": "Jean-Fran\u00e7ois",
            "last_name": "Aubry"
      },
      {
            "full_name": "Denis Shilov",
            "first_name": "Denis",
            "last_name": "Shilov"
      },
      {
            "full_name": "Edouard de R\u00e9mur",
            "first_name": "Edouard",
            "last_name": "de R\u00e9mur"
      },
      {
            "full_name": "Nicolas Vecchioli",
            "first_name": "Nicolas",
            "last_name": "Vecchioli"
      },
      {
            "full_name": "Benjamin Mai",
            "first_name": "Benjamin",
            "last_name": "Mai"
      },
      {
            "full_name": "Chirine BenZaied-Bourgerie",
            "first_name": "Chirine",
            "last_name": "BenZaied-Bourgerie"
      },
      {
            "full_name": "Marc-Antoine Lacroix",
            "first_name": "Marc-Antoine",
            "last_name": "Lacroix"
      },
      {
            "full_name": "Romain Libeau",
            "first_name": "Romain",
            "last_name": "Libeau"
      },
      {
            "full_name": "Estelle Giuly",
            "first_name": "Estelle",
            "last_name": "Giuly"
      },
      {
            "full_name": "Stanislas Polu",
            "first_name": "Stanislas",
            "last_name": "Polu"
      },
      {
            "full_name": "Gabriel Hubert",
            "first_name": "Gabriel",
            "last_name": "Hubert"
      },
      {
            "full_name": "Matias Berny",
            "first_name": "Matias",
            "last_name": "Berny"
      },
      {
            "full_name": "Quentin Le Bras",
            "first_name": "Quentin",
            "last_name": "Le Bras"
      },
      {
            "full_name": "Fr\u00e9d\u00e9ric Varaine",
            "first_name": "Fr\u00e9d\u00e9ric",
            "last_name": "Varaine"
      },
      {
            "full_name": "Jean-\u00c9ric Lucas",
            "first_name": "Jean-\u00c9ric",
            "last_name": "Lucas"
      },
      {
            "full_name": "Maxime Berthelot",
            "first_name": "Maxime",
            "last_name": "Berthelot"
      },
      {
            "full_name": "Baptiste Debever",
            "first_name": "Baptiste",
            "last_name": "Debever"
      },
      {
            "full_name": "Patrick Alexandre",
            "first_name": "Patrick",
            "last_name": "Alexandre"
      },
      {
            "full_name": "Vincent Pavanello",
            "first_name": "Vincent",
            "last_name": "Pavanello"
      },
      {
            "full_name": "Martin Pavanello",
            "first_name": "Martin",
            "last_name": "Pavanello"
      },
      {
            "full_name": "Ramil Alvarez",
            "first_name": "Ramil",
            "last_name": "Alvarez"
      },
      {
            "full_name": "Alexis Raspilair",
            "first_name": "Alexis",
            "last_name": "Raspilair"
      },
      {
            "full_name": "Ludovic Granger",
            "first_name": "Ludovic",
            "last_name": "Granger"
      },
      {
            "full_name": "Milan Stankovic",
            "first_name": "Milan",
            "last_name": "Stankovic"
      },
      {
            "full_name": "Alfred Cardinal",
            "first_name": "Alfred",
            "last_name": "Cardinal"
      },
      {
            "full_name": "St\u00e9phane Labrouche",
            "first_name": "St\u00e9phane",
            "last_name": "Labrouche"
      },
      {
            "full_name": "Robin Gabuthy",
            "first_name": "Robin",
            "last_name": "Gabuthy"
      },
      {
            "full_name": "Th\u00e9au Peronnin",
            "first_name": "Th\u00e9au",
            "last_name": "Peronnin"
      },
      {
            "full_name": "Rapha\u00ebl Lescanne",
            "first_name": "Rapha\u00ebl",
            "last_name": "Lescanne"
      },
      {
            "full_name": "Marwen Amamou",
            "first_name": "Marwen",
            "last_name": "Amamou"
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
  'funding_deals_may_2026',
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
            "org_name": "MokN",
            "founder_name": "Gautier Bugeon"
      },
      {
            "org_name": "MokN",
            "founder_name": "Antoine Coudoux"
      },
      {
            "org_name": "Opal",
            "founder_name": "Kenneth Schlenker"
      },
      {
            "org_name": "Olyzon",
            "founder_name": "Jules Minvielle"
      },
      {
            "org_name": "VorteX-io",
            "founder_name": "Guillaume Valladeau"
      },
      {
            "org_name": "VorteX-io",
            "founder_name": "Jean-Christophe Poisson"
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "founder_name": "Yann Quintilla"
      },
      {
            "org_name": "ThIA Sant\u00e9 Mentale",
            "founder_name": "Fr\u00e9d\u00e9rique Mozziconacci"
      },
      {
            "org_name": "Certo",
            "founder_name": "Bastien Deli\u00e8ge-Coste"
      },
      {
            "org_name": "Certo",
            "founder_name": "Jean Duquenne"
      },
      {
            "org_name": "Otomato",
            "founder_name": "Clement Hecquet"
      },
      {
            "org_name": "Otomato",
            "founder_name": "Dylan Breugne"
      },
      {
            "org_name": "MySunBed",
            "founder_name": "S\u00e9bastien Tomi"
      },
      {
            "org_name": "MySunBed",
            "founder_name": "Brice Sorgia"
      },
      {
            "org_name": "Leedflow",
            "founder_name": "Cl\u00e9ment R\u00e9au"
      },
      {
            "org_name": "K-Ren",
            "founder_name": "Lucie Doriez"
      },
      {
            "org_name": "K-Ren",
            "founder_name": "Fr\u00e9d\u00e9ric Planche"
      },
      {
            "org_name": "Orakle Weather",
            "founder_name": "Stella Jovet"
      },
      {
            "org_name": "Orakle Weather",
            "founder_name": "Rym Ben Hassine"
      },
      {
            "org_name": "Jinka",
            "founder_name": "Marc Lebel"
      },
      {
            "org_name": "LegalPlace",
            "founder_name": "Racem Flazi"
      },
      {
            "org_name": "LegalPlace",
            "founder_name": "Mehdi Ouchallal"
      },
      {
            "org_name": "LegalPlace",
            "founder_name": "Samuel Goldstein"
      },
      {
            "org_name": "Lithosquare",
            "founder_name": "Aym\u00e9ric Pr\u00e9veral-Etcheverry"
      },
      {
            "org_name": "Lithosquare",
            "founder_name": "Simon Leclair"
      },
      {
            "org_name": "OpsMill",
            "founder_name": "Damien Garros"
      },
      {
            "org_name": "OpsMill",
            "founder_name": "Raphael Maunier"
      },
      {
            "org_name": "Signadori Bio",
            "founder_name": "Selwyn Ho"
      },
      {
            "org_name": "Davis",
            "founder_name": "Mehdi Rais"
      },
      {
            "org_name": "Davis",
            "founder_name": "Amine Chraibi"
      },
      {
            "org_name": "OneFlash",
            "founder_name": "Lucas Di Franco"
      },
      {
            "org_name": "Nelson",
            "founder_name": "Alfred Richard"
      },
      {
            "org_name": "Nelson",
            "founder_name": "In\u00e8s Multrier"
      },
      {
            "org_name": "Nelson",
            "founder_name": "Julien Bou Abboud"
      },
      {
            "org_name": "Nelson",
            "founder_name": "Octave Locqueville"
      },
      {
            "org_name": "Huelco",
            "founder_name": "Serdar Manakli"
      },
      {
            "org_name": "Objow",
            "founder_name": "Jonathan Le Duc"
      },
      {
            "org_name": "Objow",
            "founder_name": "Hadryen Chartier"
      },
      {
            "org_name": "Kacentric Optics",
            "founder_name": "Michiel van der Keur"
      },
      {
            "org_name": "UroMems",
            "founder_name": "Hamid Lamraoui"
      },
      {
            "org_name": "Mantle8",
            "founder_name": "Emmanuel Masini"
      },
      {
            "org_name": "S\u00eameia",
            "founder_name": "Pierre Hornus"
      },
      {
            "org_name": "Sonomind",
            "founder_name": "J\u00e9r\u00e9my Bercoff"
      },
      {
            "org_name": "Sonomind",
            "founder_name": "Mickael Tanter"
      },
      {
            "org_name": "Sonomind",
            "founder_name": "Jean-Fran\u00e7ois Aubry"
      },
      {
            "org_name": "White Circle",
            "founder_name": "Denis Shilov"
      },
      {
            "org_name": "Virtual Browser",
            "founder_name": "Edouard de R\u00e9mur"
      },
      {
            "org_name": "Fakto",
            "founder_name": "Nicolas Vecchioli"
      },
      {
            "org_name": "Fakto",
            "founder_name": "Benjamin Mai"
      },
      {
            "org_name": "TwoWay",
            "founder_name": "Chirine BenZaied-Bourgerie"
      },
      {
            "org_name": "Pivot",
            "founder_name": "Marc-Antoine Lacroix"
      },
      {
            "org_name": "Pivot",
            "founder_name": "Romain Libeau"
      },
      {
            "org_name": "Pivot",
            "founder_name": "Estelle Giuly"
      },
      {
            "org_name": "Dust",
            "founder_name": "Stanislas Polu"
      },
      {
            "org_name": "Dust",
            "founder_name": "Gabriel Hubert"
      },
      {
            "org_name": "Prelude",
            "founder_name": "Matias Berny"
      },
      {
            "org_name": "Prelude",
            "founder_name": "Quentin Le Bras"
      },
      {
            "org_name": "Otrera",
            "founder_name": "Fr\u00e9d\u00e9ric Varaine"
      },
      {
            "org_name": "Otrera",
            "founder_name": "Jean-\u00c9ric Lucas"
      },
      {
            "org_name": "Lucis",
            "founder_name": "Maxime Berthelot"
      },
      {
            "org_name": "Lucis",
            "founder_name": "Baptiste Debever"
      },
      {
            "org_name": "Crossject",
            "founder_name": "Patrick Alexandre"
      },
      {
            "org_name": "Mister IA",
            "founder_name": "Vincent Pavanello"
      },
      {
            "org_name": "Mister IA",
            "founder_name": "Martin Pavanello"
      },
      {
            "org_name": "Dealinka",
            "founder_name": "Ramil Alvarez"
      },
      {
            "org_name": "Dealinka",
            "founder_name": "Alexis Raspilair"
      },
      {
            "org_name": "Leadbay",
            "founder_name": "Ludovic Granger"
      },
      {
            "org_name": "Leadbay",
            "founder_name": "Milan Stankovic"
      },
      {
            "org_name": "Mediads",
            "founder_name": "Alfred Cardinal"
      },
      {
            "org_name": "Mediads",
            "founder_name": "St\u00e9phane Labrouche"
      },
      {
            "org_name": "Ellipse",
            "founder_name": "Robin Gabuthy"
      },
      {
            "org_name": "Alice & Bob",
            "founder_name": "Th\u00e9au Peronnin"
      },
      {
            "org_name": "Alice & Bob",
            "founder_name": "Rapha\u00ebl Lescanne"
      },
      {
            "org_name": "Eyst Technology",
            "founder_name": "Marwen Amamou"
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
            "org": "mokn",
            "siren": "980821474"
      },
      {
            "org": "opal",
            "siren": "893034447"
      },
      {
            "org": "olyzon",
            "siren": "953836913"
      },
      {
            "org": "vortex-io",
            "siren": "850904202"
      },
      {
            "org": "thia-sante-mentale",
            "siren": "914329677"
      },
      {
            "org": "certo",
            "siren": "992900886"
      },
      {
            "org": "mysunbed",
            "siren": "898434592"
      },
      {
            "org": "leedflow",
            "siren": "985354646"
      },
      {
            "org": "k-ren",
            "siren": "887627776"
      },
      {
            "org": "orakle-weather",
            "siren": "979438967"
      },
      {
            "org": "jinka",
            "siren": "840936744"
      },
      {
            "org": "legalplace",
            "siren": "814428785"
      },
      {
            "org": "lithosquare",
            "siren": "927888511"
      },
      {
            "org": "opsmill",
            "siren": "948875067"
      },
      {
            "org": "signadori-bio",
            "siren": "928169697"
      },
      {
            "org": "davis",
            "siren": "994931996"
      },
      {
            "org": "oneflash",
            "siren": "853831246"
      },
      {
            "org": "nelson",
            "siren": "918697657"
      },
      {
            "org": "huelco",
            "siren": "835393554"
      },
      {
            "org": "objow",
            "siren": "852715887"
      },
      {
            "org": "kacentric-optics",
            "siren": "879329555"
      },
      {
            "org": "uromems",
            "siren": "533670931"
      },
      {
            "org": "mantle8",
            "siren": "844719500"
      },
      {
            "org": "semeia",
            "siren": "829055854"
      },
      {
            "org": "sonomind",
            "siren": "929049187"
      },
      {
            "org": "virtual-browser",
            "siren": "929565539"
      },
      {
            "org": "fakto",
            "siren": "999136732"
      },
      {
            "org": "twoway",
            "siren": "931171557"
      },
      {
            "org": "pivot",
            "siren": "953146446"
      },
      {
            "org": "dust",
            "siren": "949205314"
      },
      {
            "org": "prelude",
            "siren": "921318432"
      },
      {
            "org": "otrera",
            "siren": "924880933"
      },
      {
            "org": "lucis",
            "siren": "927853952"
      },
      {
            "org": "crossject",
            "siren": "438822215"
      },
      {
            "org": "mister-ia",
            "siren": "977834928"
      },
      {
            "org": "dealinka",
            "siren": "948306519"
      },
      {
            "org": "leadbay",
            "siren": "977615459"
      },
      {
            "org": "mediads",
            "siren": "920035607"
      },
      {
            "org": "ellipse",
            "siren": "885269514"
      },
      {
            "org": "alice-bob",
            "siren": "881729156"
      },
      {
            "org": "eyst-technology",
            "siren": "914735592"
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
FROM funding_rounds WHERE source_name = 'funding_deals_may_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_may_2026'
UNION ALL
SELECT 'Founder Links (new people)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_may_2026';
