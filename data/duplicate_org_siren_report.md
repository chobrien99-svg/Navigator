# Duplicate organization records — SIREN collision report

_Generated 2026-10-17. 129 SIREN values are attached to more than one organization, covering 259 org records._

Each block below groups the organizations that share one SIREN (company registration number). A SIREN identifies exactly one legal entity, so in principle every group is a duplicate — **but some SIRENs are mis-attached to genuinely different companies in the legacy data, so this is a triage list, not an auto-merge list.**

**Suggested-action key**

- **MERGE (name variant)** — the names normalise to the same company (case / spacing / punctuation / legal-form suffix / year). Safe to merge like the three already done (keep the record with real funding data as survivor; re-point children; delete the stub).
- **REVIEW (names differ)** — the names are not obvious variants. This is either a rebrand (e.g. Gecko Biomedical → Tissium) **or** a bad SIREN on the wrong company (e.g. two unrelated firms). Verify before merging — do **not** merge blindly.
- **dup legal entity** — one org also has two legal_entity rows with the same SIREN; that duplicate row should be removed regardless of any org merge.

**Totals:** 63 groups look like safe name-variant merges · 66 groups need review · 16 groups also contain a duplicated legal_entity row.

> Columns per org: `name` · slug · source · r=funding rounds · p=people. The record with rounds>0 (usually `funding_tracker` / `funding_deals_*`) is normally the survivor; `ilab` / `inov` / `french_tech_next` rows with r=0 are legacy stubs.

---

## Needs review — names differ (66 groups)

### SIREN `849441522` — 3 orgs
- **Pasqal** · `pasqal` · src=french_tech_next · r=2 p=0
- **PROQURE** · `proqure` · src=ilab · r=0 p=1
- **Pasqal SAS** · `pasqal-sas` · src=inov · r=0 p=0

### SIREN `447817818` — 2 orgs
- **Axoltis Pharma** · `axoltis-pharma` · src=funding_tracker · r=1 p=0
- **NEURONAX** · `neuronax` · src=ilab · r=0 p=1

### SIREN `452386121` — 2 orgs
- **MICROWAVE CHARACTERIZATION CENTER** · `microwave-characterization-center` · src=ilab · r=0 p=1
- **MC2 Technologies** · `mc2-technologies` · src=inov · r=0 p=0

### SIREN `452626252` — 2 orgs
- **DEPUR Experiences** · `depur-experiences` · src=funding_deals_2023 · r=1 p=0
- **abCSR** · `abcsr` · src=funding_deals_2023 · r=1 p=0

### SIREN `484872551` — 2 orgs
- **WATCHFROG** · `watchfrog` · src=ilab · r=0 p=2
- **SPIREC** · `spirec` · src=inov · r=0 p=0

### SIREN `498198167` — 2 orgs
- **MICROOLED** · `microoled` · src=ilab · r=2 p=1
- **Engo** · `engo` · src=funding_deals_july_2026_week3 · r=1 p=2

### SIREN `503436107` — 2 orgs
- **Aladom** · `aladom` · src=funding_deals_2023 · r=1 p=0
- **DMCC** · `dmcc` · src=funding_deals_2023 · r=1 p=0

### SIREN `514972306` — 2 orgs
- **STRUCTURE COMPUTATION** · `structure-computation` · src=ilab · r=0 p=1
- **SAS SPINALCOM** · `sas-spinalcom` · src=inov · r=0 p=0

### SIREN `529042376` — 2 orgs
- **DEVATICS** · `devatics` · src=ilab · r=0 p=1
- **Onestock** · `onestock` · src=funding_deals_2021_crunchbase · r=1 p=0

### SIREN `539529669` — 2 orgs
- **GEOCORAIL** · `geocorail` · src=inov · r=0 p=0
- **Seacure** · `seacure` · src=funding_deals_june_2026 · r=1 p=1

### SIREN `750444697` — 2 orgs
- **ZERO GACHIS** · `zero-gachis` · src=inov · r=1 p=0
- **smartway** · `smartway` · src=inov · r=1 p=0

### SIREN `793166299` — 2 orgs
- **Tissium** · `tissium` · src=french_tech_next · r=3 p=2
- **GECKO BIOMEDICAL SA** · `gecko-biomedical-sa` · src=inov · r=0 p=0

