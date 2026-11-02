-- Phase 29: Merge 43 "names differ" duplicate groups
--
-- From the 66 "names differ" review groups, these 43 are the same company under
-- two (or three) records -- rebrands, acronyms, or product/legacy names -- confirmed
-- via shared website domain, a description that names the other record, or a
-- well-known rebrand. The remaining 23 groups are NOT merged here: 14 are different
-- companies that share a SIREN by data error (to be corrected separately) and 9 need
-- further review (see data/names_differ_triage.md).
--
-- Survivor = current / brand / funded record. Re-point moves each duplicate's
-- funding_rounds, people, sectors (demoted to non-primary), programs and
-- organization_merge_map rows onto the survivor (guards skip rows the survivor
-- already has; duplicate legal_entities and leftover rows cascade when the stub
-- org is deleted).
--
-- Three duplicate rounds are intentionally NOT moved because they re-record a deal
-- the survivor already has (they cascade-delete with their stub org):
--   smartway  : Zero-Gachis Series A 2021-04-07 (= survivor's EUR10M Series A)
--   Umiami    : Swap Series A 2023-10-15      (= survivor's ~EUR32M Series A)
--   ASTRAN    : Astrachain pre-seed 2021-11   (= survivor's EUR2M pre-seed)
--
-- NOTE: the DELETE statements were run manually in the Supabase SQL editor
-- (DELETE times out over MCP).

BEGIN;
CREATE TEMP TABLE _m(dup uuid, surv uuid) ON COMMIT DROP;
INSERT INTO _m(dup,surv) VALUES
 ('d8bd49ce-e90c-4722-b0e2-f813948c8a09','18e86fc9-bc4e-42ef-9788-8e79f9a9e339'),
 ('97952e1c-e981-45ca-b5a5-83917bb1de08','911e44be-498d-4834-b61f-c8e7b8bb4a8f'),
 ('d2376137-c22d-4699-9560-c72182d5cbe1','5550e3b0-6bdb-4b3a-997e-4631a8a2fbc2'),
 ('5099f069-fd82-41b5-90ef-c2db48504d3a','cacea965-c875-487e-815c-ca3706eda837'),
 ('cbc029ac-4523-42ba-bcc2-d3876e7c9131','206b5a10-a3ec-4728-8bfd-59562b7196b7'),
 ('5adbc988-d4dd-4532-9547-7615c6d6357b','c1a6373a-4976-46b5-a1cf-b77e73471539'),
 ('46375521-9a24-4491-8563-44c4405a4f09','d54d27d1-da66-4344-9259-3586646f967b'),
 ('352e546c-8a56-4528-87f4-ec3312cf3019','272a5181-c565-45af-aa4c-1fe8ebfc1380'),
 ('298913eb-3777-477b-951b-d08200cde7a5','bc70b2b2-26b7-4c85-803c-ecb544f601fe'),
 ('55c9b059-ca28-4d20-9357-3237c4951988','5cc308ff-6fba-441f-a370-0ef481f4a47f'),
 ('96d37229-0a47-434d-81a3-eef5c31b30c2','790a8064-0daa-45c3-a24b-891077bab000'),
 ('b338c05c-13e4-421f-8f81-e9b04e87299c','78c7c2b3-5fcc-4b02-bc11-08b414279bcd'),
 ('d91592e2-2b6c-42ed-ae64-8af4793a01cc','012d5b90-eb94-4fb3-9134-5f1b0603a237'),
 ('db8b465b-65c7-4716-b950-a36f9a1b530c','77c18eed-1ee9-4f81-a55d-66babbac165f'),
 ('a99de3a6-edb4-4f36-acfc-e92f5881bc91','ea172e84-43dc-40cc-aceb-c0adb4b6e7ee'),
 ('b5bae73d-8728-4753-b49d-5403defecb54','cd708a3d-5d8b-460b-bab8-c5b7157e3355'),
 ('7b60813a-e460-4d53-8c2d-d049a167e721','433bf51d-405f-4d64-854a-8e9a4fb469f9'),
 ('92b8379e-43a2-4c3b-8866-0e7385bc1e4d','b65b0db5-df31-4087-a3cd-3a7e3610343a'),
 ('3abcb46c-8f18-40c8-9d97-eef1d90b0d1c','312ebd19-54da-4c84-8698-d7ed1adc42c2'),
 ('8b1db947-4ab7-46ab-b1c4-0c2e77a0d23c','9a433720-aaee-4687-afd9-ed74e30ab5c0'),
 ('1eed3aae-6b2a-4262-bf7c-6076aa72061d','0e0e9a1f-dc97-4010-a1b3-bf634db19436'),
 ('8cc9420a-c451-440b-8b73-2a9f04327bb5','ff6a90d3-90a2-4850-8112-0cfae32e2916'),
 ('b7bace3b-2680-47e0-87f9-78398b7915cf','98150c38-1ace-4f5b-8620-51d16ab08de7'),
 ('1167ee22-1c8a-431e-87c6-e7dbd857c8cb','9cc4ecd8-ac4a-4ef1-8cc9-b778124cc1b1'),
 ('b281f52b-cd13-47ad-9847-179c936fe36c','e21338be-e5ac-4a84-913c-a727f1fdf19a'),
 ('7188c25d-b1a5-447f-ab46-412f7822ff58','6c127cb2-927b-4574-894c-302aa705ae78'),
 ('207cad3d-8e98-4897-8b14-e9f04f50cc5d','96a054ad-7ce1-4ca1-9a7e-d7fd9b8c0d86'),
 ('7768d677-c82a-40d4-896d-c7109edaa4a2','b1fb8022-cce0-45c8-ba61-b0287c86280a'),
 ('615b83e6-a360-4d84-95b5-6dc3a257aef3','22eddafa-b7d3-4061-8931-26de12356a0f'),
 ('87dccc32-1efe-4270-892e-cb1df8594c7a','f2ffcbc9-7c72-4494-9384-b9742c30e710'),
 ('e8828979-a1e3-4b2a-bcf2-e80af125f5a3','f2ffcbc9-7c72-4494-9384-b9742c30e710'),
 ('3376f4cb-e61c-4452-b62e-4c6b135a5442','8b2119b5-12fa-4f9a-88b5-9a5176d7ab21'),
 ('7d45a8e7-90ca-4af4-8a9b-bd14fdb5e3a8','091afcf4-6c72-460c-8b76-f35eefc53b98'),
 ('f26eafd4-3c1a-4d57-ba7b-aa68e7525de7','7b51ce3f-a08a-445e-8e8d-b5caa8ea8fc1'),
 ('dd27ad07-43e8-4657-9a1f-ec86127842f4','ed7d8378-084a-4208-a979-45b1193b9385'),
 ('bcc493e7-16e2-452c-a35f-637df81a74e3','c9c70029-7fe1-4f07-9952-30de8b7c2d83'),
 ('08893251-e92f-4b96-9d70-ee8a480eded6','4f8102a1-e267-4b6c-8269-a4f0d7520c78'),
 ('be5bd518-657e-4745-aa59-489f19f28be6','9841b4c9-dd5f-407a-b8ca-e6a74897d4a0'),
 ('c101bf1a-d45d-4f08-b1fd-4c1b91d97f1a','6816a0fe-d0b5-4213-8aec-74f329b9c873'),
 ('cef6b5ab-fbf9-4f12-82bb-2f810ea2ccc2','617aac77-53f8-4d0f-95fc-5fcd961c5bf6'),
 ('cc73acac-828a-4da5-a007-0622561a657d','9b33d512-1c52-4a42-8a5b-a08c0c4c812e'),
 ('56f61638-319f-41fc-babe-c96caa0de4f1','98cebcbd-dd71-42a3-97cc-027c9669ba20'),
 ('4532dde2-6278-490b-953c-74d735f9bdf0','29d38d40-87b0-4812-ac41-52a474591f42'),
 ('375aaf81-f8d8-4ba9-bbb4-37bbb4e74f0b','69d02f5e-0a2a-4adf-87eb-f3aa5966de3c');

UPDATE funding_rounds fr SET organization_id=_m.surv FROM _m
 WHERE fr.organization_id=_m.dup AND _m.dup NOT IN ('5099f069-fd82-41b5-90ef-c2db48504d3a','be5bd518-657e-4745-aa59-489f19f28be6','c101bf1a-d45d-4f08-b1fd-4c1b91d97f1a');

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
-- Delete the 44 duplicate stub orgs (run in the Supabase SQL editor).
-- ---------------------------------------------------------------------------

DELETE FROM organizations WHERE id = 'd8bd49ce-e90c-4722-b0e2-f813948c8a09'; -- NEURONAX  (merged into Axoltis Pharma, SIREN 447817818)
DELETE FROM organizations WHERE id = '97952e1c-e981-45ca-b5a5-83917bb1de08'; -- MICROWAVE CHARACTERIZATION CENTER  (merged into MC2 Technologies, SIREN 452386121)
DELETE FROM organizations WHERE id = 'd2376137-c22d-4699-9560-c72182d5cbe1'; -- GEOCORAIL  (merged into Seacure, SIREN 539529669)
DELETE FROM organizations WHERE id = '5099f069-fd82-41b5-90ef-c2db48504d3a'; -- ZERO GACHIS  (merged into smartway, SIREN 750444697)
DELETE FROM organizations WHERE id = 'cbc029ac-4523-42ba-bcc2-d3876e7c9131'; -- GECKO BIOMEDICAL SA  (merged into Tissium, SIREN 793166299)
DELETE FROM organizations WHERE id = '5adbc988-d4dd-4532-9547-7615c6d6357b'; -- GENE ET GREENTECH  (merged into Gene&Green TK, SIREN 793845314)
DELETE FROM organizations WHERE id = '46375521-9a24-4491-8563-44c4405a4f09'; -- INSTENT  (merged into Sensome, SIREN 801623596)
DELETE FROM organizations WHERE id = '352e546c-8a56-4528-87f4-ec3312cf3019'; -- IRRAS TECHNOLOGY  (merged into Sim&Cure, SIREN 803695402)
DELETE FROM organizations WHERE id = '298913eb-3777-477b-951b-d08200cde7a5'; -- NovaRT  (merged into NovaGray, SIREN 814412672)
DELETE FROM organizations WHERE id = '55c9b059-ca28-4d20-9357-3237c4951988'; -- Earthcube  (merged into Preligens, SIREN 818503146)
DELETE FROM organizations WHERE id = '96d37229-0a47-434d-81a3-eef5c31b30c2'; -- Gilles Vallier  (merged into K-Ryol, SIREN 818670093)
DELETE FROM organizations WHERE id = 'b338c05c-13e4-421f-8f81-e9b04e87299c'; -- SAS  (merged into SMARTCATCH, SIREN 822393013)
DELETE FROM organizations WHERE id = 'd91592e2-2b6c-42ed-ae64-8af4793a01cc'; -- Interactive Autonomous DYnamic Systems  (merged into IADYS, SIREN 822704532)
DELETE FROM organizations WHERE id = 'db8b465b-65c7-4716-b950-a36f9a1b530c'; -- SCANBAT  (merged into PowerUp, SIREN 829235928)
DELETE FROM organizations WHERE id = 'a99de3a6-edb4-4f36-acfc-e92f5881bc91'; -- HIRAKLIS  (merged into Kinvent, SIREN 829348747)
DELETE FROM organizations WHERE id = 'b5bae73d-8728-4753-b49d-5403defecb54'; -- UniQom  (merged into VeriQloud, SIREN 829924638)
DELETE FROM organizations WHERE id = '7b60813a-e460-4d53-8c2d-d049a167e721'; -- SARI-SC  (merged into Dianosic, SIREN 830930889)
DELETE FROM organizations WHERE id = '92b8379e-43a2-4c3b-8866-0e7385bc1e4d'; -- Greenbig  (merged into B:Bot, SIREN 833953631)
DELETE FROM organizations WHERE id = '3abcb46c-8f18-40c8-9d97-eef1d90b0d1c'; -- PULSE  (merged into Entent, SIREN 834504862)
DELETE FROM organizations WHERE id = '8b1db947-4ab7-46ab-b1c4-0c2e77a0d23c'; -- MethaPlasm  (merged into Energo, SIREN 838969541)
DELETE FROM organizations WHERE id = '1eed3aae-6b2a-4262-bf7c-6076aa72061d'; -- LV4C  (merged into ORIXHA, SIREN 838982858)
DELETE FROM organizations WHERE id = '8cc9420a-c451-440b-8b73-2a9f04327bb5'; -- TAKALI  (merged into PLENESYS, SIREN 840607279)
DELETE FROM organizations WHERE id = 'b7bace3b-2680-47e0-87f9-78398b7915cf'; -- GanyBOT  (merged into GANYMED ROBOTICS, SIREN 840634356)
DELETE FROM organizations WHERE id = '1167ee22-1c8a-431e-87c6-e7dbd857c8cb'; -- ONCO-Boost  (merged into HEPHAISTOS-Pharma, SIREN 840990402)
DELETE FROM organizations WHERE id = 'b281f52b-cd13-47ad-9847-179c936fe36c'; -- CYS’ART  (merged into ABYS MEDICAL, SIREN 841052814)
DELETE FROM organizations WHERE id = '7188c25d-b1a5-447f-ab46-412f7822ff58'; -- KIMEA 360  (merged into Moovency, SIREN 843692559)
DELETE FROM organizations WHERE id = '207cad3d-8e98-4897-8b14-e9f04f50cc5d'; -- ARMMS  (merged into ORTHOPUS, SIREN 843788811)
DELETE FROM organizations WHERE id = '7768d677-c82a-40d4-896d-c7109edaa4a2'; -- SENSITINES  (merged into Green Impulse, SIREN 847746997)
DELETE FROM organizations WHERE id = '615b83e6-a360-4d84-95b5-6dc3a257aef3'; -- OCEAN Diagnostics  (merged into OCEAN Dx, SIREN 849349642)
DELETE FROM organizations WHERE id = '87dccc32-1efe-4270-892e-cb1df8594c7a'; -- PROQURE  (merged into Pasqal, SIREN 849441522)
DELETE FROM organizations WHERE id = 'e8828979-a1e3-4b2a-bcf2-e80af125f5a3'; -- Pasqal SAS  (merged into Pasqal, SIREN 849441522)
DELETE FROM organizations WHERE id = '3376f4cb-e61c-4452-b62e-4c6b135a5442'; -- IO_ORPHA  (merged into Apmonia Therapeutics, SIREN 849959390)
DELETE FROM organizations WHERE id = '7d45a8e7-90ca-4af4-8a9b-bd14fdb5e3a8'; -- WoundLAB  (merged into GRAPHEAL, SIREN 850364423)
DELETE FROM organizations WHERE id = 'f26eafd4-3c1a-4d57-ba7b-aa68e7525de7'; -- NextHSM  (merged into CryptoNext, SIREN 851589770)
DELETE FROM organizations WHERE id = 'dd27ad07-43e8-4657-9a1f-ec86127842f4'; -- Studio For All  (merged into Photoroom, SIREN 853059384)
DELETE FROM organizations WHERE id = 'bcc493e7-16e2-452c-a35f-637df81a74e3'; -- Mangrove  (merged into Arkhn, SIREN 853328201)
DELETE FROM organizations WHERE id = '08893251-e92f-4b96-9d70-ee8a480eded6'; -- MEDICING  (merged into Diagnoly, SIREN 882659360)
DELETE FROM organizations WHERE id = 'be5bd518-657e-4745-aa59-489f19f28be6'; -- Swap  (merged into Umiami, SIREN 883899478)
DELETE FROM organizations WHERE id = 'c101bf1a-d45d-4f08-b1fd-4c1b91d97f1a'; -- Astrachain  (merged into ASTRAN, SIREN 897590592)
DELETE FROM organizations WHERE id = 'cef6b5ab-fbf9-4f12-82bb-2f810ea2ccc2'; -- ALPHAIOTA  (merged into Vizzia, SIREN 899832901)
DELETE FROM organizations WHERE id = 'cc73acac-828a-4da5-a007-0622561a657d'; -- Bon Vivant  (merged into Verley, SIREN 908328487)
DELETE FROM organizations WHERE id = '56f61638-319f-41fc-babe-c96caa0de4f1'; -- DEESS  (merged into Cosma, SIREN 910040658)
DELETE FROM organizations WHERE id = '4532dde2-6278-490b-953c-74d735f9bdf0'; -- CURE-HD  (merged into HuntX Pharma, SIREN 921853990)
DELETE FROM organizations WHERE id = '375aaf81-f8d8-4ba9-bbb4-37bbb4e74f0b'; -- TELLUS AI  (merged into Celest Science, SIREN 949645600)
