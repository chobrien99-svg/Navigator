#!/usr/bin/env python3
"""
Build a draft mapping from Crunchbase sectors → Navigator canonical sectors,
based on the 2022 funding CSV. Outputs:
  - data/crunchbase_sector_mapping_draft.tsv  (Crunchbase term \t mapped sector \t count)

The user reviews / edits this TSV before the importer is run. Unmapped
sectors are left blank in the TSV — those will be dropped at import time
unless the user fills them in.
"""

import csv
from collections import Counter
from pathlib import Path

CSV_PATH = Path('/root/.claude/uploads/65193a0e-5069-4ea5-82ec-ac9053d3de99/0d9a8940-ftfunding2022Crunchbase__ftfunding2022DecemberCrunchbase.csv')
OUT_TSV = Path('data/crunchbase_sector_mapping_draft.tsv')


# Crunchbase term (lowercased) → Navigator canonical sector name
# Comments next to each line explain the call. Anything not in this dict
# is left blank for the user to decide.
MAP = {
    # Artificial Intelligence
    'artificial intelligence (ai)': 'Artificial Intelligence',
    'machine learning': 'Artificial Intelligence',
    'generative ai': 'Artificial Intelligence',
    'deep learning': 'Artificial Intelligence',
    'natural language processing': 'Artificial Intelligence',
    'computer vision': 'Artificial Intelligence',
    'ai infrastructure': 'Artificial Intelligence',
    'agentic ai': 'Artificial Intelligence',
    'predictive analytics': 'Artificial Intelligence',
    'ai trust and safety': 'Artificial Intelligence',

    # AgriTech
    'agtech': 'AgriTech',
    'agriculture': 'AgriTech',
    'farming': 'AgriTech',
    'animal feed': 'AgriTech',
    'aquaculture': 'AgriTech',
    'horticulture': 'AgriTech',
    'precision agriculture': 'AgriTech',

    # BioTech
    'biotechnology': 'BioTech',
    'bioinformatics': 'BioTech',
    'genetics': 'BioTech',
    'genomics': 'BioTech',
    'synthetic biology': 'BioTech',
    'life science': 'BioTech',
    'biopharma': 'BioTech',
    'pharmaceutical': 'BioTech',
    'biomass energy': 'BioTech',
    'drug discovery': 'BioTech',
    'therapeutics': 'BioTech',

    # CleanTech
    'cleantech': 'CleanTech',
    'clean energy': 'CleanTech',
    'solar': 'CleanTech',
    'wind energy': 'CleanTech',
    'hydroelectric': 'CleanTech',
    'energy efficiency': 'CleanTech',
    'renewable energy': 'CleanTech',
    'battery': 'CleanTech',
    'hydrogen': 'CleanTech',
    'smart cities': 'CleanTech',

    # ClimateTech
    'climate tech': 'ClimateTech',
    'climatetech': 'ClimateTech',
    'carbon capture': 'ClimateTech',
    'sustainability': 'ClimateTech',
    'environmental engineering': 'ClimateTech',
    'environmental consulting': 'ClimateTech',
    'green building': 'ClimateTech',
    'greentech': 'ClimateTech',

    # Cybersecurity
    'cyber security': 'Cybersecurity',
    'cybersecurity': 'Cybersecurity',
    'network security': 'Cybersecurity',
    'information security': 'Cybersecurity',
    'identity management': 'Cybersecurity',
    'fraud detection': 'Cybersecurity',
    'privacy': 'Cybersecurity',

    # DeepTech
    'quantum computing': 'DeepTech',
    'nanotechnology': 'DeepTech',
    'photonics': 'DeepTech',
    'materials science': 'DeepTech',
    'advanced materials': 'DeepTech',
    'semiconductor': 'DeepTech',

    # DefenseTech
    'defense': 'DefenseTech',
    'military': 'DefenseTech',
    'homeland security': 'DefenseTech',

    # Drones
    'drones': 'Drones',
    'uav': 'Drones',

    # E-commerce & Retail
    'e-commerce': 'E-commerce & Retail',
    'retail': 'E-commerce & Retail',
    'online portals': 'E-commerce & Retail',
    'shopping': 'E-commerce & Retail',
    'fashion': 'E-commerce & Retail',
    'beauty': 'E-commerce & Retail',
    'cosmetics': 'E-commerce & Retail',
    'apparel': 'E-commerce & Retail',
    'luxury': 'E-commerce & Retail',
    'jewelry': 'E-commerce & Retail',
    'consumer goods': 'E-commerce & Retail',
    'secondhand goods': 'E-commerce & Retail',

    # Energy (non-clean)
    'energy': 'Energy',
    'oil and gas': 'Energy',
    'energy storage': 'Energy',
    'energy management': 'Energy',
    'gas': 'Energy',
    'power grid': 'Energy',

    # Entertainment
    'entertainment': 'Entertainment',
    'music': 'Entertainment',
    'film': 'Entertainment',
    'video streaming': 'Entertainment',
    'streaming media': 'Entertainment',
    'podcast': 'Entertainment',
    'theatre': 'Entertainment',
    'performing arts': 'Entertainment',
    'video': 'Entertainment',
    'photography': 'Entertainment',
    'content creators': 'Entertainment',
    'media and entertainment': 'Entertainment',

    # FinTech
    'fintech': 'FinTech',
    'financial services': 'FinTech',
    'finance': 'FinTech',
    'banking': 'FinTech',
    'lending': 'FinTech',
    'payments': 'FinTech',
    'wealth management': 'FinTech',
    'asset management': 'FinTech',
    'personal finance': 'FinTech',
    'mobile payments': 'FinTech',
    'consumer lending': 'FinTech',
    'commercial lending': 'FinTech',
    'credit': 'FinTech',
    'credit cards': 'FinTech',
    'financial exchanges': 'FinTech',
    'trading platform': 'FinTech',

    # FoodTech
    'food and beverage': 'FoodTech',
    'food processing': 'FoodTech',
    'foodtech': 'FoodTech',
    'food delivery': 'FoodTech',
    'restaurants': 'FoodTech',
    'alternative protein': 'FoodTech',
    'nutrition': 'FoodTech',
    'organic food': 'FoodTech',
    'meat and poultry': 'FoodTech',
    'coffee': 'FoodTech',
    'craft beer': 'FoodTech',
    'wine and spirits': 'FoodTech',
    'tea': 'FoodTech',
    'cooking': 'FoodTech',
    'catering': 'FoodTech',

    # Gaming
    'gaming': 'Gaming',
    'video games': 'Gaming',
    'mobile games': 'Gaming',
    'pc games': 'Gaming',
    'console games': 'Gaming',
    'casual games': 'Gaming',
    'esports': 'Gaming',
    'online games': 'Gaming',
    'fantasy sports': 'Gaming',

    # Hardware
    'hardware': 'Hardware',
    'manufacturing': 'Hardware',
    'industrial automation': 'Hardware',
    'electronics': 'Hardware',
    'consumer electronics': 'Hardware',
    'industrial manufacturing': 'Hardware',
    'iot': 'Hardware',
    'internet of things': 'Hardware',
    '3d printing': 'Hardware',
    'sensor': 'Hardware',
    'electrical distribution': 'Hardware',
    'wearables': 'Hardware',

    # HealthTech
    'health care': 'HealthTech',
    'medical': 'HealthTech',
    'medical device': 'HealthTech',
    'digital health': 'HealthTech',
    'telehealth': 'HealthTech',
    'mhealth': 'HealthTech',
    'health diagnostics': 'HealthTech',
    'wellness': 'HealthTech',
    'mental health': 'HealthTech',
    'fitness': 'HealthTech',
    'dental': 'HealthTech',
    'home health care': 'HealthTech',
    'hospital': 'HealthTech',
    'elder care': 'HealthTech',
    'baby': 'HealthTech',
    'health insurance': 'HealthTech',
    'electronic health record (ehr)': 'HealthTech',
    'medical professionals': 'HealthTech',
    'veterinary': 'HealthTech',

    # InsurTech
    'insurtech': 'InsurTech',
    'insurance': 'InsurTech',
    'property insurance': 'InsurTech',

    # LegalTech
    'legaltech': 'LegalTech',
    'legal': 'LegalTech',
    'law enforcement': 'LegalTech',
    'compliance': 'LegalTech',
    'governance': 'LegalTech',

    # MarTech
    'advertising': 'MarTech',
    'digital marketing': 'MarTech',
    'marketing': 'MarTech',
    'marketing automation': 'MarTech',
    'adtech': 'MarTech',  # also new sector 'AdTech' — we have both now
    'brand marketing': 'MarTech',
    'content marketing': 'MarTech',
    'email marketing': 'MarTech',
    'crm': 'MarTech',
    'lead generation': 'MarTech',
    'search engine': 'MarTech',
    'seo': 'MarTech',
    'social media marketing': 'MarTech',
    'public relations': 'MarTech',

    # MedTech
    'medical device': 'MedTech',
    'surgery': 'MedTech',

    # Mobility
    'automotive': 'Mobility',
    'electric vehicle': 'Mobility',
    'autonomous vehicles': 'Mobility',
    'transportation': 'Mobility',
    'public transportation': 'Mobility',
    'mobility': 'Mobility',
    'ride sharing': 'Mobility',
    'fleet management': 'Mobility',
    'logistics': 'Mobility',
    'last mile transportation': 'Mobility',
    'shipping': 'Mobility',
    'delivery': 'Mobility',
    'parking': 'Mobility',
    'bicycles': 'Mobility',

    # PropTech
    'real estate': 'PropTech',
    'property management': 'PropTech',
    'construction': 'PropTech',
    'proptech': 'PropTech',
    'architecture': 'PropTech',
    'commercial real estate': 'PropTech',
    'residential': 'PropTech',
    'rental property': 'PropTech',
    'building material': 'PropTech',
    'interior design': 'PropTech',
    'home renovation': 'PropTech',
    'home decor': 'PropTech',
    'smart home': 'PropTech',

    # Robotics
    'robotics': 'Robotics',
    'industrial automation robotics': 'Robotics',

    # SaaS
    'saas': 'SaaS',
    'software': 'SaaS',
    'enterprise software': 'SaaS',
    'b2b': 'SaaS',
    'cloud computing': 'SaaS',
    'cloud infrastructure': 'SaaS',
    'cloud data services': 'SaaS',
    'cloud management': 'SaaS',
    'cloud security': 'SaaS',
    'cloud storage': 'SaaS',
    'apps': 'SaaS',
    'mobile apps': 'SaaS',
    'information services': 'SaaS',
    'information technology': 'SaaS',
    'analytics': 'SaaS',
    'big data': 'SaaS',
    'business intelligence': 'SaaS',
    'data integration': 'SaaS',
    'data visualization': 'SaaS',
    'database': 'SaaS',
    'developer apis': 'SaaS',
    'developer platform': 'SaaS',
    'developer tools': 'SaaS',
    'enterprise applications': 'SaaS',
    'enterprise resource planning (erp)': 'SaaS',
    'erp': 'SaaS',
    'open source': 'SaaS',
    'productivity tools': 'SaaS',
    'project management': 'SaaS',
    'software engineering': 'SaaS',
    'web development': 'SaaS',
    'mobile': 'SaaS',
    'collaboration': 'SaaS',
    'document management': 'SaaS',
    'human resources': 'SaaS',
    'recruiting': 'SaaS',
    'accounting': 'SaaS',
    'billing': 'SaaS',
    'customer service': 'SaaS',
    'sales': 'SaaS',

    # SpaceTech & Aerospace
    'aerospace': 'SpaceTech & Aerospace',
    'space travel': 'SpaceTech & Aerospace',
    'satellite': 'SpaceTech & Aerospace',
    'satellite communication': 'SpaceTech & Aerospace',
    'aviation and aerospace': 'SpaceTech & Aerospace',
    'aviation': 'SpaceTech & Aerospace',

    # TravelTech
    'travel': 'TravelTech',
    'tourism': 'TravelTech',
    'hospitality': 'TravelTech',
    'hotel': 'TravelTech',
    'vacation rental': 'TravelTech',
    'travel agency': 'TravelTech',
    'leisure': 'TravelTech',

    # Web3
    'blockchain': 'Web3',
    'cryptocurrency': 'Web3',
    'web3': 'Web3',
    'nft': 'Web3',
    'defi': 'Web3',
    'crypto': 'Web3',
    'digital currency': 'Web3',
    'metaverse': 'Web3',

    # SportsTech
    'sports': 'SportsTech',

    # Circular Economy / Recycling
    'recycling': 'Recycling',
    'waste management': 'Recycling',
    'circular economy': 'Circular Economy',

    # EdTech (new canonical sector — added at user request)
    'edtech': 'EdTech',
    'education': 'EdTech',
    'e-learning': 'EdTech',
    'training': 'EdTech',
    'corporate training': 'EdTech',
    'tutoring': 'EdTech',
    'higher education': 'EdTech',
    'primary education': 'EdTech',
    'secondary education': 'EdTech',
    'language learning': 'EdTech',
    'continuing education': 'EdTech',
    'mooc': 'EdTech',
    'stem education': 'EdTech',

    # Digital Health
    'digital health': 'Digital Health',  # also mapped to HealthTech above — first wins
}


