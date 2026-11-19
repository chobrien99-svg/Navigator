# Entity search: design specification

**Status:** draft v0.2, 18 November 2026 (v0.1: 17 November). **Owner:** France Navigator.
**Pilot:** NVIDIA (see `docs/entity-search/PILOT_NVIDIA.md`).
**Relationship to the Atlas engine:** this is the **single-entity mode** of the Atlas engine described in `docs/atlas_engine_design.md` (the "resolve" and "enrich" stages for one organisation). It lives in the same package (`scripts/atlas/`), uses the same source modules and confidence levels, and defines the **finding** format that every mode (entity, list, topic, and later Radar) shares.

## 1. Purpose

One reusable toolkit that, given an organisation, searches every public data source we know and returns **findings**: dated, sourced facts about that organisation and its French counterparts. It replaces the one-off scripts written for the SMR atlas, the TechBio map and the NVIDIA investigation.

It serves two products from the same code:

| | Navigator (built first) | Radar (built second) |
|---|---|---|
| Question | "Tell me everything about this organisation" | "Tell me what is new, as soon as it appears" |
| Trigger | An editor runs it for a named entity | A schedule runs it for every watched entity or source |
| Scope | Full history | Only records newer than the last run (cursor) |
| Output | A review report, then a database update an editor approves | Detection or signal candidates in the existing review queue |

The **connectors** (one per data source) and the **finding format** are shared. Only the runner differs.

## 2. Principles

1. **Identifiers before names.** Match on SIREN/SIRET, scanR IDs, ROR IDs or EU participant IDs whenever they exist. Name matching is a fallback and every name-only match is flagged for review. (The NVIDIA run turned up "INVIDIA Concept", "Invidia Productions" and "Envidia Systems".)
2. **Nothing reaches the database without an editor.** The toolkit proposes; a person approves. Findings carry a suggested target table, never a direct write.
3. **Every fact keeps its source.** Each finding links to the raw record it came from. Raw records are stored as fetched, so a finding can be re-derived without re-downloading.
4. **Report what failed.** A source that is down is reported as `unavailable`, never as "no results". The run manifest lists every source's status.
5. **No double counting.** Lab sub-entries are merged into their parent; amounts are summed once per legal participant.
6. **Money is stored in euros, as published.** Converted amounts say so (`amount_basis: "converted"`). The Navigator database stores funding-round amounts in millions; the loader converts, the finding does not.

## 3. Input: the entity file

One JSON file per entity, in `scripts/atlas/entities/`.

```json
{
  "key": "nvidia",
  "display_name": "NVIDIA",
  "navigator_slug": "nvidia",
  "names": ["NVIDIA", "NVentures"],
  "name_exclusions": ["INVIDIA", "ENVIDIA", "INVENTURES"],
  "sirens": ["479973455", "432108355"],
  "scanr_ids": ["ztr1i", "02kr42612", "03jdj4y14"],
  "ror_ids": [],
  "focus_country": "FR",
  "product_terms": ["DGX", "Jetson", "CUDA"],
  "hal_struct_ids": []
}
```

