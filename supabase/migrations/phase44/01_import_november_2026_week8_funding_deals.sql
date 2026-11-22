-- =============================================================================
-- November 2026 Funding Deals Import — Week 8 (11 deals, announced Nov 2–19 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week8'. Amounts in millions, EUR.
-- All 10 new SIRENs verified against the French business registry (Pappers).
--
-- New orgs (7): Stryx AI, MountAIn, Stimuli Technology, Qluster, Previsia,
-- Revio, Kosme. Existing orgs with a new round (3): Genesis AI, HoloSolis,
-- Speeral. Mistral AI: NO new round (see below).
--
-- Special cases:
--   * Mistral AI: T.Capital Tech Fund (Deutsche Telekom) invested €100M INSIDE
--     the €3B Series D announced Sept 2026 (round already in DB, 2026-09-08).
--     It is added as an investor on that existing round and the round's notes
--     are extended — no new round, so the €100M is not double-counted.
--   * Genesis AI: $500M Series A recorded as €450M (figure supplied by the
--     editor; at the 0.86 rate used elsewhere it would be ~€430M),
--     is_estimated TRUE. Co-leads Premji Invest, Khosla Ventures, Eclipse.
--   * HoloSolis: founders are corporates (EIT InnoEnergy, Groupe IDEC, TSE),
--     noted in the round notes rather than as people.
--   * Speeral: its existing legal entity carried a wrong SIREN (482439650);
--     corrected to the verified 930872064 (legal name SPIRAL, trade name Speeral).
--   * Investor mapping onto existing records: Eclipse -> eclipse-ventures,
--     Crédit Agricole -> credit-agricole, ARIS -> aris-occitanie (Toulouse),
--     Aquiti Ventures -> aquiti.
--   * Sectors not in the taxonomy were not created: Computer Vision
--     (MountAIn), RetailTech (Speeral -> E-commerce & Retail), Recruitment,
--     Career Management, Enterprise Software (Kosme).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Stryx AI","slug":"stryx-ai","website":"https://www.stryx.ai/","description":"Develops integrated systems for detecting, tracking, and intercepting hostile drones, including low-cost FPV drones and fiber-optic-guided aircraft resistant to electronic jamming. Its platform combines STRYX Watch detection radar, STRYX C2 command-and-control software, STRYX Impact AI-guided interceptors, and STRYX Launch deployment systems. Human operators retain authority over engagement decisions."},
  {"name":"MountAIn","slug":"mountain","website":"https://www.mountainedge.ai/","description":"Develops MountainCore, a software platform that enables sophisticated computer vision AI applications to run directly on inexpensive, ultra-low-power microcontrollers. Its technology automatically adapts AI models and supporting software to resource-constrained chips, reducing cloud dependence, power consumption, and deployment complexity. The company also develops IBEX, an autonomous vision sensor for remote monitoring applications."},
  {"name":"Stimuli Technology","slug":"stimuli-technology","website":"https://www.tensiplus.com/","description":"Develops Tensi+, a wearable, non-invasive neurostimulation device for treating symptoms of overactive bladder. Worn around the ankle, the device uses transcutaneous electrical stimulation of the posterior tibial nerve to help regulate bladder control. Manufactured in France, Tensi+ is a CE-marked Class IIa medical device that patients can use independently at home."},
  {"name":"Qluster","slug":"qluster","website":"https://qluster.co/","description":"Develops photonic quantum computers using continuous-variable quantum computing technology and an \"Architecture First\" approach that designs computing systems around industrial applications rather than individual qubit performance. Spun out of the Laboratoire Kastler Brossel, the startup is developing scalable, room-temperature quantum computing architectures based on light and optical entanglement, with the long-term goal of building fault-tolerant machines that can solve complex industrial problems."},
  {"name":"Previsia","slug":"previsia","website":"https://previsia.eu/","description":"Develops an AI-powered risk assessment and prevention platform for insurers, brokers, and businesses. Its software digitizes property and industrial risk inspections, generates reports and action plans, maps environmental hazards, and helps insurers analyze risk across commercial property portfolios."},
  {"name":"Revio","slug":"revio","website":"https://www.gorevio.co/","description":"Develops an AI-powered software platform for managing corporate vehicle fleets. Its system centralizes information on vehicles, leasing contracts, drivers, maintenance, and operating expenses, while AI agents automate administrative tasks and help fleet managers reduce costs, improve vehicle utilization, and plan electrification."},
  {"name":"Kosme","slug":"kosme","website":"https://kosme.io/","description":"Develops a digital career guidance and recruitment platform for healthcare professionals. Its software combines healthcare job opportunities, geographic and regulatory data, local financial incentives, personalized career recommendations, and an AI assistant with human career advisers. The platform helps medical professionals choose where and how to practice while supporting recruitment by hospitals, clinics, care facilities, and local authorities."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week8', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1a: fill gaps on existing orgs (never overwrite)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"genesis-ai","website":"https://genesis.ai/","description":"Develops general-purpose robots capable of performing complex physical tasks across industrial environments. Its vertically integrated platform combines GENE, a robotics foundation model; Genesis World, a physics-based simulation platform; a robotic hand designed for human-like dexterity; and Eno, its flagship autonomous robot. Genesis trains its AI using human movement and tactile data collected through sensor-equipped gloves, combining real-world demonstrations with simulation to improve robotic manipulation and reliability."},
  {"slug":"holosolis","website":"https://holosolis.com/","description":"Developing a large-scale European manufacturing facility for photovoltaic cells and solar panels. Its planned gigafactory in Hambach, Moselle, will use TOPCon solar technology and target an annual production capacity of 5 GW, equivalent to approximately 10 million solar panels."},
  {"slug":"speeral","website":"https://speeral.io/","description":"Develops an AI-powered platform that helps retailers resell dormant inventory, including customer returns, display models, and unsold products, through second-hand marketplaces such as Leboncoin, Vinted, and eBay. Its software automates product listings, pricing, buyer negotiations, reservations, and shipping, allowing retailers to recover value from unsold inventory without adding work for store employees."},
  {"slug":"mistral-ai","website":"https://mistral.ai/","description":"Develops frontier and open-weight AI models, enterprise AI software, and infrastructure allowing organizations to customize, deploy, and operate AI systems in cloud, private, and sovereign computing environments."}
]$json$) AS (slug TEXT, website TEXT, description TEXT))
UPDATE organizations o SET website=COALESCE(NULLIF(o.website,''), s.website), description=COALESCE(NULLIF(o.description,''), s.description), updated_at=NOW()
FROM source s WHERE o.slug=s.slug;

