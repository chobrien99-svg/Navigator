-- Phase 26: Merge name-variant duplicate organization records (batch of 55)
--
-- From the 129-SIREN duplicate report, these 55 groups are name variants of the
-- same company (case / spacing / punctuation / legal-form suffix / year). In each
-- group exactly one record carries the funding history; it is kept as the survivor
-- and the stub(s) are merged into it and deleted. (8 further variant groups where
-- more than one record held funding rounds were intentionally left for manual review.)
--
-- The stubs only hold legal_entities / organization_people / program_organizations
-- rows (verified); the guarded UPDATEs move the non-duplicate ones to the survivor,
-- and the remaining duplicates are removed by ON DELETE CASCADE when the stub org
-- is deleted.
--
-- Idempotent: the UPDATEs match nothing once applied; the DELETEs are no-ops once
-- the stub rows are gone.
--
-- NOTE: the DELETE statements were run manually in the Supabase SQL editor because
-- DELETE statements time out over the MCP connection.

BEGIN;

-- Re-point the duplicate stubs' child rows onto the survivor (non-destructive).
-- Stubs only ever hold legal_entities / organization_people / program_organizations rows;
-- guards drop rows the survivor already has (those cascade-delete with the stub org).

WITH m(dup,surv) AS (VALUES
    ('5d788a93-8960-4853-aa8c-e16e6c6f1b6f'::uuid,'f2431553-67ba-4541-8907-d7122113a0cb'::uuid),
    ('f8e36a2c-c64d-4f60-a152-3a8ee144fb2d'::uuid,'406483a7-fd65-429a-9d10-ac2399705c0a'::uuid),
    ('f0ad5128-4cb0-434b-b0dc-4301de623987'::uuid,'e976297e-378e-44d0-8ac8-93e4e96ec295'::uuid),
    ('96604567-a149-4ce9-bf57-46789c7d4f03'::uuid,'a93fb9e8-3088-4561-8b0d-4492039e70b9'::uuid),
    ('f0167502-6914-4078-a9a0-135caff3ce9c'::uuid,'a12c0812-2b16-4bd4-b9eb-3f0319c4c7fb'::uuid),
    ('4ddb331d-503b-4580-bcb3-ba24f3d8e7f2'::uuid,'ade174da-a097-4ba6-9426-cef2a9393b9a'::uuid),
    ('2c85ccee-8daa-4f47-80c4-cd2b057c1e78'::uuid,'741627ef-3d1b-40d8-933f-7fc812e25221'::uuid),
    ('10074147-7abb-4581-8a39-e204e2125d16'::uuid,'637c3812-c97d-46ee-8455-1ac07314ce48'::uuid),
    ('9dc9a30b-a8d8-4e5e-a26d-10b84f7fecb8'::uuid,'d3fe0c4d-3890-48d0-b955-106dc0e29844'::uuid),
    ('b0a10e64-b4f2-4a07-bf84-d7bc4bb56d98'::uuid,'61a94d84-560c-452c-a2b3-2ec8b7a8bd7c'::uuid),
    ('1f097857-718e-4ba8-91a2-fac14691cf74'::uuid,'ac2eff68-47eb-453c-a7c8-deb960d1e0e2'::uuid),
    ('af132c9f-35b8-4d90-8e42-a017b468a29d'::uuid,'bedd4113-ba58-4bb9-8821-87c0d8242a7a'::uuid),
    ('6b2e82f1-44f0-4032-97a2-facdfbf83522'::uuid,'0cb566a1-38d6-4bd0-bf46-daf8ee73155e'::uuid),
    ('3d875c9c-cb21-4cf8-a731-ce9bc36e33bb'::uuid,'7b50ae34-4cc8-4b17-91b2-9ffa6d22cd42'::uuid),
    ('4dd63341-6f78-4dc4-b656-2ac773eb8e9a'::uuid,'22a9045e-4068-43fc-8fb6-026f9e0718e6'::uuid),
    ('b4113e89-d0c4-4fca-a478-17382f1e0e4d'::uuid,'5cf2d2bd-b473-4101-93d4-8af0a7e81bd6'::uuid),
    ('55c6edf1-d72e-4a6a-81ef-37029749d19a'::uuid,'ee33a599-1872-46e3-b743-ac4637941095'::uuid),
    ('8ddeabaf-ba30-44a2-b4ad-c59d8401afbe'::uuid,'b8f11385-0471-4b39-be4b-0efb759bd06a'::uuid),
    ('20148e38-0cbd-4e1d-8012-2d3b3ae4ace0'::uuid,'6ca5dcd5-ebd1-4dba-903b-f524a1dfe742'::uuid),
    ('b18cc7d1-531d-4575-82a8-844b93a4f525'::uuid,'89c8bfc7-1136-407c-83a5-18a3c8f8e1db'::uuid),
    ('26542a5c-3ef1-4cf4-8d28-5abe37004a8d'::uuid,'e3e8f2fe-2d3b-4c1a-b24a-7b8828661f46'::uuid),
    ('bc5630c7-f064-4180-af9f-98ba9770d1fe'::uuid,'7f6d1afa-9ac5-4030-9f20-6182582fd61d'::uuid),
    ('30346274-c05f-4fb8-b388-4a33264814ed'::uuid,'0e15a39c-937c-496e-9bae-693639acb8e1'::uuid),
    ('b02ebfd7-7fd1-40a0-a4b0-a3c6067e753c'::uuid,'3494a805-c52d-46b7-9bfc-1bc9c0061130'::uuid),
    ('817b4e52-31f4-4865-82a5-781d8628d80a'::uuid,'a77f2024-f533-4d21-8e20-4642a196a7ae'::uuid),
    ('74f719b0-cf16-4684-960f-b298bccf5e19'::uuid,'3a763d6e-df34-4860-b57e-e1468d0de890'::uuid),
    ('ad6bfece-9594-439a-b4f4-47bec353a0c6'::uuid,'f7edee3f-2ae2-4cf2-8113-3c63be825680'::uuid),
    ('2c4d4d42-26c4-4050-98d4-d4830df6ee25'::uuid,'90dfbd41-7c69-4dba-8490-fa3b9ef5a94b'::uuid),
    ('ff296f67-4010-40d6-95c2-73979e58e2a6'::uuid,'baca28f6-011f-44ec-b192-cf0515a09897'::uuid),
    ('771ed806-3c71-45d8-8c65-07fdacc43cc1'::uuid,'3b6b9fdd-cd9f-4acc-83b2-375f5e09b23d'::uuid),
    ('f88006e8-7dd3-4296-a8b2-baf234358d85'::uuid,'c3efc8b8-839a-4168-ab37-e76add77f2d7'::uuid),
    ('1c497091-02e7-4b17-879a-fc55565f2e05'::uuid,'06b74880-a992-4814-a9d2-93df41803e3a'::uuid),
    ('e05ea736-996b-4ab3-88fb-345b5b32e430'::uuid,'12be6506-492d-43d9-be7f-39b01cdd17bd'::uuid),
    ('d55b9846-a48e-4da8-afe3-3d78bf00ab09'::uuid,'41cfebc3-cf6f-499c-9005-ced5c1bc7df9'::uuid),
    ('31ff1eec-2922-4f2e-9f98-54935552f93c'::uuid,'36d1d1e5-97cb-45c2-a6d5-35a203364553'::uuid),
    ('2b977f6f-dae8-426a-b1a9-44d6da559931'::uuid,'b351f380-a216-4123-b0be-e6c435ff6629'::uuid),
    ('69d94aaf-4603-4173-b891-19c8e293bd24'::uuid,'a175ba59-b697-4fd3-b212-15e2fd97882b'::uuid),
    ('cb0e5dcf-6d5b-429c-afc3-255d3f108cd0'::uuid,'2416f7b4-2cbf-400d-b130-1189a5d6a0b6'::uuid),
    ('d1119a46-10a5-4ab7-b51d-63b4b1f83be7'::uuid,'3fe95008-151d-439e-bc70-31866a910973'::uuid),
    ('647d7c1c-6a4f-4e7a-a455-95686b3c32f1'::uuid,'4245a781-6ca1-4371-abc4-6f6f65ab4143'::uuid),
    ('31540f37-f666-418f-8775-1af8dba485c8'::uuid,'b4d5e746-62fd-4ab7-8b78-065d8a163c8e'::uuid),
    ('38e99304-6dcd-49c0-a67e-a9772e17797d'::uuid,'c17dcc5b-facc-406e-a723-7151f520982f'::uuid),
    ('e2bb4079-5eaa-45c3-91f1-20595ef582c5'::uuid,'0f2e6c54-c876-4590-9d59-340448316fe2'::uuid),
    ('09b03e2e-5ced-4938-9d51-d9c9a048b1e5'::uuid,'1ed7b0f7-6e0e-4e27-8584-d4980ee6eb12'::uuid),
    ('8e3a73d0-aede-4f60-a29a-8fb1d7b54298'::uuid,'47b05d1a-6356-4e2a-9c82-0e93012bd985'::uuid),
    ('dda39804-b5b0-4e05-a8dd-3c401b18fb91'::uuid,'9c5d726c-cdf0-40d6-bafd-f016a7d5b908'::uuid),
    ('2a41cd14-bae1-495c-905a-89695109f5b1'::uuid,'44464d78-ca6c-4505-9f5c-d563c1cd0fb4'::uuid),
    ('c9645cce-3b8a-4e5e-9c7c-31e675577eec'::uuid,'49b839cc-7d32-417e-a837-9eedb32b362c'::uuid),
    ('cbb9a111-7140-47d2-8f32-f3c70ba82c42'::uuid,'923c25c6-2503-478d-8e74-d180788df85f'::uuid),
    ('e31637b0-cb9e-4f53-bfaa-02e4b4b2c05a'::uuid,'b1438a54-4892-41ff-aac2-c1eee6aa9b5f'::uuid),
    ('7a9c43da-1505-4a8e-9e75-a32f05fa29d1'::uuid,'17476172-92e3-4572-8938-1ba57c0c3f03'::uuid),
    ('091b31d6-c54f-4783-ac3e-498ca38ed008'::uuid,'a746b2c3-63dd-42fb-919e-0e2917ed70d4'::uuid),
    ('b2e5d02b-f6fc-4f2f-abf3-e5ba4bfc5eee'::uuid,'f22e31c4-77d2-4819-8c9c-6084c49839dd'::uuid),
    ('32831b6d-2696-4e2d-8620-9b5d522c165a'::uuid,'0d96dc86-fcc7-4731-bc3c-a1dfe1cf7305'::uuid),
    ('9856d33f-91cb-4ef8-a132-9f2e3b3eef1a'::uuid,'c4d05308-14a7-41dd-af04-014549a45b6f'::uuid))
