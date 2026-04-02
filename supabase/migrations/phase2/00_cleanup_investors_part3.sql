-- =============================================================================
-- INVESTOR CLEANUP PART 3: More name variant merges
-- Run in the FUNDING TRACKER SQL Editor
-- Run AFTER Part 2.
-- =============================================================================

-- Yellow: keep dab29f6f, merge a8a13a77 (Yellow Ventures)
DELETE FROM funding_round_investors WHERE investor_id = 'a8a13a77-a8fe-478c-a6ef-ad0419a6ff68'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'dab29f6f-a4d5-4032-98cc-b3fb8b89d707');
UPDATE funding_round_investors SET investor_id = 'dab29f6f-a4d5-4032-98cc-b3fb8b89d707' WHERE investor_id = 'a8a13a77-a8fe-478c-a6ef-ad0419a6ff68';
DELETE FROM investors WHERE id = 'a8a13a77-a8fe-478c-a6ef-ad0419a6ff68';

-- Wind: keep 36aaf6da, merge 67bc212b (Wind Capital)
DELETE FROM funding_round_investors WHERE investor_id = '67bc212b-fb14-4401-b17e-7c69f4827acd'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '36aaf6da-e0fa-4faa-acfd-6e7a2bdd5107');
UPDATE funding_round_investors SET investor_id = '36aaf6da-e0fa-4faa-acfd-6e7a2bdd5107' WHERE investor_id = '67bc212b-fb14-4401-b17e-7c69f4827acd';
DELETE FROM investors WHERE id = '67bc212b-fb14-4401-b17e-7c69f4827acd';

-- True: keep e493db0c, merge 052ebbe4 (True Capital), 388059f9 (True Global)
DELETE FROM funding_round_investors WHERE investor_id IN ('052ebbe4-a707-47df-997a-93d46451a198','388059f9-754d-4dbd-ac70-654468eb6bf2')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'e493db0c-5bdd-4d68-b207-9789e71529a2');
UPDATE funding_round_investors SET investor_id = 'e493db0c-5bdd-4d68-b207-9789e71529a2' WHERE investor_id IN ('052ebbe4-a707-47df-997a-93d46451a198','388059f9-754d-4dbd-ac70-654468eb6bf2');
DELETE FROM investors WHERE id IN ('052ebbe4-a707-47df-997a-93d46451a198','388059f9-754d-4dbd-ac70-654468eb6bf2');

-- Tomcat: keep 39dd25ea, merge ccc096ae (Tomcat Invest), 2c2e62cc (Tomcat Venture)
DELETE FROM funding_round_investors WHERE investor_id IN ('ccc096ae-febb-447c-a240-2d7b73280f08','2c2e62cc-c47c-4f41-9d8f-3921a1cbfaf1')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '39dd25ea-3f87-4bbf-a004-353a3ccb050e');
UPDATE funding_round_investors SET investor_id = '39dd25ea-3f87-4bbf-a004-353a3ccb050e' WHERE investor_id IN ('ccc096ae-febb-447c-a240-2d7b73280f08','2c2e62cc-c47c-4f41-9d8f-3921a1cbfaf1');
DELETE FROM investors WHERE id IN ('ccc096ae-febb-447c-a240-2d7b73280f08','2c2e62cc-c47c-4f41-9d8f-3921a1cbfaf1');

-- Supercapital: keep f5855621, merge 435d8454 (Super Capital)
DELETE FROM funding_round_investors WHERE investor_id = '435d8454-99e9-4528-8d06-1f0ec4fd021d'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'f5855621-c9e3-4424-9ec0-288f222ecb6f');
UPDATE funding_round_investors SET investor_id = 'f5855621-c9e3-4424-9ec0-288f222ecb6f' WHERE investor_id = '435d8454-99e9-4528-8d06-1f0ec4fd021d';
DELETE FROM investors WHERE id = '435d8454-99e9-4528-8d06-1f0ec4fd021d';

