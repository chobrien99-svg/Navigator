import json,re,unicodedata,collections
S='/tmp/claude-0/-home-user-Navigator/8db78c46-1762-56f2-8a79-dbef8001092b/scratchpad'
L=json.load(open('/home/user/Navigator/data/atlas_smr/france2030_obj1_laureates.json'))
NEW={o['siren'] or o['org']:o for o in json.load(open(S+'/f2030/new_orgs.json'))}
def slug(s): s=unicodedata.normalize('NFKD',s).encode('ascii','ignore').decode().lower(); return re.sub(r'[^a-z0-9]+','-',s).strip('-')
# siren -> (slug, display name, type, status, city_slug, nuclear_sector, founded_year, extra note)
U='university';R='research_lab';C='corporate';St='startup';P='public_agency'
M={
'812250231':('fonderie-lemer','Fonderie Lemer',C,'active','carquefou',0,None,''),
'775685019':('cea',"CEA (Commissariat à l'énergie atomique et aux énergies alternatives)",R,'active','paris',1,None,'French public research body for nuclear and alternative energy, defence, health and digital technologies.'),
'755501160':('bernardaud','Bernardaud',C,'active','limoges',0,None,'Limoges porcelain manufacturer.'),
'397862038':('trad-tests-radiations','TRAD Tests & Radiations',C,'active','labege',1,None,'Radiation testing and radiation-effects engineering.'),
'399395581':('stmicroelectronics-crolles-2','STMicroelectronics (Crolles 2) SAS',C,'active','crolles',0,None,'Semiconductor fab subsidiary of STMicroelectronics at Crolles.'),
'538613613':('laboratoire-detalons-dactivite-lea',"Laboratoire d'Étalons d'Activité (LEA)",C,'active','chatillon',1,None,'Producer of radioactive reference sources and standards.'),
'922039904':('nuward','Nuward',C,'active','paris',1,2022,'EDF subsidiary developing the NUWARD small modular reactor.'),
'324237254':('rousselet-centrifugation','Rousselet Centrifugation',C,'active','annonay',0,None,'Industrial centrifuge manufacturer.'),
'500803390':('veolia-nuclear-solutions-france','Veolia Nuclear Solutions France',C,'active','chasse-sur-rhone',1,None,'Nuclear decommissioning and waste-treatment arm of Veolia in France.'),
'305207169':('orano-demantelement','Orano Démantèlement',C,'active','chatillon',1,None,'Orano subsidiary for nuclear dismantling.'),
'817439599':('orano-recyclage','Orano Recyclage',C,'active','chatillon',1,None,'Orano subsidiary for spent-fuel recycling.'),
'400072997':('technetics-group-france','Technetics Group France',C,'active','saint-etienne',0,None,'Maker of high-performance seals and components.'),
'507759611':('socotec-monitoring-france','Socotec Monitoring France',C,'active','guyancourt',0,None,'Structural and environmental monitoring services.'),
'832780225':('innowtech','Innowtech',St,'closed','les-angles',1,2017,'Registered as ceased in the company register.'),
'510035298':('meliad','Meliad',C,'active','les-sorinieres',0,None,''),
'421356593':('orano-support','Orano Support',C,'active','chatillon',1,None,'Orano group support and R&D entity.'),
'193113818':('toulouse-inp','Toulouse INP (Institut national polytechnique de Toulouse)',U,'active','toulouse',0,None,''),
'817439557':('orano-chimie-enrichissement','Orano Chimie-Enrichissement',C,'active','chatillon',1,None,'Orano subsidiary for uranium conversion and enrichment.'),
'672008489':('orano-ds-demantelement-et-services','Orano DS – Démantèlement et Services',C,'active','massy',1,None,'Orano subsidiary for dismantling and nuclear services.'),
'198706699':('universite-de-limoges','Université de Limoges',U,'active','limoges',0,None,''),
'440546018':('irsn','IRSN (Institut de radioprotection et de sûreté nucléaire)',R,'active','fontenay-aux-roses',1,None,'Public expert body on nuclear and radiation risk; merged with ASN into ASNR on 1 January 2025.'),
'130001803':('asnr','ASNR (Autorité de sûreté nucléaire et de radioprotection)',P,'active','montrouge',1,None,'French nuclear safety and radiation protection authority, formed on 1 January 2025 from the merger of ASN and IRSN.'),
'180092025':('institut-mines-telecom','Institut Mines-Télécom (IMT)',U,'active','palaiseau',0,None,''),
'379041395':('framatome','Framatome',C,'active','courbevoie',1,None,'Nuclear reactor equipment and fuel company, majority-owned by EDF.'),
'443647144':('oakridge-orleans','Oakridge (Orléans)',C,'active','orleans',0,None,'Engineering firm in Orléans (not the US national laboratory).'),
'130015332':('aix-marseille-universite','Aix-Marseille Université',U,'active','marseille',0,None,''),
'902610443':('w-ce-process','W CE Process',C,'active','bordeaux',0,None,'Registered as W CE PROCESS (Process and Wine).'),
'652030677':('egis-nucleaire','Egis Nucléaire',C,'active','montreuil',1,None,'Nuclear engineering arm of Egis. France 2030 lists it as EGIS INDUSTRIES.'),
'191010602':('universite-de-technologie-de-troyes','Université de technologie de Troyes (UTT)',U,'active','troyes',0,None,''),
'504005612':('atlanchim-pharma','Atlanchim Pharma',C,'active','saint-herblain',0,None,'Contract chemistry research.'),
'380303107':('cyclife-france','Cyclife France',C,'active','codolet',1,None,'EDF group company for nuclear dismantling and waste treatment.'),
'909910630':('waste2glass','Waste2Glass',St,'active','limay',1,2022,''),
'344297775':('lermat','LERMAT (Laboratoire Études Recherche Matériaux)',C,'active','arles',0,None,''),
'403523525':('eci-meca','ECI Meca',C,'closed','vaison-la-romaine',0,None,'Registered as ceased in the company register.'),
'913080941':('genf','GENF',St,'active','elancourt',1,2022,''),
'950900720':('thorizon','Thorizon',St,'active','lyon',1,None,'French entity of Thorizon, a molten-salt reactor developer.'),
'197619042':('universite-de-rouen-normandie','Université de Rouen Normandie',U,'active','mont-saint-aignan',0,None,''),
'478969173':('ecm-technologies','ECM Technologies',C,'active','grenoble',0,None,'Industrial furnace maker.'),
'398750653':('curium','Curium',C,'active','montagny',1,None,'Nuclear medicine and radiopharmaceuticals.'),
'444159164':('assystem-engineering-and-operation-services','Assystem Engineering and Operation Services',C,'active','courbevoie',1,None,'Engineering subsidiary of Assystem, active in nuclear.'),
'195903497':('centrale-lille-institut','Centrale Lille Institut',U,'active','villeneuve-dascq',0,None,''),
'582056149':('brgm','BRGM',R,'active','orleans',0,None,"France's geological survey (Bureau de recherches géologiques et minières)."),
'130026123':('universite-gustave-eiffel','Université Gustave Eiffel',U,'active','champs-sur-marne',0,None,''),
'882949506':('naarea','Naarea',St,'active','nanterre',1,2020,'Developer of a molten-salt micro-reactor.'),
'622037083':('rhodia-operations','Rhodia Operations',C,'active','lyon',0,None,'Chemicals company (Solvay / Syensqo group).'),
'488453283':('itech-instruments','iTech Instruments',C,'active','vitrolles',0,None,''),
'918349796':('nuvia-protection','Nuvia Protection',C,'active','morestel',1,None,'Registered as NUVIA PROTECTION SERVICES. Nuclear protection services (Vinci group).'),
'130029754':('universite-de-lille','Université de Lille',U,'active','lille',0,None,''),
'ENTREPRISE AUGLANS':('entreprise-auglans','Entreprise Auglans',C,'active','millau',0,None,'Not found in the company register. France 2030 lists the town as Millau (69); Millau is in Aveyron (12). Needs review.'),
}
EXIST={'180089013':'cnrs','552081317':'edf','952843282':'stellaria','921792404':'blue-capsule-technology'}
CITIES={'les-angles':('Les Angles','30'),'les-sorinieres':('Les Sorinières','44'),'codolet':('Codolet','30'),'limay':('Limay','78'),'arles':('Arles','13'),'vaison-la-romaine':('Vaison-la-Romaine','84'),'montagny':('Montagny','69'),'millau':('Millau','12')}
# existing 15 by siren
EX15={'441414117':'amplitude-systemes','908713043':'calogena','413591215':'cesigma-signals-systems','808383632':'damavan-imaging','845055938':'demboost','849450705':'diamfab','953636149':'hexana','892884099':'jimmy-energy','912522240':'newcleo','924880933':'otrera','450538830':'probayes','885269332':'renaissance-fusion','442004461':'sileane','493848972':'triskem-international','832462162':'tx-4000'}
def q(s): return 'NULL' if s is None else "'"+str(s).replace("'","''")+"'"
projs=collections.OrderedDict(); orgproj=collections.defaultdict(list); conf={}
def oslug(r):
    k=r['siren'] or r['organisation']
    return M.get(k,[None])[0] or EXIST.get(k) or EX15.get(k)
