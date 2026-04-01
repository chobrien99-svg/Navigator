-- =============================================================================
-- Unified Intelligence Database - Canonical Schema
-- French Innovation Economy Hub
-- =============================================================================
-- This schema creates the canonical unified database that consolidates
-- data from French-Tech-Funding-Tracker and France-AI-Radar into a single
-- source of truth for the French innovation ecosystem.
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- for fuzzy text search

-- =============================================================================
-- CUSTOM TYPES
-- =============================================================================

CREATE TYPE organization_type AS ENUM (
  'startup',
  'corporate',
  'investor',
  'accelerator',
  'incubator',
  'university',
  'research_lab',
  'public_agency',
  'nonprofit',
  'media',
  'other'
);

CREATE TYPE organization_status AS ENUM (
  'active',
  'inactive',
  'acquired',
  'closed',
  'ipo',
  'stealth',
  'unknown'
);

CREATE TYPE funding_stage AS ENUM (
  'pre_seed',
  'seed',
  'series_a',
  'series_b',
  'series_c',
  'series_d',
  'series_e',
  'series_f',
  'growth',
  'bridge',
  'debt',
  'grant',
  'ipo',
  'secondary',
  'undisclosed',
  'other'
);

CREATE TYPE signal_type AS ENUM (
  'hiring_surge',
  'new_product',
  'pivot',
  'expansion',
  'partnership',
  'award',
  'media_mention',
  'regulatory',
  'talent_move',
  'patent_filing',
  'open_source',
  'conference',
  'other'
);

CREATE TYPE event_type AS ENUM (
  'founded',
  'funding_round',
  'acquisition',
  'ipo',
  'pivot',
  'product_launch',
  'expansion',
  'layoff',
  'shutdown',
  'merger',
  'rebrand',
  'leadership_change',
  'other'
);

CREATE TYPE relationship_type AS ENUM (
  'invested_in',
  'acquired',
  'partnered_with',
  'spun_out_from',
  'subsidiary_of',
  'competes_with',
  'incubated_by',
  'accelerated_by',
  'other'
);

CREATE TYPE verification_status AS ENUM (
  'unverified',
  'pending',
  'verified',
  'disputed'
);

CREATE TYPE source_type AS ENUM (
  'manual',
  'api',
  'scrape',
  'user_submitted',
  'press_release',
  'regulatory_filing',
  'other'
);

CREATE TYPE alert_type AS ENUM (
  'funding',
  'signal',
  'event',
  'news',
  'status_change',
  'new_organization'
);

