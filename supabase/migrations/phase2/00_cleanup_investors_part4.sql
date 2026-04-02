-- =============================================================================
-- INVESTOR CLEANUP PART 4: Remaining merges and exact duplicates
-- Run in the FUNDING TRACKER SQL Editor
-- Run AFTER Part 3.
-- =============================================================================

-- Astorya: keep dba5a500 (Astorya.vc), merge 75c4070d (AstoryaVC)
DELETE FROM funding_round_investors WHERE investor_id = '75c4070d-6df9-4176-b0b9-49a0481c1f0d'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'dba5a500-af81-41a1-96a9-32687df42080');
UPDATE funding_round_investors SET investor_id = 'dba5a500-af81-41a1-96a9-32687df42080' WHERE investor_id = '75c4070d-6df9-4176-b0b9-49a0481c1f0d';
DELETE FROM investors WHERE id = '75c4070d-6df9-4176-b0b9-49a0481c1f0d';

-- Aglaé Ventures: keep b7cba44d, merge e1861bbc (Aglaé Lab)
DELETE FROM funding_round_investors WHERE investor_id = 'e1861bbc-49a6-4f3d-aa05-35f8ea389544'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'b7cba44d-c0fd-4419-a47e-6ae949f12be9');
UPDATE funding_round_investors SET investor_id = 'b7cba44d-c0fd-4419-a47e-6ae949f12be9' WHERE investor_id = 'e1861bbc-49a6-4f3d-aa05-35f8ea389544';
DELETE FROM investors WHERE id = 'e1861bbc-49a6-4f3d-aa05-35f8ea389544';

-- INCO: keep d84a241f, merge 712017d5, 3b989c7b, 100c674e, fd548330
DELETE FROM funding_round_investors WHERE investor_id IN ('712017d5-7655-4e90-9c3e-63e79711c5dc','3b989c7b-b4a0-4ab4-a538-6fb46996aa17','100c674e-0807-49a1-a370-ebfd742cbbae','fd548330-7a94-48a8-88b4-ba98bd6901c6')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'd84a241f-6755-4baa-b636-873e316a264e');
UPDATE funding_round_investors SET investor_id = 'd84a241f-6755-4baa-b636-873e316a264e' WHERE investor_id IN ('712017d5-7655-4e90-9c3e-63e79711c5dc','3b989c7b-b4a0-4ab4-a538-6fb46996aa17','100c674e-0807-49a1-a370-ebfd742cbbae','fd548330-7a94-48a8-88b4-ba98bd6901c6');
DELETE FROM investors WHERE id IN ('712017d5-7655-4e90-9c3e-63e79711c5dc','3b989c7b-b4a0-4ab4-a538-6fb46996aa17','100c674e-0807-49a1-a370-ebfd742cbbae','fd548330-7a94-48a8-88b4-ba98bd6901c6');

-- DMG Ventures: keep 8cb39250, merge b9f4a985 (DMG Promotion)
DELETE FROM funding_round_investors WHERE investor_id = 'b9f4a985-b9dd-4b19-9b45-f24ba4b1e569'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '8cb39250-16a9-4c7c-90ce-e55613a601d2');
UPDATE funding_round_investors SET investor_id = '8cb39250-16a9-4c7c-90ce-e55613a601d2' WHERE investor_id = 'b9f4a985-b9dd-4b19-9b45-f24ba4b1e569';
DELETE FROM investors WHERE id = 'b9f4a985-b9dd-4b19-9b45-f24ba4b1e569';

-- Finovam: keep 905e7122, merge eb00dfa1 (Finovam Gestion)
DELETE FROM funding_round_investors WHERE investor_id = 'eb00dfa1-48ea-42fc-a127-e777291fa55f'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '905e7122-7fd6-44ea-92c4-35bd3deb076c');
UPDATE funding_round_investors SET investor_id = '905e7122-7fd6-44ea-92c4-35bd3deb076c' WHERE investor_id = 'eb00dfa1-48ea-42fc-a127-e777291fa55f';
DELETE FROM investors WHERE id = 'eb00dfa1-48ea-42fc-a127-e777291fa55f';

