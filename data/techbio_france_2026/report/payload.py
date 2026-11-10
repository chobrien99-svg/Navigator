import json,statistics as st,collections as C,sys
D=sys.argv[1]; S=json.load(open(D+'/an/summary.json')); R=json.load(open(D+'/an/rounds.json'))
SEGS=['Biology foundation models & data platforms','AI drug & molecule design','Synthetic biology & genetic medicine','Precision medicine & diagnostics','Lab tech: organ-on-chip, microfluidics, bioprinting, cell models']
SHORT={SEGS[0]:'Foundation models & data',SEGS[1]:'AI drug & molecule design',SEGS[2]:'Synthetic biology & genetic medicine',SEGS[3]:'Precision medicine & diagnostics',SEGS[4]:'Lab tech & cell models'}
IDF=('75','77','78','91','92','93','94','95')
cos=[]
for s,o in S.items():
  cp=o['cp'] or ''
  region='Île-de-France' if (cp[:2] in IDF if cp else o['city'] in ('Paris',)) else 'Regions'
  if s=='deeplife': region='Regions'  # Vernon (Normandy) per DB city
  name={'CHERRY BIOTECH':'Cherry Biotech','NETRI':'Netri','POIETIS':'Poietis','THEREMIA':'Theremia','EUKARYS':'Eukarÿs','INFOCUS THERAPEUTICS SAS':'InFocus Therapeutics','MAbSilico SAS':'MAbSilico','NEBULA':'Nebula','Spore Biotechnologies':'Spore.Bio','EndoGene.Bio':'Endogene.bio','Ariana Pharmaceuticals':'Ariana Pharma'}.get(o['name'],o['name'])
  cos.append(dict(slug=s,name=name,seg=SHORT[o['seg']],total=round(o['total'],2),grant=round(o['grant_total'],2),n=o['nrounds'],last=o['last'],stage=o['latest_stage'],fy=o['fy'],region=region,hq=(o['hq'] or o['city'] or '').title(),inv=[i for i in o['investors']],status=o['status']))
years=[]
for y in range(2015,2027):
  rs=[r for r in R if r['year']==y and r['stage']!='grant']
  years.append(dict(y=y,n=len(rs),eur=round(sum(r['eur'] or 0 for r in rs),1),big=sorted([(S[r['org']]['name'],r['eur']) for r in rs if r['eur']],key=lambda x:-x[1])[:3]))
stages=[]
for k,lab in [('pre_seed','Pre-seed'),('seed','Seed'),('series_a','Series A'),('series_b','Series B'),('series_c','Series C')]:
  v=[r['eur'] for r in R if r['eur'] and r['stage']==k]
  stages.append(dict(k=lab,n=len(v),med=round(st.median(v),2),min=min(v),max=max(v)))
NM={'CHERRY BIOTECH':'Cherry Biotech','THEREMIA':'Theremia','EndoGene.Bio':'Endogene.bio','Spore Biotechnologies':'Spore.Bio'}
P=C.defaultdict(set); L=C.defaultdict(set); NR=C.Counter()
for r in R:
  for i in r['inv']:
    P[i].add(r['org']); NR[i]+=1
  for i in r['lead']: L[i].add(r['org'])
TYPE={'Bpifrance':'Public bank','Kima Ventures':'Seed VC','Entrepreneurs First':'Talent incubator','Sofinnova Partners':'Life-sciences VC','Better Angle':'Seed VC','HCVC':'Deeptech VC','Eurazeo':'Multi-strategy','Galion.exe':'Founder-led VC','Omnes Capital':'Multi-strategy','Debiopharm Innovation Fund':'Pharma CVC','Alven':'Tech VC','Breega':'Tech VC','Daphni':'Tech VC','EIC Accelerator':'EU programme','EIC Fund':'EU fund','Hitachi Ventures':'Corporate VC','Kurma Partners':'Life-sciences VC','Singular':'Tech VC','Blast Club':'Angel club','Cathay Innovation':'Tech VC','M Ventures':'Pharma CVC','Quantonation':'Deeptech VC','Station F':'Campus','Plug and Play':'Accelerator','Tiny Supercomputer Investment Company':'Seed VC','NJF Capital':'Family office','Mehdi Ghissassi':'Angel'}
inv=[dict(name=n,cos=len(c),leads=len(L[n]),rounds=NR[n],type=TYPE.get(n,''),list=sorted(NM.get(S[x]['name'],S[x]['name']) for x in c)) for n,c in P.items() if n!='Business Angels' and len(c)>=2]
inv.sort(key=lambda x:(-x['cos'],-x['leads'],x['name']))
json.dump(dict(cos=cos,years=years,stages=stages,inv=inv,segs=[SHORT[s] for s in SEGS]),open(D+'/an/payload.json','w'),ensure_ascii=False)
print(len(cos),len(inv),[ (y['y'],y['n'],y['eur']) for y in years])
