-- =============================================================================
-- Ksilink: founders and leadership team
-- =============================================================================
-- legacy_source 'ksilink_team_november_2026'. Supplied by the editor (FTJ):
--   * Founders: Dr Ulf Nehrbass (original founder, now scientific & strategic
--     advisor); Antoine de Lacombe and Dr Mona Boyé, both identified as
--     co-founders in Ksilink's investor presentation.
--   * Executive team per ksilink.com/our-team and /exteam.
--   * Alain Beretz: chairman of the Ksilink Association, which is the
--     president (controlling entity) of KSILINK SERVICES SAS.
-- NB: Ksilink Services has been in judicial liquidation since 28 Sept 2026;
-- the team pages may predate that, so "current" roles reflect the website.
-- =============================================================================

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Ulf Nehrbass","first_name":"Ulf","last_name":"Nehrbass"},
  {"full_name":"Mona Boyé","first_name":"Mona","last_name":"Boyé"},
  {"full_name":"Helmut Haning","first_name":"Helmut","last_name":"Haning"},
  {"full_name":"Arnaud Ogier","first_name":"Arnaud","last_name":"Ogier"},
  {"full_name":"Karen Schmitt","first_name":"Karen","last_name":"Schmitt"},
  {"full_name":"François Kien","first_name":"François","last_name":"Kien"},
  {"full_name":"Alain Beretz","first_name":"Alain","last_name":"Beretz"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'ksilink_team_november_2026', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Antoine de Lacombe: existing 'CEO' link becomes a founder link
UPDATE organization_people op SET role='Founder', title='Co-founder; CEO & CFO', is_founder=TRUE, updated_at=NOW()
FROM organizations o, people p
WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='ksilink' AND p.slug='antoine-de-lacombe' AND op.role='CEO'
  AND NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=p.id AND x.role='Founder');

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"person":"ulf-nehrbass","role":"Founder","title":"Founder; Scientific & Strategic Advisor","founder":true},
  {"person":"mona-boye","role":"Founder","title":"Co-founder; Chief Business Development Officer","founder":true},
  {"person":"helmut-haning","role":"COO","title":"Chief Operating Officer (formerly Global Head of Medicinal Chemistry, Bayer)","founder":false},
  {"person":"arnaud-ogier","role":"Head of AI & Data","title":"Head of AI & Data","founder":false},
  {"person":"karen-schmitt","role":"R&D Director","title":"R&D Director","founder":false},
  {"person":"francois-kien","role":"Operations Manager","title":"Operations Manager","founder":false},
  {"person":"alain-beretz","role":"Chairman","title":"Chairman, Ksilink Association (controlling entity of Ksilink Services)","founder":false}
]$json$) AS (person TEXT, role TEXT, title TEXT, founder BOOLEAN))
INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, s.role, s.title, TRUE, s.founder, 'ksilink_team_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug='ksilink' JOIN people p ON p.slug=s.person
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

SELECT p.full_name, op.role, op.title, op.is_founder
FROM organization_people op JOIN people p ON p.id=op.person_id JOIN organizations o ON o.id=op.organization_id
WHERE o.slug='ksilink' ORDER BY op.is_founder DESC, p.full_name;
