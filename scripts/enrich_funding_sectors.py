#!/usr/bin/env python3
"""
Enrich the 2024 funding CSV with secondary/tertiary sector tags.

Reads the company description and name, matches keyword patterns
against the 28 canonical Navigator sectors, and adds up to 2
additional sector tags per row (beyond the primary).

Output:
  data/funding_2024_v2_enriched.csv
"""

import csv
import re
from pathlib import Path

INPUT = Path('data/funding_2024_v2.csv')
OUTPUT = Path('data/funding_2024_v2_enriched.csv')

# Canonical sector → keyword patterns
# Order matters: more specific sectors come first
SECTOR_PATTERNS = {
    "Artificial Intelligence": [
        r'\bai\b', r'artificial intelligence', r'machine learning',
        r'\bllm\b', r'large language model', r'generative', r'neural network',
        r'deep learning', r'computer vision', r'\bnlp\b',
        r'foundation model', r'foundational ai',
    ],
    "HealthTech": [
        r'\bhealth\b', r'patient', r'healthcare', r'wellness',
        r'clinical', r'telemedicine', r'digital health',
        r'mental health', r'care\b',
    ],
    "MedTech": [
        r'medical device', r'surgical', r'surgery', r'diagnostic',
        r'imaging', r'radiolog', r'prosthe',
    ],
    "BioTech": [
        r'biotech', r'\bdrug\b', r'therapeutic', r'pharmaceut',
        r'clinical trial', r'gene therapy', r'cell therapy',
        r'molecule', r'protein', r'enzyme', r'microbiome',
        r'biolog', r'genom',
    ],
    "FinTech": [
        r'fintech', r'payment', r'banking', r'lending', r'credit card',
        r'financial service', r'neobank', r'wealth management',
        r'capital markets', r'\bloan\b',
    ],
    "InsurTech": [
        r'insurtech', r'insurance', r'insurer', r'underwrit', r'\bpolicy\b.{0,30}\binsur',
    ],
    "CleanTech": [
        r'cleantech', r'carbon', r'climate', r'sustainab',
        r'decarboni', r'emission', r'recycl', r'circular econom',
        r'greenhouse', r'\beco\b',
    ],
    "Energy": [
        r'\benergy\b', r'electricity', r'\bsolar\b', r'\bwind\b',
        r'nuclear', r'\bbattery\b', r'storage.{0,15}grid', r'power grid',
        r'renewable', r'hydrogen', r'geothermal', r'photovoltaic',
    ],
    "SpaceTech & Aerospace": [
        r'\bspace\b', r'satellite', r'\brocket\b', r'launch vehicle',
        r'\borbit\b', r'aerospace', r'aeronautic', r'\bmoon\b', r'\bmars\b',
    ],
    "Drones": [
        r'\bdrone\b', r'\buav\b', r'unmanned aerial',
    ],
    "Robotics": [
        r'robot', r'robotic', r'automation', r'cobot',
    ],
    "Mobility": [
        r'mobility', r'transport', r'vehicle', r'automotive',
        r'\bcar\b', r'scooter', r'\bbike\b', r'\bfleet\b',
        r'electric vehicle', r'\bev\b.{0,10}charg', r'charging infrastructure',
        r'ride.?sharing', r'rideshar', r'\btruck', r'delivery',
        r'logistic',
    ],
    "AgriTech": [
        r'agritech', r'agriculture', r'\bfarm', r'crop', r'livestock',
        r'agronom', r'vineyard', r'orchard',
    ],
    "FoodTech": [
        r'foodtech', r'\bfood\b', r'alternative protein', r'plant.based',
        r'cultivated meat', r'dairy', r'beverage', r'restaurant',
        r'cuisine',
    ],
    "PropTech": [
        r'proptech', r'real estate', r'property management', r'rental',
        r'\bhome\b.{0,20}(sale|rent|buy)', r'construction tech', r'smart building',
    ],
    "MarTech": [
        r'martech', r'marketing', r'advertising', r'\badtech\b',
        r'brand management', r'social media', r'influencer',
        r'\bseo\b', r'content market',
    ],
    "E-commerce & Retail": [
        r'e.?commerce', r'marketplace', r'retail', r'\bshop\b',
        r'consumer good', r'\bdtc\b', r'direct.to.consumer',
        r'online store', r'second.?hand', r'refurbish',
    ],
    "Cybersecurity": [
        r'cybersecurity', r'cyber.?security', r'\bthreat\b',
        r'vulnerability', r'data protection', r'encryption',
        r'intrusion', r'firewall', r'security platform',
    ],
    "Web3": [
        r'blockchain', r'\bcrypto\b', r'web3', r'\bnft\b',
        r'\bdefi\b', r'\bdao\b', r'tokeniz', r'smart contract',
    ],
    "Gaming": [
        r'gaming', r'video game', r'esport', r'game developer',
        r'game studio', r'mobile game',
    ],
    "Entertainment": [
        r'entertainment', r'\bmedia\b', r'streaming', r'\bmusic\b',
        r'\bfilm\b', r'television', r'podcast',
    ],
    "Hardware": [
        r'hardware', r'\bchip\b', r'semiconductor', r'\bsensor\b',
        r'\bwafer\b', r'microcontroller', r'processor',
    ],
    "DeepTech": [
        r'quantum', r'photonic', r'materials science', r'nanotech',
        r'fusion\b.{0,10}(energy|power|reactor)',
    ],
    "DefenseTech": [
        r'defense', r'defence', r'military', r'tactical', r'\bweapon',
    ],
    "LegalTech": [
        r'legaltech', r'\blegal\b', r'\blaw\b', r'contract management',
        r'compliance', r'litigation',
    ],
    "TravelTech": [
        r'traveltech', r'travel', r'tourism', r'\bbooking\b', r'hotel',
        r'\bflight\b', r'\btrip\b',
    ],
    "SaaS": [
        r'\bsaas\b', r'software.as.a.service', r'b2b software',
        r'enterprise software', r'workflow', r'productivity',
    ],
}

