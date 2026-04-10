#!/usr/bin/env python3
"""
Scrape SIREN numbers from company 'mentions légales' pages.

French companies are required to display their SIREN on their website.
This script finds the legal page and extracts the SIREN number.
"""

import json
import re
import signal
import sys
import time
import urllib.request
import urllib.error
import ssl
from pathlib import Path


class TimeoutError(Exception):
    pass


def timeout_handler(signum, frame):
    raise TimeoutError("Request timed out")

# Common legal page URL patterns to try
LEGAL_PATHS = [
    "/mentions-legales",
    "/mentions-legales/",
    "/legal",
    "/legal/",
    "/legal-information",
    "/cgu",
    "/cgu/",
    "/terms",
    "/terms/",
    "/a-propos",
    "/about",
    "/about-us",
    "/imprint",
    "/impressum",
    "/cgv",
    "/conditions-generales",
    "/privacy",
    "/privacy-policy",
    "/politique-de-confidentialite",
    "/fr/mentions-legales",
    "/fr/legal",
    "/en/legal",
    "/en/legal-information",
]

# Regex patterns to find SIREN near identifying keywords
# SIREN is 9 digits, sometimes formatted with spaces (e.g., 908 311 103)
SIREN_PATTERNS = [
    # "SIREN: 123456789" or "Siren : 123 456 789"
    r'[Ss][Ii][Rr][Ee][Nn]\s*[:\s]\s*(\d[\d\s]{7,10}\d)',
    # "RCS Paris 123 456 789" or "R.C.S. Lyon B 123456789"
    r'R\.?C\.?S\.?\s+\w+\s+(?:B\s+)?(\d[\d\s]{7,10}\d)',
    # "immatricul...123456789"
    r'immatricul[ée]\w*\s+.*?(\d{3}\s?\d{3}\s?\d{3})',
    # "numéro...SIREN...123456789"
    r'num[ée]ro.*?(\d{3}\s\d{3}\s\d{3})',
    # Just a 9-digit number near "société" or "SAS" or "SARL" or "SA "
    r'(?:soci[ée]t[ée]|SAS|SARL|SA\s|SASU)\s+.*?(\d{3}\s?\d{3}\s?\d{3})',
]

# SSL context that doesn't verify (many startup sites have cert issues)
SSL_CTX = ssl.create_default_context()
SSL_CTX.check_hostname = False
SSL_CTX.verify_mode = ssl.CERT_NONE


def clean_siren(raw: str) -> str | None:
    """Remove spaces/dots and validate as 9 digits."""
    digits = re.sub(r'\D', '', raw)
    if len(digits) == 9:
        return digits
    if len(digits) == 14:  # SIRET — take first 9
        return digits[:9]
    return None


def luhn_check(siren: str) -> bool:
    """Validate SIREN with Luhn algorithm."""
    if len(siren) != 9 or not siren.isdigit():
        return False
    total = 0
    for i, ch in enumerate(siren):
        d = int(ch)
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return total % 10 == 0


def fetch_page(url: str, timeout: int = 5) -> str | None:
    """Fetch a page and return its text content. Hard timeout via signal."""
    try:
        # Set a hard 8-second deadline per page fetch
        old_handler = signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(8)
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'Mozilla/5.0 (compatible; NavigatorBot/1.0; SIREN lookup)',
                'Accept': 'text/html,application/xhtml+xml',
                'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.5',
            })
            with urllib.request.urlopen(req, timeout=timeout, context=SSL_CTX) as resp:
                content_type = resp.headers.get('Content-Type', '')
                if 'text' not in content_type and 'html' not in content_type:
                    return None
                raw = resp.read()
                for enc in ['utf-8', 'latin-1', 'iso-8859-1']:
                    try:
                        return raw.decode(enc)
                    except UnicodeDecodeError:
                        continue
                return raw.decode('utf-8', errors='replace')
        finally:
            signal.alarm(0)
            signal.signal(signal.SIGALRM, old_handler)
    except Exception:
        return None


def extract_siren(html: str) -> list[tuple[str, str]]:
    """Extract SIREN candidates from HTML text. Returns [(siren, pattern_used)]."""
    # Strip HTML tags for easier regex matching
    text = re.sub(r'<[^>]+>', ' ', html)
    text = re.sub(r'\s+', ' ', text)

    results = []
    seen = set()
    for pattern in SIREN_PATTERNS:
        for match in re.finditer(pattern, text, re.IGNORECASE):
            raw = match.group(1)
            siren = clean_siren(raw)
            if siren and siren not in seen:
                seen.add(siren)
                results.append((siren, pattern[:30]))
    return results


