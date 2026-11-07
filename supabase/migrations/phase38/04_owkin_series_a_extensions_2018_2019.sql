-- =============================================================================
-- Owkin: Series A extensions 2018–2019 (residual) + June 2020 date fix
-- =============================================================================
-- source_name 'funding_corrections_november_2026'. Editor-approved (FTJ).
--
-- Owkin's own figures are taken as canon: seed $2.1M, Series A $72M,
-- Series B $230M. Recorded Series A tranches before this file: $11M (Jan
-- 2018) + $25M (May 2020) + $18M (Jun 2020) = $54M, leaving $18M unrecorded.
-- That gap is most likely two undisclosed additions:
--   * May 2018: GV joins the Series A (amount undisclosed; VentureBeat
--     estimated ~$5M; press said Owkin had raised "$18M to date").
--   * March 2019: addition led by F-Prime Capital and Eight Roads Ventures
--     (multiples.vc), amount undisclosed.
-- Recorded here as ONE residual entry of $18M (≈€15.3M at 1.18), dated May
-- 2018 (month-level), flagged is_estimated, with GV, F-Prime Capital and
-- Eight Roads Ventures as participants (no lead flagged).
--
-- Also: the Mubadala/Bpifrance $18M extension is dated 30 June 2020
-- (tech.eu, Crunchbase News), not July 2020.
-- =============================================================================

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, source_url, legacy_id, notes, created_at)
SELECT uuid_generate_v4(), o.id, 'series_a'::funding_stage, 15.25, 'USD', 18000000, '2018-05-01', TRUE, FALSE,
  'funding_corrections_november_2026', 'https://venturebeat.com/2018/05/23/gv-invests-in-medical-machine-learning-startup-owkin', 'owkin-a1b',
  'Series A extensions 2018–2019, recorded as one residual entry: $18M (≈€15.3M at 1.18) = Owkin''s stated $72M Series A minus the $54M in itemised tranches. Most likely covers GV joining the Series A in May 2018 (amount undisclosed, est. ~$5M by VentureBeat; press reported "$18M raised to date") and a March 2019 addition led by F-Prime Capital and Eight Roads Ventures (multiples.vc). Split between the two is unknown; date is month-level (first tranche). Sources: Owkin website, VentureBeat, FinSMEs, Maddyness, multiples.vc.', NOW()
FROM organizations o WHERE o.slug='owkin'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.legacy_id='owkin-a1b');

INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, FALSE, i.name, NOW()
FROM funding_rounds fr JOIN organizations i ON i.slug IN ('gv-google-ventures','f-prime-capital','eight-roads-ventures')
WHERE fr.legacy_id='owkin-a1b' AND fr.source_name='funding_corrections_november_2026'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

UPDATE funding_rounds SET announced_date='2020-06-30', source_url='https://tech.eu/2020/06/30/owkin-series-a-2/',
  notes=replace(notes, 'Date is month-level.', 'Announced 30 June 2020 (tech.eu, Crunchbase News).'), updated_at=NOW()
WHERE legacy_id='owkin-a3' AND source_name='funding_corrections_november_2026';

-- Verification: Owkin totals by stage in USD should read seed 2.1 / series_a 72 / series_b 230
SELECT fr.stage, count(*) n, sum(fr.amount_original)/1e6 usd_m, sum(fr.amount_eur) eur_m
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id WHERE o.slug='owkin' GROUP BY fr.stage ORDER BY 1;
