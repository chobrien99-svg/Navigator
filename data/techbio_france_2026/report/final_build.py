import json,collections
S='/tmp/claude-0/-home-user-Navigator/8db78c46-1762-56f2-8a79-dbef8001092b/scratchpad/'
D='/home/user/Navigator/data/techbio_france_2026/'
P=json.load(open(S+'an/payload.json')); R=json.load(open(S+'an/research.json'))
# Patent families per company after the INPI run (DB, 9 Nov 2026): n, filed 2024+
PAT={'dna-script':(66,3),'eligo-bioscience':(30,0),'qubit-pharmaceuticals':(16,9),'owkin':(12,3),'poietis':(12,0),'netri':(12,5),'cherry-biotech':(8,2),'spore-biotechnologies':(4,2),'peaccel':(3,0),'eukarys':(3,0),'ariana-pharmaceuticals':(3,0),'iktos':(3,2),'endogenebio':(3,2),'aqemia':(2,1),'hyprview':(2,0),'one-biosciences':(2,1),'scienta-lab':(2,1),'deeplife':(2,1),'inspek':(2,1),'orakl-oncology':(2,2),'whitelab-genomics':(2,1),'okomera':(1,0),'ai-biopharma':(1,0),'generare':(1,0),'ksilink':(1,1)}
# Public-research co-owners (DB partnered_with 'Patent co-applicant'), companies/corporates excluded
CO={'ariana-pharmaceuticals':['Inserm','AP-HP','CNRS'],'cherry-biotech':['BioSense Institute (Serbia)'],'dna-script':['CNRS','Institut Pasteur'],'eligo-bioscience':['Institut Pasteur','Kantonsspital St Gallen (Switzerland)'],'iktos':['Inserm','Université d’Évry'],'one-biosciences':['CNRS','Sorbonne Université','Institut Curie','Gustave Roussy','Université Paris-Saclay'],'owkin':['Centre Léon Bérard'],'poietis':['Inserm','Université de Bordeaux','CHU de Bordeaux','Fondation Bordeaux Université','KU Leuven'],'qubit-pharmaceuticals':['CNRS','Sorbonne Université'],'whitelab-genomics':['Généthon'],'ksilink':['CECS / I-Stem','CNRS','Inserm','Sorbonne Université','Université d’Évry']}
for r in R['rows']:
    n,rec=PAT.get(r['slug'],(0,0)); r['fams']=n; r['recent']=rec; r['co']=CO.get(r['slug'],[])
# EU grants (scanR/CORDIS, company share)
eu=json.load(open(S+'eu_grants.json')); EU=collections.defaultdict(lambda:{'eur':0,'n':0,'eic':0,'eic_eur':0,'list':[]})
for g in eu:
    e=EU[g['org']]; e['eur']+=g['amt']; e['n']+=1; e['list'].append(g['name'].split(' – ',1)[1])
    if 'EIC' in g['name'] or 'SME Instrument' in g['name']: e['eic']+=1; e['eic_eur']+=g['amt']
names={c['slug']:c['name'] for c in P['cos']}; segs={c['slug']:c['seg'] for c in P['cos']}
eurows=sorted([dict(slug=k,name=names[k],seg=segs[k],eur=round(v['eur']/1e6,2),n=v['n'],eic=round(v['eic_eur']/1e6,2),list=v['list']) for k,v in EU.items()],key=lambda x:-x['eur'])
# ANR
anr=json.load(open(D+'anr_complete.json'))['anr']; AF=collections.defaultdict(float); AC=collections.defaultdict(float)
for s,rows in anr.items():
    for x in rows:
        if x.get('confidence')=='low': continue
        (AF if x['via']=='founder' else AC)[s]+=x.get('aid_partner_eur') or 0
CIR={'ksilink':'CIR 2023–25','ariana-pharmaceuticals':'CIR 2010–12, 2025–27','parean-biotechnologies':'CIR 2021–26','qubit-pharmaceuticals':'CIR 2021–23','medinsights':'CIR + CII 2025–27','ai-biopharma':'CIR 2018–20','poietis':'CIR 2015–19','insilibio':'CIR + CII 2025–27','iktos':'CIR 2018–20','netri':'CIR 2023–25'}
pub=[]
for s in names:
    pub.append(dict(slug=s,name=names[s],seg=segs[s],eu=round(EU[s]['eur']/1e6,2) if s in EU else 0,anr_f=round(AF.get(s,0)/1e6,2),anr_c=round(AC.get(s,0)/1e6,2),cir=CIR.get(s,'')))
pub=[p for p in pub if p['eu'] or p['anr_f'] or p['anr_c'] or p['cir']]
pub.sort(key=lambda p:-(p['eu']+p['anr_c']))
COURT=[dict(slug='ksilink',name='Ksilink',what='Judicial liquidation',date='2026-09-28',note='Safeguard (June 2026), then receivership (July), then liquidation (28 Sept 2026)'),
 dict(slug='iktos',name='Iktos',what='Receivership',date='2026-10-06',note='Cessation of payments 18 Sept 2026; Paris court'),
 dict(slug='ariana-pharmaceuticals',name='Ariana Pharma',what='Receivership',date='2026-09-08',note='Cessation of payments 31 July 2026; observation period to 8 March 2027'),
 dict(slug='poietis',name='Poietis',what='Judicial liquidation',date='2025-01-22',note='Receivership July 2024; sale plan for the business approved 21 Jan 2025')]
cs={c['slug']:c for c in P['cos']}
cs['poietis']['status']='inactive'
for c in COURT: cs[c['slug']]['court']=c['what']
R['eu']=eurows; R['pub']=pub; R['court']=COURT
json.dump(P,open(S+'an/payload2.json','w'),ensure_ascii=False); json.dump(R,open(S+'an/research2.json','w'),ensure_ascii=False)
w=[r for r in R['rows'] if r['fams']]
print('cos w patents',len(w),'fams',sum(r['fams'] for r in w),'recent',sum(r['recent'] for r in w),'top2',(66+30)/sum(r['fams'] for r in w))
print('EU',round(sum(e['eur'] for e in eurows),2),len(eurows),'EIC acc', [ (e['name'],e['eic']) for e in eurows if e['eic']])
seg=collections.defaultdict(int)
for r in w: seg[r['seg']]+=r['fams']
print(dict(seg)); print('co-owned public',sum(1 for r in R['rows'] if r['co']))
print('AI-first fams', [(r['name'],r['fams']) for r in w if r['seg']=='Foundation models & data'])
