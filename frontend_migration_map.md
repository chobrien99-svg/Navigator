# AI Radar Frontend → Unified DB Query Migration Map

## Table Name Mapping

| AI Radar Table | Unified DB Table | Notes |
|---------------|-----------------|-------|
| `startups` | `organizations` | Filter by `organization_type = 'startup'` |
| `founders` | `people` | Founders are people with `is_founder = TRUE` in organization_people |
| `startup_founders` | `organization_people` | `startup_id` → `organization_id`, `founder_id` → `person_id` |
| `startup_tags` | `organization_tags` | `startup_id` → `organization_id`, `label` → `tag` |
| `signals` | `signals` | `startup_id` → `organization_id` (same table name) |
| `profiles` | `profiles` | Same structure, added fields |
| `watchlist` | `watchlist` | `startup_id` → `organization_id` |
| `lists` | `lists` | Same structure |
| `list_items` | `list_items` | `startup_id` → `organization_id` |
| `saved_searches` | `saved_searches` | Same structure |
| `alerts` | `alerts` | `startup_id` → `organization_id` |
| `export_usage` | `export_usage` | Same structure |

## Column Name Changes

### organizations (was startups)
- `is_active` → `status = 'active'` (enum instead of boolean)
- `sector` → moved to `organization_sectors` join table
- `stage` → removed (use funding_rounds for stage tracking)
- `website_url` → `website`
- `contact_email` → `email`
- `contact_phone` → `phone`
- Profile fields (`investor_brief`, `analyst_note`, etc.) → moved to `organization_profiles` table
- Funding fields (`total_raised_eur`, `last_round`, etc.) → kept on organizations

### people (was founders)
- `name` → `full_name`
- `founder_signals` → removed (use signals table)
- `previous_companies` → removed (use person_experience table)
- `previous_exits` → changed from TEXT[] to INTEGER (count)

### organization_people (was startup_founders)
- `startup_id` → `organization_id`
- `founder_id` → `person_id`
- Added: `is_founder`, `is_current`, `title`, `start_date`, `end_date`

### organization_tags (was startup_tags)
- `startup_id` → `organization_id`
- `label` → `tag`
- `strength` → changed from enum to INTEGER (1-5)

### signals
- `startup_id` → `organization_id`
- `strength` → changed from enum to INTEGER (1-5)
- Added: `source_type`, `source_name`, `source_url`, `confidence_score`, `verification_status`

## Files Requiring Changes (25 files)

### Page Components (5 files)
1. `app/database/page.tsx` — main startup list/filter page
2. `app/startup/[slug]/page.tsx` — individual startup profile
3. `app/founder/[slug]/page.tsx` — individual founder profile
4. `app/account/page.tsx` — user account/watchlist/lists
5. `components/app-nav.tsx` — navigation (profile tier check)

### Admin API Routes (5 files)
6. `app/api/admin/startups/route.ts` — create startup
7. `app/api/admin/startups/[id]/route.ts` — update/delete startup
8. `app/api/admin/startups/[id]/founders/route.ts` — link founders
9. `app/api/admin/founders/route.ts` — create founder
10. `app/api/admin/founders/[id]/route.ts` — update/delete founder

### User API Routes (5 files)
11. `app/api/lists/route.ts` — create list
12. `app/api/lists/[id]/route.ts` — delete list
13. `app/api/lists/[id]/items/route.ts` — add/remove list items
14. `app/api/watchlist/route.ts` — add/remove watchlist
15. `app/api/startup/[slug]/export-csv/route.ts` — CSV export

### Auth/Stripe API Routes (2 files)
16. `app/api/stripe/portal/route.ts` — Stripe portal
17. `app/api/stripe/webhook/route.ts` — Stripe webhook

### Lib Files (2 files)
18. `lib/admin.ts` — admin check
19. `lib/supabase/server.ts` — client init (no query changes)

### RPC Functions
- `increment_export_usage` — needs to be recreated in unified DB

## Recommended Migration Order
1. Create compatibility views (instant cutover)
2. Update page components (user-facing)
3. Update admin API routes
4. Update user API routes
5. Update auth/Stripe routes
6. Drop views once all queries updated
