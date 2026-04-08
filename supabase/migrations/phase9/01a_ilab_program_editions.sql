CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: Create i-Lab program and yearly editions
INSERT INTO programs (
  id, name, slug, program_type, description, country, source_url,
  created_at, updated_at
)
VALUES (
  uuid_generate_v4(),
  'i-Lab',
  'i-lab',
  'competition',
  'Concours national d''aide à la création d''entreprises de technologies innovantes. Deep-tech startup competition run by Bpifrance since 1999.',
  'France',
  'https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-lab',
  NOW(), NOW()
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO program_editions (
  id, program_id, name, slug, year, cohort_label,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  p.id,
  e.name,
  e.slug,
  e.year,
  e.cohort_label,
  NOW(), NOW()
FROM programs p
CROSS JOIN (VALUES
  ('i-Lab — 1999', 'i-lab-1999', 1999, '1999'),
  ('i-Lab — 2000', 'i-lab-2000', 2000, '2000'),
  ('i-Lab — 2001', 'i-lab-2001', 2001, '2001'),
  ('i-Lab — 2002', 'i-lab-2002', 2002, '2002'),
  ('i-Lab — 2003', 'i-lab-2003', 2003, '2003'),
  ('i-Lab — 2004', 'i-lab-2004', 2004, '2004'),
  ('i-Lab — 2005', 'i-lab-2005', 2005, '2005'),
  ('i-Lab — 2006', 'i-lab-2006', 2006, '2006'),
  ('i-Lab — 2007', 'i-lab-2007', 2007, '2007'),
  ('i-Lab — 2008', 'i-lab-2008', 2008, '2008'),
  ('i-Lab — 2009', 'i-lab-2009', 2009, '2009'),
  ('i-Lab — 2010', 'i-lab-2010', 2010, '2010'),
  ('i-Lab — 2011', 'i-lab-2011', 2011, '2011'),
  ('i-Lab — 2012', 'i-lab-2012', 2012, '2012'),
  ('i-Lab — 2013', 'i-lab-2013', 2013, '2013'),
  ('i-Lab — 2014', 'i-lab-2014', 2014, '2014'),
  ('i-Lab — 2015', 'i-lab-2015', 2015, '2015'),
  ('i-Lab — 2016', 'i-lab-2016', 2016, '2016'),
  ('i-Lab — 2017', 'i-lab-2017', 2017, '2017'),
  ('i-Lab — 2018', 'i-lab-2018', 2018, '2018'),
  ('i-Lab — 2019', 'i-lab-2019', 2019, '2019'),
  ('i-Lab — 2020', 'i-lab-2020', 2020, '2020'),
  ('i-Lab — 2021', 'i-lab-2021', 2021, '2021'),
  ('i-Lab — 2022', 'i-lab-2022', 2022, '2022'),
  ('i-Lab — 2023', 'i-lab-2023', 2023, '2023'),
  ('i-Lab — 2024', 'i-lab-2024', 2024, '2024'),
  ('i-Lab — 2025', 'i-lab-2025', 2025, '2025')
) AS e(name, slug, year, cohort_label)
WHERE p.slug = 'i-lab'
ON CONFLICT DO NOTHING;
