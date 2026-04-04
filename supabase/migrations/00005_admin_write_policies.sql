-- =============================================================================
-- Admin write policies for content management
-- Allows authenticated admin users to INSERT, UPDATE, DELETE on core tables
-- =============================================================================

-- ─── Organizations ───────────────────────────────────────────
CREATE POLICY "Admins can insert organizations" ON organizations
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update organizations" ON organizations
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete organizations" ON organizations
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Organization Profiles ───────────────────────────────────
CREATE POLICY "Admins can insert organization_profiles" ON organization_profiles
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update organization_profiles" ON organization_profiles
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete organization_profiles" ON organization_profiles
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── People ──────────────────────────────────────────────────
CREATE POLICY "Admins can insert people" ON people
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update people" ON people
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete people" ON people
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Funding Rounds ──────────────────────────────────────────
CREATE POLICY "Admins can insert funding_rounds" ON funding_rounds
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update funding_rounds" ON funding_rounds
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete funding_rounds" ON funding_rounds
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Funding Round Investors ─────────────────────────────────
CREATE POLICY "Admins can insert funding_round_investors" ON funding_round_investors
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update funding_round_investors" ON funding_round_investors
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete funding_round_investors" ON funding_round_investors
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Legal Entities ──────────────────────────────────────────
CREATE POLICY "Admins can insert legal_entities" ON legal_entities
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update legal_entities" ON legal_entities
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete legal_entities" ON legal_entities
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Organization Sectors ────────────────────────────────────
CREATE POLICY "Admins can insert organization_sectors" ON organization_sectors
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update organization_sectors" ON organization_sectors
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete organization_sectors" ON organization_sectors
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Organization Tags ──────────────────────────────────────
CREATE POLICY "Admins can insert organization_tags" ON organization_tags
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update organization_tags" ON organization_tags
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete organization_tags" ON organization_tags
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Organization People (team/founder links) ───────────────
CREATE POLICY "Admins can insert organization_people" ON organization_people
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update organization_people" ON organization_people
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete organization_people" ON organization_people
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );

-- ─── Program Organizations ──────────────────────────────────
CREATE POLICY "Admins can insert program_organizations" ON program_organizations
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can update program_organizations" ON program_organizations
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
CREATE POLICY "Admins can delete program_organizations" ON program_organizations
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = true)
  );