### SIREN `793845314` — 2 orgs
- **GENE ET GREENTECH** · `gene-et-greentech` · src=ilab · r=0 p=2
- **Gene&Green TK** · `genegreen-tk` · src=inov · r=0 p=0

### SIREN `794167593` — 2 orgs
- **Metron** · `metron` · src=french_tech_next · r=2 p=1
- **SEVA Technologies** · `seva-technologies` · src=inov · r=0 p=0

### SIREN `801623596` — 2 orgs
- **INSTENT** · `instent` · src=ilab · r=0 p=1
- **Sensome** · `sensome` · src=inov · r=0 p=0

### SIREN `803183771` — 2 orgs
- **HEYDAY INTEGRATED CIRCUITS** · `heyday-integrated-circuits` · src=ilab · r=0 p=1
- **SQUADRONE SYSTEM** · `squadrone-system` · src=inov · r=0 p=0

### SIREN `803450287` — 2 orgs
- **WEEDEC** · `weedec` · src=ilab · r=0 p=1
- **Weenat** · `weenat` · src=inov · r=2 p=0

### SIREN `803695402` — 2 orgs
- **Sim&Cure** · `simcure` · src=funding_tracker · r=1 p=1
- **IRRAS TECHNOLOGY** · `irras-technology` · src=ilab · r=0 p=1

### SIREN `808139521` — 2 orgs
- **CLICK4TAG** · `click4tag` · src=ilab · r=0 p=1
- **DIAMIDEX** · `diamidex` · src=funding_deals_2023 · r=1 p=0

### SIREN `809273329` — 2 orgs
- **Solar Cloth System** · `solar-cloth-system` · src=inov · r=0 p=0
- **D-ICE Engineering** · `d-ice-engineering` · src=inov · r=2 p=0

### SIREN `810876177` — 2 orgs
- **SWEETCH ENERGY** · `sweetch-energy` · src=inov · r=4 p=0
- **GEOLITH** · `geolith` · src=inov · r=0 p=0

### SIREN `814412672` — 2 orgs
- **NovaRT** · `novart` · src=ilab · r=0 p=1
- **NovaGray** · `novagray` · src=inov · r=0 p=0

### SIREN `818503146` — 2 orgs
- **Earthcube** · `earthcube` · src=inov · r=0 p=0
- **Preligens** · `preligens` · src=funding_deals_2023 · r=1 p=0

### SIREN `818670093` — 2 orgs
- **Gilles Vallier** · `gilles-vallier` · src=ilab · r=0 p=1
- **K-Ryol** · `k-ryol` · src=inov · r=0 p=0

### SIREN `821893286` — 2 orgs
- **Sendinblue** · `sendinblue` · src=french_tech_next · r=0 p=0
- **Spendesk** · `spendesk` · src=french_tech_next · r=2 p=0

### SIREN `822393013` — 2 orgs
- **SAS** · `sas` · src=ilab · r=0 p=1
- **SMARTCATCH** · `smartcatch` · src=inov · r=1 p=0

### SIREN `822704532` — 2 orgs
- **IADYS** · `iadys` · src=inov · r=1 p=0
- **Interactive Autonomous DYnamic Systems** · `interactive-autonomous-dynamic-systems` · src=funding_deals_2024_v2 · r=1 p=0

### SIREN `824343214` — 2 orgs · ⚠️ dup legal_entity
- **Exeliom Biosciences** · `exeliom-biosciences` · src=funding_tracker · r=1 p=0
- **Nextbiotix** · `nextbiotix` · src=ilab · r=0 p=1

### SIREN `829235928` — 2 orgs
- **SCANBAT** · `scanbat` · src=ilab · r=0 p=1
- **PowerUp** · `powerup` · src=inov · r=0 p=0

### SIREN `829348747` — 2 orgs
- **HIRAKLIS** · `hiraklis` · src=ilab · r=0 p=1
- **Kinvent** · `kinvent` · src=funding_deals_2024_v2 · r=2 p=0

### SIREN `829924638` — 2 orgs
- **UniQom** · `uniqom` · src=ilab · r=0 p=1
- **VeriQloud** · `veriqloud` · src=inov · r=1 p=0

### SIREN `830930889` — 2 orgs
- **Dianosic** · `dianosic` · src=funding_tracker · r=2 p=4
- **SARI-SC** · `sari-sc` · src=ilab · r=0 p=1

