-- Castalie: total_raised_eur was 0 (hidden on the page) although it has three
-- rounds totalling €16.1M (pre-seed €0.6M 2013, pre-seed €2.0M 2015,
-- Series B €13.5M 2020). Set it to the sum of its rounds (in millions).
-- Applied to production 2026-11-08.
UPDATE organizations o
SET total_raised_eur = (SELECT sum(amount_eur) FROM funding_rounds fr WHERE fr.organization_id = o.id), updated_at = NOW()
WHERE o.slug = 'castalie';
