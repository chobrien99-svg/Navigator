-- =============================================================================
-- TechBio in France (October 2026 update) — 13 companies not yet in the DB
-- =============================================================================
-- source_name 'techbio_france_october_2026'. Amounts in millions, EUR.
--
-- Companies: AI-biopharma, BeLiver, D&A MedLabs, HyprView, InSiliBio, Ksilink,
-- MedInsights, Opsin, Parean Biotechnologies, Peaccel, Rosetta Omics, Tebuna,
-- TychoBio. All tagged TechBio (primary) + Biotech, plus AI / HealthTech etc.
--
-- All 13 SIRENs verified against the French business registry
-- (recherche-entreprises.api.gouv.fr / Pappers): names, registered cities,
-- creation dates and company officers match the source spreadsheet.
-- No SIREN or slug already existed in the database.
--
-- Special cases:
--   * Ksilink (KSILINK SERVICES SAS, 908717796): in judicial liquidation.
--     Strasbourg court: safeguard procedure 2026-06-29, converted to
--     receivership 2026-07-20, judicial liquidation 2026-09-28 (BODACC A
--     n°20260204, annonce 2557, rectified 2026-10-23; liquidator SELARL MJ AIR).
--     Added with status 'inactive' + three organization_events. The separate
--     Ksilink Association (its president) is not added.
--   * Peaccel: registered in Saint-Denis, La Réunion (974). New city row
--     'saint-denis-la-reunion' (the existing 'saint-denis' row is ambiguous).
--     Grant recorded from the EU state-aid register via Pappers: €1,979,950
--     R&D aid from the Conseil régional de La Réunion, granted 2018-10-08.
--     The company's claim of "$8.7M+ non-dilutive funding" is cumulative and
--     unitemised, so it is noted in the description only.
--   * HyprView: €1.4M pre-seed per the company/investor announcement;
--     aggregators (Tracxn, VCBacked) date it December 2025 and give ~$1.6M.
--     Date is month-level. Investors linked: Jean-Philippe Vert (new investor
--     record), Franck Le Ouay (existing). Other angels named in one LinkedIn
--     post only are listed in the notes, not linked.
--   * Parean: first round (capital increase, private investors, amount
--     undisclosed). Legal notice: decided 2023-08-30, completed 2023-10-25;
--     announced November 2023 (month-level date). Investors not public.
--   * Rosetta Omics: company one-pager says €350K from angel investors plus a
--     Bpifrance grant; unclear whether the grant is inside the €350K, so the
--     round is flagged is_estimated. Date (May 2024) from Caplight only.
--   * TychoBio: pre-seed reported by Crunchbase only (Kima Ventures, Tiny
--     Supercomputer Investment Company); amount and date undisclosed; not
--     independently confirmed. The French entity (TYCHOBIO FRANCE) was created
--     2025-12-29; a US entity (TychoBio Inc) also exists.
--   * No round recorded for AI-biopharma, BeLiver, D&A MedLabs, InSiliBio,
--     Ksilink, MedInsights, Opsin, Tebuna (none confirmed). Context is in the
--     descriptions.
--   * People whose founder status is unconfirmed are linked with their
--     registry/company title (is_founder FALSE). Bernard Offmann already
--     existed as a person (no org links) and is reused for Peaccel.
-- =============================================================================