-- Step 1b: city links (COALESCE keeps any existing value)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"stryx-ai","city":"paris"},{"slug":"mountain","city":"meylan"},{"slug":"stimuli-technology","city":"boulogne-billancourt"},
  {"slug":"qluster","city":"paris"},{"slug":"previsia","city":"toulouse"},{"slug":"revio","city":"paris"},{"slug":"kosme","city":"rennes"},
  {"slug":"holosolis","city":"paris"},{"slug":"speeral","city":"nantes"}
]$json$) AS (slug TEXT, city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM source s JOIN cities c ON c.slug=s.city WHERE o.slug=s.slug;

-- Step 2: funding rounds (10; Mistral handled in Step 3c)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"genesis-ai","stage":"series_a","amount_eur":450.0,"currency_original":"USD","amount_original":500000000,"announced_date":"2026-11-17","notes":"$500M Series A co-led by Premji Invest, Khosla Ventures and Eclipse at a $3.5B post-money valuation. Funds production and commercial deployment of Eno, its general-purpose robot for complex industrial tasks requiring human-like dexterity; large-scale AI training; manufacturing expansion; hiring across AI research, robotics and engineering. Full stack built in-house (hardware, GENE foundation model, Genesis World simulation, sensor-glove data capture). Initial markets: manufacturing, logistics, laboratories; later healthcare, hospitality, consumer. ~30–40 Eno robots produced; pilots with a few undisclosed customers (company-reported). EUR figure €450M as supplied. Investors: Premji Invest, Khosla Ventures, Eclipse, Durable Capital Partners, Bpifrance, HSG, NVIDIA, AMD Ventures, Zoom, Samsung Next, Business Angels, Eric Schmidt, Eric Yuan, Jerry Yang, Xavier Niel, Zach Kirkhorn. Source: Genesis AI (PR Newswire), TechCrunch."},
  {"slug":"holosolis","stage":"series_a","amount_eur":15.0,"currency_original":"EUR","amount_original":15000000,"announced_date":"2026-11-16","notes":"Series A of more than €15M bringing four new investors into the capital. Funds engineering studies, technical specifications, supplier selection and prototype qualification ahead of construction of its 5 GW TOPCon solar cell and module gigafactory in Hambach (Moselle), ~2,000 jobs at full capacity. Reports >30 GW of customer letters of intent; preparing another raise to finance construction. Corporate founders: EIT InnoEnergy, Groupe IDEC, TSE. Investors: Crédit Agricole, Calès Technologies, Forming, Ecolab. Source: HoloSolis, pv magazine."},
  {"slug":"stryx-ai","stage":"seed","amount_eur":7.7,"currency_original":"EUR","amount_original":7700000,"announced_date":"2026-11-19","notes":"€7.7M seed (first announced round) co-led by founder Armand Thiberge and Impala to industrialize its counter-drone systems (detection radar, C2 software, AI-guided interceptors, launchers) targeting FPV drones incl. fiber-optic-guided models immune to RF jamming. Selected for the Defense Innovation Agency's EPERVIER program; prototypes intercepted drones at the Sept 2026 XLAD exercise; initial order from French authorities (company-reported). Production line in France early 2027; ~30 hires to reach ~50 staff by end-2027; commercial deliveries 2027. Investors: Armand Thiberge, Impala, Michaël de Lagarde, Benjamin Benharrosh, Business Angels. Source: FrenchWeb, Startup.eu."},
  {"slug":"mountain","stage":"seed","amount_eur":7.3,"currency_original":"EUR","amount_original":7300000,"announced_date":"2026-11-17","notes":"€7.3M seed from 360 Capital, Supernova Invest and Crédit Agricole Alpes Développement, with Bpifrance support, to commercialize MountainCore, which runs complete computer-vision applications on microcontrollers costing under $10. Claims up to 3x lower model memory and deployment cut from months to hours (company-reported). Works with Teledyne e2v; partnerships with Roboflow and Alif Semiconductor. Funds engineering in Grenoble and commercial operations in Europe and Silicon Valley. Source: MountAIn (GlobeNewswire), FrenchWeb."},
  {"slug":"stimuli-technology","stage":"growth","amount_eur":7.0,"currency_original":"EUR","amount_original":7000000,"announced_date":"2026-11-02","notes":"€7M bringing Seventure Partners into the shareholder base to accelerate international expansion of Tensi+, its non-invasive ankle-worn neurostimulation treatment for overactive bladder. Reimbursed by French national health insurance since 2021; CE-marked (MDR); >50,000 units sold over five years (company-reported); ISO 13485:2016 and MDSAP certified. Funds commercial operations in France, growth in Europe and North America, clinical studies and product development. Founded 2018 by Technofounders. Investors: Seventure Partners. Source: Stimuli Technology / Seventure."},
  {"slug":"qluster","stage":"pre_seed","amount_eur":4.7,"currency_original":"EUR","amount_original":4700000,"announced_date":"2026-11-17","notes":"€4.7M pre-seed led by Quantonation with Quantum Launchpad and Bpifrance to set up its own R&D lab and expand its scientific team. Laboratoire Kastler Brossel spinout combining continuous-variable photonic quantum computing with an architecture designed around industrial requirements; builds on a patented miniature photonic source by co-founders Valentina Parigi and David Fainsin. Targets an intermediate quantum computer by 2032 and a universal fault-tolerant system by 2036 — R&D targets, not demonstrated capabilities. Source: Gide, Tech.eu."},
  {"slug":"previsia","stage":"seed","amount_eur":3.8,"currency_original":"EUR","amount_original":3800000,"announced_date":"2026-11-17","notes":"€3.8M seed from IRDI and ARIS to expand its AI-powered commercial-property risk prevention platform (automated questionnaires, photos, risk scoring, insurer-ready reports, human validation). Works with Groupama, Diot-Siaci, Verspieren, MSIG Europe and Helvetia. Says it became profitable in 2025 and grew revenue 2.5x in a year (company-reported). Funds an app for insured businesses, European natural-hazard analysis, sales and international growth. ~15 staff; office in Hamburg. Source: Tech Funding News."},
  {"slug":"speeral","stage":"seed","amount_eur":2.5,"currency_original":"EUR","amount_original":2500000,"announced_date":"2026-11-17","notes":"€2.5M seed from five investors to expand its AI platform automating the resale of retailers' dormant inventory (returns, unsold and display products) on Leboncoin, Vinted and eBay. Deployed in >250 stores in France incl. Boulanger, BigMat and BUT; targets 5x more stores within a year. Launching a Buy-Back service (store credit for second-hand products). ~12 staff, 10 hires planned. Legal entity SPIRAL. Investors: Kima Ventures, Sonorcap, Aquiti Ventures, Atlantique Vendée Investissement, Pays de la Loire Participations. Source: Speeral, Fusacq."},
  {"slug":"revio","stage":"seed","amount_eur":2.5,"currency_original":"EUR","amount_original":2500000,"announced_date":"2026-11-16","notes":"€2.5M seed led by ISAI with Kima Ventures and business angels for its AI-powered corporate fleet-management platform (connected vehicle data, leases, maintenance, AI agents automating admin tasks). Manages ~5,000 vehicles for ~50 business customers incl. Dashdoc, Exquado, Portalp and Otimo; targets 15,000 connected vehicles by end-2027. Claimed savings of up to 25% on total fleet cost are company projections. Registered office Colombes. Investors: ISAI, Kima Ventures. Source: J'aime les Startups."},
  {"slug":"kosme","stage":"pre_seed","amount_eur":1.1,"currency_original":"EUR","amount_original":1100000,"announced_date":"2026-11-17","notes":"€1.1M pre-seed from MBA Mutuelle and entrepreneur Alban Boyé, with Bpifrance, for its career-guidance and recruitment platform for healthcare professionals (job listings, regional healthcare needs, installation incentives, personalized recommendations, human advisers). Beta being tested by practitioners; free iOS/Android app planned early 2027. Founded by former Office Santé entrepreneur Stéphane Guivarc'h and two partners. Investors: MBA Mutuelle, Alban Boyé, Bpifrance. Source: Bretagne Économique, Le Journal des Entreprises."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  s.currency_original <> 'EUR', FALSE, 'funding_deals_november_2026_week8', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week8');

-- Step 3a: new investor organizations (explicit slugs)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Durable Capital Partners","slug":"durable-capital-partners","country":"United States"},
  {"name":"AMD Ventures","slug":"amd-ventures","country":"United States"},
  {"name":"Zoom","slug":"zoom","country":"United States"},
  {"name":"Eric Yuan","slug":"eric-yuan","country":"United States"},
  {"name":"Jerry Yang","slug":"jerry-yang","country":"United States"},
  {"name":"Zach Kirkhorn","slug":"zach-kirkhorn","country":"United States"},
  {"name":"Calès Technologies","slug":"cales-technologies","country":"France"},
  {"name":"Forming","slug":"forming","country":"France"},
  {"name":"Ecolab","slug":"ecolab","country":"France"},
  {"name":"T.Capital Tech Fund","slug":"t-capital-tech-fund","country":"Germany"},
  {"name":"Armand Thiberge","slug":"armand-thiberge","country":"France"},
  {"name":"Michaël de Lagarde","slug":"michael-de-lagarde","country":"France"},
  {"name":"Benjamin Benharrosh","slug":"benjamin-benharrosh","country":"France"},
  {"name":"Quantum Launchpad","slug":"quantum-launchpad","country":"France"},
  {"name":"Atlantique Vendée Investissement","slug":"atlantique-vendee-investissement","country":"France"},
  {"name":"Alban Boyé","slug":"alban-boye","country":"France"}
]$json$) AS (name TEXT, slug TEXT, country TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'investor'::organization_type, 'active'::organization_status, s.country, 'funding_deals_november_2026_week8', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: investor links on this batch's rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"o":"genesis-ai","i":"premji-invest","n":"Premji Invest","l":true},{"o":"genesis-ai","i":"khosla-ventures","n":"Khosla Ventures","l":true},{"o":"genesis-ai","i":"eclipse-ventures","n":"Eclipse","l":true},
  {"o":"genesis-ai","i":"durable-capital-partners","n":"Durable Capital Partners","l":false},{"o":"genesis-ai","i":"bpifrance","n":"Bpifrance","l":false},{"o":"genesis-ai","i":"hsg","n":"HSG","l":false},
  {"o":"genesis-ai","i":"nvidia","n":"NVIDIA","l":false},{"o":"genesis-ai","i":"amd-ventures","n":"AMD Ventures","l":false},{"o":"genesis-ai","i":"zoom","n":"Zoom","l":false},
  {"o":"genesis-ai","i":"samsung-next","n":"Samsung Next","l":false},{"o":"genesis-ai","i":"business-angels","n":"Business Angels","l":false},{"o":"genesis-ai","i":"eric-schmidt","n":"Eric Schmidt","l":false},
  {"o":"genesis-ai","i":"eric-yuan","n":"Eric Yuan","l":false},{"o":"genesis-ai","i":"jerry-yang","n":"Jerry Yang","l":false},{"o":"genesis-ai","i":"xavier-niel","n":"Xavier Niel","l":false},{"o":"genesis-ai","i":"zach-kirkhorn","n":"Zach Kirkhorn","l":false},
  {"o":"holosolis","i":"credit-agricole","n":"Crédit Agricole","l":false},{"o":"holosolis","i":"cales-technologies","n":"Calès Technologies","l":false},{"o":"holosolis","i":"forming","n":"Forming","l":false},{"o":"holosolis","i":"ecolab","n":"Ecolab","l":false},
  {"o":"stryx-ai","i":"armand-thiberge","n":"Armand Thiberge","l":true},{"o":"stryx-ai","i":"impala","n":"Impala","l":true},{"o":"stryx-ai","i":"michael-de-lagarde","n":"Michaël de Lagarde","l":false},{"o":"stryx-ai","i":"benjamin-benharrosh","n":"Benjamin Benharrosh","l":false},{"o":"stryx-ai","i":"business-angels","n":"Business Angels","l":false},
  {"o":"mountain","i":"360-capital","n":"360 Capital","l":false},{"o":"mountain","i":"supernova-invest","n":"Supernova Invest","l":false},{"o":"mountain","i":"credit-agricole-alpes-developpement","n":"Crédit Agricole Alpes Développement","l":false},{"o":"mountain","i":"bpifrance","n":"Bpifrance","l":false},
  {"o":"stimuli-technology","i":"seventure-partners","n":"Seventure Partners","l":true},
  {"o":"qluster","i":"quantonation","n":"Quantonation","l":true},{"o":"qluster","i":"quantum-launchpad","n":"Quantum Launchpad","l":false},{"o":"qluster","i":"bpifrance","n":"Bpifrance","l":false},
  {"o":"previsia","i":"irdi","n":"IRDI","l":false},{"o":"previsia","i":"aris-occitanie","n":"ARIS","l":false},
  {"o":"speeral","i":"kima-ventures","n":"Kima Ventures","l":false},{"o":"speeral","i":"sonorcap","n":"Sonorcap","l":false},{"o":"speeral","i":"aquiti","n":"Aquiti Ventures","l":false},{"o":"speeral","i":"atlantique-vendee-investissement","n":"Atlantique Vendée Investissement","l":false},{"o":"speeral","i":"pays-de-la-loire-participations","n":"Pays de la Loire Participations","l":false},
  {"o":"revio","i":"isai","n":"ISAI","l":true},{"o":"revio","i":"kima-ventures","n":"Kima Ventures","l":false},
  {"o":"kosme","i":"mba-mutuelle","n":"MBA Mutuelle","l":false},{"o":"kosme","i":"alban-boye","n":"Alban Boyé","l":false},{"o":"kosme","i":"bpifrance","n":"Bpifrance","l":false}
]$json$) AS (o TEXT, i TEXT, n TEXT, l BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.l, s.n, NOW()
FROM source s
JOIN organizations o ON o.slug=s.o
JOIN organizations inv ON inv.slug=s.i
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week8'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 3c: Mistral AI — add T.Capital Tech Fund to the EXISTING €3B Series D
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, FALSE, 'T.Capital Tech Fund', NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id
JOIN organizations inv ON inv.slug='t-capital-tech-fund'
WHERE o.slug='mistral-ai' AND fr.stage='series_d' AND fr.announced_date='2026-09-08'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

UPDATE funding_rounds fr SET notes = COALESCE(fr.notes || ' ', '') || 'Update 2026-11-19: Deutsche Telekom disclosed that its strategic investment arm T.Capital Tech Fund invested €100M in this €3B Series D (part of the round, not additional money), laying the groundwork for a planned partnership to deliver European AI solutions to German industrial companies and public institutions (builds on Mistral''s Munich hub and Deutsche Telekom''s sovereign AI infrastructure). Source: Deutsche Telekom.'
FROM organizations o
WHERE o.id=fr.organization_id AND o.slug='mistral-ai' AND fr.stage='series_d' AND fr.announced_date='2026-09-08'
  AND coalesce(fr.notes,'') NOT LIKE '%T.Capital Tech Fund invested%';

-- Step 4a: sector links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"o":"genesis-ai","s":"artificial-intelligence"},{"o":"genesis-ai","s":"robotics"},{"o":"genesis-ai","s":"deeptech"},
  {"o":"holosolis","s":"climatetech"},{"o":"holosolis","s":"deeptech"},
  {"o":"stryx-ai","s":"defensetech"},{"o":"stryx-ai","s":"artificial-intelligence"},{"o":"stryx-ai","s":"drones"},{"o":"stryx-ai","s":"robotics"},
  {"o":"mountain","s":"artificial-intelligence"},{"o":"mountain","s":"deeptech"},
  {"o":"stimuli-technology","s":"medtech"},{"o":"stimuli-technology","s":"healthtech"},
  {"o":"qluster","s":"quantum-computing"},{"o":"qluster","s":"deeptech"},
  {"o":"previsia","s":"insurtech"},{"o":"previsia","s":"artificial-intelligence"},{"o":"previsia","s":"saas"},
  {"o":"speeral","s":"e-commerce-retail"},{"o":"speeral","s":"artificial-intelligence"},{"o":"speeral","s":"saas"},
  {"o":"revio","s":"mobility"},{"o":"revio","s":"artificial-intelligence"},{"o":"revio","s":"saas"},
  {"o":"kosme","s":"healthtech"},{"o":"kosme","s":"hrtech"},{"o":"kosme","s":"digital-health"},{"o":"kosme","s":"artificial-intelligence"}
]$json$) AS (o TEXT, s TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), org.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations org ON org.slug=s.o JOIN sectors sec ON sec.slug=s.s
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: primary sector where none exists
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"o":"stryx-ai","s":"defensetech"},{"o":"mountain","s":"artificial-intelligence"},{"o":"stimuli-technology","s":"medtech"},
  {"o":"qluster","s":"quantum-computing"},{"o":"previsia","s":"insurtech"},{"o":"revio","s":"mobility"},{"o":"kosme","s":"healthtech"}
]$json$) AS (o TEXT, s TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations org ON org.slug=s.o JOIN sectors sec ON sec.slug=s.s
WHERE os.organization_id=org.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=org.id AND x.is_primary=TRUE);