### SIREN `833737653` — 2 orgs
- **ALTAROAD** · `altaroad` · src=ilab · r=0 p=1
- **Green Communications** · `green-communications` · src=inov · r=0 p=0

### SIREN `833953631` — 2 orgs
- **Greenbig** · `greenbig` · src=inov · r=1 p=0
- **B:Bot** · `bbot` · src=funding_deals_2023 · r=2 p=0

### SIREN `834504862` — 2 orgs
- **Entent** · `entent` · src=funding_tracker · r=2 p=1
- **PULSE** · `pulse` · src=ilab · r=0 p=1

### SIREN `838887263` — 2 orgs
- **UrbanAirNet** · `urbanairnet` · src=ilab · r=0 p=1
- **WaltR** · `waltr` · src=inov · r=1 p=0

### SIREN `838969541` — 2 orgs
- **MethaPlasm** · `methaplasm` · src=ilab · r=0 p=1
- **Energo** · `energo` · src=funding_deals_2024_v2 · r=1 p=0

### SIREN `838982858` — 2 orgs
- **LV4C** · `lv4c` · src=ilab · r=0 p=1
- **ORIXHA** · `orixha` · src=inov · r=1 p=0

### SIREN `840607279` — 2 orgs
- **TAKALI** · `takali` · src=ilab · r=0 p=1
- **PLENESYS** · `plenesys` · src=inov · r=0 p=0

### SIREN `840634356` — 2 orgs
- **GanyBOT** · `ganybot` · src=ilab · r=0 p=1
- **GANYMED ROBOTICS** · `ganymed-robotics` · src=inov · r=2 p=0

### SIREN `840990402` — 2 orgs
- **ONCO-Boost** · `onco-boost` · src=ilab · r=0 p=1
- **HEPHAISTOS-Pharma** · `hephaistos-pharma` · src=inov · r=1 p=0

### SIREN `841052814` — 2 orgs
- **CYS’ART** · `cysart` · src=ilab · r=0 p=1
- **ABYS MEDICAL** · `abys-medical` · src=inov · r=0 p=0

### SIREN `841218118` — 2 orgs
- **Autonomous Clean Water Appliance (ACWA)** · `autonomous-clean-water-appliance-acwa` · src=ilab · r=0 p=1
- **CT2MC** · `ct2mc` · src=inov · r=0 p=0

### SIREN `843692559` — 2 orgs
- **KIMEA 360** · `kimea-360` · src=ilab · r=0 p=1
- **Moovency** · `moovency` · src=inov · r=0 p=0

### SIREN `843788811` — 2 orgs
- **ARMMS** · `armms` · src=ilab · r=0 p=1
- **ORTHOPUS** · `orthopus` · src=inov · r=1 p=0

### SIREN `845055938` — 2 orgs
- **DEMZONE 2** · `demzone-2` · src=ilab · r=0 p=1
- **DEMBoost** · `demboost` · src=inov · r=0 p=0

### SIREN `847746997` — 2 orgs
- **SENSITINES** · `sensitines` · src=ilab · r=0 p=1
- **Green Impulse** · `green-impulse` · src=inov · r=0 p=0

### SIREN `849349642` — 2 orgs
- **OCEAN Diagnostics** · `ocean-diagnostics` · src=ilab · r=0 p=1
- **OCEAN Dx** · `ocean-dx` · src=inov · r=0 p=0

### SIREN `849959390` — 2 orgs
- **Apmonia Therapeutics** · `apmonia-therapeutics` · src=funding_tracker · r=3 p=1
- **IO_ORPHA** · `ioorpha` · src=ilab · r=0 p=1

### SIREN `850364423` — 2 orgs
- **WoundLAB** · `woundlab` · src=ilab · r=0 p=1
- **GRAPHEAL** · `grapheal` · src=inov · r=1 p=0

### SIREN `851436188` — 2 orgs
- **Moon surgical** · `moon-surgical` · src=french_tech_next · r=2 p=0
- **MASTOR** · `mastor` · src=inov · r=0 p=0

### SIREN `851589770` — 2 orgs
- **NextHSM** · `nexthsm` · src=ilab · r=0 p=1
- **CryptoNext** · `cryptonext` · src=inov · r=0 p=0

### SIREN `853059384` — 2 orgs
- **Studio For All** · `studio-for-all` · src=ilab · r=0 p=1
- **Photoroom** · `photoroom` · src=funding_deals_2024_v2 · r=2 p=0

