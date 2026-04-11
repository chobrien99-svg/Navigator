-- =============================================================================
-- Sector Deduplication Cleanup
-- =============================================================================
-- 6 sector names have two rows with different slugs (old "-and-" style vs
-- new canonical). We keep the canonical (second ID in each pair) and merge
-- the old ones into them.
--
-- Canonical IDs to keep:
--   Artificial Intelligence  → 9d35a5b4-88ec-44ea-af55-ef2d820f83e1 (slug: artificial-intelligence)
--   E-commerce & Retail       → 63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f (slug: e-commerce-retail)
--   Mobility                  → 6ddcbe32-372a-4ea1-bddb-7730ef7b5385 (slug: mobility)
--   PropTech                  → 86ee75e4-32bb-46ea-a0d9-dd7c60c187da (slug: proptech)
--   SaaS                      → 4e07372a-d48c-4a00-a463-0dfa18ab51a1 (slug: saas)
--   SpaceTech & Aerospace    → 64e2e443-dcfb-43f7-a1a0-24007104fac8 (slug: spacetech-aerospace)
-- =============================================================================

-- Step 1: Where an org is ALREADY linked to the canonical sector via the new ID,
-- propagate primary status from the duplicate link if needed, then drop the
-- duplicate link to avoid UNIQUE (organization_id, sector_id) violations in Step 2.

-- Promote canonical to primary if the duplicate was primary and the canonical wasn't
WITH dup_map AS (
  SELECT * FROM (VALUES
    ('9d35a5b4-88ec-44ea-af55-ef2d820f83e1'::uuid, '957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
    ('63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f'::uuid, 'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
    ('6ddcbe32-372a-4ea1-bddb-7730ef7b5385'::uuid, '71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
    ('86ee75e4-32bb-46ea-a0d9-dd7c60c187da'::uuid, 'a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
    ('4e07372a-d48c-4a00-a463-0dfa18ab51a1'::uuid, '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
    ('64e2e443-dcfb-43f7-a1a0-24007104fac8'::uuid, 'c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
  ) AS t(keep_id, drop_id)
),
promote_targets AS (
  SELECT os_canonical.id AS canonical_row_id
  FROM organization_sectors os_dup
  JOIN dup_map ON os_dup.sector_id = dup_map.drop_id
  JOIN organization_sectors os_canonical
    ON os_canonical.organization_id = os_dup.organization_id
    AND os_canonical.sector_id = dup_map.keep_id
  WHERE os_dup.is_primary = TRUE
  AND os_canonical.is_primary = FALSE
)
UPDATE organization_sectors
SET is_primary = TRUE
WHERE id IN (SELECT canonical_row_id FROM promote_targets);

-- Step 2: Drop duplicate links where the org is already linked to the canonical
DELETE FROM organization_sectors os
USING (VALUES
  ('9d35a5b4-88ec-44ea-af55-ef2d820f83e1'::uuid, '957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
  ('63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f'::uuid, 'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
  ('6ddcbe32-372a-4ea1-bddb-7730ef7b5385'::uuid, '71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
  ('86ee75e4-32bb-46ea-a0d9-dd7c60c187da'::uuid, 'a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
  ('4e07372a-d48c-4a00-a463-0dfa18ab51a1'::uuid, '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
  ('64e2e443-dcfb-43f7-a1a0-24007104fac8'::uuid, 'c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
) AS m(keep_id, drop_id)
WHERE os.sector_id = m.drop_id
AND EXISTS (
  SELECT 1 FROM organization_sectors os2
  WHERE os2.organization_id = os.organization_id AND os2.sector_id = m.keep_id
);

-- Step 3: Repoint remaining duplicate links to the canonical sector
-- Also demote is_primary if promoting it would violate idx_one_primary_sector_per_org
WITH dup_map AS (
  SELECT * FROM (VALUES
    ('9d35a5b4-88ec-44ea-af55-ef2d820f83e1'::uuid, '957f88d4-cef3-434f-9e97-d32430a0b3d1'::uuid),
    ('63ad1ac9-6aca-4ca4-bd3b-f98249c6a68f'::uuid, 'bd5b2291-c1ee-4c6a-94ce-854ac35c98d1'::uuid),
    ('6ddcbe32-372a-4ea1-bddb-7730ef7b5385'::uuid, '71f8d11b-5caf-4af1-86ef-6bfb9d81272c'::uuid),
    ('86ee75e4-32bb-46ea-a0d9-dd7c60c187da'::uuid, 'a88ce2c8-7544-4d71-b774-6b82805b7070'::uuid),
    ('4e07372a-d48c-4a00-a463-0dfa18ab51a1'::uuid, '50d276bc-d0d5-4c1b-812d-8d2a1bbb2662'::uuid),
    ('64e2e443-dcfb-43f7-a1a0-24007104fac8'::uuid, 'c9460d00-f17f-49ba-8562-721d8ff30daf'::uuid)
  ) AS t(keep_id, drop_id)
)
UPDATE organization_sectors os
SET
  sector_id = m.keep_id,
  -- Demote to non-primary if the org already has another primary
  is_primary = CASE
    WHEN os.is_primary AND EXISTS (
      SELECT 1 FROM organization_sectors os2
      WHERE os2.organization_id = os.organization_id
      AND os2.is_primary = TRUE
      AND os2.id != os.id
    ) THEN FALSE
    ELSE os.is_primary
  END
FROM dup_map m
WHERE os.sector_id = m.drop_id;

-- Step 4: Delete the now-orphaned duplicate sector rows
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
