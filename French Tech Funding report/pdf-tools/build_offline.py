#!/usr/bin/env python3
"""Produce an offline, self-contained copy of the report HTML for PDF rendering:
   - embeds Newsreader + Public Sans as base64 woff2 @font-face rules
   - inlines Chart.js (vendored UMD build)
   - strips Google Fonts <link>s and the iframe-resizer script (not needed in print)
"""
import base64, os, re, sys, pathlib

# Vendored assets (chart.umd.min.js, nr/, ps/) are resolved from PDF_ASSETS,
# else the current working directory (where make-pdf.sh extracts them).
BUILD = pathlib.Path(os.environ.get("PDF_ASSETS", os.getcwd()))
SRC = pathlib.Path(sys.argv[1])
OUT = pathlib.Path(sys.argv[2])

NR = BUILD / "nr/package/files"
PS = BUILD / "ps/package/files"

# (family, weight, style, file)
FONTS = [
    ("Newsreader", 400, "normal", NR / "newsreader-latin-400-normal.woff2"),
    ("Newsreader", 500, "normal", NR / "newsreader-latin-500-normal.woff2"),
    ("Newsreader", 600, "normal", NR / "newsreader-latin-600-normal.woff2"),
    ("Newsreader", 700, "normal", NR / "newsreader-latin-700-normal.woff2"),
    ("Newsreader", 400, "italic", NR / "newsreader-latin-400-italic.woff2"),
    ("Newsreader", 500, "italic", NR / "newsreader-latin-500-italic.woff2"),
    ("Public Sans", 300, "normal", PS / "public-sans-latin-300-normal.woff2"),
    ("Public Sans", 400, "normal", PS / "public-sans-latin-400-normal.woff2"),
    ("Public Sans", 500, "normal", PS / "public-sans-latin-500-normal.woff2"),
    ("Public Sans", 600, "normal", PS / "public-sans-latin-600-normal.woff2"),
    ("Public Sans", 700, "normal", PS / "public-sans-latin-700-normal.woff2"),
]

def face(family, weight, style, path):
    b64 = base64.b64encode(path.read_bytes()).decode()
    return (f"@font-face{{font-family:'{family}';font-style:{style};font-weight:{weight};"
            f"font-display:swap;src:url(data:font/woff2;base64,{b64}) format('woff2');}}")

font_css = "<style id=\"embedded-fonts\">\n" + "\n".join(
    face(*f) for f in FONTS) + "\n</style>"

chartjs = (BUILD / "chart.umd.min.js").read_text()

html = SRC.read_text()

# Strip the three Google Fonts link/preconnect lines.
html = re.sub(r'<link rel="preconnect"[^>]*>\s*', '', html)
html = re.sub(r'<link href="https://fonts\.googleapis\.com[^>]*>\s*', '', html)

# Replace Chart.js CDN with inline vendored build (function repl avoids backslash escapes).
# Append print-friendly defaults: no animation (charts are final immediately) + crisp DPR.
chart_block = ('<script>\n' + chartjs +
               '\nChart.defaults.animation=false;'
               'Chart.defaults.animations=false;'
               'Chart.defaults.transitions.active.animation.duration=0;'
               'Chart.defaults.devicePixelRatio=2;\n</script>')
html = re.sub(r'<script src="https://cdn\.jsdelivr\.net/npm/chart\.js"></script>',
              lambda m: chart_block, html)

# Drop iframe-resizer (CDN, embed-only helper).
html = re.sub(r'<script src="https://cdn\.jsdelivr\.net/npm/iframe-resizer[^>]*></script>\s*', '', html)

# Inject embedded fonts right after <head> so they load first.
html = html.replace('</head>', font_css + '\n</head>', 1)

# Sanity: no remaining external http(s) resource references.
leftovers = re.findall(r'(?:src|href)="https?://[^"]+"', html)
if leftovers:
    sys.stderr.write("WARNING remaining external refs:\n" + "\n".join(leftovers) + "\n")

OUT.write_text(html)
print(f"wrote {OUT} ({len(html)} bytes), {len(FONTS)} fonts embedded")