### SIREN `853328201` — 2 orgs
- **Mangrove** · `mangrove` · src=ilab · r=0 p=1
- **Arkhn** · `arkhn` · src=inov · r=1 p=0

### SIREN `881016174` — 2 orgs
- **PRACAD** · `pracad` · src=ilab · r=0 p=1
- **Brightflow** · `brightflow` · src=funding_deals_2024_v2 · r=1 p=0

### SIREN `882659360` — 2 orgs
- **Diagnoly** · `diagnoly` · src=funding_tracker · r=2 p=2
- **MEDICING** · `medicing` · src=ilab · r=0 p=1

### SIREN `883899478` — 2 orgs
- **Umiami** · `umiami` · src=french_tech_next · r=3 p=1
- **Swap** · `swap` · src=funding_deals_2023 · r=1 p=0

### SIREN `891908576` — 2 orgs · ⚠️ dup legal_entity
- **Ecosystem Restoration Standard** · `ecosystem-restoration-standard` · src=funding_tracker · r=1 p=1
- **Equitable Earth** · `equitable-earth` · src=funding_tracker · r=4 p=2

### SIREN `897590592` — 2 orgs
- **Astrachain** · `astrachain` · src=ilab · r=1 p=1
- **ASTRAN** · `astran` · src=inov · r=2 p=0

### SIREN `899832901` — 2 orgs
- **Vizzia** · `vizzia` · src=funding_tracker · r=3 p=3
- **ALPHAIOTA** · `alphaiota` · src=inov · r=0 p=0

### SIREN `903949691` — 2 orgs · ⚠️ dup legal_entity
- **Hexalean** · `hexalean` · src=funding_tracker · r=1 p=1
- **ïkos Bordeaux** · `ikos-bordeaux` · src=funding_tracker · r=1 p=0

### SIREN `908328487` — 2 orgs
- **Verley** · `verley` · src=funding_tracker · r=1 p=2
- **Bon Vivant** · `bon-vivant` · src=ilab · r=2 p=1

### SIREN `910040658` — 2 orgs
- **Cosma** · `cosma` · src=funding_tracker · r=1 p=2
- **DEESS** · `deess` · src=ilab · r=0 p=1

### SIREN `921853990` — 2 orgs
- **CURE-HD** · `cure-hd` · src=ilab · r=0 p=1
- **HuntX Pharma** · `huntx-pharma` · src=inov · r=0 p=0

### SIREN `949645600` — 2 orgs
- **Celest Science** · `celest-science` · src=funding_tracker · r=1 p=2
- **TELLUS AI** · `tellus-ai` · src=ilab · r=0 p=1

### SIREN `982235590` — 2 orgs · ⚠️ dup legal_entity
- **fluiidd** · `fluiidd` · src=funding_tracker · r=1 p=2
- **ITIE** · `itie` · src=ilab · r=0 p=1

## Likely safe merges — name variants (63 groups)

### SIREN `490533528` — 2 orgs
- **VU Log** · `vu-log` · src=inov · r=0 p=0
- **VULOG** · `vulog` · src=inov · r=1 p=0

### SIREN `503225716` — 2 orgs
- **VEKIA SAS** · `vekia-sas` · src=ilab · r=0 p=1
- **VEKIA** · `vekia` · src=inov · r=0 p=0

### SIREN `508290947` — 2 orgs
- **Campings.com** · `campingscom` · src=french_tech_next · r=0 p=0
- **Campings** · `campings` · src=funding_deals_2023 · r=1 p=0

### SIREN `509397832` — 2 orgs · ⚠️ dup legal_entity
- **PulseSight Therapeutics** · `pulsesight-therapeutics` · src=funding_tracker · r=1 p=0
- **PulseSight** · `eyevensys` · src=french_tech_next · r=1 p=0

### SIREN `511778532` — 2 orgs
- **DIOTASOFT** · `diotasoft` · src=ilab · r=0 p=1
- **DIOTASOFT S.A.S.** · `diotasoft-sas` · src=inov · r=0 p=0

### SIREN `521563742` — 2 orgs
- **LA COMPAGNIE DES MOBILITÉS Geovelo** · `la-compagnie-des-mobilites-geovelo` · src=inov · r=0 p=0
- **GEOVELO** · `geovelo` · src=inov · r=1 p=0

### SIREN `524724820` — 2 orgs
- **BW Ideol** · `bw-ideol` · src=funding_tracker · r=1 p=2
- **IDEOL** · `ideol` · src=ilab · r=0 p=1

