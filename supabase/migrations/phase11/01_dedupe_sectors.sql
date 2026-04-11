-- =============================================================================
-- Sector Deduplication Cleanup (v2 — simpler, constraint-safe)
-- =============================================================================
-- 6 sector names have two rows with different slugs. We keep the canonical
-- (second) ID in each pair and merge the older ones in.
--
-- Strategy:
--   1. Delete duplicate links where the org is already linked to the canonical
--      (the is_primary flag is lost for those orgs if the dup was primary and
--      the canonical wasn't — the user can re-mark primary in the admin UI).
--   2. Repoint remaining duplicate links to the canonical sector, handling
--      is_primary carefully so we don't trip the one-primary-per-org constraint.
--   3. Delete the now-orphaned duplicate sector rows.
-- =============================================================================

-- Step 1: Delete duplicate links where the org already has the canonical.
-- Uses a subquery to collect row IDs first so the DELETE itself is simple.
DELETE FROM organization_sectors
WHERE id IN (
  SELECT os_dup.id
  FROM organization_sectors os_dup
  JOIN (VALUES
    ('9d35a5b4-88ec-44ea-af55-ef2d820f83e1'::uuid, '957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
    ('63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f'::uuid, 'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
    ('6ddcbe32-372a-4ea1-bddb-7730ef7b5385'::uuid, '71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
    ('86ee75e4-32bb-46ea-a0d9-dd7c60c187da'::uuid, 'a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
    ('4e07372a-d48c-4a00-a463-0dfa18ab51a1'::uuid, '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
    ('64e2e443-dcfb-43f7-a1a0-24007104fac8'::uuid, 'c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
  ) AS m(keep_id, drop_id) ON os_dup.sector_id = m.drop_id
  JOIN organization_sectors os_canonical
    ON os_canonical.organization_id = os_dup.organization_id
    AND os_canonical.sector_id = m.keep_id
);

-- Step 2a: Before repointing, if a duplicate row is primary AND the target
-- canonical sector already has a primary elsewhere for this org… actually
-- by now, no org has the canonical linked (Step 1 removed any dups where
-- canonical existed), so we're safe. Any remaining dup row was the ONLY
-- link for its org to this sector, so repointing it to canonical cannot
-- conflict with the one-primary-per-org constraint UNLESS the org already
-- has a primary on a DIFFERENT sector.

-- Demote any duplicate link that is_primary and would conflict with an
-- existing primary elsewhere on the org.
UPDATE organization_sectors os
SET is_primary = FALSE
FROM (VALUES
  ('957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
  ('bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
  ('71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
  ('a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
  ('50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
  ('c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
) AS drop_ids(drop_id)
WHERE os.sector_id = drop_ids.drop_id
AND os.is_primary = TRUE
AND EXISTS (
  SELECT 1 FROM organization_sectors os2
  WHERE os2.organization_id = os.organization_id
  AND os2.is_primary = TRUE
  AND os2.id != os.id
);

-- Step 2b: Now safely repoint all remaining duplicate links to the canonical.
UPDATE organization_sectors os
SET sector_id = m.keep_id
FROM (VALUES
  ('9d35a5b4-88ec-44ea-af55-ef2d820f83e1'::uuid, '957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
  ('63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f'::uuid, 'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
  ('6ddcbe32-372a-4ea1-bddb-7730ef7b5385'::uuid, '71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
  ('86ee75e4-32bb-46ea-a0d9-dd7c60c187da'::uuid, 'a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
  ('4e07372a-d48c-4a00-a463-0dfa18ab51a1'::uuid, '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
  ('64e2e443-dcfb-43f7-a1a0-24007104fac8'::uuid, 'c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
) AS m(keep_id, drop_id)
WHERE os.sector_id = m.drop_id;

-- Step 3: Delete the now-orphaned duplicate sector rows
DELETE FROM sectors WHERE id IN (
  '957f88d4-cef3-434f-9e97-d32430a0b3d1',
  'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1',
  '71f8d11b-5caf-4af1-86ef-6bfb9d81272c',
  'a88ce2c8-7544-4d71-b774-6b82805b7070',
  '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662',
  'c9460d00-f17f-49ba-8562-721d8ff30daf'
);

-- Verify: should return 0 rows
SELECT name, count(*)
FROM sectors
GROUP BY name
HAVING count(*) > 1;
