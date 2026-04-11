# Navigator — Vision & 2-4 Week Strategic Roadmap

## Vision

**The Navigator is the authoritative, connected intelligence graph of the French innovation ecosystem.**

Crunchbase tells you a company raised money. PitchBook tells you who the investors are. Dealroom gives you a dashboard. But none of them answer the questions French Tech people actually ask:

- *"Of the 200 companies in the French Tech Next 40/120 history, how many came from an i-Lab or i-PhD program?"*
- *"Which French DeepTech founders have done this before — and where did their previous companies end up?"*
- *"When Mistral raised their Series A, which French Tech programs had they already been part of? Who else in that program has raised since?"*
- *"Of the companies Bpifrance invested in last year, how many were also awarded a government innovation grant or tax credit?"*

Answering those requires a **connected graph** — organizations, people, funding, programs, research labs, regulatory filings, and grants — all tied together by durable identifiers like SIREN. That graph doesn't exist anywhere else because:

1. The data is scattered across government open-data portals, private databases, and company websites
2. Most platforms are Anglo-centric and treat France as a thin slice
3. The SIREN-based linking that makes it all fit together requires real French domain knowledge

### What Navigator is becoming

A platform where:
- **Every French tech company** has a dossier that tells its complete story — funding, founders, programs, grants, patents, news
- **Every founder** has a trail of their companies past and present, with attribution across the ecosystem
- **Every program** (French Tech Next 40/120, i-Lab, i-Nov, i-PhD, French Tech Seed, grants, accelerators) has a full historic roster with year-over-year movement
- **Every funding round** is attributed to real SIREN entities so the same company across multiple datasets is recognized as one
- **The cross-references** — the "who came from where, who ended up where" — are first-class queries, not manual stitching

### Who it serves

**Today:** French Tech Journal editorial team — reporting, fact-checking, story research.

**Next:** Investors, corporates, government policy folks, academics, other journalists, scouts. Anyone whose work depends on understanding how the French innovation ecosystem actually connects.

**What the paid product looks like (eventually):** Tiered access — free tier for browsing individual company dossiers, pro tier for analytical views and cross-dataset queries, enterprise tier for bulk exports and custom research. But that's a later-phase question.

### North Star outcome

When a journalist, investor, or policymaker wants to know **anything** about the French tech ecosystem, The Navigator is the first place they go — and it gives them an answer that nowhere else can.

The 4-week roadmap below is about moving from **"we have the data"** to **"the data is actually connected and usable."**

---

## Context

The Navigator has evolved from a schema sketch into a genuinely useful institutional intelligence platform for the French innovation ecosystem. We now have:

- **~1,800 organizations** from Funding Tracker + AI Radar imports
- **6 years of French Tech Next 40/120** cohort data (2020-2025)
- **3,923 i-Lab laureates** across 27 years (1999-2025)
- **753 i-Nov laureates** (2018-2025)
- **234 i-PhD laureates** (2019-2025)
- **9 Q1 2026 funding deals** + pre-existing funding rounds
- **Admin editing** with RLS write policies + inline funding round editing
- **3 interactive program dashboards** (French Tech, i-Lab, i-Nov) with movement tracking

But the project has accumulated friction across three dimensions:
1. **Data is rich but disconnected** — only ~30% of orgs have SIREN, so cross-referencing across datasets is unreliable (is this iLab winner the same as this French Tech Next 40 company?)
2. **Admin UX is inconsistent** — funding list has search + pagination, org/people lists don't, making it painful to find things as the DB grows
3. **The connected value isn't surfaced** — an org's dossier doesn't yet show its full story across programs + funding + events

The next 4 weeks should focus on making the internal tool feel tight and complete — no external product prep, no Stripe, no signup flows. Build the thing French Tech Journal editors actually need to do their work, and the external product will follow naturally from there.

---

## Week 1 — Data Foundation & Cleanup

**Goal:** Connect the data you already have.

### 1.1 Deploy existing SIREN enrichment
- Run `data/siren_update.sql` (57 from web scraping) in Supabase SQL editor
- Run `data/siren_api_update.sql` (65 from recherche-entreprises API) in Supabase SQL editor
- **Outcome:** 122 new `legal_entities` rows linking orgs to their SIREN numbers

### 1.2 Full-database SIREN enrichment
- Export all orgs missing SIREN from Supabase (query provided in chat history)
- Run `scripts/enrich_siren_api.py` on the exported JSON
- Review medium-confidence matches in generated CSV
- Apply high-confidence SQL updates
- **Expected outcome:** 60-75% hit rate → 500-1000+ new SIREN records
- **Reusable:** `scripts/enrich_siren_api.py` (already built, resumable, with retry logic)

### 1.3 Detect and report duplicate organizations
After SIREN enrichment, some orgs will share a SIREN — these are duplicates created by different imports. Don't auto-merge; generate a review report:
- Query: orgs grouped by SIREN where count > 1
- **New file:** `scripts/detect_duplicates.py` — outputs `data/duplicates_review.csv`
- **Manual merge workflow** in admin UI (future week)

