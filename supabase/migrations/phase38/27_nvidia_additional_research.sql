-- =============================================================================
-- NVIDIA in France: items from the editor's additional research (12 Nov 2026)
-- =============================================================================
-- legacy_source 'nvidia_france_november_2026'. Sources were read from the
-- original pages (saved in data/nvidia_france_2026/sources/additional_research_2026-11-12/),
-- except C2I2 (univ-reims.eu blocked automated access; confirmed via the
-- university's page as indexed and a 2015 URCA release) and Wayve/Stellantis
-- (media.stellantis.com blocked; confirmed via The Next Web, Unite.AI and others).
-- * URCA: first French NVIDIA CUDA Research Center; GPU Computing Application
--   Lab at ROMEO announced 20 Mar 2015 (funded by the region and Reims
--   Métropole). C2I2 chair 1 Jan 2017 - 2020, partners CEA DAM IDF, Bull, NVIDIA.
-- * Fondation Inria open-source AI adoption working group, 13 Oct 2026: NVIDIA
--   among principal contributors and founding members.
-- * AI Factory France (GENCI): NVIDIA Inception/Connect collaboration announced
--   25 Nov 2025 (Adopt AI Summit); NVIDIA joins AI2F advisory committee;
--   operational at VivaTech June 2026; early users Pleias, Ryax (Nebula not
--   linked: identity of the GENCI-cited "Nebula" with the database record unconfirmed).
-- * ConcordAI (GENCI + Bristol Centre for Supercomputing), 21 Oct 2026, NVIDIA
--   technical support.
-- * Valeo / NVIDIA Hyperion, 21 Oct 2026. Wayve, Stellantis and NVIDIA with the
--   French government, ~23 Oct 2026. Omi / NVIDIA technology partnership,
--   21 Oct 2026 (Maddyness).
-- =============================================================================
BEGIN;

-- New organisations
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, city_id, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.n, s.slug, s.t::organization_type, s.d, s.w, 'active'::organization_status, s.c, (SELECT id FROM cities WHERE slug=s.city), 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('Université de Reims Champagne-Ardenne','universite-de-reims-champagne-ardenne','university','Public university in Reims (URCA); runs the ROMEO regional HPC centre. First French university named an NVIDIA CUDA Research Center.','https://www.univ-reims.fr','France','reims'),
 ('GENCI','genci','public_agency','Grand équipement national de calcul intensif: France''s national agency for high-performance computing; owns the Jean Zay, Adastra and Joliot-Curie supercomputers and leads AI Factory France.','https://www.genci.fr','France','paris'),
 ('Bull','bull','corporate','French computing manufacturer (formerly part of Atos/Eviden); builds BullSequana supercomputers and AI servers.','https://www.bull.com','France',NULL),
 ('Fondation Inria','fondation-inria','nonprofit','Foundation supporting Inria''s research and digital commons (Software Heritage, OCaml).','https://www.fondation-inria.fr','France','paris'),
 ('Valeo','valeo','corporate','French automotive supplier.','https://www.valeo.com','France','paris'),
 ('Stellantis','stellantis','corporate','Carmaker formed from PSA and FCA.','https://www.stellantis.com','France',NULL),
 ('Wayve','wayve','startup','UK developer of AI driving software ("AI Driver").','https://wayve.ai','United Kingdom',NULL),
 ('Bristol Centre for Supercomputing','bristol-centre-for-supercomputing','research_lab','University of Bristol centre operating the UK''s Isambard-AI supercomputer.','https://www.bristol.ac.uk','United Kingdom',NULL)) s(n,slug,t,d,w,c,city)
WHERE NOT EXISTS (SELECT 1 FROM organizations o WHERE o.slug=s.slug);

UPDATE organizations SET description='Paris start-up (founded 2020 by Hugo and Paul Borensztein) that creates product photos and videos for brands from 3D digital twins using AI; about 55 staff in Paris and New York; serves 1,000+ brands including L''Oréal, Nestlé, Estée Lauder and Shiseido.', website=coalesce(website,'https://omi.so'), updated_at=NOW()
WHERE slug='omi' AND (description IS NULL OR description LIKE 'Omi operates in sectors%');

