-- Phase 30: Merge 4 rebrand/duplicate orgs surfaced during bad-SIREN research
--
-- While researching the 14 "different companies" SIREN-collision pairs
-- (see data/bad_siren_research_findings.md), four turned out to be the SAME
-- company under two records -- confirmed against the official French registry:
--   514972306  STRUCTURE COMPUTATION -> SpinalCom   (renamed 2016)
--   529042376  Devatics              -> Onestock    (same legal entity)
--   891908576  ERS (Ecosystem Restoration Standard) -> Equitable Earth (renamed 2025)
--   821893286  Sendinblue            -> Brevo       (duplicate; Brevo already holds the
--                                                    correct SIREN 498019298. Sendinblue's
--                                                    stored 821893286 is Spendesk's number
--                                                    and is left to cascade, NOT moved.)
--
-- Survivor keeps the current/brand record. Re-point moves each duplicate's people,
-- sectors (demoted to non-primary), programs and organization_merge_map rows onto the
-- survivor (guards skip rows the survivor already has). No funding_rounds are moved:
-- ERS's lone round (seed EUR5M 2025-01-01) duplicates Equitable Earth's seed EUR5M
-- 2024-12-05, so it is left to cascade with the ERS org. Duplicate legal_entities
-- cascade when the stub org is deleted.
--
-- NOTE: the DELETE statements were run manually in the Supabase SQL editor
-- (DELETE times out over MCP).

BEGIN;
CREATE TEMP TABLE _m(dup uuid, surv uuid) ON COMMIT DROP;
INSERT INTO _m(dup,surv) VALUES
 ('9afb1c5e-9414-41c9-ace7-4a98d90cf525','8001455b-486d-4a4e-856f-22da5e8da352'),
 ('e309b079-99f8-4854-8263-8ccc863dd7cf','67bc1a3e-a868-42af-9032-173c4b367d48'),
 ('7b80261d-7334-4398-a1e6-83e82026e786','0a1495ce-a2a6-45ca-adc5-93809a9a03b2'),
 ('54fbd8e4-c788-4f51-ab09-6e959ed81e5f','d39a68c8-c553-4df9-aed7-3d0011b54570');

UPDATE organization_people op SET organization_id=_m.surv FROM _m
 WHERE op.organization_id=_m.dup
   AND NOT EXISTS (SELECT 1 FROM organization_people o2 WHERE o2.organization_id=_m.surv AND o2.person_id=op.person_id);

UPDATE organization_sectors os SET organization_id=_m.surv, is_primary=false FROM _m
 WHERE os.organization_id=_m.dup
   AND NOT EXISTS (SELECT 1 FROM organization_sectors o2 WHERE o2.organization_id=_m.surv AND o2.sector_id=os.sector_id);

UPDATE program_organizations pg SET organization_id=_m.surv FROM _m
 WHERE pg.organization_id=_m.dup
   AND NOT EXISTS (SELECT 1 FROM program_organizations p2 WHERE p2.organization_id=_m.surv AND p2.program_edition_id=pg.program_edition_id);

UPDATE organization_merge_map mm SET organization_id=_m.surv FROM _m
 WHERE mm.organization_id=_m.dup
   AND NOT EXISTS (SELECT 1 FROM organization_merge_map x WHERE x.organization_id=_m.surv
                    AND x.source_db=mm.source_db AND x.source_table=mm.source_table AND x.source_id=mm.source_id);
COMMIT;

-- ---------------------------------------------------------------------------
-- Run in the Supabase SQL editor.
-- (a) Remove Equitable Earth's duplicate legal_entity row (keep the other, same SIREN):
DELETE FROM legal_entities WHERE id = '99db5feb-4d51-4498-b66c-38856ca84580'; -- Equitable Earth dup LE (891908576)

-- (b) Delete the 4 duplicate stub orgs (cascade clears their leftovers, incl. ERS's
--     duplicate round and Sendinblue's wrong-SIREN legal entity):
DELETE FROM organizations WHERE id = '9afb1c5e-9414-41c9-ace7-4a98d90cf525'; -- Structure Computation -> SpinalCom
DELETE FROM organizations WHERE id = 'e309b079-99f8-4854-8263-8ccc863dd7cf'; -- Devatics -> Onestock
DELETE FROM organizations WHERE id = '7b80261d-7334-4398-a1e6-83e82026e786'; -- ERS -> Equitable Earth
DELETE FROM organizations WHERE id = '54fbd8e4-c788-4f51-ab09-6e959ed81e5f'; -- Sendinblue -> Brevo