-- Clover: keep ff253ccd, merge 61379c65 (Clover VC)
DELETE FROM funding_round_investors WHERE investor_id = '61379c65-ac04-4ff1-8ca3-936df4d79790'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'ff253ccd-9630-4919-8bd9-a598401ced8c');
UPDATE funding_round_investors SET investor_id = 'ff253ccd-9630-4919-8bd9-a598401ced8c' WHERE investor_id = '61379c65-ac04-4ff1-8ca3-936df4d79790';
DELETE FROM investors WHERE id = '61379c65-ac04-4ff1-8ca3-936df4d79790';

-- Climate Club: keep 45b45e24, merge 27dfbf24 (Climate Club VC)
DELETE FROM funding_round_investors WHERE investor_id = '27dfbf24-f60d-47a0-836c-1d0236ab6b67'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '45b45e24-286d-4b44-a062-a22ae8dd9d9f');
UPDATE funding_round_investors SET investor_id = '45b45e24-286d-4b44-a062-a22ae8dd9d9f' WHERE investor_id = '27dfbf24-f60d-47a0-836c-1d0236ab6b67';
DELETE FROM investors WHERE id = '27dfbf24-f60d-47a0-836c-1d0236ab6b67';

-- Endgame: keep b42acf22, merge bf79ca2d (Endgame Capital)
DELETE FROM funding_round_investors WHERE investor_id = 'bf79ca2d-b7be-4b51-b582-caed77ebdd8f'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'b42acf22-164b-4029-bb76-f3cddded0443');
UPDATE funding_round_investors SET investor_id = 'b42acf22-164b-4029-bb76-f3cddded0443' WHERE investor_id = 'bf79ca2d-b7be-4b51-b582-caed77ebdd8f';
DELETE FROM investors WHERE id = 'bf79ca2d-b7be-4b51-b582-caed77ebdd8f';

-- Drysdale: keep 20ea10d7, merge af68f476 (Drysdale Ventures)
DELETE FROM funding_round_investors WHERE investor_id = 'af68f476-8218-4e4f-8269-42e67fef6bb3'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '20ea10d7-3a59-4af2-b077-0d1db30e8392');
UPDATE funding_round_investors SET investor_id = '20ea10d7-3a59-4af2-b077-0d1db30e8392' WHERE investor_id = 'af68f476-8218-4e4f-8269-42e67fef6bb3';
DELETE FROM investors WHERE id = 'af68f476-8218-4e4f-8269-42e67fef6bb3';

-- DST Global: keep 8597616e, merge 41e8c823 (DST Global Partners)
DELETE FROM funding_round_investors WHERE investor_id = '41e8c823-c152-4f15-8ee6-e6d67539b390'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '8597616e-d22d-4f80-96ba-225931e1a907');
UPDATE funding_round_investors SET investor_id = '8597616e-d22d-4f80-96ba-225931e1a907' WHERE investor_id = '41e8c823-c152-4f15-8ee6-e6d67539b390';
DELETE FROM investors WHERE id = '41e8c823-c152-4f15-8ee6-e6d67539b390';

-- Expansion Ventures: keep dc523822, merge 18c36229 (Expansion Venture Capital)
DELETE FROM funding_round_investors WHERE investor_id = '18c36229-b91f-400c-9dd1-ae0e3beb192a'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'dc523822-6e7a-4178-bf41-94eb2aa39f4a');
UPDATE funding_round_investors SET investor_id = 'dc523822-6e7a-4178-bf41-94eb2aa39f4a' WHERE investor_id = '18c36229-b91f-400c-9dd1-ae0e3beb192a';
DELETE FROM investors WHERE id = '18c36229-b91f-400c-9dd1-ae0e3beb192a';