### SIREN `530890599` — 2 orgs
- **IT CONTROL EXPERT** · `it-control-expert` · src=inov · r=0 p=0
- **I.T.Control Expert** · `itcontrol-expert` · src=inov · r=0 p=0

### SIREN `531208734` — 2 orgs · ⚠️ dup legal_entity
- **Expliseat** · `expliseat` · src=funding_tracker · r=2 p=0
- **EXPLISEAT SAS** · `expliseat-sas` · src=inov · r=0 p=0

### SIREN `538758236` — 2 orgs
- **Dracula Technologies** · `dracula-technologies` · src=funding_tracker · r=2 p=1
- **SARL DRACULA Technologies** · `sarl-dracula-technologies` · src=inov · r=0 p=0

### SIREN `749906525` — 2 orgs
- **Aleph-Networks** · `aleph-networks` · src=funding_tracker · r=1 p=1
- **Aleph- Networks** · `aleph--networks` · src=inov · r=0 p=0

### SIREN `750423295` — 2 orgs
- **Matawan Mobility** · `ubitransport` · src=french_tech_next · r=0 p=0
- **Matawan** · `matawan` · src=french_tech_next · r=0 p=0

### SIREN `789041027` — 2 orgs
- **CARDIORENAL DIAGNOSTICS** · `cardiorenal-diagnostics` · src=ilab · r=0 p=1
- **Cardiorenal** · `cardiorenal` · src=inov · r=1 p=0

### SIREN `793920521` — 2 orgs
- **THERAPIXEL** · `therapixel` · src=ilab · r=2 p=1
- **Therapixel SA** · `therapixel-sa` · src=inov · r=0 p=0

### SIREN `794581223` — 2 orgs
- **CINTOO 3D** · `cintoo-3d` · src=ilab · r=0 p=1
- **Cintoo** · `cintoo` · src=inov · r=2 p=0

### SIREN `802524512` — 2 orgs
- **QUCIT** · `qucit` · src=ilab · r=0 p=1
- **QUCIT SAS** · `qucit-sas` · src=inov · r=0 p=0

### SIREN `808490619` — 2 orgs
- **PHOST'IN** · `phostin` · src=ilab · r=0 p=1
- **PHOST’IN THERAPEUTICS** · `phostin-therapeutics` · src=inov · r=0 p=0

### SIREN `808684443` — 2 orgs
- **Everysens SAS** · `everysens-sas` · src=inov · r=0 p=0
- **everysens** · `everysens` · src=inov · r=1 p=0

### SIREN `808749873` — 2 orgs
- **MilliDrop Instruments SAS** · `millidrop-instruments-sas` · src=ilab · r=0 p=1
- **MilliDrop Instrument SAS** · `millidrop-instrument-sas` · src=inov · r=0 p=0

### SIREN `809711856` — 2 orgs
- **Etix Everywhere** · `etix-everywhere` · src=funding_deals_2023 · r=1 p=0
- **Etix** · `etix` · src=funding_deals_2023 · r=1 p=0

### SIREN `809890510` — 2 orgs
- **Jay & Joy** · `jay-joy` · src=funding_tracker · r=1 p=1
- **Jay&Joy** · `jayjoy` · src=funding_tracker · r=3 p=2

### SIREN `812878742` — 2 orgs
- **Exotec Solutions** · `exotec-solutions` · src=french_tech_next · r=0 p=1
- **Exotec** · `exotec` · src=french_tech_next · r=1 p=0

### SIREN `819345042` — 2 orgs
- **ACKLIO SAS** · `acklio-sas` · src=ilab · r=0 p=1
- **Acklio** · `acklio` · src=inov · r=0 p=0

### SIREN `819556168` — 2 orgs
- **Velco SAS** · `velco-sas` · src=inov · r=0 p=0
- **VEL'CO** · `velco` · src=inov · r=2 p=0

### SIREN `820081602` — 2 orgs
- **Japet Medical Devices** · `japet-medical-devices` · src=ilab · r=0 p=1
- **Japet Medical** · `japet-medical` · src=inov · r=1 p=0

### SIREN `820569218` — 2 orgs
- **Laclaree Vision** · `-laclaree-vision` · src=funding_tracker · r=1 p=1
- **Laclarée** · `laclaree` · src=ilab · r=1 p=1

