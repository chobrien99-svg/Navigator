# Atlas engine: design

**Status:** design, November 2026. First test topic: small modular reactors (SMRs).
**Built from:** the TechBio in France research pull (October 2026 list), whose
outputs are in `data/techbio_france_2026/` and whose source notes are in
`docs/techbio_research_sources.md`.

---

## 1. What it is for

France Navigator's goal is to connect everything about innovation in France:
start-ups, investors, public research, government programmes, patents, EU
grants. An **Atlas** is that picture for one topic. A user asks for
"small modular reactors" (or "TechBio", or "quantum sensing") and gets:

- the **organisations** involved: start-ups, corporates, labs, universities,
  hospitals, investors, public bodies
- the **people**: founders, lab heads, inventors, project coordinators
- the **money**: equity rounds, ANR and France 2030 grants, EU grants, public
  contracts
- the **knowledge**: patents, publications, research projects
- the **links** between them: spun out from, co-owns patents with, invested
  in, partner in project X, laureate of programme Y
- a **report** (web page and PDF, like the TechBio Funding Map) and a
  **network map** (like scanR's networks view)

The engine is the code that builds an Atlas. The same engine also runs the
simpler job we did for TechBio: "here is a list of companies, research them".

### What makes it different from scanR

scanR maps public research very well, but has no venture capital, funding
rounds or investors, and little about start-ups as businesses. Navigator
holds that side. The Atlas joins the two: lab, then patent, then spin-off,
then investors, then public programmes, then EU grants.

---

## 2. How it works: seven stages

```
 Topic spec ─► 1 DISCOVER ─► 2 RESOLVE ─► 3 ENRICH ─► 4 LINK ─► 5 REVIEW ─► 6 LOAD ─► 7 PUBLISH
 (or a list)    find          identify      add          build      a person    database    report,
                candidates    each one      details      the graph  confirms    update      map
                                                                    doubtful    files
                                                                    items
```

| Stage | What happens | Example (SMRs) |
|---|---|---|
| 1. Discover | Search every source for the topic's keywords and classification codes and collect candidate organisations, people, projects and patents. | scanR projects mentioning "réacteur modulaire"; patents in class G21C; ANR projects on molten-salt reactors; Navigator start-ups tagged nuclear |
| 2. Resolve | Turn each candidate into a known identity: SIREN for companies, RNSR code for labs, ORCID/IdRef for researchers, family number for patents. Merge duplicates. | "NAAREA SA", "Naarea" and SIREN xxx are one company |
| 3. Enrich | For every resolved entity, pull the standard profile from every source. | Registry, BODACC timeline, funding rounds, patents, EU projects, ANR grants, prizes |
| 4. Link | Turn shared facts into relationships with evidence. | Hexana and CEA co-own a patent family, so "partnered_with (patent co-owner)" |
| 5. Review | Anything below high confidence goes to a review list for a person to accept or reject. | Homonyms, name-only matches, generic words |
| 6. Load | Write database update files (never direct writes), applied after review. | `supabase/migrations/atlas/smr/...sql` |
| 7. Publish | Build the Atlas report (HTML and PDF), the network data, and later the website page. | "Small Modular Reactors in France: Atlas" |

**List mode** (what we did for TechBio) skips stage 1: the input is the list.

---

## 3. The topic spec

Each Atlas starts from a small settings file. Draft for SMRs:

```yaml
# atlas/topics/smr.yaml
id: smr
title: Small modular reactors in France
languages: [fr, en]
keywords:
  include:
    - "small modular reactor"        # EN
    - "SMR"                          # matched as a whole word, with a nuclear context word
    - "advanced modular reactor"
    - "AMR"                          # same rule as SMR (ambiguous acronym)
    - "petit réacteur modulaire"     # FR
    - "réacteur modulaire"
    - "réacteur nucléaire innovant"
    - "microréacteur"
    - "réacteur à sels fondus"       # molten salt
    - "molten salt reactor"
    - "réacteur à neutrons rapides"  # fast reactors
    - "lead-cooled fast reactor"
    - "sodium-cooled fast reactor"
    - "high-temperature gas reactor"
  context_words: [nucléaire, nuclear, réacteur, reactor, fission, combustible, fuel]
  exclude: ["fusion", "SMR (spinal muscular)", "service management"]
classification:
  patents_cpc: [G21C, G21D, G21F, G21G]     # nuclear reactors, plants, protection, conversion
  naf: ["35.11Z", "71.12B", "72.19Z"]         # supporting signal only
  scanr_domains: ["nuclear engineering", "énergie nucléaire"]
seeds:                                        # known players, always included
  companies: [Newcleo, Naarea, Jimmy Energy, Hexana, Calogena, Stellaria,
              Blue Capsule, Otrera Nuclear Energy, Thorizon, Nuward]
  research: [CEA]
  programmes: ["France 2030 – Réacteurs nucléaires innovants"]
time_window: [2015, 2026]
geography: France                             # organisations registered or with a site in France
```

Notes:
- Short acronyms (SMR, AMR) are only accepted next to a context word, to
  avoid "spinal muscular atrophy" and IT "service management".
- Seeds guarantee the obvious players are in even if a source misses them.
  Each seed is still verified (resolved and enriched), never taken on trust.
- Fusion is excluded here; it would be its own Atlas.

---

## 4. Sources (modules)

Each source is a small module with the same three functions: `discover(topic)`
(optional), `enrich(entity)`, and `check_schema()`. A settings file lists the
URL and dataset ID of each source, so a changed dataset means editing one
line, not the code.

| Module | Discover? | Enrich? | Match keys | Access | Notes from TechBio run |
|---|---|---|---|---|---|
| navigator_db | yes (sector tags, keywords in descriptions) | yes (rounds, investors, people) | slug, SIREN | Supabase | Source of all private-funding data |
| registry (recherche-entreprises) | yes (name search) | yes (directors, dates, headcount, finances) | SIREN | Free API | Connection sometimes drops: retry |
| bodacc | no | yes (timeline: capital increases, directors, receivership) | SIREN | Free API | Added Nov 2026 |
| scanr_dumps | yes (projects, patents, organisations by keyword or domain) | yes (EU and other projects, patents with titles and inventors, labels) | SIREN, RNSR, scanR id | Free downloads, about 1 GB | Live API needs a login from the scanR team |
| esr_startups | no | yes (official public-research spin-off: parents, incubator, IP type) | SIREN plus name | data.gouv.fr Tabular API | Some firms appear under an old SIREN (DNA Script) |
| ilab / inov / iphd | yes (keyword in project summary) | yes (laureate, year, lab) | SIREN, founder name | data.gouv.fr | |
| anr_01 / anr_02 | yes (keyword in project title or summary) | yes (grants, consortium totals) | company name, founder surname | data.gouv.fr | ANR_02 gives only consortium totals |
| patents_mesr | yes (by CPC through scanR, by applicant) | yes (families, co-applicants) | SIREN, applicant name | data.gouv.fr | 18-month publication lag; no titles |
| inpi | no | yes (titles, inventors, legal status) | publication number | INPI API, account login | Rate-limited: run slowly |
| horizon (ESR portal) | yes | yes | PIC, SIREN, name | Ministry portal | Portal connection unstable; scanR covers it |
| hal | yes (keyword) | yes (founders' publications, affiliations) | person name, IdRef, ORCID | Free API | Name homonyms: needs a field check |
| tax_credit_lists (CIR, CII, CICo) | no | yes (approved R&D provider) | SIREN | Ministry portal (whole-file download) | |
| clinicaltrials | yes (condition plus sponsor) | yes (trials, phase, status) | sponsor name | Free API | Health topics only |
| procurement (DECP) | no | yes (public contracts won) | SIREN | data.gouv.fr files | Important for defence, energy, health |
| rnsr | no | yes (official lab record: code, parents, director) | RNSR code | data.gouv.fr | Standardises lab names |
| curated_lists | yes | yes | name, then resolved | Manual CSV from press releases | For programme laureates with no open data (France 2030 calls, i-Démo) |
| pappers (optional) | no | yes (state-aid amounts) | SIREN | Paid API | Internal use only: not for republication |

**Curated lists** matter for SMRs. See section 4a for France 2030.

### 4a. France 2030: why it needs special handling

France 2030 is not an agency. It is steered by the **SGPI** (Secrétariat
général pour l'investissement, under the Prime Minister) and run through four
operators, each publishing (or not) in its own way:

| Operator | Scope | What is open |
|---|---|---|
| ANR | higher education, research, training | ANR_02 "DGPIE" dataset on data.gouv.fr (projects, partners, totals) |
| ADEME | ecological transition | financial-aid data on data.ademe.fr (to check) |
| Bpifrance | innovation and industry for businesses | almost nothing at company level |
| Caisse des Dépôts | territorial and structural investment | a few lists (e.g. "Démonstrateurs ville durable") |

The most complete list is the **laureates page on info.gouv.fr**
(`/grand-dossier/france-2030/laureats`), filterable by objective. Filtered on
"Objectif 1" (small innovative reactors) it lists **139 laureates**, against
the 11 headline reactor projects announced in press releases. The other 128
are the supply chain and research partners (for example Fonderie Lemer, an
SME in Carquefou, and Université de Technologie de Troyes), and no other
source lists them. Each entry gives only: organisation name, project name,
category (SME, research body…), objective, town and département. Entries are
not clickable and there is no export.

**Access:** the page is protected by Cloudflare's anti-bot check, so the
engine does **not** fetch it automatically (it won't bypass a protection the
site has chosen). Instead:
1. A person opens the filtered page in a browser, loads all entries, and saves
   the page (or copies the text) to a file.
2. The `france2030_page` reader turns that file into rows (name, project,
   category, objective, town, département).
3. Each row is resolved to a SIREN with the registry API using **name plus
   town/département**, which works well even for small suppliers; research
   bodies resolve to RNSR/Paysage records.
4. The source (page URL plus save date) is recorded as evidence on every row.

Also worth doing: requesting publication of the list as open data (through
data.gouv.fr or from the SGPI). A machine-readable list for a €54bn programme
doesn't exist, which is itself newsworthy.

---

## 5. Identity resolution (the hard part)

Every record ends up attached to one canonical entity. Rules learned on TechBio:

| Entity | Primary key | Secondary keys | Rules |
|---|---|---|---|
| Company | SIREN | name, website domain, scanR id, former names | Match SIREN **and** name; keep all known SIRENs (old, closed entities) and former legal names (Rivercell / Blossom Life Sciences) |
| Lab or research unit | RNSR code | scanR id, Paysage id, acronym | Normalise to the RNSR record |
| University or institution | Paysage id / SIREN | ROR id, name variants | "CNRS" = "Centre national de la recherche scientifique" |
| Person | ORCID or IdRef when available | full name plus affiliation plus field | A name alone is never enough when the surname is common; require first name plus a field or institution fit |
| Patent | DOCDB family number | publication numbers | One record per family; update, don't duplicate |
| Project | Official project code (ANR-xx-..., EU grant number) | acronym | |

**Confidence levels** on every match and every link:
- **high:** an identifier matched (SIREN, ORCID, project code)
- **medium:** name plus one strong signal (institution, field, city, year)
- **low:** name only, or a generic word. Goes to review, never published automatically

---

## 6. Data model

The existing Navigator tables already hold most of it (organisations,
people, legal_entities, funding_rounds, funding_round_investors, programs and
program_editions/program_organizations, patents, grants,
organization_relationships, organization_events). Additions needed:

| New table | Purpose |
|---|---|
| `atlases` | One row per Atlas: id, title, topic spec (JSON), status, last run date |
| `atlas_members` | Which entities belong to which Atlas, with a role (start-up, lab, investor, programme...), relevance score, confidence and review status |
| `evidence` | For every fact or link: source module, source record id or URL, date retrieved, confidence. Lets every number on a page say where it came from |
| `review_queue` | Items waiting for a person: proposed match or link, reason it is doubtful, decision, who decided |
| `source_runs` | When each source was queried for each Atlas, and with which dataset version (for refreshes) |

Existing tables get two optional columns where missing: `source` and
`confidence`.

---

## 7. Review step

The engine writes a review file (and later a review page) listing every
medium or low-confidence item, for example:

| Proposed | Why doubtful | Suggested | Decision |
|---|---|---|---|
| Eric Durand (HAL, 119 papers) is Bioptimus co-founder | Common name; field mismatch (microbiology) | Reject | |
| "Jimmy" (BODACC) is Jimmy Energy SAS | Name-only | Accept if SIREN matches | |

Nothing below high confidence reaches the database or the published page
without a decision. Decisions are remembered, so the next refresh doesn't ask
again.

---

## 8. Outputs

1. **Atlas report** (HTML and PDF), same template as the TechBio Funding Map:
   headline figures, findings, funding charts, investors, research origins,
   patents, public money (ANR, France 2030, EU), companies to watch, data notes.
2. **Network data** (nodes and links as JSON) for a map like scanR's networks
   view: organisations as nodes, typed links (spun out, co-patent, invested,
   project partner).
3. **Database update files** for review and loading.
4. Later, an **Atlas page on francenavigator.com**. The site is a Next.js app
   reading the same Supabase database, so the page reads `atlas_members` plus
   the existing tables and draws the map.

---

## 9. Running it

```bash
# list mode (what we did for TechBio)
python -m atlas run --list data/techbio_list.xlsx --name techbio-2026

# topic mode
python -m atlas run --topic atlas/topics/smr.yaml

# individual stages, to re-run one part
python -m atlas discover --topic atlas/topics/smr.yaml
python -m atlas enrich --atlas smr --source bodacc
python -m atlas review --atlas smr        # writes the review file
python -m atlas publish --atlas smr       # report and PDF
```

Engineering rules (from TechBio):
- **Retries everywhere** with growing pauses; several government services drop
  connections.
- **Save after every entity and resume.** A run must be restartable: each
  company's result is written as soon as it's fetched, and a re-run skips what
  is already done. (A TechBio BODACC run lost an hour of results by saving only
  at the end.)
- **Respect access controls.** Sites protected by anti-bot checks (e.g.
  Cloudflare on info.gouv.fr) are handled with a manual export, never by
  disguising automated requests.
- **Cache** every response on disk, so a re-run doesn't re-download, and a
  report can be rebuilt offline.
- **Schema checks:** each module checks that the columns it expects still
  exist and stops with a clear message if not.
- **Secrets** (INPI login, Pappers key, Supabase) come from environment
  settings only, never from code or files. Modules needing a missing secret
  are skipped with a warning.
- **Network:** the Navigator cloud environment already allows all the hosts
  listed in section 4.

---

## 10. Rules on licences and personal data

- **Etalab 2.0** sources (most French government data, scanR, HAL metadata):
  can be republished with attribution. Every published number links to its
  source.
- **Paid sources** (Pappers, Crunchbase, Dealroom): internal research only;
  never shown on public pages.
- **Personal data:** names, roles and affiliations of founders and researchers
  are public and can be shown. Contact details (emails, phones) are never
  stored or shown, even when a dataset includes them.

---

## 11. SMR test: plan and success criteria

1. Write `atlas/topics/smr.yaml` (draft in section 3). Save the info.gouv.fr
   laureates page filtered on Objectif 1 (139 entries) and run the
   `france2030_page` reader; add the press-release details of the 11 headline
   "Réacteurs nucléaires innovants" projects (phases 1 and 2).
2. Run discover. Expect: about 10–15 start-ups, CEA and other labs, EDF/Nuward,
   Framatome and other corporates, ANR and Euratom projects, nuclear-class
   patents.
3. Resolve, enrich, link; produce the review file.
4. Review with the editor; load; publish the Atlas report.

**The test passes if:**
- every France 2030 Objectif 1 laureate (139) is resolved to a SIREN or a
  research-body record, with a list of any that couldn't be resolved
- each start-up has funding, investors, programme support, patents and EU
  projects where they exist
- research links to CEA (and other labs) appear with evidence
- fewer than about 20 items need review, and no unreviewed low-confidence
  item reaches the report
- the same command, with a different topic file, works without code changes

---

## 12. Build plan

| Step | Content | Proves |
|---|---|---|
| 1 | Package skeleton, settings file, HTTP helper (retries, cache), entity store | Foundations |
| 2 | Port the TechBio modules (registry, BODACC, ESR, i-Lab, ANR, patents, scanR, HAL, tax lists, clinical trials) as engine modules | List mode reproduces the TechBio results |
| 3 | Resolution and confidence rules; review file | Quality control |
| 4 | Discovery functions and topic spec; curated lists | Topic mode |
| 5 | SMR run, review, report | The reusability test |
| 6 | Data model additions (atlases, atlas_members, evidence, review_queue) | Ready for the website |
| 7 | Atlas page on francenavigator.com | Public product |

## 13. Open questions

- **scanR API login:** request one from the scanR team; it makes discovery
  much faster than the 1 GB downloads.
- **Which investors' data can be shown publicly?** (Depends on the source of
  each round.)
- **Refresh frequency** per Atlas (monthly?), and who reviews.
- **Topic overlap:** an organisation can belong to several Atlases (CEA will
  be in many). Fine by design, since membership is a separate table.
