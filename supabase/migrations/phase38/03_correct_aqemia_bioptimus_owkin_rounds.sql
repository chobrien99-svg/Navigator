-- =============================================================================
-- Funding-round corrections: Aqemia, Bioptimus, Owkin (source_name 'funding_corrections_november_2026')
-- =============================================================================
-- Corrections supplied by the editor (FTJ), with press sources, after the
-- TechBio-in-France analysis surfaced inconsistencies. Amounts in millions.
-- USD rounds are converted to EUR at the approximate ECB reference rate for
-- the month of announcement; the rate used is stated in each round's notes.
--
-- AQEMIA
--   * Oct 2019 pre-seed: €1.1M -> €1.6M (Elaia).
--   * 2021 round: was 'series_a' €9.0M dated 2021-05-01 -> 'seed', $10.2M
--     (≈€8.4M @1.217), dated January 2021 (month-level; aggregator source).
--   * 2022-10-19 Series A: €20M -> €30M; Eurazeo and Bpifrance Large Venture
--     co-led (BusinessWire, Bpifrance press release).
--   * 2024-01-30: €30M Series A extension (Series A total €60M), led by
--     Wendel Growth with Bpifrance Large Venture, Eurazeo, Elaia (Dentons,
--     BusinessWire). Lead flag moved from Bpifrance to Wendel Growth.
--   * 2024-12-10: was 'series_a' €38M -> 'series_b', $38M (≈€36.2M @1.05)
--     (TechCrunch).
--   * NEW 2025-04-01 grant: France 2030, $7.4M (≈€6.85M @1.08) (BiopharmaTrend).
-- BIOPTIMUS
--   * 2024-02-20 seed: $35M (was stored as €35M) -> ≈€32.4M @1.08.
-- OWKIN (company-reported total $304.1M: seed $2.1M, Series A $72M, Series B $230M)
--   * 2016 seed: €1.91M kept; original currency corrected to USD $2.1M.
--   * NEW 2018-01-16 Series A: $11M (≈€9.0M @1.22), led by Otium Capital;
--     Cathay Innovation, Plug and Play, NJF Capital.
--   * NEW May 2020 Series A extension: $25M (≈€22.9M @1.09), led by Bpifrance
--     Large Venture; MACSF, GV, F-Prime Capital, Eight Roads Ventures.
--   * NEW July 2020 Series A final extension: $18M (≈€15.7M @1.146), co-led by
--     Mubadala (linked to the existing 'Mubadala Capital Ventures' record) and
--     Bpifrance Large Venture.
--     NB: the three tranches total $54M, not the $72M Series A Owkin reports;
--     ~$18M of Series A is unaccounted for and is NOT recorded here.
--   * 2021-11-10 Sanofi: was 'growth' €180M -> 'series_b', $180M (≈€158.7M @1.134).
--   * NEW 2022-06-08 Series B-1: $50M equity (≈€46.7M @1.07), led by Bristol
--     Myers Squibb, part of an $80M package that also included upfront fees for
--     a clinical-trial collaboration (tech.eu, Owkin press release).
-- Month-level dates use the 1st of the month.
-- =============================================================================

-- New investor records
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at) VALUES
  (uuid_generate_v4(), 'Bristol Myers Squibb', 'bristol-myers-squibb', 'corporate'::organization_type, 'active'::organization_status, 'United States', 'funding_corrections_november_2026', NOW(), NOW()),
  (uuid_generate_v4(), 'F-Prime Capital', 'f-prime-capital', 'investor'::organization_type, 'active'::organization_status, 'United States', 'funding_corrections_november_2026', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- ---------------------------------------------------------------- AQEMIA
UPDATE funding_rounds SET amount_eur=1.6, currency_original='EUR', amount_original=1600000,
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: amount €1.6M per FTJ editor.]'), updated_at=NOW()
WHERE id='ad3a7900-b29a-4ba3-af05-625084aa19ca';

UPDATE funding_rounds SET stage='seed', amount_eur=8.38, currency_original='USD', amount_original=10200000, announced_date='2021-01-01',
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: seed round of $10.2M (≈€8.4M at 1.217), January 2021 (month-level; date from aggregator data, no primary release found). Previously recorded as a €9M Series A dated May 2021.]'), updated_at=NOW()
WHERE id='3079c4ff-c985-4906-80cb-5ec560a2eef8';

