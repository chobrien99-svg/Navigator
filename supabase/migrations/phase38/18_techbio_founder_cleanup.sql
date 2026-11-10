-- =============================================================================
-- TechBio founder clean-up (10 Nov 2026)
-- =============================================================================
-- legacy_source 'techbio_founder_cleanup_november_2026'.
-- * Bioptimus: one "person" held six names separated by ';'. Split into six
--   people; Eric Durand is the same person already recorded as Rivercell
--   co-founder (Rivercell press coverage: ex-Owkin, co-founded Bioptimus).
-- * Spore.Bio: one "person" held three names. Split; Amine Raji already exists.
-- * Netri: one "person" held "Thibault Honegger; Florian Larramendy; CA Netri
--   Goel". Split into the two founders; "CA Netri Goel" is an import artefact
--   and is dropped. Thibault Honegger already exists (linked to Lys Therapeutics).
-- * Rivercell: Yann Fleureau linked twice ('Founder' and 'founder'); duplicate
--   link removed.
-- * Scienta Lab: wrong 'energy' sector removed.
-- * Tebuna: only its president (Minyoung Heo, appointed 17 Nov 2025; company
--   registered 5 Nov 2025) is public; no source names the founders, so she is
--   left as President, not marked founder.
-- =============================================================================
BEGIN;
WITH src(full_name, first_name, last_name) AS (VALUES
 ('David Cahané','David','Cahané'),('Jean-Philippe Vert','Jean-Philippe','Vert'),('Rodolphe Jenatton','Rodolphe','Jenatton'),
 ('Felipe Llinares López','Felipe','Llinares López'),('Zelda Mariet','Zelda','Mariet'),
 ('Mohamed Tazi','Mohamed','Tazi'),('Maxime Mistretta','Maxime','Mistretta'),('Florian Larramendy','Florian','Larramendy'))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'techbio_founder_cleanup_november_2026', NOW()
FROM src s ON CONFLICT (slug) DO NOTHING;

WITH src(org, person, title) AS (VALUES
 ('bioptimus','david-cahane','Co-founder'),('bioptimus','eric-durand','Co-founder'),('bioptimus','jean-philippe-vert','Co-founder'),
 ('bioptimus','rodolphe-jenatton','Co-founder'),('bioptimus','felipe-llinares-lopez','Co-founder'),('bioptimus','zelda-mariet','Co-founder'),
 ('spore-biotechnologies','mohamed-tazi','Co-founder'),('spore-biotechnologies','maxime-mistretta','Co-founder'),
 ('netri','thibault-honegger','Co-founder'),('netri','florian-larramendy','Co-founder'))
INSERT INTO organization_people (id, organization_id, person_id, role, title, is_current, is_founder, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', s.title, TRUE, TRUE, 'techbio_founder_cleanup_november_2026', NOW(), NOW()
FROM src s JOIN organizations o ON o.slug=s.org JOIN people p ON p.slug=s.person
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=p.id AND x.is_founder);

-- remove the combined records (links first, then the orphaned people)
DELETE FROM organization_people WHERE person_id IN (SELECT id FROM people WHERE slug IN
 ('david-cahane-eric-durand-jean-philippe-vert-rodolphe-jenatton-felipe-llinares-lopez-zelda-mariet','amine-raji-mohamed-tazi-maxime-mistretta','thibault-honegger-florian-larramendy-ca-netri-goel'));
DELETE FROM people p WHERE p.slug IN
 ('david-cahane-eric-durand-jean-philippe-vert-rodolphe-jenatton-felipe-llinares-lopez-zelda-mariet','amine-raji-mohamed-tazi-maxime-mistretta','thibault-honegger-florian-larramendy-ca-netri-goel')
 AND NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.person_id=p.id);

-- Rivercell: duplicate founder link for Yann Fleureau
DELETE FROM organization_people op USING organizations o, people p
WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='rivercell' AND p.slug='yann-fleureau' AND op.role='founder'
  AND EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=p.id AND x.role='Founder');

-- Scienta Lab: remove wrong energy sector
DELETE FROM organization_sectors os USING organizations o, sectors s
WHERE os.organization_id=o.id AND os.sector_id=s.id AND o.slug='scienta-lab' AND s.slug='energy';
COMMIT;

SELECT o.slug, string_agg(p.full_name, ', ' ORDER BY p.full_name) founders
FROM organization_people op JOIN people p ON p.id=op.person_id JOIN organizations o ON o.id=op.organization_id
WHERE op.is_founder AND o.slug IN ('bioptimus','spore-biotechnologies','netri','rivercell','scienta-lab') GROUP BY 1
UNION ALL SELECT 'scienta-lab sectors', string_agg(s.slug, ',') FROM organization_sectors os JOIN sectors s ON s.id=os.sector_id JOIN organizations o ON o.id=os.organization_id WHERE o.slug='scienta-lab';
