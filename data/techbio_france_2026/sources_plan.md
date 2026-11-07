# Source assessment & query plan: 48 French TechBio startups

Tested 2026-11-07. Network: direct curl got **CONNECT 403 (code 000)** from www.data.gouv.fr, tabular-api.data.gouv.fr, data.enseignementsup-recherche.gouv.fr, api.archives-ouvertes.fr, scanr.enseignementsup-recherche.gouv.fr, scanr-api.enseignementsup-recherche.gouv.fr, www.entreprises.gouv.fr, cordis.europa.eu, theses.fr, pub.orcid.org, api.openalex.org.
**Reachable:** recherche-entreprises.api.gouv.fr (200, but the connection drops intermittently) and the **France_Open_Data MCP**. The MCP's `query_resource_data` works only on resources that data.gouv.fr's Tabular API has indexed. ESR-portal mirrors are hit or miss: some are indexed, some are not (see each section).

> **Data-quality alert from the tests: DNA Script has two SIRENs.** recherche-entreprises shows `801172834 DNA SCRIPT` (active, created 2014-03-12) and `801575572 DNA SCRIPT` (ceased, created 2014-04-07). The ESR startup list and i-Lab both point to **801575572** (the ceased entity). An exact SIREN join on our list would miss DNA Script. **Always join on SIREN and also on normalised company name.** Expect the same problem for other companies that re-incorporated.

---

## 13. Startups issues de l'ESR (fr-esr-startup-esr-france): HIGHEST VALUE
- **Access:** MCP Tabular works. Dataset `6970b64c71cf5ecda2209ca6`. **resource_id `8129ef0f-ea7a-4a75-9f78-f882c7a3fbce`** (CSV). Mirrored from ESR portal; updated 2026-07-29.
- **Contents:** 4,734 rows. Columns: `SIREN`, `Raison sociale`, `Date création`, `Liste d'actifs` (e.g. "Savoir-faire secret", licensed patents), `Structures ESR liées`, `Identifiant Structures ESR liées` (SIRET of the tutelles), `Structures ESR liées liste` (pipe-separated), `Incubateur de la recherche publique`, `Date accompagnement IRP`, `Statut` (Actif/Cessé), `Date fermeture`, `Date observation état`, `Site internet`, `Id crunchbase`, `Id dealroom`, `Code postal`, `Commune`, `Département`, `Région`, plus geo codes. No person names.
- **Match key:** `SIREN` exact, with a fallback of `Raison sociale` contains (uppercase).
- **Test:**
  - SIREN 948448972 returns ORAKL ONCOLOGY: created 2023-01-25, assets "Savoir-faire secret", linked to Université Paris-Saclay, Institut Gustave Roussy, Inserm…, incubator Agoranov (2022), Actif.
  - 883649238 returns QUBIT PHARMACEUTICALS: Sorbonne U, CNRS, UGA, CEA…, incubator Paris Biotech Santé (2020).
  - 802255372 returns ELIGO BIOSCIENCE: Agoranov 2015, no ESR structure listed.
  - 801172834 (DNA Script): 0 rows. `Raison sociale contains DNA SCRIPT` returns SIREN 801575572 (Agoranov 2015, marked Cessé 2016-05, crunchbase dna-script).
- **Value: HIGH.** This is the official "spin-off from public research" flag. It gives the parent institutions, the incubator and the type of IP transferred. Use it to decide which of the 48 count as academic spin-offs.

