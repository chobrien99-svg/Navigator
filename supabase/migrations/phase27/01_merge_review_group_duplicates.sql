-- Phase 27: Merge the 8 "review" duplicate groups (both records held funding rounds)
--
-- These 8 name-variant groups were held back from the phase-26 batch because more
-- than one record carried funding rounds, so each needed individual judgement on
-- whether the rounds were distinct or the same deal double-entered.
--
--   SIREN       survivor (kept)          <- stub (deleted)              rounds
--   509397832   PulseSight Therapeutics  <- PulseSight (eyevensys)      distinct: +Series B 2021
--   809711856   Etix Everywhere          <- Etix                        SAME EUR30M deal: stub round
--                                                                        left to cascade-delete
--   809890510   Jay&Joy (jayjoy)         <- Jay & Joy (jay-joy)         moved "other EUR2M/2025" round
--                                                                        (possible dup of 2026 seed - flagged)
--   820569218   Laclaree                 <- Laclaree Vision            distinct: +seed EUR3.5M 2025
--   880788054   GeoLinks                 <- Geolinks Services          distinct: +seed EUR3.4M 2026
--   888737186   Hemerion Therapeutics    <- Hemerion                   distinct: +3 earlier rounds
--   902971720   Kumulus                  <- Kumulus Water              distinct: +2 earlier rounds
--   922166996   Spore Biotechnologies    <- Spore.Bio                  distinct: +pre-seed EUR7.98M 2023
--
-- Re-point moves the stubs' distinct rounds (all groups except Etix) plus any
-- people / sectors / programs the survivor lacks (moved sectors demoted to
-- non-primary). Legal entities need no move - every survivor already holds the
-- SIREN; four survivors (PulseSight, Hemerion, Kumulus, Spore) carry a redundant
-- second legal_entity row that is deleted below.
--
-- NOTE: DELETE statements were run manually in the Supabase SQL editor
-- (DELETE times out over MCP).

BEGIN;

WITH m(dup,surv) AS (VALUES
  ('f3b8b323-bbef-48fb-a87e-4fe02e3e7d06'::uuid,'93f4d117-18be-42e4-8464-58ff6f416ca5'::uuid),
  ('7c37746d-b1ca-4f33-a890-c92309d596b3'::uuid,'9f462d5a-fb0d-4f72-beaf-cc34bdacb93d'::uuid),
  ('084b1af6-c20c-427e-a49f-8b8f7a3ce487'::uuid,'fb53ccd2-6fa4-40b0-bd5d-38e76c2bb1d6'::uuid),
  ('e8a36704-be3d-4142-895a-554be8e1bba4'::uuid,'1c872b25-c425-427d-95fb-abd1ed62d1b9'::uuid),
  ('49f30b02-eca7-442e-97ce-2e12e6d9e2ff'::uuid,'0b940c96-c397-4985-a275-01ac37dc821b'::uuid),
  ('4ecd285c-e960-45b2-9549-4f13de7b384c'::uuid,'618bcd65-1b51-45c8-9a0f-57527c49f316'::uuid),
  ('43c86a05-31ef-4cb7-8208-995b062c040b'::uuid,'83a95abd-089d-4747-a547-2d5fe589c527'::uuid))
UPDATE funding_rounds fr SET organization_id = m.surv
  FROM m WHERE fr.organization_id = m.dup;

WITH m(dup,surv) AS (VALUES
  ('f3b8b323-bbef-48fb-a87e-4fe02e3e7d06'::uuid,'93f4d117-18be-42e4-8464-58ff6f416ca5'::uuid),
  ('4c8e630c-8e84-4f79-a1d6-127cd84d0297'::uuid,'9f1bb0eb-d880-45de-a9a4-0dffcc5be9d3'::uuid),
  ('7c37746d-b1ca-4f33-a890-c92309d596b3'::uuid,'9f462d5a-fb0d-4f72-beaf-cc34bdacb93d'::uuid),
  ('084b1af6-c20c-427e-a49f-8b8f7a3ce487'::uuid,'fb53ccd2-6fa4-40b0-bd5d-38e76c2bb1d6'::uuid),
  ('e8a36704-be3d-4142-895a-554be8e1bba4'::uuid,'1c872b25-c425-427d-95fb-abd1ed62d1b9'::uuid),
  ('49f30b02-eca7-442e-97ce-2e12e6d9e2ff'::uuid,'0b940c96-c397-4985-a275-01ac37dc821b'::uuid),
  ('4ecd285c-e960-45b2-9549-4f13de7b384c'::uuid,'618bcd65-1b51-45c8-9a0f-57527c49f316'::uuid),
  ('43c86a05-31ef-4cb7-8208-995b062c040b'::uuid,'83a95abd-089d-4747-a547-2d5fe589c527'::uuid))
UPDATE organization_people op SET organization_id = m.surv
  FROM m WHERE op.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM organization_people o2
                     WHERE o2.organization_id = m.surv AND o2.person_id = op.person_id);

