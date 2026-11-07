import re,sys,json,glob,os
CATS={'GE','Catégorie Non Transmise','Etat','État','Grande Entreprise','Grandes Entreprises','Collectivités territoriales','PME','ETI','Grande entreprise','Grandes entreprises','Etablissements de recherche','Etablissements publics','Etablissement public','Associations','Association','Collectivités','Collectivité territoriale','Startup','Start-up','TPE','Autres','Autre','Entreprise','Etablissements d\'enseignement supérieur','Etablissements de santé','Groupement','Organismes de recherche'}
def parse(txt,page):
    lines=[l.strip() for l in txt.splitlines() if len(l.strip())>1]
    out=[];i=0
    while i<len(lines):
        if lines[i] in CATS:
            cat=lines[i]; j=i+1; block=[]
            while j<len(lines) and not lines[j].startswith('Objectif'):
                block.append(lines[j]); j+=1
            if j>=len(lines): break
            # objective may span 2 lines; city line follows
            k=j+1
            while k<len(lines) and not re.search(r'\(\s*(\d{2}|2A|2B|97\d)\s*\)\s*$',lines[k]) and lines[k] not in CATS: k+=1
            city=lines[k] if k<len(lines) and lines[k] not in CATS else None
            m=re.match(r'(.*)\(\s*(\d{2,3}|2A|2B)\s*\)\s*$',city or '')
            if len(block)>=2:
                cut=next((n for n,b in enumerate(block) if n>0 and re.search(r'[a-zà-ÿ]',b)),len(block)-1)
                out.append({'category':cat,'organisation':' '.join(block[:cut]),'project':' '.join(block[cut:]),'town':m.group(1).strip() if m else None,'departement':m.group(2) if m else None,'page':page})
            elif block:
                out.append({'category':cat,'organisation':block[0],'project':None,'town':m.group(1).strip() if m else None,'departement':m.group(2) if m else None,'page':page,'note':'only one text line: unclear whether organisation or project; no town shown'})
            i=k+1 if city else k
        else: i+=1
    return out
rows=[]
for f in sorted(glob.glob(sys.argv[1]+'/pdfs/smr_*.txt')):
    rows+=parse(open(f).read(),int(re.search(r'smr_(\d+)',f).group(1)))
seen=set();ded=[]
for r in rows:
    k=(r['organisation'],r['project'],r['town'])
    if k in seen: r['duplicate']=True
    else: seen.add(k); ded.append(r)
json.dump(ded,open(sys.argv[1]+'/smr_laureates_p3-7.json','w'),ensure_ascii=False,indent=1)
print('parsed',len(rows),'unique',len(ded))
import collections as C
print(C.Counter(r['category'] for r in ded)); print('per page',C.Counter(r['page'] for r in rows))
print('missing town',sum(1 for r in ded if not r['town']),'missing project',sum(1 for r in ded if not r['project']))