## (Bonus, not in the brief) i-Lab laureates: VERY HIGH VALUE
- **Access:** MCP Tabular works. Dataset `577cb487c751df29779901a0`. **resource_id `93162d25-e501-4b38-b995-6e0fd46df1ef`**.
- **Contents:** 3,992 rows, 1999–2026. Columns: `Année de concours`, `Type de candidature` (en émergence / création-développement), `Grand-Prix`, `Domaine technologique`, `Nom du lauréat`, `Prénom du candidat`, `Idref`, `Email`, `N° SIREN`, `N° SIRET`, `Libellé entreprise`, `Moto`, `Résumé`, `Unité de recherche liée au projet` (+ id/sigle), `Structure liée au projet`, `Déjà lauréat en`, `Jury`.
- **Match key:** `N° SIREN` exact, or `Nom du lauréat` contains (founder surname, then check the first name).
- **Test:**
  - `Nom du lauréat contains Ybert` returns 2 rows: Thomas Ybert, 2014 émergence (regional jury) and 2016 création-développement (national), SIREN 801575572, linked lab "Biologie Structurale des Processus Cellulaires et Maladies Infectieuses" (UPMC/Paris Diderot/CNRS).
  - `contains Guillemot` returns Fabien Guillemot, 2012 émergence and 2014 création, POIETIS 804776797, lab BIOTIS (U. Bordeaux / Inserm).
- **Value: VERY HIGH.** It shows public seed money (Bpifrance/MESR), the founder-to-lab link and the year. It is the closest open proxy for state "first cheque" support. Note that personal emails are present: handle them carefully and do not publish them.

## 3. ANR projects & partners (ANR_02 DGPIE, plus ANR_01 DOS/DGDS, which matters more)
- **Access:** MCP Tabular works.
  - ANR_02 (DGPIE = PIA/France 2030 programmes: RHU, Carnot, IHU, PEPR…): dataset `60ca244980d5c4f0aecd07d1`. **Partners resource `51cba202-da27-4f95-9337-0ff5aae7e6ae`** (16,976 rows, 2006–2026). Projects resource `aca6972b-577c-496a-aa26-009f81256dcb`.
  - **ANR_01 (generic calls AAPG/CE, JCJC, PRCE, LabCom…):** dataset `60ca2086030c7b7e52e2c02e`. **Partners 2010+ resource `4b576f41-8f4a-4f0f-860a-98eca420f3b9`**. Partners 2005–09 resource `0d691519-9a6c-4d66-a2e0-b9a8b3938968`. Projects 2010+ resource `87d29a24-392e-4a29-a009-83eddcff3e66` (135 MB, so filter only). The MCP returned one intermittent Bad Gateway; it worked on retry.
- **Contents (partners):**
  - Both files: `Projet.Code_Decision`, `Projet.Acronyme`, `Projet.Partenaire.Est_coordinateur`, `Projet.Partenaire.Nom_organisme`, `Projet.Partenaire.Categorie_organisme` (Entreprises Privées / PME / Université…), `Projet.Partenaire.Responsable_scientifique.Nom` (UPPERCASE) / `.Prenom`, `Projet.Partenaire.Adresse.Ville/Region/Pays`.
  - ANR_02 only: `Action.Edition`.
  - ANR_01 only: `Projet.Partenaire.Code_RNSR`, `...Responsable_scientifique.ORCID`, `Projet.Partenaire.Aide_allouee.ANR` (euros), `Projet.Partenaire.Financement.Source`.
  - No SIREN in either file.
- **Match key:**
  - Company as partner: `Nom_organisme contains <NAME>`.
  - Founder as PI: `Responsable_scientifique.Nom` exact UPPERCASE surname, then filter on the first name.
  - The year comes from the code (ANR-**YY**-…).
- **Test:**
  - ANR_02 `Nom_organisme contains OWKIN` returns OWKIN France as partner in RHU AI-TRIOMPH (ANR-23-RHUS-0012) and RHU CONDOR (ANR-21-RHUS-0010).
  - ANR_02 `Nom = YBERT` returns only Sébastien Ybert (IFREMER), a false positive.
  - **ANR_01 `Nom = PIQUEMAL`** returns **Jean-Philip Piquemal, Sorbonne U, ANR-22-CE29-0014 MAPPLE, €197,298, ORCID 0000-0001-6615-9426** (plus homonyms Jean-Yves, Fabrice and David, which shows why the first-name check is needed).
- **Value: HIGH.** It quantifies public grant money to founders (pre-company) and to the companies (as partners). Run both ANR_01 and ANR_02.