rank={'high':3,'medium':2,'low':1,'review':0}
for r in L:
    p=r['project'] or r['organisation']
    if r['organisation']=='PALLAS': continue  # project name in the organisation slot; see note
    s=oslug(r); assert s,r
    projs.setdefault(p,[]); 
    if s not in projs[p]: projs[p].append(s)
    if p not in orgproj[s]: orgproj[s].append(p)
    c=r['match_confidence']; conf[s]=min(conf.get(s,c),c,key=lambda x:rank[x])
TAG='techbio' and 'f2030_obj1_smr_november_2026'
out=["-- =============================================================================",
"-- Atlas SMR: France 2030 Objectif 1 laureates (innovative small nuclear reactors",
"-- and better waste management) - organisations, projects and network links",
"-- =============================================================================",
"-- legacy_source 'f2030_obj1_smr_november_2026'.",
"-- Source: info.gouv.fr France 2030 laureates map, Objectif 1 filter, exported",
"-- manually by the editor (7 pages, 139 rows; Innowtech/PACH3 listed twice).",
"-- Parsed + resolved in data/atlas_smr/ (parse_f2030.py, resolve.py) against",
"-- recherche-entreprises.api.gouv.fr. Confidence carried in verification_status.",
"--  * 49 new organisations (48 with SIREN; Entreprise Auglans needs review).",
"--  * Existing CNRS, EDF, Blue Capsule Technology get their SIREN.",
"--  * Stellaria fix: the stored SIREN 837707512 belongs to an unrelated 2018",
"--    services firm in Saint-Pierre-la-Palud; the SMR developer is STELLARIA",
"--    DESIGN, SIREN 952843282 (Grenoble, 2023), which is the France 2030 laureate.",
"--  * 55 France 2030 projects in `projects`, linked to partners and to the",
"--    programme edition through `project_links` (role 'laureate').",
"--  * PALLAS appears on the list with no organisation (an IRSN-led project name);",
"--    it is linked to its four named partners only.",
"-- =============================================================================","",
"INSERT INTO cities (id, name, slug, department_code, country, created_at, updated_at) VALUES"]
out.append(',\n'.join(f"  (uuid_generate_v4(), {q(n)}, {q(s)}, {q(d)}, 'France', NOW(), NOW())" for s,(n,d) in CITIES.items())+"\nON CONFLICT (slug) DO NOTHING;\n")
rows=[]
for k,(s,n,t,st,city,nuc,fy,desc) in M.items():
    pr=orgproj[s]; full=(desc+' ' if desc else '')+f"France 2030 Objectif 1 laureate (project{'s' if len(pr)>1 else ''}: {', '.join(pr)})."
    rows.append(f"  (uuid_generate_v4(), {q(n)}, {q(s)}, '{t}'::organization_type, {q(full)}, '{st}'::organization_status, 'France', (SELECT id FROM cities WHERE slug={q(city)}), {fy or 'NULL'}, 'f2030_obj1_smr_november_2026', NOW(), NOW())")
