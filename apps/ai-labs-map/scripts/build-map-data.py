#!/usr/bin/env python3
"""
Build geocoded GeoJSON from ai_labs_france.json for the map app.

Normalizes messy RNSR city names to clean coordinates using a
hand-curated French city geocoding table. Outputs a GeoJSON
FeatureCollection ready for MapLibre.

Usage:
  python3 apps/ai-labs-map/scripts/build-map-data.py
"""

import json
import re
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent.parent.parent / "data"
OUTPUT = Path(__file__).parent.parent / "public" / "data" / "ai-labs.geojson"

# ── French city coordinates (lat, lon) ──────────────────────────────────
# Hand-curated for the ~30 unique metro areas in our dataset.
CITY_COORDS = {
    "paris":              [48.8566, 2.3522],
    "saclay":             [48.7144, 2.1680],
    "gif-sur-yvette":     [48.7016, 2.1335],
    "orsay":              [48.6964, 2.1874],
    "palaiseau":          [48.7147, 2.2474],
    "marne-la-vallee":    [48.8412, 2.5879],
    "montrouge":          [48.8186, 2.3194],
    "cergy":              [49.0363, 2.0760],
    "villetaneuse":       [48.9563, 2.3428],
    "saint-denis":        [48.9362, 2.3575],
    "evry":               [48.6325, 2.4408],
    "versailles":         [48.8014, 2.1301],
    "boulogne-billancourt": [48.8397, 2.2399],
    "chatillon":          [48.8036, 2.2928],
    "lille":              [50.6292, 3.0573],
    "villeneuve-d-ascq":  [50.6227, 3.1475],
    "lens":               [50.4280, 2.8327],
    "valenciennes":       [50.3577, 3.5235],
    "rennes":             [48.1173, -1.6778],
    "brest":              [48.3905, -4.4860],
    "nantes":             [47.2184, -1.5536],
    "caen":               [49.1829, -0.3707],
    "rouen":              [49.4432, 1.0993],
    "nancy":              [48.6921, 6.1844],
    "strasbourg":         [48.5734, 7.7521],
    "illkirch":           [48.5283, 7.7183],
    "compiegne":          [49.4175, 2.8266],
    "lyon":               [45.7640, 4.8357],
    "villeurbanne":       [45.7668, 4.8796],
    "saint-etienne":      [45.4397, 4.3872],
    "grenoble":           [45.1885, 5.7245],
    "saint-martin-d-heres": [45.1675, 5.7648],
    "la-tronche":         [45.2042, 5.7464],
    "clermont-ferrand":   [45.7772, 3.0870],
    "aubiere":            [45.7613, 3.1110],
    "toulouse":           [43.6047, 1.4442],
    "bordeaux":           [44.8378, -0.5792],
    "talence":            [44.8016, -0.5917],
    "montpellier":        [43.6108, 3.8767],
    "nice":               [43.7102, 7.2620],
    "sophia-antipolis":   [43.6164, 7.0550],
    "valbonne":           [43.6411, 7.0089],
    "marseille":          [43.2965, 5.3698],
    "toulon":             [43.1242, 5.9280],
    "ales":               [44.1249, 4.0820],
    "poitiers":           [46.5802, 0.3404],
    "limoges":            [45.8336, 1.2611],
    "orleans":            [47.9029, 1.9093],
    "besancon":            [47.2378, 6.0241],
    "dijon":              [47.3220, 5.0415],
    "meylan":             [45.2107, 5.7780],
    "calais":             [50.9513, 1.8587],
    "mulhouse":           [47.7508, 7.3359],
    "ales":               [44.1249, 4.0820],
    "besancon":           [47.2378, 6.0241],
    "la-rochelle":        [46.1603, -1.1511],
    "tsukuba":            [36.0835, 140.0764],  # Japan (JRL)
    "singapore":          [1.3521, 103.8198],
    "tokyo":              [35.6762, 139.6503],
    "montreal":           [45.5017, -73.5673],
    "tel-aviv":           [32.0853, 34.7818],
}