## 1. scanR API
- **Access: BLOCKED from here.** scanr / scanr-api hosts return 403 at the proxy.
  - Dataservice `672cfc39db38d1541be152f8` has **no machine_documentation_url** (the MCP cannot fetch an OpenAPI spec).
  - The catalogue description lists 5 Elasticsearch indices: `scanr-organizations`, `scanr-persons`, `scanr-projects`, `scanr-publications`, `scanr-patents`. Docs are at `scanr.enseignementsup-recherche.gouv.fr/docs/...`.
  - The likely pattern is `POST https://scanr-api.enseignementsup-recherche.gouv.fr/api/<index>/_search` (ES query DSL).
  - Web search could not confirm the auth requirement. Older v2 REST (`/api/v2/{structures|persons|projects|publications}/search`) is documented in github.com/dataesr/scanr. A third-party harvester (svp-harvester) uses ES user/password, so **assume credentials may be required. Check the docs page from an open network.**
- **Contents:** organisations are keyed by SIREN for companies (e.g. `scanr.../structure/804776797` for Poietis, seen in the i-Lab data). It has persons (idref/ORCID), projects (ANR, H2020/HE, PIA), publications and patents with affiliations.
- **Match key:** organisation id = SIREN. Persons by name or idref (idref ids are available from i-Lab and ANR ORCID).
- **Test:** not possible (blocked). Indirect evidence: the i-Lab and Étoiles files carry scanR links built from SIREN.
- **Value: HIGH if unblocked.** It is a one-stop shop for patents, projects and publications per SIREN. Ask for `scanr-api.enseignementsup-recherche.gouv.fr` to be allow-listed, or run from another machine.
- Fallback: data.gouv.fr dataset "Export des organisations exposées dans scanR" (bulk JSON, last update 2020, stale).

## 2. HAL search API
- **Access: BLOCKED** (api.archives-ouvertes.fr returns 403). No data.gouv.fr tabular mirror.
- **Contents:** French open archive of publications (Solr). Useful fields: `authFullName_s`, `authIdHal_s`, `authORCIDIdExt_s`, `structName_s`, `labStructName_s`, `instStructName_s`, `producedDateY_i`, `title_s`, `doiId_s`, `docType_s`.
- **Match key:** founder full name plus affiliation, e.g.
  `https://api.archives-ouvertes.fr/search/?q=authFullName_s:"Fanny Jaulin"&fq=structName_s:"Gustave Roussy"&fl=title_s,producedDateY_i,doiId_s,structName_s&rows=200&wt=json`.
  Use ORCID when ANR gives one (`authORCIDIdExt_s:0000-0001-6615-9426`).
- **Test:** not possible (blocked).
- **Value: MEDIUM.** Good for establishing the scientific track record and lab of origin. Publication counts alone are a weak story angle. Needs network access.

## 5. Horizon Europe: collaborations (excl. ERC/MSCA)
- **Access: NOT QUERYABLE.**
  - Dataset `654af9ccfd67a5846eea1a01`, resource `dd0d569d-5512-42ac-8557-bb8994949abe` (CSV) / `c9f1a777-afd8-4512-8dde-3b6617317b15` (JSON).
  - The Tabular API reports "Not available". The files live only on data.enseignementsup-recherche.gouv.fr (dataset `fr-esr-all-signed-projects-collaborations`), which is blocked.
- **Contents:** country-to-country / org collaboration pairs. Column names are unverified.
- **Match key:** organisation name (it likely has no SIREN).
- **Test:** none possible.
- **Value: LOW.** These are aggregated collaboration links. Use source 6 instead.

## 6. Horizon Europe: projets lauréats et participations
- **Access: NOT QUERYABLE.**
  - Dataset `6657ebeb881a38cb377c6364`, resource `c6cb9b75-bcad-4a02-91e1-51f5656efa3b` (CSV) / `d1c89f0f-a670-4982-9354-aa60158e0a8a` (JSON). ESR id `fr-esr-horizon-projects-entities`. Not in the Tabular API; the ESR host is blocked.
  - The same applies to Horizon 2020 (`66593e01ad8723ca657c6364`, resource `7965f997-bcc4-4e16-8942-14e17a634ebe`) and PCRI project info (`654af9cc120bfeaa5aea1a02`).