-- Relationships with NVIDIA
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, end_date, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.de, s.sd::date, s.ed::date, s.st, s.sn, s.u, s.v, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('universite-de-reims-champagne-ardenne','nvidia','partnered_with','First French university named an NVIDIA CUDA Research Center; GPU Computing Application Lab at ROMEO announced March 2015 (lab funded by the region and Reims Métropole).','2015-03-20',NULL,'university','URCA / ROMEO','https://romeo.univ-reims.fr/18_actualites.html/165/The_University_of_Reims_Champagne-Ardenne_Announces_GPU_Computing_Application_Lab','high'),
 ('nvidia','universite-de-reims-champagne-ardenne','partnered_with','Industrial partner, with CEA DAM and Bull, of the C2I2 chair in supercomputing and industry (chairholder Michaël Krajecki), Jan 2017 for four years. Contribution not disclosed.','2017-01-01','2020-12-31','university','URCA','https://www.univ-reims.eu/research-at-urca/chairs/c2i2/c2i2-supercomputing-and-industry-industrial-chair,23654,39159.html','high'),
 ('nvidia','fondation-inria','partnered_with','Founding member and among the principal contributors of the working group on open-source AI adoption (launched 13 Oct 2026; findings spring 2027). Contribution not disclosed.','2026-10-13',NULL,'press_release','Fondation Inria','https://www.fondation-inria.fr/adoption-de-lia-open-source-la-fondation-inria-lance-un-groupe-de-travail/','high'),
 ('genci','nvidia','partnered_with','AI Factory France collaboration with NVIDIA Inception and NVIDIA Connect (announced 25 Nov 2025); NVIDIA sits on AI2F''s scientific and industrial advisory committee. NVIDIA also gave technical support to the ConcordAI UK-France federated AI project (Oct 2026).','2025-11-25',NULL,'press_release','GENCI','https://www.genci.fr/actualites/fast-track-success-ai-factory-france-supercharges-ai-adoption-french-startups-and-smes','high'),
 ('valeo','nvidia','partnered_with','Will develop and industrialise automotive high-performance compute platforms on the NVIDIA Hyperion architecture (DRIVE AGX Thor, Halos) for Level 4 driving.','2026-10-21',NULL,'press_release','Valeo','https://www.valeo.com/en/valeo-builds-next-generation-high-performance-compute-platforms-built-on-nvidia-hyperion/','high'),
 ('stellantis','nvidia','partnered_with','With Wayve and NVIDIA, joined the French government on deploying autonomous vehicles in France (Assises du Véhicule Autonome); Stellantis supplies L4-ready platforms, NVIDIA Hyperion compute. No launch date set.','2026-10-23',NULL,'press','The Next Web / Unite.AI','https://thenextweb.com/news/wayve-stellantis-nvidia-france-self-driving','medium'),
 ('wayve','nvidia','partnered_with','Wayve AI Driver on NVIDIA Hyperion and Halos, in the Wayve-Stellantis-NVIDIA autonomous-vehicle collaboration with the French government.','2026-10-23',NULL,'press','The Next Web / Unite.AI','https://thenextweb.com/news/wayve-stellantis-nvidia-france-self-driving','medium'),
 ('wayve','stellantis','partnered_with','Technology partnership to bring Wayve''s AI Driver into Stellantis vehicles from 2028 (May 2026); joint French AV deployment with NVIDIA (Oct 2026).','2026-05-01',NULL,'press','The Next Web','https://thenextweb.com/news/wayve-stellantis-nvidia-france-self-driving','medium'),
 ('omi','nvidia','partnered_with','Technology partnership: NVIDIA RTX PRO 6000 Blackwell GPUs plus NVIDIA engineers to speed image generation (not an investment).','2026-10-21',NULL,'press','Maddyness','https://www.maddyness.com/uk/2026/10/21/nvidia-partners-with-french-startup-omi/','high'),
 ('genci','bristol-centre-for-supercomputing','partnered_with','ConcordAI: linking Jean Zay and Adastra with Isambard-AI for federated AI training across the UK and France; direct connection targeted by end 2026.','2026-10-21',NULL,'press_release','GENCI','https://www.genci.fr/actualites/uk-and-france-pioneer-european-federated-infrastructure-opening-new-frontiers-ai','high')) s(src,tgt,t,de,sd,ed,st,sn,u,v)
JOIN organizations a ON a.slug=s.src JOIN organizations b ON b.slug=s.tgt
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type AND coalesce(x.start_date,'1900-01-01')=coalesce(s.sd::date,'1900-01-01'));

-- Partner links for the C2I2 chair
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, end_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'partnered_with'::relationship_type, 'Industrial partner of the URCA C2I2 chair in supercomputing and industry (2017-2020).', '2017-01-01', '2020-12-31', 'university', 'URCA', 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations a JOIN organizations b ON b.slug='universite-de-reims-champagne-ardenne' WHERE a.slug IN ('cea','bull')
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='partnered_with');