UPDATE funding_rounds SET amount_eur=30, currency_original='EUR', amount_original=30000000,
  source_url='https://www.businesswire.com/news/home/20221019005005/en/Aqemia-Raises-%E2%82%AC30M-to-Scale-its-Deep-Physics-and-AI-Enabled-Drug-Discovery-Pipeline',
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: €30M Series A co-led by Eurazeo and Bpifrance Large Venture, with Elaia. Sources: BusinessWire, Bpifrance press release.]'), updated_at=NOW()
WHERE id='8e847a88-02cb-400f-a912-680621be8ff0';

UPDATE funding_rounds SET source_url='https://www.businesswire.com/news/home/20240129209892/en/AQEMIA-Boosts-Series-A-Funding-to-%E2%82%AC60M-to-Accelerate-on-its-Proprietary-Therapeutic-Pipeline',
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: €30M extension of the Series A, bringing the Series A to €60M. Led by Wendel Growth with Bpifrance Large Venture, Eurazeo and Elaia. Sources: Dentons, BusinessWire.]'), updated_at=NOW()
WHERE id='dc9e01e7-f661-48e1-b239-7bc72bae91e7';

UPDATE funding_rounds SET stage='series_b', amount_eur=36.19, currency_original='USD', amount_original=38000000,
  source_url='https://techcrunch.com/2024/12/10/aqemia-raises-38m-to-find-new-drugs-by-meshing-theoretical-physics-with-genai/',
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: $38M (≈€36.2M at 1.05), classified as Series B. Previously stored as €38M Series A. Source: TechCrunch.]'), updated_at=NOW()
WHERE id='3f57f4c6-b4d3-40e1-a875-ceb95ffbc451';

-- Aqemia lead flags: Oct 2022 co-led by Eurazeo + Bpifrance (Large Venture); Jan 2024 led by Wendel Growth
UPDATE funding_round_investors fri SET is_lead=TRUE
FROM organizations i WHERE fri.investor_id=i.id AND fri.funding_round_id='8e847a88-02cb-400f-a912-680621be8ff0' AND i.slug='eurazeo';
UPDATE funding_round_investors fri SET is_lead=(i.slug='wendel-growth')
FROM organizations i WHERE fri.investor_id=i.id AND fri.funding_round_id='dc9e01e7-f661-48e1-b239-7bc72bae91e7';

-- Aqemia France 2030 grant
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, source_url, notes, created_at)
SELECT uuid_generate_v4(), o.id, 'grant'::funding_stage, 6.85, 'USD', 7400000, '2025-04-01', FALSE, FALSE, 'funding_corrections_november_2026',
  'https://www.biopharmatrend.com/news/aqemia-secures-74m-to-expand-rna-targeting-programs-with-physics-based-generative-ai-1186/',
  'France 2030 grant of $7.4M (≈€6.85M at 1.08) to expand RNA-targeting programmes using physics-based generative AI. Source: BiopharmaTrend.', NOW()
FROM organizations o WHERE o.slug='aqemia'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.stage='grant' AND x.announced_date='2025-04-01');

-- ---------------------------------------------------------------- BIOPTIMUS
UPDATE funding_rounds SET amount_eur=32.41, currency_original='USD', amount_original=35000000,
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: $35M seed (≈€32.4M at 1.08); previously stored as €35M.]'), updated_at=NOW()
WHERE id='99b06d7e-b29c-4442-9af1-f7b9ac5d6c6e';

-- ---------------------------------------------------------------- OWKIN
UPDATE funding_rounds SET currency_original='USD', amount_original=2100000,
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: original amount $2.1M per Owkin.]'), updated_at=NOW()
WHERE id='1b16c22e-71d2-49c1-8b0c-d5c3096d85f3';

UPDATE funding_rounds SET stage='series_b', amount_eur=158.73, currency_original='USD', amount_original=180000000,
  notes=concat_ws(' ', notes, '[Corrected Nov 2026: $180M (≈€158.7M at 1.134) equity investment by Sanofi, first tranche of Owkin''s $230M Series B, signed alongside a multi-year oncology collaboration. Previously stored as a €180M growth round.]'), updated_at=NOW()
