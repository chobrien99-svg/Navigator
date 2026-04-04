-- =============================================================================
-- Organization Programs
-- Tracks membership in government/institutional programs (e.g. French Tech Next 40/120)
-- =============================================================================

CREATE TABLE organization_programs (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  program_name    TEXT NOT NULL,          -- e.g. 'french_tech_next'
  tier            TEXT,                   -- e.g. 'next40', '120'
  year            INTEGER NOT NULL,       -- cohort year
  source_url      TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, program_name, year)
);

CREATE INDEX idx_org_programs_org ON organization_programs(organization_id);
CREATE INDEX idx_org_programs_program ON organization_programs(program_name);
CREATE INDEX idx_org_programs_year ON organization_programs(year DESC);
CREATE INDEX idx_org_programs_tier ON organization_programs(tier);

-- Auto-update updated_at
CREATE TRIGGER set_updated_at_organization_programs
  BEFORE UPDATE ON organization_programs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS
ALTER TABLE organization_programs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON organization_programs FOR SELECT USING (true);
