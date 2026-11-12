-- =============================================================================
-- NVIDIA in France (12 Nov 2026)
-- =============================================================================
-- legacy_source 'nvidia_france_november_2026'. See data/nvidia_france_2026/.
-- * NVIDIA and NVentures profiles: descriptions, website; NVentures linked as
--   NVIDIA's venture arm. Organisation type and country left at the database's
--   investor convention ('investor', 'France').
-- * NVIDIA's French legal entities (company register):
--   NVIDIA Développement France SAS, SIREN 479973455 (R&D, Biot/Sophia
--   Antipolis, created 2 Dec 2004); NVIDIA Ltd French branch, SIREN 432108355.
-- * Stakes announced 13 Oct 2026 (NVIDIA blog; Reuters; Le Monde Informatique;
--   Tech.eu): Doctolib (minority stake, confirmed by Doctolib), Entalpic
--   (planned), Genesis AI (planned strategic investment). Amounts undisclosed.
-- * Hugging Face: NVIDIA agreed to acquire it, announced 3 Sep 2026 (~$12.9bn
--   per press; closing expected H1 2027, subject to regulatory approval).
-- * Leadership: Jensen Huang stepped down as CEO and director on 12 Nov 2026
--   (NVIDIA Form 8-K); CFO Colette Kress interim CEO; Harvey C. Jones chair.
-- * Duplicate programme "NVIDIA Inception" merged into "NVIDIA Inception
--   Program" (Percisio membership moved; empty duplicate edition and programme
--   deleted).
-- =============================================================================
BEGIN;

-- NVIDIA / NVentures profiles
UPDATE organizations SET name='NVIDIA', website=coalesce(website,'https://www.nvidia.com'),
  description=coalesce(description,'US maker of GPUs and AI computing platforms (Santa Clara). In France: R&D subsidiary NVIDIA Développement France SAS at Sophia Antipolis and a sales branch of NVIDIA Ltd (Courbevoie). Invests directly and through its venture arm NVentures.'),
  short_description=coalesce(short_description,'US AI computing company; investor in French AI, quantum and deep-tech start-ups.'),
  legacy_source=coalesce(legacy_source,'nvidia_france_november_2026'), updated_at=NOW()
WHERE slug='nvidia';
UPDATE organizations SET website=coalesce(website,'https://www.nvidia.com/en-us/about-nvidia/nventures/'),
  description=coalesce(description,'Venture capital arm of NVIDIA.'), updated_at=NOW()
WHERE slug='nventures';
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'subsidiary_of'::relationship_type, 'NVentures is NVIDIA''s venture capital arm.', 'company_website', 'NVIDIA', 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations a JOIN organizations b ON b.slug='nvidia' WHERE a.slug='nventures'
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='subsidiary_of');

-- French legal entities
INSERT INTO legal_entities (id, organization_id, legal_name, legal_form, siren, incorporation_date, registered_city, naf_code, naf_label, country, is_primary, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.n, s.f, s.siren, s.d::date, s.c, s.naf, s.lab, 'France', FALSE, 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations o, (VALUES
 ('NVIDIA DEVELOPPEMENT FRANCE','SAS','479973455','2004-12-02','BIOT','72.19Z','Recherche-développement en autres sciences physiques et naturelles'),
 ('NVIDIA LTD (succursale française)','Société commerciale étrangère','432108355',NULL,NULL,'46.52Z','Commerce de gros de composants et d''équipements électroniques et de télécommunication')) s(n,f,siren,d,c,naf,lab)
WHERE o.slug='nvidia' AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren=s.siren);

-- October 2026 stakes
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, announced_date, is_estimated, source_url, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'undisclosed'::funding_stage, NULL, '2026-10-13', FALSE, s.u, s.sn, s.notes, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('doctolib','https://www.lemondeinformatique.fr/actualites/lire-nvidia-investit-dans-doctolib-et-trois-entreprises-francaises-de-l-ia-100852.html','Le Monde Informatique / Reuters / NVIDIA blog','NVIDIA minority stake announced by Jensen Huang in Paris on 13 Oct 2026 and confirmed by Doctolib. Amount, terms and whether new or existing shares not disclosed; no board seat reported.'),
 ('entalpic','https://tech.eu/2026/10/14/nvidia-invests-in-four-french-tech-companies-makes-ps250m-uk-compute-donation/','Tech.eu / NVIDIA blog','Planned NVIDIA minority investment announced 13 Oct 2026 (NVIDIA blog). Amount undisclosed; Entalpic had not confirmed to Reuters at the time.'),
 ('genesis-ai','https://live.euronext.com/en/financial-news/nvidia-buys-stakes-french-tech-startups-doctolib-genesis-ai','Reuters','Planned NVIDIA strategic investment announced 13 Oct 2026; Genesis AI said NVIDIA is a strategic investor. Amount undisclosed.')) s(slug,u,sn,notes)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.announced_date='2026-10-13' AND x.legacy_source='nvidia_france_november_2026');
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), r.id, n.id, TRUE, 'NVIDIA', NOW()
FROM funding_rounds r JOIN organizations n ON n.slug='nvidia'
WHERE r.legacy_source='nvidia_france_november_2026' AND r.announced_date='2026-10-13'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=r.id AND x.investor_id=n.id);
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), n.id, o.id, 'invested_in'::relationship_type, s.d, '2026-10-13', 'press', s.sn, s.u, 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('doctolib','Minority stake (announced 13 Oct 2026).','Le Monde Informatique / Reuters','https://www.lemondeinformatique.fr/actualites/lire-nvidia-investit-dans-doctolib-et-trois-entreprises-francaises-de-l-ia-100852.html'),
 ('entalpic','Planned minority stake (announced 13 Oct 2026).','Tech.eu / NVIDIA blog','https://tech.eu/2026/10/14/nvidia-invests-in-four-french-tech-companies-makes-ps250m-uk-compute-donation/'),
 ('genesis-ai','Planned strategic investment (announced 13 Oct 2026).','Reuters','https://live.euronext.com/en/financial-news/nvidia-buys-stakes-french-tech-startups-doctolib-genesis-ai')) s(slug,d,sn,u)