UPDATE legal_entities le SET organization_id = m.surv
  FROM m WHERE le.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM legal_entities l2
                     WHERE l2.organization_id = m.surv AND l2.siren = le.siren);

WITH m(dup,surv) AS (VALUES
    ('5d788a93-8960-4853-aa8c-e16e6c6f1b6f'::uuid,'f2431553-67ba-4541-8907-d7122113a0cb'::uuid),
    ('f8e36a2c-c64d-4f60-a152-3a8ee144fb2d'::uuid,'406483a7-fd65-429a-9d10-ac2399705c0a'::uuid),
    ('f0ad5128-4cb0-434b-b0dc-4301de623987'::uuid,'e976297e-378e-44d0-8ac8-93e4e96ec295'::uuid),
    ('96604567-a149-4ce9-bf57-46789c7d4f03'::uuid,'a93fb9e8-3088-4561-8b0d-4492039e70b9'::uuid),
    ('f0167502-6914-4078-a9a0-135caff3ce9c'::uuid,'a12c0812-2b16-4bd4-b9eb-3f0319c4c7fb'::uuid),
    ('4ddb331d-503b-4580-bcb3-ba24f3d8e7f2'::uuid,'ade174da-a097-4ba6-9426-cef2a9393b9a'::uuid),
    ('2c85ccee-8daa-4f47-80c4-cd2b057c1e78'::uuid,'741627ef-3d1b-40d8-933f-7fc812e25221'::uuid),
    ('10074147-7abb-4581-8a39-e204e2125d16'::uuid,'637c3812-c97d-46ee-8455-1ac07314ce48'::uuid),
    ('9dc9a30b-a8d8-4e5e-a26d-10b84f7fecb8'::uuid,'d3fe0c4d-3890-48d0-b955-106dc0e29844'::uuid),
    ('b0a10e64-b4f2-4a07-bf84-d7bc4bb56d98'::uuid,'61a94d84-560c-452c-a2b3-2ec8b7a8bd7c'::uuid),
    ('1f097857-718e-4ba8-91a2-fac14691cf74'::uuid,'ac2eff68-47eb-453c-a7c8-deb960d1e0e2'::uuid),
    ('af132c9f-35b8-4d90-8e42-a017b468a29d'::uuid,'bedd4113-ba58-4bb9-8821-87c0d8242a7a'::uuid),
    ('6b2e82f1-44f0-4032-97a2-facdfbf83522'::uuid,'0cb566a1-38d6-4bd0-bf46-daf8ee73155e'::uuid),
    ('3d875c9c-cb21-4cf8-a731-ce9bc36e33bb'::uuid,'7b50ae34-4cc8-4b17-91b2-9ffa6d22cd42'::uuid),
    ('4dd63341-6f78-4dc4-b656-2ac773eb8e9a'::uuid,'22a9045e-4068-43fc-8fb6-026f9e0718e6'::uuid),
    ('b4113e89-d0c4-4fca-a478-17382f1e0e4d'::uuid,'5cf2d2bd-b473-4101-93d4-8af0a7e81bd6'::uuid),
    ('55c6edf1-d72e-4a6a-81ef-37029749d19a'::uuid,'ee33a599-1872-46e3-b743-ac4637941095'::uuid),
    ('8ddeabaf-ba30-44a2-b4ad-c59d8401afbe'::uuid,'b8f11385-0471-4b39-be4b-0efb759bd06a'::uuid),
    ('20148e38-0cbd-4e1d-8012-2d3b3ae4ace0'::uuid,'6ca5dcd5-ebd1-4dba-903b-f524a1dfe742'::uuid),
    ('b18cc7d1-531d-4575-82a8-844b93a4f525'::uuid,'89c8bfc7-1136-407c-83a5-18a3c8f8e1db'::uuid),
    ('26542a5c-3ef1-4cf4-8d28-5abe37004a8d'::uuid,'e3e8f2fe-2d3b-4c1a-b24a-7b8828661f46'::uuid),
    ('bc5630c7-f064-4180-af9f-98ba9770d1fe'::uuid,'7f6d1afa-9ac5-4030-9f20-6182582fd61d'::uuid),
    ('30346274-c05f-4fb8-b388-4a33264814ed'::uuid,'0e15a39c-937c-496e-9bae-693639acb8e1'::uuid),
    ('b02ebfd7-7fd1-40a0-a4b0-a3c6067e753c'::uuid,'3494a805-c52d-46b7-9bfc-1bc9c0061130'::uuid),
    ('817b4e52-31f4-4865-82a5-781d8628d80a'::uuid,'a77f2024-f533-4d21-8e20-4642a196a7ae'::uuid),
    ('74f719b0-cf16-4684-960f-b298bccf5e19'::uuid,'3a763d6e-df34-4860-b57e-e1468d0de890'::uuid),
    ('ad6bfece-9594-439a-b4f4-47bec353a0c6'::uuid,'f7edee3f-2ae2-4cf2-8113-3c63be825680'::uuid),
    ('2c4d4d42-26c4-4050-98d4-d4830df6ee25'::uuid,'90dfbd41-7c69-4dba-8490-fa3b9ef5a94b'::uuid),
    ('ff296f67-4010-40d6-95c2-73979e58e2a6'::uuid,'baca28f6-011f-44ec-b192-cf0515a09897'::uuid),
    ('771ed806-3c71-45d8-8c65-07fdacc43cc1'::uuid,'3b6b9fdd-cd9f-4acc-83b2-375f5e09b23d'::uuid),
    ('f88006e8-7dd3-4296-a8b2-baf234358d85'::uuid,'c3efc8b8-839a-4168-ab37-e76add77f2d7'::uuid),
    ('1c497091-02e7-4b17-879a-fc55565f2e05'::uuid,'06b74880-a992-4814-a9d2-93df41803e3a'::uuid),
    ('e05ea736-996b-4ab3-88fb-345b5b32e430'::uuid,'12be6506-492d-43d9-be7f-39b01cdd17bd'::uuid),
    ('d55b9846-a48e-4da8-afe3-3d78bf00ab09'::uuid,'41cfebc3-cf6f-499c-9005-ced5c1bc7df9'::uuid),
    ('31ff1eec-2922-4f2e-9f98-54935552f93c'::uuid,'36d1d1e5-97cb-45c2-a6d5-35a203364553'::uuid),
    ('2b977f6f-dae8-426a-b1a9-44d6da559931'::uuid,'b351f380-a216-4123-b0be-e6c435ff6629'::uuid),
    ('69d94aaf-4603-4173-b891-19c8e293bd24'::uuid,'a175ba59-b697-4fd3-b212-15e2fd97882b'::uuid),
    ('cb0e5dcf-6d5b-429c-afc3-255d3f108cd0'::uuid,'2416f7b4-2cbf-400d-b130-1189a5d6a0b6'::uuid),
    ('d1119a46-10a5-4ab7-b51d-63b4b1f83be7'::uuid,'3fe95008-151d-439e-bc70-31866a910973'::uuid),
    ('647d7c1c-6a4f-4e7a-a455-95686b3c32f1'::uuid,'4245a781-6ca1-4371-abc4-6f6f65ab4143'::uuid),
    ('31540f37-f666-418f-8775-1af8dba485c8'::uuid,'b4d5e746-62fd-4ab7-8b78-065d8a163c8e'::uuid),
    ('38e99304-6dcd-49c0-a67e-a9772e17797d'::uuid,'c17dcc5b-facc-406e-a723-7151f520982f'::uuid),
    ('e2bb4079-5eaa-45c3-91f1-20595ef582c5'::uuid,'0f2e6c54-c876-4590-9d59-340448316fe2'::uuid),
    ('09b03e2e-5ced-4938-9d51-d9c9a048b1e5'::uuid,'1ed7b0f7-6e0e-4e27-8584-d4980ee6eb12'::uuid),
    ('8e3a73d0-aede-4f60-a29a-8fb1d7b54298'::uuid,'47b05d1a-6356-4e2a-9c82-0e93012bd985'::uuid),
    ('dda39804-b5b0-4e05-a8dd-3c401b18fb91'::uuid,'9c5d726c-cdf0-40d6-bafd-f016a7d5b908'::uuid),
    ('2a41cd14-bae1-495c-905a-89695109f5b1'::uuid,'44464d78-ca6c-4505-9f5c-d563c1cd0fb4'::uuid),
    ('c9645cce-3b8a-4e5e-9c7c-31e675577eec'::uuid,'49b839cc-7d32-417e-a837-9eedb32b362c'::uuid),
    ('cbb9a111-7140-47d2-8f32-f3c70ba82c42'::uuid,'923c25c6-2503-478d-8e74-d180788df85f'::uuid),
    ('e31637b0-cb9e-4f53-bfaa-02e4b4b2c05a'::uuid,'b1438a54-4892-41ff-aac2-c1eee6aa9b5f'::uuid),
    ('7a9c43da-1505-4a8e-9e75-a32f05fa29d1'::uuid,'17476172-92e3-4572-8938-1ba57c0c3f03'::uuid),
    ('091b31d6-c54f-4783-ac3e-498ca38ed008'::uuid,'a746b2c3-63dd-42fb-919e-0e2917ed70d4'::uuid),
    ('b2e5d02b-f6fc-4f2f-abf3-e5ba4bfc5eee'::uuid,'f22e31c4-77d2-4819-8c9c-6084c49839dd'::uuid),
    ('32831b6d-2696-4e2d-8620-9b5d522c165a'::uuid,'0d96dc86-fcc7-4731-bc3c-a1dfe1cf7305'::uuid),
    ('9856d33f-91cb-4ef8-a132-9f2e3b3eef1a'::uuid,'c4d05308-14a7-41dd-af04-014549a45b6f'::uuid))