def main() -> None:
    with open(CSV_PATH) as f:
        rows = list(csv.DictReader(f))
    # Drop Institut Mérieux first row
    rows = [r for r in rows
            if not (r['Organization Name'].strip() == 'Institut Merieux'
                    and r['Funding Type'].strip() == 'Private Equity')]

    counts = Counter()
    for r in rows:
        for s in (r['Sectors'] or '').split(','):
            s = s.strip()
            if s:
                counts[s] += 1

    rows_out = []
    for term, cnt in counts.most_common():
        mapped = MAP.get(term.lower(), '')
        rows_out.append((cnt, term, mapped))

    OUT_TSV.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_TSV, 'w') as f:
        f.write("count\tcrunchbase_term\tcanonical_sector\n")
        for cnt, term, mapped in rows_out:
            f.write(f"{cnt}\t{term}\t{mapped}\n")

    mapped_count = sum(1 for _, _, m in rows_out if m)
    print(f"Total unique Crunchbase sectors: {len(rows_out)}")
    print(f"Auto-mapped: {mapped_count} ({100*mapped_count//len(rows_out)}%)")
    print(f"Unmapped (blank): {len(rows_out) - mapped_count}")
    print(f"\nWritten to: {OUT_TSV}")

    # Coverage in terms of rows: of all sector occurrences, what fraction has a mapping?
    total_occurrences = sum(cnt for cnt, _, _ in rows_out)
    mapped_occurrences = sum(cnt for cnt, _, m in rows_out if m)
    print(f"\nOccurrence coverage: {mapped_occurrences:,} / {total_occurrences:,} "
          f"({100*mapped_occurrences//total_occurrences}%)")


if __name__ == '__main__':
    main()