-- Otium Capital: keep ece0378b, merge 6eb80759 (Otium Partners)
DELETE FROM funding_round_investors WHERE investor_id = '6eb80759-a790-4627-b215-a88e232c71b5'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'ece0378b-43d8-49c2-a798-990e80ad79d5');
UPDATE funding_round_investors SET investor_id = 'ece0378b-43d8-49c2-a798-990e80ad79d5' WHERE investor_id = '6eb80759-a790-4627-b215-a88e232c71b5';
DELETE FROM investors WHERE id = '6eb80759-a790-4627-b215-a88e232c71b5';

-- CEA Investissement: keep 003cba9c, merge 6f3b326e (CEA Investissement Citizen Capital)
DELETE FROM funding_round_investors WHERE investor_id = '6f3b326e-b1d4-481c-9197-128623a0bef4'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '003cba9c-18f0-4d94-8713-f93602a3745b');
UPDATE funding_round_investors SET investor_id = '003cba9c-18f0-4d94-8713-f93602a3745b' WHERE investor_id = '6f3b326e-b1d4-481c-9197-128623a0bef4';
DELETE FROM investors WHERE id = '6f3b326e-b1d4-481c-9197-128623a0bef4';

-- Entrepreneur First: keep e16eadd2, merge 00efe72c (Entrepreneurs First)
DELETE FROM funding_round_investors WHERE investor_id = '00efe72c-bd8d-4e25-afa6-cbaac9d41c70'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e16eadd2-99ac-424b-98a4-71a8374ea7da');
UPDATE funding_round_investors SET investor_id = 'e16eadd2-99ac-424b-98a4-71a8374ea7da' WHERE investor_id = '00efe72c-bd8d-4e25-afa6-cbaac9d41c70';
DELETE FROM investors WHERE id = '00efe72c-bd8d-4e25-afa6-cbaac9d41c70';

-- Odyssée Venture: keep de7d988d, (Business Angels Europe variant already deleted in Part 1)

-- Sorbonne Venture: keep ed1fc2bf, (by Audacia variant already deleted in Part 1)

-- Elevation Capital Partners: keep e5e1e812, merge be553c6b
DELETE FROM funding_round_investors WHERE investor_id = 'be553c6b-9372-49a2-9fac-14a3493fd532'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e5e1e812-bb54-4f81-bc38-8c081f771fa7');
UPDATE funding_round_investors SET investor_id = 'e5e1e812-bb54-4f81-bc38-8c081f771fa7' WHERE investor_id = 'be553c6b-9372-49a2-9fac-14a3493fd532';
DELETE FROM investors WHERE id = 'be553c6b-9372-49a2-9fac-14a3493fd532';

-- ─────────────────────────────────────────────────────────────────────────────
-- EXACT DUPLICATES (same name, different IDs)
-- ─────────────────────────────────────────────────────────────────────────────

-- Blast Club: keep 98fc3671, merge 03d48a7c
DELETE FROM funding_round_investors WHERE investor_id = '03d48a7c-4af9-472e-b886-1659f8f43a6b'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '98fc3671-f7d5-4fe8-bd47-3b850c244a6c');
UPDATE funding_round_investors SET investor_id = '98fc3671-f7d5-4fe8-bd47-3b850c244a6c' WHERE investor_id = '03d48a7c-4af9-472e-b886-1659f8f43a6b';
DELETE FROM investors WHERE id = '03d48a7c-4af9-472e-b886-1659f8f43a6b';

-- Caisse d'Epargne: keep e90796ff, merge 83ced95b, 23dd5527
DELETE FROM funding_round_investors WHERE investor_id IN ('83ced95b-f122-40bd-bb22-e3721f012741','23dd5527-7c89-4736-8259-8492345fdbd8')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e90796ff-f8fe-4964-a57b-8a6a88816cb1');
UPDATE funding_round_investors SET investor_id = 'e90796ff-f8fe-4964-a57b-8a6a88816cb1' WHERE investor_id IN ('83ced95b-f122-40bd-bb22-e3721f012741','23dd5527-7c89-4736-8259-8492345fdbd8');
DELETE FROM investors WHERE id IN ('83ced95b-f122-40bd-bb22-e3721f012741','23dd5527-7c89-4736-8259-8492345fdbd8');

