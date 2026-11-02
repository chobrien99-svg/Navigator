# Bad-SIREN research findings (the 14 "different companies" groups)

_Generated 2026-10-25. No database changes were made — this is a findings/triage note._

## Headline

The 14 flagged pairs are **not 14 isolated errors**. Researching each company's real
SIREN in the official French registry (annuaire-entreprises.data.gouv.fr / pappers /
societe.com) showed that the **legacy `inov` import assigned SIRENs that belong to other
companies**, pervasively. Every correct SIREN I looked up was already sitting on a
*different* org in the DB — itself an `inov` record carrying the wrong number.

Scale: there are **548 legal-entity rows across 545 `inov`-sourced orgs** (plus 1,643 `ilab`).
The 14 pairs are only the cases where a scrambled `inov` SIREN happened to collide with a
correctly-numbered record, which is how they surfaced in the duplicate report.

### Evidence (correct SIREN → where it already (wrongly) sits in the DB)

| Company (real SIREN, per registry) | In our DB that SIREN is on | That org's source |
|---|---|---|
| SPIREC — 433386554 | SEREEMA SA | inov |
| SEVA Technologies — 432103141 | CityTaps | inov |
| Squadrone System — 800970212 | Dashdoc | inov |
| Solar Cloth System — 800532822 | BuyCo | funding_tracker* |
| Green Communications — 522782481 | LODIAG | inov |
| Geolith — 818024234 | VEL'CO (2nd, duplicate LE) | inov |
| Sendinblue/Brevo — 498019298 | Brevo (correct!) | french_tech_next |

\* BuyCo is funding_tracker but holds Solar Cloth's number — so the scramble reaches
beyond `inov` in at least one case; needs confirming.

Because the "correct" SIREN for each wrong org is already occupied by another (also-wrong)
record, **piecemeal correction is unsafe** — it would create new collisions and would not
address the underlying misalignment.

## Per-pair verdicts

