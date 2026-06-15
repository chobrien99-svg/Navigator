-- Phase 14 · Fix: AMI Labs duplicate created by 05_french_tech_promotion_2026.sql
--
-- During the 2026 ingest, "AMI Labs" was created as a new org (slug
-- 'ami-labs') because the name didn't fuzzy-match the existing record
-- (slug 'advanced-machine-intelligence', name 'Advanced Machine
-- Intelligence'). Per editorial confirmation, they are the same company,
-- so fold the just-created stub back into the real org and rename the
-- survivor to the official 2026 spelling.

BEGIN;

SELECT merge_organizations('ami-labs', 'advanced-machine-intelligence');

UPDATE organizations
   SET name = 'AMI Labs', updated_at = NOW()
 WHERE slug = 'advanced-machine-intelligence';

COMMIT;