UPDATE organization_people op SET organization_id = m.surv
  FROM m WHERE op.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM organization_people o2
                     WHERE o2.organization_id = m.surv AND o2.person_id = op.person_id);

WITH m(dup,surv) AS (VALUES
    ('5d788a93-8960-4853-aa8c-e16e6c6f1b6f'::uuid,'f2431553-67ba-4541-8907-d7122113a0cb'::uuid),
    ('f8e36a2c-c64d-4f60-a152-3a8ee144fb2d'::uuid,'406483a7-fd65-429a-9d10-ac2399705c0a'::uuid),
    ('f0ad5128-4cb0-434b-b0dc-4301de623987'::uuid,'e976297e-378e-44d0-8ac8-93e4e96ec295'::uuid),
    ('96604567-a149-4ce9-bf57-46789c7d4f03'::uuid,'a93fb9e8-3088-4561-8b0d-4492039e70b9'::uuid),
    ('f0167502-6914-4078-a9a0-135caff3ce9c'::uuid,'a12c0812-2b16-4bd4-b9eb-3f0319c4c7fb'::uuid),
    ('4ddb331d-503b-4580-bcb3-ba24f3d8e7f2'::uuid,'ade174da-a097-4ba6-9426-cef2a9393b9a'::uuid),
    ('2c85ccee-8daa-4f47-80c4-cd2b057c1e78'::uuid,'741627ef-3d1b-40d8-933f-7fc812e25221'::uuid),
    ('10074147-7abb-4581-8a39-e204e2125d16'::uuid,'637c3812-c97d-46ee-8455-1ac07314ce48'::uuid),
    ('9dc9a30b-a8d8-4e5e-a26d-10b84f7fecb8'::uuid,'d3fe0c4d-3890-48d0-b955-106dc0e29844'::uuid),
    ('b0a10e64-b4f2-4a07-bf84-d7bc4bb56d98'::uuid,'61a94d84-560c-452c-a2b3-2ec8b7a8bd7c'::uuid),
    ('1f097857-718e-4ba8-91a2-fac14691cf74'::uuid,'ac2eff68-47eb-453c-a7c8-deb960d1e0e2'::uuid),
    ('af132c9f-35b8-4d90-8e42-a017b468a29d'::uuid,'bedd4113-ba58-4bb9-8821-87c0d8242a7a'::uuid),
    ('6b2e82f1-44f0-4032-97a2-facdfbf83522'::uuid,'0cb566a1-38d6-4bd0-bf46-daf8ee73155e'::uuid),
    ('3d875c9c-cb21-4cf8-a731-ce9bc36e33bb'::uuid,'7b50ae34-4cc8-4b17-91b2-9ffa6d22cd42'::uuid),
    ('4dd63341-6f78-4dc4-b656-2ac773eb8e9a'::uuid,'22a9045e-4068-43fc-8fb6-026f9e0718e6'::uuid),
    ('b4113e89-d0c4-4fca-a478-17382f1e0e4d'::uuid,'5cf2d2bd-b473-4101-93d4-8af0a7e81bd6'::uuid),
    ('55c6edf1-d72e-4a6a-81ef-37029749d19a'::uuid,'ee33a599-1872-46e3-b743-ac4637941095'::uuid),
    ('8ddeabaf-ba30-44a2-b4ad-c59d8401afbe'::uuid,'b8f11385-0471-4b39-be4b-0efb759bd06a'::uuid),
    ('20148e38-0cbd-4e1d-8012-2d3b3ae4ace0'::uuid,'6ca5dcd5-ebd1-4dba-903b-f524a1dfe742'::uuid),
    ('b18cc7d1-531d-4575-82a8-844b93a4f525'::uuid,'89c8bfc7-1136-407c-83a5-18a3c8f8e1db'::uuid),
    ('26542a5c-3ef1-4cf4-8d28-5abe37004a8d'::uuid,'e3e8f2fe-2d3b-4c1a-b24a-7b8828661f46'::uuid),
    ('bc5630c7-f064-4180-af9f-98ba9770d1fe'::uuid,'7f6d1afa-9ac5-4030-9f20-6182582fd61d'::uuid),
    ('30346274-c05f-4fb8-b388-4a33264814ed'::uuid,'0e15a39c-937c-496e-9bae-693639acb8e1'::uuid),
    ('b02ebfd7-7fd1-40a0-a4b0-a3c6067e753c'::uuid,'3494a805-c52d-46b7-9bfc-1bc9c0061130'::uuid),
    ('817b4e52-31f4-4865-82a5-781d8628d80a'::uuid,'a77f2024-f533-4d21-8e20-4642a196a7ae'::uuid),
    ('74f719b0-cf16-4684-960f-b298bccf5e19'::uuid,'3a763d6e-df34-4860-b57e-e1468d0de890'::uuid),
    ('ad6bfece-9594-439a-b4f4-47bec353a0c6'::uuid,'f7edee3f-2ae2-4cf2-8113-3c63be825680'::uuid),
    ('2c4d4d42-26c4-4050-98d4-d4830df6ee25'::uuid,'90dfbd41-7c69-4dba-8490-fa3b9ef5a94b'::uuid),
    ('ff296f67-4010-40d6-95c2-73979e58e2a6'::uuid,'baca28f6-011f-44ec-b192-cf0515a09897'::uuid),
    ('771ed806-3c71-45d8-8c65-07fdacc43cc1'::uuid,'3b6b9fdd-cd9f-4acc-83b2-375f5e09b23d'::uuid),
    ('f88006e8-7dd3-4296-a8b2-baf234358d85'::uuid,'c3efc8b8-839a-4168-ab37-e76add77f2d7'::uuid),
    ('1c497091-02e7-4b17-879a-fc55565f2e05'::uuid,'06b74880-a992-4814-a9d2-93df41803e3a'::uuid),
    ('e05ea736-996b-4ab3-88fb-345b5b32e430'::uuid,'12be6506-492d-43d9-be7f-39b01cdd17bd'::uuid),
    ('d55b9846-a48e-4da8-afe3-3d78bf00ab09'::uuid,'41cfebc3-cf6f-499c-9005-ced5c1bc7df9'::uuid),
    ('31ff1eec-2922-4f2e-9f98-54935552f93c'::uuid,'36d1d1e5-97cb-45c2-a6d5-35a203364553'::uuid),
    ('2b977f6f-dae8-426a-b1a9-44d6da559931'::uuid,'b351f380-a216-4123-b0be-e6c435ff6629'::uuid),
    ('69d94aaf-4603-4173-b891-19c8e293bd24'::uuid,'a175ba59-b697-4fd3-b212-15e2fd97882b'::uuid),
    ('cb0e5dcf-6d5b-429c-afc3-255d3f108cd0'::uuid,'2416f7b4-2cbf-400d-b130-1189a5d6a0b6'::uuid),
    ('d1119a46-10a5-4ab7-b51d-63b4b1f83be7'::uuid,'3fe95008-151d-439e-bc70-31866a910973'::uuid),
    ('647d7c1c-6a4f-4e7a-a455-95686b3c32f1'::uuid,'4245a781-6ca1-4371-abc4-6f6f65ab4143'::uuid),
    ('31540f37-f666-418f-8775-1af8dba485c8'::uuid,'b4d5e746-62fd-4ab7-8b78-065d8a163c8e'::uuid),
    ('38e99304-6dcd-49c0-a67e-a9772e17797d'::uuid,'c17dcc5b-facc-406e-a723-7151f520982f'::uuid),
    ('e2bb4079-5eaa-45c3-91f1-20595ef582c5'::uuid,'0f2e6c54-c876-4590-9d59-340448316fe2'::uuid),
    ('09b03e2e-5ced-4938-9d51-d9c9a048b1e5'::uuid,'1ed7b0f7-6e0e-4e27-8584-d4980ee6eb12'::uuid),
    ('8e3a73d0-aede-4f60-a29a-8fb1d7b54298'::uuid,'47b05d1a-6356-4e2a-9c82-0e93012bd985'::uuid),
    ('dda39804-b5b0-4e05-a8dd-3c401b18fb91'::uuid,'9c5d726c-cdf0-40d6-bafd-f016a7d5b908'::uuid),
    ('2a41cd14-bae1-495c-905a-89695109f5b1'::uuid,'44464d78-ca6c-4505-9f5c-d563c1cd0fb4'::uuid),
    ('c9645cce-3b8a-4e5e-9c7c-31e675577eec'::uuid,'49b839cc-7d32-417e-a837-9eedb32b362c'::uuid),
    ('cbb9a111-7140-47d2-8f32-f3c70ba82c42'::uuid,'923c25c6-2503-478d-8e74-d180788df85f'::uuid),
    ('e31637b0-cb9e-4f53-bfaa-02e4b4b2c05a'::uuid,'b1438a54-4892-41ff-aac2-c1eee6aa9b5f'::uuid),
    ('7a9c43da-1505-4a8e-9e75-a32f05fa29d1'::uuid,'17476172-92e3-4572-8938-1ba57c0c3f03'::uuid),
    ('091b31d6-c54f-4783-ac3e-498ca38ed008'::uuid,'a746b2c3-63dd-42fb-919e-0e2917ed70d4'::uuid),
    ('b2e5d02b-f6fc-4f2f-abf3-e5ba4bfc5eee'::uuid,'f22e31c4-77d2-4819-8c9c-6084c49839dd'::uuid),
    ('32831b6d-2696-4e2d-8620-9b5d522c165a'::uuid,'0d96dc86-fcc7-4731-bc3c-a1dfe1cf7305'::uuid),
    ('9856d33f-91cb-4ef8-a132-9f2e3b3eef1a'::uuid,'c4d05308-14a7-41dd-af04-014549a45b6f'::uuid))
