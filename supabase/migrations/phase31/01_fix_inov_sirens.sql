-- Phase 31: Correct mis-assigned SIRENs on inov legal entities
--
-- The legacy i-Nov import carried sporadic wrong SIRENs (each copied faithfully from the
-- official i-Nov winners dataset, which itself has a scrambled SIREN column for a subset of
-- rows). A full pass verified all 548 inov legal_entities against the French business
-- registry (recherche-entreprises.api.gouv.fr): 481 matched, 66 were flagged. A second
-- name->SIREN lookup confirmed the correct number for 30 of the flagged records (the rest
-- are false positives -- rebrands/legal-name/acquisition -- where the stored SIREN is
-- actually correct, or could not be confidently resolved; left unchanged).
--
-- This corrects the 30 confirmed records (legal_entities.siren -> registry-correct value).
-- legal_entities has no unique constraint on siren, so reassigning the scramble chain is safe.
-- Mapping (db_name | old_siren -> correct_siren):
--   ANANKE | 810683078 -> 832784615 | le=b28b01f6-6872-41e8-9050-ff5b9ba1e80d
--   BIROTA | 832111967 -> 830590659 | le=1c44782e-6982-4594-b8f2-568d5971927a
--   CONSTRUCTION 3D | 831687009 -> 844265017 | le=ae679318-5a32-406e-b1fe-4da4ac1e8126
--   CT2MC | 841218118 -> 539201244 | le=8160546c-9a70-4bff-973a-e1902c52af75
--   CWS MOREL | 811732700 -> 823946595 | le=86da4d37-b1eb-4cc0-bad2-b9e9507000b4
--   D-ICE Engineering | 814888798 -> 809273329 | le=c0f1f424-fa20-4b12-9443-0b28de276147
--   DASHDOC | 800970212 -> 813603222 | le=6d65156d-991b-4da1-88c8-a86a87e600d5
--   DigiMobee | 834554982 -> 793002908 | le=dfe47b12-6f48-409f-b5f3-4f53c28ed3ba
--   ENWIRES | 793002908 -> 819431834 | le=5e6ff66e-4de7-4c96-9d27-41c7c2e7a3f4
--   ETS DUBRULLE | 447350018 -> 498173038 | le=c7f9f3a0-ede1-4934-b355-51df22541363
--   GEOLITH | 810876177 -> 818024234 | le=d7daef6f-391f-4e6c-84f6-92c600764afa
--   INALVE | 830590659 -> 819699893 | le=d493d7cd-5d02-4282-ba7e-0e94a6f7e912
--   ITinSell | 832948962 -> 913164141 | le=d7ed43b3-e0a4-4140-a1ab-ca8e41bfa443
--   KAIKO | 807388376 -> 949756399 | le=0e5898b0-f0b4-4ca1-b7a5-1e0736aa94d9
--   LODIAG | 522782481 -> 834554982 | le=61c17e3f-0a5b-4281-b95a-481f75aed205
--   LOUISE | 914943774 -> 520864950 | le=46dfebfb-1aed-40df-b1f3-88fef031e53a
--   MOBA | 850032491 -> 851163188 | le=3c274a68-ba37-4916-a8b7-0c984f4b2bf5
--   MODETIC | 498845064 -> 480278308 | le=692cfd23-a01d-40fe-9a7b-e32e290ecea3
--   Nextmind | 832089031 -> 982251902 | le=b5685a4f-a2f5-4bc6-9778-eb407ce49904
--   SAS Consilium | 840239271 -> 841795149 | le=3504065f-2fa0-4bf1-9a83-a4c1e2456b9b
--   SEREEMA SA | 433386554 -> 810683078 | le=163997c9-836b-4594-9a6e-e15c8fbd607a
--   SEVA Technologies | 794167593 -> 432103141 | le=9e3aa031-aeb1-42ef-ad37-aa5620596258
--   SPIREC | 484872551 -> 433386554 | le=4f5739a0-863d-44c9-bd7d-09ee852cb092
--   SQUADRONE SYSTEM | 803183771 -> 800970212 | le=61c55973-6369-4ec8-9adf-b289709ece14
--   Solar Cloth System | 809273329 -> 800532822 | le=7adbcbb8-6aff-4465-87df-71588eb8ae6a
--   VEL'CO | 818024234 -> 819556168 | le=b6b80eb2-9712-4683-b728-bc48d830a60a
--   CITYTAPS | 432103141 -> 811732700 | le=fe3b7ad0-864f-4b03-ac9e-56fe4ba9d30f
--   Green Communications | 833737653 -> 522782481 | le=6523ffa3-211c-46c1-9eed-441cba4ef3a7
--   EOLINK SAS | 823946595 -> 814888798 | le=0ab54bd0-1fd6-4973-ad4f-a37fddaf90ec
--   AUTONOMOUS CLEAN WATER APPLIANCE  ROBOTICS | 539201244 -> 841218118 | le=99887a10-50da-40fc-8bdb-8b970ee41579

