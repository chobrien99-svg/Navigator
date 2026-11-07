import json,sys,os,re,unicodedata,difflib
sys.path.insert(0,sys.argv[1]+'/run3')
from nethelper import get_json
F=sys.argv[1]+'/f2030'; OUT=F+'/resolved'; os.makedirs(OUT,exist_ok=True)
rows=json.load(open(F+'/smr_laureates_all.json'))
def norm(s):
    s=unicodedata.normalize('NFKD',s or '').encode('ascii','ignore').decode().upper()
    s=re.sub(r"\b(SAS|SA|SASU|SARL|SE|GIE|EPIC|THE)\b",' ',s); return re.sub(r'[^A-Z0-9]+',' ',s).strip()
orgs={}
for r in rows:
    if r['organisation']: orgs.setdefault((r['organisation'],r['departement']),r)
API='https://recherche-entreprises.api.gouv.fr/search'
for (name,dep),r in orgs.items():
    key=re.sub(r'[^a-z0-9]+','_',(name+'_'+str(dep)).lower())[:90]; fn=f'{OUT}/{key}.json'
    if os.path.exists(fn): continue
    best=None
    for params in ([{'q':name,'departement':dep,'per_page':10}] if dep else [])+[{'q':name,'per_page':10}]:
        try: d=get_json(API,params,tries=6,wait=3)
        except Exception as e: d={'results':[]}
        for c in d.get('results',[]):
            nm=c.get('nom_complet') or ''; sc=difflib.SequenceMatcher(None,norm(name),norm(re.sub(r'\(.*?\)','',nm))).ratio()
            deps={(e.get('departement') or (e.get('code_postal') or '')[:2]) for e in [c.get('siege') or {}]+(c.get('matching_etablissements') or [])}
            dep_ok=bool(dep) and dep in deps
            cand={'siren':c['siren'],'name':nm,'score':round(sc,3),'dep_match':dep_ok,'siege_city':(c.get('siege') or {}).get('libelle_commune'),'etat':c.get('etat_administratif'),'naf':c.get('activite_principale'),'nature':c.get('nature_juridique'),'created':c.get('date_creation')}
            if not best or (cand['score']+0.2*dep_ok)>(best['score']+0.2*best['dep_match']): best=cand
        if best and best['score']>=0.9 and (best['dep_match'] or not dep): break
    conf='low'
    no_dep=not dep
    if best:
        if best['score']>=0.95 and best['dep_match']: conf='high'
        elif best['score']>=0.95 and no_dep: conf='low'
        elif best['score']>=0.8: conf='medium'
    json.dump({'organisation':name,'departement':dep,'category':r['category'],'best':best,'confidence':conf},open(fn,'w'),ensure_ascii=False)
    print(conf.ljust(6),name[:50].ljust(50),dep,'->',(best or {}).get('siren'),(best or {}).get('name','')[:45],(best or {}).get('score'),flush=True)
