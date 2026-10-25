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