UPDATE program_organizations pg SET organization_id = m.surv
  FROM m WHERE pg.organization_id = m.dup
    AND NOT EXISTS (SELECT 1 FROM program_organizations p2
                     WHERE p2.organization_id = m.surv AND p2.program_edition_id = pg.program_edition_id);

COMMIT;

-- ---------------------------------------------------------------------------
-- Delete the 55 duplicate stub orgs (run in the Supabase SQL editor).
-- ---------------------------------------------------------------------------

DELETE FROM organizations WHERE id = '5d788a93-8960-4853-aa8c-e16e6c6f1b6f'; -- VU Log  (merged into VULOG)
DELETE FROM organizations WHERE id = 'f8e36a2c-c64d-4f60-a152-3a8ee144fb2d'; -- VEKIA  (merged into VEKIA SAS)
DELETE FROM organizations WHERE id = 'f0ad5128-4cb0-434b-b0dc-4301de623987'; -- Campings.com  (merged into Campings)
DELETE FROM organizations WHERE id = '96604567-a149-4ce9-bf57-46789c7d4f03'; -- DIOTASOFT S.A.S.  (merged into DIOTASOFT)
DELETE FROM organizations WHERE id = 'f0167502-6914-4078-a9a0-135caff3ce9c'; -- LA COMPAGNIE DES MOBILITÉS Geovelo  (merged into GEOVELO)
DELETE FROM organizations WHERE id = '4ddb331d-503b-4580-bcb3-ba24f3d8e7f2'; -- IDEOL  (merged into BW Ideol)
DELETE FROM organizations WHERE id = '2c85ccee-8daa-4f47-80c4-cd2b057c1e78'; -- IT CONTROL EXPERT  (merged into I.T.Control Expert)
DELETE FROM organizations WHERE id = '10074147-7abb-4581-8a39-e204e2125d16'; -- EXPLISEAT SAS  (merged into Expliseat)
DELETE FROM organizations WHERE id = '9dc9a30b-a8d8-4e5e-a26d-10b84f7fecb8'; -- SARL DRACULA Technologies  (merged into Dracula Technologies)
DELETE FROM organizations WHERE id = 'b0a10e64-b4f2-4a07-bf84-d7bc4bb56d98'; -- Aleph- Networks  (merged into Aleph-Networks)
DELETE FROM organizations WHERE id = '1f097857-718e-4ba8-91a2-fac14691cf74'; -- Matawan Mobility  (merged into Matawan)
DELETE FROM organizations WHERE id = 'af132c9f-35b8-4d90-8e42-a017b468a29d'; -- CARDIORENAL DIAGNOSTICS  (merged into Cardiorenal)
DELETE FROM organizations WHERE id = '6b2e82f1-44f0-4032-97a2-facdfbf83522'; -- Therapixel SA  (merged into THERAPIXEL)
DELETE FROM organizations WHERE id = '3d875c9c-cb21-4cf8-a731-ce9bc36e33bb'; -- CINTOO 3D  (merged into Cintoo)
DELETE FROM organizations WHERE id = '4dd63341-6f78-4dc4-b656-2ac773eb8e9a'; -- QUCIT SAS  (merged into QUCIT)
DELETE FROM organizations WHERE id = 'b4113e89-d0c4-4fca-a478-17382f1e0e4d'; -- PHOST’IN THERAPEUTICS  (merged into PHOST'IN)
DELETE FROM organizations WHERE id = '55c6edf1-d72e-4a6a-81ef-37029749d19a'; -- Everysens SAS  (merged into everysens)
DELETE FROM organizations WHERE id = '8ddeabaf-ba30-44a2-b4ad-c59d8401afbe'; -- MilliDrop Instrument SAS  (merged into MilliDrop Instruments SAS)
DELETE FROM organizations WHERE id = '20148e38-0cbd-4e1d-8012-2d3b3ae4ace0'; -- Exotec Solutions  (merged into Exotec)
DELETE FROM organizations WHERE id = 'b18cc7d1-531d-4575-82a8-844b93a4f525'; -- Acklio  (merged into ACKLIO SAS)
DELETE FROM organizations WHERE id = '26542a5c-3ef1-4cf4-8d28-5abe37004a8d'; -- Velco SAS  (merged into VEL'CO)
DELETE FROM organizations WHERE id = 'bc5630c7-f064-4180-af9f-98ba9770d1fe'; -- Japet Medical Devices  (merged into Japet Medical)
DELETE FROM organizations WHERE id = '30346274-c05f-4fb8-b388-4a33264814ed'; -- Antescofo SAS  (merged into Antescofo)
DELETE FROM organizations WHERE id = 'b02ebfd7-7fd1-40a0-a4b0-a3c6067e753c'; -- Swile  (merged into Swile)
DELETE FROM organizations WHERE id = '817b4e52-31f4-4865-82a5-781d8628d80a'; -- ALKION BIO INNOVATIONS  (merged into Alkion BioInnovations)
DELETE FROM organizations WHERE id = '74f719b0-cf16-4684-960f-b298bccf5e19'; -- REDBERRY SAS  (merged into REDBERRY)
DELETE FROM organizations WHERE id = 'ad6bfece-9594-439a-b4f4-47bec353a0c6'; -- ElicitPlant  (merged into Elicit Plant)
DELETE FROM organizations WHERE id = '2c4d4d42-26c4-4050-98d4-d4830df6ee25'; -- MagIA Diagnostics SAS  (merged into MagIA Diagnostics)
DELETE FROM organizations WHERE id = 'ff296f67-4010-40d6-95c2-73979e58e2a6'; -- MYCOPHYTO 2019  (merged into MYCOPHYTO)
DELETE FROM organizations WHERE id = '771ed806-3c71-45d8-8c65-07fdacc43cc1'; -- Return of Silicon (ROSI)  (merged into ROSI)
DELETE FROM organizations WHERE id = 'f88006e8-7dd3-4296-a8b2-baf234358d85'; -- ELWAVE Système  (merged into ELWAVE)
DELETE FROM organizations WHERE id = '1c497091-02e7-4b17-879a-fc55565f2e05'; -- InBrainPharma  (merged into InBrain Pharma)
DELETE FROM organizations WHERE id = 'e05ea736-996b-4ab3-88fb-345b5b32e430'; -- COSMIAN TECH  (merged into COSMIAN)
DELETE FROM organizations WHERE id = 'd55b9846-a48e-4da8-afe3-3d78bf00ab09'; -- SESTERCE France LABS  (merged into SESTERCE)
DELETE FROM organizations WHERE id = '31ff1eec-2922-4f2e-9f98-54935552f93c'; -- MATERR'UP SAS  (merged into Materrup)
DELETE FROM organizations WHERE id = '2b977f6f-dae8-426a-b1a9-44d6da559931'; -- Tree Frog Therapeutics  (merged into TreeFrog Therapeutics)
DELETE FROM organizations WHERE id = '69d94aaf-4603-4173-b891-19c8e293bd24'; -- Mablink  (merged into Mablink Bioscience)
DELETE FROM organizations WHERE id = 'cb0e5dcf-6d5b-429c-afc3-255d3f108cd0'; -- TOOPI-Organics SAS  (merged into TOOPI Organics)
DELETE FROM organizations WHERE id = 'd1119a46-10a5-4ab7-b51d-63b4b1f83be7'; -- OKEENEA DIGITAL  (merged into OKEENEA)
DELETE FROM organizations WHERE id = '647d7c1c-6a4f-4e7a-a455-95686b3c32f1'; -- SeaBeLife_2020  (merged into SeaBeLife)
DELETE FROM organizations WHERE id = '31540f37-f666-418f-8775-1af8dba485c8'; -- vorteX.io  (merged into vorteX-io)
DELETE FROM organizations WHERE id = '38e99304-6dcd-49c0-a67e-a9772e17797d'; -- Dry4Good (LGD)  (merged into Dry4Good)
DELETE FROM organizations WHERE id = 'e2bb4079-5eaa-45c3-91f1-20595ef582c5'; -- Surgical Augmented Reality (SurgAR)  (merged into SURGAR)
DELETE FROM organizations WHERE id = '09b03e2e-5ced-4938-9d51-d9c9a048b1e5'; -- Loft Orbital  (merged into Loft Orbital)
DELETE FROM organizations WHERE id = '8e3a73d0-aede-4f60-a29a-8fb1d7b54298'; -- G-LYTE  (merged into G+Lyte)
DELETE FROM organizations WHERE id = 'dda39804-b5b0-4e05-a8dd-3c401b18fb91'; -- Quantiq  (merged into Quantiq.io)
DELETE FROM organizations WHERE id = '2a41cd14-bae1-495c-905a-89695109f5b1'; -- Alice&Bob  (merged into Alice & Bob)
DELETE FROM organizations WHERE id = 'c9645cce-3b8a-4e5e-9c7c-31e675577eec'; -- RDS SAS  (merged into RDS)
DELETE FROM organizations WHERE id = 'cbb9a111-7140-47d2-8f32-f3c70ba82c42'; -- PATHWAY (NAVALGO)  (merged into NavAlgo)
DELETE FROM organizations WHERE id = 'e31637b0-cb9e-4f53-bfaa-02e4b4b2c05a'; -- STANDING OVATION SAS  (merged into Standing Ovation)
DELETE FROM organizations WHERE id = '7a9c43da-1505-4a8e-9e75-a32f05fa29d1'; -- Enginn  (merged into ENGINN TECHNOLOGIES)
DELETE FROM organizations WHERE id = '091b31d6-c54f-4783-ac3e-498ca38ed008'; -- ESCAPE TECHNOLOGIES  (merged into Escape)
DELETE FROM organizations WHERE id = 'b2e5d02b-f6fc-4f2f-abf3-e5ba4bfc5eee'; -- Biomemory labs  (merged into Biomemory)
DELETE FROM organizations WHERE id = '32831b6d-2696-4e2d-8620-9b5d522c165a'; -- L'Aéronde  (merged into Aéronde)
DELETE FROM organizations WHERE id = '9856d33f-91cb-4ef8-a132-9f2e3b3eef1a'; -- PRONOE SAS  (merged into Pronoe)