def normalize_city(raw):
    """Normalize a raw RNSR city string to a lookup key."""
    if not raw:
        return None
    s = raw.lower().strip()
    # Remove CEDEX and postal suffixes
    s = re.sub(r'\s+cedex\s*\d*', '', s)
    s = re.sub(r'\s+cedex$', '', s)
    # Remove parenthetical notes
    s = re.sub(r'\s*-\s*(champs|valbonne|cergy).*', '', s, flags=re.IGNORECASE)
    s = s.strip()
    # Common normalizations
    mapping = {
        "gif sur yvette": "gif-sur-yvette",
        "gif-sur-yvette": "gif-sur-yvette",
        "st martin d heres": "saint-martin-d-heres",
        "saint martin d'hères": "saint-martin-d-heres",
        "saint-martin-d'hères": "saint-martin-d-heres",
        "villers lès nancy": "nancy",
        "vandoeuvre les nancy": "nancy",
        "villeneuve d ascq": "villeneuve-d-ascq",
        "villeneuve d'ascq": "villeneuve-d-ascq",
        "marne la vallee": "marne-la-vallee",
        "sophia antipolis": "sophia-antipolis",
        "saint etienne du rouvray": "rouen",
        "illkirch-graffenstaden": "illkirch",
        "montbonnot st martin": "grenoble",
        "saint ismier": "grenoble",
        "nantes": "nantes",
        "talence": "talence",
        "le chesnay": "versailles",
        "paris": "paris",
        "lyon": "lyon",
        "aubiere": "aubiere",
        "alès": "ales",
        "ales": "ales",
        "besançon": "besancon",
        "besancon": "besancon",
    }
    # Try direct mapping
    for key, val in mapping.items():
        if key in s:
            return val
    # Try prefix match against coords
    for key in CITY_COORDS:
        if key in s or s in key:
            return key
    return None


def build_geojson():
    """Build GeoJSON from AI labs data."""
    with open(DATA_DIR / "ai_labs_france.json", "r") as f:
        labs = json.load(f)

    # Take only Tier 1+2 + private (score >= 35)
    top_labs = [l for l in labs if l["ai_score"] >= 35]

    features = []
    missing_cities = set()

    for lab in top_labs:
        city_raw = lab.get("city") or ""
        city_key = normalize_city(city_raw)

        if city_key and city_key in CITY_COORDS:
            coords = CITY_COORDS[city_key]
            # Add small jitter to prevent overlap in same city
            import hashlib
            h = hashlib.md5((lab.get("name") or "").encode()).hexdigest()
            jitter_lat = (int(h[:4], 16) / 65536 - 0.5) * 0.02
            jitter_lon = (int(h[4:8], 16) / 65536 - 0.5) * 0.02
            lon = coords[1] + jitter_lon
            lat = coords[0] + jitter_lat
        else:
            missing_cities.add(city_raw)
            continue

        sector = lab.get("sector", "public")
        tier = "private" if sector == "private" else (
            "tier1" if lab["ai_score"] >= 50 else "tier2"
        )

        # Determine thematic category
        domain = (lab.get("domain") or "").lower()
        name_lower = (lab.get("name") or "").lower()
        if sector == "private":
            category = "Private R&D"
        elif any(k in name_lower for k in ["math", "probabilit", "statistiq"]):
            category = "Mathematics"
        elif any(k in name_lower for k in ["robot", "système", "signal", "automat"]):
            category = "Engineering & Robotics"
        elif any(k in name_lower for k in ["intelligence artificielle", "artificial intelligence", "machine learning", "apprentissage"]):
            category = "AI-Dedicated"
        else:
            category = "Computer Science"

        feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [round(lon, 5), round(lat, 5)],
            },
            "properties": {
                "name": lab.get("name"),
                "acronym": lab.get("acronym"),
                "umr": lab.get("umr_label"),
                "type": lab.get("type"),
                "sector": sector,
                "tier": tier,
                "category": category,
                "city": city_raw.replace(" CEDEX", "").replace(" Cedex", "").strip().rstrip("0123456789 -"),
                "tutelles": lab.get("tutelles"),
                "parent_company": lab.get("parent_company"),
                "year_created": lab.get("year_created"),
                "website": lab.get("website"),
                "ai_score": lab["ai_score"],
                "rnsr_url": lab.get("rnsr_url"),
            },
        }
        features.append(feature)

    geojson = {
        "type": "FeatureCollection",
        "features": features,
    }

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT, "w") as f:
        json.dump(geojson, f, indent=2, ensure_ascii=False)

    print(f"Built {len(features)} features")
    print(f"Output: {OUTPUT}")
    if missing_cities:
        print(f"\nCities not geocoded ({len(missing_cities)}):")
        for c in sorted(missing_cities):
            print(f"  - '{c}'")

    # Stats
    tiers = {}
    for feat in features:
        t = feat["properties"]["tier"]
        tiers[t] = tiers.get(t, 0) + 1
    print(f"\nBy tier: {tiers}")

    cats = {}
    for feat in features:
        c = feat["properties"]["category"]
        cats[c] = cats.get(c, 0) + 1
    print(f"By category: {cats}")


if __name__ == "__main__":
    build_geojson()
