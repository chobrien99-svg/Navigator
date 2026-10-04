#!/usr/bin/env bash
# make-pdf.sh — render a French Tech Journal quarterly report HTML to a clean,
# paginated A4 PDF (one section per page, running header + page numbers),
# fully offline: Chart.js vendored and Newsreader/Public Sans embedded as base64.
#
# Usage:
#   ./make-pdf.sh <input.html> <output.pdf> ["Running-header right label"]
#
# Example:
#   ./make-pdf.sh q3-2026-full-report.html Q3-2026-French-Tech-Funding-Report.pdf \
#       "Q3 2026 French Tech Funding Report"
#
# Requirements (all present in the Claude Code cloud environment):
#   - node + npm (npm registry reachable; CDNs are not, hence the vendoring)
#   - python3
#   - pre-installed Chromium under /opt/pw-browsers (auto-detected; override with PDF_CHROME)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN="${1:?input HTML required}"
OUT="${2:?output PDF required}"
LABEL="${3:-Quarterly Funding Report}"

# Resolve to absolute paths.
IN="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
mkdir -p "$(dirname "$OUT")"
OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

CHART_VER="${CHART_VER:-4}"
NR_VER="${NR_VER:-5}"
PS_VER="${PS_VER:-5}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

echo "[make-pdf] vendoring assets into $WORK ..."
npm pack "chart.js@${CHART_VER}" >/dev/null 2>&1
npm pack "@fontsource/newsreader@${NR_VER}" >/dev/null 2>&1
npm pack "@fontsource/public-sans@${PS_VER}" >/dev/null 2>&1
npm install playwright-core >/dev/null 2>&1

tar xzf chart.js-*.tgz
cp package/dist/chart.umd.min.js ./chart.umd.min.js
tar xzf fontsource-newsreader-*.tgz --one-top-level=nr
tar xzf fontsource-public-sans-*.tgz --one-top-level=ps

echo "[make-pdf] building offline HTML ..."
python3 "$HERE/build_offline.py" "$IN" "$WORK/offline.html"

echo "[make-pdf] rendering PDF ..."
NODE_PATH="$WORK/node_modules" node "$HERE/render_pdf.js" "$WORK/offline.html" "$OUT" "$LABEL"

echo "[make-pdf] done -> $OUT"
