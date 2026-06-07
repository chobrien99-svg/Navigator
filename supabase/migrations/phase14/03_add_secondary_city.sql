-- =============================================================================
-- Add secondary HQ city to organizations
-- =============================================================================
-- Some companies operate from two HQs (e.g. Paris + NYC). This optional
-- column captures the secondary location alongside the existing primary
-- `city_id`. NULL means "single HQ". When a city row is deleted, this FK
-- nulls out (same behavior as the primary city_id).
-- =============================================================================

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID
    REFERENCES cities(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_organizations_secondary_city
  ON organizations(secondary_city_id);
