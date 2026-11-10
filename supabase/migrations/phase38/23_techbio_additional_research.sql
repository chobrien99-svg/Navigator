-- =============================================================================
-- TechBio additional research (editor-supplied research doc + Eligo funding
-- table, 10 Nov 2026)
-- =============================================================================
-- legacy_source 'techbio_additional_research_november_2026'.
-- POIETIS: business taken over by Poietis Biosystems, SIREN 939889283,
--   registered 21 Jan 2025 (the day the Bordeaux court approved the sale plan)
--   at Poietis's address (27 allée Charles Darwin, Pessac); renamed NGB
--   Biosystems in 2026 (statutes amended, filing of 1 Sep 2026). Register
--   (recherche-entreprises, Pappers): president 1M86 SAS (Bordeaux), managing
--   director Laurent Vrignaud. Company announcement (research doc) names Luc
--   Milbergue as president. The judgment itself was not read; buyer identity
--   rests on the announcement plus matching date and address (medium-high).
-- ELIGO (funding table + research doc):
--   * Jul 2017 Khosla round: €0 -> undisclosed.
--   * Apr 2018 €1.8M: kept, flagged; equity vs grant not established.
--   * Grants: Jan 2019 $4.5M (funder not named); Jun 2020 CARB-X $7.1M;
--     Jan 2021 EIT Health support; May 2025 France 2030 $5M (Bpifrance,
--     immuno-dermatology platform).
--   * Series B: Eligo said in May 2025 it had extended its 2023 Series B from
--     $30M to $35M. Recorded as a $5M extension (≈€4.4M, estimated), investors
--     not disclosed.
--   * Origins: spin-out of MIT, Inria, Rockefeller University and Institut
--     Pasteur (Jan 2014); HEC Challenge+ (Oct 2014); Agoranov (Jan 2015).
-- PHAGOS: Oct 2025 €25M Series A co-led by Capagro, Hoxton Ventures, CapHorn
--   and Demeter (leads marked); date set to 8 Oct 2025. Citizen Capital and
--   Capagro II report 2024 investments; not linked to the Aug 2024 entry.
-- KSILINK: €16M PIA funding launched the Ksilink Association (recorded on the
--   association). CORDIS IMPACT project: €159,829.85 EU contribution to a
--   participant named KSILINK; legal entity unconfirmed.
-- TYCHOBIO: Kima Ventures investment signal dated 29 May 2026 (tracker).
-- =============================================================================
BEGIN;
-- Poietis successor
INSERT INTO organizations (id, name, slug, organization_type, description, status, country, city_id, founded_date, founded_year, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'NGB Biosystems', 'ngb-biosystems', 'startup'::organization_type,
 'Formerly Poietis Biosystems. Took over the activities of Poietis (3D bioprinters and bioprinted tissue for grafting) after the Bordeaux court approved a sale plan in January 2025. Registered 21 January 2025 at Poietis''s former address in Pessac; renamed NGB Biosystems in 2026.',
 'active'::organization_status, 'France', (SELECT id FROM cities WHERE slug='pessac'), '2025-01-21', 2025, 'techbio_additional_research_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE slug='ngb-biosystems');
INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, registered_city, naf_code, capital_eur, country, is_primary, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'NGB BIOSYSTEMS', '939889283', '2025-01-21', 'PESSAC', '72.11Z', 9978, 'France', TRUE, 'high', 'techbio_additional_research_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='ngb-biosystems' AND NOT EXISTS (SELECT 1 FROM legal_entities WHERE siren='939889283');
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'acquired'::relationship_type, 'Took over Poietis''s activities under the court-approved sale plan of 21 January 2025 (announced by Poietis Biosystems; same address; registered the same day). Judgment not read.', '2025-01-21', 'company_website', 'Poietis Biosystems announcement; company register', 'medium', 'techbio_additional_research_november_2026', NOW(), NOW()
FROM organizations a JOIN organizations b ON b.slug='poietis' WHERE a.slug='ngb-biosystems'
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='acquired');
UPDATE organization_events e SET description='Bordeaux court approved a sale plan (plan de cession) on 21 January 2025. The activities were taken over by Poietis Biosystems (SIREN 939889283, registered that day at Poietis''s address; renamed NGB Biosystems in 2026), per its announcement; the notice itself does not name the buyer. BODACC A n°20250022, annonce 2255, 31 January 2025.', updated_at=NOW()
FROM organizations o WHERE e.organization_id=o.id AND o.slug='poietis' AND e.title='Court approves sale plan for Poietis''s business';

