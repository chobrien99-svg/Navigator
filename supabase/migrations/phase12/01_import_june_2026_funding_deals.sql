-- =============================================================================
-- June 2026 Funding Deals Import
-- =============================================================================
-- Imports 53 funding deals from June 2026.
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
            "name": "Grenoble",
            "country": "France"
      },
      {
            "name": "Lyon",
            "country": "France"
      },
      {
            "name": "Montpellier",
            "country": "France"
      },
      {
            "name": "Levallois-Perret",
            "country": "France"
      },
      {
            "name": "New York City",
            "country": "USA"
      },
      {
            "name": "Bordeaux",
            "country": "France"
      },
      {
            "name": "Rennes",
            "country": "France"
      },
      {
            "name": "Pressac",
            "country": "France"
      },
      {
            "name": "Cergy",
            "country": "France"
      },
      {
            "name": "Toulouse",
            "country": "France"
      },
      {
            "name": "Marseille",
            "country": "France"
      },
      {
            "name": "Fort Worth",
            "country": "USA"
      },
      {
            "name": "Plouzan\u00e9",
            "country": "France"
      },
      {
            "name": "Sequedin",
            "country": "France"
      },
      {
            "name": "Geneva",
            "country": "Switzerland"
      },
      {
            "name": "Avignonet-Lauragais",
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
-- Step 1: Create organizations (53 startups; existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Alan",
            "website": "https://alan.com",
            "description": "Alan is an AI-native digital health and insurance platform that combines health insurance, prevention, healthcare services, and care navigation into a single experience for businesses, self-employed professionals, retirees, and individuals. The company uses AI to improve customer service, automate operations, and deliver personalized preventive healthcare."
      },
      {
            "name": "Bionyra Pharma",
            "website": "https://www.bionyrapharma.com",
            "description": "Bionyra Pharma is a clinical-stage biotechnology company developing biologic therapies for immune-mediated inflammatory diseases, initially targeting severe atopic dermatitis (eczema) and inflammatory bowel diseases, including Crohn's disease and ulcerative colitis."
      },
      {
            "name": "TISSIUM",
            "website": "https://www.tissium.com",
            "description": "TISSIUM develops biomorphic polymer-based medical devices for tissue reconstruction and repair. Its platform enables sutureless tissue repair across multiple surgical applications, including peripheral nerve repair, hernia repair, and cardiovascular surgery."
      },
      {
            "name": "Tsuga",
            "website": "https://www.tsuga.ai",
            "description": "Tsuga develops an AI-native observability platform that runs entirely within customers' cloud environments, enabling enterprises to monitor AI applications and cloud infrastructure without moving telemetry to third-party clouds. Its platform eliminates data duplication, reduces observability costs, and provides AI agents with access to complete, unsampled telemetry."
      },
      {
            "name": "AlpSemi",
            "website": "https://alpsemi.com",
            "description": "AlpSemi develops next-generation semiconductor power switches for solid-state circuit breakers (SSCBs), enabling digitally controlled, software-defined electrical distribution for buildings, industrial systems, AI data centers, and electric mobility. Its vertically integrated platform spans materials, devices, and systems to improve the efficiency, safety, and intelligence of power infrastructure."
      },
      {
            "name": "Flease",
            "website": "https://www.flease.fr",
            "description": "Flease provides flexible B2B leasing and fleet management solutions for reconditioned vehicles. Its platform combines telematics and fleet management software to optimize vehicle usage, maintenance, and total cost of ownership while promoting the adoption of refurbished vehicles."
      },
      {
            "name": "Wheere",
            "website": "https://www.wheere.com",
            "description": "Wheere develops next-generation positioning technology that enables precise indoor and outdoor localization using proprietary VHF radio signals capable of penetrating complex environments. The company aims to build a sovereign alternative for Positioning, Navigation, and Timing (PNT), ultimately extending its technology through a low Earth orbit satellite constellation and dedicated semiconductor chips."
      },
      {
            "name": "Linc",
            "website": "https://www.lincpay.io",
            "description": "Linc develops AI-powered payroll software for accounting firms, helping them manage payroll more efficiently through modern workflows, real-time data access, and automation. The platform is designed specifically for payroll professionals, offering collaborative tools and deep regulatory coverage of the French payroll system."
      },
      {
            "name": "Sopht",
            "website": "https://www.sopht.com",
            "description": "Sopht develops a software platform that helps enterprises optimize the cost, performance, and environmental footprint of their IT infrastructure. By consolidating data across cloud environments, datacenters, and end-user devices, the platform identifies cost-saving opportunities and recommends actions to improve both financial and environmental efficiency."
      },
      {
            "name": "Blyyd",
            "website": "https://blyyd.com",
            "description": "Blyyd designs and manufactures 100% electric yard vehicles for logistics and industrial sites, enabling the movement of trailers while improving operational efficiency, safety, and reducing carbon emissions through electric propulsion, swappable batteries, and fleet management software."
      },
      {
            "name": "Cardiawave",
            "website": "https://cardiawave.com",
            "description": "Cardiawave develops Valvosoft\u00ae, the first non-invasive, image-guided ultrasound therapy for severe calcific aortic stenosis. The CE-marked device uses focused ultrasound to fracture valve calcifications without surgery, implants, or general anesthesia, targeting patients who are ineligible for or unwilling to undergo valve replacement."
      },
      {
            "name": "Macrodata Labs",
            "website": "https://macrodata.co",
            "description": "Macrodata Labs builds infrastructure that transforms raw multimodal robotics data into training-ready datasets for embodied AI. Its flagship product, Refiner, is an open-source framework and managed cloud runtime that processes video, sensor data, robotics logs, and other heterogeneous inputs into high-quality datasets for robot foundation models."
      },
      {
            "name": "Haiku",
            "website": "https://www.haiku.fr",
            "description": "Haiku develops an AI-powered legal research and productivity platform that helps legal professionals search, analyze, and draft legal documents. The company partners with bar associations, institutions, and legal publishers to bring AI tools to the legal sector."
      },
      {
            "name": "Concord",
            "website": "https://concord.ad",
            "description": "Concord develops an agentic AI platform that automates media buying by turning campaign briefs into live advertising campaigns, managing execution, optimization, and reporting across major advertising platforms, including Google, Meta, Amazon DSP, The Trade Desk, and TikTok."
      },
      {
            "name": "Beams",
            "website": "https://www.beams.bio",
            "description": "Beams is a French medtech spin-off from the CNRS developing TRIOP\u00ae, an intra-operative probe that uses nuclear medicine to help surgeons detect and remove residual cancer tissue during oncological surgery, improving surgical precision and reducing the risk of recurrence."
      },
      {
            "name": "Cilcare",
            "website": "https://cilcare.com",
            "description": "Cilcare is a biotechnology company developing novel therapies for hearing disorders, including hearing loss and tinnitus, while leveraging proprietary auditory biomarkers and AI-driven analytics to improve drug development and patient stratification."
      },
      {
            "name": "Fascent",
            "website": "https://fascent.com",
            "description": "Fascent is a Paris-based fragrance brand creating playful, sustainable perfumes at accessible price points. Founded in 2023 by former executives from Diptyque, Guerlain, Firmenich, and LVMH, the company combines French fragrance expertise with eco-conscious packaging and a direct-to-consumer approach."
      },
      {
            "name": "MNGRS.AI",
            "website": "https://mngrs.ai",
            "description": "MNGRS.AI develops an AI-powered artist management platform that helps independent musicians with career planning, strategy, content development, and other management functions, bringing professional artist management tools to creators at scale."
      },
      {
            "name": "Comand AI",
            "website": "https://comand.ai",
            "description": "Comand AI is a Paris-based defense technology company developing AI-native command-and-control software for military operations. Its flagship platform, Prevail, enables armed forces to coordinate autonomous systems, distributed sensors, drone swarms, and human operators through AI-assisted decision-making and battlefield management."
      },
      {
            "name": "Prophesee",
            "website": "https://www.prophesee.ai",
            "description": "Prophesee develops event-based vision sensors inspired by the human eye. Its technology captures only changes in a scene, enabling ultra-low-latency perception for applications in defense, security, robotics, and autonomous systems."
      },
      {
            "name": "Rocapine",
            "website": "https://rocapine.com",
            "description": "Rocapine is a Paris-based AI-native wellness venture studio that develops and scales consumer wellness applications focused on healthier habits, women's health, nutrition, and addiction recovery. Its portfolio includes Harmony, Unchaind, Stashcook, That Girl, and Eve, and it uses an AI-powered studio model to rapidly test, launch, and scale wellness apps."
      },
      {
            "name": "Green-Got",
            "website": "https://green-got.com",
            "description": "Green-Got is a French sustainable finance fintech offering current accounts, payment cards, savings products, life insurance, and investment solutions designed to align customers' money with environmental values. The company aims to build an independent European banking alternative focused on financing the ecological transition."
      },
      {
            "name": "CardNexus",
            "website": "https://cardnexus.com",
            "description": "CardNexus is a mobile-first marketplace and collection management platform for trading card game (TCG) enthusiasts. The app combines AI-powered card scanning, collection tracking, and peer-to-peer trading across more than a dozen card games in a single platform."
      },
      {
            "name": "Osmos X",
            "website": "https://osmosx.space",
            "description": "Osmos X develops high-thrust reusable space vehicles and advanced plasma propulsion systems for orbital logistics, satellite servicing, space debris removal, and future interplanetary transportation. The company positions itself as a provider of the last mile of space logistics."
      },
      {
            "name": "NotiPark",
            "website": "https://www.notipark.com",
            "description": "NotiPark develops an automated on-street parking solution that starts and stops parking sessions automatically using proprietary high-precision localization technology. The platform eliminates the need for drivers to manually launch parking apps and ensures that users pay only for the time they actually park."
      },
      {
            "name": "Eledone",
            "website": "https://eledone.com",
            "description": "Eledone develops agentic AI software that automates B2B order processing and sales administration. Its platform integrates into existing workflows and systems, eliminating manual data entry between customers and suppliers without requiring companies to change their tools or processes."
      },
      {
            "name": "Aiffin",
            "website": "https://aiffin.com",
            "description": "Aiffin is a Paris-based fintech providing AI-powered vehicle leasing and financing solutions for micro-entrepreneurs and small businesses. Its proprietary underwriting engine, OrbitScore, uses open banking data, cash-flow analysis, and behavioral signals to assess creditworthiness and automate financing decisions."
      },
      {
            "name": "Dawex",
            "website": "https://www.dawex.com",
            "description": "Dawex develops data exchange and data ecosystem technology that enables organizations to securely source, share, trace, and govern data across industries. Its platform supports trusted data collaboration, AI traceability, compliance, and secure data transactions for enterprises and public-sector organizations."
      },
      {
            "name": "Cyclair",
            "website": "https://www.cyclair.fr",
            "description": "Cyclair develops autonomous robotic weeding solutions for field crops. Its robots use camera- and LIDAR-based visual navigation to identify crop rows, distinguish weeds from cultivated plants, perform mechanical weeding, and collect agronomic field data without relying on GPS."
      },
      {
            "name": "Dry4Good",
            "website": "https://www.dry4good.com",
            "description": "Dry4Good develops precision drying technology that transforms fruits, vegetables, and natural raw materials into high-value ingredients while preserving their nutritional and organoleptic properties. The company produces natural flavoring and coloring solutions that help food manufacturers reduce reliance on artificial additives and ingredients."
      },
      {
            "name": "Ellona",
            "website": "https://www.ellona.io",
            "description": "Ellona develops AI-powered environmental and situational intelligence solutions that combine sensors, real-time data analysis, and automated response systems. Its platform helps industrial operators, infrastructure providers, airports, and cities monitor environmental conditions, improve operational efficiency, and optimize infrastructure performance."
      },
      {
            "name": "Morpho Labs",
            "website": "https://morpho.org",
            "description": "Morpho is an open blockchain-based credit network that enables lenders, borrowers, banks, asset managers, fintechs, exchanges, and institutions to build and access programmable on-chain lending and borrowing products through a shared credit infrastructure."
      },
      {
            "name": "Alta Ares",
            "website": "https://www.altaares.com",
            "description": "Alta Ares develops AI-powered air defense systems combining embedded computer vision, radar fusion, and autonomous interceptors to detect, identify, and neutralize drones and cruise missiles in real time."
      },
      {
            "name": "Eclipse",
            "website": "https://eclipse-flow.com/",
            "description": "Eclipse develops battery energy storage projects and Flowstream, an AI-powered optimization platform that buys, stores, and sells electricity based on real-time market conditions. The company aims to transform battery storage into a bankable financial asset while reducing renewable energy waste on European power grids."
      },
      {
            "name": "Mendo",
            "website": "https://mendo.cloud",
            "description": "Mendo develops a SaaS platform that helps enterprises drive adoption of generative AI and AI agents by embedding guidance, training, analytics, and deployment capabilities directly into employees' everyday tools such as Microsoft 365 Copilot, ChatGPT, Gemini, and Mistral AI."
      },
      {
            "name": "Finovox",
            "website": "https://finovox.com",
            "description": "Finovox develops AI-powered document fraud detection solutions for insurers, banks, lenders, and financial institutions. Its platform verifies the authenticity of identity documents, invoices, payroll records, bank details, and supporting documents through API integrations embedded directly into customer workflows."
      },
      {
            "name": "Kyber",
            "website": "https://kyber.io",
            "description": "Kyber develops a real-time communications infrastructure designed for robots, drones, autonomous systems, and AI-powered machines, enabling ultra-low-latency transmission of video, sensor data, audio, and control commands across distributed environments."
      },
      {
            "name": "Seacure",
            "website": "https://www.seacure.fr",
            "description": "Seacure develops Geocorail\u00ae, a patented electrochemical technology that creates natural rock structures in marine environments to protect coastlines, reinforce maritime infrastructure, combat coastal erosion, and restore marine biodiversity."
      },
      {
            "name": "Rematch",
            "website": "https://www.rematch.tv",
            "description": "Rematch is a community-powered media platform for grassroots sports, enabling fans, parents, coaches, and volunteers to capture, create, and share sports highlights. The company is building a global media infrastructure for amateur sports powered by user-generated content and AI-driven video technologies."
      },
      {
            "name": "Builder Assist",
            "website": "https://www.builder-assist.com/",
            "description": "Builder Assist develops robotic solutions for the construction industry. Its flagship product, Surface Assist, is a multi-purpose construction robot designed to automate hazardous and labor-intensive work at height, including facade scanning, precision drilling, sanding, cleaning, and painting."
      },
      {
            "name": "Mobioos",
            "website": "https://www.mobioos.com",
            "description": "Mobioos is building an enterprise context layer that connects business intent, software systems, and organizational knowledge into a trusted foundation for AI agents, autonomous systems, and AI-powered software development. Its platform projects business intent directly into codebases, helping enterprises improve the reliability, governance, and effectiveness of AI-driven workflows."
      },
      {
            "name": "Hit Mag",
            "website": "https://www.hit-mag.fr/en/",
            "description": "Hit Mag develops proprietary magnetic powder technologies to produce high-performance permanent magnets without rare earth elements. Its solutions aim to reduce carbon emissions, strengthen industrial sovereignty, and serve critical sectors including telecommunications, aerospace, automotive, robotics, and renewable energy."
      },
      {
            "name": "R\u00e9empro",
            "website": "https://www.reempro.fr",
            "description": "R\u00e9empro specializes in the reuse and refurbishment of construction materials, equipment, and professional furniture from renovation and selective deconstruction projects. The company manages the full value chain, including diagnostics, selective dismantling, waste management, refurbishment, resale, and logistics."
      },
      {
            "name": "TheraPPI Bioscience",
            "website": "https://tppibio.com",
            "description": "TheraPPI is a preclinical-stage biotech developing protein interaction-modifying therapies for oncology, rare diseases, and inflammatory disorders. Its lead program targets the ERK/MyD88 protein interaction within the Ras-MAPK pathway to overcome cancer drug resistance."
      },
      {
            "name": "Quobly",
            "website": "https://www.quobly.io",
            "description": "Quobly develops silicon-based quantum processors using a proprietary silicon spin qubit architecture designed for scalable, industrial-grade quantum computing. The company leverages semiconductor manufacturing processes to build fault-tolerant quantum systems capable of scaling to millions of qubits."
      },
      {
            "name": "Innovafeed",
            "website": "https://www.innovafeed.com",
            "description": "Innovafeed produces sustainable insect-based ingredients derived from black soldier fly (Hermetia illucens) larvae for animal nutrition, pet food, and agricultural applications. The company operates one of the world's largest insect protein production facilities and focuses on reducing dependence on traditional marine and agricultural feed resources."
      },
      {
            "name": "Innovorder",
            "website": "https://www.innovorder.com",
            "description": "Innovorder develops an all-in-one SaaS platform for restaurant digitalization, covering order management, payments, kitchen operations, business management, customer loyalty, and AI-powered analytics for both commercial and contract catering operators."
      },
      {
            "name": "NP Co.",
            "website": "https://augursim.ai/",
            "description": "NP Co. develops AI foundation models for industrial simulation, enabling engineering teams to run complex physics simulations in seconds rather than days or weeks. Its technology applies transformer architectures to fluid dynamics and industrial engineering problems, helping manufacturers accelerate product design and innovation."
      },
      {
            "name": "noa",
            "website": "https://www.noa.fit",
            "description": "noa is a premium digital wellness startup developing personalized fitness and Pilates applications. The company focuses on structured, long-term coaching experiences that combine fitness, design, and technology to improve user engagement and outcomes."
      },
      {
            "name": "Upstream",
            "website": "https://www.upstream.do/",
            "description": "Upstream is building an AI-native email platform designed for both humans and AI agents. The company transforms the inbox into a collaborative workspace where AI agents can manage workflows, draft responses, schedule meetings, retrieve information, and coordinate actions across teams."
      },
      {
            "name": "Drotek",
            "website": "https://www.drotek.com",
            "description": "Drotek designs and manufactures professional drones and proprietary swarm-flight software for drone light shows. The company provides an integrated offering covering drone production, show creation, regulatory support, rental, technical support, and after-sales services."
      },
      {
            "name": "Primomanda",
            "website": "https://primomanda.fr",
            "description": "Primomanda operates a technology platform dedicated to exclusive real estate mandates, connecting property sellers with real estate agents through a proprietary matching and scoring infrastructure. The company combines marketplace and SaaS models to optimize mandate distribution and agent selection."
      },
      {
            "name": "Tiva",
            "website": "https://tiva.care",
            "description": "Tiva develops performance-focused cosmetic products designed to improve athletic performance, including grip-enhancing gels, waxes, and sports sunscreen products used by professional and amateur athletes."
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
  'funding_deals_june_2026',
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
            "org_name": "Alan",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Bionyra Pharma",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "TISSIUM",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Tsuga",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "AlpSemi",
            "city": "Grenoble",
            "secondary_city": null
      },
      {
            "org_name": "Flease",
            "city": "Lyon",
            "secondary_city": null
      },
      {
            "org_name": "Wheere",
            "city": "Montpellier",
            "secondary_city": null
      },
      {
            "org_name": "Linc",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Sopht",
            "city": "Lyon",
            "secondary_city": null
      },
      {
            "org_name": "Blyyd",
            "city": "Lyon",
            "secondary_city": null
      },
      {
            "org_name": "Cardiawave",
            "city": "Levallois-Perret",
            "secondary_city": null
      },
      {
            "org_name": "Macrodata Labs",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Haiku",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Concord",
            "city": "Paris",
            "secondary_city": "New York City"
      },
      {
            "org_name": "Beams",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Cilcare",
            "city": "Montpellier",
            "secondary_city": null
      },
      {
            "org_name": "Fascent",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "MNGRS.AI",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Comand AI",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Prophesee",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Rocapine",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Green-Got",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "CardNexus",
            "city": "Bordeaux",
            "secondary_city": null
      },
      {
            "org_name": "Osmos X",
            "city": "Rennes",
            "secondary_city": null
      },
      {
            "org_name": "NotiPark",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Eledone",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Aiffin",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Dawex",
            "city": "Lyon",
            "secondary_city": null
      },
      {
            "org_name": "Cyclair",
            "city": "Pressac",
            "secondary_city": null
      },
      {
            "org_name": "Dry4Good",
            "city": "Cergy",
            "secondary_city": null
      },
      {
            "org_name": "Ellona",
            "city": "Toulouse",
            "secondary_city": null
      },
      {
            "org_name": "Morpho Labs",
            "city": "Paris",
            "secondary_city": "New York City"
      },
      {
            "org_name": "Alta Ares",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Eclipse",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Mendo",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Finovox",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Kyber",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Seacure",
            "city": "Marseille",
            "secondary_city": null
      },
      {
            "org_name": "Rematch",
            "city": "Bordeaux",
            "secondary_city": "Fort Worth"
      },
      {
            "org_name": "Builder Assist",
            "city": "Toulouse",
            "secondary_city": null
      },
      {
            "org_name": "Mobioos",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Hit Mag",
            "city": "Plouzan\u00e9",
            "secondary_city": null
      },
      {
            "org_name": "R\u00e9empro",
            "city": "Sequedin",
            "secondary_city": null
      },
      {
            "org_name": "TheraPPI Bioscience",
            "city": "Lyon",
            "secondary_city": "Geneva"
      },
      {
            "org_name": "Quobly",
            "city": "Grenoble",
            "secondary_city": null
      },
      {
            "org_name": "Innovafeed",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Innovorder",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "NP Co.",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "noa",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Upstream",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Drotek",
            "city": "Avignonet-Lauragais",
            "secondary_city": null
      },
      {
            "org_name": "Primomanda",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Tiva",
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
            "name": "Alan",
            "stage": "growth",
            "amount_eur": 480.0,
            "currency_original": "EUR",
            "amount_original": 480000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac480M at a \u20ac5.5B valuation, led by Prosus. 1.1M+ members, 37,000+ businesses, \u20ac800M+ ARR. Subject to French regulatory approval. Sources: Financial Times, Les Echos."
      },
      {
            "name": "Bionyra Pharma",
            "stage": "series_a",
            "amount_eur": 140.0,
            "currency_original": "EUR",
            "amount_original": 140000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac140M oversubscribed Series A, described as the largest biotech Series A ever raised in France. Three clinical-stage candidates. Sources: Maddyness, Genetic Engineering News."
      },
      {
            "name": "TISSIUM",
            "stage": "series_d",
            "amount_eur": 30.0,
            "currency_original": "EUR",
            "amount_original": 30000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac60M package: completed \u20ac30M Series D2 plus up to \u20ac30M from the EIB. Expands US rollout of COAPTIUM CONNECT. $200M+ raised to date. Source: Tech Funding News."
      },
      {
            "name": "Tsuga",
            "stage": "series_a",
            "amount_eur": 30.0,
            "currency_original": "EUR",
            "amount_original": 30000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac30M Series A. Founded 2024; several million euros ARR six months after stealth. Customers incl. Le Monde, Camunda. Source: EU-Startups."
      },
      {
            "name": "AlpSemi",
            "stage": "seed",
            "amount_eur": 17.0,
            "currency_original": "EUR",
            "amount_original": 17000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac17M to industrialize semiconductor power switches for solid-state circuit breakers. First product AS800; roadmap to 800V DC for AI data centers. Source: Les Echos."
      },
      {
            "name": "Flease",
            "stage": "series_a",
            "amount_eur": 13.0,
            "currency_original": "EUR",
            "amount_original": 13000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac13M equity plus \u20ac2.5M debt. Founded 2021; manages 2,000 vehicles. Competes with Arval and Ayvens. Source: Maddyness."
      },
      {
            "name": "Wheere",
            "stage": "bridge",
            "amount_eur": 4.2,
            "currency_original": "EUR",
            "amount_original": 4200000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac4.2M equity within \u20ac8.5M bridge financing ahead of a planned \u20ac40M Series A. Meter-level positioning through 50m of concrete. Customers incl. TotalEnergies, EDF, L'Or\u00e9al. Source: FrenchWeb."
      },
      {
            "name": "Linc",
            "stage": "seed",
            "amount_eur": 8.5,
            "currency_original": "EUR",
            "amount_original": 8500000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac8.5M seed. Serves ~60 accounting firms, targeting 500 by 2027. Founded 2024, French market focus. Source: The French Tech Journal."
      },
      {
            "name": "Sopht",
            "stage": "series_a",
            "amount_eur": 5.0,
            "currency_original": "EUR",
            "amount_original": 5000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as \u20ac7.5M to expand across Europe. ~50 enterprise customers incl. LVMH, BNP Paribas, E.ON, NHS. Source: Maddyness."
      },
      {
            "name": "Blyyd",
            "stage": "growth",
            "amount_eur": 5.0,
            "currency_original": "EUR",
            "amount_original": 5000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac5M from Meridiam's Green Impact Growth Fund. Founded 2015; 160+ vehicles across 100+ sites. Source: Fusacq."
      },
      {
            "name": "Cardiawave",
            "stage": "growth",
            "amount_eur": 3.8,
            "currency_original": "EUR",
            "amount_original": 3800000,
            "announced_date": "2026-06-01",
            "notes": "~\u20ac3.8M via Capital Cell to scale Valvosoft commercialization and prepare FDA submission. Part of a broader recapitalization after 2024 restructuring. Sources: Capital Cell, Les Echos."
      },
      {
            "name": "Macrodata Labs",
            "stage": "pre_seed",
            "amount_eur": 3.6,
            "currency_original": "USD",
            "amount_original": 4000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $4M pre-seed led by Air Street Capital. Founded by ex-Hugging Face researchers (FineWeb). Sources: AirStreet, The Agent Times."
      },
      {
            "name": "Haiku",
            "stage": "seed",
            "amount_eur": 3.0,
            "currency_original": "EUR",
            "amount_original": 3000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac3M (nearly \u20ac5M total). Partners with bar associations and legal publishers. Source: LinkedIn."
      },
      {
            "name": "Concord",
            "stage": "seed",
            "amount_eur": 2.63,
            "currency_original": "USD",
            "amount_original": 3000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $3M seed. Concord Agent automates media buying; early customers report up to 70% time savings. Works with WPP and Havas networks. Source: PR."
      },
      {
            "name": "Beams",
            "stage": "seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.5M within \u20ac3M+ total (equal private/public). CNRS spin-off; first-in-human trials targeted for 2027. Source: LinkedIn."
      },
      {
            "name": "Cilcare",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Updated Sanofi licensing agreement (CIL001, CIL003) with improved royalties; Sanofi becomes a minority shareholder. Source: PR."
      },
      {
            "name": "Fascent",
            "stage": "seed",
            "amount_eur": 1.3,
            "currency_original": "EUR",
            "amount_original": 1300000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.3M angel round (14 industry angels) to expand in the US. 300%+ YoY growth; ~400 stores in 30 countries. Sources: Beauty Independent, Beauty Scale."
      },
      {
            "name": "MNGRS.AI",
            "stage": "seed",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Undisclosed investment from artist manager Cortez Bryant, who joined as Strategic Advisor. Previously raised $1M in 2025. Source: Music Business News."
      },
      {
            "name": "Comand AI",
            "stage": "series_a",
            "amount_eur": 32.0,
            "currency_original": "EUR",
            "amount_original": 32000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac32M Series A for its Prevail C2 platform, deployed in France, Germany, Ukraine and other allied nations. Strategic partnership with Saab. Sources: PR, Tech Funding News."
      },
      {
            "name": "Prophesee",
            "stage": "growth",
            "amount_eur": 20.0,
            "currency_original": "EUR",
            "amount_original": 20000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac20M to commercialize Mantara, its event-based drone detection and tracking system; unveiled Hearth software platform. Source: FrenchWeb."
      },
      {
            "name": "Rocapine",
            "stage": "series_a",
            "amount_eur": 11.0,
            "currency_original": "EUR",
            "amount_original": 11000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $13M Series A (incl. \u20ac2.5M debt). Founded late 2024; $6M ARR within nine months, 2.5M+ downloads, 70% US revenue. Source: Tech Funding News."
      },
      {
            "name": "Green-Got",
            "stage": "other",
            "amount_eur": 8.0,
            "currency_original": "EUR",
            "amount_original": 8000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac8M equity crowdfunding on Crowdcube (5,286 investors). Licensed payment institution (ACPR). \u20ac3B+ transaction volume. Source: Maddyness."
      },
      {
            "name": "CardNexus",
            "stage": "pre_seed",
            "amount_eur": 3.5,
            "currency_original": "EUR",
            "amount_original": 3500000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac3.5M pre-seed. Founded 2025; 50,000+ users, 30M+ cards inventoried. Vault service planned for 2027. Source: EU-Startups."
      },
      {
            "name": "Osmos X",
            "stage": "seed",
            "amount_eur": 2.0,
            "currency_original": "EUR",
            "amount_original": 2000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac2M seed led by Expansion and Rymdkapital. Founded 2022; building a first in-space demonstrator. Source: Le Journal des entreprises."
      },
      {
            "name": "NotiPark",
            "stage": "seed",
            "amount_eur": 1.7,
            "currency_original": "EUR",
            "amount_original": 1700000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.7M to deploy automated on-street parking. In discussions with 30+ cities across Belgium, France, and the Netherlands. Source: LinkedIn."
      },
      {
            "name": "Eledone",
            "stage": "seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.5M seed co-led by Wind to automate B2B order and sales administration with agentic AI. Founded 2024. Source: LinkedIn."
      },
      {
            "name": "Aiffin",
            "stage": "seed",
            "amount_eur": 3.12,
            "currency_original": "EUR",
            "amount_original": 3125000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac3.125M (\u20ac625K equity + \u20ac2.5M debt). OrbitScore underwriting engine; ~\u20ac3M financing portfolio, 250+ applications/month. Source: PR."
      },
      {
            "name": "Dawex",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Strategic investment from Germany's Nemetschek Group to expand governed data exchange and AI-ready data ecosystems. Founders retain full control. Source: Engineering."
      },
      {
            "name": "Cyclair",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Minority investment from cooperative Oc\u00e9alia (Cap 2030 strategy). Robotic weeding for maize, sunflower, rapeseed. Source: Igrownews."
      },
      {
            "name": "Dry4Good",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Backing from the \u00cele-de-France R\u00e9industrialisation Fund (INNOVACOM \u2013 Turenne) and agri-food investors; \u20ac5M to scale the Cergy site to 800 tonnes/year. Source: Fusacq."
      },
      {
            "name": "Ellona",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Growth round led by Green Growth Fund 2; Wermuth Asset Management took ~25%. Existing backers ADP Invest, Airbus Ventures. Source: Assetphysics."
      },
      {
            "name": "Morpho Labs",
            "stage": "growth",
            "amount_eur": 151.1,
            "currency_original": "USD",
            "amount_original": 175000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $175M, co-led by Paradigm, a16z crypto and Ribbit Capital. $11B+ deposits. Attached to existing 'Morpho Labs' organization. Sources: Morpho, Cathay."
      },
      {
            "name": "Alta Ares",
            "stage": "series_a",
            "amount_eur": 50.0,
            "currency_original": "EUR",
            "amount_original": 50000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac50M Series A led by Air Street Capital. Interceptors X-Lock and Black Bird. Airbus Defence and Space partnership. \u20ac10M allocated to Ukraine activities. Sources: Airbus, Reuters, Maddyness."
      },
      {
            "name": "Eclipse",
            "stage": "series_a",
            "amount_eur": 20.0,
            "currency_original": "EUR",
            "amount_original": 20000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac20M Series A led by Noria; BNP Paribas invests and acts as offtaker. Targets 2 GW under management by 2030. Source: LinkedIn."
      },
      {
            "name": "Mendo",
            "stage": "series_a",
            "amount_eur": 12.0,
            "currency_original": "EUR",
            "amount_original": 12000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac12M Series A led by Ventech and Educapital. 100+ large organizations incl. PwC, Novo Nordisk, Cr\u00e9dit Agricole. Source: Journal du net."
      },
      {
            "name": "Finovox",
            "stage": "series_a",
            "amount_eur": 8.2,
            "currency_original": "EUR",
            "amount_original": 8200000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac8.2M Series A led by TX Ventures. 70+ companies across 15 countries incl. Bouygues Telecom, HP, MetLife, Allianz Direct. Sources: Finovox, Maddyness."
      },
      {
            "name": "Kyber",
            "stage": "seed",
            "amount_eur": 4.3,
            "currency_original": "USD",
            "amount_original": 5000000,
            "announced_date": "2026-06-01",
            "notes": "$5M seed led by Lightspeed. Founded by Jean-Baptiste Kempf (VLC/FFmpeg); ~8ms latency, open-core strategy. Source: FrenchWeb."
      },
      {
            "name": "Seacure",
            "stage": "growth",
            "amount_eur": 7.4,
            "currency_original": "EUR",
            "amount_original": 7400000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac7.4M led by the Fonds R\u00e9volution Environnementale et Solidaire (Cr\u00e9dit Mutuel Impact), with Truffle Capital. Founded 2011 in Marseille. Source: Mesinfos."
      },
      {
            "name": "Rematch",
            "stage": "growth",
            "amount_eur": 3.0,
            "currency_original": "EUR",
            "amount_original": 3000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $3.5M growth round. Founded 2017; 1B+ organic views. Second HQ in Fort Worth, Texas. Source: The Antlers American."
      },
      {
            "name": "Builder Assist",
            "stage": "pre_seed",
            "amount_eur": 2.0,
            "currency_original": "EUR",
            "amount_original": 2000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac2M+ combined dilutive and non-dilutive financing. Unveiled Surface Assist at ConTech Connect 2026; partnership with Haulotte. Source: J'aime les startups."
      },
      {
            "name": "Mobioos",
            "stage": "pre_seed",
            "amount_eur": 1.3,
            "currency_original": "USD",
            "amount_original": 1500000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $1.5M pre-seed led by Bombellii Ventures. Supported by Cegid Innovation Hub and Le Village by CA Paris. Source: LinkedIn."
      },
      {
            "name": "Hit Mag",
            "stage": "seed",
            "amount_eur": 1.6,
            "currency_original": "EUR",
            "amount_original": 1600000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.6M to industrialize rare-earth-free magnetic materials. Founded late 2025 in Brest. Sources: Le Telegramme, Les Echos."
      },
      {
            "name": "R\u00e9empro",
            "stage": "growth",
            "amount_eur": 1.6,
            "currency_original": "EUR",
            "amount_original": 1600000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac1.6M to scale construction-material reuse. \u20ac2M revenue in 2025; targeting \u20ac15M within four years. New center near Paris in 2026. Sources: LinkedIn, La Gazette."
      },
      {
            "name": "TheraPPI Bioscience",
            "stage": "pre_seed",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Second closing of a Pre-Seed round with PULSALYS and FONGIT, after Bpifrance France 2030 support. ERK/MyD88 oncology program (Nature Communications 2024). Sources: PR, StartupTicker."
      },
      {
            "name": "Quobly",
            "stage": "series_a",
            "amount_eur": 115.0,
            "currency_original": "EUR",
            "amount_original": 115000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac115M Series A to industrialize silicon spin qubit technology. CEA-Leti spin-out; collaborates with STMicroelectronics. First commercial machine targeted end of 2026. Source: SiliconAngle."
      },
      {
            "name": "Innovafeed",
            "stage": "growth",
            "amount_eur": 51.0,
            "currency_original": "EUR",
            "amount_original": 51000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac51M to move from industrial scale-up to commercial growth. Nesle site fully operational (15,000+ tons produced). Reorganization incl. ~60 position reductions."
      },
      {
            "name": "Innovorder",
            "stage": "growth",
            "amount_eur": 20.0,
            "currency_original": "EUR",
            "amount_original": 20000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac20M led by UL Invest (buyout of some historical investors; Evolem remains). Clients incl. Sodexo, Elior, Compass. Profitable since 2024. Source: EU Startups."
      },
      {
            "name": "NP Co.",
            "stage": "pre_seed",
            "amount_eur": 6.0,
            "currency_original": "EUR",
            "amount_original": 6000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac6M pre-seed led by Partech. Founded 2025; claims up to 1,000x simulation speedups. Product AugurSim. Source: The French Tech Journal."
      },
      {
            "name": "noa",
            "stage": "seed",
            "amount_eur": 5.0,
            "currency_original": "EUR",
            "amount_original": 5000000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac5M seed for its fitness and Pilates platform. Founded 2025; team previously built AppTurbo and Green Panda Games (acquired by Ubisoft)."
      },
      {
            "name": "Upstream",
            "stage": "pre_seed",
            "amount_eur": 2.61,
            "currency_original": "USD",
            "amount_original": 3000000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $3M pre-seed. Founded 2023 at Station F; invite-only beta with thousands of testers. Source: TechFundingNews."
      },
      {
            "name": "Drotek",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-06-01",
            "notes": "Opened capital to Re-Sources and Grand Sud-Ouest Capital. Founded 2012; ~\u20ac8M revenue, 1,000+ drones/month, 5,000+ shows. US arm in Orlando. Source: Gazette du Midi."
      },
      {
            "name": "Primomanda",
            "stage": "seed",
            "amount_eur": 0.6,
            "currency_original": "EUR",
            "amount_original": 600000,
            "announced_date": "2026-06-01",
            "notes": "\u20ac600K to modernize allocation of exclusive real estate mandates. ~100 mandates/month, ~50 partner agents. Partnership with Arthurimmo.com. Source: J'aime les startups."
      },
      {
            "name": "Tiva",
            "stage": "pre_seed",
            "amount_eur": 0.53,
            "currency_original": "USD",
            "amount_original": 600000,
            "announced_date": "2026-06-01",
            "notes": "Reported as $600K+ pre-seed led by Apex, with tennis star Elina Svitolina joining as ambassador and investor. In ~60 retail locations. Source: Sportico."
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
  'funding_deals_june_2026',
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
            "name": "50 Partners"
      },
      {
            "name": "a16z crypto"
      },
      {
            "name": "A16Z Scout"
      },
      {
            "name": "ABC Impact"
      },
      {
            "name": "Acadian Ventures"
      },
      {
            "name": "ADM"
      },
      {
            "name": "Adnexus"
      },
      {
            "name": "ADP Invest"
      },
      {
            "name": "Air Street Capital"
      },
      {
            "name": "Airbus Ventures"
      },
      {
            "name": "Alberto Uncini Manganelli"
      },
      {
            "name": "Amadeus"
      },
      {
            "name": "Aonia"
      },
      {
            "name": "Apex"
      },
      {
            "name": "Apollo Funds"
      },
      {
            "name": "Apollo Health Ventures"
      },
      {
            "name": "Aquiti"
      },
      {
            "name": "Arkin Bio"
      },
      {
            "name": "Arthur Querou"
      },
      {
            "name": "Athletico Ventures"
      },
      {
            "name": "Auriga Cyber Ventures II"
      },
      {
            "name": "Axeleo Capital"
      },
      {
            "name": "Bam Azizi"
      },
      {
            "name": "Banque des Territoires"
      },
      {
            "name": "Better Angle"
      },
      {
            "name": "Blast Club"
      },
      {
            "name": "Blossom Capital"
      },
      {
            "name": "BNP Paribas"
      },
      {
            "name": "Bombellii Ventures"
      },
      {
            "name": "Bouygues Construction"
      },
      {
            "name": "Bpifrance"
      },
      {
            "name": "Bpifrance Digital Venture"
      },
      {
            "name": "Breizh Up"
      },
      {
            "name": "Business Angels d'Ille-et-Vilaine"
      },
      {
            "name": "Business Angels du Finist\u00e8re"
      },
      {
            "name": "Capital Cell"
      },
      {
            "name": "Center Court Capital"
      },
      {
            "name": "Charles Gorintin"
      },
      {
            "name": "Cherry Ventures"
      },
      {
            "name": "Christian Terrassoux"
      },
      {
            "name": "Circle Ventures"
      },
      {
            "name": "Clover"
      },
      {
            "name": "Colas"
      },
      {
            "name": "commit"
      },
      {
            "name": "Connect Ventures"
      },
      {
            "name": "Cortez Bryant"
      },
      {
            "name": "Creadev"
      },
      {
            "name": "Cycle Group"
      },
      {
            "name": "C\u00e9dric O"
      },
      {
            "name": "Daphni"
      },
      {
            "name": "Dara Holdings"
      },
      {
            "name": "Databricks Ventures"
      },
      {
            "name": "Drysdale"
      },
      {
            "name": "Drysdale Ventures"
      },
      {
            "name": "DST Global Partners"
      },
      {
            "name": "Eden"
      },
      {
            "name": "Educapital"
      },
      {
            "name": "Elina Svitolina"
      },
      {
            "name": "Eno Polo"
      },
      {
            "name": "Erik Rosengren"
      },
      {
            "name": "Evolem"
      },
      {
            "name": "Expansion"
      },
      {
            "name": "Expeditions"
      },
      {
            "name": "FDJ United Ventures"
      },
      {
            "name": "Finorpa SCR"
      },
      {
            "name": "Florian Douetteau"
      },
      {
            "name": "Fonds R\u00e9volution Environnementale et Solidaire"
      },
      {
            "name": "FONGIT"
      },
      {
            "name": "Force Over Mass"
      },
      {
            "name": "Founders Future"
      },
      {
            "name": "French Future Champions"
      },
      {
            "name": "FSJ"
      },
      {
            "name": "General Catalyst"
      },
      {
            "name": "Gerald Maradan"
      },
      {
            "name": "Grand Sud-Ouest Capital"
      },
      {
            "name": "Green Growth Fund 2"
      },
      {
            "name": "Groupe IMA"
      },
      {
            "name": "Guillaume Lample"
      },
      {
            "name": "Harpoon"
      },
      {
            "name": "HashKey"
      },
      {
            "name": "Headline"
      },
      {
            "name": "Index Ventures"
      },
      {
            "name": "Intervalle Capital"
      },
      {
            "name": "Intuition"
      },
      {
            "name": "IOSG"
      },
      {
            "name": "Isalt"
      },
      {
            "name": "Itochu Corporation"
      },
      {
            "name": "Jean-Charles Samuelian-Werve"
      },
      {
            "name": "Jean-Jacques Dordain"
      },
      {
            "name": "Jeito Capital"
      },
      {
            "name": "Jorn van Dijk"
      },
      {
            "name": "Julien Lemoine"
      },
      {
            "name": "Kima Ventures"
      },
      {
            "name": "Koen Bok"
      },
      {
            "name": "Lars Jonker"
      },
      {
            "name": "Ledger Cathay Capital"
      },
      {
            "name": "Lightspeed Venture Partners"
      },
      {
            "name": "Linda Tong"
      },
      {
            "name": "Lita"
      },
      {
            "name": "M Capital"
      },
      {
            "name": "MakeSense Seed II"
      },
      {
            "name": "Meridiam"
      },
      {
            "name": "Mirana"
      },
      {
            "name": "Momentous Ventures"
      },
      {
            "name": "Motier"
      },
      {
            "name": "Motier Ventures"
      },
      {
            "name": "MTech Capital"
      },
      {
            "name": "Myriam Maestroni"
      },
      {
            "name": "N1 Investment Company"
      },
      {
            "name": "Navitas Semiconductor"
      },
      {
            "name": "Nemetschek Group"
      },
      {
            "name": "Newfund Capital"
      },
      {
            "name": "Nicolas Dessaigne"
      },
      {
            "name": "NJJ Capital"
      },
      {
            "name": "Noria"
      },
      {
            "name": "Oc\u00e9alia"
      },
      {
            "name": "OPRTRS"
      },
      {
            "name": "OPRTRS CLUB"
      },
      {
            "name": "OTB Ventures"
      },
      {
            "name": "OVNI"
      },
      {
            "name": "OVNI Capital"
      },
      {
            "name": "Paradigm"
      },
      {
            "name": "Partech"
      },
      {
            "name": "Patrick Dalsace"
      },
      {
            "name": "Peugeot Family Office"
      },
      {
            "name": "Philippe Corrot"
      },
      {
            "name": "Picus"
      },
      {
            "name": "Pierre Etienne Lorenceau"
      },
      {
            "name": "Piton Capital"
      },
      {
            "name": "Prelude"
      },
      {
            "name": "Prosus"
      },
      {
            "name": "PULSALYS"
      },
      {
            "name": "Qatar Investment Authority"
      },
      {
            "name": "QuantumLight"
      },
      {
            "name": "Re-Sources"
      },
      {
            "name": "Resonance"
      },
      {
            "name": "Ribbit Capital"
      },
      {
            "name": "Rightbear Holding"
      },
      {
            "name": "Ring Capital"
      },
      {
            "name": "Roxanne Varza"
      },
      {
            "name": "Rymdkapital"
      },
      {
            "name": "R\u00e9mi Lemonnier"
      },
      {
            "name": "Saab"
      },
      {
            "name": "Sanofi"
      },
      {
            "name": "Sanofi Ventures"
      },
      {
            "name": "SATT Ouest Valorisation"
      },
      {
            "name": "SBI Group"
      },
      {
            "name": "SE Ventures"
      },
      {
            "name": "SEALSQ"
      },
      {
            "name": "Singular"
      },
      {
            "name": "Sixty Degree Capital"
      },
      {
            "name": "Sofilaro"
      },
      {
            "name": "Sofinnova Partners"
      },
      {
            "name": "Sowefund"
      },
      {
            "name": "Start Ventures"
      },
      {
            "name": "STMicroelectronics"
      },
      {
            "name": "St\u00e9phane Le Guen"
      },
      {
            "name": "St\u00e9phanie Gottlib-Zeh"
      },
      {
            "name": "Tatiana Terrassoux"
      },
      {
            "name": "Teachers' Venture Growth"
      },
      {
            "name": "Temasek"
      },
      {
            "name": "Ternel"
      },
      {
            "name": "Thierry Herrmann"
      },
      {
            "name": "Thomas Wolf"
      },
      {
            "name": "Thomas Zaepffel"
      },
      {
            "name": "Tomcat"
      },
      {
            "name": "Truffle Capital"
      },
      {
            "name": "TX Ventures"
      },
      {
            "name": "UL Invest"
      },
      {
            "name": "Univers Capital"
      },
      {
            "name": "VanEck"
      },
      {
            "name": "Variant"
      },
      {
            "name": "Ventech"
      },
      {
            "name": "Vincent Luciani"
      },
      {
            "name": "Vives Partners"
      },
      {
            "name": "Wermuth Asset Management"
      },
      {
            "name": "Wind"
      },
      {
            "name": "Wind Capital"
      },
      {
            "name": "Wintermute Ventures"
      },
      {
            "name": "Y Combinator"
      },
      {
            "name": "YG Ventures"
      },
      {
            "name": "Yotta Capital"
      },
      {
            "name": "Youcef Ramdane"
      },
      {
            "name": "\u00c9ric Larchev\u00eaque"
      },
      {
            "name": "\u00cele-de-France R\u00e9industrialisation Fund"
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
  'funding_deals_june_2026',
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
            "org_name": "Alan",
            "announced_date": "2026-06-01",
            "amount_eur": 480.0,
            "investor_name": "Prosus",
            "is_lead": true
      },
      {
            "org_name": "Alan",
            "announced_date": "2026-06-01",
            "amount_eur": 480.0,
            "investor_name": "Teachers' Venture Growth",
            "is_lead": false
      },
      {
            "org_name": "Alan",
            "announced_date": "2026-06-01",
            "amount_eur": 480.0,
            "investor_name": "Index Ventures",
            "is_lead": false
      },
      {
            "org_name": "Alan",
            "announced_date": "2026-06-01",
            "amount_eur": 480.0,
            "investor_name": "Dara Holdings",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Jeito Capital",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Sofinnova Partners",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Arkin Bio",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Sanofi Ventures",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Sixty Degree Capital",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Vives Partners",
            "is_lead": false
      },
      {
            "org_name": "Bionyra Pharma",
            "announced_date": "2026-06-01",
            "amount_eur": 140.0,
            "investor_name": "Apollo Health Ventures",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "Singular",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "General Catalyst",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "DST Global Partners",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "QuantumLight",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "Picus",
            "is_lead": false
      },
      {
            "org_name": "Tsuga",
            "announced_date": "2026-06-01",
            "amount_eur": 30.0,
            "investor_name": "Databricks Ventures",
            "is_lead": false
      },
      {
            "org_name": "AlpSemi",
            "announced_date": "2026-06-01",
            "amount_eur": 17.0,
            "investor_name": "Yotta Capital",
            "is_lead": false
      },
      {
            "org_name": "AlpSemi",
            "announced_date": "2026-06-01",
            "amount_eur": 17.0,
            "investor_name": "SE Ventures",
            "is_lead": false
      },
      {
            "org_name": "AlpSemi",
            "announced_date": "2026-06-01",
            "amount_eur": 17.0,
            "investor_name": "Navitas Semiconductor",
            "is_lead": false
      },
      {
            "org_name": "AlpSemi",
            "announced_date": "2026-06-01",
            "amount_eur": 17.0,
            "investor_name": "Cycle Group",
            "is_lead": false
      },
      {
            "org_name": "Flease",
            "announced_date": "2026-06-01",
            "amount_eur": 13.0,
            "investor_name": "Partech",
            "is_lead": false
      },
      {
            "org_name": "Wheere",
            "announced_date": "2026-06-01",
            "amount_eur": 4.2,
            "investor_name": "Blast Club",
            "is_lead": false
      },
      {
            "org_name": "Wheere",
            "announced_date": "2026-06-01",
            "amount_eur": 4.2,
            "investor_name": "\u00c9ric Larchev\u00eaque",
            "is_lead": false
      },
      {
            "org_name": "Wheere",
            "announced_date": "2026-06-01",
            "amount_eur": 4.2,
            "investor_name": "Sofilaro",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Headline",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Resonance",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Founders Future",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Acadian Ventures",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Adnexus",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "50 Partners",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Motier",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "199 Ventures",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Aonia",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Better Angle",
            "is_lead": false
      },
      {
            "org_name": "Linc",
            "announced_date": "2026-06-01",
            "amount_eur": 8.5,
            "investor_name": "Clover",
            "is_lead": false
      },
      {
            "org_name": "Sopht",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Ternel",
            "is_lead": false
      },
      {
            "org_name": "Sopht",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Axeleo Capital",
            "is_lead": false
      },
      {
            "org_name": "Sopht",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Wind Capital",
            "is_lead": false
      },
      {
            "org_name": "Sopht",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "FDJ United Ventures",
            "is_lead": false
      },
      {
            "org_name": "Blyyd",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Meridiam",
            "is_lead": false
      },
      {
            "org_name": "Cardiawave",
            "announced_date": "2026-06-01",
            "amount_eur": 3.8,
            "investor_name": "Capital Cell",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "Air Street Capital",
            "is_lead": true
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "Thomas Wolf",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "Drysdale Ventures",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "OPRTRS CLUB",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "commit",
            "is_lead": false
      },
      {
            "org_name": "Macrodata Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 3.6,
            "investor_name": "YG Ventures",
            "is_lead": false
      },
      {
            "org_name": "Haiku",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "Newfund Capital",
            "is_lead": false
      },
      {
            "org_name": "Haiku",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "M Capital",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "A16Z Scout",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Drysdale",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Motier Ventures",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Better Angle",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "R\u00e9mi Lemonnier",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Philippe Corrot",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Arthur Querou",
            "is_lead": false
      },
      {
            "org_name": "Concord",
            "announced_date": "2026-06-01",
            "amount_eur": 2.63,
            "investor_name": "Thomas Zaepffel",
            "is_lead": false
      },
      {
            "org_name": "Beams",
            "announced_date": "2026-06-01",
            "amount_eur": 1.5,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Cilcare",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Sanofi",
            "is_lead": false
      },
      {
            "org_name": "MNGRS.AI",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Cortez Bryant",
            "is_lead": false
      },
      {
            "org_name": "Comand AI",
            "announced_date": "2026-06-01",
            "amount_eur": 32.0,
            "investor_name": "Blossom Capital",
            "is_lead": false
      },
      {
            "org_name": "Comand AI",
            "announced_date": "2026-06-01",
            "amount_eur": 32.0,
            "investor_name": "Saab",
            "is_lead": false
      },
      {
            "org_name": "Comand AI",
            "announced_date": "2026-06-01",
            "amount_eur": 32.0,
            "investor_name": "Expeditions",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Educapital",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Daphni",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Ring Capital",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Center Court Capital",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Athletico Ventures",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Better Angle",
            "is_lead": false
      },
      {
            "org_name": "Rocapine",
            "announced_date": "2026-06-01",
            "amount_eur": 11.0,
            "investor_name": "Jean-Charles Samuelian-Werve",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "Piton Capital",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "Motier",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "FSJ",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "OPRTRS",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "CardNexus",
            "announced_date": "2026-06-01",
            "amount_eur": 3.5,
            "investor_name": "Aquiti",
            "is_lead": false
      },
      {
            "org_name": "Osmos X",
            "announced_date": "2026-06-01",
            "amount_eur": 2.0,
            "investor_name": "Expansion",
            "is_lead": true
      },
      {
            "org_name": "Osmos X",
            "announced_date": "2026-06-01",
            "amount_eur": 2.0,
            "investor_name": "Rymdkapital",
            "is_lead": false
      },
      {
            "org_name": "Osmos X",
            "announced_date": "2026-06-01",
            "amount_eur": 2.0,
            "investor_name": "Jean-Jacques Dordain",
            "is_lead": false
      },
      {
            "org_name": "NotiPark",
            "announced_date": "2026-06-01",
            "amount_eur": 1.7,
            "investor_name": "Sowefund",
            "is_lead": false
      },
      {
            "org_name": "NotiPark",
            "announced_date": "2026-06-01",
            "amount_eur": 1.7,
            "investor_name": "N1 Investment Company",
            "is_lead": false
      },
      {
            "org_name": "NotiPark",
            "announced_date": "2026-06-01",
            "amount_eur": 1.7,
            "investor_name": "Bpifrance Digital Venture",
            "is_lead": false
      },
      {
            "org_name": "Eledone",
            "announced_date": "2026-06-01",
            "amount_eur": 1.5,
            "investor_name": "Wind",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Nemetschek Group",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Banque des Territoires",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Amadeus",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Itochu Corporation",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Bouygues Construction",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Colas",
            "is_lead": false
      },
      {
            "org_name": "Dawex",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Univers Capital",
            "is_lead": false
      },
      {
            "org_name": "Cyclair",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Oc\u00e9alia",
            "is_lead": false
      },
      {
            "org_name": "Dry4Good",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "\u00cele-de-France R\u00e9industrialisation Fund",
            "is_lead": false
      },
      {
            "org_name": "Ellona",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Green Growth Fund 2",
            "is_lead": true
      },
      {
            "org_name": "Ellona",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Wermuth Asset Management",
            "is_lead": false
      },
      {
            "org_name": "Ellona",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "ADP Invest",
            "is_lead": false
      },
      {
            "org_name": "Ellona",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Airbus Ventures",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Paradigm",
            "is_lead": true
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "a16z crypto",
            "is_lead": true
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Ribbit Capital",
            "is_lead": true
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Apollo Funds",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Circle Ventures",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "VanEck",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Ledger Cathay Capital",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Variant",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Wintermute Ventures",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Prelude",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "IOSG",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "HashKey",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Mirana",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "NJJ Capital",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "SBI Group",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Morpho Labs",
            "announced_date": "2026-06-01",
            "amount_eur": 151.1,
            "investor_name": "Bam Azizi",
            "is_lead": false
      },
      {
            "org_name": "Alta Ares",
            "announced_date": "2026-06-01",
            "amount_eur": 50.0,
            "investor_name": "Air Street Capital",
            "is_lead": true
      },
      {
            "org_name": "Alta Ares",
            "announced_date": "2026-06-01",
            "amount_eur": 50.0,
            "investor_name": "Cherry Ventures",
            "is_lead": false
      },
      {
            "org_name": "Alta Ares",
            "announced_date": "2026-06-01",
            "amount_eur": 50.0,
            "investor_name": "OTB Ventures",
            "is_lead": false
      },
      {
            "org_name": "Alta Ares",
            "announced_date": "2026-06-01",
            "amount_eur": 50.0,
            "investor_name": "Harpoon",
            "is_lead": false
      },
      {
            "org_name": "Eclipse",
            "announced_date": "2026-06-01",
            "amount_eur": 20.0,
            "investor_name": "Noria",
            "is_lead": true
      },
      {
            "org_name": "Eclipse",
            "announced_date": "2026-06-01",
            "amount_eur": 20.0,
            "investor_name": "BNP Paribas",
            "is_lead": false
      },
      {
            "org_name": "Mendo",
            "announced_date": "2026-06-01",
            "amount_eur": 12.0,
            "investor_name": "Ventech",
            "is_lead": true
      },
      {
            "org_name": "Mendo",
            "announced_date": "2026-06-01",
            "amount_eur": 12.0,
            "investor_name": "Educapital",
            "is_lead": true
      },
      {
            "org_name": "Mendo",
            "announced_date": "2026-06-01",
            "amount_eur": 12.0,
            "investor_name": "Tomcat",
            "is_lead": false
      },
      {
            "org_name": "Mendo",
            "announced_date": "2026-06-01",
            "amount_eur": 12.0,
            "investor_name": "OVNI",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "TX Ventures",
            "is_lead": true
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "Auriga Cyber Ventures II",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "MTech Capital",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "Start Ventures",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "Force Over Mass",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "FDJ UNITED Ventures",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "Blast Club",
            "is_lead": false
      },
      {
            "org_name": "Finovox",
            "announced_date": "2026-06-01",
            "amount_eur": 8.2,
            "investor_name": "Groupe IMA",
            "is_lead": false
      },
      {
            "org_name": "Kyber",
            "announced_date": "2026-06-01",
            "amount_eur": 4.3,
            "investor_name": "Lightspeed Venture Partners",
            "is_lead": true
      },
      {
            "org_name": "Kyber",
            "announced_date": "2026-06-01",
            "amount_eur": 4.3,
            "investor_name": "OVNI Capital",
            "is_lead": false
      },
      {
            "org_name": "Kyber",
            "announced_date": "2026-06-01",
            "amount_eur": 4.3,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "Seacure",
            "announced_date": "2026-06-01",
            "amount_eur": 7.4,
            "investor_name": "Fonds R\u00e9volution Environnementale et Solidaire",
            "is_lead": true
      },
      {
            "org_name": "Seacure",
            "announced_date": "2026-06-01",
            "amount_eur": 7.4,
            "investor_name": "Truffle Capital",
            "is_lead": false
      },
      {
            "org_name": "Rematch",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "Intervalle Capital",
            "is_lead": false
      },
      {
            "org_name": "Rematch",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "St\u00e9phanie Gottlib-Zeh",
            "is_lead": false
      },
      {
            "org_name": "Rematch",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "Erik Rosengren",
            "is_lead": false
      },
      {
            "org_name": "Rematch",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "Rightbear Holding",
            "is_lead": false
      },
      {
            "org_name": "Rematch",
            "announced_date": "2026-06-01",
            "amount_eur": 3.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Mobioos",
            "announced_date": "2026-06-01",
            "amount_eur": 1.3,
            "investor_name": "Bombellii Ventures",
            "is_lead": true
      },
      {
            "org_name": "Mobioos",
            "announced_date": "2026-06-01",
            "amount_eur": 1.3,
            "investor_name": "Pierre Etienne Lorenceau",
            "is_lead": false
      },
      {
            "org_name": "Mobioos",
            "announced_date": "2026-06-01",
            "amount_eur": 1.3,
            "investor_name": "Myriam Maestroni",
            "is_lead": false
      },
      {
            "org_name": "Mobioos",
            "announced_date": "2026-06-01",
            "amount_eur": 1.3,
            "investor_name": "Gerald Maradan",
            "is_lead": false
      },
      {
            "org_name": "Mobioos",
            "announced_date": "2026-06-01",
            "amount_eur": 1.3,
            "investor_name": "Youcef Ramdane",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Lita",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "SATT Ouest Valorisation",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Breizh Up",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Business Angels du Finist\u00e8re",
            "is_lead": false
      },
      {
            "org_name": "Hit Mag",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Business Angels d'Ille-et-Vilaine",
            "is_lead": false
      },
      {
            "org_name": "R\u00e9empro",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "MakeSense Seed II",
            "is_lead": false
      },
      {
            "org_name": "R\u00e9empro",
            "announced_date": "2026-06-01",
            "amount_eur": 1.6,
            "investor_name": "Finorpa SCR",
            "is_lead": false
      },
      {
            "org_name": "TheraPPI Bioscience",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "PULSALYS",
            "is_lead": false
      },
      {
            "org_name": "TheraPPI Bioscience",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "FONGIT",
            "is_lead": false
      },
      {
            "org_name": "Quobly",
            "announced_date": "2026-06-01",
            "amount_eur": 115.0,
            "investor_name": "STMicroelectronics",
            "is_lead": false
      },
      {
            "org_name": "Quobly",
            "announced_date": "2026-06-01",
            "amount_eur": 115.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Quobly",
            "announced_date": "2026-06-01",
            "amount_eur": 115.0,
            "investor_name": "SEALSQ",
            "is_lead": false
      },
      {
            "org_name": "Quobly",
            "announced_date": "2026-06-01",
            "amount_eur": 115.0,
            "investor_name": "Isalt",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "Creadev",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "Qatar Investment Authority",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "Temasek",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "French Future Champions",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "ABC Impact",
            "is_lead": false
      },
      {
            "org_name": "Innovafeed",
            "announced_date": "2026-06-01",
            "amount_eur": 51.0,
            "investor_name": "ADM",
            "is_lead": false
      },
      {
            "org_name": "Innovorder",
            "announced_date": "2026-06-01",
            "amount_eur": 20.0,
            "investor_name": "UL Invest",
            "is_lead": true
      },
      {
            "org_name": "Innovorder",
            "announced_date": "2026-06-01",
            "amount_eur": 20.0,
            "investor_name": "Evolem",
            "is_lead": false
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "Partech",
            "is_lead": true
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "Guillaume Lample",
            "is_lead": false
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "C\u00e9dric O",
            "is_lead": false
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "Peugeot Family Office",
            "is_lead": false
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "Florian Douetteau",
            "is_lead": false
      },
      {
            "org_name": "NP Co.",
            "announced_date": "2026-06-01",
            "amount_eur": 6.0,
            "investor_name": "Vincent Luciani",
            "is_lead": false
      },
      {
            "org_name": "noa",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Founders Future",
            "is_lead": false
      },
      {
            "org_name": "noa",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "noa",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Drysdale",
            "is_lead": false
      },
      {
            "org_name": "noa",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Eden",
            "is_lead": false
      },
      {
            "org_name": "noa",
            "announced_date": "2026-06-01",
            "amount_eur": 5.0,
            "investor_name": "Intuition",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Y Combinator",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Connect Ventures",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Koen Bok",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Jorn van Dijk",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Nicolas Dessaigne",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Julien Lemoine",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Linda Tong",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Jean-Charles Samuelian-Werve",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Charles Gorintin",
            "is_lead": false
      },
      {
            "org_name": "Upstream",
            "announced_date": "2026-06-01",
            "amount_eur": 2.61,
            "investor_name": "Roxanne Varza",
            "is_lead": false
      },
      {
            "org_name": "Drotek",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Re-Sources",
            "is_lead": false
      },
      {
            "org_name": "Drotek",
            "announced_date": "2026-06-01",
            "amount_eur": null,
            "investor_name": "Grand Sud-Ouest Capital",
            "is_lead": false
      },
      {
            "org_name": "Primomanda",
            "announced_date": "2026-06-01",
            "amount_eur": 0.6,
            "investor_name": "Patrick Dalsace",
            "is_lead": false
      },
      {
            "org_name": "Primomanda",
            "announced_date": "2026-06-01",
            "amount_eur": 0.6,
            "investor_name": "Thierry Herrmann",
            "is_lead": false
      },
      {
            "org_name": "Primomanda",
            "announced_date": "2026-06-01",
            "amount_eur": 0.6,
            "investor_name": "St\u00e9phane Le Guen",
            "is_lead": false
      },
      {
            "org_name": "Primomanda",
            "announced_date": "2026-06-01",
            "amount_eur": 0.6,
            "investor_name": "Christian Terrassoux",
            "is_lead": false
      },
      {
            "org_name": "Primomanda",
            "announced_date": "2026-06-01",
            "amount_eur": 0.6,
            "investor_name": "Tatiana Terrassoux",
            "is_lead": false
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Apex",
            "is_lead": true
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Elina Svitolina",
            "is_lead": false
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Eno Polo",
            "is_lead": false
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Lars Jonker",
            "is_lead": false
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Alberto Uncini Manganelli",
            "is_lead": false
      },
      {
            "org_name": "Tiva",
            "announced_date": "2026-06-01",
            "amount_eur": 0.53,
            "investor_name": "Momentous Ventures",
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
  AND fr.source_name = 'funding_deals_june_2026'
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
            "org": "alan",
            "sec": "insurtech"
      },
      {
            "org": "alan",
            "sec": "artificial-intelligence"
      },
      {
            "org": "bionyra-pharma",
            "sec": "biotech"
      },
      {
            "org": "bionyra-pharma",
            "sec": "healthtech"
      },
      {
            "org": "tissium",
            "sec": "medtech"
      },
      {
            "org": "tissium",
            "sec": "biotech"
      },
      {
            "org": "tsuga",
            "sec": "artificial-intelligence"
      },
      {
            "org": "tsuga",
            "sec": "saas"
      },
      {
            "org": "alpsemi",
            "sec": "semiconductors"
      },
      {
            "org": "alpsemi",
            "sec": "artificial-intelligence"
      },
      {
            "org": "alpsemi",
            "sec": "climatetech"
      },
      {
            "org": "alpsemi",
            "sec": "deeptech"
      },
      {
            "org": "flease",
            "sec": "mobility"
      },
      {
            "org": "flease",
            "sec": "climatetech"
      },
      {
            "org": "flease",
            "sec": "saas"
      },
      {
            "org": "wheere",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "wheere",
            "sec": "deeptech"
      },
      {
            "org": "wheere",
            "sec": "semiconductors"
      },
      {
            "org": "linc",
            "sec": "saas"
      },
      {
            "org": "linc",
            "sec": "fintech"
      },
      {
            "org": "linc",
            "sec": "artificial-intelligence"
      },
      {
            "org": "sopht",
            "sec": "climatetech"
      },
      {
            "org": "sopht",
            "sec": "artificial-intelligence"
      },
      {
            "org": "blyyd",
            "sec": "cleantech"
      },
      {
            "org": "blyyd",
            "sec": "mobility"
      },
      {
            "org": "cardiawave",
            "sec": "medtech"
      },
      {
            "org": "cardiawave",
            "sec": "healthtech"
      },
      {
            "org": "cardiawave",
            "sec": "deeptech"
      },
      {
            "org": "macrodata-labs",
            "sec": "artificial-intelligence"
      },
      {
            "org": "macrodata-labs",
            "sec": "robotics"
      },
      {
            "org": "haiku",
            "sec": "legaltech"
      },
      {
            "org": "haiku",
            "sec": "artificial-intelligence"
      },
      {
            "org": "haiku",
            "sec": "saas"
      },
      {
            "org": "concord",
            "sec": "adtech"
      },
      {
            "org": "concord",
            "sec": "artificial-intelligence"
      },
      {
            "org": "concord",
            "sec": "saas"
      },
      {
            "org": "beams",
            "sec": "medtech"
      },
      {
            "org": "cilcare",
            "sec": "biotech"
      },
      {
            "org": "cilcare",
            "sec": "healthtech"
      },
      {
            "org": "cilcare",
            "sec": "artificial-intelligence"
      },
      {
            "org": "fascent",
            "sec": "e-commerce-retail"
      },
      {
            "org": "mngrsai",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mngrsai",
            "sec": "entertainment"
      },
      {
            "org": "comand-ai",
            "sec": "defensetech"
      },
      {
            "org": "comand-ai",
            "sec": "artificial-intelligence"
      },
      {
            "org": "prophesee",
            "sec": "defensetech"
      },
      {
            "org": "prophesee",
            "sec": "drones"
      },
      {
            "org": "prophesee",
            "sec": "artificial-intelligence"
      },
      {
            "org": "prophesee",
            "sec": "deeptech"
      },
      {
            "org": "rocapine",
            "sec": "healthtech"
      },
      {
            "org": "rocapine",
            "sec": "artificial-intelligence"
      },
      {
            "org": "green-got",
            "sec": "fintech"
      },
      {
            "org": "green-got",
            "sec": "cleantech"
      },
      {
            "org": "green-got",
            "sec": "climatetech"
      },
      {
            "org": "cardnexus",
            "sec": "gaming"
      },
      {
            "org": "cardnexus",
            "sec": "artificial-intelligence"
      },
      {
            "org": "cardnexus",
            "sec": "fintech"
      },
      {
            "org": "osmos-x",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "osmos-x",
            "sec": "defensetech"
      },
      {
            "org": "notipark",
            "sec": "mobility"
      },
      {
            "org": "notipark",
            "sec": "saas"
      },
      {
            "org": "eledone",
            "sec": "artificial-intelligence"
      },
      {
            "org": "eledone",
            "sec": "saas"
      },
      {
            "org": "aiffin",
            "sec": "fintech"
      },
      {
            "org": "aiffin",
            "sec": "mobility"
      },
      {
            "org": "aiffin",
            "sec": "artificial-intelligence"
      },
      {
            "org": "dawex",
            "sec": "artificial-intelligence"
      },
      {
            "org": "dawex",
            "sec": "saas"
      },
      {
            "org": "cyclair",
            "sec": "agritech"
      },
      {
            "org": "cyclair",
            "sec": "robotics"
      },
      {
            "org": "dry4good",
            "sec": "foodtech"
      },
      {
            "org": "dry4good",
            "sec": "agritech"
      },
      {
            "org": "dry4good",
            "sec": "biotech"
      },
      {
            "org": "ellona",
            "sec": "artificial-intelligence"
      },
      {
            "org": "ellona",
            "sec": "climatetech"
      },
      {
            "org": "morpho-labs",
            "sec": "fintech"
      },
      {
            "org": "morpho-labs",
            "sec": "web3"
      },
      {
            "org": "alta-ares",
            "sec": "defensetech"
      },
      {
            "org": "alta-ares",
            "sec": "artificial-intelligence"
      },
      {
            "org": "alta-ares",
            "sec": "drones"
      },
      {
            "org": "eclipse",
            "sec": "climatetech"
      },
      {
            "org": "eclipse",
            "sec": "energy"
      },
      {
            "org": "eclipse",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mendo",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mendo",
            "sec": "saas"
      },
      {
            "org": "finovox",
            "sec": "fintech"
      },
      {
            "org": "finovox",
            "sec": "insurtech"
      },
      {
            "org": "finovox",
            "sec": "cybersecurity"
      },
      {
            "org": "finovox",
            "sec": "artificial-intelligence"
      },
      {
            "org": "kyber",
            "sec": "artificial-intelligence"
      },
      {
            "org": "kyber",
            "sec": "robotics"
      },
      {
            "org": "kyber",
            "sec": "defensetech"
      },
      {
            "org": "kyber",
            "sec": "drones"
      },
      {
            "org": "seacure",
            "sec": "climatetech"
      },
      {
            "org": "seacure",
            "sec": "deeptech"
      },
      {
            "org": "rematch",
            "sec": "sportstech"
      },
      {
            "org": "rematch",
            "sec": "entertainment"
      },
      {
            "org": "rematch",
            "sec": "artificial-intelligence"
      },
      {
            "org": "builder-assist",
            "sec": "robotics"
      },
      {
            "org": "builder-assist",
            "sec": "deeptech"
      },
      {
            "org": "builder-assist",
            "sec": "proptech"
      },
      {
            "org": "mobioos",
            "sec": "artificial-intelligence"
      },
      {
            "org": "mobioos",
            "sec": "saas"
      },
      {
            "org": "hit-mag",
            "sec": "cleantech"
      },
      {
            "org": "hit-mag",
            "sec": "deeptech"
      },
      {
            "org": "reempro",
            "sec": "cleantech"
      },
      {
            "org": "reempro",
            "sec": "climatetech"
      },
      {
            "org": "therappi-bioscience",
            "sec": "biotech"
      },
      {
            "org": "therappi-bioscience",
            "sec": "deeptech"
      },
      {
            "org": "quobly",
            "sec": "quantum-computing"
      },
      {
            "org": "quobly",
            "sec": "deeptech"
      },
      {
            "org": "innovafeed",
            "sec": "agritech"
      },
      {
            "org": "innovafeed",
            "sec": "foodtech"
      },
      {
            "org": "innovafeed",
            "sec": "climatetech"
      },
      {
            "org": "innovorder",
            "sec": "foodtech"
      },
      {
            "org": "innovorder",
            "sec": "saas"
      },
      {
            "org": "innovorder",
            "sec": "artificial-intelligence"
      },
      {
            "org": "np-co",
            "sec": "artificial-intelligence"
      },
      {
            "org": "np-co",
            "sec": "deeptech"
      },
      {
            "org": "noa",
            "sec": "sportstech"
      },
      {
            "org": "noa",
            "sec": "healthtech"
      },
      {
            "org": "noa",
            "sec": "artificial-intelligence"
      },
      {
            "org": "upstream",
            "sec": "artificial-intelligence"
      },
      {
            "org": "upstream",
            "sec": "saas"
      },
      {
            "org": "drotek",
            "sec": "drones"
      },
      {
            "org": "drotek",
            "sec": "robotics"
      },
      {
            "org": "primomanda",
            "sec": "proptech"
      },
      {
            "org": "primomanda",
            "sec": "saas"
      },
      {
            "org": "tiva",
            "sec": "sportstech"
      },
      {
            "org": "tiva",
            "sec": "healthtech"
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
            "org": "alan",
            "sec": "insurtech"
      },
      {
            "org": "bionyra-pharma",
            "sec": "biotech"
      },
      {
            "org": "tissium",
            "sec": "medtech"
      },
      {
            "org": "tsuga",
            "sec": "artificial-intelligence"
      },
      {
            "org": "alpsemi",
            "sec": "semiconductors"
      },
      {
            "org": "flease",
            "sec": "mobility"
      },
      {
            "org": "wheere",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "linc",
            "sec": "saas"
      },
      {
            "org": "sopht",
            "sec": "climatetech"
      },
      {
            "org": "blyyd",
            "sec": "cleantech"
      },
      {
            "org": "cardiawave",
            "sec": "medtech"
      },
      {
            "org": "macrodata-labs",
            "sec": "artificial-intelligence"
      },
      {
            "org": "haiku",
            "sec": "legaltech"
      },
      {
            "org": "concord",
            "sec": "adtech"
      },
      {
            "org": "beams",
            "sec": "medtech"
      },
      {
            "org": "cilcare",
            "sec": "biotech"
      },
      {
            "org": "fascent",
            "sec": "e-commerce-retail"
      },
      {
            "org": "mngrsai",
            "sec": "artificial-intelligence"
      },
      {
            "org": "comand-ai",
            "sec": "defensetech"
      },
      {
            "org": "prophesee",
            "sec": "defensetech"
      },
      {
            "org": "rocapine",
            "sec": "healthtech"
      },
      {
            "org": "green-got",
            "sec": "fintech"
      },
      {
            "org": "cardnexus",
            "sec": "gaming"
      },
      {
            "org": "osmos-x",
            "sec": "spacetech-aerospace"
      },
      {
            "org": "notipark",
            "sec": "mobility"
      },
      {
            "org": "eledone",
            "sec": "artificial-intelligence"
      },
      {
            "org": "aiffin",
            "sec": "fintech"
      },
      {
            "org": "dawex",
            "sec": "artificial-intelligence"
      },
      {
            "org": "cyclair",
            "sec": "agritech"
      },
      {
            "org": "dry4good",
            "sec": "foodtech"
      },
      {
            "org": "ellona",
            "sec": "artificial-intelligence"
      },
      {
            "org": "morpho-labs",
            "sec": "fintech"
      },
      {
            "org": "alta-ares",
            "sec": "defensetech"
      },
      {
            "org": "eclipse",
            "sec": "climatetech"
      },
      {
            "org": "mendo",
            "sec": "artificial-intelligence"
      },
      {
            "org": "finovox",
            "sec": "fintech"
      },
      {
            "org": "kyber",
            "sec": "artificial-intelligence"
      },
      {
            "org": "seacure",
            "sec": "climatetech"
      },
      {
            "org": "rematch",
            "sec": "sportstech"
      },
      {
            "org": "builder-assist",
            "sec": "robotics"
      },
      {
            "org": "mobioos",
            "sec": "artificial-intelligence"
      },
      {
            "org": "hit-mag",
            "sec": "cleantech"
      },
      {
            "org": "reempro",
            "sec": "cleantech"
      },
      {
            "org": "therappi-bioscience",
            "sec": "biotech"
      },
      {
            "org": "quobly",
            "sec": "quantum-computing"
      },
      {
            "org": "innovafeed",
            "sec": "agritech"
      },
      {
            "org": "innovorder",
            "sec": "foodtech"
      },
      {
            "org": "np-co",
            "sec": "artificial-intelligence"
      },
      {
            "org": "noa",
            "sec": "sportstech"
      },
      {
            "org": "upstream",
            "sec": "artificial-intelligence"
      },
      {
            "org": "drotek",
            "sec": "drones"
      },
      {
            "org": "primomanda",
            "sec": "proptech"
      },
      {
            "org": "tiva",
            "sec": "sportstech"
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
            "full_name": "Jean-Charles Samuelian-Werve",
            "first_name": "Jean-Charles",
            "last_name": "Samuelian-Werve"
      },
      {
            "full_name": "Charles Gorintin",
            "first_name": "Charles",
            "last_name": "Gorintin"
      },
      {
            "full_name": "Fr\u00e9d\u00e9ric Marrache",
            "first_name": "Fr\u00e9d\u00e9ric",
            "last_name": "Marrache"
      },
      {
            "full_name": "Christophe Bancel",
            "first_name": "Christophe",
            "last_name": "Bancel"
      },
      {
            "full_name": "Maria Pereira",
            "first_name": "Maria",
            "last_name": "Pereira"
      },
      {
            "full_name": "Gabriel-James Safar",
            "first_name": "Gabriel-James",
            "last_name": "Safar"
      },
      {
            "full_name": "Fr\u00e9d\u00e9ric Dupont",
            "first_name": "Fr\u00e9d\u00e9ric",
            "last_name": "Dupont"
      },
      {
            "full_name": "Fabrice Letertre",
            "first_name": "Fabrice",
            "last_name": "Letertre"
      },
      {
            "full_name": "Constantin Eliard",
            "first_name": "Constantin",
            "last_name": "Eliard"
      },
      {
            "full_name": "Vincent Dreyfus",
            "first_name": "Vincent",
            "last_name": "Dreyfus"
      },
      {
            "full_name": "Pierre-Arnaud Coquelin",
            "first_name": "Pierre-Arnaud",
            "last_name": "Coquelin"
      },
      {
            "full_name": "Antoine Carrabin",
            "first_name": "Antoine",
            "last_name": "Carrabin"
      },
      {
            "full_name": "Baptiste Le Bihan",
            "first_name": "Baptiste",
            "last_name": "Le Bihan"
      },
      {
            "full_name": "F\u00e9lix Wattez",
            "first_name": "F\u00e9lix",
            "last_name": "Wattez"
      },
      {
            "full_name": "Thomas de Priestere",
            "first_name": "Thomas",
            "last_name": "de Priestere"
      },
      {
            "full_name": "Julien Rouz\u00e9",
            "first_name": "Julien",
            "last_name": "Rouz\u00e9"
      },
      {
            "full_name": "J\u00e9r\u00e9mie Veg",
            "first_name": "J\u00e9r\u00e9mie",
            "last_name": "Veg"
      },
      {
            "full_name": "Damien Gambey",
            "first_name": "Damien",
            "last_name": "Gambey"
      },
      {
            "full_name": "Micka\u00ebl Tanter",
            "first_name": "Micka\u00ebl",
            "last_name": "Tanter"
      },
      {
            "full_name": "Mathieu Pernot",
            "first_name": "Mathieu",
            "last_name": "Pernot"
      },
      {
            "full_name": "Emmanuel Messas",
            "first_name": "Emmanuel",
            "last_name": "Messas"
      },
      {
            "full_name": "Guilherme Penedo",
            "first_name": "Guilherme",
            "last_name": "Penedo"
      },
      {
            "full_name": "Hynek Kydl\u00ed\u010dek",
            "first_name": "Hynek",
            "last_name": "Kydl\u00ed\u010dek"
      },
      {
            "full_name": "Jules Touzet",
            "first_name": "Jules",
            "last_name": "Touzet"
      },
      {
            "full_name": "Jorick Nuss",
            "first_name": "Jorick",
            "last_name": "Nuss"
      },
      {
            "full_name": "Jean Marcel Touzet",
            "first_name": "Jean",
            "last_name": "Marcel Touzet"
      },
      {
            "full_name": "Nathan Venezia",
            "first_name": "Nathan",
            "last_name": "Venezia"
      },
      {
            "full_name": "Nicolas Cosson",
            "first_name": "Nicolas",
            "last_name": "Cosson"
      },
      {
            "full_name": "Antoine Chwalek",
            "first_name": "Antoine",
            "last_name": "Chwalek"
      },
      {
            "full_name": "Virginie Simon",
            "first_name": "Virginie",
            "last_name": "Simon"
      },
      {
            "full_name": "Estelle Villedieu de Torcy",
            "first_name": "Estelle",
            "last_name": "Villedieu de Torcy"
      },
      {
            "full_name": "St\u00e9phane Palfi",
            "first_name": "St\u00e9phane",
            "last_name": "Palfi"
      },
      {
            "full_name": "Laurent M\u00e9nard",
            "first_name": "Laurent",
            "last_name": "M\u00e9nard"
      },
      {
            "full_name": "Celia Belline",
            "first_name": "Celia",
            "last_name": "Belline"
      },
      {
            "full_name": "Sophie Gaboyard-Niay",
            "first_name": "Sophie",
            "last_name": "Gaboyard-Niay"
      },
      {
            "full_name": "Fanny Descamps",
            "first_name": "Fanny",
            "last_name": "Descamps"
      },
      {
            "full_name": "Edwina R\u00e9thor\u00e9",
            "first_name": "Edwina",
            "last_name": "R\u00e9thor\u00e9"
      },
      {
            "full_name": "Alexandre Deniot",
            "first_name": "Alexandre",
            "last_name": "Deniot"
      },
      {
            "full_name": "Thomas Quenoil",
            "first_name": "Thomas",
            "last_name": "Quenoil"
      },
      {
            "full_name": "Lo\u00efc Mougeolle",
            "first_name": "Lo\u00efc",
            "last_name": "Mougeolle"
      },
      {
            "full_name": "Antoine Chassan",
            "first_name": "Antoine",
            "last_name": "Chassan"
      },
      {
            "full_name": "Luca Verre",
            "first_name": "Luca",
            "last_name": "Verre"
      },
      {
            "full_name": "Christoph Posch",
            "first_name": "Christoph",
            "last_name": "Posch"
      },
      {
            "full_name": "Ryad Benosman",
            "first_name": "Ryad",
            "last_name": "Benosman"
      },
      {
            "full_name": "Stanislas Marchand",
            "first_name": "Stanislas",
            "last_name": "Marchand"
      },
      {
            "full_name": "Jean-Gabriel Boinot-Tramoni",
            "first_name": "Jean-Gabriel",
            "last_name": "Boinot-Tramoni"
      },
      {
            "full_name": "Sammy Teillet",
            "first_name": "Sammy",
            "last_name": "Teillet"
      },
      {
            "full_name": "Maud Caillaux",
            "first_name": "Maud",
            "last_name": "Caillaux"
      },
      {
            "full_name": "Andr\u00e9a Ganovelli",
            "first_name": "Andr\u00e9a",
            "last_name": "Ganovelli"
      },
      {
            "full_name": "Fabien Huet",
            "first_name": "Fabien",
            "last_name": "Huet"
      },
      {
            "full_name": "Tristan Foureur",
            "first_name": "Tristan",
            "last_name": "Foureur"
      },
      {
            "full_name": "Matthieu Cavellier",
            "first_name": "Matthieu",
            "last_name": "Cavellier"
      },
      {
            "full_name": "Jeremy Skowronek",
            "first_name": "Jeremy",
            "last_name": "Skowronek"
      },
      {
            "full_name": "Bruno Heckel",
            "first_name": "Bruno",
            "last_name": "Heckel"
      },
      {
            "full_name": "Arno Heckel",
            "first_name": "Arno",
            "last_name": "Heckel"
      },
      {
            "full_name": "Erwan Boullier",
            "first_name": "Erwan",
            "last_name": "Boullier"
      },
      {
            "full_name": "Sergii Vaskov",
            "first_name": "Sergii",
            "last_name": "Vaskov"
      },
      {
            "full_name": "Khalil Aram",
            "first_name": "Khalil",
            "last_name": "Aram"
      },
      {
            "full_name": "Laure Lucchesi",
            "first_name": "Laure",
            "last_name": "Lucchesi"
      },
      {
            "full_name": "Fabrice Tocco",
            "first_name": "Fabrice",
            "last_name": "Tocco"
      },
      {
            "full_name": "Quentin Guillemot",
            "first_name": "Quentin",
            "last_name": "Guillemot"
      },
      {
            "full_name": "Sebastien Gorry",
            "first_name": "Sebastien",
            "last_name": "Gorry"
      },
      {
            "full_name": "Camille Auger",
            "first_name": "Camille",
            "last_name": "Auger"
      },
      {
            "full_name": "Jean-Gabriel Dijoud",
            "first_name": "Jean-Gabriel",
            "last_name": "Dijoud"
      },
      {
            "full_name": "Romaric Janssen",
            "first_name": "Romaric",
            "last_name": "Janssen"
      },
      {
            "full_name": "Abdelwahed Lahmar",
            "first_name": "Abdelwahed",
            "last_name": "Lahmar"
      },
      {
            "full_name": "R\u00e9mi El-Ouazzane",
            "first_name": "R\u00e9mi",
            "last_name": "El-Ouazzane"
      },
      {
            "full_name": "Abdelilah Lahmar",
            "first_name": "Abdelilah",
            "last_name": "Lahmar"
      },
      {
            "full_name": "Paul Frambot",
            "first_name": "Paul",
            "last_name": "Frambot"
      },
      {
            "full_name": "Stanislas Walch",
            "first_name": "Stanislas",
            "last_name": "Walch"
      },
      {
            "full_name": "Th\u00e9o Bondarec",
            "first_name": "Th\u00e9o",
            "last_name": "Bondarec"
      },
      {
            "full_name": "Hadrien Bernard",
            "first_name": "Hadrien",
            "last_name": "Bernard"
      },
      {
            "full_name": "Alain Henry",
            "first_name": "Alain",
            "last_name": "Henry"
      },
      {
            "full_name": "Hadrien Canter",
            "first_name": "Hadrien",
            "last_name": "Canter"
      },
      {
            "full_name": "Augustin Derville",
            "first_name": "Augustin",
            "last_name": "Derville"
      },
      {
            "full_name": "Quentin Amaudry",
            "first_name": "Quentin",
            "last_name": "Amaudry"
      },
      {
            "full_name": "Alexandre Pinon",
            "first_name": "Alexandre",
            "last_name": "Pinon"
      },
      {
            "full_name": "Marc de Beaucorps",
            "first_name": "Marc",
            "last_name": "de Beaucorps"
      },
      {
            "full_name": "Th\u00e9ophile du Portal",
            "first_name": "Th\u00e9ophile",
            "last_name": "du Portal"
      },
      {
            "full_name": "Pierre-Alexis Gouzien",
            "first_name": "Pierre-Alexis",
            "last_name": "Gouzien"
      },
      {
            "full_name": "Jean-Baptiste Kempf",
            "first_name": "Jean-Baptiste",
            "last_name": "Kempf"
      },
      {
            "full_name": "Christophe Souillart",
            "first_name": "Christophe",
            "last_name": "Souillart"
      },
      {
            "full_name": "Pierre Husson",
            "first_name": "Pierre",
            "last_name": "Husson"
      },
      {
            "full_name": "Franck-Si Hassen",
            "first_name": "Franck-Si",
            "last_name": "Hassen"
      },
      {
            "full_name": "Fran\u00e7ois Alary",
            "first_name": "Fran\u00e7ois",
            "last_name": "Alary"
      },
      {
            "full_name": "Alban Brisy",
            "first_name": "Alban",
            "last_name": "Brisy"
      },
      {
            "full_name": "Zaak Chalal",
            "first_name": "Zaak",
            "last_name": "Chalal"
      },
      {
            "full_name": "Arnault Trac",
            "first_name": "Arnault",
            "last_name": "Trac"
      },
      {
            "full_name": "Jean-Baptiste Duran",
            "first_name": "Jean-Baptiste",
            "last_name": "Duran"
      },
      {
            "full_name": "Adrien Verlinde",
            "first_name": "Adrien",
            "last_name": "Verlinde"
      },
      {
            "full_name": "Luc Otten",
            "first_name": "Luc",
            "last_name": "Otten"
      },
      {
            "full_name": "Toufic Renno",
            "first_name": "Toufic",
            "last_name": "Renno"
      },
      {
            "full_name": "Isabelle Coste",
            "first_name": "Isabelle",
            "last_name": "Coste"
      },
      {
            "full_name": "St\u00e9phane Giraud",
            "first_name": "St\u00e9phane",
            "last_name": "Giraud"
      },
      {
            "full_name": "Maud Vinet",
            "first_name": "Maud",
            "last_name": "Vinet"
      },
      {
            "full_name": "Laurent Schmid",
            "first_name": "Laurent",
            "last_name": "Schmid"
      },
      {
            "full_name": "Philippe Campana",
            "first_name": "Philippe",
            "last_name": "Campana"
      },
      {
            "full_name": "Aude Guo",
            "first_name": "Aude",
            "last_name": "Guo"
      },
      {
            "full_name": "Bastien Oggeri",
            "first_name": "Bastien",
            "last_name": "Oggeri"
      },
      {
            "full_name": "Cl\u00e9ment Ray",
            "first_name": "Cl\u00e9ment",
            "last_name": "Ray"
      },
      {
            "full_name": "J\u00e9r\u00f4me Varnier",
            "first_name": "J\u00e9r\u00f4me",
            "last_name": "Varnier"
      },
      {
            "full_name": "Romain Melloul",
            "first_name": "Romain",
            "last_name": "Melloul"
      },
      {
            "full_name": "Olivier Loverde",
            "first_name": "Olivier",
            "last_name": "Loverde"
      },
      {
            "full_name": "Emmanuel Menier",
            "first_name": "Emmanuel",
            "last_name": "Menier"
      },
      {
            "full_name": "Matthieu Nastorg",
            "first_name": "Matthieu",
            "last_name": "Nastorg"
      },
      {
            "full_name": "Guillaume Sztejnberg",
            "first_name": "Guillaume",
            "last_name": "Sztejnberg"
      },
      {
            "full_name": "Shreyas Rajagopalan",
            "first_name": "Shreyas",
            "last_name": "Rajagopalan"
      },
      {
            "full_name": "Jason Akakpo",
            "first_name": "Jason",
            "last_name": "Akakpo"
      },
      {
            "full_name": "Louis Lecat",
            "first_name": "Louis",
            "last_name": "Lecat"
      },
      {
            "full_name": "Jonathan Tiret",
            "first_name": "Jonathan",
            "last_name": "Tiret"
      },
      {
            "full_name": "J\u00e9r\u00f4me Perin",
            "first_name": "J\u00e9r\u00f4me",
            "last_name": "Perin"
      },
      {
            "full_name": "Benjamin Leiba",
            "first_name": "Benjamin",
            "last_name": "Leiba"
      },
      {
            "full_name": "Benjamin Mechaly",
            "first_name": "Benjamin",
            "last_name": "Mechaly"
      },
      {
            "full_name": "Louis Cossart",
            "first_name": "Louis",
            "last_name": "Cossart"
      },
      {
            "full_name": "Amaury Obadia",
            "first_name": "Amaury",
            "last_name": "Obadia"
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
  'funding_deals_june_2026',
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
            "org_name": "Alan",
            "founder_name": "Jean-Charles Samuelian-Werve"
      },
      {
            "org_name": "Alan",
            "founder_name": "Charles Gorintin"
      },
      {
            "org_name": "Bionyra Pharma",
            "founder_name": "Fr\u00e9d\u00e9ric Marrache"
      },
      {
            "org_name": "TISSIUM",
            "founder_name": "Christophe Bancel"
      },
      {
            "org_name": "TISSIUM",
            "founder_name": "Maria Pereira"
      },
      {
            "org_name": "Tsuga",
            "founder_name": "Gabriel-James Safar"
      },
      {
            "org_name": "AlpSemi",
            "founder_name": "Fr\u00e9d\u00e9ric Dupont"
      },
      {
            "org_name": "AlpSemi",
            "founder_name": "Fabrice Letertre"
      },
      {
            "org_name": "Flease",
            "founder_name": "Constantin Eliard"
      },
      {
            "org_name": "Flease",
            "founder_name": "Vincent Dreyfus"
      },
      {
            "org_name": "Wheere",
            "founder_name": "Pierre-Arnaud Coquelin"
      },
      {
            "org_name": "Wheere",
            "founder_name": "Antoine Carrabin"
      },
      {
            "org_name": "Linc",
            "founder_name": "Baptiste Le Bihan"
      },
      {
            "org_name": "Linc",
            "founder_name": "F\u00e9lix Wattez"
      },
      {
            "org_name": "Linc",
            "founder_name": "Thomas de Priestere"
      },
      {
            "org_name": "Sopht",
            "founder_name": "Julien Rouz\u00e9"
      },
      {
            "org_name": "Sopht",
            "founder_name": "J\u00e9r\u00e9mie Veg"
      },
      {
            "org_name": "Blyyd",
            "founder_name": "Damien Gambey"
      },
      {
            "org_name": "Cardiawave",
            "founder_name": "Micka\u00ebl Tanter"
      },
      {
            "org_name": "Cardiawave",
            "founder_name": "Mathieu Pernot"
      },
      {
            "org_name": "Cardiawave",
            "founder_name": "Emmanuel Messas"
      },
      {
            "org_name": "Macrodata Labs",
            "founder_name": "Guilherme Penedo"
      },
      {
            "org_name": "Macrodata Labs",
            "founder_name": "Hynek Kydl\u00ed\u010dek"
      },
      {
            "org_name": "Haiku",
            "founder_name": "Jules Touzet"
      },
      {
            "org_name": "Haiku",
            "founder_name": "Jorick Nuss"
      },
      {
            "org_name": "Haiku",
            "founder_name": "Jean Marcel Touzet"
      },
      {
            "org_name": "Concord",
            "founder_name": "Nathan Venezia"
      },
      {
            "org_name": "Concord",
            "founder_name": "Nicolas Cosson"
      },
      {
            "org_name": "Concord",
            "founder_name": "Antoine Chwalek"
      },
      {
            "org_name": "Beams",
            "founder_name": "Virginie Simon"
      },
      {
            "org_name": "Beams",
            "founder_name": "Estelle Villedieu de Torcy"
      },
      {
            "org_name": "Beams",
            "founder_name": "St\u00e9phane Palfi"
      },
      {
            "org_name": "Beams",
            "founder_name": "Laurent M\u00e9nard"
      },
      {
            "org_name": "Cilcare",
            "founder_name": "Celia Belline"
      },
      {
            "org_name": "Cilcare",
            "founder_name": "Sophie Gaboyard-Niay"
      },
      {
            "org_name": "Fascent",
            "founder_name": "Fanny Descamps"
      },
      {
            "org_name": "Fascent",
            "founder_name": "Edwina R\u00e9thor\u00e9"
      },
      {
            "org_name": "MNGRS.AI",
            "founder_name": "Alexandre Deniot"
      },
      {
            "org_name": "MNGRS.AI",
            "founder_name": "Thomas Quenoil"
      },
      {
            "org_name": "Comand AI",
            "founder_name": "Lo\u00efc Mougeolle"
      },
      {
            "org_name": "Comand AI",
            "founder_name": "Antoine Chassan"
      },
      {
            "org_name": "Prophesee",
            "founder_name": "Luca Verre"
      },
      {
            "org_name": "Prophesee",
            "founder_name": "Christoph Posch"
      },
      {
            "org_name": "Prophesee",
            "founder_name": "Ryad Benosman"
      },
      {
            "org_name": "Rocapine",
            "founder_name": "Stanislas Marchand"
      },
      {
            "org_name": "Rocapine",
            "founder_name": "Jean-Gabriel Boinot-Tramoni"
      },
      {
            "org_name": "Rocapine",
            "founder_name": "Sammy Teillet"
      },
      {
            "org_name": "Green-Got",
            "founder_name": "Maud Caillaux"
      },
      {
            "org_name": "Green-Got",
            "founder_name": "Andr\u00e9a Ganovelli"
      },
      {
            "org_name": "Green-Got",
            "founder_name": "Fabien Huet"
      },
      {
            "org_name": "CardNexus",
            "founder_name": "Tristan Foureur"
      },
      {
            "org_name": "Osmos X",
            "founder_name": "Matthieu Cavellier"
      },
      {
            "org_name": "NotiPark",
            "founder_name": "Jeremy Skowronek"
      },
      {
            "org_name": "Eledone",
            "founder_name": "Bruno Heckel"
      },
      {
            "org_name": "Eledone",
            "founder_name": "Arno Heckel"
      },
      {
            "org_name": "Eledone",
            "founder_name": "Erwan Boullier"
      },
      {
            "org_name": "Aiffin",
            "founder_name": "Sergii Vaskov"
      },
      {
            "org_name": "Aiffin",
            "founder_name": "Khalil Aram"
      },
      {
            "org_name": "Dawex",
            "founder_name": "Laure Lucchesi"
      },
      {
            "org_name": "Dawex",
            "founder_name": "Fabrice Tocco"
      },
      {
            "org_name": "Cyclair",
            "founder_name": "Quentin Guillemot"
      },
      {
            "org_name": "Cyclair",
            "founder_name": "Sebastien Gorry"
      },
      {
            "org_name": "Cyclair",
            "founder_name": "Camille Auger"
      },
      {
            "org_name": "Dry4Good",
            "founder_name": "Jean-Gabriel Dijoud"
      },
      {
            "org_name": "Dry4Good",
            "founder_name": "Romaric Janssen"
      },
      {
            "org_name": "Ellona",
            "founder_name": "Abdelwahed Lahmar"
      },
      {
            "org_name": "Ellona",
            "founder_name": "R\u00e9mi El-Ouazzane"
      },
      {
            "org_name": "Ellona",
            "founder_name": "Abdelilah Lahmar"
      },
      {
            "org_name": "Morpho Labs",
            "founder_name": "Paul Frambot"
      },
      {
            "org_name": "Alta Ares",
            "founder_name": "Stanislas Walch"
      },
      {
            "org_name": "Alta Ares",
            "founder_name": "Th\u00e9o Bondarec"
      },
      {
            "org_name": "Alta Ares",
            "founder_name": "Hadrien Bernard"
      },
      {
            "org_name": "Alta Ares",
            "founder_name": "Alain Henry"
      },
      {
            "org_name": "Alta Ares",
            "founder_name": "Hadrien Canter"
      },
      {
            "org_name": "Eclipse",
            "founder_name": "Augustin Derville"
      },
      {
            "org_name": "Mendo",
            "founder_name": "Quentin Amaudry"
      },
      {
            "org_name": "Mendo",
            "founder_name": "Alexandre Pinon"
      },
      {
            "org_name": "Finovox",
            "founder_name": "Marc de Beaucorps"
      },
      {
            "org_name": "Finovox",
            "founder_name": "Th\u00e9ophile du Portal"
      },
      {
            "org_name": "Finovox",
            "founder_name": "Pierre-Alexis Gouzien"
      },
      {
            "org_name": "Kyber",
            "founder_name": "Jean-Baptiste Kempf"
      },
      {
            "org_name": "Seacure",
            "founder_name": "Christophe Souillart"
      },
      {
            "org_name": "Rematch",
            "founder_name": "Pierre Husson"
      },
      {
            "org_name": "Rematch",
            "founder_name": "Franck-Si Hassen"
      },
      {
            "org_name": "Rematch",
            "founder_name": "Fran\u00e7ois Alary"
      },
      {
            "org_name": "Builder Assist",
            "founder_name": "Alban Brisy"
      },
      {
            "org_name": "Mobioos",
            "founder_name": "Zaak Chalal"
      },
      {
            "org_name": "Hit Mag",
            "founder_name": "Arnault Trac"
      },
      {
            "org_name": "R\u00e9empro",
            "founder_name": "Jean-Baptiste Duran"
      },
      {
            "org_name": "R\u00e9empro",
            "founder_name": "Adrien Verlinde"
      },
      {
            "org_name": "TheraPPI Bioscience",
            "founder_name": "Luc Otten"
      },
      {
            "org_name": "TheraPPI Bioscience",
            "founder_name": "Toufic Renno"
      },
      {
            "org_name": "TheraPPI Bioscience",
            "founder_name": "Isabelle Coste"
      },
      {
            "org_name": "TheraPPI Bioscience",
            "founder_name": "St\u00e9phane Giraud"
      },
      {
            "org_name": "Quobly",
            "founder_name": "Maud Vinet"
      },
      {
            "org_name": "Quobly",
            "founder_name": "Laurent Schmid"
      },
      {
            "org_name": "Quobly",
            "founder_name": "Philippe Campana"
      },
      {
            "org_name": "Innovafeed",
            "founder_name": "Aude Guo"
      },
      {
            "org_name": "Innovafeed",
            "founder_name": "Bastien Oggeri"
      },
      {
            "org_name": "Innovafeed",
            "founder_name": "Cl\u00e9ment Ray"
      },
      {
            "org_name": "Innovorder",
            "founder_name": "J\u00e9r\u00f4me Varnier"
      },
      {
            "org_name": "Innovorder",
            "founder_name": "Romain Melloul"
      },
      {
            "org_name": "Innovorder",
            "founder_name": "Olivier Loverde"
      },
      {
            "org_name": "NP Co.",
            "founder_name": "Emmanuel Menier"
      },
      {
            "org_name": "NP Co.",
            "founder_name": "Matthieu Nastorg"
      },
      {
            "org_name": "noa",
            "founder_name": "Guillaume Sztejnberg"
      },
      {
            "org_name": "noa",
            "founder_name": "Shreyas Rajagopalan"
      },
      {
            "org_name": "noa",
            "founder_name": "Jason Akakpo"
      },
      {
            "org_name": "Upstream",
            "founder_name": "Louis Lecat"
      },
      {
            "org_name": "Upstream",
            "founder_name": "Jonathan Tiret"
      },
      {
            "org_name": "Drotek",
            "founder_name": "J\u00e9r\u00f4me Perin"
      },
      {
            "org_name": "Primomanda",
            "founder_name": "Benjamin Leiba"
      },
      {
            "org_name": "Primomanda",
            "founder_name": "Benjamin Mechaly"
      },
      {
            "org_name": "Tiva",
            "founder_name": "Louis Cossart"
      },
      {
            "org_name": "Tiva",
            "founder_name": "Amaury Obadia"
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
            "org": "alan",
            "siren": "818353070"
      },
      {
            "org": "bionyra-pharma",
            "siren": "990995334"
      },
      {
            "org": "tissium",
            "siren": "793166299"
      },
      {
            "org": "tsuga",
            "siren": "985331073"
      },
      {
            "org": "alpsemi",
            "siren": "984935965"
      },
      {
            "org": "flease",
            "siren": "834902314"
      },
      {
            "org": "wheere",
            "siren": "890768344"
      },
      {
            "org": "linc",
            "siren": "928067941"
      },
      {
            "org": "sopht",
            "siren": "908543580"
      },
      {
            "org": "cardiawave",
            "siren": "805240108"
      },
      {
            "org": "macrodata-labs",
            "siren": "103760575"
      },
      {
            "org": "haiku",
            "siren": "981575947"
      },
      {
            "org": "concord",
            "siren": "988513875"
      },
      {
            "org": "beams",
            "siren": "899384135"
      },
      {
            "org": "cilcare",
            "siren": "803146125"
      },
      {
            "org": "fascent",
            "siren": "953759289"
      },
      {
            "org": "mngrsai",
            "siren": "921180402"
      },
      {
            "org": "comand-ai",
            "siren": "951510627"
      },
      {
            "org": "prophesee",
            "siren": "800681892"
      },
      {
            "org": "rocapine",
            "siren": "929934503"
      },
      {
            "org": "green-got",
            "siren": "883981763"
      },
      {
            "org": "cardnexus",
            "siren": "937817674"
      },
      {
            "org": "osmos-x",
            "siren": "922472543"
      },
      {
            "org": "notipark",
            "siren": "984911495"
      },
      {
            "org": "eledone",
            "siren": "929846400"
      },
      {
            "org": "aiffin",
            "siren": "990647711"
      },
      {
            "org": "dawex",
            "siren": "810307207"
      },
      {
            "org": "cyclair",
            "siren": "880131800"
      },
      {
            "org": "dry4good",
            "siren": "851016329"
      },
      {
            "org": "ellona",
            "siren": "817658909"
      },
      {
            "org": "morpho-labs",
            "siren": "902498492"
      },
      {
            "org": "alta-ares",
            "siren": "983352451"
      },
      {
            "org": "eclipse",
            "siren": "981729635"
      },
      {
            "org": "mendo",
            "siren": "901452177"
      },
      {
            "org": "finovox",
            "siren": "878381961"
      },
      {
            "org": "kyber",
            "siren": "909894768"
      },
      {
            "org": "seacure",
            "siren": "539529669"
      },
      {
            "org": "rematch",
            "siren": "832876585"
      },
      {
            "org": "builder-assist",
            "siren": "945059079"
      },
      {
            "org": "mobioos",
            "siren": "990692295"
      },
      {
            "org": "hit-mag",
            "siren": "989157953"
      },
      {
            "org": "reempro",
            "siren": "914180682"
      },
      {
            "org": "therappi-bioscience",
            "siren": "947964219"
      },
      {
            "org": "quobly",
            "siren": "921773792"
      },
      {
            "org": "innovafeed",
            "siren": "819671843"
      },
      {
            "org": "innovorder",
            "siren": "804818482"
      },
      {
            "org": "np-co",
            "siren": "953351962"
      },
      {
            "org": "noa",
            "siren": "942968934"
      },
      {
            "org": "upstream",
            "siren": "978437069"
      },
      {
            "org": "drotek",
            "siren": "539120667"
      },
      {
            "org": "primomanda",
            "siren": "978738227"
      },
      {
            "org": "tiva",
            "siren": "921143350"
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
FROM funding_rounds WHERE source_name = 'funding_deals_june_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_june_2026'
UNION ALL
SELECT 'Founder Links (new people)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_june_2026';
