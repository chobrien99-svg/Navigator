-- =============================================================================
-- TechBio list: additional company-level ANR grants (complete ANR search)
-- =============================================================================
-- Source: ANR_01 (generic calls) and ANR_02 (DGPIE: France 2030 / PIA) open
-- data on data.gouv.fr. ANR_02 publishes only whole-project totals, so
-- amount_eur is NULL for those and the consortium total is in the description.
-- =============================================================================
WITH src(org,name,amt,dt,prog,descr,url) AS (VALUES
('eligo-bioscience','ANR FAREWEL','218196','2016-01-01','AAPG CE18','ANR project FAREWEL "Fighting Antibiotic Resistance in E. coli with Eligobiotics" (ANR-16-CE18-0021), 2016. Role: coordinator. Project total €534,576.','https://www.data.gouv.fr/datasets/anr-01-projets-anr-dos-et-dgds-detail-des-projets-et-des-partenaires'),
('orakl-oncology','ANR ORGANOMIC',NULL,'2021-01-01','France 2030/PIA RHU (RHUS)','ANR project ORGANOMIC "Organoid-based assays for functional personalized medicine strategies" (ANR-21-RHUS-0003), 2021 edition. Role: partner; consortium coordinated by Orakl co-founder Fanny Jaulin (Gustave Roussy). Whole-consortium ANR funding €9,069,437; the company''s share is not published. Orakl was created in 2023, so it was likely added to the consortium later.','https://www.data.gouv.fr/datasets/anr-02-projets-anr-dgpie-detail-des-projets-et-des-partenaires'),
('okomera','ANR ORGANOMIC',NULL,'2021-01-01','France 2030/PIA RHU (RHUS)','ANR project ORGANOMIC "Organoid-based assays for functional personalized medicine strategies" (ANR-21-RHUS-0003), 2021. Role: partner. Whole-consortium ANR funding €9,069,437; the company''s share is not published.','https://www.data.gouv.fr/datasets/anr-02-projets-anr-dgpie-detail-des-projets-et-des-partenaires'),
('ariana-pharmaceuticals','ANR AUGMENTREG',NULL,'2023-01-01','France 2030 RHU (RHUS)','ANR project AUGMENTREG "Augmented Treg cell therapy to achieve operational tolerance to transplanted allogeneic solid organs" (ANR-23-RHUS-0005), 2023. Role: partner; PI Makoto Miyara. Whole-consortium ANR funding €9,823,734; the company''s share is not published.','https://www.data.gouv.fr/datasets/anr-02-projets-anr-dgpie-detail-des-projets-et-des-partenaires'),
('ariana-pharmaceuticals','ANR ATRACTION',NULL,'2018-01-01','PIA RHU (RHUS)','ANR project ATRACTION (autoimmunity/inflammation single-cell RNA-seq for therapeutic innovation) (ANR-18-RHUS-0010), 2018. Role: partner; PI Frédéric Rieux-Laucat. Whole-consortium ANR funding €9,939,535; the company''s share is not published.','https://www.data.gouv.fr/datasets/anr-02-projets-anr-dgpie-detail-des-projets-et-des-partenaires'),
('whitelab-genomics','ANR GenoTher',NULL,'2023-01-01','France 2030 Biocluster (BIOC)','France 2030 Biocluster GenoTher (Paris–Évry gene-therapy cluster) (ANR-23-BIOC-0003), 2023. Role: partner. Whole-biocluster funding €70,000,000; the company''s share is not published.','https://www.data.gouv.fr/datasets/anr-02-projets-anr-dgpie-detail-des-projets-et-des-partenaires'))
INSERT INTO grants (id,organization_id,grant_name,granting_body,amount_eur,awarded_date,program,description,source_url,created_at,updated_at)
SELECT uuid_generate_v4(),o.id,s.name,'Agence nationale de la recherche (ANR)',s.amt::numeric,s.dt::date,s.prog,s.descr,s.url,NOW(),NOW()
FROM src s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM grants g WHERE g.organization_id=o.id AND g.grant_name=s.name);