### 1.4 Remove Network Navigator from sidebar
- Edit `frontend/src/components/sidebar.tsx` — remove the `/network` entry from `navigation` array
- Edit `frontend/src/app/page.tsx` (if Network card exists on homepage) — remove or hide

### 1.5 Verify
- SQL count: `SELECT count(*) FROM legal_entities WHERE siren IS NOT NULL;` should increase significantly
- Dashboard stats on `/atlas` should reflect the enriched data
- Sidebar should no longer show Network Navigator

---

## Week 2 — Admin UX Parity

**Goal:** Make the admin experience feel consistent so editorial work is fast.

### 2.1 Add search + pagination to admin Organizations list
Mirror the pattern from `frontend/src/app/(admin)/admin/funding/page.tsx`:
- Server-side pagination with `.range(page*PAGE_SIZE, (page+1)*PAGE_SIZE - 1)`
- Client-side name search (or server-side ILIKE for larger datasets)
- Filter dropdowns: organization_type, status
- **Critical file:** `frontend/src/app/(admin)/admin/organizations/page.tsx`

### 2.2 Add search + pagination to admin People list
Same pattern.
- **Critical file:** `frontend/src/app/(admin)/admin/people/page.tsx`

### 2.3 Enrich org edit page with sectors + tags
Currently the org edit page handles core fields + organization_profiles + funding rounds. Missing:
- **Organization sectors** — multi-select with primary designation
- **Organization tags** — free-text tag chips with strength (1-5)
- **Critical file:** `frontend/src/app/(admin)/admin/organizations/[id]/page.tsx` — extend the form

### 2.4 "Create new" actions
Neither admin list has a "Create new" button. Add:
- New button → `/admin/organizations/new` (or inline form)
- Same for people
- **New files:** `frontend/src/app/(admin)/admin/organizations/new/page.tsx`, `frontend/src/app/(admin)/admin/people/new/page.tsx`

### 2.5 Verify
- Navigate to `/admin/organizations` — should see search box, page controls, 50 rows per page
- Search "Doctolib" should filter the list
- Click a row → edit page should have sector + tag sections
- Click "Create new" → empty form → fills in → saves → redirects back to list

---

## Week 3 — Cross-Dataset Value

**Goal:** Surface the stories that were hidden before data was connected.

### 3.1 Programs section on entity dossier
On `/entities/[slug]`, add a "Programs & Awards" card showing:
- All `program_organizations` for this org joined to `program_editions` and `programs`
- Grouped by program (French Tech Next 40/120, i-Lab, i-Nov)
- Timeline: which years, which tier/domain, Grand Prix winners highlighted
- **Critical file:** `frontend/src/app/(dashboard)/entities/[slug]/page.tsx`
- **New query:** `getOrganizationPrograms(orgId)` — already exists in `queries.ts`, just wire it in

### 3.2 Programs landing page
Create `/programs` — a hub listing all programs with summary stats, linking to each dashboard.
- **New files:** `frontend/src/app/(dashboard)/programs/page.tsx`
- Add to primary sidebar nav (replace Network Navigator slot)

### 3.3 Cross-program analytical queries
New dashboard insights that surface connected patterns. Pick 2-3 to start:
- "**iLab pipeline to French Tech**" — of all iLab laureates, how many later joined French Tech Next 40/120? (join via SIREN where available)
- "**Funding by program**" — total capital raised by companies in each program, comparing iLab vs French Tech vs unaffiliated
- "**Most decorated**" — companies that appear in multiple programs (iLab + iNov + French Tech), ranked
- These can be new cards on the Atlas page or a dedicated `/insights` page
- **Critical file:** `frontend/src/app/(dashboard)/atlas/page.tsx` (replace cluster stub with these insights)

### 3.4 People dossier cross-references
On `/people/[slug]`, show:
- All companies they've founded (from `organization_people` where `is_founder = true`)
- Their i-Lab / i-PhD participation (via `organization_people` → org → program_organizations)
- **Critical file:** `frontend/src/app/(dashboard)/people/[slug]/page.tsx`

### 3.5 Verify
- Visit `/entities/doctolib` → should show French Tech Next 40/120 membership timeline
- Visit `/entities/alan` → should show French Tech + any program history
- `/programs` → should list all 3 programs with stats
- Atlas page → should show the new cross-dataset insights instead of the placeholder cluster viz

---

## Week 4 — Admin Depth + Duplicate Merging

**Goal:** Make admin workflows handle the messy reality of the data.

### 4.1 Duplicate organization merge UI
From Week 1.3, we'll have a list of orgs sharing a SIREN. Build the tool to merge them safely:
- Side-by-side comparison of the duplicate orgs
- Pick which fields to keep from which side
- Atomic merge: move all funding_rounds, organization_people, program_organizations, tags from B → A, then delete B
- **New files:** `frontend/src/app/(admin)/admin/merge/page.tsx`
- **New Supabase RPC function:** `merge_organizations(keep_id, delete_id)` in a new migration
- **Critical table awareness:** everything that references `organizations.id` needs to be updated in the merge transaction