def find_siren_for_company(name: str, website: str) -> dict:
    """Try to find SIREN for a company by scraping its legal pages."""
    result = {
        'name': name,
        'website': website,
        'siren': None,
        'source_url': None,
        'luhn_valid': None,
        'method': None,
    }

    # Normalize base URL
    base = website.rstrip('/')
    if not base.startswith('http'):
        base = 'https://' + base

    # First try the homepage itself (some sites put mentions légales in footer)
    pages_to_try = [base] + [base + path for path in LEGAL_PATHS]

    for url in pages_to_try:
        html = fetch_page(url)
        if not html:
            continue

        candidates = extract_siren(html)
        for siren, method in candidates:
            is_valid = luhn_check(siren)
            if is_valid:
                result['siren'] = siren
                result['source_url'] = url
                result['luhn_valid'] = True
                result['method'] = method
                return result

        # If we found candidates but none pass Luhn, keep the first one
        if candidates and not result['siren']:
            siren, method = candidates[0]
            result['siren'] = siren
            result['source_url'] = url
            result['luhn_valid'] = luhn_check(siren)
            result['method'] = method

    return result


def main():
    # Load companies from stdin or from a JSON file
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        with open(input_file, 'r') as f:
            companies = json.load(f)
    else:
        print("Usage: python3 scripts/scrape_siren.py <input.json>")
        print("Input format: [{\"name\": \"...\", \"website\": \"...\", \"slug\": \"...\"}]")
        sys.exit(1)

    print(f"Scraping SIREN for {len(companies)} companies...")
    print()

    # Save progress incrementally to support resuming
    output_dir = Path(__file__).parent.parent / 'data'
    output_path = output_dir / 'siren_scrape_results.json'

    # Load existing results if any (for resume)
    existing = {}
    if output_path.exists():
        try:
            with open(output_path) as f:
                prev = json.load(f)
                for r in prev:
                    existing[r['slug']] = r
            print(f"Loaded {len(existing)} existing results — resuming.")
        except Exception:
            pass

    results = list(existing.values())
    found = sum(1 for r in results if r.get('siren'))
    valid = sum(1 for r in results if r.get('siren') and r.get('luhn_valid'))

    for i, company in enumerate(companies):
        name = company['name']
        website = company['website']
        slug = company.get('slug', '')

        # Skip if already attempted
        if slug in existing:
            continue

        print(f"[{i+1}/{len(companies)}] {name} ({website})...", end=" ", flush=True)

        try:
            result = find_siren_for_company(name, website)
        except Exception as e:
            result = {'name': name, 'website': website, 'siren': None, 'source_url': None, 'luhn_valid': None, 'method': None}
            print(f"error: {e}")
            result['slug'] = slug
            results.append(result)
            # Save progress
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)
            continue

        result['slug'] = slug
        results.append(result)

        if result['siren']:
            found += 1
            if result['luhn_valid']:
                valid += 1
            status = f"FOUND: {result['siren']}"
            if result['luhn_valid']:
                status += " (valid)"
            else:
                status += " (LUHN FAIL)"
            print(status)
        else:
            print("not found")

        # Save after every company so we can resume on crash
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)

        time.sleep(0.3)

    print(f"\n{'='*60}")
    print(f"Results: {found}/{len(companies)} SIREN found ({found*100//len(companies)}%)")
    print(f"  Luhn valid: {valid}")
    print(f"  Luhn invalid: {found - valid}")
    print(f"Saved to {output_path}")

    # Generate SQL update for valid SIRENs
    valid_results = [r for r in results if r['siren'] and r['luhn_valid']]
    if valid_results:
        sql_path = output_dir / 'siren_update.sql'
        with open(sql_path, 'w', encoding='utf-8') as f:
            f.write("-- SIREN updates from web scraping\n")
            f.write("-- Review before running!\n\n")
            for r in valid_results:
                f.write(f"-- {r['name']} (from {r['source_url']})\n")
                f.write(f"INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)\n")
                f.write(f"SELECT uuid_generate_v4(), o.id, '{r['name'].replace(chr(39), chr(39)+chr(39))}', '{r['siren']}', 'France', TRUE, NOW(), NOW()\n")
                f.write(f"FROM organizations o WHERE o.slug = '{r['slug']}'\n")
                f.write(f"AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '{r['siren']}');\n\n")
        print(f"SQL updates saved to {sql_path}")


if __name__ == '__main__':
    main()