- **Contents (from the ESR portal; columns not verified here):** one row per French participation, with project id/acronym, call, pillar/programme, participant name, role (coordinator/partner), EU contribution, and a participant identifier that is SIREN for French companies.
- **Match key:** SIREN (to verify), with participant name as a fallback.
- **Test:** none possible.
- **Value: HIGH if accessible.** EIC Accelerator/Pathfinder grants to TechBio startups are a strong money story. Download the ESR export from an open machine, or use the CORDIS bulk CSV (cordis.europa.eu, also blocked here).

## 7. Trophée « Les Étoiles de l'Europe »
- **Access:** MCP Tabular works. Dataset `5845abf4c751df7bc0c0bb7e`, **resource_id `d6e7c119-019b-4ad3-b9c8-65b7eeef4547`**. A twin dataset `586dae78a3a7290df6f4bea4` (resource `01755340-f7e3-410b-bbc3-857a41e1bfb5`) is not indexed.
- **Contents:** 119 rows, editions 2015–2022. Columns: `Edition`, `Mention`, `Prénom`, `Nom`, `IdRef`, `projet_acronyme`, `projet_titre`, `programme_nom`, `project_id`, `structure_identifiant` (SIREN for companies, e.g. ACRI ST 428834113), `structure_libelle`, `region_nom`, `projet_lien_cordis`.
- **Match key:** `Nom` contains the founder surname, or `structure_identifiant` = SIREN.
- **Test:** `Nom contains PIQUEMAL` returned 0 rows. Previewing confirmed the columns.
- **Value: LOW.** Small prize list for EU project coordinators. One pass over 45 surnames is cheap.

## 8. Ma thèse en 180 secondes
- **Access:** MCP Tabular works. Dataset `577cb6f0c751df2ddb9901a0`, **resource_id `9614efcc-096f-4e24-beef-b7d5a0765636`**.
- **Contents:** 204 rows, roughly 2014–2026 national finalists. Columns: `Millesime`, `Niveau`, `Lauréat`, `Prix`, `Prénom`, `Nom`, `Prénom Nom`, `Compte LinkedIn`, `orcid`, `idref`, `Titre de la thèse`, `Lien vers theses.fr`, `Laboratoire`, `Code laboratoire`, `Etablissement`.
- **Match key:** `Nom` contains the founder surname.
- **Test:** `Nom contains Duportet` returned 0 rows.
- **Value: LOW.** An unlikely hit for this population. Include it as a cheap surname sweep.

## 4. Prix science ouverte de la thèse
- **Access:** MCP Tabular works. Dataset `672ed04b2ff8689d10c25365`, **resource_id `713517d7-26a1-40fd-9677-eb3d379a0ba9`**.
- **Contents:** 16 rows (editions from 2024). Columns: `Millesime`, `Résultat`, `Prenom`, `Nom`, `Prenom_nom`, `ORCID`, `Idref`, `Numero national de thèse`, `Laboratoire`, `ROR Laboratoire`, `Etablissement`.
- **Match key:** `Nom` contains the founder surname.
- **Test:** `Nom contains Jaulin` returned 0 rows.
- **Value: LOW.** Tiny and recent. Founders are unlikely to appear.

## 9. i-Démo (Bpifrance / France 2030)
- **Access:** entreprises.gouv.fr is blocked. **No open dataset of i-Démo laureates was found.** data.gouv.fr searches for "i-Démo", "lauréats France 2030", "PIA lauréats", "France 2030 bénéficiaires" and "concours i-Nov" found only unrelated datasets: "Démonstrateurs ville durable", Innov'up Leader PIA (IDF), and a Bretagne "France 2030" stub with 0 resources.
- **Alternatives:**
  - i-Lab (above, open, high value).
  - ANR_02 DGPIE (France 2030 programmes run by ANR).
  - Innov'up Leader PIA (Région IDF) dataset `605574ce66802712b571fa22`, not tested.
  - "Lauréats du concours d'innovation i-PhD" `610219d02cc8bb8ce8042cfd`, not tested and relevant to founders who hold PhDs.
  - Otherwise, use press releases and the Bpifrance lists of laureates (web, manual).
