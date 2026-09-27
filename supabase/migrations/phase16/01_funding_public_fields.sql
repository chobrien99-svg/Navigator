-- =============================================================================
-- Phase 16 — Public funding fields for the FTJ Funding Hub
-- =============================================================================
-- Adds the two fields the public funding API (/api/public/v1/funding/*) needs:
--
--   publish_status  Controls whether a round may appear on public surfaces
--                   such as frenchtechjournal.com/funding/. Only 'published'
--                   rows are returned by the public API. Existing rows default
--                   to 'published' so the hub launches with current data.
--                   Set a row to 'embargoed' or 'draft' before its
--                   announcement, or 'hidden' to pull it (rumour, rejected,
--                   duplicate) without deleting it.
--
--   ftj_url         Optional link to the related French Tech Journal story
--                   or Funding Wire edition. When set, the company name on
--                   /funding/ links to it.
--
-- Note: the Navigator app itself still reads funding_rounds with the public
-- "Public read access" RLS policy, so this flag filters the FTJ hub, not
-- Navigator's own screens.
-- =============================================================================

ALTER TABLE funding_rounds
  ADD COLUMN IF NOT EXISTS publish_status TEXT NOT NULL DEFAULT 'published'
    CHECK (publish_status IN ('published', 'embargoed', 'draft', 'hidden')),
  ADD COLUMN IF NOT EXISTS ftj_url TEXT;

CREATE INDEX IF NOT EXISTS idx_funding_publish_status_date
  ON funding_rounds (publish_status, announced_date DESC);
