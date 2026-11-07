-- =============================================================================
-- TechBio list: INPI patent run (2026-11-07)
-- =============================================================================
-- Goal: find patents for the 52 TechBio-tagged companies via INPI, prioritising
-- the 29 with no patents yet.
--
-- INPI could NOT be queried from this environment:
--   * data.inpi.fr, www.inpi.fr, bases-brevets19e.inpi.fr: blocked by the
--     session's network policy (CONNECT 403 at the proxy).
--   * api-gateway.inpi.fr (INPI "API PI" diffusion API): reachable, but every
--     data endpoint returns 401 "Full authentication is required". It needs an
--     INPI account (username/password login that returns a session token).
--   * static.data.gouv.fr (third-party parquet dump "Brevets d'invention
--     Francais 1981-2026", dataset 6a2c13d26ca78616d3f3d51c): blocked.
--   * INPI "Publications de demandes de brevets 2020" (tabular) has no
--     applicant column, so it cannot be matched to companies.
--
-- Fallback used: MESR "Déposants des brevets" (dataset 63b4ebd006676a13059dde9a,
-- resource 7744f1fc-..., the same source as file 09), checked by SIREN and by
-- applicant name for the zero-patent companies.
--
-- Result: one gap filled. Qynapse (SIREN 815093356) has 2 patent families
-- that were not loaded (Qynapse was tagged TechBio after file 09 ran).
-- No co-applicants on either family.
-- Rejected name match: "Synhelix" (SIREN 848917373) is not Helix Research
-- Intelligence (SIREN 107351702).
--
-- Idempotent: skips any family already stored for the company.
-- =============================================================================
BEGIN;
WITH src(org,pn,title,abstract,fd,office,url) AS (VALUES
('qynapse','WO2018081267WEP',NULL,'[Patent family record] DOCDB family 64316567; 4 application(s); offices: CN, EP, US, WO.',NULL,'WO','family:64316567'),
('qynapse','FR1700496A',NULL,'[Patent family record] DOCDB family 60382248; 1 application(s); offices: FR.',NULL,'FR','family:60382248'))
INSERT INTO patents (id,organization_id,patent_number,title,abstract,filing_date,patent_office,url,created_at,updated_at)
SELECT uuid_generate_v4(),o.id,s.pn,COALESCE(s.title,'Patent family '||split_part(s.url,':',2)||' (title not in open data)'),s.abstract,s.fd::date,s.office,NULL,NOW(),NOW() FROM src s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM patents x WHERE x.organization_id=o.id AND x.abstract LIKE '%DOCDB family '||split_part(s.url,':',2)||';%');
COMMIT;