-- Step 0: new city (Peaccel) and new angel investor (HyprView)
INSERT INTO cities (id, name, slug, department, department_code, region, country, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Saint-Denis (La Réunion)', 'saint-denis-la-reunion', 'La Réunion', '974', 'La Réunion', 'France', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO organizations (id, name, slug, organization_type, description, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Jean-Philippe Vert', 'jean-philippe-vert', 'investor'::organization_type,
  'Business angel. Machine-learning researcher specialising in computational biology.',
  'active'::organization_status, 'France', 'techbio_france_october_2026', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"AI-biopharma","slug":"ai-biopharma","website":"https://ai-biopharma.com","status":"active","founded":"2018-02-15","city":"montpellier","description":"Drug-discovery company combining medicinal chemistry with computational design tools to develop small-molecule drug candidates, including antiviral programmes. Based in Montpellier."},
  {"name":"BeLiver","slug":"beliver","website":"https://beliver.fr","status":"active","founded":"2025-02-19","city":"bordeaux","description":"Develops AI and proteomics tools that predict how patients will respond to cancer treatment, starting with liver cancer. Based in Bordeaux. A 2025 pitch document cited a €2.5M seed target; no completed round has been confirmed."},
  {"name":"D&A MedLabs","slug":"da-medlabs","website":"https://www.dna-medlabs.com","status":"active","founded":"2024-04-25","city":"lyon","description":"Builds biomedical knowledge graphs and AI tools to support biomarker discovery and drug-target research. Based in Lyon."},
  {"name":"HyprView","slug":"hyprview","website":"https://www.hyprview.com","status":"active","founded":"2022-04-22","city":"paris","description":"Combines photonics measurement with AI to identify predictive biomarkers for precision oncology. Originally based in Caen, now in Paris."},
  {"name":"InSiliBio","slug":"insilibio","website":"https://www.insilibio.com","status":"active","founded":"2019-04-30","city":"limoges","description":"Provides molecular-modelling and simulation services to predict how molecules behave, for pharmaceutical, cosmetics and other industrial clients. Based in Limoges. Initially financed by Jouaud Investissements and two plastics companies; said in 2024 that it had not raised a funding round."},
  {"name":"Ksilink","slug":"ksilink","website":"https://www.ksilink.com","status":"inactive","founded":"2021-12-07","city":"strasbourg","description":"Phenotypic drug-discovery company using patient-derived cell models, high-content imaging and data analysis to find new therapeutic targets and compounds. Based in Strasbourg; the operating company Ksilink Services is controlled by the Ksilink Association. Placed in judicial liquidation by the Strasbourg court on 28 September 2026, after a safeguard procedure (June 2026) and receivership (July 2026)."},
  {"name":"MedInsights","slug":"medinsights","website":"https://www.medinsights.fr","status":"active","founded":"2022-08-11","city":"paris","description":"Develops explainable-AI and knowledge-graph tools to analyse biomedical data, including molecular digital twins for health research. Based in Paris. Its CardioTwin project received Eureka Eurostars funding (amount not disclosed)."},
  {"name":"Opsin","slug":"opsin","website":"https://www.opsin.bio","status":"active","founded":"2026-08-07","city":"gif-sur-yvette","description":"Develops an AI orchestration layer that coordinates experiments, instruments and data in drug-development laboratories. Based in Gif-sur-Yvette; founded in August 2026."},
  {"name":"Parean Biotechnologies","slug":"parean-biotechnologies","website":"https://www.pareanbiotech.fr","status":"active","founded":"2021-01-07","city":"saint-malo","description":"Combines laboratory services and data science to provide deep immune-profiling analyses for pharmaceutical and biotech clients. Based in Saint-Malo."},
  {"name":"Peaccel","slug":"peaccel","website":"https://www.peaccel.com","status":"active","founded":"2011-03-05","city":"saint-denis-la-reunion","description":"Uses AI and computational methods to design and optimise peptides and proteins for therapeutic and industrial uses. Registered in Saint-Denis, La Réunion. Reports more than $8.7M in cumulative non-dilutive funding."},
  {"name":"Rosetta Omics","slug":"rosetta-omics","website":"https://rosetta-omics.com","status":"active","founded":"2023-10-30","city":"paris","description":"Develops a precision-oncology platform that combines multi-omics data and AI to help match cancer patients with effective treatments. Based in Paris; incubated at Agoranov and Station F."},
  {"name":"Tebuna","slug":"tebuna","website":"https://tebuna.bio","status":"active","founded":"2025-11-05","city":"nice","description":"Combines computational design with laboratory screening to produce custom peptide binders for research use. Based in Nice."},
  {"name":"TychoBio","slug":"tychobio","website":"https://tychobio.ai","status":"active","founded":"2025-12-29","city":"saint-mande","description":"Develops AI-designed RNA therapeutics, combining high-throughput screening with machine learning, with a focus on rare diseases. In October 2026 announced a partnership with PacBio to generate long-read RNA data for training its models. Not related to the older Danish company of the same name."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, status TEXT, founded TEXT, city TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, city_id, founded_date, founded_year, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, s.status::organization_status, 'France',
  (SELECT c.id FROM cities c WHERE c.slug=s.city), s.founded::DATE, EXTRACT(YEAR FROM s.founded::DATE)::INT,
  'techbio_france_october_2026', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"hyprview","stage":"pre_seed","amount_eur":1.4,"currency_original":"EUR","amount_original":1400000,"announced_date":"2025-12-01","closed_date":null,"is_estimated":false,"notes":"€1.4M pre-seed to advance its photonics + AI platform for precision oncology. Announcement date is month-level (December 2025 per Tracxn/VCBacked, which give ~$1.6M). Investors: Jean-Philippe Vert, Franck Le Ouay; a LinkedIn announcement also names Julien Dassault, Stéphane Distinguin, Julie Carnis, Olivier Vaury, John Gridley and Witold Rezner (not linked; single source). Source: company/investor announcement, Crunchbase, VCBacked, Tracxn."},
  {"slug":"parean-biotechnologies","stage":"undisclosed","amount_eur":null,"currency_original":null,"amount_original":null,"announced_date":"2023-11-01","closed_date":"2023-10-25","is_estimated":false,"notes":"First fundraising: capital increase subscribed by private investors, amount undisclosed. Shareholders' decision 2023-08-30, completion recorded 2023-10-25 (legal notice); announced November 2023 (month-level date). Funds European expansion (Switzerland, Germany, Belgium, Netherlands), R&D including an oncology project, and hiring. Investors not disclosed (PitchBook lists Paris Biotech Santé; unconfirmed). Source: Le Journal des Entreprises, Atlanpole Biotherapies, Biotech Santé Bretagne."},
  {"slug":"peaccel","stage":"grant","amount_eur":1.97995,"currency_original":"EUR","amount_original":1979950,"announced_date":"2018-10-08","closed_date":null,"is_estimated":false,"notes":"R&D grant (industrial research, RDI framework scheme SA.40391) from the Conseil régional de La Réunion, aid amount €1,979,950, granted 2018-10-08. Source: EU state-aid transparency register via Pappers. The company separately reports more than $8.7M in cumulative non-dilutive funding (not itemised)."},
  {"slug":"rosetta-omics","stage":"pre_seed","amount_eur":0.35,"currency_original":"EUR","amount_original":350000,"announced_date":"2024-05-01","closed_date":null,"is_estimated":true,"notes":"After two years of founder bootstrapping, raised €350K from angel investors plus a non-dilutive Bpifrance grant (company one-pager, 2025); unclear whether the grant is included in the €350K, so the amount is flagged as estimated. Date from Caplight (May 2024). Other sources differ: Euroquity €300K incl. founders, grant and private investors; Caplight $375K; PitchBook ~$439K angel round. The company is now seeking a €2M–3M pre-seed/seed (not closed). Source: Rosetta Omics one-pager (Business France), Euroquity, Caplight, PitchBook."},
  {"slug":"tychobio","stage":"pre_seed","amount_eur":null,"currency_original":null,"amount_original":null,"announced_date":null,"closed_date":null,"is_estimated":false,"notes":"Pre-seed round, amount and date undisclosed, reported by Crunchbase with Kima Ventures and Tiny Supercomputer Investment Company among investors. Not independently confirmed; may have been raised by the US entity (TychoBio Inc) rather than TYCHOBIO FRANCE. Source: Crunchbase."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, closed_date TEXT, is_estimated BOOLEAN, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, closed_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE, s.closed_date::DATE,
  s.is_estimated, FALSE, 'techbio_france_october_2026', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='techbio_france_october_2026');

