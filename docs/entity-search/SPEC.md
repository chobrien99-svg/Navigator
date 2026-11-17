# Entity search: design specification

**Status:** draft v0.1, 17 November 2026. **Owner:** France Navigator.
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
  "focus_country": "FR"
}
```

`names` are matched as whole words, case-insensitively; any text that also contains an exclusion is rejected.

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

### Finding types (v0.1)

| Type | Connector | Suggested Navigator target |
|---|---|---|
| `legal_entity` | registry | `legal_entities` |
| `establishment` | registry | `organization_events` (opening or closure) |
| `financials` | registry | organisation profile (revenue, net income) |
| `officer` | registry | `organization_people` |
| `related_entity_candidate` | registry | review only |
| `legal_notice` | bodacc | `organization_events` |
| `eu_project` | scanr_projects | `projects`, `project_links`, `grants` |

## 6. Connectors

Each connector is a source module in `scripts/atlas/sources/` with an `enrich(entity, ctx) -> list[Finding]` function (the Atlas engine's `enrich`). It saves raw records through `ctx.save_raw(...)` and records its status through `ctx.status(...)`.

| Connector | Source | Access | Matching | Status |
|---|---|---|---|---|
| `registry` | recherche-entreprises.api.gouv.fr | JSON API | SIREN exact; name search for related entities (review only) | v0.1 |
| `bodacc` | BODACC on Opendatasoft | JSON API, flaky; retries with backoff | SIREN in `registre` | v0.1 |
| `scanr_projects` | scanR projects dump (CORDIS data) | Bulk `jsonl.gz`, cached locally | scanR/ROR/SIREN IDs, then names | v0.1 |
| `patents` | scanR patents dump | Bulk | applicant IDs and names | planned |
| `hal` | api.archives-ouvertes.fr | Solr API | structure names | planned |
| `lobbying` | HATVP open data | CSV | SIREN, names | planned |
| `procurement` | DECP consolidated | CSV/Parquet | SIRET/SIREN; product names in contract subject | planned |
| `ftj_archive` | Ghost Admin API | API | names | planned |
| `navigator` | Navigator database | SQL | slug | planned (what we already know) |
| `press` | web search | search API | names | planned, `single` confidence only |

Lessons from the manual runs to build in:

- **Procurement:** supplier names are often missing; search by SIRET and by product names in the contract subject.
- **EU projects:** a lab can appear next to its parent with the same amount. Merge on participant ID before summing.
- **Lobbying:** consultant filings name clients in a separate table. Spending brackets belong to the consultant, not the client.
- **BODACC:** expect connection resets. Retry, then report `unavailable`.

## 7. Review and loading (Navigator)

1. An editor runs the search for an entity.
2. The editor reads `report.md`. Name-only matches are listed separately.
3. Approved findings are turned into an idempotent SQL migration (`NOT EXISTS` guards, `legacy_source = 'atlas:entity:<key>'`) by a loader (planned, v0.2).
4. The migration is committed under `supabase/migrations/` and applied.

## 8. Radar (later)

- The runner gains an `--since` cursor per connector. Cursors are stored in `detection_sources.cursor`.
- Raw records are written to `source_records`, runs to `ingestion_runs`.
- Findings not seen before become `detection_candidates` (new organisations) or `signal_candidates` (news about watched organisations), with `candidate_evidence` pointing at the raw record.
- Good Radar sources (fast-moving): BODACC, the company register, procurement, EU grants, competition laureates. Slow sources (HAL, lobbying) stay Navigator-only.

## 9. Running it

```bash
cd scripts && python3 -m atlas entity --entity atlas/entities/nvidia.json
```

Options: `--sources registry,bodacc` to run some modules only; `--out DIR` to change the output folder.

Python 3 standard library only; HTTP goes through `curl` so the environment proxy and certificates apply. Every HTTP response is cached on disk in `$ATLAS_CACHE` (default `~/.cache/atlas`), so a rerun after a failure resumes without re-downloading (the Atlas engine's "save after every entity" rule). The scanR projects dump (~370 MB) is downloaded once into the same cache.