-- Caisse d'Épargne Normandie Innovation: keep 0a52b37b, merge 8a390525
DELETE FROM funding_round_investors WHERE investor_id = '8a390525-1568-4ab2-b91e-1f6d27302338'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '0a52b37b-a79b-4654-9783-b04178f3352f');
UPDATE funding_round_investors SET investor_id = '0a52b37b-a79b-4654-9783-b04178f3352f' WHERE investor_id = '8a390525-1568-4ab2-b91e-1f6d27302338';
DELETE FROM investors WHERE id = '8a390525-1568-4ab2-b91e-1f6d27302338';

-- Caisse d'Épargne Rhône-Alpes: keep 6472a938, merge d3d420ee, e5532ccb
DELETE FROM funding_round_investors WHERE investor_id IN ('d3d420ee-f66a-40d5-98ae-623163b02541','e5532ccb-c6bb-48c1-a4b7-d3edf12907a1')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '6472a938-d3c6-4a04-bcec-2d9913037e87');
UPDATE funding_round_investors SET investor_id = '6472a938-d3c6-4a04-bcec-2d9913037e87' WHERE investor_id IN ('d3d420ee-f66a-40d5-98ae-623163b02541','e5532ccb-c6bb-48c1-a4b7-d3edf12907a1');
DELETE FROM investors WHERE id IN ('d3d420ee-f66a-40d5-98ae-623163b02541','e5532ccb-c6bb-48c1-a4b7-d3edf12907a1');

-- SISTAFUND: keep 5b5f1261, merge ebf7817f
DELETE FROM funding_round_investors WHERE investor_id = 'ebf7817f-6fc4-452a-a5a8-b3e185e908c3'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '5b5f1261-ba4c-4692-b1b1-99d7ae059c0f');
UPDATE funding_round_investors SET investor_id = '5b5f1261-ba4c-4692-b1b1-99d7ae059c0f' WHERE investor_id = 'ebf7817f-6fc4-452a-a5a8-b3e185e908c3';
DELETE FROM investors WHERE id = 'ebf7817f-6fc4-452a-a5a8-b3e185e908c3';

-- OPRTRS: keep af2ff2d8, merge 68e7d3ce (OPRTRS Club), 3cdcd0ba (OPRTRS CLUB)
DELETE FROM funding_round_investors WHERE investor_id IN ('68e7d3ce-b444-4b8d-8df9-4a927dd9802d','3cdcd0ba-7eb2-4e64-814f-11d3ab2f3a4b')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'af2ff2d8-49a4-4aed-a468-79815159664d');
UPDATE funding_round_investors SET investor_id = 'af2ff2d8-49a4-4aed-a468-79815159664d' WHERE investor_id IN ('68e7d3ce-b444-4b8d-8df9-4a927dd9802d','3cdcd0ba-7eb2-4e64-814f-11d3ab2f3a4b');
DELETE FROM investors WHERE id IN ('68e7d3ce-b444-4b8d-8df9-4a927dd9802d','3cdcd0ba-7eb2-4e64-814f-11d3ab2f3a4b');

-- FrenchFounders: keep e916774b, merge 12d1ea47, 38af347f (Frenchfounders Business Angels)
DELETE FROM funding_round_investors WHERE investor_id IN ('12d1ea47-50f9-46b9-b44d-28413b0b3f8b','38af347f-e505-415c-b729-6472b5b67f1a')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e916774b-5d16-46a3-a340-482bcbf2741c');
UPDATE funding_round_investors SET investor_id = 'e916774b-5d16-46a3-a340-482bcbf2741c' WHERE investor_id IN ('12d1ea47-50f9-46b9-b44d-28413b0b3f8b','38af347f-e505-415c-b729-6472b5b67f1a');
DELETE FROM investors WHERE id IN ('12d1ea47-50f9-46b9-b44d-28413b0b3f8b','38af347f-e505-415c-b729-6472b5b67f1a');