out.append("INSERT INTO organizations (id, name, slug, organization_type, description, status, country, city_id, founded_year, legacy_source, created_at, updated_at) VALUES\n"+',\n'.join(rows)+"\nON CONFLICT (slug) DO NOTHING;\n")
# Stellaria fix
out.append("""-- Stellaria: replace the wrong legal entity with STELLARIA DESIGN
DELETE FROM legal_entities le USING organizations o WHERE le.organization_id=o.id AND o.slug='stellaria' AND le.siren='837707512';
""")
le=[]
NM={o['siren']:o for o in NEW.values() if o['siren']}
for k,v in list(M.items())+[(k,(v,)) for k,v in EXIST.items()]:
    if k not in NM: continue
    o=NM[k]; inc=o.get('created'); inc=None if (not inc or inc.endswith('-01-01')) else inc
    ln=re.sub(r'\s*\(.*$','',o.get('reg') or o['org'])
    le.append(f"  ({q(v[0])}, {q(ln)}, {q(k)}, {q(k)}, {q(inc)}, {q(o.get('city'))}, {q(o.get('naf'))}, {q(conf.get(v[0],'high'))})")
out.append("WITH source(slug, legal_name, siren, siren2, inc, city, naf, conf) AS (VALUES\n"+',\n'.join(le)+""")
INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, registered_city, naf_code, country, is_primary, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, s.inc::date, s.city, s.naf, 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.organization_id=o.id), s.conf, 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.siren=s.siren);
""")
nuc=[v[0] for v in M.values() if v[5]]
out.append(f"""-- Sector: Nuclear for nuclear-industry organisations
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, (SELECT id FROM sectors WHERE slug='nuclear'), NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id), NOW()
FROM organizations o WHERE o.slug IN ({','.join(q(s) for s in nuc)})
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.sector_id=(SELECT id FROM sectors WHERE slug='nuclear'));
""")
out.append("""-- Programme and edition
INSERT INTO programs (id, name, slug, program_type, description, country, source_url, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'France 2030', 'france-2030', 'france_2030', 'French state investment plan (€54bn) run by the SGPI with four operators: ANR, ADEME, Bpifrance and Caisse des Dépôts. Organised around 10 objectives.', 'France', 'https://www.info.gouv.fr/france-2030', 'f2030_obj1_smr_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM programs WHERE slug='france-2030');
INSERT INTO program_editions (id, program_id, name, slug, description, source_url, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'France 2030 — Objectif 1: small innovative nuclear reactors & better waste management', 'france-2030-objectif-1-nucleaire',
  'Laureates of France 2030 Objectif 1: « Faire émerger en France d''ici 2030 des réacteurs nucléaires de petite taille, innovants et avec une meilleure gestion des déchets ». 139 laureate rows (138 unique) as listed on the official map in November 2026.',
  'https://www.info.gouv.fr/france-2030/laureats', 'high', 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM programs p WHERE p.slug='france-2030' AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='france-2030-objectif-1-nucleaire');
""")
po=[f"  ({q(s)}, {q('Projects: '+', '.join(p))}, {q(conf[s])})" for s,p in orgproj.items()]
out.append("WITH source(slug, notes, conf) AS (VALUES\n"+',\n'.join(po)+""")
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Laureate', s.notes, s.conf, 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.slug JOIN program_editions pe ON pe.slug='france-2030-objectif-1-nucleaire'
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;
""")
pj=[]
for p,orgs in projs.items():
    summ=f"France 2030 Objectif 1 laureate project (small innovative nuclear reactors and waste management). {len(orgs)} named partner{'s' if len(orgs)>1 else ''}."
    if p=='PALLAS': summ+=" The official list also shows PALLAS as an entry with no organisation."
    pj.append(f"  ({q(p)}, {q('france-2030-obj1-'+slug(p))}, {q(summ)})")
