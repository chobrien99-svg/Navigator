-- =============================================================================
-- October 2026 Funding Deals Import (36 deals)
-- =============================================================================
-- source_name 'funding_deals_october_2026'. Amounts in millions.
-- 19 new organizations + 17 existing that each get a new, distinct round
-- (verified: none of their prior rounds match this batch's amount/date).
--
-- Rebrand handled in Step 0b: 'blossom-life-sciences' -> Rivercell (the company
--   was previously registered as Blossom Life Sciences; same SIREN 981215718).
--
-- Reference-by-existing-name (to hit the existing slug, avoid duplicate orgs):
--   Wiremind -> "WIREMIND SAS" (slug wiremind-sas).
--
-- Data-quality notes (flagged, left for a later cleanup):
--   * Edonia: its SIREN 949848907 already sits on a separate 'alt-g-protein'
--     record. The round is attached to the 'edonia' brand org; the SIREN is NOT
--     re-added here to avoid a duplicate-SIREN conflict.
--   * Archeon: two duplicate records exist ('archeon' and 'archeon-medical', both
--     SIREN 835009465). The round is attached to 'archeon-medical'.
--
-- Corrections / caveats per the source:
--   * Edonia: €15M total financing (SWEN notes €12M is equity; balance non-dilutive).
--   * Logbook and Fibraterre were publicly announced in September (dated accordingly);
--     included here in the October processing batch but not double-counted as October.
--   * Spiko $90M (=€77.4M), WhiteLab $26M, Rivercell $25M, Vocca $20M, Netsec $10M,
--     Archeon $9M, AlloBrain $7M, Verso $6M, Goodweek $12M -> amount_eur estimated.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- Step 0: cities (Manosque, Oissel, Chasselay, Verrières-en-Anjou, Milan are new)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Suresnes","country":"France"},{"name":"Lyon","country":"France"},{"name":"Paris","country":"France"},
  {"name":"Le Plessis-Pâté","country":"France"},{"name":"Strasbourg","country":"France"},{"name":"Nanterre","country":"France"},
  {"name":"Manosque","country":"France"},{"name":"Lille","country":"France"},{"name":"Saint-Fons","country":"France"},
  {"name":"Oissel","country":"France"},{"name":"Besançon","country":"France"},{"name":"Rouen","country":"France"},
  {"name":"Chasselay","country":"France"},{"name":"Marseille","country":"France"},{"name":"Grenoble","country":"France"},
  {"name":"Verrières-en-Anjou","country":"France"},{"name":"Bordeaux","country":"France"},{"name":"Levallois-Perret","country":"France"},
  {"name":"Toulouse","country":"France"},{"name":"Escalquens","country":"France"},{"name":"Neuilly-sur-Seine","country":"France"},
  {"name":"New York","country":"USA"},{"name":"Milan","country":"Italy"}
]$json$) AS (name TEXT, country TEXT))
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 0b: rebrand Blossom Life Sciences -> Rivercell
UPDATE organizations SET name='Rivercell', slug='rivercell', website='https://www.rivercell.ai/',
  description='Develops proprietary biological-data infrastructure and AI models that predict how human cells respond to drugs and genetic modifications. Its platform combines automated laboratory experiments, multimodal single-cell data, and AI world models to accelerate drug discovery. Formerly registered as Blossom Life Sciences.',
  updated_at=NOW()
WHERE slug='blossom-life-sciences';