-- Step 3: funding round investors
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"hyprview","investor_slug":"jean-philippe-vert","investor_name":"Jean-Philippe Vert","is_lead":false},
  {"slug":"hyprview","investor_slug":"franck-le-ouay","investor_name":"Franck Le Ouay","is_lead":false},
  {"slug":"rosetta-omics","investor_slug":"business-angels","investor_name":"Business Angels","is_lead":false},
  {"slug":"tychobio","investor_slug":"kima-ventures","investor_name":"Kima Ventures","is_lead":false},
  {"slug":"tychobio","investor_slug":"tiny-supercomputer-investment-company","investor_name":"Tiny Supercomputer Investment Company","is_lead":false}
]$json$) AS (slug TEXT, investor_slug TEXT, investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations inv ON inv.slug=s.investor_slug
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='techbio_france_october_2026'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 4a: sector links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ai-biopharma","sec":"techbio"},{"org":"ai-biopharma","sec":"biotech"},{"org":"ai-biopharma","sec":"artificial-intelligence"},
  {"org":"beliver","sec":"techbio"},{"org":"beliver","sec":"biotech"},{"org":"beliver","sec":"artificial-intelligence"},{"org":"beliver","sec":"healthtech"},
  {"org":"da-medlabs","sec":"techbio"},{"org":"da-medlabs","sec":"biotech"},{"org":"da-medlabs","sec":"artificial-intelligence"},
  {"org":"hyprview","sec":"techbio"},{"org":"hyprview","sec":"biotech"},{"org":"hyprview","sec":"artificial-intelligence"},{"org":"hyprview","sec":"healthtech"},{"org":"hyprview","sec":"deeptech"},
  {"org":"insilibio","sec":"techbio"},{"org":"insilibio","sec":"biotech"},
  {"org":"ksilink","sec":"techbio"},{"org":"ksilink","sec":"biotech"},
  {"org":"medinsights","sec":"techbio"},{"org":"medinsights","sec":"biotech"},{"org":"medinsights","sec":"artificial-intelligence"},{"org":"medinsights","sec":"healthtech"},
  {"org":"opsin","sec":"techbio"},{"org":"opsin","sec":"biotech"},{"org":"opsin","sec":"artificial-intelligence"},{"org":"opsin","sec":"saas"},
  {"org":"parean-biotechnologies","sec":"techbio"},{"org":"parean-biotechnologies","sec":"biotech"},{"org":"parean-biotechnologies","sec":"healthtech"},
  {"org":"peaccel","sec":"techbio"},{"org":"peaccel","sec":"biotech"},{"org":"peaccel","sec":"artificial-intelligence"},
  {"org":"rosetta-omics","sec":"techbio"},{"org":"rosetta-omics","sec":"biotech"},{"org":"rosetta-omics","sec":"artificial-intelligence"},{"org":"rosetta-omics","sec":"healthtech"},
  {"org":"tebuna","sec":"techbio"},{"org":"tebuna","sec":"biotech"},
  {"org":"tychobio","sec":"techbio"},{"org":"tychobio","sec":"biotech"},{"org":"tychobio","sec":"artificial-intelligence"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: primary sector (TechBio for all 13) where none exists
UPDATE organization_sectors os SET is_primary=TRUE
FROM organizations o, sectors sec
WHERE o.legacy_source='techbio_france_october_2026' AND o.organization_type='startup' AND sec.slug='techbio'
  AND os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (Bernard Offmann already exists and is reused)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Cyril Dousson","first_name":"Cyril","last_name":"Dousson"},
  {"full_name":"David Dukhan","first_name":"David","last_name":"Dukhan"},
  {"full_name":"Thierry Convard","first_name":"Thierry","last_name":"Convard"},
  {"full_name":"Claire Pierra Rouvière","first_name":"Claire","last_name":"Pierra Rouvière"},
  {"full_name":"Madeleine Moscatelli","first_name":"Madeleine","last_name":"Moscatelli"},
  {"full_name":"Hadrien Mary","first_name":"Hadrien","last_name":"Mary"},
  {"full_name":"Frédéric Saltel","first_name":"Frédéric","last_name":"Saltel"},
  {"full_name":"Anne-Aurélie Raymond","first_name":"Anne-Aurélie","last_name":"Raymond"},
  {"full_name":"Malick Paye","first_name":"Malick","last_name":"Paye"},
  {"full_name":"François Auvray","first_name":"François","last_name":"Auvray"},
  {"full_name":"Victor Outters","first_name":"Victor","last_name":"Outters"},
  {"full_name":"Maxime Jouaud","first_name":"Maxime","last_name":"Jouaud"},
  {"full_name":"Patrick Trouillas","first_name":"Patrick","last_name":"Trouillas"},
  {"full_name":"Antoine de Lacombe","first_name":"Antoine","last_name":"de Lacombe"},
  {"full_name":"Soham Saha","first_name":"Soham","last_name":"Saha"},
  {"full_name":"Sophie Ameloot","first_name":"Sophie","last_name":"Ameloot"},
  {"full_name":"Jules Rainon","first_name":"Jules","last_name":"Rainon"},
  {"full_name":"Lilas Germain","first_name":"Lilas","last_name":"Germain"},
  {"full_name":"Valentin Uzan","first_name":"Valentin","last_name":"Uzan"},
  {"full_name":"Marwan Touati","first_name":"Marwan","last_name":"Touati"},
  {"full_name":"Valentin Quiniou","first_name":"Valentin","last_name":"Quiniou"},
  {"full_name":"Hang-Phuong Pham","first_name":"Hang-Phuong","last_name":"Pham"},
  {"full_name":"Frédéric Cadet","first_name":"Frédéric","last_name":"Cadet"},
  {"full_name":"Bernard Offmann","first_name":"Bernard","last_name":"Offmann"},
  {"full_name":"Wahid Awad","first_name":"Wahid","last_name":"Awad"},
  {"full_name":"Kevin Adam","first_name":"Kevin","last_name":"Adam"},
  {"full_name":"Minyoung Heo","first_name":"Minyoung","last_name":"Heo"},
  {"full_name":"Félix Raimundo","first_name":"Félix","last_name":"Raimundo"},
  {"full_name":"Mathurin Dorel","first_name":"Mathurin","last_name":"Dorel"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'techbio_france_october_2026', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: people links (founders, plus officers whose founder status is unconfirmed)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ai-biopharma","person":"cyril-dousson","role":"Founder","title":"Président","is_founder":true},
  {"org":"ai-biopharma","person":"david-dukhan","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"ai-biopharma","person":"thierry-convard","role":"Directeur Général","title":"Directeur Général","is_founder":false},
  {"org":"ai-biopharma","person":"claire-pierra-rouviere","role":"Directeur Général","title":"Directeur Général","is_founder":false},
  {"org":"beliver","person":"madeleine-moscatelli","role":"Founder","title":"CEO","is_founder":true},
  {"org":"beliver","person":"hadrien-mary","role":"Founder","title":null,"is_founder":true},
  {"org":"beliver","person":"frederic-saltel","role":"Founder","title":null,"is_founder":true},
  {"org":"beliver","person":"anne-aurelie-raymond","role":"Founder","title":null,"is_founder":true},
  {"org":"da-medlabs","person":"malick-paye","role":"Founder","title":"Président","is_founder":true},
  {"org":"hyprview","person":"francois-auvray","role":"Founder","title":"Président","is_founder":true},
  {"org":"hyprview","person":"victor-outters","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"insilibio","person":"maxime-jouaud","role":"Founder","title":"Président","is_founder":true},
  {"org":"insilibio","person":"patrick-trouillas","role":"Founder","title":null,"is_founder":true},
  {"org":"ksilink","person":"antoine-de-lacombe","role":"CEO","title":"CEO","is_founder":false},
  {"org":"medinsights","person":"soham-saha","role":"Founder","title":"Président","is_founder":true},
  {"org":"medinsights","person":"sophie-ameloot","role":"Founder","title":null,"is_founder":true},
  {"org":"opsin","person":"jules-rainon","role":"Founder","title":"Président","is_founder":true},
  {"org":"opsin","person":"lilas-germain","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"opsin","person":"valentin-uzan","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"parean-biotechnologies","person":"marwan-touati","role":"Founder","title":"Président","is_founder":true},
  {"org":"parean-biotechnologies","person":"valentin-quiniou","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"parean-biotechnologies","person":"hang-phuong-pham","role":"Founder","title":"Directeur Général","is_founder":true},
  {"org":"peaccel","person":"frederic-cadet","role":"Founder","title":null,"is_founder":true},
  {"org":"peaccel","person":"bernard-offmann","role":"Founder","title":null,"is_founder":true},
  {"org":"rosetta-omics","person":"wahid-awad","role":"Founder","title":"CEO","is_founder":true},
  {"org":"rosetta-omics","person":"kevin-adam","role":"CSO","title":"CSO","is_founder":false},
  {"org":"tebuna","person":"minyoung-heo","role":"President","title":"Président","is_founder":false},
  {"org":"tychobio","person":"felix-raimundo","role":"Founder","title":"CEO","is_founder":true},
  {"org":"tychobio","person":"mathurin-dorel","role":"CSO","title":"CSO","is_founder":false}
]$json$) AS (org TEXT, person TEXT, role TEXT, title TEXT, is_founder BOOLEAN))
INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, s.role, s.title, TRUE, s.is_founder, 'techbio_france_october_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people p ON p.slug=s.person
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities (all verified in the registry)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ai-biopharma","legal_name":"AI-BIOPHARMA","siren":"838199636","siret":"83819963600013","inc":"2018-02-15","city":"Montpellier","naf":"72.19Z"},
  {"org":"beliver","legal_name":"BELIVER","siren":"941567711","siret":"94156771100010","inc":"2025-02-19","city":"Bordeaux","naf":"72.19Z"},
  {"org":"da-medlabs","legal_name":"D&A MEDLABS","siren":"928114396","siret":"92811439600015","inc":"2024-04-25","city":"Lyon","naf":"70.22Z"},
  {"org":"hyprview","legal_name":"HYPRVIEW","siren":"912839370","siret":"91283937000026","inc":"2022-04-22","city":"Paris","naf":"62.01Z"},
  {"org":"insilibio","legal_name":"INSILIBIO","siren":"850454513","siret":"85045451300019","inc":"2019-04-30","city":"Limoges","naf":"72.11Z"},
  {"org":"ksilink","legal_name":"KSILINK SERVICES SAS","siren":"908717796","siret":"90871779600019","inc":"2021-12-07","city":"Strasbourg","naf":"72.11Z"},
  {"org":"medinsights","legal_name":"MEDINSIGHTS","siren":"918422742","siret":"91842274200026","inc":"2022-08-11","city":"Paris","naf":"62.02A"},
  {"org":"opsin","legal_name":"OPSIN","siren":"108637158","siret":"10863715800016","inc":"2026-08-07","city":"Gif-sur-Yvette","naf":"62.01Z"},
  {"org":"parean-biotechnologies","legal_name":"PAREAN BIOTECHNOLOGIES","siren":"892712118","siret":"89271211800025","inc":"2021-01-07","city":"Saint-Malo","naf":"74.90B"},
  {"org":"peaccel","legal_name":"PEACCEL","siren":"530983352","siret":"53098335200028","inc":"2011-03-05","city":"Saint-Denis (La Réunion)","naf":"72.11Z"},
  {"org":"rosetta-omics","legal_name":"ROSETTA OMICS","siren":"981135361","siret":"98113536100013","inc":"2023-10-30","city":"Paris","naf":"72.19Z"},
  {"org":"tebuna","legal_name":"TEBUNA BIOSCIENCE","siren":"993570498","siret":"99357049800010","inc":"2025-11-05","city":"Nice","naf":"72.11Z"},
  {"org":"tychobio","legal_name":"TYCHOBIO FRANCE","siren":"999724958","siret":"99972495800015","inc":"2025-12-29","city":"Saint-Mandé","naf":"72.11Z"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT, siret TEXT, inc TEXT, city TEXT, naf TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, legal_form, siren, siret, incorporation_date, registered_city, naf_code, country, is_primary, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, 'SAS', s.siren, s.siret, s.inc::DATE, s.city, s.naf, 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), 'techbio_france_october_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Step 8: Ksilink insolvency timeline (Tribunal judiciaire de Strasbourg, RG 26/01535)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"type":"other","date":"2026-06-29","title":"Ksilink Services placed under safeguard procedure","description":"The Strasbourg court opened a safeguard procedure (procédure de sauvegarde) for Ksilink Services SAS. Administrator: SAS Weil-Guyomard-Lutz; creditors' representative: SELARL MJ AIR. BODACC A n°20260127, annonce 5208.","url":"https://www.bodacc.fr"},
  {"type":"other","date":"2026-07-20","title":"Ksilink Services safeguard converted to receivership","description":"The Strasbourg court converted the safeguard procedure into receivership (redressement judiciaire), fixing the date of cessation of payments at 20 July 2026. BODACC A n°20260139, annonce 3292.","url":"https://www.bodacc.fr"},
  {"type":"shutdown","date":"2026-09-28","title":"Ksilink Services placed in judicial liquidation","description":"The Strasbourg court converted the receivership into judicial liquidation (liquidation judiciaire). Liquidator: SELARL MJ AIR (Me Louise Zorgniotti). BODACC A n°20260204, annonce 2557 (rectified notice published 23 October 2026, replacing annonce 3800 of 2 October 2026)."  ,"url":"https://www.bodacc.fr"}
]$json$) AS (type TEXT, date TEXT, title TEXT, description TEXT, url TEXT))
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_name, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.type::event_type, s.date::DATE, s.title, s.description, s.url, 'BODACC', 'techbio_france_october_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug='ksilink'
WHERE NOT EXISTS (SELECT 1 FROM organization_events x WHERE x.organization_id=o.id AND x.event_date=s.date::DATE AND x.title=s.title);

-- Verification
SELECT 'New Orgs (startup)' AS entity, COUNT(*) AS count FROM organizations WHERE legacy_source='techbio_france_october_2026' AND organization_type='startup'
UNION ALL SELECT 'Funding Rounds', COUNT(*) FROM funding_rounds WHERE source_name='techbio_france_october_2026'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='techbio_france_october_2026'
UNION ALL SELECT 'People Links', COUNT(*) FROM organization_people WHERE legacy_source='techbio_france_october_2026'
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE legacy_source='techbio_france_october_2026'
UNION ALL SELECT 'TechBio-tagged (new)', COUNT(*) FROM organization_sectors os JOIN organizations o ON o.id=os.organization_id JOIN sectors s ON s.id=os.sector_id WHERE o.legacy_source='techbio_france_october_2026' AND s.slug='techbio'
UNION ALL SELECT 'Ksilink Events', COUNT(*) FROM organization_events WHERE legacy_source='techbio_france_october_2026';
