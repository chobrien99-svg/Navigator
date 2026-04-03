-- =============================================================================
-- Product scoping: which organizations appear in which frontend product
-- =============================================================================

-- Products catalog — each frontend product gets a row
CREATE TABLE product_catalog (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL UNIQUE,
  slug        TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON product_catalog
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE product_catalog ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON product_catalog FOR SELECT USING (true);

-- Seed the first product
INSERT INTO product_catalog (name, slug, description)
VALUES ('AI Radar', 'ai-radar', 'French AI startup intelligence platform');

-- Product-organization join table
CREATE TABLE product_organizations (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id      UUID NOT NULL REFERENCES product_catalog(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(product_id, organization_id)
);

CREATE INDEX idx_prod_orgs_product ON product_organizations(product_id);
CREATE INDEX idx_prod_orgs_org ON product_organizations(organization_id);

ALTER TABLE product_organizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON product_organizations FOR SELECT USING (true);

-- Assign the 6 AI Radar startups to the AI Radar product
INSERT INTO product_organizations (product_id, organization_id)
SELECT pc.id, o.id
FROM product_catalog pc, organizations o
WHERE pc.slug = 'ai-radar'
  AND o.legacy_source = 'ai_radar';

-- Verify
SELECT o.name, pc.name AS product
FROM product_organizations po
JOIN organizations o ON o.id = po.organization_id
JOIN product_catalog pc ON pc.id = po.product_id
ORDER BY o.name;
