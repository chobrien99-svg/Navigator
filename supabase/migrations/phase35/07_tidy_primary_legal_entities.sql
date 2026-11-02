-- =====================================================================
-- Phase 35 - Tidy is_primary: one primary legal entity per org.
--
-- After dedup, 24 orgs still had >1 is_primary legal entity (each a
-- distinct SIREN). For each, the correct operating entity was chosen
-- against the French registry (active over ceased, operating company
-- over holding/SCI, matching name/sector) and set as the sole primary;
-- the rest set non-primary. Plus one org (locala) that had a single
-- legal entity with no primary flag.
--
-- is_primary only; no entities added or removed here. Idempotent.
--
-- NOTE: several of the now-non-primary rows are unrelated companies
-- wrongly attached (e.g. DASHDOC on heyday, BUYCO on watchfrog) and are
-- candidates for removal in a follow-up - not handled here.
-- =====================================================================

BEGIN;

WITH chosen(id) AS (VALUES
  ('d5f664cc-3dc4-43ab-986d-f9a60dc061ec'::uuid), -- electra      ELECTRA 891624884
  ('60c97bf7-791b-4b51-9dff-c52460235526'),       -- formance     409983756
  ('167e698c-d49c-482c-a9e9-a2573683c296'),       -- greenly      OFFSPEND 878730647
  ('1e1e60ec-f3fc-44db-b43f-8b7773a77177'),       -- heyday       HEYDAY 803183771
  ('013165c8-a38e-4dd4-b42c-065a1c25940d'),       -- klara        938600145
  ('4b709017-e9d6-422f-a2d4-35c94f8d9794'),       -- la-fourche   LA FOURCHE 839765062
  ('6be13bcf-37c3-4f2b-9c1d-32f925fa7e9b'),       -- luce-robotics LUCE ROBOTICS 109012310
  ('536c4264-7143-44bc-a47c-11492ce01c0e'),       -- lydia        753222520
  ('2749511e-857d-4b9e-9181-fc0f0c86305b'),       -- metron       METRON 794167593
  ('64527661-4a3b-41be-ab61-e16f7ea3a9c6'),       -- newcleo      NEWCLEO 929009140
  ('929d4622-83f3-4f10-be2f-8f59b1e23850'),       -- noia-labs    NOIA LABS 103380721
  ('437ba404-3f0f-4e18-9eae-e15a6ef6e9e6'),       -- notung       NOTUNG 131977431
  ('b5861814-ffeb-433f-bcfc-abad45a60ea9'),       -- opalin       OPALIN 130760101
  ('9c9a014c-8f06-4bf0-80e9-f45a82d314ba'),       -- outline      OUTLINE 105710222
  ('ab1189b4-14f4-40c6-987c-fac8225e39c2'),       -- papkot       PAPKOT 891257636
  ('1661930d-4416-4bc5-8bde-393c0263b7ae'),       -- pennylane    PENNYLANE 880265921
  ('70531576-c4bf-4f9e-a52f-063896762de5'),       -- pigment      PIGMENT 852785914
  ('409cd2cb-ed44-4e54-98af-1cec07eebeae'),       -- pixmania     PIXMANIA 352236244
  ('74abcde1-93e6-41d0-9236-199243078b04'),       -- qonto        QONTO 819489626
  ('842f28ac-e047-4d7c-a8b3-8a82b44d44a3'),       -- resilience   RESILIENCE 893834713
  ('626d5dd4-d7ce-4b4e-81f3-5ff5e45b7a31'),       -- swan         SWAN 853827103
  ('fcb7f2b5-62ca-4a0e-adcf-1c5f906c0d69'),       -- watchfrog    WATCHFROG 484872551
  ('31f58e59-04a2-4389-828a-2df95c9c1588'),       -- zama         ZAMA 879243319
  ('f9593c90-e5c8-4549-a6bb-7ef521564223')        -- zefir        VESTA 851800235
),
target_orgs AS (SELECT DISTINCT organization_id FROM legal_entities WHERE id IN (SELECT id FROM chosen))
UPDATE legal_entities le
SET is_primary = (le.id IN (SELECT id FROM chosen)), updated_at = NOW()
WHERE le.organization_id IN (SELECT organization_id FROM target_orgs);

-- locala: lone legal entity that had no primary flag
UPDATE legal_entities SET is_primary = true, updated_at = NOW()
WHERE id = '0c6a5ece-0cf7-4fa0-b15d-61865d2d2e74';

COMMIT;