-- Eligo rounds
UPDATE funding_rounds fr SET amount_eur=NULL, amount_original=NULL, notes=coalesce(fr.notes||' ','')||'Amount undisclosed.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='eligo-bioscience' AND fr.announced_date='2017-07-01' AND fr.amount_eur=0;
UPDATE funding_rounds fr SET notes=coalesce(fr.notes||' ','')||'€1.8M listed by Dealroom (Bpifrance database) as early VC, no investor; Eligo''s news page lists French government grants in April 2018, so it may be grant funding. Unconfirmed.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='eligo-bioscience' AND fr.announced_date='2018-04-01' AND coalesce(fr.notes,'') NOT LIKE '%Dealroom%';
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'series_b', 4.4, 'USD', 5000000, '2025-05-01', TRUE, 'Eligo announcement (May 2025)', 'Series B extension: Eligo said the 2023 Series B was extended from $30M to $35M. Timing of the extra $5M and its investors not disclosed; euro amount converted.', 'techbio_additional_research_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='eligo-bioscience'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.announced_date='2025-05-01' AND x.stage='series_b');
INSERT INTO grants (id, organization_id, grant_name, granting_body, amount_eur, awarded_date, program, description, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.n, s.b, s.a, s.d::date, s.p, s.descr, NOW(), NOW()
FROM organizations o, (VALUES
 ('Grant (January 2019)',NULL,3.9e6,'2019-01-01',NULL,'Grant of $4.5M (≈€3.9M), funder not named (editor-supplied funding table).'),
 ('CARB-X award (2020)','CARB-X',6.3e6,'2020-06-01','CARB-X','CARB-X funding of $7.1M (≈€6.3M) (editor-supplied funding table).'),
 ('EIT Health support programme (2021)','EIT Health',NULL,'2021-01-01','EIT Health','Support programme, amount not disclosed (editor-supplied funding table).'),
 ('France 2030 grant – immuno-dermatology platform (2025)','Bpifrance (France 2030)',4.4e6,'2025-05-01','France 2030','France 2030 grant of $5M (≈€4.4M) operated by Bpifrance for its immuno-dermatology platform (Eligo announcement, May 2025).')) s(n,b,a,d,p,descr)
WHERE o.slug='eligo-bioscience' AND NOT EXISTS (SELECT 1 FROM grants g WHERE g.organization_id=o.id AND g.grant_name=s.n);

-- Eligo origins
INSERT INTO organizations (id, name, slug, organization_type, description, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'Rockefeller University', 'rockefeller-university', 'university'::organization_type, 'Biomedical research university in New York.', 'active'::organization_status, 'United States', 'techbio_additional_research_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE slug='rockefeller-university');
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.d, s.sd::date, 'editor', 'Editor-supplied funding table (FTJ)', 'medium', 'techbio_additional_research_november_2026', NOW(), NOW()
FROM (VALUES ('rockefeller-university','spun_out_from','Spin-out (January 2014) involving MIT, Inria, Rockefeller University and Institut Pasteur.','2014-01-01'),
             ('inria','spun_out_from','Spin-out (January 2014) involving MIT, Inria, Rockefeller University and Institut Pasteur.','2014-01-01'),
             ('institut-pasteur','spun_out_from','Spin-out (January 2014) involving MIT, Inria, Rockefeller University and Institut Pasteur.','2014-01-01'),
             ('agoranov','incubated_by','Agoranov support programme from January 2015.','2015-01-01')) s(slug,t,d,sd)
JOIN organizations a ON a.slug='eligo-bioscience' JOIN organizations b ON b.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type);
INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'HEC Challenge+ — 2014', 'hec-challenge-plus-2014', 2014, 'October 2014', NOW(), NOW()
FROM programs p WHERE p.slug='hec-challenge-plus' AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='hec-challenge-plus-2014');
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Participant', 'Support programme, October 2014 (editor-supplied).', 'medium', 'techbio_additional_research_november_2026', NOW(), NOW()
FROM program_editions pe JOIN organizations o ON o.slug='eligo-bioscience' WHERE pe.slug='hec-challenge-plus-2014'
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;

-- Phagos
UPDATE funding_rounds fr SET announced_date='2025-10-08', notes=coalesce(fr.notes||' ','')||'Co-led by Capagro, Hoxton Ventures, CapHorn and Demeter.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='phagos' AND fr.stage='series_a' AND fr.announced_date IN ('2025-10-01','2025-10-08') AND coalesce(fr.notes,'') NOT LIKE '%Co-led%';
UPDATE funding_round_investors fri SET is_lead=TRUE
FROM funding_rounds fr, organizations o, organizations i
WHERE fri.funding_round_id=fr.id AND fr.organization_id=o.id AND fri.investor_id=i.id AND o.slug='phagos' AND fr.stage='series_a' AND i.slug IN ('capagro','hoxton-ventures','caphorn','demeter');
UPDATE funding_rounds fr SET notes=coalesce(fr.notes||' ','')||'Citizen Capital and Capagro II both report investing in Phagos in 2024; not confirmed as participants in this transaction.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='phagos' AND fr.announced_date='2024-08-18' AND coalesce(fr.notes,'') NOT LIKE '%Citizen Capital%';

-- Ksilink
INSERT INTO grants (id, organization_id, grant_name, granting_body, amount_eur, awarded_date, program, description, source_url, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.n, s.b, s.a, NULL, s.p, s.descr, s.u, NOW(), NOW()
FROM (VALUES
 ('ksilink-association','Programme d''Investissement d''Avenir funding (launch)','French State (PIA)',16000000,'Programme d''Investissement d''Avenir','€16M of PIA funding launched the Ksilink Association, with impetus from Inserm and Sanofi (Ksilink website). Platform and team transferred to the spin-off company in 2022.','https://ksilink.com/'),
 ('ksilink','Horizon 2020 – IMPACT (participant ''KSILINK'')','European Commission',159829.85,'Horizon 2020','Net EU contribution of €159,829.85 to a participant named KSILINK in the IMPACT project (participation ended), per CORDIS. Which Ksilink legal entity (association or company) received it is unconfirmed.',NULL)) s(slug,n,b,a,p,descr,u)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM grants g WHERE g.organization_id=o.id AND g.grant_name=s.n);

-- TychoBio
UPDATE funding_rounds fr SET notes=fr.notes||' An investment tracker dates a Kima Ventures signal to 29 May 2026 (signal date, not necessarily the closing date).', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='tychobio' AND fr.stage='pre_seed' AND fr.notes NOT LIKE '%29 May 2026%';
COMMIT;
