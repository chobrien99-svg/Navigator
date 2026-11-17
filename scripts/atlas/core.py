"""Atlas engine core: HTTP with retries and disk cache, run context, findings.

See docs/entity-search/SPEC.md (finding format) and docs/atlas_engine_design.md.
Standard library only. HTTP goes through curl so the environment proxy and CA apply.
"""
import datetime as dt
import gzip
import hashlib
import json
import os
import re
import subprocess
import time
import urllib.parse

CACHE_DIR = os.environ.get("ATLAS_CACHE", os.path.expanduser("~/.cache/atlas"))


class SourceUnavailable(Exception):
    """A source could not be reached after retries. Reported, never treated as 'no results'."""


def now_iso():
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _cache_path(key):
    h = hashlib.sha256(key.encode()).hexdigest()
    return os.path.join(CACHE_DIR, "http", h[:2], h + ".json")


def http_json(url, params=None, tries=6, wait=2.0, timeout=45, use_cache=True):
    """GET a JSON document. Retries with growing pauses; caches successful responses on disk."""
    if params:
        url += ("&" if "?" in url else "?") + urllib.parse.urlencode(params, doseq=True)
    cp = _cache_path(url)
    if use_cache and os.path.exists(cp):
        with open(cp) as f:
            return json.load(f)
    last = None
    for k in range(tries):
        r = subprocess.run(["curl", "-sS", "-L", "-m", str(timeout), "-A", "france-navigator-atlas/0.1",
                            "-w", "\n%{http_code}", url], capture_output=True, text=True)
        body, _, code = r.stdout.rpartition("\n")
        if r.returncode == 0 and code == "200":
            try:
                data = json.loads(body)
            except ValueError as e:
                last = f"invalid JSON: {e}"
            else:
                os.makedirs(os.path.dirname(cp), exist_ok=True)
                with open(cp, "w") as f:
                    json.dump(data, f)
                return data
        elif code in ("400", "404"):
            raise SourceUnavailable(f"HTTP {code} for {url[:160]}")
        else:
            last = f"curl rc={r.returncode} http={code} {r.stderr.strip()[:160]}"
        time.sleep(wait * (1.7 ** k))
    raise SourceUnavailable(f"GET failed after {tries} tries: {url[:160]} :: {last}")


def download(url, name, timeout=1800):
    """Download a large file once into the cache and return its path."""
    path = os.path.join(CACHE_DIR, "files", name)
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".part"
    for k in range(4):
        r = subprocess.run(["curl", "-sS", "-L", "-C", "-", "-m", str(timeout), "-o", tmp, url],
                           capture_output=True, text=True)
        if r.returncode == 0:
            os.replace(tmp, path)
            return path
        time.sleep(5 * (k + 1))
    raise SourceUnavailable(f"download failed: {url} :: {r.stderr.strip()[:160]}")


# ---------------------------------------------------------------- names

class NameMatcher:
    """Whole-word, case-insensitive name matching with an exclusion list."""

    def __init__(self, names, exclusions=()):
        self.pats = [re.compile(r"(?<![\w])" + re.escape(n) + r"(?![\w])", re.I) for n in names]
        self.excl = [e.lower() for e in exclusions]

    def matches(self, text):
        if not text:
            return None
        low = text.lower()
        if any(e in low for e in self.excl):
            return None
        for p in self.pats:
            m = p.search(text)
            if m:
                return m.group(0)
        return None


def norm_siren(x):
    d = re.sub(r"\D", "", str(x or ""))
    return d[:9] if len(d) >= 9 else None


# ---------------------------------------------------------------- findings

FINDING_KEYS = ("finding_id", "entity", "type", "date", "date_precision", "title", "summary",
                "amount_eur", "amount_basis", "subject", "counterparts", "facts", "source",
                "match", "confidence", "suggested_target")


def finding(ctx, *, connector, type, ext_id, title, summary="", date=None, date_precision=None,
            amount_eur=None, amount_basis=None, subject=None, counterparts=None, facts=None,
            source_name="", url=None, match_method="identifier", match_on="", level="high",
            confidence="official", suggested_target=None):
    return {
        "finding_id": f"{connector}:{type}:{ext_id}",
        "entity": ctx.entity["key"],
        "type": type,
        "date": date,
        "date_precision": date_precision or (("day" if len(date) == 10 else "month" if len(date) == 7 else "year") if date else None),
        "title": title,
        "summary": summary,
        "amount_eur": amount_eur,
        "amount_basis": amount_basis,
        "subject": subject or {},
        "counterparts": counterparts or [],
        "facts": facts or {},
        "source": {"connector": connector, "name": source_name, "url": url, "external_id": str(ext_id)},
        "match": {"method": match_method, "on": match_on, "level": level, "needs_review": level != "high"},
        "confidence": confidence,
        "suggested_target": suggested_target,
    }


# ---------------------------------------------------------------- run context

class RunContext:
    def __init__(self, entity, out_dir):
        self.entity = entity
        self.out_dir = out_dir
        self.started_at = now_iso()
        self.sources = {}
        self._raw = {}
        os.makedirs(os.path.join(out_dir, "raw"), exist_ok=True)

    def save_raw(self, connector, external_id, url, payload):
        """Store a raw record in the shape of the source_records table."""
        body = json.dumps(payload, sort_keys=True, ensure_ascii=False)
        rec = {"connector": connector, "external_id": str(external_id), "url": url, "fetched_at": now_iso(),
               "content_hash": hashlib.sha256(body.encode()).hexdigest(), "payload": payload}
        self._raw.setdefault(connector, []).append(rec)

    def status(self, connector, state, **info):
        self.sources[connector] = {"status": state, **info}

    def log(self, msg):
        print(f"[{dt.datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)

    def write(self, findings):
        for c, recs in self._raw.items():
            with gzip.open(os.path.join(self.out_dir, "raw", f"{c}.jsonl.gz"), "wt") as f:
                for r in recs:
                    f.write(json.dumps(r, ensure_ascii=False) + "\n")
        with open(os.path.join(self.out_dir, "findings.json"), "w") as f:
            json.dump(findings, f, ensure_ascii=False, indent=1)
        manifest = {"entity": self.entity, "started_at": self.started_at, "finished_at": now_iso(),
                    "sources": self.sources, "findings": len(findings),
                    "findings_by_type": _count(findings, "type"),
                    "needs_review": sum(1 for x in findings if x["match"]["needs_review"])}
        with open(os.path.join(self.out_dir, "manifest.json"), "w") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=1)
        return manifest


def _count(items, key):
    out = {}
    for i in items:
        out[i[key]] = out.get(i[key], 0) + 1
    return out
