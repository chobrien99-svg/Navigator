-- Resilience: since 30 June 2025 the Président is DANUBE 524 SB ASSETS, S.L.
-- (Spanish SL, Alcobendas, Madrid), represented by Jonathan Benhamou — per the
-- company's appointment act (user-provided excerpt). Recorded as the title on
-- Benhamou's link to Resilience. Applied to production 2026-11-08.
UPDATE organization_people op
SET title = 'Président (via DANUBE 524 SB ASSETS, S.L., represented by Jonathan Benhamou, since 30 June 2025)', updated_at = NOW()
FROM organizations o, people p
WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='resilience' AND p.slug='jonathan-benhamou';
