# TechBio France (Oct 2026 list): research-data pull outputs

Processed outputs from the open-data research pull run on 7 November 2026 for the
48 companies on the "TechBio in France – October 2026" list. Used to build the
French TechBio Funding Map report and as test fixtures for the reusable
sector-research script.

| File | Contents |
|---|---|
| sirens.json | company slug → SIREN |
| summary.json, rounds.json, payload.json | funding analysis inputs (from the Navigator DB) |
| registry.json | registry data (recherche-entreprises.api.gouv.fr) |
| laureates.json | i-Lab / i-PhD matches (MESR open data) |
| esr_anr.json, anr_complete.json | ESR start-up list matches; complete ANR grant search |
| patents.json | patent families + co-applicants (MESR "Déposants des brevets") |
| scanr_companies.json | scanR organisations/projects/patents extract (EU projects, labels) |
| hal.json, people.txt | founders' HAL publication counts/affiliations (name matches – verify) |
| tax_credit_lists/matches.json | CIR / CII / CICo approval-list matches |
| small_prizes.json | MT180, open-science thesis prize, Étoiles de l'Europe (no matches) |
| sources_plan.md | access notes and query plan per source |
| research.json | per-company research-origin summary used in the report |

Large raw dumps (scanR jsonl.gz) are not committed; see manifest.json for URLs.