-- WiSeed: keep ba6f379e, merge 875b2c29
DELETE FROM funding_round_investors WHERE investor_id = '875b2c29-aeb9-45f9-93bd-391cef5c8add'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'ba6f379e-8a99-4252-8602-581b541b97a8');
UPDATE funding_round_investors SET investor_id = 'ba6f379e-8a99-4252-8602-581b541b97a8' WHERE investor_id = '875b2c29-aeb9-45f9-93bd-391cef5c8add';
DELETE FROM investors WHERE id = '875b2c29-aeb9-45f9-93bd-391cef5c8add';

-- WeLoveFounders: keep 9657aa43, merge fb90f702
DELETE FROM funding_round_investors WHERE investor_id = 'fb90f702-f47d-4cc4-808c-b17eeeabbda5'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '9657aa43-5b5b-4f73-ba28-31e5c2402fd5');
UPDATE funding_round_investors SET investor_id = '9657aa43-5b5b-4f73-ba28-31e5c2402fd5' WHERE investor_id = 'fb90f702-f47d-4cc4-808c-b17eeeabbda5';
DELETE FROM investors WHERE id = 'fb90f702-f47d-4cc4-808c-b17eeeabbda5';

-- Capagro: keep 6328e345, merge e7b82b7e (CapAgro)
DELETE FROM funding_round_investors WHERE investor_id = 'e7b82b7e-b871-4796-9c2a-6fa194e96ab9'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '6328e345-c997-420e-ab81-2fa9ebcdf00e');
UPDATE funding_round_investors SET investor_id = '6328e345-c997-420e-ab81-2fa9ebcdf00e' WHERE investor_id = 'e7b82b7e-b871-4796-9c2a-6fa194e96ab9';
DELETE FROM investors WHERE id = 'e7b82b7e-b871-4796-9c2a-6fa194e96ab9';

-- Pays de la Loire Participations: keep c6babe15, merge 0c5736a2, 5c12c15a
DELETE FROM funding_round_investors WHERE investor_id IN ('0c5736a2-6ba1-40ea-85e2-179d80c26df1','5c12c15a-9f37-497e-b42a-82e796c2cc1d')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'c6babe15-fd24-4b69-8c02-db29c933bd6a');
UPDATE funding_round_investors SET investor_id = 'c6babe15-fd24-4b69-8c02-db29c933bd6a' WHERE investor_id IN ('0c5736a2-6ba1-40ea-85e2-179d80c26df1','5c12c15a-9f37-497e-b42a-82e796c2cc1d');
DELETE FROM investors WHERE id IN ('0c5736a2-6ba1-40ea-85e2-179d80c26df1','5c12c15a-9f37-497e-b42a-82e796c2cc1d');

-- The Yield Lab: keep e9498e5f, merge ae3ffb82 (The Yield Lab Europe)
DELETE FROM funding_round_investors WHERE investor_id = 'ae3ffb82-10d9-45cc-9eb6-2abc44328424'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e9498e5f-6207-46b4-8de4-765bf0c7d569');
UPDATE funding_round_investors SET investor_id = 'e9498e5f-6207-46b4-8de4-765bf0c7d569' WHERE investor_id = 'ae3ffb82-10d9-45cc-9eb6-2abc44328424';
DELETE FROM investors WHERE id = 'ae3ffb82-10d9-45cc-9eb6-2abc44328424';

-- IRIS: keep 8316a712, merge 4e17f27b (IRIS Ventures)
DELETE FROM funding_round_investors WHERE investor_id = '4e17f27b-0466-4bad-b667-637430b62512'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '8316a712-8832-4f53-85f0-10862675cb7b');
UPDATE funding_round_investors SET investor_id = '8316a712-8832-4f53-85f0-10862675cb7b' WHERE investor_id = '4e17f27b-0466-4bad-b667-637430b62512';
DELETE FROM investors WHERE id = '4e17f27b-0466-4bad-b667-637430b62512';