# Stop words — avoid these matching as sector indicators
def compile_patterns():
    return {
        sector: [re.compile(p, re.IGNORECASE) for p in patterns]
        for sector, patterns in SECTOR_PATTERNS.items()
    }


def detect_sectors(text: str, compiled) -> list[tuple[str, int]]:
    """Return sorted list of (sector, match_count) for sectors that match."""
    matches = []
    for sector, patterns in compiled.items():
        count = sum(1 for p in patterns if p.search(text))
        if count > 0:
            matches.append((sector, count))
    # Sort by match count desc
    return sorted(matches, key=lambda x: -x[1])


def main():
    compiled = compile_patterns()

    with open(INPUT) as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    # Column order: keep original, add secondary_sector and tertiary_sector after official_sector
    original_fields = [k for k in rows[0].keys() if k != '']
    # Insert after official_sector
    new_fields = []
    for f in original_fields:
        new_fields.append(f)
        if f == 'official_sector':
            new_fields.append('secondary_sector')
            new_fields.append('tertiary_sector')

    stats = {
        'total': len(rows),
        'with_secondary': 0,
        'with_tertiary': 0,
        'no_additional': 0,
    }

    enriched = []
    for row in rows:
        primary = (row.get('official_sector') or '').strip()
        description = (row.get('description') or '').strip()
        company = (row.get('company') or '').strip()

        # Combined text for matching
        text = f"{company} {description}".lower()

        detected = detect_sectors(text, compiled)
        # Remove the primary from candidates
        detected = [(s, c) for s, c in detected if s != primary]

        secondary = detected[0][0] if len(detected) >= 1 else ''
        tertiary = detected[1][0] if len(detected) >= 2 else ''

        if secondary:
            stats['with_secondary'] += 1
        if tertiary:
            stats['with_tertiary'] += 1
        if not secondary:
            stats['no_additional'] += 1

        new_row = {f: row.get(f, '') for f in original_fields}
        new_row['secondary_sector'] = secondary
        new_row['tertiary_sector'] = tertiary
        enriched.append(new_row)

    # Write output
    with open(OUTPUT, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=new_fields)
        writer.writeheader()
        writer.writerows(enriched)

    print(f"Wrote {len(enriched)} enriched rows to {OUTPUT}")
    print()
    print("Statistics:")
    print(f"  Rows with secondary sector: {stats['with_secondary']} ({stats['with_secondary']*100//stats['total']}%)")
    print(f"  Rows with tertiary sector:  {stats['with_tertiary']} ({stats['with_tertiary']*100//stats['total']}%)")
    print(f"  Rows with no additional:    {stats['no_additional']}")


if __name__ == '__main__':
    main()