`names` are matched as whole words, case-insensitively; any text that also contains an exclusion is rejected. Former names belong in `names` too (NVIDIA's French R&D company was Icera SARL until 2011).

`product_terms` (case-sensitive) are searched only in public-contract subjects and always give `low` matches. `hal_struct_ids` are HAL structure IDs confirmed by a reviewer; until then HAL matches are `medium`.

## 4. Output

A run writes one folder: `data/atlas_runs/entity-<key>/<YYYY-MM-DD>/`.

| File | Contents |
|---|---|
| `manifest.json` | Entity, start and end time, each connector's status (`ok`, `partial`, `unavailable`), counts, errors |
| `findings.json` | The findings (section 5) |
| `raw/<connector>.jsonl.gz` | Raw records as fetched |
| `report.md` | Human-readable review report grouped by finding type |

### Raw record

Mirrors the existing `source_records` table, so Radar can write raw records there unchanged.

```json
{"connector": "registry", "external_id": "479973455", "url": "...", "fetched_at": "2026-11-17T10:00:00Z", "content_hash": "sha256…", "payload": {}}
```

## 5. The finding

```json
{
  "finding_id": "registry:legal_entity:479973455",
  "entity": "nvidia",
  "type": "legal_entity",
  "date": "2004-12-02", "date_precision": "day",
  "title": "NVIDIA Développement France SAS",
  "summary": "R&D company in Biot (NAF 72.19Z), 50–99 staff (2024).",
  "amount_eur": null, "amount_basis": null,
  "subject": {"name": "NVIDIA DEVELOPPEMENT FRANCE SAS", "siren": "479973455", "country": "FR"},
  "counterparts": [],
  "facts": {},
  "source": {"connector": "registry", "name": "Recherche d'entreprises (INSEE/INPI)", "url": "...", "external_id": "479973455"},
  "match": {"method": "identifier", "on": "siren:479973455", "level": "high", "needs_review": false},
  "confidence": "official",
  "suggested_target": "legal_entities"
}
```

- `finding_id` is stable across runs (connector, type and source identifiers), so a rerun can tell new findings from known ones. Radar's "what is new" is exactly the set of `finding_id`s not seen before.
- `confidence` describes the **source**: `official` (government or institutional data), `press` (company release or several outlets), `single` (one secondary source).
- `match.level` describes the **match**, using the Atlas engine's levels: `high` (an identifier matched), `medium` (name plus one strong signal), `low` (name only). `medium` and `low` set `needs_review`.
- `facts` holds type-specific detail (for example, per-partner funding for an EU project).

### Finding types (v0.2)

| Type | Connector | Suggested Navigator target |
|---|---|---|
| `legal_entity` | registry | `legal_entities` |
| `establishment` | registry | `organization_events` (opening or closure) |
| `financials` | registry | organisation profile (revenue, net income) |
| `officer` | registry | `organization_people` |
| `related_entity_candidate` | registry | review only |
| `legal_notice` | bodacc | `organization_events` |
| `eu_project` | scanr_projects | `projects`, `project_links`, `grants` |
| `patent` | patents | `patents` |
| `research_paper` | hal | `articles`, `article_organizations` |
| `funding_acknowledgement` | hal | review only |
| `hal_structure` | hal | entity file (`hal_struct_ids`) |
| `lobbying_registration`, `lobbying_action` | lobbying | `organization_events` |
| `lobbying_client` | lobbying | `organization_relationships` |
| `public_contract` | procurement | `organization_events` |
| `navigator_record` | navigator | already stored |

Every finding also carries `in_navigator` (true when Navigator already holds it, matched by SIREN or source URL), so the review and the loader can skip known facts.

## 6. Connectors

Each connector is a source module in `scripts/atlas/sources/` with an `enrich(entity, ctx) -> list[Finding]` function (the Atlas engine's `enrich`). It saves raw records through `ctx.save_raw(...)` and records its status through `ctx.status(...)`.

| Connector | Source | Access | Matching | Status |
|---|---|---|---|---|
| `registry` | recherche-entreprises.api.gouv.fr | JSON API | SIREN exact; name search for related entities (review only) | v0.1 |
| `bodacc` | BODACC on Opendatasoft | JSON API, flaky; retries with backoff | SIREN in `registre` | v0.1 |
| `scanr_projects` | scanR projects dump (CORDIS data) | Bulk `jsonl.gz`, cached locally | scanR/ROR/SIREN IDs, then names | v0.1 |
| `patents` | scanR patents dump | Bulk `jsonl.gz`, cached | applicant SIREN, then applicant organisation name | v0.2 |
| `hal` | api.archives-ouvertes.fr | Solr API (cursor paging) | confirmed HAL structure IDs, then structure names; funding field | v0.2 |
| `lobbying` | HATVP open data (data.gouv.fr permanent links) | CSV, monthly cache | registrant or client SIREN, then names; beneficiary of actions | v0.2 |
| `procurement` | DECP consolidated (data.gouv.fr permanent link) | CSV, monthly cache | holder SIRET/SIREN, then holder name, then names or product terms in the subject (low) | v0.2 |
| `ftj_archive` | Ghost Admin API | API | names | planned |
| `navigator` | Navigator database | export file from `scripts/atlas/sql/navigator_entity_export.sql` (direct access once the runner has a Supabase key) | slug | v0.2 |
| `press` | web search | search API | names | planned, `single` confidence only |

Lessons from the manual runs to build in:

- **Procurement:** supplier names are often missing; search by SIRET and by product names in the contract subject.
- **EU projects:** a lab can appear next to its parent with the same amount. Merge on participant ID before summing.
- **Lobbying:** consultant filings name clients in a separate table. Spending brackets belong to the consultant, not the client.
- **BODACC:** expect connection resets. Retry, then report `unavailable`.

## 7. Review and loading (Navigator)

1. An editor runs the search for an entity and reads `report.md`.
2. `python3 -m atlas review --run <run folder>` writes `decisions.json` (one decision per finding) and `review.md`. Default decisions:
   - **skip**: already in Navigator (✓), or a type Navigator doesn't store as a record (officers, accounts, funding mentions, HAL structures, related-company candidates).
   - **reject**: accounts-filing notices (`dpc`), which are routine.
   - **pending**: anything that needs review (not an identifier match), and EU projects with no French partner.
   - **accept**: everything else.
   The editor changes `pending` to `accept` or `reject` in `decisions.json`. Rerunning `review` keeps decisions already made.
3. `python3 -m atlas load --run <run folder>` writes `load.sql` from the accepted findings. It never touches the database. Every insert carries `legacy_source = 'atlas:entity:<key>'` and `legacy_id = <finding_id>` and is guarded by `NOT EXISTS`, so the file can be applied twice without duplicates.
   - legal_entity → `legal_entities`; establishment → expansion event (plus a closure event); legal_notice → event (rebrand / shutdown / other); eu_project → project, project link and grant; research_paper → article and article link; patent → `patents`; lobbying and public contracts → events.
4. Before applying, the SQL is dry-run inside a `DO` block that ends with `RAISE EXCEPTION`, which rolls everything back.
5. With editor approval, the file is copied to `supabase/migrations/` and applied.

**Matching against Navigator** ("already held"): SIREN for legal entities; patent number (Navigator numbers start with a family member's ID) or French/English title for patents; source URL for everything else, with BODACC's old and new URL formats treated as the same notice.

## 8. Radar (later)

- The runner gains an `--since` cursor per connector. Cursors are stored in `detection_sources.cursor`.
- Raw records are written to `source_records`, runs to `ingestion_runs`.
- Findings not seen before become `detection_candidates` (new organisations) or `signal_candidates` (news about watched organisations), with `candidate_evidence` pointing at the raw record.
- Good Radar sources (fast-moving): BODACC, the company register, procurement, EU grants, competition laureates. Slow sources (HAL, lobbying) stay Navigator-only.

## 9. Running it

```bash
cd scripts && python3 -m atlas entity --entity atlas/entities/nvidia.json
```

Then `python3 -m atlas review --run DIR` and `python3 -m atlas load --run DIR` (section 7).

Options: `--sources registry,bodacc` to run some modules only; `--out DIR` to change the output folder.

Python 3 standard library only; HTTP goes through `curl` so the environment proxy and certificates apply. Every HTTP response is cached on disk in `$ATLAS_CACHE` (default `~/.cache/atlas`), so a rerun after a failure resumes without re-downloading (the Atlas engine's "save after every entity" rule). The scanR projects dump (~370 MB) is downloaded once into the same cache.
