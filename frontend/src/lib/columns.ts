// Columns of `people` and `organizations` that pages may read.
//
// Email and phone are not in these lists: once
// supabase/migrations/phase28/02_hide_contact_columns.sql is applied, the
// database no longer lets the site's public key read them, so asking for
// "*" on these tables fails with "permission denied". The Navigator team
// gets them through lib/contact.ts instead.
//
// Written as one fixed string (not built at runtime) so supabase-js can
// check the column names and type the results.
//
// Adding a column to either table? Add it here, and grant it in the same
// way as phase28/02 does, or pages won't be able to read it.

export const PERSON_COLUMNS =
  "id,full_name,slug,first_name,last_name,linkedin_url,twitter_url,bio,photo_url,has_phd,is_repeat_founder,has_big_tech_background,big_tech_employer,academic_lab,previous_exits,legacy_source,legacy_id,created_at,updated_at,verification_status,is_public_profile,google_scholar_url,github_url,personal_website_url,notable_publications,short_bio" as const;

export const ORGANIZATION_COLUMNS =
  "id,name,slug,organization_type,description,short_description,website,linkedin_url,twitter_url,logo_url,status,country,city_id,founded_date,employee_count,employee_range,founded_year,first_seen_at,is_stealth,total_raised_eur,last_round,fundraising_status,technology_layer,signal_count,last_signal_date,legacy_source,legacy_id,created_at,updated_at,is_public_profile,verification_status,secondary_city_id" as const;