WHERE id='0b9d1229-4b63-42d0-97d2-358833b460fa';

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"key":"owkin-a1","stage":"series_a","eur":9.02,"usd":11000000,"date":"2018-01-16","url":"https://www.cathaycapital.com/owkin-closes-11-million-series-a-financing-round/","notes":"$11M Series A (≈€9.0M at 1.22) led by Otium Capital, with Cathay Innovation, Plug and Play and NJF Capital, to launch the OWKIN Socrates machine-learning platform. Sources: Cathay Capital, WSJ."},
  {"key":"owkin-a2","stage":"series_a","eur":22.94,"usd":25000000,"date":"2020-05-01","url":null,"notes":"$25M Series A extension (≈€22.9M at 1.09) led by Bpifrance Large Venture, with MACSF, GV, F-Prime Capital and Eight Roads Ventures, to advance federated-learning technology. Date is month-level. Source: Owkin / multiples.vc."},
  {"key":"owkin-a3","stage":"series_a","eur":15.71,"usd":18000000,"date":"2020-07-01","url":"https://www.actuia.com/en/news/medical-research-owkin-closes-series-a-with-70-million-raised/","notes":"$18M final Series A extension (≈€15.7M at 1.146) co-led by Mubadala and Bpifrance, closing a Series A Owkin reports at ~$70–72M; to expand into new geographies (Germany, Middle East). Date is month-level. The three recorded Series A tranches total $54M; the remaining ~$18M is not itemised. Sources: ActuIA, multiples.vc."},
  {"key":"owkin-b1","stage":"series_b","eur":46.73,"usd":50000000,"date":"2022-06-08","url":"https://tech.eu/2022/06/08/french-ai-biotech-startup-owkin-gets-an-80-million-shot-to-accelerate-drug-discovery/","notes":"Series B-1 equity investment of $50M (≈€46.7M at 1.07) led by Bristol Myers Squibb, completing Owkin's $230M Series B. Part of an $80M package combining the equity investment and upfront fees for a cardiovascular clinical-trial collaboration, with potential milestones above $100M. Sources: tech.eu, Owkin press release."}
]$json$) AS (key TEXT, stage TEXT, eur NUMERIC, usd NUMERIC, date TEXT, url TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, source_url, legacy_id, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.eur, 'USD', s.usd, s.date::DATE, FALSE, FALSE, 'funding_corrections_november_2026', s.url, s.key, s.notes, NOW()
FROM source s JOIN organizations o ON o.slug='owkin'
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.legacy_id=s.key);

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"key":"owkin-a1","inv":"otium-capital","name":"Otium Capital","lead":true},
  {"key":"owkin-a1","inv":"cathay-innovation","name":"Cathay Innovation","lead":false},
  {"key":"owkin-a1","inv":"plug-and-play","name":"Plug and Play","lead":false},
  {"key":"owkin-a1","inv":"njf-capital","name":"NJF Capital","lead":false},
  {"key":"owkin-a2","inv":"bpifrance-large-venture","name":"Bpifrance Large Venture","lead":true},
  {"key":"owkin-a2","inv":"macsf","name":"MACSF","lead":false},
  {"key":"owkin-a2","inv":"gv-google-ventures","name":"GV (Google Ventures)","lead":false},
  {"key":"owkin-a2","inv":"f-prime-capital","name":"F-Prime Capital","lead":false},
  {"key":"owkin-a2","inv":"eight-roads-ventures","name":"Eight Roads Ventures","lead":false},
  {"key":"owkin-a3","inv":"mubadala-capital-ventures","name":"Mubadala Capital","lead":true},
  {"key":"owkin-a3","inv":"bpifrance-large-venture","name":"Bpifrance Large Venture","lead":true},
  {"key":"owkin-b1","inv":"bristol-myers-squibb","name":"Bristol Myers Squibb","lead":true}
]$json$) AS (key TEXT, inv TEXT, name TEXT, lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.lead, s.name, NOW()
FROM source s JOIN funding_rounds fr ON fr.legacy_id=s.key AND fr.source_name='funding_corrections_november_2026'
JOIN organizations i ON i.slug=s.inv
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, FALSE, 'France 2030', NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id AND o.slug='aqemia'
JOIN organizations i ON i.slug='france-2030'
WHERE fr.source_name='funding_corrections_november_2026' AND fr.stage='grant'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Verification
SELECT o.slug, fr.announced_date, fr.stage, fr.amount_eur, fr.currency_original, fr.amount_original,
  (SELECT string_agg((CASE WHEN fri.is_lead THEN '*' ELSE '' END)||fri.investor_name, ', ') FROM funding_round_investors fri WHERE fri.funding_round_id=fr.id) investors
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id
WHERE o.slug IN ('aqemia','bioptimus','owkin') ORDER BY o.slug, fr.announced_date;
