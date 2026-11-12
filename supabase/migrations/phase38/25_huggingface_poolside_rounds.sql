-- =============================================================================
-- Hugging Face Series D (Aug 2023) and Poolside (company + Series B, Oct 2024)
-- =============================================================================
-- legacy_source 'nvidia_france_november_2026'.
-- HUGGING FACE: $235M Series D announced 24 Aug 2023 at $4.5bn valuation, led
--   by Salesforce Ventures with Google, Amazon, NVIDIA, AMD, Intel, Qualcomm
--   Ventures, IBM and Sound Ventures (TechCrunch; CEO's announcement). €217M
--   as reported by Silicon Canals; valuation ≈€4.15bn.
-- POOLSIDE: AI coding-model company; French entity POOLSIDE AI, SIREN
--   977666437, Paris, registered 10 Jul 2023 (directors Eiso Kant, Jason
--   Warner). $500M Series B announced 2 Oct 2024 at ~$3bn, led by Bain
--   Capital Ventures with eBay Ventures, DST Global, StepStone, NVIDIA, Citi
--   Ventures and HSBC Ventures (TechCrunch, Crunchbase News, Sifted). ≈€453M.
--   Earlier rounds not loaded (sources conflict on seed lead and dates).
--   Bloomberg (Oct 2025) reported NVIDIA planned to invest up to $1bn in a
--   ~$2bn round at $12bn; not confirmed as closed, so noted only.
-- =============================================================================
BEGIN;

-- New investor organisations
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.n, s.slug, 'investor'::organization_type, 'active'::organization_status, 'France', 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES ('Google','google'),('Intel','intel'),('IBM','ibm'),('Qualcomm Ventures','qualcomm-ventures'),('Sound Ventures','sound-ventures'),('eBay Ventures','ebay-ventures'),('StepStone Group','stepstone-group')) s(n,slug)
WHERE NOT EXISTS (SELECT 1 FROM organizations o WHERE o.slug=s.slug);

-- Poolside
INSERT INTO organizations (id, name, slug, organization_type, description, short_description, website, status, country, city_id, founded_date, founded_year, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'Poolside', 'poolside', 'startup'::organization_type,
 'Builds foundation models for software development (AI coding). Co-founded in 2023 by Jason Warner (former GitHub CTO) and Eiso Kant; French entity POOLSIDE AI registered in Paris in July 2023.',
 'AI models for software development.', 'https://poolside.ai', 'active'::organization_status, 'France',
 (SELECT id FROM cities WHERE slug='paris'), '2023-07-10', 2023, 'nvidia_france_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE slug='poolside');
INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, registered_city, naf_code, country, is_primary, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'POOLSIDE AI', '977666437', '2023-07-10', 'PARIS', '63.11Z', 'France', TRUE, 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='poolside' AND NOT EXISTS (SELECT 1 FROM legal_entities WHERE siren='977666437');

-- Rounds
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, amount_usd, currency_original, amount_original, announced_date, is_estimated, valuation_eur, source_url, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.st::funding_stage, s.eur, s.usd, 'USD', s.orig, s.d::date, s.est, s.val, s.u, s.sn, s.notes, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('hugging-face','series_d',217,235,235000000,'2023-08-24',FALSE,4150,'https://techcrunch.com/2023/08/24/hugging-face-raises-235m-from-investors-including-salesforce-and-nvidia','TechCrunch / Silicon Canals','$235M at a $4.5bn valuation (≈€4.15bn), led by Salesforce Ventures. Investor list per CEO Clément Delangue''s announcement.'),
 ('poolside','series_b',453,500,500000000,'2024-10-02',TRUE,2720,'https://techcrunch.com/2024/10/02/ai-coding-startup-poolside-raises-500m-from-ebay-nvidia-and-others','TechCrunch / Crunchbase News / Sifted','$500M at about $3bn valuation, led by Bain Capital Ventures; euro amounts converted. Funds to bring 10,000 NVIDIA GPUs online. Bloomberg reported in Oct 2025 that NVIDIA planned to invest up to $1bn in a ~$2bn round at $12bn; not confirmed as closed.')) s(slug,st,eur,usd,orig,d,est,val,u,sn,notes)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.announced_date=s.d::date AND x.stage=s.st::funding_stage);
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), r.id, i.id, s.lead, s.nm, NOW()
FROM (VALUES
 ('hugging-face','2023-08-24','salesforce-ventures','Salesforce Ventures',TRUE),
 ('hugging-face','2023-08-24','google','Google',FALSE),
 ('hugging-face','2023-08-24','amazon','Amazon',FALSE),
 ('hugging-face','2023-08-24','nvidia','NVIDIA',FALSE),
 ('hugging-face','2023-08-24','amd','AMD',FALSE),
 ('hugging-face','2023-08-24','intel','Intel',FALSE),
 ('hugging-face','2023-08-24','qualcomm-ventures','Qualcomm Ventures',FALSE),
 ('hugging-face','2023-08-24','ibm','IBM',FALSE),
 ('hugging-face','2023-08-24','sound-ventures','Sound Ventures',FALSE),
 ('poolside','2024-10-02','bain-capital-ventures','Bain Capital Ventures',TRUE),
 ('poolside','2024-10-02','ebay-ventures','eBay Ventures',FALSE),
 ('poolside','2024-10-02','dst-global','DST Global',FALSE),
 ('poolside','2024-10-02','stepstone-group','StepStone Group',FALSE),
 ('poolside','2024-10-02','nvidia','NVIDIA',FALSE),
 ('poolside','2024-10-02','citi-ventures','Citi Ventures',FALSE),
 ('poolside','2024-10-02','hsbc','HSBC Ventures',FALSE)) s(org,d,inv,nm,lead)
JOIN organizations o ON o.slug=s.org
JOIN funding_rounds r ON r.organization_id=o.id AND r.announced_date=s.d::date AND r.legacy_source='nvidia_france_november_2026'
JOIN organizations i ON i.slug=s.inv
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=r.id AND x.investor_id=i.id);

-- NVIDIA links
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), n.id, o.id, 'invested_in'::relationship_type, s.de, s.d::date, 'press', s.sn, s.u, 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('hugging-face','Participant in the $235M Series D (Aug 2023).','2023-08-24','TechCrunch','https://techcrunch.com/2023/08/24/hugging-face-raises-235m-from-investors-including-salesforce-and-nvidia'),
 ('poolside','Participant in the $500M Series B (Oct 2024).','2024-10-02','TechCrunch','https://techcrunch.com/2024/10/02/ai-coding-startup-poolside-raises-500m-from-ebay-nvidia-and-others')) s(slug,de,d,sn,u)
JOIN organizations o ON o.slug=s.slug JOIN organizations n ON n.slug='nvidia'
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=n.id AND x.target_org_id=o.id AND x.relationship_type='invested_in');

COMMIT;