JOIN organizations o ON o.slug=s.slug JOIN organizations n ON n.slug='nvidia'
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=n.id AND x.target_org_id=o.id AND x.relationship_type='invested_in');

-- Hugging Face acquisition agreement
UPDATE organizations SET website=coalesce(website,'https://huggingface.co'),
  description=coalesce(description,'Open-source AI model and dataset platform founded by French entrepreneurs (Clément Delangue, Julien Chaumond, Thomas Wolf), headquartered in New York with a large Paris team. NVIDIA agreed to acquire it in September 2026 (pending regulatory approval).'),
  updated_at=NOW()
WHERE slug='hugging-face';
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), n.id, h.id, 'acquired'::relationship_type, 'Acquisition agreement announced 3 Sep 2026, about $12.9bn (≈$11.9bn to holders plus ≈$1bn retention equity, per filing as reported). Closing expected H1 2027, subject to regulatory approval.', '2026-09-03', 'press', 'SiliconANGLE / Euronews', 'https://siliconangle.com/2026/09/03/nvidia-confirms-12-9b-acquisition-of-ai-hosting-platform-hugging-face/', 'medium', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations n JOIN organizations h ON h.slug='hugging-face' WHERE n.slug='nvidia'
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=n.id AND x.target_org_id=h.id AND x.relationship_type='acquired');
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.t::event_type, s.d::date, s.ti, s.de, s.u, s.st, s.sn, s.v, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('hugging-face','acquisition','2026-09-03','NVIDIA agrees to acquire Hugging Face','NVIDIA confirmed an agreement to acquire Hugging Face for about $12.9bn. Closing expected in the first half of 2027, subject to regulatory approval.','https://siliconangle.com/2026/09/03/nvidia-confirms-12-9b-acquisition-of-ai-hosting-platform-hugging-face/','press','SiliconANGLE / Euronews','medium'),
 ('nvidia','acquisition','2026-09-03','NVIDIA agrees to acquire Hugging Face','Agreement to acquire the French-founded AI platform Hugging Face for about $12.9bn; closing expected H1 2027, subject to regulatory approval.','https://siliconangle.com/2026/09/03/nvidia-confirms-12-9b-acquisition-of-ai-hosting-platform-hugging-face/','press','SiliconANGLE / Euronews','medium'),
 ('nvidia','leadership_change','2026-11-12','Jensen Huang steps down as NVIDIA CEO','Jensen Huang stepped down with immediate effect as CEO and as a member of the board. CFO Colette Kress was appointed interim CEO and Harvey C. Jones became chair of the board.','https://www.sec.gov/Archives/edgar/data/0001045810/000104581026000082/nvidiaannouncesceotransiti.htm','regulatory_filing','NVIDIA Form 8-K','high')) s(slug,t,d,ti,de,u,st,sn,v)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM organization_events e WHERE e.organization_id=o.id AND e.title=s.ti);

-- Merge duplicate NVIDIA Inception programme
UPDATE program_organizations SET program_edition_id='0c0da62b-1c39-459e-b4dd-0351d83fb3a0', updated_at=NOW()
WHERE program_edition_id='1acb7910-36ba-4e31-8cf5-0cf5d91eef73'
  AND organization_id NOT IN (SELECT organization_id FROM program_organizations WHERE program_edition_id='0c0da62b-1c39-459e-b4dd-0351d83fb3a0');
DELETE FROM program_organizations WHERE program_edition_id='1acb7910-36ba-4e31-8cf5-0cf5d91eef73';
DELETE FROM program_editions WHERE id='1acb7910-36ba-4e31-8cf5-0cf5d91eef73';
DELETE FROM programs WHERE id='0b9ad009-0f90-4cfa-a186-3df70b037b37';
UPDATE programs SET host_organization_id=(SELECT id FROM organizations WHERE slug='nvidia'),
  operator_organization_id=coalesce(operator_organization_id,(SELECT id FROM organizations WHERE slug='nvidia')),
  description=coalesce(description,'NVIDIA''s free programme for AI and data-science start-ups (technical resources, training, cloud credits, investor exposure). NVIDIA says more than 700 French companies are members (VivaTech 2026).'),
  source_url=coalesce(source_url,'https://www.nvidia.com/en-us/startups/'), updated_at=NOW()
WHERE id='92a3cc19-06b8-4e18-b692-5fd52a964df5';

COMMIT;