-- Sharpstone: keep 9e78724d, merge 5bad9ec9 (Sharpstone Capital)
DELETE FROM funding_round_investors WHERE investor_id = '5bad9ec9-91c3-4285-a72f-7d890cd70248'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '9e78724d-a005-4962-9cef-e89b76cbf5df');
UPDATE funding_round_investors SET investor_id = '9e78724d-a005-4962-9cef-e89b76cbf5df' WHERE investor_id = '5bad9ec9-91c3-4285-a72f-7d890cd70248';
DELETE FROM investors WHERE id = '5bad9ec9-91c3-4285-a72f-7d890cd70248';

-- OVNI: keep 5258f32d, merge 4ee348f2 (OVNI Capital)
DELETE FROM funding_round_investors WHERE investor_id = '4ee348f2-1c76-4362-8e83-dc07a4bd4bfa'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '5258f32d-bbc9-4ce8-9ef7-85e191bef824');
UPDATE funding_round_investors SET investor_id = '5258f32d-bbc9-4ce8-9ef7-85e191bef824' WHERE investor_id = '4ee348f2-1c76-4362-8e83-dc07a4bd4bfa';
DELETE FROM investors WHERE id = '4ee348f2-1c76-4362-8e83-dc07a4bd4bfa';

-- Founders Future: keep ee30ad6a, merge 7f6cf2b9 (Founders Futures)
DELETE FROM funding_round_investors WHERE investor_id = '7f6cf2b9-a7f4-4a5b-b3f7-08e2894faa80'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = 'ee30ad6a-96eb-4799-b840-8d4dd044a447');
UPDATE funding_round_investors SET investor_id = 'ee30ad6a-96eb-4799-b840-8d4dd044a447' WHERE investor_id = '7f6cf2b9-a7f4-4a5b-b3f7-08e2894faa80';
DELETE FROM investors WHERE id = '7f6cf2b9-a7f4-4a5b-b3f7-08e2894faa80';

-- Plug and Play: keep 9b008a61, merge 231cb49e (Plug & Play Ventures), 8b49169e (Plug and Play Ventures)
DELETE FROM funding_round_investors WHERE investor_id IN ('231cb49e-6226-48da-b2f1-51357e906116','8b49169e-e971-43b1-810e-82fea82b2b99')
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '9b008a61-5e93-44b1-a5e3-fb23b7dd1138');
UPDATE funding_round_investors SET investor_id = '9b008a61-5e93-44b1-a5e3-fb23b7dd1138' WHERE investor_id IN ('231cb49e-6226-48da-b2f1-51357e906116','8b49169e-e971-43b1-810e-82fea82b2b99');
DELETE FROM investors WHERE id IN ('231cb49e-6226-48da-b2f1-51357e906116','8b49169e-e971-43b1-810e-82fea82b2b99');

-- Verve Ventures: keep 3267c0d7, merge 5195b593 (Verve Capital)
DELETE FROM funding_round_investors WHERE investor_id = '5195b593-3ed1-408d-8287-922b44e639fe'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '3267c0d7-f688-4667-879e-70b072ca2df5');
UPDATE funding_round_investors SET investor_id = '3267c0d7-f688-4667-879e-70b072ca2df5' WHERE investor_id = '5195b593-3ed1-408d-8287-922b44e639fe';
DELETE FROM investors WHERE id = '5195b593-3ed1-408d-8287-922b44e639fe';

-- Cathay Innovation: keep 13298a07, merge 59d8cb56 (Cathay Venture)
DELETE FROM funding_round_investors WHERE investor_id = '59d8cb56-d7bb-42a2-8302-8c29b0f519e3'
  AND funding_round_id IN (SELECT funding_round_id FROM funding_round_investors WHERE investor_id = '13298a07-80ce-471e-9399-c7e788f520b0');
UPDATE funding_round_investors SET investor_id = '13298a07-80ce-471e-9399-c7e788f520b0' WHERE investor_id = '59d8cb56-d7bb-42a2-8302-8c29b0f519e3';
DELETE FROM investors WHERE id = '59d8cb56-d7bb-42a2-8302-8c29b0f519e3';

SELECT 'Part 3a complete' AS status;