-- Events
INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.t::event_type, s.d::date, s.ti, s.de, s.u, s.st, s.sn, 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('fondation-inria','other','2026-10-13','Fondation Inria launches open-source AI adoption working group','Working group to document use cases, obstacles and good practice in adopting open AI models; backed by NVIDIA (a founding member and principal contributor). Members include Bull, Cap Digital, Caisse des Dépôts-EuroCommons, Cigref, Dassault Systèmes, Euro-Information, Gradium, H Company, Hugging Face and Scaleway. Findings due spring 2027.','https://www.fondation-inria.fr/adoption-de-lia-open-source-la-fondation-inria-lance-un-groupe-de-travail/','press_release','Fondation Inria'),
 ('genci','other','2025-11-25','AI Factory France announces collaboration with NVIDIA Inception and Connect','Announced at the Adopt AI Summit as Europe''s first AI Factory collaboration with NVIDIA''s start-up and ISV programmes; members can access AI2F computing and services (eligibility conditions apply). Went operational at VivaTech in June 2026. GENCI said it had supported 250+ start-ups and 1,400+ AI projects a year on Jean Zay.','https://www.genci.fr/actualites/fast-track-success-ai-factory-france-supercharges-ai-adoption-french-startups-and-smes','press_release','GENCI'),
 ('genci','other','2026-10-21','GENCI and Bristol launch ConcordAI UK-France federated AI partnership','Announced at GTC Berlin with technical support from NVIDIA: Jean Zay and Adastra (France) and Isambard-AI (UK) to train AI models jointly via federated learning (NVIDIA FLARE) without moving sensitive data; direct connection targeted by end 2026.','https://www.genci.fr/actualites/uk-and-france-pioneer-european-federated-infrastructure-opening-new-frontiers-ai','press_release','GENCI'),
 ('omi','other','2026-10-21','Omi signs technology partnership with NVIDIA','NVIDIA supplies RTX PRO 6000 Blackwell GPUs and engineering support; Omi says it will generate images ten times faster. Omi also launched ProductDrop and reported $4M ARR in the US.','https://www.maddyness.com/uk/2026/10/21/nvidia-partners-with-french-startup-omi/','press','Maddyness'),
 ('valeo','product_launch','2026-10-21','Valeo to build high-performance compute platforms on NVIDIA Hyperion','Automotive-grade compute platforms for Level 4 autonomous driving and robotaxis, based on NVIDIA Hyperion (dual DRIVE AGX Thor) and Halos.','https://www.valeo.com/en/valeo-builds-next-generation-high-performance-compute-platforms-built-on-nvidia-hyperion/','press_release','Valeo')) s(slug,t,d,ti,de,u,st,sn)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM organization_events e WHERE e.organization_id=o.id AND e.title=s.ti);

-- AI Factory France programme
INSERT INTO programs (id, name, slug, program_type, description, host_organization_id, operator_organization_id, country, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'AI Factory France (AI2F)', 'ai-factory-france', 'government',
 'National and European AI Factory led by GENCI and co-funded by the EuroHPC Joint Undertaking (partners include Inria, CNRS, CEA, CINES, AMIAD, Station F, Mission French Tech). Offers computing on public supercomputers such as Jean Zay, AI services, training and expert support. Collaboration with NVIDIA Inception and NVIDIA Connect announced Nov 2025 and operational from June 2026 for eligible members (open research, R&D in Europe).',
 g.id, g.id, 'France', 'https://www.genci.fr/actualites/fast-track-success-ai-factory-france-supercharges-ai-adoption-french-startups-and-smes', 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM organizations g WHERE g.slug='genci' AND NOT EXISTS (SELECT 1 FROM programs WHERE slug='ai-factory-france');
INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, announcement_date, description, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'AI Factory France × NVIDIA Inception — 2026', 'ai-factory-france-nvidia-2026', 2026, 'NVIDIA Inception / Connect track', '2025-11-25', 'Track opening AI2F resources to eligible NVIDIA Inception and Connect members; launched operationally at VivaTech, June 2026.', 'https://www.genci.fr/en/news/ai-factory-france-nvidia-program-launches-vivatech-accelerating-ai-innovation-french-and', 'high', 'nvidia_france_november_2026', NOW(), NOW()
FROM programs p WHERE p.slug='ai-factory-france' AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='ai-factory-france-nvidia-2026');
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Participant', 'Named by GENCI among early users of the AI2F × NVIDIA programme (June 2026).', 'medium', 'nvidia_france_november_2026', NOW(), NOW()
FROM program_editions pe JOIN organizations o ON o.slug IN ('pleias','ryax-technologies') WHERE pe.slug='ai-factory-france-nvidia-2026'
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;

COMMIT;