-- =============================================================================
-- 1. CORE ENTITY LAYER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cities
-- Normalized city reference table
-- -----------------------------------------------------------------------------
CREATE TABLE cities (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT NOT NULL,
  slug            TEXT UNIQUE NOT NULL,
  department      TEXT,
  department_code TEXT,
  region          TEXT,
  country         TEXT NOT NULL DEFAULT 'France',
  latitude        NUMERIC(10, 7),
  longitude       NUMERIC(10, 7),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cities_slug ON cities(slug);
CREATE INDEX idx_cities_country ON cities(country);

-- -----------------------------------------------------------------------------
-- organizations
-- Main tracked entity across the ecosystem
-- -----------------------------------------------------------------------------
CREATE TABLE organizations (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT NOT NULL,
  slug               TEXT UNIQUE NOT NULL,
  organization_type  organization_type NOT NULL DEFAULT 'startup',
  description        TEXT,
  short_description  TEXT,
  website            TEXT,
  email              TEXT,
  phone              TEXT,
  linkedin_url       TEXT,
  twitter_url        TEXT,
  logo_url           TEXT,
  status             organization_status NOT NULL DEFAULT 'active',
  country            TEXT NOT NULL DEFAULT 'France',
  city_id            UUID REFERENCES cities(id) ON DELETE SET NULL,
  founded_date       DATE,
  employee_count     INTEGER,
  employee_range     TEXT,
  first_seen_at      TIMESTAMPTZ,
  is_stealth         BOOLEAN NOT NULL DEFAULT FALSE,
  -- Migration provenance
  legacy_source      TEXT,
  legacy_id          TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_type ON organizations(organization_type);
CREATE INDEX idx_organizations_status ON organizations(status);
CREATE INDEX idx_organizations_city ON organizations(city_id);
CREATE INDEX idx_organizations_country ON organizations(country);
CREATE INDEX idx_organizations_name_trgm ON organizations USING gin (name gin_trgm_ops);
CREATE INDEX idx_organizations_legacy ON organizations(legacy_source, legacy_id);

-- -----------------------------------------------------------------------------
-- legal_entities
-- Formal legal identity layer (French business registry data)
-- -----------------------------------------------------------------------------
CREATE TABLE legal_entities (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id    UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  legal_name         TEXT NOT NULL,
  legal_form         TEXT,
  siren              TEXT,
  siret              TEXT,
  capital_eur        NUMERIC(15, 2),
  incorporation_date DATE,
  registered_city    TEXT,
  country            TEXT NOT NULL DEFAULT 'France',
  is_primary         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_legal_entities_org ON legal_entities(organization_id);
CREATE INDEX idx_legal_entities_siren ON legal_entities(siren);
CREATE INDEX idx_legal_entities_siret ON legal_entities(siret);

-- -----------------------------------------------------------------------------
-- people
-- Canonical people table
-- -----------------------------------------------------------------------------
CREATE TABLE people (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name               TEXT NOT NULL,
  slug                    TEXT UNIQUE NOT NULL,
  first_name              TEXT,
  last_name               TEXT,
  linkedin_url            TEXT,
  twitter_url             TEXT,
  email                   TEXT,
  bio                     TEXT,
  photo_url               TEXT,
  has_phd                 BOOLEAN NOT NULL DEFAULT FALSE,
  is_repeat_founder       BOOLEAN NOT NULL DEFAULT FALSE,
  has_big_tech_background BOOLEAN NOT NULL DEFAULT FALSE,
  big_tech_employer       TEXT,
  academic_lab            TEXT,
  previous_exits          INTEGER DEFAULT 0,
  -- Migration provenance
  legacy_source           TEXT,
  legacy_id               TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_people_slug ON people(slug);
CREATE INDEX idx_people_name_trgm ON people USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_people_legacy ON people(legacy_source, legacy_id);

-- -----------------------------------------------------------------------------
-- organization_people
-- Join table linking people to organizations with roles
-- -----------------------------------------------------------------------------
CREATE TABLE organization_people (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  person_id       UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  role            TEXT,
  title           TEXT,
  is_current      BOOLEAN NOT NULL DEFAULT TRUE,
  is_founder      BOOLEAN NOT NULL DEFAULT FALSE,
  start_date      DATE,
  end_date        DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, person_id, role)
);

CREATE INDEX idx_org_people_org ON organization_people(organization_id);
CREATE INDEX idx_org_people_person ON organization_people(person_id);
CREATE INDEX idx_org_people_founder ON organization_people(is_founder) WHERE is_founder = TRUE;

-- -----------------------------------------------------------------------------
-- person_experience
-- Historical person/organization history
-- -----------------------------------------------------------------------------
CREATE TABLE person_experience (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_id       UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  company_name    TEXT,
  role            TEXT,
  title           TEXT,
  start_date      DATE,
  end_date        DATE,
  is_current      BOOLEAN NOT NULL DEFAULT FALSE,
  description     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_person_exp_person ON person_experience(person_id);
CREATE INDEX idx_person_exp_org ON person_experience(organization_id);

-- =============================================================================
-- 2. CLASSIFICATION LAYER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- sectors
-- Structured taxonomy for industry classification
-- -----------------------------------------------------------------------------
CREATE TABLE sectors (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,
  parent_id   UUID REFERENCES sectors(id) ON DELETE SET NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sectors_slug ON sectors(slug);
CREATE INDEX idx_sectors_parent ON sectors(parent_id);

-- -----------------------------------------------------------------------------
-- organization_sectors
-- Join table linking organizations to sectors
-- -----------------------------------------------------------------------------
CREATE TABLE organization_sectors (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  sector_id       UUID NOT NULL REFERENCES sectors(id) ON DELETE CASCADE,
  is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, sector_id)
);

CREATE INDEX idx_org_sectors_org ON organization_sectors(organization_id);
CREATE INDEX idx_org_sectors_sector ON organization_sectors(sector_id);

-- -----------------------------------------------------------------------------
-- organization_tags
-- Flexible labels for non-taxonomy categorization
-- -----------------------------------------------------------------------------
CREATE TABLE organization_tags (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  tag             TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, tag)
);

CREATE INDEX idx_org_tags_org ON organization_tags(organization_id);
CREATE INDEX idx_org_tags_tag ON organization_tags(tag);

-- =============================================================================
-- 3. INTELLIGENCE LAYER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- signals
-- Early indicators / evidence of noteworthy activity
-- -----------------------------------------------------------------------------
CREATE TABLE signals (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id     UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  signal_type         signal_type NOT NULL,
  signal_date         DATE,
  strength            INTEGER CHECK (strength BETWEEN 1 AND 5),
  title               TEXT NOT NULL,
  description         TEXT,
  source_type         source_type,
  source_name         TEXT,
  source_url          TEXT,
  confidence_score    NUMERIC(3, 2) CHECK (confidence_score BETWEEN 0 AND 1),
  verification_status verification_status NOT NULL DEFAULT 'unverified',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_signals_org ON signals(organization_id);
CREATE INDEX idx_signals_type ON signals(signal_type);
CREATE INDEX idx_signals_date ON signals(signal_date DESC);
CREATE INDEX idx_signals_verification ON signals(verification_status);

-- -----------------------------------------------------------------------------
-- organization_events
-- Structured dated events in an organization's lifecycle
-- -----------------------------------------------------------------------------
CREATE TABLE organization_events (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  event_type      event_type NOT NULL,
  event_date      DATE,
  title           TEXT NOT NULL,
  description     TEXT,
  source_url      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_org_events_org ON organization_events(organization_id);
CREATE INDEX idx_org_events_type ON organization_events(event_type);
CREATE INDEX idx_org_events_date ON organization_events(event_date DESC);

-- -----------------------------------------------------------------------------
-- organization_relationships
-- Graph relationships between organizations
-- -----------------------------------------------------------------------------
CREATE TABLE organization_relationships (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_org_id       UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  target_org_id       UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  relationship_type   relationship_type NOT NULL,
  description         TEXT,
  start_date          DATE,
  end_date            DATE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (source_org_id <> target_org_id)
);

CREATE INDEX idx_org_rel_source ON organization_relationships(source_org_id);
CREATE INDEX idx_org_rel_target ON organization_relationships(target_org_id);
CREATE INDEX idx_org_rel_type ON organization_relationships(relationship_type);

-- -----------------------------------------------------------------------------
-- products
-- Products or product lines belonging to organizations
-- -----------------------------------------------------------------------------
CREATE TABLE products (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  product_url     TEXT,
  launch_date     DATE,
  status          TEXT DEFAULT 'active',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_org ON products(organization_id);

-- -----------------------------------------------------------------------------
-- organization_profiles
-- Analyst / editorial layer for enriched organization intelligence
-- -----------------------------------------------------------------------------
CREATE TABLE organization_profiles (
  id                       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id          UUID UNIQUE NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  what_they_are_building   TEXT,
  why_it_matters           TEXT,
  investor_brief           TEXT,
  analyst_note             TEXT,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_org_profiles_org ON organization_profiles(organization_id);

-- =============================================================================
-- 4. CAPITAL AND ECOSYSTEM LAYER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- funding_rounds
-- Funding events for organizations
-- -----------------------------------------------------------------------------
CREATE TABLE funding_rounds (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id   UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  stage             funding_stage NOT NULL,
  amount_eur        NUMERIC(15, 2),
  amount_usd        NUMERIC(15, 2),
  currency_original TEXT DEFAULT 'EUR',
  amount_original   NUMERIC(15, 2),
  announced_date    DATE,
  closed_date       DATE,
  is_estimated      BOOLEAN NOT NULL DEFAULT FALSE,
  source_url        TEXT,
  source_name       TEXT,
  valuation_eur     NUMERIC(15, 2),
  -- Migration provenance
  legacy_source     TEXT,
  legacy_id         TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_funding_org ON funding_rounds(organization_id);
CREATE INDEX idx_funding_stage ON funding_rounds(stage);
CREATE INDEX idx_funding_date ON funding_rounds(announced_date DESC);
CREATE INDEX idx_funding_legacy ON funding_rounds(legacy_source, legacy_id);

-- -----------------------------------------------------------------------------
-- funding_round_investors
-- Join table linking funding rounds to investor organizations
-- -----------------------------------------------------------------------------
CREATE TABLE funding_round_investors (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  funding_round_id UUID NOT NULL REFERENCES funding_rounds(id) ON DELETE CASCADE,
  investor_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  is_lead          BOOLEAN NOT NULL DEFAULT FALSE,
  investor_name    TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(funding_round_id, investor_id)
);

CREATE INDEX idx_fri_round ON funding_round_investors(funding_round_id);
CREATE INDEX idx_fri_investor ON funding_round_investors(investor_id);

-- -----------------------------------------------------------------------------
-- articles
-- News articles and press coverage
-- -----------------------------------------------------------------------------
CREATE TABLE articles (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title          TEXT NOT NULL,
  url            TEXT,
  source_name    TEXT,
  published_date DATE,
  summary        TEXT,
  language       TEXT DEFAULT 'fr',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_articles_date ON articles(published_date DESC);
CREATE INDEX idx_articles_source ON articles(source_name);

-- -----------------------------------------------------------------------------
-- article_organizations
-- Join table linking articles to organizations
-- -----------------------------------------------------------------------------
CREATE TABLE article_organizations (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  article_id      UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(article_id, organization_id)
);

CREATE INDEX idx_article_orgs_article ON article_organizations(article_id);
CREATE INDEX idx_article_orgs_org ON article_organizations(organization_id);

-- -----------------------------------------------------------------------------
-- patents
-- Patent filings
-- -----------------------------------------------------------------------------
CREATE TABLE patents (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  patent_number   TEXT,
  title           TEXT NOT NULL,
  abstract        TEXT,
  filing_date     DATE,
  grant_date      DATE,
  patent_office   TEXT DEFAULT 'INPI',
  status          TEXT DEFAULT 'filed',
  url             TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_patents_org ON patents(organization_id);
CREATE INDEX idx_patents_number ON patents(patent_number);
CREATE INDEX idx_patents_filing ON patents(filing_date DESC);

-- -----------------------------------------------------------------------------
-- patent_inventors
-- Join table linking patents to people
-- -----------------------------------------------------------------------------
CREATE TABLE patent_inventors (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patent_id  UUID NOT NULL REFERENCES patents(id) ON DELETE CASCADE,
  person_id  UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(patent_id, person_id)
);

CREATE INDEX idx_patent_inv_patent ON patent_inventors(patent_id);
CREATE INDEX idx_patent_inv_person ON patent_inventors(person_id);

-- -----------------------------------------------------------------------------
-- grants
-- Public grants and subsidies (future-ready)
-- -----------------------------------------------------------------------------
CREATE TABLE grants (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  grant_name      TEXT NOT NULL,
  granting_body   TEXT,
  amount_eur      NUMERIC(15, 2),
  awarded_date    DATE,
  program         TEXT,
  description     TEXT,
  source_url      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_grants_org ON grants(organization_id);
CREATE INDEX idx_grants_body ON grants(granting_body);
CREATE INDEX idx_grants_date ON grants(awarded_date DESC);

-- =============================================================================
-- 5. USER / PRODUCT LAYER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- profiles
-- User profiles (linked to Supabase Auth)
-- -----------------------------------------------------------------------------
CREATE TABLE profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email      TEXT,
  full_name  TEXT,
  avatar_url TEXT,
  role       TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- watchlist
-- User watchlist of organizations
-- -----------------------------------------------------------------------------
CREATE TABLE watchlist (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, organization_id)
);

CREATE INDEX idx_watchlist_user ON watchlist(user_id);
CREATE INDEX idx_watchlist_org ON watchlist(organization_id);

-- -----------------------------------------------------------------------------
-- alerts
-- User alert subscriptions
-- -----------------------------------------------------------------------------
CREATE TABLE alerts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  alert_type      alert_type NOT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  filters         JSONB DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_alerts_user ON alerts(user_id);
CREATE INDEX idx_alerts_org ON alerts(organization_id);
CREATE INDEX idx_alerts_active ON alerts(is_active) WHERE is_active = TRUE;

-- -----------------------------------------------------------------------------
-- lists
-- User-created lists of organizations
-- -----------------------------------------------------------------------------
CREATE TABLE lists (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  is_public   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lists_user ON lists(user_id);

-- -----------------------------------------------------------------------------
-- list_items
-- Items within user-created lists
-- -----------------------------------------------------------------------------
CREATE TABLE list_items (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id         UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  notes           TEXT,
  position        INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(list_id, organization_id)
);

CREATE INDEX idx_list_items_list ON list_items(list_id);
CREATE INDEX idx_list_items_org ON list_items(organization_id);

-- -----------------------------------------------------------------------------
-- saved_searches
-- User saved search queries
-- -----------------------------------------------------------------------------
CREATE TABLE saved_searches (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  query       JSONB NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_saved_searches_user ON saved_searches(user_id);

-- =============================================================================
-- MIGRATION HELPER TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- organization_merge_map
-- Maps legacy IDs from source databases to canonical organization IDs
-- -----------------------------------------------------------------------------
CREATE TABLE organization_merge_map (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  source_db       TEXT NOT NULL,
  source_table    TEXT NOT NULL,
  source_id       TEXT NOT NULL,
  notes           TEXT,
  migrated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(source_db, source_table, source_id)
);

CREATE INDEX idx_merge_map_org ON organization_merge_map(organization_id);
CREATE INDEX idx_merge_map_source ON organization_merge_map(source_db, source_id);

-- -----------------------------------------------------------------------------
-- person_merge_map
-- Maps legacy IDs from source databases to canonical person IDs
-- -----------------------------------------------------------------------------
CREATE TABLE person_merge_map (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_id   UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,
  source_db   TEXT NOT NULL,
  source_table TEXT NOT NULL,
  source_id   TEXT NOT NULL,
  notes       TEXT,
  migrated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(source_db, source_table, source_id)
);

CREATE INDEX idx_person_merge_person ON person_merge_map(person_id);
CREATE INDEX idx_person_merge_source ON person_merge_map(source_db, source_id);

-- =============================================================================
-- UPDATED_AT TRIGGERS
-- =============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables with an updated_at column
CREATE TRIGGER set_updated_at BEFORE UPDATE ON cities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON legal_entities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON people
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_people
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON person_experience
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON sectors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON signals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_relationships
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON funding_rounds
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON patents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON grants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON alerts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON lists
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON saved_searches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE legal_entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE people ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_people ENABLE ROW LEVEL SECURITY;
ALTER TABLE person_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_sectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE funding_rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE funding_round_investors ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE patents ENABLE ROW LEVEL SECURITY;
ALTER TABLE patent_inventors ENABLE ROW LEVEL SECURITY;
ALTER TABLE grants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_merge_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE person_merge_map ENABLE ROW LEVEL SECURITY;

-- Public read access for core data tables (all authenticated users can read)
CREATE POLICY "Public read access" ON cities FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organizations FOR SELECT USING (true);
CREATE POLICY "Public read access" ON legal_entities FOR SELECT USING (true);
CREATE POLICY "Public read access" ON people FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_people FOR SELECT USING (true);
CREATE POLICY "Public read access" ON person_experience FOR SELECT USING (true);
CREATE POLICY "Public read access" ON sectors FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_sectors FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_tags FOR SELECT USING (true);
CREATE POLICY "Public read access" ON signals FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_events FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_relationships FOR SELECT USING (true);
CREATE POLICY "Public read access" ON products FOR SELECT USING (true);
CREATE POLICY "Public read access" ON organization_profiles FOR SELECT USING (true);
CREATE POLICY "Public read access" ON funding_rounds FOR SELECT USING (true);
CREATE POLICY "Public read access" ON funding_round_investors FOR SELECT USING (true);
CREATE POLICY "Public read access" ON articles FOR SELECT USING (true);
CREATE POLICY "Public read access" ON article_organizations FOR SELECT USING (true);
CREATE POLICY "Public read access" ON patents FOR SELECT USING (true);
CREATE POLICY "Public read access" ON patent_inventors FOR SELECT USING (true);
CREATE POLICY "Public read access" ON grants FOR SELECT USING (true);

-- User-specific RLS policies for user/product layer
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage own watchlist" ON watchlist
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own alerts" ON alerts
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own lists" ON lists
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Public lists are readable" ON lists
  FOR SELECT USING (is_public = TRUE);

CREATE POLICY "Users can manage own list items" ON list_items
  FOR ALL USING (
    list_id IN (SELECT id FROM lists WHERE user_id = auth.uid())
  );
CREATE POLICY "Public list items are readable" ON list_items
  FOR SELECT USING (
    list_id IN (SELECT id FROM lists WHERE is_public = TRUE)
  );

CREATE POLICY "Users can manage own saved searches" ON saved_searches
  FOR ALL USING (auth.uid() = user_id);