-- Galion: keep 0f881129, merge 4abdd299 (Galion.exe)
DELETE FROM funding_round_investors WHERE investor_id = '4abdd299-bc2c-4b46-a60e-547bfbf5d8c3'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '0f881129-13c6-40ff-8628-d6154b503315');
UPDATE funding_round_investors SET investor_id = '0f881129-13c6-40ff-8628-d6154b503315' WHERE investor_id = '4abdd299-bc2c-4b46-a60e-547bfbf5d8c3';
DELETE FROM investors WHERE id = '4abdd299-bc2c-4b46-a60e-547bfbf5d8c3';

-- EIC: keep 5bbde5ff, merge 57990daf, 1d418e7c, b529bee7, 66ce3f5e
DELETE FROM funding_round_investors WHERE investor_id IN ('57990daf-5635-4d4d-a8f7-7de0512f63a4','1d418e7c-cabe-491f-b668-0eb240e60fb7','b529bee7-aab8-4cbe-9041-c3697b340484','66ce3f5e-946f-4470-883f-9e38d9f33582')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '5bbde5ff-ea46-42b2-98f0-f03af2ed8614');
UPDATE funding_round_investors SET investor_id = '5bbde5ff-ea46-42b2-98f0-f03af2ed8614' WHERE investor_id IN ('57990daf-5635-4d4d-a8f7-7de0512f63a4','1d418e7c-cabe-491f-b668-0eb240e60fb7','b529bee7-aab8-4cbe-9041-c3697b340484','66ce3f5e-946f-4470-883f-9e38d9f33582');
DELETE FROM investors WHERE id IN ('57990daf-5635-4d4d-a8f7-7de0512f63a4','1d418e7c-cabe-491f-b668-0eb240e60fb7','b529bee7-aab8-4cbe-9041-c3697b340484','66ce3f5e-946f-4470-883f-9e38d9f33582');
UPDATE investors SET name = 'European Innovation Council' WHERE id = '5bbde5ff-ea46-42b2-98f0-f03af2ed8614';

-- EIB: keep 2d4a083e, merge b36733f1 (European Investment Bank (EIB))
DELETE FROM funding_round_investors WHERE investor_id = 'b36733f1-6dee-4cbc-8215-249dbb393ece'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '2d4a083e-4a17-4c63-80a5-3e7f82cb4484');
UPDATE funding_round_investors SET investor_id = '2d4a083e-4a17-4c63-80a5-3e7f82cb4484' WHERE investor_id = 'b36733f1-6dee-4cbc-8215-249dbb393ece';
DELETE FROM investors WHERE id = 'b36733f1-6dee-4cbc-8215-249dbb393ece';

-- Jean-Charles Samuelian: keep aa45918a, merge 4b7b1bc3 (Jean-Charles Samuelian-Werve)
DELETE FROM funding_round_investors WHERE investor_id = '4b7b1bc3-7b2f-4dbb-9874-95c81b8c2523'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'aa45918a-088d-47ef-b42c-b1d8f894bd32');
UPDATE funding_round_investors SET investor_id = 'aa45918a-088d-47ef-b42c-b1d8f894bd32' WHERE investor_id = '4b7b1bc3-7b2f-4dbb-9874-95c81b8c2523';
DELETE FROM investors WHERE id = '4b7b1bc3-7b2f-4dbb-9874-95c81b8c2523';

-- Sodero: keep a5908599, merge 5be17707 (Sodero Gestion)
DELETE FROM funding_round_investors WHERE investor_id = '5be17707-3018-4900-9914-48ec8ad8c430'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'a5908599-7e49-4917-b3dd-d01e7fd456a6');
UPDATE funding_round_investors SET investor_id = 'a5908599-7e49-4917-b3dd-d01e7fd456a6' WHERE investor_id = '5be17707-3018-4900-9914-48ec8ad8c430';
DELETE FROM investors WHERE id = '5be17707-3018-4900-9914-48ec8ad8c430';

-- Watermelon: keep e05d7c49 (only one, already clean)

-- Final count
SELECT COUNT(*) AS remaining_investors FROM investors;
