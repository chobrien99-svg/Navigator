-- =====================================================================
-- Phase 35 - Remove wrongly-attached legal entities.
--
-- Registry verification (recherche-entreprises.api.gouv.fr, 2026-11-02)
-- showed these 12 legal_entities rows are unrelated companies that share
-- only a name with the org they were attached to. All are non-primary;
-- each org keeps its correct primary entity.
--
--   electra     812527802  cosmetics retailer (SARL)        keep 891624884
--   greenly     999234222  blank-NAF shell                  keep 878730647 (OFFSPEND)
--   greenly     922774963  ceased taxi co (GREENLY CAB)     keep 878730647
--   heyday-ic   813603222  DASHDOC - logistics SaaS         keep 803183771
--   la-fourche  439617259  SCI (real estate)                keep 839765062
--   metron      819431834  ENWIRES - different company      keep 794167593
--   pigment     941429565  a restaurant                     keep 852785914
--   resilience  834439663  catering/restaurant              keep 893834713
--   swan        830009965  ceased clothing wholesaler       keep 853827103
--   watchfrog   811684190  BUYCO - shipping SaaS            keep 484872551
--   zama        432302271  SCI (real estate)                keep 879243319
--   zefir       522820661  security-services company        keep 851800235
--
-- No table has a foreign key to legal_entities. Idempotent (fixed ids).
-- =====================================================================

BEGIN;

DELETE FROM legal_entities
WHERE id IN (
  'b890bb95-f14c-49a5-b24c-4675edba55af',  -- electra     812527802
  'f448a17c-4272-4fa6-8f24-0f68e92b25d8',  -- greenly     999234222
  'e2f0a3f6-d66a-42b9-8f08-5ee9889cef68',  -- greenly     922774963
  '7fddd6c3-96e5-444f-85dc-88242785ad0a',  -- heyday-ic   813603222 (DASHDOC)
  '4ac9dfa2-17fa-4900-a2e8-0367bc9fc5ca',  -- la-fourche  439617259 (SCI)
  '4b0d4bea-3d96-42e1-8743-e1b2257c6594',  -- metron      819431834 (ENWIRES)
  'a40753d5-bf0f-419d-8e96-17cf66fa4ebc',  -- pigment     941429565 (restaurant)
  '7fc98aa3-9389-44ed-80b5-9391576803ab',  -- resilience  834439663 (restaurant)
  '8481dabe-11d9-47bf-8c39-1c17d1f67a11',  -- swan        830009965 (clothing)
  '128275e8-0d23-4171-8603-0163c502c437',  -- watchfrog   811684190 (BUYCO)
  'fb72a5c0-f173-49d1-bca9-5ada2ec59031',  -- zama        432302271 (SCI)
  'a3d8f5cd-7590-4d1c-a226-eb5d7ecbfe37'   -- zefir       522820661 (security)
);

COMMIT;
