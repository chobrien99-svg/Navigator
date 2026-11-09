# Atlas test topic: small modular reactors (France 2030 Objectif 1)

Everything behind the SMR network page, so the work can be rebuilt or audited.

## Source
- `sources/smr_1.pdf` … `smr_7.pdf`: the official France 2030 laureates map (info.gouv.fr),
  filtered on Objectif 1, saved by hand in November 2026 (the site blocks automated access).
  `.txt` files are `pdftotext -layout` extracts.

## Pipeline (run in order)
1. `parse_f2030.py`: reads the page extracts, 139 rows → 138 unique (Innowtech/PACH3 listed twice).
2. `resolve.py`: matches each organisation to the company register (recherche-entreprises.api.gouv.fr)
   by name + département; saves after each organisation. Manual overrides are noted in the files.
3. `build_sql.py`: builds `supabase/migrations/phase38/12_atlas_smr_france2030_obj1.sql`.

## Data
- `france2030_obj1_laureates.json`: 138 rows with SIREN and match confidence.
- `network.json`: 68 organisations, 53 projects, partners, lead, published State aid.
- `project_funding.json`: lead partner, call, description and aid per project, with source URL and quote.
- `amounts_reactors.json`, `amounts_waste.json`: the raw research notes (call totals, contradictions).
- `projects_with_partners.txt`: plain list used for the research.

## Database migrations (supabase/migrations/phase38/)
- `12_atlas_smr_france2030_obj1.sql`: organisations, SIRENs, programme, projects, links.
- `15_atlas_smr_project_funding.sql`: lead partners, summaries, 19 grants (€570.7M traced).
- `16_naarea_liquidation_bodacc.sql`: Naarea receivership, liquidation and sale plan (BODACC).

## Page
- `smr_network.html`: the published page (claude.ai artifact CMapuZuMJywvWBDGF69J9d, private).
- `page/template.html`: the same page with a `/*DATA*/` placeholder; rebuild by inserting `network.json`.

## Caveats
- Amounts marked `[to verify]` / confidence medium or low were read from search extracts, not opened pages.
- 36 of 53 projects have no published per-project amount (only call totals).
- VAL'M2 TCN = EDF Technocentre is an inference; newcleo's grant figure is disputed.
