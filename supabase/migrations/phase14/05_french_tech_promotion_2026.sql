-- Phase 14 · French Tech Next 40/120 — Promotion 2026
--
-- Ingests the official 2026 cohort (announced Mon 15 Jun 2026) from the
-- "Dossier de presse · Promotion 2026 du programme French Tech Next40/120"
-- (Annexe 2 — Liste des lauréats 2026).
--
-- 115 of 120 lauréats already exist as organizations from prior cohorts.
-- Two are existing orgs that needed their canonical name updated to the
-- 2026 spelling (my-unisoft → "MyUnisoft", resilience → "Resilience Care").
-- Three are net-new: AMI Labs, Crème de la Crème, Positive.
--
-- A potential duplicate to verify: an existing stub org "AMI" (slug "ami",
-- no description / no programs) may be the same company as the new
-- "AMI Labs" — left as a separate stub for the editorial team to confirm
-- and merge via merge_organizations() if appropriate.

BEGIN;

-- 1. Create the 2026 edition (idempotent)
INSERT INTO program_editions (program_id, year, cohort_label)
SELECT 'c282f128-db37-40bb-a12c-fa32d6dc74a4', 2026, '2026'
 WHERE NOT EXISTS (
   SELECT 1 FROM program_editions
    WHERE program_id='c282f128-db37-40bb-a12c-fa32d6dc74a4' AND year=2026
 );

-- 2. Rename existing orgs to the official 2026 spelling
UPDATE organizations SET name='MyUnisoft',       updated_at=NOW() WHERE slug='my-unisoft';
UPDATE organizations SET name='Resilience Care', updated_at=NOW() WHERE slug='resilience';

-- 3. Create the three net-new orgs (idempotent on slug)
INSERT INTO organizations (slug, name, organization_type, status, country)
SELECT v.slug, v.name, 'startup', 'active', 'France'
  FROM (VALUES
    ('ami-labs',          'AMI Labs'),
    ('creme-de-la-creme', 'Crème de la Crème'),
    ('positive',          'Positive')
  ) AS v(slug, name)
 WHERE NOT EXISTS (SELECT 1 FROM organizations o WHERE o.slug=v.slug);