out.append("WITH source(name, slug, summary) AS (VALUES\n"+',\n'.join(pj)+""")
INSERT INTO projects (id, name, slug, summary, technical_focus, sector, commercialization_status, is_public, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, s.summary, ARRAY['nuclear'], 'Nucléaire', 'awarded', FALSE, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

INSERT INTO project_links (id, project_id, program_edition_id, role, status, created_at)
SELECT uuid_generate_v4(), p.id, pe.id, 'laureate', 'verified', NOW()
FROM projects p JOIN program_editions pe ON pe.slug='france-2030-objectif-1-nucleaire'
WHERE p.slug LIKE 'france-2030-obj1-%' AND NOT EXISTS (SELECT 1 FROM project_links x WHERE x.project_id=p.id AND x.program_edition_id=pe.id);
""")
pl=[]
for p,orgs in projs.items():
    for s in orgs: pl.append(f"  ({q('france-2030-obj1-'+slug(p))}, {q(s)}, {q('verified' if conf[s]=='high' else 'proposed')})")
out.append("WITH source(pslug, oslug, st) AS (VALUES\n"+',\n'.join(pl)+""")
INSERT INTO project_links (id, project_id, organization_id, role, status, created_at)
SELECT uuid_generate_v4(), p.id, o.id, 'laureate', s.st, NOW()
FROM source s JOIN projects p ON p.slug=s.pslug JOIN organizations o ON o.slug=s.oslug
WHERE NOT EXISTS (SELECT 1 FROM project_links x WHERE x.project_id=p.id AND x.organization_id=o.id);
""")
rel=[('orano-demantelement','orano','subsidiary_of','Orano group subsidiary.'),('orano-recyclage','orano','subsidiary_of','Orano group subsidiary.'),('orano-support','orano','subsidiary_of','Orano group subsidiary.'),('orano-chimie-enrichissement','orano','subsidiary_of','Orano group subsidiary.'),('orano-ds-demantelement-et-services','orano','subsidiary_of','Orano group subsidiary.'),
 ('nuward','edf','subsidiary_of','EDF subsidiary developing the NUWARD SMR.'),('framatome','edf','subsidiary_of','Majority-owned by EDF.'),('cyclife-france','edf','subsidiary_of','EDF group company.'),
 ('stmicroelectronics-crolles-2','stmicroelectronics','subsidiary_of','STMicroelectronics fab subsidiary.'),('cea-investissement','cea','subsidiary_of','Investment arm of CEA.'),
 ('irsn','asnr','other','IRSN merged with ASN to form ASNR on 1 January 2025.')]