-- Step 5: people (existing slugs are reused: david-fainsin, julien-chevalier)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"f":"Zhou Xian","fn":"Xian","ln":"Zhou"},{"f":"Théophile Gervet","fn":"Théophile","ln":"Gervet"},
  {"f":"Armand Thiberge","fn":"Armand","ln":"Thiberge"},{"f":"Henri Jouhaud","fn":"Henri","ln":"Jouhaud"},{"f":"Pierre-Louis Blossier","fn":"Pierre-Louis","ln":"Blossier"},
  {"f":"Vincent Huard","fn":"Vincent","ln":"Huard"},{"f":"Olivier Montfort","fn":"Olivier","ln":"Montfort"},{"f":"David Nahmani","fn":"David","ln":"Nahmani"},
  {"f":"Delphine Agullo","fn":"Delphine","ln":"Agullo"},{"f":"Gaspard Moreau","fn":"Gaspard","ln":"Moreau"},
  {"f":"David Fainsin","fn":"David","ln":"Fainsin"},{"f":"Ambroise Boyer","fn":"Ambroise","ln":"Boyer"},{"f":"Clarisse Thibault","fn":"Clarisse","ln":"Thibault"},{"f":"Valentina Parigi","fn":"Valentina","ln":"Parigi"},
  {"f":"Hélie Brouchet","fn":"Hélie","ln":"Brouchet"},{"f":"David Salom","fn":"David","ln":"Salom"},
  {"f":"Julien Chevalier","fn":"Julien","ln":"Chevalier"},{"f":"Matthieu Charron","fn":"Matthieu","ln":"Charron"},
  {"f":"Adrien Prot","fn":"Adrien","ln":"Prot"},{"f":"Augustin Charpentier","fn":"Augustin","ln":"Charpentier"},{"f":"Victor Leibovici","fn":"Victor","ln":"Leibovici"},
  {"f":"Stéphane Guivarc'h","fn":"Stéphane","ln":"Guivarc'h"},{"f":"Chloé Houget","fn":"Chloé","ln":"Houget"},{"f":"Geoffrey Rasse","fn":"Geoffrey","ln":"Rasse"}
]$json$) AS (f TEXT, fn TEXT, ln TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.f, lower(regexp_replace(regexp_replace(unaccent(s.f), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.fn, s.ln, 'funding_deals_november_2026_week8', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"o":"genesis-ai","p":"zhou-xian"},{"o":"genesis-ai","p":"theophile-gervet"},
  {"o":"stryx-ai","p":"armand-thiberge"},{"o":"stryx-ai","p":"henri-jouhaud"},{"o":"stryx-ai","p":"pierre-louis-blossier"},
  {"o":"mountain","p":"vincent-huard"},{"o":"mountain","p":"olivier-montfort"},{"o":"mountain","p":"david-nahmani"},
  {"o":"stimuli-technology","p":"delphine-agullo"},{"o":"stimuli-technology","p":"gaspard-moreau"},
  {"o":"qluster","p":"david-fainsin"},{"o":"qluster","p":"ambroise-boyer"},{"o":"qluster","p":"clarisse-thibault"},{"o":"qluster","p":"valentina-parigi"},
  {"o":"previsia","p":"helie-brouchet"},{"o":"previsia","p":"david-salom"},
  {"o":"speeral","p":"julien-chevalier"},{"o":"speeral","p":"matthieu-charron"},
  {"o":"revio","p":"adrien-prot"},{"o":"revio","p":"augustin-charpentier"},{"o":"revio","p":"victor-leibovici"},
  {"o":"kosme","p":"stephane-guivarch"},{"o":"kosme","p":"chloe-houget"},{"o":"kosme","p":"geoffrey-rasse"}
]$json$) AS (o TEXT, p TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), org.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations org ON org.slug=s.o JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=org.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7a: correct Speeral's wrong SIREN (482439650 -> 930872064, legal name SPIRAL)
UPDATE legal_entities le SET siren='930872064', legal_name='SPIRAL', updated_at=NOW()
FROM organizations o
WHERE le.organization_id=o.id AND o.slug='speeral' AND le.siren='482439650'
  AND NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.siren='930872064');