-- Step 0c: new sectors
INSERT INTO sectors (id, name, slug, created_at, updated_at) VALUES
  (uuid_generate_v4(),'Blockchain','blockchain',NOW(),NOW()),
  (uuid_generate_v4(),'TechBio','techbio',NOW(),NOW()),
  (uuid_generate_v4(),'Consumer Electronics','consumer-electronics',NOW(),NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 1: organizations (new + existing upserted)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Flying Whales","website":"https://www.flying-whales.com/","description":"Develops large-capacity cargo airships capable of transporting heavy and oversized loads to locations without conventional transport infrastructure. Its LCA60T airship is designed to carry up to 60 tonnes and load or unload cargo while hovering, targeting forestry, renewable energy, construction, and industrial logistics."},
  {"name":"Dougs","website":"https://www.dougs.fr","description":"Develops an online accounting and business-management platform combining proprietary software, AI automation, and professional accountants. Its subscription services cover bookkeeping, tax filings, company formation, payroll, legal services, and electronic invoicing."},
  {"name":"Epyr","website":"https://www.epyr.co/","description":"Develops high-temperature thermal-energy storage systems that help industrial manufacturers replace fossil-fuel boilers with electric heat. Its technology uses inexpensive electricity to heat firebricks, storing energy for subsequent delivery as industrial steam. Also offers integrated deployment, energy management, and Heat-as-a-Service financing."},
  {"name":"HyLight","website":"https://www.hylight.aero/","description":"Develops autonomous, hydrogen-powered airships that inspect electricity networks, gas pipelines, and railway infrastructure. Its HyLighter aircraft collect high-resolution imagery and sensor data, which the company processes using AI to detect defects, identify methane leaks, and help infrastructure operators plan preventive maintenance."},
  {"name":"Goodweek","website":"https://www.goodweek.com","description":"Develops a platform that allows SMEs to manage employee access to multiple AI models, including ChatGPT, Claude, Gemini, and Mistral. It combines AI tools within a controlled environment where businesses can administer permissions, protect company data, and monitor spending."},
  {"name":"Wavo","website":"https://www.wavo.fr","description":"Provides inventory financing for SMEs and mid-sized companies. Instead of issuing loans, Wavo temporarily purchases eligible stock and resells it to clients as they sell their products. Its technology analyzes inventory movements and financial information to assess financing eligibility and manage transactions."},
  {"name":"Webyn","website":"https://www.webyn.ai","description":"Develops an AI-powered conversion optimization platform that uses autonomous agents to analyze visitor behavior, test website improvements, and personalize e-commerce experiences in real time."},
  {"name":"CarbonFarm","website":"https://carbonfarm.tech/","description":"Develops technology and financing infrastructure to reduce methane emissions from rice cultivation. Its platform combines satellite imagery, AI, agricultural field data, and greenhouse-gas modeling to measure emissions, verify changes in farming practices, and support the certification of carbon-reduction projects."},
  {"name":"Bruxless","website":"https://bruxless.com","description":"Develops a wearable device intended to reduce nocturnal teeth grinding and jaw clenching. Its connected chin strap detects jaw muscle contractions and delivers calibrated mechanical stimulation to encourage muscle relaxation. Incorporates technology developed by parent company Techno Concept."},
  {"name":"Koddex","website":"https://koddex.io/","description":"Develops an Engineering Operating System for companies designing complex industrial products. Its platform connects product requirements, components, bills of materials, testing, engineering decisions, and certification evidence, replacing fragmented spreadsheets and disconnected engineering tools with a traceable information system."},
  {"name":"H&B Materials","website":"https://hbmaterials.fr","description":"Develops bio-based, PFAS-free treatments that make textiles water-repellent without relying on conventional fluorinated coatings. Its patented technology chemically binds hydrophobic molecules to textile fibers and works with existing industrial finishing equipment."},
  {"name":"Fibraterre","website":"https://fibraterre.fr","description":"Manufactures low-carbon insulation panels made entirely from compressed wheat straw, without glue or synthetic resins. Its products provide thermal and acoustic insulation for new buildings and renovations."},
  {"name":"Logbook","website":"https://www.logbook.education/","description":"Develops an AI-assisted audio-feedback platform that allows teachers to record spoken comments on student work. The software transcribes and analyzes the feedback, tracks progress by skill for each student, and helps teachers personalize instruction."},
  {"name":"Lili for Life","website":"https://www.liliforlife.com","description":"Develops assistive reading devices for people with dyslexia. Its product range includes the Lili Lamp and a computer monitor that uses light-pulsing technology to improve reading comfort and reduce visual fatigue."},
  {"name":"UZAI","website":"https://uz-ip.tech/fr","description":"Develops an AI-powered platform for collecting, classifying, analyzing, and archiving evidence that trademarks are being used commercially. The software helps corporations and IP professionals document trademark use across jurisdictions, supporting enforcement, renewals, and legal proceedings. Operates as UZ.IP."},
  {"name":"MAGE-X Medical AI","website":"https://mage-x.com/","description":"Develops an AI-powered SaaS platform that automatically converts unstructured medical records, including clinical notes, surgical reports, and PDFs, into structured datasets, helping physicians, hospitals, and medical-device manufacturers conduct clinical research, track outcomes, and generate real-world evidence."},
  {"name":"Spiko","website":"https://www.spiko.io","description":"Regulated cash-management platform that issues tokenized money-market funds and makes them accessible to businesses, individuals, and financial platforms through apps and APIs. Manages $2.7B in assets across funds denominated in four currencies."},
  {"name":"WIREMIND SAS","website":"https://www.wiremind.io/","description":"Develops AI-powered revenue-management, inventory, distribution, and ticketing software for passenger transport, air cargo, sports, and live entertainment. Brand: Wiremind."},
  {"name":"Vates","website":"https://vates.tech/","description":"Develops open-source enterprise virtualization software, including XCP-ng and Xen Orchestra, offering organizations an alternative to VMware for managing virtual machines, infrastructure, backups, and data-center operations."},
  {"name":"WhiteLab Genomics","website":"https://whitelabgx.com","description":"Uses AI and experimental validation to design and optimize delivery systems and programmable genetic payloads for genomic medicines, including viral vectors, lipid nanoparticles, and synthetic promoters."},
  {"name":"Rivercell","website":"https://www.rivercell.ai/","description":"Develops proprietary biological-data infrastructure and AI models that predict how human cells respond to drugs and genetic modifications. Combines automated laboratory experiments, multimodal single-cell data, and AI world models to accelerate drug discovery."},
  {"name":"Vocca","website":"https://vocca.com/","description":"Builds healthcare-specific AI voice agents that answer patient calls, book and reschedule appointments, handle routine queries and administrative requests, and integrate with medical scheduling systems."},
  {"name":"VoltR","website":"https://www.voltr.tech/","description":"Remanufactures lithium batteries by recovering usable cells from end-of-first-life batteries, testing their residual performance and redeploying them into new made-in-France battery packs."},
  {"name":"Edonia","website":"https://www.edonia.com","description":"Develops Edo, a minimally processed, high-protein food ingredient made from spirulina using its patented Edonization process, for food manufacturers and foodservice operators."},
  {"name":"Netsec","website":"https://www.netsec.it","description":"AI-native managed IT and cybersecurity platform that consolidates endpoint management, identity, networking, security operations, cloud infrastructure, and help-desk services, delivered through Slack and Microsoft Teams. Legal entity Barbican SAS."},
  {"name":"Archeon Medical","website":"https://archeon-medical.com","description":"Develops real-time ventilation-monitoring technology for emergency resuscitation. Its EOlife system measures ventilation delivered to cardiac-arrest patients and provides visual feedback to emergency responders, helping them avoid insufficient or excessive ventilation."},
  {"name":"Cleavr","website":"https://www.cleavr.fr/","description":"AI-native accounts-receivable platform that automates invoice collection from post-invoicing through payment, including multichannel reminders, calls, dispute handling, payment matching, and escalation."},
  {"name":"AlloBrain","website":"https://www.allobrain.com","description":"Develops an AI platform for contact centers combining automated customer-service agents, real-time assistance for human operators, conversation analysis, and quality monitoring, with human oversight for sensitive decisions. Formerly AlloReview."},
  {"name":"Verso","website":"https://www.askverso.ai/","description":"AI-powered consumer research platform that automates study design, participant recruitment, video and voice interviews, and qualitative analysis, using adaptive AI interviewers and building continuously updated consumer profiles and searchable knowledge bases."},
  {"name":"Fleuret AI","website":"https://fleuret.ai","description":"Develops an agentic AI platform that automates penetration testing for web applications and APIs, continuously identifying vulnerabilities, proving exploitability, supporting remediation, and retesting fixes."},
  {"name":"VoltaBack","website":"https://www.voltaback.com","description":"Software platform that uses connected-vehicle, electricity-meter, and tariff data to manage corporate fleets and reimburse employees for home EV charging without installing dedicated charging hardware."},
  {"name":"Joe AI","website":"https://www.getjoe-ai.com","description":"Builds omnichannel AI agents for real-estate professionals that handle phone, email, SMS, WhatsApp and live-chat interactions and can execute actions directly inside property-management and other industry software."},
  {"name":"Betty Care","website":"https://betty.care/","description":"Digital perioperative-care platform helping medical teams manage patient preparation before surgery, rehabilitation, outcomes reporting, and remote post-operative monitoring. Operated by AIMED2."},
  {"name":"V-Loc","website":"https://www.v-loc.fr","description":"Provides medium-term rentals of electric licence-free cars, typically for periods ranging from one to 12 months, targeting drivers including teenagers, seniors and people with suspended licences."},
  {"name":"Combiné Kids","website":"https://combinekids.com/","description":"Develops screen-free, Wi-Fi-connected corded telephones for children aged 4-12. The device lets children make and receive calls without a smartphone, browser, or social media, while parents manage approved contacts, calling hours, and voicemail through a companion app. Operated by Dorim Group."},
  {"name":"Doors3","website":"https://doors3.io/","description":"Technology-transformation consultancy combining strategic consulting, software development, and creative services, specializing in artificial intelligence, blockchain, digital assets, and immersive technologies."}
]$json$) AS (name TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_october_2026', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1b: city links (primary; secondary for dual-HQ)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Flying Whales","city":"Suresnes","secondary_city":null},
  {"org_name":"Dougs","city":"Lyon","secondary_city":null},
  {"org_name":"Epyr","city":"Paris","secondary_city":null},
  {"org_name":"HyLight","city":"Le Plessis-Pâté","secondary_city":null},
  {"org_name":"Goodweek","city":"Strasbourg","secondary_city":null},
  {"org_name":"Wavo","city":"Lyon","secondary_city":null},
  {"org_name":"Webyn","city":"Paris","secondary_city":null},
  {"org_name":"CarbonFarm","city":"Nanterre","secondary_city":null},
  {"org_name":"Bruxless","city":"Manosque","secondary_city":null},
  {"org_name":"Koddex","city":"Lille","secondary_city":null},
  {"org_name":"H&B Materials","city":"Saint-Fons","secondary_city":null},
  {"org_name":"Fibraterre","city":"Oissel","secondary_city":null},
  {"org_name":"Logbook","city":"Besançon","secondary_city":null},
  {"org_name":"Lili for Life","city":"Rouen","secondary_city":null},
  {"org_name":"UZAI","city":"Chasselay","secondary_city":null},
  {"org_name":"MAGE-X Medical AI","city":"Marseille","secondary_city":null},
  {"org_name":"Spiko","city":"Paris","secondary_city":null},
  {"org_name":"WIREMIND SAS","city":"Paris","secondary_city":null},
  {"org_name":"Vates","city":"Grenoble","secondary_city":null},
  {"org_name":"WhiteLab Genomics","city":"Paris","secondary_city":null},
  {"org_name":"Rivercell","city":"Paris","secondary_city":null},
  {"org_name":"Vocca","city":"Paris","secondary_city":"New York"},
  {"org_name":"VoltR","city":"Verrières-en-Anjou","secondary_city":null},
  {"org_name":"Edonia","city":"Bordeaux","secondary_city":null},
  {"org_name":"Netsec","city":"Paris","secondary_city":"Milan"},
  {"org_name":"Archeon Medical","city":"Besançon","secondary_city":"New York"},
  {"org_name":"Cleavr","city":"Paris","secondary_city":null},
  {"org_name":"AlloBrain","city":"Paris","secondary_city":null},
  {"org_name":"Verso","city":"Paris","secondary_city":null},
  {"org_name":"Fleuret AI","city":"Paris","secondary_city":null},
  {"org_name":"VoltaBack","city":"Levallois-Perret","secondary_city":null},
  {"org_name":"Joe AI","city":"Paris","secondary_city":null},
  {"org_name":"Betty Care","city":"Toulouse","secondary_city":null},
  {"org_name":"V-Loc","city":"Escalquens","secondary_city":null},
  {"org_name":"Combiné Kids","city":"Neuilly-sur-Seine","secondary_city":null},
  {"org_name":"Doors3","city":"Marseille","secondary_city":null}
]$json$) AS (org_name TEXT, city TEXT, secondary_city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id,c1.id), secondary_city_id=COALESCE(o.secondary_city_id,c2.id), updated_at=NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug=lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
LEFT JOIN cities c2 ON c2.slug=lower(regexp_replace(regexp_replace(unaccent(s.secondary_city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- Step 2: funding rounds (36)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Flying Whales","stage":"growth","amount_eur":90.0,"currency_original":"EUR","amount_original":90000000,"announced_date":"2026-10-12","notes":"€90M growth round led by CMA CGM, cumulative funding ~€400M, for its LCA60T cargo airship and a manufacturing facility at Laruscade near Bordeaux. Smaller than the €105M+ previously anticipated; Québec did not participate. Investors: CMA CGM, Carac, Air Liquide, Groupe ADP, Bouygues, Sogecap, French Tech Souveraineté, Temaris, Principality of Monaco, Nouvelle-Aquitaine Regional Government. Source: La Tribune."},
  {"name":"Dougs","stage":"growth","amount_eur":50.0,"currency_original":"EUR","amount_original":50000000,"announced_date":"2026-10-15","notes":"€50M from Expedition Growth Capital for its AI-powered accounting platform. 50,000+ customers and €50M+ ARR (from 14,000 / €15M at Expedition's €25M July 2023 investment). Plans 800->1,000 staff in 2027. Disclosed funding across two institutional rounds €75M. Operating entity (holding: Dougs Group, SIREN 901509364). Source: FrenchWeb, EU-Startups."},
  {"name":"Epyr","stage":"series_a","amount_eur":15.0,"currency_original":"EUR","amount_original":15000000,"announced_date":"2026-10-13","notes":"Oversubscribed €15M Series A to expand its industrial thermal-storage business across Europe. First install at WEPA's Troyes mill (May 2026) supplies up to 25% of steam; next a 35 MWh install at Papeco's Orval-sur-Sienne mill. ~15 employees. Prior €3M pre-seed Feb 2025. Investors: SlateVC, AENU, Daphni, OVNI Capital, WEPA Ventures, Aurum Impact. Source: Epyr."},
  {"name":"HyLight","stage":"series_a","amount_eur":13.0,"currency_original":"EUR","amount_original":13000000,"announced_date":"2026-10-12","notes":"€13M Series A to industrialize its autonomous airship fleet and expand AI inspection. 750+ flight hours; customers Enedis, NaTran, Teréga, SNCF Réseau, VINCI. Aims 4->15 HyLighters in 2027; ~50 hires. Prior €3.7M April 2024 (cumulative ~€16.7M). Investors: Rubio Impact Ventures, DRW, Teampact Ventures, Y Combinator, Ring Capital. Source: AeroMorning, FrenchWeb."},
  {"name":"Goodweek","stage":"seed","amount_eur":10.32,"currency_original":"USD","amount_original":12000000,"announced_date":"2026-10-15","notes":"$12M (~€10.3M est.) led by Adara Ventures to commercialize its AI-management platform and expand internationally. Founded 2025; 50 employees across three countries, ~150 customers. Investors: Adara Ventures, Anamcara Capital, BGV, BY Venture Partners, CentraleSupélec Venture, FJ Labs, Interlace Ventures, True Ventures. Source: Goodweek, EU-Startups."},
  {"name":"Wavo","stage":"series_a","amount_eur":10.0,"currency_original":"EUR","amount_original":10000000,"announced_date":"2026-10-13","notes":"€10M led by Eurazeo to expand its inventory-financing platform in France and Northern Europe. Financed ~€35M of inventory for ~100 businesses (separate volume metric). Prior €3.5M Feb 2025 (cumulative ~€13.5M). Investors: Eurazeo, Axeleo Capital, HUB612. Source: Wavo, Le Journal des Entreprises."},
  {"name":"Webyn","stage":"series_a","amount_eur":7.0,"currency_original":"EUR","amount_original":7000000,"announced_date":"2026-10-15","notes":"€7M Series A led by Réflexion Capital to accelerate its AI agents and expand across Europe. Founded 2023, profitable; ~200 brands incl. Fusalp, Nuxe, SFR, Nutrimuscle; optimizes 100M monthly visitors. Investors: Réflexion Capital, Tomcat, Business Angels. Source: Webyn, LinkedIn."},
  {"name":"CarbonFarm","stage":"series_a","amount_eur":7.0,"currency_original":"EUR","amount_original":7000000,"announced_date":"2026-10-13","notes":"Oversubscribed €7M Series A led by Colam Impact to expand its rice-decarbonization business. Operates in 19 countries; partners Mars Food, Diageo, Ebro, Tilda. Satellite + field MRV for methane-reduction carbon credits. Investors: Colam Impact, Proparco, Suma Capital, elea, Working Capital Fund, Albo, Bpifrance, Serena, makesense, Technmind. Source: EU-Startups, AgFunder."},
  {"name":"Bruxless","stage":"seed","amount_eur":4.0,"currency_original":"EUR","amount_original":4000000,"announced_date":"2026-10-13","notes":"€4M equity from family shareholders (undisclosed) to commercialize its wearable anti-bruxism device. Tech from parent Techno Concept (functional proprioceptive stimulation). ~500 devices delivered summer 2026, 1,500 more ordered. Source: Presse Agence, J'aime les Startups."},
  {"name":"Koddex","stage":"seed","amount_eur":3.0,"currency_original":"EUR","amount_original":3000000,"announced_date":"2026-10-12","notes":"€3M led by Breega with Exotec for its Engineering Operating System for complex industrial products. ~10 employees; target industries robotics, aerospace, defense, medical devices, energy. Founder previously worked at Exotec. Source: J'aime les startups, La Gazette France."},
  {"name":"H&B Materials","stage":"pre_seed","amount_eur":2.1,"currency_original":"EUR","amount_original":2100000,"announced_date":"2026-10-07","notes":"€2.1M pre-seed to advance its bio-based, PFAS-free textile water-repellent treatment from lab samples to industrial finishing lines. Won a Techtextil Innovation Award 2026. Investors: Anima, Alpha Star, Keenest, RAISE Sherpas, Bpifrance, Caisse d'Épargne. Source: LinkedIn."},
  {"name":"Fibraterre","stage":"seed","amount_eur":1.8,"currency_original":"EUR","amount_original":1800000,"announced_date":"2026-09-15","notes":"€1.8M to industrialize its wheat-straw insulation panels at its Oissel site and build a national distribution network; targeting ~3,000 tonnes/year of wheat straw by 2030. Announced publicly in September (not a new October round). Investors: UTC Alumni Invest, SideAngels, Normandie Participations, Bpifrance. Source: Normandie Participations."},
  {"name":"Logbook","stage":"seed","amount_eur":1.0,"currency_original":"EUR","amount_original":1000000,"announced_date":"2026-09-15","notes":"€1M co-led by Time4 (daphni) and makesense Seed II to expand its AI-assisted educational audio-feedback platform. ~10,000 teachers, 13,000 hours of feedback, 220,000 students reached. Announced in September (not a new October round). Also many angels. Source: LinkedIn."},
  {"name":"Lili for Life","stage":"seed","amount_eur":1.1,"currency_original":"EUR","amount_original":1100000,"announced_date":"2026-10-14","notes":"€1.1M from existing shareholders (undisclosed), completed summer 2026, to strengthen commercial/marketing and accelerate sales of its assistive computer monitor (Lili Screen) alongside its Lili Lamp (pulsed-light tech from University of Rennes research). Source: Ouest France."},
  {"name":"UZAI","stage":"pre_seed","amount_eur":1.0,"currency_original":"EUR","amount_original":1000000,"announced_date":"2026-10-15","notes":"First €1M round to commercialize and internationalize its AI trademark-use evidence platform (operates as UZ.IP). Targets large international trademark portfolios incl. CAC 40. Expansion to China; co-founder Lieven Jacquot appointed CTO (ex-Alan). Investors: Paris Business Angels, HUB612, Business Angels. Source: Paris Business Angels."},
  {"name":"MAGE-X Medical AI","stage":"pre_seed","amount_eur":0.38,"currency_original":"EUR","amount_original":380000,"announced_date":"2026-10-09","notes":"€380K with healthcare professionals, supported by Bpifrance, to deploy its AI platform converting unstructured medical records into research-ready datasets (orthopedic/spinal surgery first). Partnership with EUROSPINE (Spine Tango) is separate from the financing. Source: Gomet."},
  {"name":"Spiko","stage":"series_b","amount_eur":77.4,"currency_original":"USD","amount_original":90000000,"announced_date":"2026-10-06","notes":"$90M (~€77.4M est.) Series B led by NEA, total funding $120M. 10,000+ businesses/individuals across 25+ jurisdictions; tokenized money-market funds. Investors: NEA, Index Ventures, Bpifrance, Speedinvest, Flourish Ventures, Shapers, White Star Capital, Blockwall, Frst, EQNX, Mirana Ventures, Wintermute Ventures, Business Angels, Axel Weber. Source: StreetInsider."},
  {"name":"WIREMIND SAS","stage":"growth","amount_eur":35.0,"currency_original":"EUR","amount_original":35000000,"announced_date":"2026-10-06","notes":"€35M first external capital after 12 years bootstrapped (profitable) for international expansion (South America, Middle East, APAC) and AI/R&D incl. LLMs. 80+ customers; founders retain majority control. Brand Wiremind. Investors: IronWave, Bpifrance, Seaya Andromeda. Source: PR Newswire."},
  {"name":"Vates","stage":"growth","amount_eur":30.0,"currency_original":"EUR","amount_original":30000000,"announced_date":"2026-10-06","notes":"€30M first external investment for international expansion of its open-source virtualization platform (XCP-ng, Xen Orchestra), a VMware alternative. 1,000+ customers in ~100 countries, 90% revenue outside France. Grew 65%+ in 2025; founders retain majority control. Investors: IRIS, Bpifrance. Source: Vates, Tech.eu."},
  {"name":"WhiteLab Genomics","stage":"series_b","amount_eur":22.36,"currency_original":"USD","amount_original":26000000,"announced_date":"2026-10-06","notes":"$26M (~€22.4M est.) Series B to expand in vivo validation of its AI-designed genomic-medicine assets and grow across North America, Europe and Asia (Boston, US West Coast; Japan, South Korea). Investors: AVP, Yaday Health, Blast Club, Omnes Capital, Debiopharm Innovation Fund. Source: WhiteLab Genomics."},
  {"name":"Rivercell","stage":"seed","amount_eur":21.5,"currency_original":"USD","amount_original":25000000,"announced_date":"2026-10-07","notes":"$25M (~€21.5M est.) seed led by HV; emerged from stealth to build an AI world model predicting how human cells respond to treatments. Founders ex-Cardiologs (Yann Fleureau) and ex-Owkin/Bioptimus (Eric Durand). Formerly Blossom Life Sciences. Investors: HV, HCVC, Alven, Bpifrance, Business Angels. Source: AFP, EU-Startups."},
  {"name":"Vocca","stage":"series_a","amount_eur":17.2,"currency_original":"USD","amount_original":20000000,"announced_date":"2026-10-06","notes":"$20M (~€17.2M est.) Series A; grew from ~2,000 to 15,000 practitioners across 1,500 practices in Europe and the US. 1M+ patient interactions/month, ~70% without human intervention. Healthcare AI voice agents. Dual HQ Paris / New York. Investors: Norrsken, Heal Capital, Speedinvest, firstminute, Business Angels. Source: Sifted."},
  {"name":"VoltR","stage":"series_a","amount_eur":22.0,"currency_original":"EUR","amount_original":22000000,"announced_date":"2026-10-05","notes":"€22M to industrialize its lithium-battery remanufacturing model: double its Verrières-en-Anjou factory, 6x production capacity over two years, ~40 jobs. Investors: Bpifrance, Decathlon PULSE, France 2030. Source: Bpifrance, Decathlon PULSE."},
  {"name":"Edonia","stage":"series_a","amount_eur":15.0,"currency_original":"EUR","amount_original":15000000,"announced_date":"2026-10-06","notes":"€15M total Series A financing (SWEN notes ~€12M equity; balance non-dilutive/public and bank financing) to build a French production facility and expand across Europe, Japan and the US. ~20 customer contracts / €30M preorders. Spirulina protein ingredient (Edo). Investors: SWEN, Asterion Ventures, EIT Food, Bpifrance, France 2030. Source: SWEN, EIT Food."},
  {"name":"Netsec","stage":"growth","amount_eur":8.6,"currency_original":"USD","amount_original":10000000,"announced_date":"2026-10-06","notes":"$10M+ (~€8.6M est.) led by Partech for its AI-native managed IT and cybersecurity platform across Europe and the US. French-Italian; thousands of endpoints; median incident response under 14 min. Legal entity Barbican SAS. Dual HQ Paris / Milan. Investors: Partech, Primo Capital, View Different, Riccardo Zacconi, Kima Ventures, Ithaca Investments, Vento, Vito Lomele, Everywhere Ventures, Business Angels. Source: Partech, Primo Capital."},
  {"name":"Archeon Medical","stage":"series_a","amount_eur":7.74,"currency_original":"USD","amount_original":9000000,"announced_date":"2026-10-06","notes":"$9M (~€7.7M est.) Series A led by Newfund to finance US clinical validation and commercial expansion of EOlife (emergency ventilation monitoring). Studies across Amsterdam UMC, Tualatin Valley Fire & Rescue, Rush University Medical Center. Founded 2018, ~25 employees, $1.5M 2025 revenue; FDA-cleared, CE-marked. Legal entity ARCHEON. Investors: Newfund, Eiffel Investment Group, UI Investissement, Majycc Innovation Santé, Karot Capital. Source: EU-Startups."},
  {"name":"Cleavr","stage":"seed","amount_eur":8.0,"currency_original":"EUR","amount_original":8000000,"announced_date":"2026-10-06","notes":"€8M seed six months after a €1M pre-seed; 100+ customers in seven months, expanded to Spain, Germany, Belgium, Italy, UK; processes several billion € of invoices/year. AI-native accounts-receivable. Investors: Varsity, Kima Ventures, Better Angle, 100IN, Portfolio Ventures, Kerala Ventures, Financière Saint James, Station F, Clover, Business Angels. Source: Cleavr, Tech.eu."},
  {"name":"AlloBrain","stage":"seed","amount_eur":6.02,"currency_original":"USD","amount_original":7000000,"announced_date":"2026-10-07","notes":"$7M (~€6M est.) seed led by Varsity for European expansion plus MEA presence. Founded 2020; AI contact-center agents with human oversight; customers SNCF Connect, Club Med, Groupama Gan Vie, Schneider Electric, Leroy Merlin. Formerly AlloReview. Investors: Varsity, Groupama, Business Angels. Source: J'aime les Startups, Stratégies."},
  {"name":"Verso","stage":"seed","amount_eur":5.16,"currency_original":"USD","amount_original":6000000,"announced_date":"2026-10-08","notes":"$6M (~€5.2M est.) seed led by Angular Ventures to expand its AI consumer-research platform internationally (esp. US). 30+ companies incl. Ferrero, Orange, Michelin. Investors: Angular Ventures, 100IN, Kima Ventures, Olympe Capital, Sharpstone Capital, Business Angels, Roxanne Varza, Hexa. Source: Hexa, Tech.eu."},
  {"name":"Fleuret AI","stage":"pre_seed","amount_eur":4.0,"currency_original":"EUR","amount_original":4000000,"announced_date":"2026-10-05","notes":"€4M pre-seed led by RAISE Ventures to build its automated offensive-security (agentic pentest) platform across European enterprises. Built via X-HEC Entrepreneurs. Investors: RAISE Ventures, Auriga Cyber Ventures, Wind Capital, Better Angle, Business Angels, Jules Veyrat, Alexandre Andreini, Eric Fourrier, Georges Lotigier, Olivier Pantaleo, Jean-François Aliotti. Source: The French Tech Journal."},
  {"name":"VoltaBack","stage":"seed","amount_eur":2.8,"currency_original":"EUR","amount_original":2800000,"announced_date":"2026-10-01","notes":"€2.8M to grow its team and expand its home EV-charging reimbursement / fleet-management platform across Europe. 20% of CAC 40 adopted it within 12 months; customers Veolia, Equans. Investors: Serena, Business Angels, Aurélien de Meaux, Maxime Brousse. Source: Automobile Propre."},
  {"name":"Joe AI","stage":"seed","amount_eur":2.0,"currency_original":"EUR","amount_original":2000000,"announced_date":"2026-10-01","notes":"€2M to develop its omnichannel AI agents for real estate, push into commercial real estate and prepare European expansion. 500+ customers, several thousand professionals in France. Investors: Xplore, Plug and Play Ventures, Business Angels, Thierry Herrmann, Olivier Safar, Patrick Safar, Marc Menasé, Benjamin Chemla, Justine Cazalière, Rémy Sultan, Renaud Dalbera, Cyril Madar, Julien Madar, Bpifrance. Source: Xplore."},
  {"name":"Betty Care","stage":"seed","amount_eur":1.5,"currency_original":"EUR","amount_original":1500000,"announced_date":"2026-10-01","notes":"€1.5M second round (undisclosed investors) to expand deployment of Betty, its digital perioperative-care platform. Operated by AIMED2 (Toulouse). Source: La Vie Economique."},
  {"name":"V-Loc","stage":"seed","amount_eur":1.5,"currency_original":"EUR","amount_original":1500000,"announced_date":"2026-10-02","notes":"€1.5M (undisclosed structure) to scale its medium-term, licence-free electric-vehicle rental model; targeting a 9,000-vehicle fleet in France by 2031. Source: La Vie Economique."},
  {"name":"Combiné Kids","stage":"seed","amount_eur":1.0,"currency_original":"EUR","amount_original":1000000,"announced_date":"2026-10-05","notes":"€1M from business angels to launch its screen-free children's corded phone (controlled network + parental app). 1,500 preorders within weeks; deliveries before Christmas 2026; priced €99.90 + €9.99/mo. Operated by Dorim Group. R&D in France, manufacturing in China. Investors: Business Angels, Kelly Massol, Alice Lhabouz, Angélique Gérard, Jérémy Bendayan. Source: Maddyness."},
  {"name":"Doors3","stage":"growth","amount_eur":1.0,"currency_original":"EUR","amount_original":1000000,"announced_date":"2026-10-06","notes":"9 Capital Management acquired an equity stake to finance recruitment, expand technology services and support international growth (Europe, Africa, Middle East). Founded 2022; AI, blockchain, stablecoins, tokenization, immersive tech. Investors: 9 Capital Management. Source: Doors3, Gomet, Cryptoast."}
]$json$) AS (name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original!='EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END, FALSE, 'funding_deals_october_2026', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- Step 3a: investor organizations (idempotent)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"CMA CGM"},{"name":"Carac"},{"name":"Air Liquide"},{"name":"Groupe ADP"},{"name":"Bouygues"},{"name":"Sogecap"},{"name":"French Tech Souveraineté"},{"name":"Temaris"},{"name":"Principality of Monaco"},{"name":"Nouvelle-Aquitaine Regional Government"},
  {"name":"Expedition Growth Capital"},
  {"name":"SlateVC"},{"name":"AENU"},{"name":"Daphni"},{"name":"OVNI Capital"},{"name":"WEPA Ventures"},{"name":"Aurum Impact"},
  {"name":"Rubio Impact Ventures"},{"name":"DRW"},{"name":"Teampact Ventures"},{"name":"Y Combinator"},{"name":"Ring Capital"},
  {"name":"Adara Ventures"},{"name":"Anamcara Capital"},{"name":"BGV"},{"name":"BY Venture Partners"},{"name":"CentraleSupélec Venture"},{"name":"FJ Labs"},{"name":"Interlace Ventures"},{"name":"True Ventures"},
  {"name":"Eurazeo"},{"name":"Axeleo Capital"},{"name":"HUB612"},
  {"name":"Réflexion Capital"},{"name":"Tomcat"},{"name":"Business Angels"},
  {"name":"Colam Impact"},{"name":"Proparco"},{"name":"Suma Capital"},{"name":"elea"},{"name":"Working Capital Fund"},{"name":"Albo"},{"name":"Bpifrance"},{"name":"Serena"},{"name":"makesense"},{"name":"Technmind"},
  {"name":"Breega"},{"name":"Exotec"},
  {"name":"Anima"},{"name":"Alpha Star"},{"name":"Keenest"},{"name":"RAISE Sherpas"},{"name":"Caisse d'Épargne"},
  {"name":"UTC Alumni Invest"},{"name":"SideAngels"},{"name":"Normandie Participations"},
  {"name":"Time4"},{"name":"makesense Seed II"},
  {"name":"Paris Business Angels"},
  {"name":"NEA"},{"name":"Index Ventures"},{"name":"Speedinvest"},{"name":"Flourish Ventures"},{"name":"Shapers"},{"name":"White Star Capital"},{"name":"Blockwall"},{"name":"Frst"},{"name":"EQNX"},{"name":"Mirana Ventures"},{"name":"Wintermute Ventures"},{"name":"Axel Weber"},
  {"name":"IronWave"},{"name":"Seaya Andromeda"},
  {"name":"IRIS"},
  {"name":"AVP"},{"name":"Yaday Health"},{"name":"Blast Club"},{"name":"Omnes Capital"},{"name":"Debiopharm Innovation Fund"},
  {"name":"HV"},{"name":"HCVC"},{"name":"Alven"},
  {"name":"Norrsken"},{"name":"Heal Capital"},{"name":"firstminute"},
  {"name":"Decathlon PULSE"},{"name":"France 2030"},
  {"name":"SWEN"},{"name":"Asterion Ventures"},{"name":"EIT Food"},
  {"name":"Partech"},{"name":"Primo Capital"},{"name":"View Different"},{"name":"Riccardo Zacconi"},{"name":"Kima Ventures"},{"name":"Ithaca Investments"},{"name":"Vento"},{"name":"Vito Lomele"},{"name":"Everywhere Ventures"},
  {"name":"Newfund"},{"name":"Eiffel Investment Group"},{"name":"UI Investissement"},{"name":"Majycc Innovation Santé"},{"name":"Karot Capital"},
  {"name":"Varsity"},{"name":"Better Angle"},{"name":"100IN"},{"name":"Portfolio Ventures"},{"name":"Kerala Ventures"},{"name":"Financière Saint James"},{"name":"Station F"},{"name":"Clover"},
  {"name":"Groupama"},
  {"name":"Angular Ventures"},{"name":"Olympe Capital"},{"name":"Sharpstone Capital"},{"name":"Roxanne Varza"},{"name":"Hexa"},
  {"name":"RAISE Ventures"},{"name":"Auriga Cyber Ventures"},{"name":"Wind Capital"},{"name":"Jules Veyrat"},{"name":"Alexandre Andreini"},{"name":"Eric Fourrier"},{"name":"Georges Lotigier"},{"name":"Olivier Pantaleo"},{"name":"Jean-François Aliotti"},
  {"name":"Aurélien de Meaux"},{"name":"Maxime Brousse"},
  {"name":"Xplore"},{"name":"Plug and Play Ventures"},{"name":"Thierry Herrmann"},{"name":"Olivier Safar"},{"name":"Patrick Safar"},{"name":"Marc Menasé"},{"name":"Benjamin Chemla"},{"name":"Justine Cazalière"},{"name":"Rémy Sultan"},{"name":"Renaud Dalbera"},{"name":"Cyril Madar"},{"name":"Julien Madar"},
  {"name":"Kelly Massol"},{"name":"Alice Lhabouz"},{"name":"Angélique Gérard"},{"name":"Jérémy Bendayan"},
  {"name":"9 Capital Management"}
]$json$) AS (name TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_october_2026', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: funding round investors (joined on org + source). Bruxless, Lili for
-- Life, Betty Care and V-Loc have undisclosed investors (no links).
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Flying Whales","investor_name":"CMA CGM","is_lead":true},{"org_name":"Flying Whales","investor_name":"Carac","is_lead":false},{"org_name":"Flying Whales","investor_name":"Air Liquide","is_lead":false},{"org_name":"Flying Whales","investor_name":"Groupe ADP","is_lead":false},{"org_name":"Flying Whales","investor_name":"Bouygues","is_lead":false},{"org_name":"Flying Whales","investor_name":"Sogecap","is_lead":false},{"org_name":"Flying Whales","investor_name":"French Tech Souveraineté","is_lead":false},{"org_name":"Flying Whales","investor_name":"Temaris","is_lead":false},{"org_name":"Flying Whales","investor_name":"Principality of Monaco","is_lead":false},{"org_name":"Flying Whales","investor_name":"Nouvelle-Aquitaine Regional Government","is_lead":false},
  {"org_name":"Dougs","investor_name":"Expedition Growth Capital","is_lead":true},
  {"org_name":"Epyr","investor_name":"SlateVC","is_lead":false},{"org_name":"Epyr","investor_name":"AENU","is_lead":false},{"org_name":"Epyr","investor_name":"Daphni","is_lead":false},{"org_name":"Epyr","investor_name":"OVNI Capital","is_lead":false},{"org_name":"Epyr","investor_name":"WEPA Ventures","is_lead":false},{"org_name":"Epyr","investor_name":"Aurum Impact","is_lead":false},
  {"org_name":"HyLight","investor_name":"Rubio Impact Ventures","is_lead":false},{"org_name":"HyLight","investor_name":"DRW","is_lead":false},{"org_name":"HyLight","investor_name":"Teampact Ventures","is_lead":false},{"org_name":"HyLight","investor_name":"Y Combinator","is_lead":false},{"org_name":"HyLight","investor_name":"Ring Capital","is_lead":false},
  {"org_name":"Goodweek","investor_name":"Adara Ventures","is_lead":true},{"org_name":"Goodweek","investor_name":"Anamcara Capital","is_lead":false},{"org_name":"Goodweek","investor_name":"BGV","is_lead":false},{"org_name":"Goodweek","investor_name":"BY Venture Partners","is_lead":false},{"org_name":"Goodweek","investor_name":"CentraleSupélec Venture","is_lead":false},{"org_name":"Goodweek","investor_name":"FJ Labs","is_lead":false},{"org_name":"Goodweek","investor_name":"Interlace Ventures","is_lead":false},{"org_name":"Goodweek","investor_name":"True Ventures","is_lead":false},
  {"org_name":"Wavo","investor_name":"Eurazeo","is_lead":true},{"org_name":"Wavo","investor_name":"Axeleo Capital","is_lead":false},{"org_name":"Wavo","investor_name":"HUB612","is_lead":false},
  {"org_name":"Webyn","investor_name":"Réflexion Capital","is_lead":true},{"org_name":"Webyn","investor_name":"Tomcat","is_lead":false},{"org_name":"Webyn","investor_name":"Business Angels","is_lead":false},
  {"org_name":"CarbonFarm","investor_name":"Colam Impact","is_lead":true},{"org_name":"CarbonFarm","investor_name":"Proparco","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Suma Capital","is_lead":false},{"org_name":"CarbonFarm","investor_name":"elea","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Working Capital Fund","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Albo","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Bpifrance","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Serena","is_lead":false},{"org_name":"CarbonFarm","investor_name":"makesense","is_lead":false},{"org_name":"CarbonFarm","investor_name":"Technmind","is_lead":false},
  {"org_name":"Koddex","investor_name":"Breega","is_lead":true},{"org_name":"Koddex","investor_name":"Exotec","is_lead":false},
  {"org_name":"H&B Materials","investor_name":"Anima","is_lead":false},{"org_name":"H&B Materials","investor_name":"Alpha Star","is_lead":false},{"org_name":"H&B Materials","investor_name":"Keenest","is_lead":false},{"org_name":"H&B Materials","investor_name":"RAISE Sherpas","is_lead":false},{"org_name":"H&B Materials","investor_name":"Bpifrance","is_lead":false},{"org_name":"H&B Materials","investor_name":"Caisse d'Épargne","is_lead":false},
  {"org_name":"Fibraterre","investor_name":"UTC Alumni Invest","is_lead":false},{"org_name":"Fibraterre","investor_name":"SideAngels","is_lead":false},{"org_name":"Fibraterre","investor_name":"Normandie Participations","is_lead":false},{"org_name":"Fibraterre","investor_name":"Bpifrance","is_lead":false},
  {"org_name":"Logbook","investor_name":"Time4","is_lead":true},{"org_name":"Logbook","investor_name":"makesense Seed II","is_lead":true},{"org_name":"Logbook","investor_name":"Business Angels","is_lead":false},
  {"org_name":"UZAI","investor_name":"Paris Business Angels","is_lead":false},{"org_name":"UZAI","investor_name":"HUB612","is_lead":false},{"org_name":"UZAI","investor_name":"Business Angels","is_lead":false},
  {"org_name":"MAGE-X Medical AI","investor_name":"Bpifrance","is_lead":false},{"org_name":"MAGE-X Medical AI","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Spiko","investor_name":"NEA","is_lead":true},{"org_name":"Spiko","investor_name":"Index Ventures","is_lead":false},{"org_name":"Spiko","investor_name":"Bpifrance","is_lead":false},{"org_name":"Spiko","investor_name":"Speedinvest","is_lead":false},{"org_name":"Spiko","investor_name":"Flourish Ventures","is_lead":false},{"org_name":"Spiko","investor_name":"Shapers","is_lead":false},{"org_name":"Spiko","investor_name":"White Star Capital","is_lead":false},{"org_name":"Spiko","investor_name":"Blockwall","is_lead":false},{"org_name":"Spiko","investor_name":"Frst","is_lead":false},{"org_name":"Spiko","investor_name":"EQNX","is_lead":false},{"org_name":"Spiko","investor_name":"Mirana Ventures","is_lead":false},{"org_name":"Spiko","investor_name":"Wintermute Ventures","is_lead":false},{"org_name":"Spiko","investor_name":"Business Angels","is_lead":false},{"org_name":"Spiko","investor_name":"Axel Weber","is_lead":false},
  {"org_name":"WIREMIND SAS","investor_name":"IronWave","is_lead":false},{"org_name":"WIREMIND SAS","investor_name":"Bpifrance","is_lead":false},{"org_name":"WIREMIND SAS","investor_name":"Seaya Andromeda","is_lead":false},
  {"org_name":"Vates","investor_name":"IRIS","is_lead":false},{"org_name":"Vates","investor_name":"Bpifrance","is_lead":false},
  {"org_name":"WhiteLab Genomics","investor_name":"AVP","is_lead":false},{"org_name":"WhiteLab Genomics","investor_name":"Yaday Health","is_lead":false},{"org_name":"WhiteLab Genomics","investor_name":"Blast Club","is_lead":false},{"org_name":"WhiteLab Genomics","investor_name":"Omnes Capital","is_lead":false},{"org_name":"WhiteLab Genomics","investor_name":"Debiopharm Innovation Fund","is_lead":false},
  {"org_name":"Rivercell","investor_name":"HV","is_lead":true},{"org_name":"Rivercell","investor_name":"HCVC","is_lead":false},{"org_name":"Rivercell","investor_name":"Alven","is_lead":false},{"org_name":"Rivercell","investor_name":"Bpifrance","is_lead":false},{"org_name":"Rivercell","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Vocca","investor_name":"Norrsken","is_lead":false},{"org_name":"Vocca","investor_name":"Heal Capital","is_lead":false},{"org_name":"Vocca","investor_name":"Speedinvest","is_lead":false},{"org_name":"Vocca","investor_name":"firstminute","is_lead":false},{"org_name":"Vocca","investor_name":"Business Angels","is_lead":false},
  {"org_name":"VoltR","investor_name":"Bpifrance","is_lead":false},{"org_name":"VoltR","investor_name":"Decathlon PULSE","is_lead":false},{"org_name":"VoltR","investor_name":"France 2030","is_lead":false},
  {"org_name":"Edonia","investor_name":"SWEN","is_lead":false},{"org_name":"Edonia","investor_name":"Asterion Ventures","is_lead":false},{"org_name":"Edonia","investor_name":"EIT Food","is_lead":false},{"org_name":"Edonia","investor_name":"Bpifrance","is_lead":false},{"org_name":"Edonia","investor_name":"France 2030","is_lead":false},
  {"org_name":"Netsec","investor_name":"Partech","is_lead":true},{"org_name":"Netsec","investor_name":"Primo Capital","is_lead":false},{"org_name":"Netsec","investor_name":"View Different","is_lead":false},{"org_name":"Netsec","investor_name":"Riccardo Zacconi","is_lead":false},{"org_name":"Netsec","investor_name":"Kima Ventures","is_lead":false},{"org_name":"Netsec","investor_name":"Ithaca Investments","is_lead":false},{"org_name":"Netsec","investor_name":"Vento","is_lead":false},{"org_name":"Netsec","investor_name":"Vito Lomele","is_lead":false},{"org_name":"Netsec","investor_name":"Everywhere Ventures","is_lead":false},{"org_name":"Netsec","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Archeon Medical","investor_name":"Newfund","is_lead":true},{"org_name":"Archeon Medical","investor_name":"Eiffel Investment Group","is_lead":false},{"org_name":"Archeon Medical","investor_name":"UI Investissement","is_lead":false},{"org_name":"Archeon Medical","investor_name":"Majycc Innovation Santé","is_lead":false},{"org_name":"Archeon Medical","investor_name":"Karot Capital","is_lead":false},
  {"org_name":"Cleavr","investor_name":"Varsity","is_lead":false},{"org_name":"Cleavr","investor_name":"Kima Ventures","is_lead":false},{"org_name":"Cleavr","investor_name":"Better Angle","is_lead":false},{"org_name":"Cleavr","investor_name":"100IN","is_lead":false},{"org_name":"Cleavr","investor_name":"Portfolio Ventures","is_lead":false},{"org_name":"Cleavr","investor_name":"Kerala Ventures","is_lead":false},{"org_name":"Cleavr","investor_name":"Financière Saint James","is_lead":false},{"org_name":"Cleavr","investor_name":"Station F","is_lead":false},{"org_name":"Cleavr","investor_name":"Clover","is_lead":false},{"org_name":"Cleavr","investor_name":"Business Angels","is_lead":false},
  {"org_name":"AlloBrain","investor_name":"Varsity","is_lead":true},{"org_name":"AlloBrain","investor_name":"Groupama","is_lead":false},{"org_name":"AlloBrain","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Verso","investor_name":"Angular Ventures","is_lead":true},{"org_name":"Verso","investor_name":"100IN","is_lead":false},{"org_name":"Verso","investor_name":"Kima Ventures","is_lead":false},{"org_name":"Verso","investor_name":"Olympe Capital","is_lead":false},{"org_name":"Verso","investor_name":"Sharpstone Capital","is_lead":false},{"org_name":"Verso","investor_name":"Business Angels","is_lead":false},{"org_name":"Verso","investor_name":"Roxanne Varza","is_lead":false},{"org_name":"Verso","investor_name":"Hexa","is_lead":false},
  {"org_name":"Fleuret AI","investor_name":"RAISE Ventures","is_lead":true},{"org_name":"Fleuret AI","investor_name":"Auriga Cyber Ventures","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Wind Capital","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Better Angle","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Business Angels","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Jules Veyrat","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Alexandre Andreini","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Eric Fourrier","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Georges Lotigier","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Olivier Pantaleo","is_lead":false},{"org_name":"Fleuret AI","investor_name":"Jean-François Aliotti","is_lead":false},
  {"org_name":"VoltaBack","investor_name":"Serena","is_lead":false},{"org_name":"VoltaBack","investor_name":"Business Angels","is_lead":false},{"org_name":"VoltaBack","investor_name":"Aurélien de Meaux","is_lead":false},{"org_name":"VoltaBack","investor_name":"Maxime Brousse","is_lead":false},
  {"org_name":"Joe AI","investor_name":"Xplore","is_lead":false},{"org_name":"Joe AI","investor_name":"Plug and Play Ventures","is_lead":false},{"org_name":"Joe AI","investor_name":"Business Angels","is_lead":false},{"org_name":"Joe AI","investor_name":"Thierry Herrmann","is_lead":false},{"org_name":"Joe AI","investor_name":"Olivier Safar","is_lead":false},{"org_name":"Joe AI","investor_name":"Patrick Safar","is_lead":false},{"org_name":"Joe AI","investor_name":"Marc Menasé","is_lead":false},{"org_name":"Joe AI","investor_name":"Benjamin Chemla","is_lead":false},{"org_name":"Joe AI","investor_name":"Justine Cazalière","is_lead":false},{"org_name":"Joe AI","investor_name":"Rémy Sultan","is_lead":false},{"org_name":"Joe AI","investor_name":"Renaud Dalbera","is_lead":false},{"org_name":"Joe AI","investor_name":"Cyril Madar","is_lead":false},{"org_name":"Joe AI","investor_name":"Julien Madar","is_lead":false},{"org_name":"Joe AI","investor_name":"Bpifrance","is_lead":false},
  {"org_name":"Combiné Kids","investor_name":"Business Angels","is_lead":false},{"org_name":"Combiné Kids","investor_name":"Kelly Massol","is_lead":false},{"org_name":"Combiné Kids","investor_name":"Alice Lhabouz","is_lead":false},{"org_name":"Combiné Kids","investor_name":"Angélique Gérard","is_lead":false},{"org_name":"Combiné Kids","investor_name":"Jérémy Bendayan","is_lead":false},
  {"org_name":"Doors3","investor_name":"9 Capital Management","is_lead":true}
]$json$) AS (org_name TEXT, investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN organizations inv ON inv.slug=lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_october_2026'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 4a: sector links (idempotent)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"flying-whales","sec":"spacetech-aerospace"},{"org":"flying-whales","sec":"climatetech"},{"org":"flying-whales","sec":"aviation"},{"org":"flying-whales","sec":"mobility"},
  {"org":"dougs","sec":"fintech"},{"org":"dougs","sec":"saas"},{"org":"dougs","sec":"artificial-intelligence"},
  {"org":"epyr","sec":"climatetech"},{"org":"epyr","sec":"energy"},
  {"org":"hylight","sec":"climatetech"},{"org":"hylight","sec":"spacetech-aerospace"},{"org":"hylight","sec":"robotics"},{"org":"hylight","sec":"artificial-intelligence"},{"org":"hylight","sec":"energy"},
  {"org":"goodweek","sec":"artificial-intelligence"},{"org":"goodweek","sec":"saas"},
  {"org":"wavo","sec":"fintech"},{"org":"wavo","sec":"artificial-intelligence"},
  {"org":"webyn","sec":"artificial-intelligence"},{"org":"webyn","sec":"martech"},{"org":"webyn","sec":"saas"},
  {"org":"carbonfarm","sec":"climatetech"},{"org":"carbonfarm","sec":"agritech"},{"org":"carbonfarm","sec":"artificial-intelligence"},{"org":"carbonfarm","sec":"spacetech-aerospace"},
  {"org":"bruxless","sec":"medtech"},{"org":"bruxless","sec":"healthtech"},
  {"org":"koddex","sec":"saas"},{"org":"koddex","sec":"artificial-intelligence"},
  {"org":"hb-materials","sec":"deeptech"},{"org":"hb-materials","sec":"climatetech"},
  {"org":"fibraterre","sec":"climatetech"},{"org":"fibraterre","sec":"deeptech"},
  {"org":"logbook","sec":"edtech"},{"org":"logbook","sec":"artificial-intelligence"},{"org":"logbook","sec":"saas"},
  {"org":"lili-for-life","sec":"healthtech"},{"org":"lili-for-life","sec":"consumer-electronics"},{"org":"lili-for-life","sec":"edtech"},
  {"org":"uzai","sec":"legaltech"},{"org":"uzai","sec":"artificial-intelligence"},{"org":"uzai","sec":"saas"},
  {"org":"mage-x-medical-ai","sec":"artificial-intelligence"},{"org":"mage-x-medical-ai","sec":"healthtech"},{"org":"mage-x-medical-ai","sec":"medtech"},{"org":"mage-x-medical-ai","sec":"saas"},
  {"org":"spiko","sec":"fintech"},{"org":"spiko","sec":"blockchain"},{"org":"spiko","sec":"web3"},
  {"org":"wiremind-sas","sec":"saas"},{"org":"wiremind-sas","sec":"artificial-intelligence"},{"org":"wiremind-sas","sec":"traveltech"},{"org":"wiremind-sas","sec":"mobility"},
  {"org":"vates","sec":"saas"},{"org":"vates","sec":"cybersecurity"},
  {"org":"whitelab-genomics","sec":"biotech"},{"org":"whitelab-genomics","sec":"techbio"},{"org":"whitelab-genomics","sec":"artificial-intelligence"},
  {"org":"rivercell","sec":"artificial-intelligence"},{"org":"rivercell","sec":"biotech"},{"org":"rivercell","sec":"techbio"},
  {"org":"vocca","sec":"healthtech"},{"org":"vocca","sec":"artificial-intelligence"},{"org":"vocca","sec":"voice-ai"},{"org":"vocca","sec":"saas"},
  {"org":"voltr","sec":"climatetech"},{"org":"voltr","sec":"energy"},
  {"org":"edonia","sec":"foodtech"},{"org":"edonia","sec":"agritech"},{"org":"edonia","sec":"climatetech"},
  {"org":"netsec","sec":"cybersecurity"},{"org":"netsec","sec":"artificial-intelligence"},{"org":"netsec","sec":"saas"},
  {"org":"archeon-medical","sec":"medtech"},
  {"org":"cleavr","sec":"fintech"},{"org":"cleavr","sec":"artificial-intelligence"},{"org":"cleavr","sec":"saas"},
  {"org":"allobrain","sec":"artificial-intelligence"},{"org":"allobrain","sec":"saas"},{"org":"allobrain","sec":"voice-ai"},
  {"org":"verso","sec":"artificial-intelligence"},{"org":"verso","sec":"saas"},{"org":"verso","sec":"martech"},
  {"org":"fleuret-ai","sec":"cybersecurity"},{"org":"fleuret-ai","sec":"artificial-intelligence"},{"org":"fleuret-ai","sec":"saas"},
  {"org":"voltaback","sec":"mobility"},{"org":"voltaback","sec":"saas"},{"org":"voltaback","sec":"climatetech"},
  {"org":"joe-ai","sec":"artificial-intelligence"},{"org":"joe-ai","sec":"proptech"},{"org":"joe-ai","sec":"saas"},
  {"org":"betty-care","sec":"healthtech"},{"org":"betty-care","sec":"saas"},
  {"org":"v-loc","sec":"mobility"},{"org":"v-loc","sec":"climatetech"},
  {"org":"combine-kids","sec":"consumer-electronics"},{"org":"combine-kids","sec":"hardware"},{"org":"combine-kids","sec":"telecom"},
  {"org":"doors3","sec":"artificial-intelligence"},{"org":"doors3","sec":"blockchain"},{"org":"doors3","sec":"web3"},{"org":"doors3","sec":"saas"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: promote primary where none exists
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"flying-whales","sec":"spacetech-aerospace"},{"org":"dougs","sec":"fintech"},{"org":"epyr","sec":"climatetech"},{"org":"hylight","sec":"climatetech"},{"org":"goodweek","sec":"artificial-intelligence"},{"org":"wavo","sec":"fintech"},{"org":"webyn","sec":"artificial-intelligence"},{"org":"carbonfarm","sec":"climatetech"},{"org":"bruxless","sec":"medtech"},{"org":"koddex","sec":"saas"},{"org":"hb-materials","sec":"deeptech"},{"org":"fibraterre","sec":"climatetech"},{"org":"logbook","sec":"edtech"},{"org":"lili-for-life","sec":"healthtech"},{"org":"uzai","sec":"legaltech"},{"org":"mage-x-medical-ai","sec":"artificial-intelligence"},{"org":"spiko","sec":"fintech"},{"org":"wiremind-sas","sec":"saas"},{"org":"vates","sec":"saas"},{"org":"whitelab-genomics","sec":"biotech"},{"org":"rivercell","sec":"artificial-intelligence"},{"org":"vocca","sec":"healthtech"},{"org":"voltr","sec":"climatetech"},{"org":"edonia","sec":"foodtech"},{"org":"netsec","sec":"cybersecurity"},{"org":"archeon-medical","sec":"medtech"},{"org":"cleavr","sec":"fintech"},{"org":"allobrain","sec":"artificial-intelligence"},{"org":"verso","sec":"artificial-intelligence"},{"org":"fleuret-ai","sec":"cybersecurity"},{"org":"voltaback","sec":"mobility"},{"org":"joe-ai","sec":"artificial-intelligence"},{"org":"betty-care","sec":"healthtech"},{"org":"v-loc","sec":"mobility"},{"org":"combine-kids","sec":"consumer-electronics"},{"org":"doors3","sec":"artificial-intelligence"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (founders)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Sébastien Bougon","first_name":"Sébastien","last_name":"Bougon"},
  {"full_name":"Patrick Maurice","first_name":"Patrick","last_name":"Maurice"},{"full_name":"Véronique Maurice","first_name":"Véronique","last_name":"Maurice"},{"full_name":"Sarah Jaouani","first_name":"Sarah","last_name":"Jaouani"},{"full_name":"Florent Galland","first_name":"Florent","last_name":"Galland"},
  {"full_name":"Bastien Oggeri","first_name":"Bastien","last_name":"Oggeri"},{"full_name":"Léa Dardenne","first_name":"Léa","last_name":"Dardenne"},
  {"full_name":"Martin Bocken","first_name":"Martin","last_name":"Bocken"},{"full_name":"Josef Rokusek","first_name":"Josef","last_name":"Rokusek"},{"full_name":"Thomas Laporte","first_name":"Thomas","last_name":"Laporte"},
  {"full_name":"Guillaume Nominé","first_name":"Guillaume","last_name":"Nominé"},{"full_name":"Nicolas Stehle","first_name":"Nicolas","last_name":"Stehle"},
  {"full_name":"Julien Decherf","first_name":"Julien","last_name":"Decherf"},{"full_name":"Adrien Plat","first_name":"Adrien","last_name":"Plat"},{"full_name":"Tanguy Clerget","first_name":"Tanguy","last_name":"Clerget"},
  {"full_name":"Vincent Oliveira","first_name":"Vincent","last_name":"Oliveira"},{"full_name":"Alexandre Farhat","first_name":"Alexandre","last_name":"Farhat"},
  {"full_name":"Vassily Carantino","first_name":"Vassily","last_name":"Carantino"},{"full_name":"James Hastwell","first_name":"James","last_name":"Hastwell"},
  {"full_name":"Guillaume Collinot","first_name":"Guillaume","last_name":"Collinot"},
  {"full_name":"Stéphane Dicostanzo","first_name":"Stéphane","last_name":"Dicostanzo"},
  {"full_name":"Hichem Ichou","first_name":"Hichem","last_name":"Ichou"},{"full_name":"Baptiste Andrin","first_name":"Baptiste","last_name":"Andrin"},
  {"full_name":"Alain Le Berre","first_name":"Alain","last_name":"Le Berre"},{"full_name":"Gilles Froidure","first_name":"Gilles","last_name":"Froidure"},{"full_name":"Cédric Billard","first_name":"Cédric","last_name":"Billard"},{"full_name":"Vincent Billaud","first_name":"Vincent","last_name":"Billaud"},
  {"full_name":"Axelle Lhermitte","first_name":"Axelle","last_name":"Lhermitte"},{"full_name":"Mathieu Pichon","first_name":"Mathieu","last_name":"Pichon"},{"full_name":"Benjamin Abdi","first_name":"Benjamin","last_name":"Abdi"},
  {"full_name":"Frédéric Granotier","first_name":"Frédéric","last_name":"Granotier"},
  {"full_name":"Julie Cahen","first_name":"Julie","last_name":"Cahen"},{"full_name":"Julien Scicluna","first_name":"Julien","last_name":"Scicluna"},{"full_name":"Louis Stockreisser","first_name":"Louis","last_name":"Stockreisser"},{"full_name":"Lieven Jacquot","first_name":"Lieven","last_name":"Jacquot"},
  {"full_name":"Augustin Missoffe","first_name":"Augustin","last_name":"Missoffe"},{"full_name":"Hadrien Giorgi","first_name":"Hadrien","last_name":"Giorgi"},{"full_name":"Aymeric Faure","first_name":"Aymeric","last_name":"Faure"},{"full_name":"Marc Szadkowski","first_name":"Marc","last_name":"Szadkowski"},{"full_name":"Henri d'Astorg","first_name":"Henri","last_name":"d'Astorg"},{"full_name":"Alfred Butler","first_name":"Alfred","last_name":"Butler"},
  {"full_name":"Paul-Adrien Hyppolite","first_name":"Paul-Adrien","last_name":"Hyppolite"},{"full_name":"Antoine Michon","first_name":"Antoine","last_name":"Michon"},
  {"full_name":"Colin Girault-Matz","first_name":"Colin","last_name":"Girault-Matz"},{"full_name":"Charles Pierre","first_name":"Charles","last_name":"Pierre"},
  {"full_name":"Olivier Lambert","first_name":"Olivier","last_name":"Lambert"},{"full_name":"Nithida Vialle","first_name":"Nithida","last_name":"Vialle"},{"full_name":"Julien Fontanet","first_name":"Julien","last_name":"Fontanet"},
  {"full_name":"David Del Bourgo","first_name":"David","last_name":"Del Bourgo"},{"full_name":"Lucia Cinquem","first_name":"Lucia","last_name":"Cinquem"},{"full_name":"Julien Cottineau","first_name":"Julien","last_name":"Cottineau"},
  {"full_name":"Yann Fleureau","first_name":"Yann","last_name":"Fleureau"},{"full_name":"Eric Durand","first_name":"Eric","last_name":"Durand"},
  {"full_name":"Eliott Hoffenberg","first_name":"Eliott","last_name":"Hoffenberg"},{"full_name":"Hugo Danet","first_name":"Hugo","last_name":"Danet"},
  {"full_name":"Alban Regnier","first_name":"Alban","last_name":"Regnier"},{"full_name":"Maxime Bleskine","first_name":"Maxime","last_name":"Bleskine"},{"full_name":"François Mallet","first_name":"François","last_name":"Mallet"},{"full_name":"Thibaud Maufront","first_name":"Thibaud","last_name":"Maufront"},
  {"full_name":"Hugo Valentin","first_name":"Hugo","last_name":"Valentin"},{"full_name":"Pierre Mignon","first_name":"Pierre","last_name":"Mignon"},{"full_name":"Nicolas Irlinger","first_name":"Nicolas","last_name":"Irlinger"},
  {"full_name":"Gianluca Varisco","first_name":"Gianluca","last_name":"Varisco"},{"full_name":"Guglielmo Reina","first_name":"Guglielmo","last_name":"Reina"},
  {"full_name":"Alban De Luca","first_name":"Alban","last_name":"De Luca"},{"full_name":"Pierre-Edouard Saillard","first_name":"Pierre-Edouard","last_name":"Saillard"},
  {"full_name":"Baptiste Nassoy","first_name":"Baptiste","last_name":"Nassoy"},{"full_name":"Arthur Guérin","first_name":"Arthur","last_name":"Guérin"},{"full_name":"Antoine Grenard","first_name":"Antoine","last_name":"Grenard"},
  {"full_name":"Zied Haj-Yahia","first_name":"Zied","last_name":"Haj-Yahia"},{"full_name":"Adrien Sasportes","first_name":"Adrien","last_name":"Sasportes"},{"full_name":"Yves-Marie Bouedo","first_name":"Yves-Marie","last_name":"Bouedo"},
  {"full_name":"Lydia Bellahouel","first_name":"Lydia","last_name":"Bellahouel"},{"full_name":"Camille Epitalon","first_name":"Camille","last_name":"Epitalon"},
  {"full_name":"Yanis Grigy","first_name":"Yanis","last_name":"Grigy"},{"full_name":"Augustin Ponsin","first_name":"Augustin","last_name":"Ponsin"},
  {"full_name":"Arnaud Tran","first_name":"Arnaud","last_name":"Tran"},{"full_name":"Adrien Guenard","first_name":"Adrien","last_name":"Guenard"},
  {"full_name":"Stanislas Chertok","first_name":"Stanislas","last_name":"Chertok"},{"full_name":"Victor Perez","first_name":"Victor","last_name":"Perez"},
  {"full_name":"Guillaume Ploussard","first_name":"Guillaume","last_name":"Ploussard"},{"full_name":"Jean-Baptiste Beauval","first_name":"Jean-Baptiste","last_name":"Beauval"},
  {"full_name":"Quentin Sabathé","first_name":"Quentin","last_name":"Sabathé"},{"full_name":"Lucas Sabathé","first_name":"Lucas","last_name":"Sabathé"},{"full_name":"Estelle Henny","first_name":"Estelle","last_name":"Henny"},{"full_name":"Guillaume Gomanne","first_name":"Guillaume","last_name":"Gomanne"},
  {"full_name":"Mélody Madar","first_name":"Mélody","last_name":"Madar"},{"full_name":"Yohan Elbase","first_name":"Yohan","last_name":"Elbase"},
  {"full_name":"Karen Jouve","first_name":"Karen","last_name":"Jouve"},{"full_name":"Guillaume Moret-Bailly","first_name":"Guillaume","last_name":"Moret-Bailly"},{"full_name":"Julien Furlanetto","first_name":"Julien","last_name":"Furlanetto"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_october_2026', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Flying Whales","founder_name":"Sébastien Bougon"},
  {"org_name":"Dougs","founder_name":"Patrick Maurice"},{"org_name":"Dougs","founder_name":"Véronique Maurice"},{"org_name":"Dougs","founder_name":"Sarah Jaouani"},{"org_name":"Dougs","founder_name":"Florent Galland"},
  {"org_name":"Epyr","founder_name":"Bastien Oggeri"},{"org_name":"Epyr","founder_name":"Léa Dardenne"},
  {"org_name":"HyLight","founder_name":"Martin Bocken"},{"org_name":"HyLight","founder_name":"Josef Rokusek"},{"org_name":"HyLight","founder_name":"Thomas Laporte"},
  {"org_name":"Goodweek","founder_name":"Guillaume Nominé"},{"org_name":"Goodweek","founder_name":"Nicolas Stehle"},
  {"org_name":"Wavo","founder_name":"Julien Decherf"},{"org_name":"Wavo","founder_name":"Adrien Plat"},{"org_name":"Wavo","founder_name":"Tanguy Clerget"},
  {"org_name":"Webyn","founder_name":"Vincent Oliveira"},{"org_name":"Webyn","founder_name":"Alexandre Farhat"},
  {"org_name":"CarbonFarm","founder_name":"Vassily Carantino"},{"org_name":"CarbonFarm","founder_name":"James Hastwell"},
  {"org_name":"Bruxless","founder_name":"Guillaume Collinot"},
  {"org_name":"Koddex","founder_name":"Stéphane Dicostanzo"},
  {"org_name":"H&B Materials","founder_name":"Hichem Ichou"},{"org_name":"H&B Materials","founder_name":"Baptiste Andrin"},
  {"org_name":"Fibraterre","founder_name":"Alain Le Berre"},{"org_name":"Fibraterre","founder_name":"Gilles Froidure"},{"org_name":"Fibraterre","founder_name":"Cédric Billard"},{"org_name":"Fibraterre","founder_name":"Vincent Billaud"},
  {"org_name":"Logbook","founder_name":"Axelle Lhermitte"},{"org_name":"Logbook","founder_name":"Mathieu Pichon"},{"org_name":"Logbook","founder_name":"Benjamin Abdi"},
  {"org_name":"Lili for Life","founder_name":"Frédéric Granotier"},
  {"org_name":"UZAI","founder_name":"Julie Cahen"},{"org_name":"UZAI","founder_name":"Julien Scicluna"},{"org_name":"UZAI","founder_name":"Louis Stockreisser"},{"org_name":"UZAI","founder_name":"Lieven Jacquot"},
  {"org_name":"MAGE-X Medical AI","founder_name":"Augustin Missoffe"},{"org_name":"MAGE-X Medical AI","founder_name":"Hadrien Giorgi"},{"org_name":"MAGE-X Medical AI","founder_name":"Aymeric Faure"},{"org_name":"MAGE-X Medical AI","founder_name":"Marc Szadkowski"},{"org_name":"MAGE-X Medical AI","founder_name":"Henri d'Astorg"},{"org_name":"MAGE-X Medical AI","founder_name":"Alfred Butler"},
  {"org_name":"Spiko","founder_name":"Paul-Adrien Hyppolite"},{"org_name":"Spiko","founder_name":"Antoine Michon"},
  {"org_name":"WIREMIND SAS","founder_name":"Colin Girault-Matz"},{"org_name":"WIREMIND SAS","founder_name":"Charles Pierre"},
  {"org_name":"Vates","founder_name":"Olivier Lambert"},{"org_name":"Vates","founder_name":"Nithida Vialle"},{"org_name":"Vates","founder_name":"Julien Fontanet"},
  {"org_name":"WhiteLab Genomics","founder_name":"David Del Bourgo"},{"org_name":"WhiteLab Genomics","founder_name":"Lucia Cinquem"},{"org_name":"WhiteLab Genomics","founder_name":"Julien Cottineau"},
  {"org_name":"Rivercell","founder_name":"Yann Fleureau"},{"org_name":"Rivercell","founder_name":"Eric Durand"},
  {"org_name":"Vocca","founder_name":"Eliott Hoffenberg"},{"org_name":"Vocca","founder_name":"Hugo Danet"},
  {"org_name":"VoltR","founder_name":"Alban Regnier"},{"org_name":"VoltR","founder_name":"Maxime Bleskine"},{"org_name":"VoltR","founder_name":"François Mallet"},{"org_name":"VoltR","founder_name":"Thibaud Maufront"},
  {"org_name":"Edonia","founder_name":"Hugo Valentin"},{"org_name":"Edonia","founder_name":"Pierre Mignon"},{"org_name":"Edonia","founder_name":"Nicolas Irlinger"},
  {"org_name":"Netsec","founder_name":"Gianluca Varisco"},{"org_name":"Netsec","founder_name":"Guglielmo Reina"},
  {"org_name":"Archeon Medical","founder_name":"Alban De Luca"},{"org_name":"Archeon Medical","founder_name":"Pierre-Edouard Saillard"},
  {"org_name":"Cleavr","founder_name":"Baptiste Nassoy"},{"org_name":"Cleavr","founder_name":"Arthur Guérin"},{"org_name":"Cleavr","founder_name":"Antoine Grenard"},
  {"org_name":"AlloBrain","founder_name":"Zied Haj-Yahia"},{"org_name":"AlloBrain","founder_name":"Adrien Sasportes"},{"org_name":"AlloBrain","founder_name":"Yves-Marie Bouedo"},
  {"org_name":"Verso","founder_name":"Lydia Bellahouel"},{"org_name":"Verso","founder_name":"Camille Epitalon"},
  {"org_name":"Fleuret AI","founder_name":"Yanis Grigy"},{"org_name":"Fleuret AI","founder_name":"Augustin Ponsin"},
  {"org_name":"VoltaBack","founder_name":"Arnaud Tran"},{"org_name":"VoltaBack","founder_name":"Adrien Guenard"},
  {"org_name":"Joe AI","founder_name":"Stanislas Chertok"},{"org_name":"Joe AI","founder_name":"Victor Perez"},
  {"org_name":"Betty Care","founder_name":"Guillaume Ploussard"},{"org_name":"Betty Care","founder_name":"Jean-Baptiste Beauval"},
  {"org_name":"V-Loc","founder_name":"Quentin Sabathé"},{"org_name":"V-Loc","founder_name":"Lucas Sabathé"},{"org_name":"V-Loc","founder_name":"Estelle Henny"},{"org_name":"V-Loc","founder_name":"Guillaume Gomanne"},
  {"org_name":"Combiné Kids","founder_name":"Mélody Madar"},{"org_name":"Combiné Kids","founder_name":"Yohan Elbase"},
  {"org_name":"Doors3","founder_name":"Karen Jouve"},{"org_name":"Doors3","founder_name":"Guillaume Moret-Bailly"},{"org_name":"Doors3","founder_name":"Julien Furlanetto"}
]$json$) AS (org_name TEXT, founder_name TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN people p ON p.slug=lower(regexp_replace(regexp_replace(unaccent(s.founder_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities. Idempotent. Edonia skipped (its SIREN 949848907
-- already sits on a separate 'alt-g-protein' record); Joe AI has no SIREN.
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"flying-whales","legal_name":"FLYING WHALES","siren":"788658946"},
  {"org":"dougs","legal_name":"DOUGS","siren":"810319517"},
  {"org":"epyr","legal_name":"EPYR","siren":"938163904"},
  {"org":"hylight","legal_name":"HYLIGHT","siren":"915019947"},
  {"org":"goodweek","legal_name":"GOODWEEK","siren":"991305160"},
  {"org":"wavo","legal_name":"WAVO","siren":"921951232"},
  {"org":"webyn","legal_name":"WEBYN","siren":"949963136"},
  {"org":"carbonfarm","legal_name":"CARBONFARM","siren":"912160389"},
  {"org":"bruxless","legal_name":"BRUXLESS","siren":"894562826"},
  {"org":"koddex","legal_name":"KODDEX","siren":"931914287"},
  {"org":"hb-materials","legal_name":"H&B MATERIALS","siren":"943676825"},
  {"org":"fibraterre","legal_name":"FIBRATERRE","siren":"930847447"},
  {"org":"logbook","legal_name":"LOGBOOK","siren":"928990571"},
  {"org":"lili-for-life","legal_name":"LILI FOR LIFE","siren":"889676466"},
  {"org":"uzai","legal_name":"UZAI","siren":"979273604"},
  {"org":"mage-x-medical-ai","legal_name":"MAGE-X MEDICAL AI","siren":"928989680"},
  {"org":"spiko","legal_name":"SPIKO","siren":"953542958"},
  {"org":"wiremind-sas","legal_name":"WIREMIND SAS","siren":"805145828"},
  {"org":"vates","legal_name":"VATES","siren":"752155259"},
  {"org":"whitelab-genomics","legal_name":"WHITELAB GENOMICS","siren":"847935046"},
  {"org":"rivercell","legal_name":"RIVERCELL","siren":"981215718"},
  {"org":"vocca","legal_name":"VOCCA","siren":"931119150"},
  {"org":"voltr","legal_name":"VOLTR","siren":"947745634"},
  {"org":"netsec","legal_name":"BARBICAN SAS","siren":"988183455"},
  {"org":"archeon-medical","legal_name":"ARCHEON","siren":"835009465"},
  {"org":"cleavr","legal_name":"CLEAVR","siren":"989360615"},
  {"org":"allobrain","legal_name":"ALLOBRAIN","siren":"890721178"},
  {"org":"verso","legal_name":"VERSO","siren":"102243441"},
  {"org":"fleuret-ai","legal_name":"FLEURET AI","siren":"999515604"},
  {"org":"voltaback","legal_name":"VOLTABACK","siren":"938589512"},
  {"org":"betty-care","legal_name":"AIMED2","siren":"921089090"},
  {"org":"v-loc","legal_name":"V-LOC","siren":"905370110"},
  {"org":"combine-kids","legal_name":"DORIM GROUP","siren":"102039476"},
  {"org":"doors3","legal_name":"DOORS 3","siren":"949279046"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_october_2026'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_october_2026'
UNION ALL SELECT 'Founder People (new)', COUNT(*) FROM people WHERE legacy_source='funding_deals_october_2026';