out.append("WITH source(a, b, t, d) AS (VALUES\n"+',\n'.join(f"  ({q(a)}, {q(b)}, {q(t)}, {q(d)})" for a,b,t,d in rel)+""")
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.d, 'public_record', 'Company register / public sources', 'high', 'f2030_obj1_smr_november_2026', NOW(), NOW()
FROM source s JOIN organizations a ON a.slug=s.a JOIN organizations b ON b.slug=s.b
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type);
""")
allslugs=list(orgproj)
out.append(f"""-- Tags
INSERT INTO organization_tags (id, organization_id, tag, created_at)
SELECT uuid_generate_v4(), o.id, t.tag, NOW() FROM organizations o CROSS JOIN (VALUES ('France 2030 laureate'),('Atlas: SMR & nuclear innovation')) t(tag)
WHERE o.slug IN ({','.join(q(s) for s in allslugs)})
ON CONFLICT (organization_id, tag) DO NOTHING;

SELECT (SELECT count(*) FROM organizations WHERE legacy_source='f2030_obj1_smr_november_2026') new_orgs,
 (SELECT count(*) FROM program_organizations po JOIN program_editions pe ON pe.id=po.program_edition_id WHERE pe.slug='france-2030-objectif-1-nucleaire') laureates,
 (SELECT count(*) FROM projects WHERE slug LIKE 'france-2030-obj1-%') projects,
 (SELECT count(*) FROM project_links pl JOIN projects p ON p.id=pl.project_id WHERE p.slug LIKE 'france-2030-obj1-%' AND pl.organization_id IS NOT NULL) org_links;
""")
open('/home/user/Navigator/supabase/migrations/phase38/12_atlas_smr_france2030_obj1.sql','w').write('\n'.join(out))
print(len(M),len(projs),len(pl),len(orgproj))