### SIREN `821738515` — 2 orgs
- **Antescofo** · `antescofo` · src=ilab · r=0 p=1
- **Antescofo SAS** · `antescofo-sas` · src=inov · r=0 p=0

### SIREN `824012173` — 2 orgs
- **Swile** · `lunchr` · src=french_tech_next · r=0 p=0
- **Swile** · `swile` · src=french_tech_next · r=1 p=0

### SIREN `828176784` — 2 orgs
- **Alkion BioInnovations** · `alkion-bioinnovations` · src=funding_tracker · r=2 p=0
- **ALKION BIO INNOVATIONS** · `alkion-bio-innovations` · src=inov · r=0 p=0

### SIREN `829480318` — 2 orgs
- **REDBERRY** · `redberry` · src=ilab · r=0 p=1
- **REDBERRY SAS** · `redberry-sas` · src=inov · r=0 p=0

### SIREN `831286455` — 2 orgs
- **ElicitPlant** · `elicitplant` · src=french_tech_next · r=0 p=0
- **Elicit Plant** · `elicit-plant` · src=funding_deals_2024_v2 · r=3 p=0

### SIREN `831351796` — 2 orgs
- **MagIA Diagnostics SAS** · `magia-diagnostics-sas` · src=inov · r=0 p=0
- **MagIA Diagnostics** · `magia-diagnostics` · src=inov · r=0 p=0

### SIREN `832815948` — 2 orgs · ⚠️ dup legal_entity
- **MYCOPHYTO** · `mycophyto` · src=funding_tracker · r=3 p=1
- **MYCOPHYTO 2019** · `mycophyto-2019` · src=ilab · r=0 p=1

### SIREN `833310204` — 2 orgs
- **Return of Silicon (ROSI)** · `return-of-silicon-rosi` · src=ilab · r=0 p=1
- **ROSI** · `rosi` · src=inov · r=4 p=0

### SIREN `837540210` — 2 orgs · ⚠️ dup legal_entity
- **ELWAVE** · `elwave` · src=funding_tracker · r=1 p=1
- **ELWAVE Système** · `elwave-systeme` · src=ilab · r=0 p=1

### SIREN `840545123` — 2 orgs · ⚠️ dup legal_entity
- **InBrain Pharma** · `inbrain-pharma` · src=funding_tracker · r=1 p=2
- **InBrainPharma** · `inbrainpharma` · src=ilab · r=0 p=1

### SIREN `840903447` — 2 orgs
- **COSMIAN** · `cosmian` · src=ilab · r=1 p=1
- **COSMIAN TECH** · `cosmian-tech` · src=inov · r=0 p=0

### SIREN `842753436` — 2 orgs
- **SESTERCE** · `sesterce` · src=inov · r=0 p=0
- **SESTERCE France LABS** · `sesterce-france-labs` · src=inov · r=0 p=0

### SIREN `842959249` — 2 orgs
- **MATERR'UP SAS** · `materrup-sas` · src=inov · r=0 p=0
- **Materrup** · `materrup` · src=funding_deals_2024_v2 · r=1 p=0

### SIREN `844370320` — 2 orgs · ⚠️ dup legal_entity
- **TreeFrog Therapeutics** · `treefrog-therapeutics` · src=funding_tracker · r=2 p=4
- **Tree Frog Therapeutics** · `tree-frog-therapeutics` · src=french_tech_next · r=0 p=0

### SIREN `845257930` — 2 orgs
- **Mablink** · `mablink` · src=ilab · r=0 p=1
- **Mablink Bioscience** · `mablink-bioscience` · src=inov · r=2 p=0

### SIREN `848016093` — 2 orgs
- **TOOPI Organics** · `toopi-organics` · src=ilab · r=1 p=1
- **TOOPI-Organics SAS** · `toopi-organics-sas` · src=inov · r=0 p=0

### SIREN `848981809` — 2 orgs
- **OKEENEA DIGITAL** · `okeenea-digital` · src=inov · r=0 p=0
- **OKEENEA** · `okeenea` · src=inov · r=0 p=0

### SIREN `849445192` — 2 orgs · ⚠️ dup legal_entity
- **SeaBeLife** · `seabelife` · src=funding_tracker · r=3 p=4
- **SeaBeLife_2020** · `seabelife2020` · src=ilab · r=0 p=1

