-- Céline Lazorthes (co-founder) left Resilience in 2025: keep her as founder,
-- but no longer current. Applied to production 2026-11-08.
UPDATE organization_people op SET is_current=FALSE, updated_at=NOW()
FROM organizations o, people p
WHERE op.organization_id=o.id AND op.person_id=p.id AND o.slug='resilience' AND p.slug='celine-lazorthes';