### 4.2 Bulk operations on admin org list
- Checkbox column, bulk actions: "Add tag", "Change type", "Mark inactive", "Delete"
- Useful for cleaning up data imports in bulk
- **Critical file:** `frontend/src/app/(admin)/admin/organizations/page.tsx`

### 4.3 Admin activity log (optional)
Simple append-only log table for audit trail:
- `admin_activity (id, user_id, action, table_name, record_id, diff, created_at)`
- Log on every admin UPDATE via a Postgres trigger or application-level logging
- Display recent activity on admin dashboard
- **New migration:** `00006_admin_activity_log.sql`

### 4.4 Verify
- Run duplicate detection → find a known duplicate pair
- Use merge UI → merge them → verify funding rounds / program memberships preserved on the survivor, no orphan references to the deleted row
- Select 5 orgs in admin list → bulk-tag them → verify tags applied
- (Optional) Admin dashboard shows "5 changes by Chris in the last hour"

---

## Critical Files (Overall)

### Read to understand patterns
- `frontend/src/app/(admin)/admin/funding/page.tsx` — the gold standard for admin list pages
- `frontend/src/app/(dashboard)/programs/french-tech-next40-120/french-tech-dashboard.tsx` — interactive dashboard pattern
- `frontend/src/app/(admin)/admin/organizations/[id]/page.tsx` — admin edit pattern with inline editing
- `frontend/src/lib/queries.ts` — query conventions (the 3-step program lookup pattern)

### Scripts already built (reuse, don't rebuild)
- `scripts/enrich_siren_api.py` — resumable SIREN enrichment with retry logic
- `scripts/scrape_siren.py` — fallback web scraper for orgs not in SIRENE
- `scripts/fetch_ilab_laureates.py`, `scripts/fetch_inov_iphd.py` — MESR API fetchers

### Files that will be created
- `scripts/detect_duplicates.py` (Week 1)
- `frontend/src/app/(admin)/admin/organizations/new/page.tsx` (Week 2)
- `frontend/src/app/(admin)/admin/people/new/page.tsx` (Week 2)
- `frontend/src/app/(dashboard)/programs/page.tsx` (Week 3)
- `frontend/src/app/(admin)/admin/merge/page.tsx` (Week 4)
- `supabase/migrations/00006_admin_activity_log.sql` (Week 4, optional)

### Files that will be modified
- `frontend/src/components/sidebar.tsx` (Week 1: remove Network)
- `frontend/src/app/(admin)/admin/organizations/page.tsx` (Week 2: search/paginate; Week 4: bulk ops)
- `frontend/src/app/(admin)/admin/people/page.tsx` (Week 2: search/paginate)
- `frontend/src/app/(admin)/admin/organizations/[id]/page.tsx` (Week 2: sectors + tags)
- `frontend/src/app/(dashboard)/entities/[slug]/page.tsx` (Week 3: programs card)
- `frontend/src/app/(dashboard)/people/[slug]/page.tsx` (Week 3: cross-refs)
- `frontend/src/app/(dashboard)/atlas/page.tsx` (Week 3: replace stub with real insights)
- `frontend/src/lib/queries.ts` (Week 3: new analytical queries)

---

## What This Plan Does NOT Include

Intentionally deferred to keep the scope focused:
- **No Stripe integration, subscription UI, or paywalls** — schema-ready, but product-level work waits
- **No user signup flow** — current Supabase Auth login is sufficient for internal use
- **No Network Navigator visualization** — removed from nav to stop promising what isn't there
- **No Ecosystem Atlas cluster visualization** — replaced by cross-dataset insight cards (simpler, more immediately valuable)
- **No historic funding data import** — waiting on data source; can be slotted in whenever
- **No landing page or marketing site** — internal-only for now

---

## Verification End-to-End

After all 4 weeks:

1. **Data completeness check** (Supabase SQL)
   ```sql
   SELECT
     (SELECT count(*) FROM organizations) AS total_orgs,
     (SELECT count(*) FROM legal_entities WHERE siren IS NOT NULL) AS orgs_with_siren,
     (SELECT count(*) FROM organizations o
      LEFT JOIN legal_entities le ON le.organization_id = o.id
      WHERE le.siren IS NULL) AS orgs_missing_siren;
   ```
   Target: orgs_with_siren > 50% of total_orgs (up from ~10% today)

2. **Admin UX smoke test**
   - `/admin/organizations` → search, paginate, create new, edit, delete
   - `/admin/people` → same
   - `/admin/funding` → unchanged (already good)
   - `/admin/merge` → can merge a known duplicate pair

3. **Cross-dataset narrative**
   - Pick a well-known French company (e.g., Doctolib). Visit `/entities/doctolib`.
   - Should see: description + full French Tech Next 40/120 history + funding rounds + i-Lab participation (if any) + founders with links to their other companies.
   - This is the "wow" moment that proves the data is connected.

4. **Build passes**
   - `npm run build` in `frontend/` should complete without TypeScript errors on Vercel.

5. **No regression in existing pages**
   - `/entities`, `/funding`, `/programs/french-tech-next40-120`, `/programs/i-lab`, `/programs/i-nov` should all still work.
