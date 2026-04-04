-- =============================================================================
-- French Tech Next 40/120 — Program & Edition Setup
-- =============================================================================
-- Creates the program record and edition records for each cohort year.
-- Run this BEFORE the per-year company import migrations.
-- =============================================================================

-- Step 1: Create the program (skip if it already exists)
INSERT INTO programs (
  id, name, slug, program_type, description, country, source_url,
  created_at, updated_at
)
VALUES (
  uuid_generate_v4(),
  'French Tech Next 40/120',
  'french-tech-next40-120',
  'government_label',
  'The French government''s flagship program highlighting the nation''s most promising and high-growth tech companies. The Next 40 recognizes the top-tier scale-ups, while the FT 120 captures the broader cohort of rising champions.',
  'France',
  'https://lafrenchtech.gouv.fr/fr/programme/french-tech-next-40-120/',
  NOW(),
  NOW()
)
ON CONFLICT (slug) DO NOTHING;

-- Step 2: Create editions for each cohort year (2020–2025)
INSERT INTO program_editions (
  id, program_id, name, slug, year, cohort_label,
  source_url, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  p.id,
  e.name,
  e.slug,
  e.year,
  e.cohort_label,
  'https://lafrenchtech.gouv.fr/fr/programme/french-tech-next-40-120/',
  NOW(),
  NOW()
FROM programs p
CROSS JOIN (VALUES
  ('French Tech Next 40/120 — 2020', 'french-tech-next40-120-2020', 2020, '2020'),
  ('French Tech Next 40/120 — 2021', 'french-tech-next40-120-2021', 2021, '2021'),
  ('French Tech Next 40/120 — 2022', 'french-tech-next40-120-2022', 2022, '2022'),
  ('French Tech Next 40/120 — 2023', 'french-tech-next40-120-2023', 2023, '2023'),
  ('French Tech Next 40/120 — 2024', 'french-tech-next40-120-2024', 2024, '2024'),
  ('French Tech Next 40/120 — 2025', 'french-tech-next40-120-2025', 2025, '2025')
) AS e(name, slug, year, cohort_label)
WHERE p.slug = 'french-tech-next40-120'
ON CONFLICT DO NOTHING;
