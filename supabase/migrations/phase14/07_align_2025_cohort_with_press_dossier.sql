-- Phase 14 · Fix: align 2025 cohort with the press dossier
--
-- The 2026 bulletin's "new to FT 120" count came out at 22 instead of the
-- 19 highlighted in the official press release. Diagnosis (per editorial
-- review of the PDF):
--
--   • Upsun is the 2025 rebrand of Platform.sh (six-year FT 120 member,
--     slug 'platformsh'). The 2026 ingest created a duplicate 'upsun' org.
--   • Positive is the 2025 rebrand of Groupe positive (2024+2025 FT 120
--     member, slug 'groupe-positive'). 2026 ingest created a duplicate.
--   • Elicit Plant was genuinely missing from our 2025 record, despite
--     being in the 2025 cohort officially.
--
-- Folds the two duplicates back into the established orgs (carrying the
-- 2026 program membership with them), renames each to the new brand
-- (slug + display name), and inserts the missing 2025 FT 120 row for
-- Elicit Plant.
--
-- Side effect: 2025 cohort now has 121 program_organizations rows. One
-- of those was almost certainly attributed in error and should be
-- reconciled against the 2025 press dossier when handy. The 2026 numbers
-- are unaffected.

BEGIN;

-- 1. Upsun = renamed Platform.sh
SELECT merge_organizations('upsun', 'platformsh');
UPDATE organizations
   SET slug='upsun', name='Upsun', updated_at=NOW()
 WHERE slug='platformsh';

-- 2. Positive = renamed Groupe positive
SELECT merge_organizations('positive', 'groupe-positive');
UPDATE organizations
   SET slug='positive', name='Positive', updated_at=NOW()
 WHERE slug='groupe-positive';

-- 3. Backfill Elicit Plant's 2025 FT 120 membership
INSERT INTO program_organizations (program_edition_id, organization_id, group_label)
SELECT 'e310e2be-b2ba-4dc6-91e2-b5b01cb1344c',
       (SELECT id FROM organizations WHERE slug='elicit-plant'),
       'FT 120'
 WHERE NOT EXISTS (
   SELECT 1 FROM program_organizations
    WHERE program_edition_id='e310e2be-b2ba-4dc6-91e2-b5b01cb1344c'
      AND organization_id=(SELECT id FROM organizations WHERE slug='elicit-plant')
 );

COMMIT;