-- 4. Link all 120 lauréats to the 2026 edition with their tier
WITH candidates(name, candidate_slug, tier) AS (VALUES
  -- Next 40 (40)
  ('Alan','alan','Next 40'),('Alice & Bob','alice-bob','Next 40'),('Alma','alma','Next 40'),
  ('AMI Labs','ami-labs','Next 40'),('Aqemia','aqemia','Next 40'),('Aura Aero','aura-aero','Next 40'),
  ('Back Market','back-market','Next 40'),('Blablacar','blablacar','Next 40'),('Chapsvision','chapsvision','Next 40'),
  ('Contentsquare','contentsquare','Next 40'),('Descartes Underwriting','descartes-underwriting','Next 40'),
  ('Doctolib','doctolib','Next 40'),('EcoVadis','ecovadis','Next 40'),('Ekimetrics','ekimetrics','Next 40'),
  ('Electra','electra','Next 40'),('Exotec','exotec','Next 40'),('Flying Whales','flying-whales','Next 40'),
  ('Foodles','foodles','Next 40'),('H Company','h-company','Next 40'),('Hublo','hublo','Next 40'),
  ('Innovafeed','innovafeed','Next 40'),('Ledger','ledger','Next 40'),('Legalplace','legalplace','Next 40'),
  ('Malt','malt','Next 40'),('Medadom','medadom','Next 40'),('Mistral AI','mistral-ai','Next 40'),
  ('NW','nw','Next 40'),('Pasqal','pasqal','Next 40'),('Payfit','payfit','Next 40'),
  ('Pennylane','pennylane','Next 40'),('Pigment','pigment','Next 40'),('Qonto','qonto','Next 40'),
  ('Quobly','quobly','Next 40'),('Shift Technology','shift-technology','Next 40'),('Spendesk','spendesk','Next 40'),
  ('Swile','swile','Next 40'),('Tissium','tissium','Next 40'),('Verkor','verkor','Next 40'),
  ('Voodoo','voodoo','Next 40'),('Wandercraft','wandercraft','Next 40'),
  -- FT 120 (80)
  ('360Learning','360learning','FT 120'),('52 Entertainment','52-entertainment','FT 120'),
  ('Acheel','acheel','FT 120'),('Adikteev','adikteev','FT 120'),('Agicap','agicap','FT 120'),
  ('Agryco','agryco','FT 120'),('Akeneo','akeneo','FT 120'),('Akur8','akur8','FT 120'),
  ('Animaj','animaj','FT 120'),('Bigblue','bigblue','FT 120'),('Bump','bump','FT 120'),
  ('Chargemap','chargemap','FT 120'),('ClubFunding','clubfunding','FT 120'),('CorWave','corwave','FT 120'),
  ('Crème de la Crème','creme-de-la-creme','FT 120'),('Deepki','deepki','FT 120'),
  ('Elicit Plant','elicit-plant','FT 120'),('Energy Pool','energy-pool','FT 120'),('Exotrail','exotrail','FT 120'),
  ('Fairmat','fairmat','FT 120'),('Flowdesk','flowdesk','FT 120'),('FoodFlow','foodflow','FT 120'),
  ('FreelanceRepublik','freelancerepublik','FT 120'),('GitGuardian','gitguardian','FT 120'),
  ('Gradium','gradium','FT 120'),('GravitHy','gravithy','FT 120'),('Greenly','greenly','FT 120'),
  ('HelloCSE','hellocse','FT 120'),('Homa','homa','FT 120'),('HomeExchange','homeexchange','FT 120'),
  ('iSupplier','isupplier','FT 120'),('ITEN','iten','FT 120'),('Jimmy','jimmy','FT 120'),
  ('La Fourche','la-fourche','FT 120'),('Latitude','latitude','FT 120'),('LeHibou','lehibou','FT 120'),
  ('Libon','libon','FT 120'),('Locala','locala','FT 120'),('Metron','metron','FT 120'),
  ('Mistertemp'' Group','mistertemp-group','FT 120'),('Moon Surgical','moon-surgical','FT 120'),
  ('MWM','mwm','FT 120'),('MyLight150','mylight150','FT 120'),('MyUnisoft','my-unisoft','FT 120'),
  ('Naboo','naboo','FT 120'),('Ornikar','ornikar','FT 120'),('Ouihelp','ouihelp','FT 120'),
  ('Papernest','papernest','FT 120'),('Partoo','partoo','FT 120'),('Pixmania','pixmania','FT 120'),
  ('Planity','planity','FT 120'),('Positive','positive','FT 120'),('Qair','qair','FT 120'),
  ('Resilience Care','resilience','FT 120'),('Scintil Photonics','scintil-photonics','FT 120'),
  ('Sekoia','sekoia','FT 120'),('Seyna','seyna','FT 120'),('Shares','shares','FT 120'),
  ('Shippeo','shippeo','FT 120'),('Shopopop','shopopop','FT 120'),('SparingVision','sparingvision','FT 120'),
  ('Spore.Bio','spore-bio','FT 120'),('Step Pharma','step-pharma','FT 120'),('Stockly','stockly','FT 120'),
  ('Stoïk','stoik','FT 120'),('Stych','stych','FT 120'),('Superprof','superprof','FT 120'),
  ('Swan','swan','FT 120'),('Sweep','sweep','FT 120'),('TSE','tse','FT 120'),
  ('Unseenlabs','unseenlabs','FT 120'),('Upsun','upsun','FT 120'),('Verley','verley','FT 120'),
  ('Vestiaire Collective','vestiaire-collective','FT 120'),('Voltalis','voltalis','FT 120'),
  ('Waat','waat','FT 120'),('Weezevent','weezevent','FT 120'),('Yespark','yespark','FT 120'),
  ('Yubo','yubo','FT 120'),('Zeplug','zeplug','FT 120')
),
ed AS (
  SELECT id FROM program_editions
   WHERE program_id='c282f128-db37-40bb-a12c-fa32d6dc74a4' AND year=2026
)
INSERT INTO program_organizations (program_edition_id, organization_id, group_label)
SELECT ed.id, m.org_id, c.tier
  FROM candidates c
  CROSS JOIN ed
  JOIN LATERAL (
    SELECT o.id AS org_id FROM organizations o
     WHERE o.slug = c.candidate_slug OR lower(o.name) = lower(c.name)
     ORDER BY (o.slug = c.candidate_slug) DESC NULLS LAST,
              (lower(o.name) = lower(c.name)) DESC NULLS LAST,
              o.created_at
     LIMIT 1
  ) m ON TRUE
 WHERE NOT EXISTS (
   SELECT 1 FROM program_organizations po
    WHERE po.program_edition_id = ed.id AND po.organization_id = m.org_id
 );

COMMIT;