WITH m(dup,surv) AS (VALUES
  ('f3b8b323-bbef-48fb-a87e-4fe02e3e7d06'::uuid,'93f4d117-18be-42e4-8464-58ff6f416ca5'::uuid),
  ('4c8e630c-8e84-4f79-a1d6-127cd84d0297'::uuid,'9f1bb0eb-d880-45de-a9a4-0dffcc5be9d3'::uuid),
  ('7c37746d-b1ca-4f33-a890-c92309d596b3'::uuid,'9f462d5a-fb0d-4f72-beaf-cc34bdacb93d'::uuid),
  ('084b1af6-c20c-427e-a49f-8b8f7a3ce487'::uuid,'fb53ccd2-6fa4-40b0-bd5d-38e76c2bb1d6'::uuid),
  ('e8a36704-be3d-4142-895a-554be8e1bba4'::uuid,'1c872b25-c425-427d-95fb-abd1ed62d1b9'::uuid),
  ('49f30b02-eca7-442e-97ce-2e12e6d9e2ff'::uuid,'0b940c96-c397-4985-a275-01ac37dc821b'::uuid),
  ('4ecd285c-e960-45b2-9549-4f13de7b384c'::uuid,'618bcd65-1b51-45c8-9a0f-57527c49f316'::uuid),
  ('43c86a05-31ef-4cb7-8208-995b062c040b'::uuid,'83a95abd-089d-4747-a547-2d5fe589c527'::uuid))
UPDATE organization_sectors os SET organization_id = m.surv, is_primary = false
  FROM m WHERE os.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM organization_sectors o2
                     WHERE o2.organization_id = m.surv AND o2.sector_id = os.sector_id);

WITH m(dup,surv) AS (VALUES
  ('f3b8b323-bbef-48fb-a87e-4fe02e3e7d06'::uuid,'93f4d117-18be-42e4-8464-58ff6f416ca5'::uuid),
  ('4c8e630c-8e84-4f79-a1d6-127cd84d0297'::uuid,'9f1bb0eb-d880-45de-a9a4-0dffcc5be9d3'::uuid),
  ('7c37746d-b1ca-4f33-a890-c92309d596b3'::uuid,'9f462d5a-fb0d-4f72-beaf-cc34bdacb93d'::uuid),
  ('084b1af6-c20c-427e-a49f-8b8f7a3ce487'::uuid,'fb53ccd2-6fa4-40b0-bd5d-38e76c2bb1d6'::uuid),
  ('e8a36704-be3d-4142-895a-554be8e1bba4'::uuid,'1c872b25-c425-427d-95fb-abd1ed62d1b9'::uuid),
  ('49f30b02-eca7-442e-97ce-2e12e6d9e2ff'::uuid,'0b940c96-c397-4985-a275-01ac37dc821b'::uuid),
  ('4ecd285c-e960-45b2-9549-4f13de7b384c'::uuid,'618bcd65-1b51-45c8-9a0f-57527c49f316'::uuid),
  ('43c86a05-31ef-4cb7-8208-995b062c040b'::uuid,'83a95abd-089d-4747-a547-2d5fe589c527'::uuid))
UPDATE program_organizations pg SET organization_id = m.surv
  FROM m WHERE pg.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM program_organizations p2
                     WHERE p2.organization_id = m.surv AND p2.program_edition_id = pg.program_edition_id);

COMMIT;

-- ---------------------------------------------------------------------------
-- Run in the Supabase SQL editor.
-- (a) Remove the redundant duplicate legal_entity row on the 4 survivors
--     that carried two rows for their SIREN (keeping the other row):
DELETE FROM legal_entities WHERE id = '8147fe99-6684-4e7f-b08b-cfe7ecc67533'; -- PulseSight Therapeutics (509397832)
DELETE FROM legal_entities WHERE id = 'b2712a3a-a870-492a-83ad-c7fdd7c9c3af'; -- Hemerion Therapeutics (888737186)
DELETE FROM legal_entities WHERE id = '660b8069-f02e-42d6-b592-c50e5bed7f30'; -- Kumulus (902971720)
DELETE FROM legal_entities WHERE id = '2d815a70-e61c-4693-aeaa-4cf719f17b08'; -- Spore Biotechnologies (922166996)

-- (b) Delete the 8 duplicate stub orgs (cascade clears their remaining rows,
--     including Etix's duplicate EUR30M round):
DELETE FROM organizations WHERE id = 'f3b8b323-bbef-48fb-a87e-4fe02e3e7d06'; -- PulseSight (eyevensys) -> PulseSight Therapeutics
DELETE FROM organizations WHERE id = '4c8e630c-8e84-4f79-a1d6-127cd84d0297'; -- Etix -> Etix Everywhere
DELETE FROM organizations WHERE id = '7c37746d-b1ca-4f33-a890-c92309d596b3'; -- Jay & Joy -> Jay&Joy
DELETE FROM organizations WHERE id = '084b1af6-c20c-427e-a49f-8b8f7a3ce487'; -- Laclaree Vision -> Laclaree
DELETE FROM organizations WHERE id = 'e8a36704-be3d-4142-895a-554be8e1bba4'; -- Geolinks Services -> GeoLinks
DELETE FROM organizations WHERE id = '49f30b02-eca7-442e-97ce-2e12e6d9e2ff'; -- Hemerion -> Hemerion Therapeutics
DELETE FROM organizations WHERE id = '4ecd285c-e960-45b2-9549-4f13de7b384c'; -- Kumulus Water -> Kumulus
DELETE FROM organizations WHERE id = '43c86a05-31ef-4cb7-8208-995b062c040b'; -- Spore.Bio -> Spore Biotechnologies
