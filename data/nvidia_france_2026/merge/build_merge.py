"""Cross-match the public-records run (data/nvidia_france_2026) with the FTJ Ghost
archive run (docs/handoffs/nvidia-ghost-coverage-2026-11-12). Run: python3 -I build_merge.py"""
import json, re, csv, os
H = os.path.join(os.path.dirname(__file__), '..', '..', '..', 'docs', 'handoffs', 'nvidia-ghost-coverage-2026-11-12', 'nvidia_articles.json')
A = json.load(open(H))
# Findings from the public-records run (category, finding, regex searched in FTJ snippets)
F = [
 ('investment','Moon Surgical Series B (NVentures co-lead, 2023)',r'Moon Surgical'),
 ('investment','Hugging Face Series D (2023)',r'Hugging Face.{0,400}(235|Series D)|(235|Series D).{0,400}Hugging Face'),
 ('investment','Mistral AI rounds (2024, 2025, 2026)',r'Mistral.{0,300}(Series B|Series C|Series D|€3 ?b|\$2 ?b|round|invest)'),
 ('investment','Poolside Series B (2024) / reported $1bn follow-on',r'Poolside'),
 ('investment','Scintil Photonics Series B (2025)',r'Scintil'),
 ('investment','AMI Labs seed (2026)',r'AMI Labs|AMI launched|LeCun|Website: AMI'),
 ('investment','Alice & Bob (NVentures, 2026)',r'Alice ?& ?Bob'),
 ('investment','Gradium seed extension (2026)',r'Gradium'),
 ('investment','Pigment Series E (2026)',r'Pigment'),
 ('investment','Doctolib stake (Oct 2026)',r'Doctolib'),
 ('investment','Entalpic stake (Oct 2026)',r'Entalpic'),
 ('investment','Genesis AI stake (Oct 2026)',r'Genesis AI'),
 ('acquisition','Hugging Face acquisition agreement (Sep 2026)',r'(buy|buying|acquire|bought).{0,120}Hugging Face|Hugging Face.{0,250}(12\.9|\$14 b|being bought|prize)'),
 ('presence','NVIDIA Développement France / Sophia Antipolis R&D',r'Sophia|Antipolis|Développement France|Icera'),
 ('research','EU research projects with NVIDIA',r'Horizon|CORDIS|EU-funded|European Commission.{0,100}project'),
 ('research','HAL co-authored papers / CNRS / Inria',r'Inria|CNRS'),
 ('research','GPU donations to researchers',r'donat|grant program|hardware grant'),
 ('compute','Jean Zay supercomputer (H100)',r'Jean Zay|GENCI|IDRIS'),
 ('compute','Dalia (GENCI GB200)',r'Dalia'),
 ('compute','Ifremer DGX A100 purchase',r'Ifremer'),
 ('compute','Asgard defence supercomputer',r'defen[cs]e.{0,200}supercomput|Asgard|AMIAD|Ministry of (the )?Armed'),
 ('compute','Scaleway / Iliad DGX SuperPOD',r'Scaleway|Iliad'),
 ('compute','Mistral Compute (18,000 Grace Blackwell)',r'Mistral Compute|18,000'),
 ('compute','Campus IA (MGX/Bpifrance/Mistral)',r'MGX|campus'),
 ('compute','TotalEnergies Pangea 5',r'TotalEnergies|Pangea'),
 ('compute','Bull Angers / Vera Rubin',r'Bull|Angers|Vera Rubin'),
 ('programme','Inception / AI Factory France',r'Inception|AI Factory France|AI2F'),
 ('programme','Sofinnova DGX Cloud credits',r'Sofinnova'),
 ('partnership','Dassault Systèmes',r'Dassault Syst'),
 ('partnership','Schneider Electric',r'Schneider'),
 ("partnership","L'Oréal",r"L.Or[ée]al"),
 ('partnership','Quantum (Pasqal, Quandela, CUDA-Q)',r'Pasqal|Quandela|CUDA-Q|NVQLink'),
 ('partnership','Owkin',r'Owkin'),
 ('partnership','Wandercraft',r'Wandercraft'),
 ('partnership','Nemotron (Mistral / H Company / Pleias)',r'Nemotron|Pleias|H Company'),
 ('influence','HATVP lobbying on Arm takeover (Brunswick)',r'\bArm\b.{0,80}(acqui|takeover|deal|bid)|Brunswick|HATVP'),
 ('influence','Macron / Élysée',r'Macron|Élysée|Elysee'),
 ('influence','Jensen Huang resignation (12 Nov 2026)',r'resign|step(s|ped)? down|Alice Huang|Megaspeed'),
]
rows = []
for cat, name, pat in F:
    hits = [a for a in A if not a['boilerplate_only'] and any(re.search(pat, s, re.I) for s in a['snippets'])]
    hits.sort(key=lambda a: a['published_at'])
    rows.append(dict(category=cat, finding=name, ftj_posts=len(hits),
        first=hits[0]['published_at'][:10] if hits else '', last=hits[-1]['published_at'][:10] if hits else '',
        example_url=hits[-1]['url'] if hits else '', example_title=hits[-1]['title'] if hits else '',
        ghost_ids=';'.join(a['ghost_id'] for a in hits)))
out = os.path.dirname(__file__)
with open(os.path.join(out, 'coverage_matrix.csv'), 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
for r in rows: print(f"{r['ftj_posts']:>3}  {r['category']:<12} {r['finding']:<52} {r['first']} → {r['last']}")
