-- =====================================================================
-- Phase 35 - Cleanup: remove wrong legal entities from Castalie.
--
-- The Castalie org (slug castalie - the water-fountain company,
-- CASTALIE SAS / SIREN 532029600, Boulogne-Billancourt) had two
-- unrelated companies wrongly attached as legal entities:
--
--   GREEN ACRES (SIREN 453785156) - real-estate web portal, Paris (NAF 63.12Z)
--   LE CHENE    (SIREN 798834867) - fund management, Paris (NAF 66.30Z)
--
-- Neither is Castalie; no funding rounds reference them and no other
-- data points to them. Remove the two rows, leaving CASTALIE as the
-- sole (primary) legal entity.
--
-- Idempotent: targets fixed row ids.
-- =====================================================================

BEGIN;

DELETE FROM legal_entities
WHERE id IN (
  '7bdda331-ddf9-402d-a097-37cfb0db4f1d',  -- GREEN ACRES (453785156)
  '1df2f28e-d441-4d22-8021-0be9fcc0984a'   -- LE CHENE (798834867)
);

COMMIT;
