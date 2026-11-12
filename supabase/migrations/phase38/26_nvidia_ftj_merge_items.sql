-- =============================================================================
-- NVIDIA items found by the FTJ Ghost-archive run (merge, 12 Nov 2026)
-- =============================================================================
-- legacy_source 'nvidia_france_november_2026'. See data/nvidia_france_2026/merge/MERGE.md.
-- * Competition authority: raid on NVIDIA's Paris office, late Sep 2023 (FTJ
--   5 Oct 2023: "last week"; exact day not confirmed); probe "nearing its end"
--   (July 2026, Euronews/AFP, The Next Web). No statement of objections or
--   decision found as of 12 Nov 2026.
-- * Sesterce: H100 supercomputer in Marseille (FTJ La Machine #9, Nov 2024).
-- * HPE x NVIDIA AI Factory Lab, Grenoble: announced 1 Dec 2025 (HPE / Business
--   Wire); HPE listed availability for Q2 2026.
-- * Pollen Robotics (Bordeaux, Reachy robots): acquired by Hugging Face,
--   announced 14 Apr 2025 (TechCrunch, Fortune); passes to NVIDIA when the
--   Hugging Face acquisition closes.
-- =============================================================================
BEGIN;

INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.t::event_type, s.d::date, s.ti, s.de, s.u, s.st, s.sn, s.v, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('nvidia','other','2023-09-27','French competition authority raids NVIDIA''s Paris office',
  'The Autorité de la concurrence searched NVIDIA''s Paris office in late September 2023 as part of an inquiry into possible anti-competitive practices in the graphics-card and cloud sector (exact day not confirmed; FTJ reported it on 5 Oct 2023 as "last week"). Its president Benoît Cœuré confirmed the probe to Reuters in 2024.',
  'https://www.frenchtechjournal.com/france-gaga-ai/','press','French Tech Journal; Reuters','medium'),
 ('nvidia','other','2026-07-15','French competition authority says NVIDIA probe is nearing its end',
  'The Autorité de la concurrence said its investigation into NVIDIA was nearing its end. Reported concerns include developers'' dependence on CUDA and NVIDIA''s investments in AI cloud providers. No statement of objections or decision had been announced as of 12 Nov 2026.',
  'https://thenextweb.com/news/france-nvidia-antitrust-probe-nearing-end','press','Euronews/AFP; The Next Web; French Tech Journal','medium'),
 ('nvidia','expansion','2025-12-01','HPE and NVIDIA announce AI Factory Lab in Grenoble',
  'HPE and NVIDIA announced an AI Factory Lab in Grenoble, billed as the first in the EU, where customers can test sovereign AI factories (NVIDIA AI Enterprise, Spectrum-X networking, HPE servers and storage). HPE listed availability for Q2 2026.',
  'https://www.hpe.com/us/en/newsroom/press-release/2025/12/hpe-and-nvidia-simplify-ai-ready-data-centers-with-secure-next-gen-ai-factories.html','press_release','HPE / Business Wire','high'),
 ('sesterce','product_launch','2024-11-01','Sesterce unveils H100 AI supercomputer in Marseille',
  'Sesterce unveiled an AI supercomputer in Marseille built on NVIDIA H100 GPUs (FTJ, November 2024 recap).',
  'https://www.frenchtechjournal.com/la-machine-9-french-ai-radar-november-recap/','press','French Tech Journal','medium'),
 ('pollen-robotics','acquisition','2025-04-14','Hugging Face acquires Pollen Robotics',
  'Hugging Face bought the Bordeaux maker of the open-source Reachy humanoid robots for an undisclosed amount; co-founders Matthieu Lapeyre and Pierre Rouanet and about 20 staff joined Hugging Face. Pollen passes to NVIDIA when NVIDIA''s acquisition of Hugging Face closes.',
  'https://techcrunch.com/2025/04/14/hugging-face-buys-a-humanoid-robotics-startup','press','TechCrunch; Fortune','high')) s(slug,t,d,ti,de,u,st,sn,v)
JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM organization_events e WHERE e.organization_id=o.id AND e.title=s.ti);

INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.de, s.d::date, s.st, s.sn, s.u, s.v, 'nvidia_france_november_2026', NOW(), NOW()
FROM (VALUES
 ('hugging-face','pollen-robotics','acquired','Acquired Pollen Robotics (announced 14 Apr 2025), amount undisclosed.','2025-04-14','press','TechCrunch','https://techcrunch.com/2025/04/14/hugging-face-buys-a-humanoid-robotics-startup','high'),
 ('hewlett-packard-enterprise','nvidia','partnered_with','AI Factory Lab in Grenoble for sovereign AI infrastructure (announced 1 Dec 2025).','2025-12-01','press_release','HPE / Business Wire','https://www.hpe.com/us/en/newsroom/press-release/2025/12/hpe-and-nvidia-simplify-ai-ready-data-centers-with-secure-next-gen-ai-factories.html','high'),
 ('sesterce','nvidia','partnered_with','Builds its AI cloud and Marseille supercomputer on NVIDIA H100 GPUs (customer relationship).','2024-11-01','press','French Tech Journal','https://www.frenchtechjournal.com/la-machine-9-french-ai-radar-november-recap/','medium')) s(src,tgt,t,de,d,st,sn,u,v)
JOIN organizations a ON a.slug=s.src JOIN organizations b ON b.slug=s.tgt
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type);

UPDATE organizations SET description=coalesce(description,'Bordeaux robotics company behind the open-source Reachy humanoid robots and the Reachy Mini desktop robot. Acquired by Hugging Face in April 2025.'),
  website=coalesce(website,'https://www.pollen-robotics.com'),
  city_id=coalesce(city_id,(SELECT id FROM cities WHERE slug='bordeaux')), updated_at=NOW()
WHERE slug='pollen-robotics';
UPDATE organizations SET description=description||' Now an AI cloud and compute provider; unveiled an NVIDIA H100 supercomputer in Marseille in November 2024.', updated_at=NOW()
WHERE slug='sesterce' AND description NOT LIKE '%H100%';

COMMIT;