- **Value:** HIGH for the story, but **no open data**, so collection is manual.

## 10. CICo: public bodies approved for the collaborative research tax credit (crédit d'impôt collaboration de recherche)
- **Access: NOT QUERYABLE.** Dataset `632a7e4986e524915deacfa4`, resource `8b861ca1-74cf-4902-aaf3-12960c36a6e9` (CSV). Not in the Tabular API; the ESR host is blocked.
- **Contents:** public research bodies and labs approved as CICo partners. They are public organisations, not startups.
- **Match key:** none for our companies.
- **Value: LOW.** Irrelevant to startup identification.

## 11. Organisms, experts and design studios approved for the research tax credit (CIR)
- **Access: NOT QUERYABLE.** Dataset `63aa5fcc55fdea38a39dde9a`, resource `3d3f3933-58e9-4498-9611-bb6c13e15984`. The legacy dataset `5a6a9bcab59508043d78dc80` (resource `fc75e069-35d3-43ec-a6f9-0dede9dc788d`) and the experts dataset `5a6a9bf3b59508044178dc80` are not indexed either.
- **Contents:** private organisations approved to perform R&D subcontracted under CIR. The ESR portal versions usually include SIREN, name, address and approval period (not verified here).
- **Match key:** SIREN (to verify).
- **Value: LOW to MEDIUM.** Approval means the startup sells R&D services to other firms (e.g. a CRO-like activity). It does not mean the startup itself claims CIR.

## 12. Private organisations approved for the innovation tax credit (CII)
- **Access: NOT QUERYABLE.** Dataset `63aa5fd055fdea38a39dde9b`, resource `c81fb7ab-4b84-4e1c-8b43-9431426fc7d0`. Not in the Tabular API.
- **Contents / match key / value:** same logic as source 11. Probably SIREN-keyed, but not verified. **LOW to MEDIUM.**

---

## Recommended run order
1. **ESR startups** (`8129ef0f-…`): SIREN exact for all 47, then a name fallback for misses. This fixes the spin-off status, institutions, incubator and IP type, and surfaces SIREN mismatches like DNA Script.
2. **i-Lab** (`93162d25-…`): `N° SIREN` exact, plus `Nom du lauréat` for the 45 founder surnames (verify first names). Captures public seed awards, years and labs.
3. **ANR_01 partners** (`4b576f41-…` and `0d691519-…`): surname exact on `Responsable_scientifique.Nom` (UPPERCASE), checking first name and ORCID; then `Nom_organisme contains` for the 48 company names.
4. **ANR_02 partners** (`51cba202-…`): same two passes, for PIA/France 2030 money (RHU/IHU partners).
5. Cheap surname sweeps: **Étoiles de l'Europe** (`d6e7c119-…`), **MT180** (`9614efcc-…`), **Prix thèse SO** (`713517d7-…`).
6. Untested bonus: i-PhD (`610219d02cc8bb8ce8042cfd`) and Innov'up Leader PIA (`605574ce66802712b571fa22`).
7. **Needs network allow-listing or another machine:** scanR API (patents/projects/publications by SIREN), Horizon Europe participations (`fr-esr-horizon-projects-entities`), HAL, then the CIR/CII approval lists.
8. i-Démo: manual collection from press releases, as no open dataset exists.

Tabular API tips:
- Filters are single-column. Use `contains` for names and `exact` for SIREN.
- Intermittent "Bad Gateway" errors from the MCP clear on retry.
- ANR surnames are UPPERCASE. ESR `Raison sociale` is UPPERCASE.