-- Step 7b: SIREN legal entities (Genesis AI already holds its SIREN)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"o":"holosolis","ln":"HOLOSOLIS","s":"911980274"},
  {"o":"stryx-ai","ln":"STRYX AI","s":"945366284"},
  {"o":"mountain","ln":"MOUNTAIN","s":"989487434"},
  {"o":"stimuli-technology","ln":"STIMULI TECHNOLOGY","s":"835253618"},
  {"o":"qluster","ln":"QLUSTER","s":"106045701"},
  {"o":"previsia","ln":"PREVISIA","s":"980329189"},
  {"o":"speeral","ln":"SPIRAL","s":"930872064"},
  {"o":"revio","ln":"REVIO","s":"942585191"},
  {"o":"kosme","ln":"KOSME","s":"103481503"}
]$json$) AS (o TEXT, ln TEXT, s TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), org.id, s.ln, s.s, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=org.id), NOW(), NOW()
FROM source s JOIN organizations org ON org.slug=s.o
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=org.id AND le.siren=s.s);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week8'
UNION ALL SELECT 'Investor Links (batch rounds)', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week8'
UNION ALL SELECT 'Mistral Series D has T.Capital', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id JOIN organizations o ON o.id=fr.organization_id WHERE o.slug='mistral-ai' AND fr.stage='series_d' AND fri.investor_name='T.Capital Tech Fund'
UNION ALL SELECT 'New Orgs (startup)', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week8' AND organization_type='startup'
UNION ALL SELECT 'New Investors', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week8' AND organization_type='investor'
UNION ALL SELECT 'Founder Links (batch orgs)', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('genesis-ai','stryx-ai','mountain','stimuli-technology','qluster','previsia','speeral','revio','kosme') AND op.is_founder
UNION ALL SELECT 'Legal Entities (batch SIRENs)', COUNT(*) FROM legal_entities WHERE siren IN ('938912912','911980274','945366284','989487434','835253618','106045701','980329189','930872064','942585191','103481503')
UNION ALL SELECT 'Speeral old SIREN left', COUNT(*) FROM legal_entities WHERE siren='482439650';
