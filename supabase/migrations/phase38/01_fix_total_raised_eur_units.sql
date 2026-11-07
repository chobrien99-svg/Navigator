-- =============================================================================
-- Fix organizations.total_raised_eur unit mismatch
-- =============================================================================
-- total_raised_eur is stored in MILLIONS of euros (like funding_rounds.amount_eur);
-- the site formats it with formatEurFromDb (×1,000,000). The admin edit form
-- saved it as typed in raw euros, so e.g. Granit's €5M was stored as 5000000
-- and displayed as "€5000.0B". 11 orgs were affected (granit, uncovr,
-- bleu-robotics, fleuret-ai, outline, kervalion, cyberna, neurathletics,
-- exanodia, neutrogen-technologies, sagacity-health). The form now converts
-- raw euros to millions on save. Applied to production 2026-11-07.
--
-- Any value >= 1000 is necessarily raw euros (€1,000M+ for a startup total
-- would be implausible in this table; the max correct value was < 1).
UPDATE organizations
SET total_raised_eur = round(total_raised_eur / 1000000.0, 2), updated_at = NOW()
WHERE total_raised_eur >= 1000;