### True different-companies (stored SIREN belongs to one; the other is mis-numbered)
- 484872551 WATCHFROG ✓ vs **SPIREC** (real 433386554, occupied by SEREEMA)
- 794167593 Metron ✓ vs **SEVA Technologies** (real 432103141, occupied by CityTaps)
- 803183771 Heyday ✓ vs **Squadrone System** (real 800970212, occupied by Dashdoc)
- 809273329 D-ICE ✓ vs **Solar Cloth System** (real 800532822, occupied by BuyCo)
- 810876177 Sweetch Energy ✓ vs **Geolith** (real 818024234, occupied by VEL'CO)
- 833737653 Altaroad ✓ vs **Green Communications** (real 522782481, occupied by LODIAG)
- 821893286 Spendesk ✓ vs **Sendinblue** — but Sendinblue already exists correctly as **Brevo**
  (498019298), so "Sendinblue" here is a DUPLICATE of Brevo, not just a bad SIREN.

### Actually rebrands — safe to MERGE (same legal entity, confirmed by registry)
- 514972306 **STRUCTURE COMPUTATION → SpinalCom** (renamed 2016)
- 529042376 **Devatics → Onestock** (same entity; confirmed via crowdfunding record)
- 891908576 **ERS (Ecosystem Restoration Standard) → Equitable Earth** (renamed 2025)
- 821893286 **Sendinblue → Brevo** (duplicate; merge Sendinblue into existing Brevo org)

### Could not confirm a correct SIREN (defunct / ambiguous) — detach & flag
- 452626252 stored = SARL HILLEL (jewellery, unrelated). abCSR's real SIREN = 823648167;
  DEPUR Experiences = trade name of HILLEL SAS 789164654. Both DB records mis-numbered.
- 503436107 Aladom ✓ vs **DMCC** — several French "DMCC"; dmcc-france.fr not resolvable.
- 838887263 WaltR ✓ vs **UrbanAirNet** — no registry entry found (defunct?).
- 903949691 stored = HEXALEAN GROUPE (a holding). **ïkos Bordeaux** real SIREN = 928585355;
  the heating-tech "Hexalean" (hexalean.com) could not be matched. Both mis-numbered.

## Recommendation

1. **Do not trust `legal_entities.siren` on `inov`-sourced records** (and audit `ilab`).
   Treat the ~548 inov SIRENs as suspect pending re-derivation from the original inov source
   file, or clear them.
2. The 4 rebrand/duplicate cases above (SpinalCom, Onestock, Equitable Earth, Brevo) are safe
   to merge now on a name/identity basis, independent of the SIREN issue.
3. Earlier merges (phases 25–29) were validated by name + website, so they remain valid; but
   surviving `inov`/`ilab` records may still carry wrong SIRENs — part of the same audit.

---

# Addendum — scoping the inov SIREN audit (2026-10-25)

After the headline above, I sampled the inov records directly against the registry to
measure the real error rate (collisions only catch 13 of 548, so they understate it).

**Method:** random sample of 16 inov orgs; looked up each stored SIREN in the registry and
compared the registered company name to our org name.

**Result: 14 correct, 1 wrong, 1 inconclusive.**
- Correct (14): DOCENT, Stockage Plus, Group Elastoteck, ZIWIG, Clever Cloud, INALVE,
  Privacy Chambers, Newheat, APHELIOR, Loop Logistics/Lizee, ANOD, CIRCOULEUR, QC Ware France,
  SMARTCATCH.
- **Wrong (1): "Pando2" carries SIREN 841677461, which is actually WINK** (online-catalogue
  retail, Paris). Pando2's real number is unknown.
- Inconclusive (1): OKEENEA 848981809 — registry lookup returned nothing (number is
  Luhn-valid; likely fine, not confirmed).

**Revised assessment**
- The inov SIRENs are **mostly correct**; the error is **sporadic (~6%)**, not a wholesale
  column shift. Extrapolated to 548 inov records, roughly **30–40 wrong SIRENs** (order of
  magnitude), of which only 13 surface as collisions.
- Therefore a **wholesale clear of inov SIRENs would destroy far more good data than bad.**
  The right fix is a **targeted verification pass**: check each inov SIREN's registered name
  against the org name and correct only the mismatches.

**Correcting a mismatch is itself non-trivial** (as the 7 bad-SIREN pairs showed): the record's
*correct* SIREN is often occupied by another mis-numbered record, so corrections may need to be
sequenced, and some correct SIRENs can't be found (defunct companies).

## Recommended approach (pick one)

1. **Best — re-derive from source.** If the original inov import file (name ↔ SIREN) still
   exists outside this repo, re-importing/comparing is the cleanest fix. It is **not** in the
   repo (no committed migration sets `legacy_source='inov'`), so this needs the source file.
2. **Bulk registry verification.** Allowlist `recherche-entreprises.api.gouv.fr` (currently
   blocked by the container network policy) so all 548 inov SIRENs can be name-matched
   programmatically in one pass; I then propose corrections for the mismatches.
3. **Incremental verification via web search.** No infra change; I verify the 548 in batches
   (~16 per step, as sampled here) and correct mismatches as they're found. Slow and
   search-heavy but needs nothing enabled.

Given the ~6% rate, I'd recommend 1 if the source file exists, otherwise 2. I did **not** make
any SIREN changes.

---

# Addendum 2 — the official i-Nov source file does NOT fix it (2026-10-25)

The user supplied the official i-Nov winners dataset (data.gouv.fr: `fr-esr-laureats-concours-i-nov`,
753 valid-SIREN rows). I diffed it against the 545 inov records by exact company/project name.

**Result: only 4 name-exact divergences** between the file and the DB — because **the DB faithfully
matches the file**. The SIREN errors are IN THE OFFICIAL FILE itself:

- File lists **SPIREC → 484872551** (the registry's Watchfrog number) and Watchfrog → 811684190.
- File lists **SEVA Technologies → 794167593** (Metron's), **SQUADRONE SYSTEM → 803183771**
  (Heyday's), **GEOLITH → 810876177** (Sweetch's), **Green Communications → 833737653**
  (Altaroad's), **Solar Cloth System → 809273329** (D-ICE's).

Every bad SIREN we found earlier is reproduced verbatim in the government file. The DB didn't
corrupt them — it copied them. **So re-deriving from this file changes nothing.**

**The 4 file-vs-DB divergences (and why none warrant a DB change):**

| DB org | DB SIREN | i-Nov file SIREN | Verdict |
|---|---|---|---|
| VEL'CO | 819556168 | 818024234 | DB right (819556168 = VEL'CO in registry; 818024234 = Geolith). File wrong. |
| INALVE | 819699893 | 830590659 | DB right (819699893 = INALVE in registry). File differs. |
| D-ICE Engineering | 809273329 | 814888798 | DB right (809273329 = D-ICE in registry). File differs. |
| DigiMobee | 834554982 | 793002908 | Uncertain — the file maps 793002908 to BOTH Digimobee and ENWIRES, so the file is internally inconsistent here. Needs registry check. |

The file is also internally inconsistent (e.g. SIREN 793002908 appears for both "Digimobee" and
"ENWIRES"), confirming it is not a clean ground truth.

## Final recommendation (revised)

- **Re-derivation (option 1) is off the table** — the source carries the same errors.
- Authoritative correction requires the **business registry** (annuaire-entreprises /
  recherche-entreprises.api.gouv.fr), which is **blocked by the container network policy**.
- Practical paths:
  1. **Allowlist `recherche-entreprises.api.gouv.fr`** → I batch-verify all ~545 inov SIRENs by
     name against the registry in one pass and propose corrections (est. ~30-40).
  2. **Accept and annotate** — leave the SIRENs, mark inov-sourced SIRENs as "unverified
     (i-Nov source)" so downstream users don't over-trust them.
  3. **Incremental web-search verification** (no infra change; slow).
- Either way, do **not** change VEL'CO / INALVE / D-ICE to the file's values — the DB is correct
  there.

No DB changes were made in this step.