BEGIN;
WITH fix(le_id, correct_siren) AS (VALUES
 ('b28b01f6-6872-41e8-9050-ff5b9ba1e80d','832784615'),
 ('1c44782e-6982-4594-b8f2-568d5971927a','830590659'),
 ('ae679318-5a32-406e-b1fe-4da4ac1e8126','844265017'),
 ('8160546c-9a70-4bff-973a-e1902c52af75','539201244'),
 ('86da4d37-b1eb-4cc0-bad2-b9e9507000b4','823946595'),
 ('c0f1f424-fa20-4b12-9443-0b28de276147','809273329'),
 ('6d65156d-991b-4da1-88c8-a86a87e600d5','813603222'),
 ('dfe47b12-6f48-409f-b5f3-4f53c28ed3ba','793002908'),
 ('5e6ff66e-4de7-4c96-9d27-41c7c2e7a3f4','819431834'),
 ('c7f9f3a0-ede1-4934-b355-51df22541363','498173038'),
 ('d7daef6f-391f-4e6c-84f6-92c600764afa','818024234'),
 ('d493d7cd-5d02-4282-ba7e-0e94a6f7e912','819699893'),
 ('d7ed43b3-e0a4-4140-a1ab-ca8e41bfa443','913164141'),
 ('0e5898b0-f0b4-4ca1-b7a5-1e0736aa94d9','949756399'),
 ('61c17e3f-0a5b-4281-b95a-481f75aed205','834554982'),
 ('46dfebfb-1aed-40df-b1f3-88fef031e53a','520864950'),
 ('3c274a68-ba37-4916-a8b7-0c984f4b2bf5','851163188'),
 ('692cfd23-a01d-40fe-9a7b-e32e290ecea3','480278308'),
 ('b5685a4f-a2f5-4bc6-9778-eb407ce49904','982251902'),
 ('3504065f-2fa0-4bf1-9a83-a4c1e2456b9b','841795149'),
 ('163997c9-836b-4594-9a6e-e15c8fbd607a','810683078'),
 ('9e3aa031-aeb1-42ef-ad37-aa5620596258','432103141'),
 ('4f5739a0-863d-44c9-bd7d-09ee852cb092','433386554'),
 ('61c55973-6369-4ec8-9adf-b289709ece14','800970212'),
 ('7adbcbb8-6aff-4465-87df-71588eb8ae6a','800532822'),
 ('b6b80eb2-9712-4683-b728-bc48d830a60a','819556168'),
 ('fe3b7ad0-864f-4b03-ac9e-56fe4ba9d30f','811732700'),
 ('6523ffa3-211c-46c1-9eed-441cba4ef3a7','522782481'),
 ('0ab54bd0-1fd6-4973-ad4f-a37fddaf90ec','814888798'),
 ('99887a10-50da-40fc-8bdb-8b970ee41579','841218118'))
UPDATE legal_entities le SET siren = f.correct_siren
  FROM fix f WHERE le.id = f.le_id::uuid;
COMMIT;
