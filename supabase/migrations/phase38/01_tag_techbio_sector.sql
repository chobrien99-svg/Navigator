-- =============================================================================
-- Tag existing organizations with the TechBio sector
-- =============================================================================
-- Source: "TechBio in France - October 2026 update" (48 companies).
-- Matched against organizations by website domain or normalized name.
--
-- 35 of the 48 already exist in the database. 3 of them (Eligo Bioscience,
-- Rivercell, WhiteLab Genomics) were already tagged TechBio; this adds the
-- tag to the other 32. Existing sectors are left untouched.
--
-- Matches under a different name in the database:
--   Ariana Pharma   -> Ariana Pharmaceuticals (ariana-pharmaceuticals)
--   MAbSilico       -> MAbSilico SAS (mabsilico-sas)
--   InFocus Ther.   -> INFOCUS THERAPEUTICS SAS (infocus-therapeutics-sas)
--   Spore.Bio       -> Spore Biotechnologies (spore-biotechnologies)
--
-- Not in the database (13, not added here): AI-biopharma, BeLiver,
-- D&A MedLabs, HyprView, InSiliBio, Ksilink, MedInsights, Opsin,
-- Parean Biotechnologies, Peaccel, Rosetta Omics, Tebuna, TychoBio.
--
-- Idempotent: safe to re-run.
-- =============================================================================

INSERT INTO sectors (id, name, slug, created_at, updated_at)
VALUES (uuid_generate_v4(), 'TechBio', 'techbio', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO organization_sectors (organization_id, sector_id, is_primary)
SELECT o.id, s.id, FALSE
FROM organizations o
CROSS JOIN sectors s
WHERE s.slug = 'techbio'
  AND o.slug IN (
    'aqemia', 'arcascience', 'ariana-pharmaceuticals', 'biolevate',
    'bioptimus', 'brink-therapeutics', 'cherry-biotech', 'cure51',
    'deeplife', 'dna-script', 'eligo-bioscience', 'endogenebio', 'eukarys',
    'generare', 'iktos', 'infocus-therapeutics-sas', 'inspek', 'karavela',
    'mabsilico-sas', 'nebula', 'netri', 'okomera', 'one-biosciences',
    'orakl-oncology', 'oria-bioscience', 'owkin', 'phagos', 'poietis',
    'qubit-pharmaceuticals', 'rivercell', 'scienta-lab',
    'spore-biotechnologies', 'theremia', 'whitelab-genomics', 'zebramed'
  )
ON CONFLICT (organization_id, sector_id) DO NOTHING;