### SIREN `850904202` — 2 orgs
- **vorteX.io** · `vortexio` · src=inov · r=0 p=0
- **vorteX-io** · `vortex-io` · src=funding_deals_2024_v2 · r=2 p=2

### SIREN `851016329` — 2 orgs
- **Dry4Good (LGD)** · `dry4good-lgd` · src=inov · r=0 p=0
- **Dry4Good** · `dry4good` · src=funding_deals_june_2026 · r=1 p=2

### SIREN `878322155` — 2 orgs
- **Surgical Augmented Reality (SurgAR)** · `surgical-augmented-reality-surgar` · src=ilab · r=0 p=1
- **SURGAR** · `surgar` · src=inov · r=1 p=0

### SIREN `878678051` — 2 orgs
- **Loft Orbital** · `loft-orbital` · src=funding_tracker · r=1 p=1
- **Loft Orbital** · `loft-orbital-solutions` · src=french_tech_next · r=0 p=0

### SIREN `879295277` — 2 orgs
- **G+Lyte** · `glyte` · src=ilab · r=0 p=1
- **G-LYTE** · `g-lyte` · src=inov · r=0 p=0

### SIREN `880788054` — 2 orgs
- **Geolinks Services** · `geolinks-services` · src=funding_tracker · r=1 p=1
- **GeoLinks** · `geolinks` · src=ilab · r=1 p=1

### SIREN `881527477` — 2 orgs
- **Quantiq** · `quantiq` · src=ilab · r=0 p=1
- **Quantiq.io** · `quantiqio` · src=inov · r=1 p=0

### SIREN `881729156` — 2 orgs
- **Alice & Bob** · `alice-bob` · src=funding_tracker · r=7 p=4
- **Alice&Bob** · `alicebob` · src=ilab · r=0 p=1

### SIREN `882347958` — 2 orgs · ⚠️ dup legal_entity
- **RDS** · `rds` · src=funding_tracker · r=5 p=1
- **RDS SAS** · `rds-sas` · src=inov · r=0 p=0

### SIREN `882417314` — 2 orgs
- **NavAlgo** · `navalgo` · src=ilab · r=0 p=1
- **PATHWAY (NAVALGO)** · `pathway-navalgo` · src=inov · r=0 p=0

### SIREN `884522582` — 2 orgs
- **Standing Ovation** · `standing-ovation` · src=funding_deals_march_2026 · r=3 p=2
- **STANDING OVATION SAS** · `standing-ovation-sas` · src=ilab · r=0 p=1

### SIREN `888384252` — 2 orgs
- **Enginn** · `enginn` · src=ilab · r=0 p=1
- **ENGINN TECHNOLOGIES** · `enginn-technologies` · src=inov · r=2 p=0

### SIREN `888699584` — 2 orgs
- **Escape** · `escape` · src=funding_tracker · r=3 p=2
- **ESCAPE TECHNOLOGIES** · `escape-technologies` · src=inov · r=0 p=0

### SIREN `888737186` — 2 orgs · ⚠️ dup legal_entity
- **Hemerion Therapeutics** · `hemerion-therapeutics` · src=funding_tracker · r=1 p=1
- **Hemerion** · `hemerion` · src=ilab · r=3 p=1

### SIREN `901036848` — 2 orgs
- **Biomemory labs** · `biomemory-labs` · src=ilab · r=0 p=1
- **Biomemory** · `biomemory` · src=funding_deals_2024_v2 · r=2 p=0

### SIREN `902971720` — 2 orgs · ⚠️ dup legal_entity
- **Kumulus** · `kumulus` · src=funding_tracker · r=1 p=2
- **Kumulus Water** · `kumulus-water` · src=ilab · r=2 p=1

### SIREN `917949927` — 2 orgs
- **Aéronde** · `aeronde` · src=funding_tracker · r=1 p=1
- **L'Aéronde** · `laeronde` · src=ilab · r=0 p=1

### SIREN `920440989` — 2 orgs · ⚠️ dup legal_entity
- **Pronoe** · `pronoe` · src=funding_tracker · r=1 p=1
- **PRONOE SAS** · `pronoe-sas` · src=ilab · r=0 p=1

### SIREN `922166996` — 2 orgs · ⚠️ dup legal_entity
- **Spore Biotechnologies** · `spore-biotechnologies` · src=funding_tracker · r=1 p=1
- **Spore.Bio** · `sporebio` · src=ilab · r=1 p=1
