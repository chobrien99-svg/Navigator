-- =============================================================================
-- PHASE 2 - IMPORT 1: Cities
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 1 from 01_export_from_funding_tracker.sql in your Funding
--    Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '[
  {
    "json_agg": [
      {
        "id": "a9c65aac-6d58-44f7-b343-26335e91704c",
        "name": "Aix-en-Provence",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:20.601862+00:00"
      },
      {
        "id": "e43826e5-2016-4755-a508-66d8e4a0c792",
        "name": "Alfortville",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:46.271635+00:00"
      },
      {
        "id": "463530f5-5f81-4761-ad66-dffcfc411902",
        "name": "Angers",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:19.641841+00:00"
      },
      {
        "id": "ccc228db-3f00-4369-af72-1d2ef43f2a40",
        "name": "Annecy",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:17.231499+00:00"
      },
      {
        "id": "3fb513b4-d570-441a-8688-1b7a48617a6f",
        "name": "Arras",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:38:28.980632+00:00"
      },
      {
        "id": "3566371b-9685-4fc5-89ce-60257ea01ebf",
        "name": "Aubagne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:14.769903+00:00"
      },
      {
        "id": "4665afa6-138f-4ecd-82fc-dd56c323200f",
        "name": "Avon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:19.148098+00:00"
      },
      {
        "id": "e9eeb9b2-5be4-4592-a18e-6f9e23cd79d9",
        "name": "Bagnolet",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:48.001745+00:00"
      },
      {
        "id": "dadba794-40db-456d-98f7-e4d62fc45fb8",
        "name": "Balma",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:24.924849+00:00"
      },
      {
        "id": "eb86be74-2025-4abf-9f21-b8e9d5dc983a",
        "name": "Barberaz",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:40.760241+00:00"
      },
      {
        "id": "879536fe-1f86-436f-866f-acb081a48d6b",
        "name": "Bayonne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:32.519144+00:00"
      },
      {
        "id": "3434c2b3-b0a3-410d-8365-9164e658d3ef",
        "name": "Biarritz",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:47.870499+00:00"
      },
      {
        "id": "9993eb2d-182c-4edf-b6f6-9c1b6292f77d",
        "name": "Biot",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-26T17:05:51.802994+00:00"
      },
      {
        "id": "f1a084b7-2c63-4375-8a0b-25ccc15d8bf8",
        "name": "Bordeaux",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:16.588994+00:00"
      },
      {
        "id": "e6c2915e-2afc-4a4d-aff7-0296feb9c057",
        "name": "Boulogne-Billancourt",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:48.862815+00:00"
      },
      {
        "id": "dd4812ca-7529-4416-8435-910efedf1308",
        "name": "Brens",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:38:19.462419+00:00"
      },
      {
        "id": "0ef88f10-3a58-4f1d-8621-ac019f0ea480",
        "name": "Bron",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:25.290236+00:00"
      },
      {
        "id": "8b299c17-e511-4889-a663-b357df098311",
        "name": "Caen",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:10.365348+00:00"
      },
      {
        "id": "4013a8a9-808f-4f31-b9da-b61a97026799",
        "name": "Camblanes-et-Meynac",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:35:07.555351+00:00"
      },
      {
        "id": "a4e2af21-c509-4a6c-a7bd-9d3f7dce94be",
        "name": "Cannes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:02.019354+00:00"
      },
      {
        "id": "18af0e55-28fe-4fd2-94e3-ddae0733e542",
        "name": "Carquefou",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:13.143994+00:00"
      },
      {
        "id": "80e4b982-2643-439d-b4ad-ecf8a6c4c290",
        "name": "Castelnau-le-Lez",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:11.445042+00:00"
      },
      {
        "id": "0369ead2-20ec-494f-8ade-8bb5776e97e9",
        "name": "Cesson-Sévigné",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:20.056026+00:00"
      },
      {
        "id": "addd0ba9-289a-4fff-8086-60ac26b2013f",
        "name": "Chambéry",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:53.092085+00:00"
      },
      {
        "id": "cdfbc9fd-2339-4199-b975-670d9dc3732f",
        "name": "Chartres",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:32.050991+00:00"
      },
      {
        "id": "602ccc69-d4c6-4717-ba5b-2c68f7c2fc37",
        "name": "Claix",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:22.004397+00:00"
      },
      {
        "id": "75837dfc-77f7-4adc-9bd5-b52a01a58969",
        "name": "Clermont-Ferrand",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:15.207907+00:00"
      },
      {
        "id": "0a37fe22-f279-4fa6-8686-aa84e01eee4b",
        "name": "Confrançon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:12.663898+00:00"
      },
      {
        "id": "de3992e7-15f9-4126-9131-12da56eb144b",
        "name": "Courbevoie",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:01.147686+00:00"
      },
      {
        "id": "98f93377-822f-4363-9a1a-85b1e0cfede1",
        "name": "Cugand",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:28:10.322876+00:00"
      },
      {
        "id": "e1f8b626-4854-4e7e-85fd-ce3c7ecbf097",
        "name": "Cugnaux",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:49.188489+00:00"
      },
      {
        "id": "f59587c0-f6e2-48ab-bc94-46b8c5deee70",
        "name": "Dijon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:47.439602+00:00"
      },
      {
        "id": "7200b06a-0e0e-4a19-b40e-5cfb269487d3",
        "name": "Évry",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:54.776969+00:00"
      },
      {
        "id": "c30f815d-20ed-4fe1-926d-de22b88da60d",
        "name": "Évry-Courcouronnes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:14.224407+00:00"
      },
      {
        "id": "1bae1da5-aae0-4411-9af6-61a0576fdfa4",
        "name": "Fenouillet",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:55.849466+00:00"
      },
      {
        "id": "f802e12b-b097-4060-b9c6-cf3e0bebf09c",
        "name": "Fontaine",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:34.605338+00:00"
      },
      {
        "id": "4d969335-3931-4c47-b4ba-457cd4ac5544",
        "name": "France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:50.442584+00:00"
      },
      {
        "id": "e3ebf024-4605-4959-a927-b5675f7249ba",
        "name": "Goetzenbruck",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:11.506941+00:00"
      },
      {
        "id": "18ee692e-8de3-4a7c-b9b4-20c890e60ef3",
        "name": "Grasse",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:28:21.937033+00:00"
      },
      {
        "id": "f385a681-bacf-49d0-94c3-9b79e0d70e6d",
        "name": "Grenoble",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:36.044444+00:00"
      },
      {
        "id": "e72f9cc8-410d-4a27-ae50-4d9d9396761e",
        "name": "Guadeloupe",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:07.46483+00:00"
      },
      {
        "id": "75fc317f-bd4f-4f02-89e0-055cf0922335",
        "name": "Haguenau",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:29.664914+00:00"
      },
      {
        "id": "7f16d203-3904-421a-8a75-d6bc023bd5f0",
        "name": "Hallennes-lez-Haubourdin",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:59.361134+00:00"
      },
      {
        "id": "4b326e4a-3c38-43a2-8904-42b84e7c6692",
        "name": "Hérault",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:58.799449+00:00"
      },
      {
        "id": "590e430c-53cc-4522-8a63-b5fe8bd30b00",
        "name": "Île‑de‑France region, France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:46.199494+00:00"
      },
      {
        "id": "9aaf80b3-554c-4b42-a9eb-1322cc9dd4f5",
        "name": "Illkirch",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:32.286881+00:00"
      },
      {
        "id": "32a54a3c-d9a8-4b5d-9a09-670d2675ab27",
        "name": "Isle",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:58.422756+00:00"
      },
      {
        "id": "6a602337-f0af-49b8-8e76-b518d5b04aa8",
        "name": "Issy-les-Moulineaux",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:12.211485+00:00"
      },
      {
        "id": "7cac7613-56b5-4372-af4d-66e24bab6dd6",
        "name": "Ivry-sur-Seine",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:06.258355+00:00"
      },
      {
        "id": "5a65ac52-4a49-4f15-af12-1c4fc48bcde5",
        "name": "La Ciotat",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:28.119378+00:00"
      },
      {
        "id": "152d4c3a-48da-402c-9b44-01fb032b75fc",
        "name": "La Courneuve",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:12.727856+00:00"
      },
      {
        "id": "58e1f8dc-3a76-499e-995f-9aac750ef24d",
        "name": "La Roche-sur-Yon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:38:24.411515+00:00"
      },
      {
        "id": "0cdb3307-d2d6-4f5e-9bbb-2a5638919093",
        "name": "La Rochelle",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:26.15847+00:00"
      },
      {
        "id": "148be02a-ab43-4e0a-8243-0973adb7e222",
        "name": "La Tronche",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:07.682942+00:00"
      },
      {
        "id": "4704fe3f-3df9-405c-ae9d-87385b954eb3",
        "name": "Lacroix-Saint-Ouen",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:48.282646+00:00"
      },
      {
        "id": "0358f1be-c7ec-4e69-a048-c291c2f6aa9f",
        "name": "Lannion",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:28:13.644146+00:00"
      },
      {
        "id": "98c19952-2387-4378-b71f-2715bf09a91c",
        "name": "Laudun-l'Ardoise",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:54.747864+00:00"
      },
      {
        "id": "b5886d1d-3e6c-4f8c-91e0-8690f34337cf",
        "name": "Laval",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-26T17:05:54.277102+00:00"
      },
      {
        "id": "4753d9e7-bfe6-4484-957a-dedcae3617c1",
        "name": "Le Bourget-du-Lac",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:21.628117+00:00"
      },
      {
        "id": "4b27a0f8-2016-45e7-8206-4cdf325f2126",
        "name": "Le Haillan",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-25T23:48:55.169372+00:00"
      },
      {
        "id": "145378de-d0a2-474b-a2ba-073b877984fe",
        "name": "Le Kremlin-Bicêtre",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:01.868536+00:00"
      },
      {
        "id": "6509db06-b5c6-4f7e-82d7-45572718e47a",
        "name": "Le Versoud",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:31.963165+00:00"
      },
      {
        "id": "dcdfe416-a222-4c2e-b53a-5630bfacf668",
        "name": "Les Ulis",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:03.757376+00:00"
      },
      {
        "id": "9f023383-9831-4c91-8420-b189c752c636",
        "name": "Levallois-Perret",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:19.889118+00:00"
      },
      {
        "id": "9bc577e1-a93f-4b92-ab46-bf284360676d",
        "name": "Libourne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:47.486793+00:00"
      },
      {
        "id": "5e422f16-a289-4349-b4e9-62df16b419b7",
        "name": "Lille",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:35.516557+00:00"
      },
      {
        "id": "c22464b6-bbe1-4a4e-b8f7-962b63bf1f98",
        "name": "Limoges",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:28.670323+00:00"
      },
      {
        "id": "a67be608-976f-4b0d-adb5-5c92f1eb46fe",
        "name": "Lorient",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:18.669598+00:00"
      },
      {
        "id": "dd74bbb7-a3a4-48ea-b984-1e57c9bd8457",
        "name": "Lyon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:10.186142+00:00"
      },
      {
        "id": "310f44d2-7a6b-4688-96ac-de1b57dda076",
        "name": "Maisons-Laffitte",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:41.860697+00:00"
      },
      {
        "id": "297a48e2-8d10-439c-8c79-606268036f68",
        "name": "Marseille",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:15.160516+00:00"
      },
      {
        "id": "6a1489f6-4a34-4c10-9de4-65c9b06f31bb",
        "name": "Massy",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-02-08T05:50:56.134154+00:00"
      },
      {
        "id": "440a317e-2cd3-4cd5-bd5f-2cd54da62e23",
        "name": "Mauguio",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:34.121438+00:00"
      },
      {
        "id": "9849f22d-3ebe-4bee-a088-569ed5e0b7d4",
        "name": "Mérignac",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:22.597258+00:00"
      },
      {
        "id": "6f2e21db-1d5b-4500-9f3e-84bb0d1cb46d",
        "name": "Meylan",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:45.450138+00:00"
      },
      {
        "id": "35eb403a-2746-46e8-b44b-fff68c9eebec",
        "name": "Meyreuil",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:36.595061+00:00"
      },
      {
        "id": "064a897c-db12-4b11-907c-bc67776a0df7",
        "name": "Montoir-de-Bretagne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:39.401955+00:00"
      },
      {
        "id": "160dfdf5-24d9-4ab1-9fc4-a24800c3da90",
        "name": "Montpellier",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:19.789351+00:00"
      },
      {
        "id": "0286fee8-cb27-475d-b2f7-3a6594a8bf80",
        "name": "Montreuil",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:19.386228+00:00"
      },
      {
        "id": "43aace0c-336f-4a02-b31b-d6445d3dcba6",
        "name": "Nancy",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:42.706858+00:00"
      },
      {
        "id": "7aebe104-917d-4406-9b3b-8e18653b81bd",
        "name": "Nanterre",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:55.153062+00:00"
      },
      {
        "id": "5a7f2e1b-a942-4afc-9730-edbced605bd5",
        "name": "Nantes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:00.072417+00:00"
      },
      {
        "id": "5aa78649-b116-4983-8b73-211083f845c6",
        "name": "Naveil",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:34.472744+00:00"
      },
      {
        "id": "865b4848-332d-434c-bccd-321226aa7b13",
        "name": "Neuilly-sur-Seine",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:17.08389+00:00"
      },
      {
        "id": "d364f6ee-4719-4552-81c5-bb23952d63ad",
        "name": "New York City, Paris",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-26T17:05:29.473983+00:00"
      },
      {
        "id": "d0adbac0-cc5e-4afc-898a-3736ff7b2ff5",
        "name": "Nice",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:30.714868+00:00"
      },
      {
        "id": "aa9a2449-97ef-4011-a00b-85547aa98fe6",
        "name": "Nice ",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:55.094787+00:00"
      },
      {
        "id": "0ff2d14b-c1e0-43e2-b4b2-aec477fa57be",
        "name": "Nice, France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:45.948549+00:00"
      },
      {
        "id": "c960c59e-8f22-463a-bdf8-0ad2b97f9429",
        "name": "Nîmes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:28.941874+00:00"
      },
      {
        "id": "1a9381b4-687c-4b67-ba87-c5699183a9ba",
        "name": "Nîmes, France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:15.262973+00:00"
      },
      {
        "id": "e6d8d6b1-e59a-465e-becc-ca71c4596573",
        "name": "Nouvelle-Aquitaine",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:40.307205+00:00"
      },
      {
        "id": "fdac1d99-98cd-48c4-bb6c-1b72e07f36d4",
        "name": "Olivet",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:28:15.065077+00:00"
      },
      {
        "id": "b4d3cea0-795b-4426-8092-7fb5dd52c894",
        "name": "Olonne-sur-Mer",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:00.568318+00:00"
      },
      {
        "id": "ec03f414-65bf-46ee-85cf-287ba51dfb6c",
        "name": "Orgeval",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:16.63402+00:00"
      },
      {
        "id": "ab982465-f4ef-4a2f-b097-546eb0ddafa4",
        "name": "Orléans",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:39.56235+00:00"
      },
      {
        "id": "1c6d0cf1-806e-454a-8af5-213ae0714b50",
        "name": "Orsay",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:27.451645+00:00"
      },
      {
        "id": "2df14185-41fd-4dba-b2bd-130f8a759fd7",
        "name": "Palaiseau",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:10.284858+00:00"
      },
      {
        "id": "855de75a-dff2-4cb7-8220-500428c72a9b",
        "name": "Paris",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:11.518718+00:00"
      },
      {
        "id": "ba00da3f-2707-4903-b2f5-6db9c6434ded",
        "name": "Paris & Palo Alto",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:17.977434+00:00"
      },
      {
        "id": "6277b4e7-55e6-4257-960b-5ea6f303713a",
        "name": "Paris-Saclay",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:35:54.580113+00:00"
      },
      {
        "id": "65c7274c-3f37-46df-afcc-7e37472a3a17",
        "name": "Paris, Turin",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-02-27T10:54:43.527843+00:00"
      },
      {
        "id": "805484e9-f8d3-4544-a6b0-b301844004c6",
        "name": "Pau",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:57.943223+00:00"
      },
      {
        "id": "cf855c7f-6cad-4318-a215-0efa36c47e15",
        "name": "Pessac",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:05.340273+00:00"
      },
      {
        "id": "d6ce33b5-4b98-4713-aadf-29ed3625f8a8",
        "name": "Puteaux",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:55.482896+00:00"
      },
      {
        "id": "d4683d56-9ddf-4225-a6d8-a6ad42b58602",
        "name": "Reims",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-02-27T10:13:43.70817+00:00"
      },
      {
        "id": "f430dd81-3810-4688-9858-a4b3286b68f0",
        "name": "Rennes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:26.017283+00:00"
      },
      {
        "id": "7876d332-b3ee-40fa-93a3-588545416abe",
        "name": "Roissy-en-France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:51.718809+00:00"
      },
      {
        "id": "5b0935c6-f15c-4f79-a669-f6b7802c44d8",
        "name": "Romainville",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:41.260039+00:00"
      },
      {
        "id": "ef43f95e-8cfe-4f26-9c6c-56beba297b41",
        "name": "Roscoff",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:35:12.611032+00:00"
      },
      {
        "id": "23534015-9fa3-4498-8d8f-6a1e26afb8ce",
        "name": "Rosières-près-Troyes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:26.744314+00:00"
      },
      {
        "id": "eb024269-a32c-457f-8749-677c801825d5",
        "name": "Rosny-sous-Bois",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:26.46017+00:00"
      },
      {
        "id": "45bb7e21-f585-4258-b6fd-6cdbf6ef3be0",
        "name": "Roubaix",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:35.626817+00:00"
      },
      {
        "id": "3fba75ce-2a65-4b00-8fd4-f0bce8f3346a",
        "name": "Rungis",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:30.010773+00:00"
      },
      {
        "id": "2cba51c3-28d3-49f5-825a-4c02ab460dea",
        "name": "Saint-Brieuc",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:21.388092+00:00"
      },
      {
        "id": "781b231e-f8cb-443c-ba66-f45b8cf11319",
        "name": "Saint-Étienne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:01.08375+00:00"
      },
      {
        "id": "d87a5c9a-f4c1-4641-8b6e-58ca79a51b40",
        "name": "Saint-Genis-Pouilly",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:35:46.660478+00:00"
      },
      {
        "id": "6a38859a-2a35-4039-9ee6-d22ff5afd7c1",
        "name": "Saint-Herblain",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:09.368648+00:00"
      },
      {
        "id": "171796e7-9d53-4874-ae64-095d7212649a",
        "name": "Saint-Jacques-de-la-Lande",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:23.213103+00:00"
      },
      {
        "id": "78b1e1b6-3c92-4e24-9a45-b216e44bc29e",
        "name": "Saint-Jean-de-Braye",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:33.520987+00:00"
      },
      {
        "id": "2f76e9df-ba85-4eba-af8f-b97e25789e10",
        "name": "Saint-Malo",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:32.366871+00:00"
      },
      {
        "id": "b61b0b07-356e-4e22-98d1-0927e246119e",
        "name": "Saint-Mandé",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:31:00.776015+00:00"
      },
      {
        "id": "eea75b13-f3c5-41f0-b931-98a5ad88de9c",
        "name": "Saint-Nom-la-Bretèche",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:51.396275+00:00"
      },
      {
        "id": "56495de8-78f1-4413-861e-fc301305be71",
        "name": "Saint-Ouen",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-26T17:05:42.691292+00:00"
      },
      {
        "id": "43de45ed-0baf-496c-98ac-9a47d181b2f9",
        "name": "Saint-Ouen-sur-Seine",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:49.647453+00:00"
      },
      {
        "id": "e044b263-9cb7-4167-a1f7-a2a9a4ba448f",
        "name": "Saint-Priest",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:39.175727+00:00"
      },
      {
        "id": "4cb1d399-5bac-4b34-ab3b-ac7222dd8b67",
        "name": "Saint-Rémy",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:29:54.831603+00:00"
      },
      {
        "id": "71f442e3-f066-44a2-85fe-3449a049a3d7",
        "name": "Saint-Romain-d'Ay",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:16.737028+00:00"
      },
      {
        "id": "5bc6a1e2-7072-43b1-a91d-660c0027f7d6",
        "name": "Schiltigheim",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:40.867693+00:00"
      },
      {
        "id": "2f810b1f-bbe1-4de0-9d43-b859d3ee7a41",
        "name": "Schlierbach",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:40.448291+00:00"
      },
      {
        "id": "b134eb28-e054-4cfd-8334-a8a78fbe2bda",
        "name": "Sèvres",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:38:34.195154+00:00"
      },
      {
        "id": "89ff02f7-2797-4fb8-8bbc-9cbf5afd6ff5",
        "name": "Sophia Antipolis",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-02-08T05:50:59.491999+00:00"
      },
      {
        "id": "8ea8299d-745e-4099-8ad7-f4026b09aa95",
        "name": "Strasbourg",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:52.345966+00:00"
      },
      {
        "id": "d5c3a24c-ca7d-447f-b805-c0ceaab48814",
        "name": "Strasbourg, France",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:53.518249+00:00"
      },
      {
        "id": "a0779684-a1c7-488d-a62f-6e5592800d86",
        "name": "Toulouse",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:21.109461+00:00"
      },
      {
        "id": "d1880115-6f08-43f5-8ace-31e1bb0f2af4",
        "name": "Tourcoing",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:24.230368+00:00"
      },
      {
        "id": "900192dc-0aaa-45d5-bdea-aa02c300c89f",
        "name": "Tours",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:47.312533+00:00"
      },
      {
        "id": "e8933379-5299-4e2c-b251-3f76f349962a",
        "name": "Toussus‑le‑Noble",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:32:45.022687+00:00"
      },
      {
        "id": "39063f71-424a-4599-b881-da50746eb943",
        "name": "Val-de-Reuil",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:38:08.383049+00:00"
      },
      {
        "id": "995ebb4f-5a74-4f1d-88de-2337088401e1",
        "name": "Valbonne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:29.30319+00:00"
      },
      {
        "id": "042a5bd9-2f6c-4f10-b06a-3a9ba452acef",
        "name": "Valence",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:36:06.367239+00:00"
      },
      {
        "id": "31a72553-140b-4a77-923b-72b65bcf3afc",
        "name": "Vannes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:29.624285+00:00"
      },
      {
        "id": "c346b508-6d34-47ac-ba4b-152953b59ab8",
        "name": "Vélizy-Villacoublay",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:09.020177+00:00"
      },
      {
        "id": "ad3cf0ee-6222-4823-9b52-44dc02b07725",
        "name": "Vernon",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:15.78978+00:00"
      },
      {
        "id": "c98af89f-0e79-4f76-99d4-c71378277c7a",
        "name": "Verrières-le-Buisson",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:44.577823+00:00"
      },
      {
        "id": "097fa6a8-4c06-41a2-b1fe-3e3ada5ba0a2",
        "name": "Versailles",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:37:45.634434+00:00"
      },
      {
        "id": "c218437e-9bda-405d-9a92-ab8f452a76db",
        "name": "Villefranche-sur-Mer",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:33:21.644743+00:00"
      },
      {
        "id": "5134f72e-e390-4672-a18d-661c6a7db78f",
        "name": "Villefranche-sur-Saône",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:04.074836+00:00"
      },
      {
        "id": "b2cb9332-3d11-477e-bbb5-54897089c1dc",
        "name": "Villeneuve-d'Ascq",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:58.697195+00:00"
      },
      {
        "id": "e42a2eff-38dd-4e65-9679-6bea44b39aab",
        "name": "Villeneuve-la-Garenne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:49.67474+00:00"
      },
      {
        "id": "eee1e153-47f5-4d78-b711-be3ef41dcc09",
        "name": "Villepinte",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:30:54.182291+00:00"
      },
      {
        "id": "655d9b51-8864-4b70-9a9a-35858a96484c",
        "name": "Villers-lès-Nancy",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:27:16.022879+00:00"
      },
      {
        "id": "e74f434d-aedc-4ebe-87fb-847c145a12d7",
        "name": "Villeurbanne",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:31.116058+00:00"
      },
      {
        "id": "ab2eaacd-5afb-48de-83a5-943aca79a3d2",
        "name": "Vincennes",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:26:33.066052+00:00"
      },
      {
        "id": "1e2c7b24-e28a-455e-b5c7-8f8eaa94b814",
        "name": "Vitry-en-Artois",
        "region": null,
        "country": "France",
        "latitude": null,
        "longitude": null,
        "created_at": "2026-01-24T23:34:28.480305+00:00"
      }
    ]
  }
]
  ) AS (
    id          UUID,
    name        TEXT,
    region      TEXT,
    country     TEXT,
    latitude    NUMERIC,
    longitude   NUMERIC,
    created_at  TIMESTAMPTZ
  )
)
INSERT INTO cities (
  id,
  name,
  slug,
  region,
  country,
  latitude,
  longitude,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.region,
  COALESCE(s.country, 'France'),
  s.latitude,
  s.longitude,
  COALESCE(s.created_at, NOW()),
  NOW()
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Verify
SELECT COUNT(*) AS cities_imported FROM cities;
