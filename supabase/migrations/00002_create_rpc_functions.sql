-- =============================================================================
-- RPC Functions for the Unified Database
-- =============================================================================

-- increment_export_usage: atomically increment export count for a user/period
CREATE OR REPLACE FUNCTION increment_export_usage(p_user_id UUID, p_period TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO export_usage (user_id, period, export_count)
  VALUES (p_user_id, p_period, 1)
  ON CONFLICT (user_id, period)
  DO UPDATE SET export_count = export_usage.export_count + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
