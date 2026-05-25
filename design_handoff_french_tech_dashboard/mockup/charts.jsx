// ─── Cohort flow + supporting charts ─────────────────────

const { useMemo } = React;

// ─── Cohort Flow (alluvial) ──────────────────────────────
// Year columns with N40+FT120 stacked bars; ribbons for retained/promoted/demoted between adjacent years; new/exit shown as bookend strips above/below each column.

function CohortFlow({
  width = 1000,
  height = 480,
  barWidth = 14,
  segmentGap = 18,
  showLabels = true,
  highlightYear = 2025,
  tonal = "full", // "full" or "muted" or "spot" (highlights current year transition only)
  showLegend = true,
  topPad = 60,
  bottomPad = 60,
  yearAtBottom = true,
  colorScheme = "default", // "default" | "ink" (more muted)
}) {
  const cohorts = window.COHORTS;
  const transitions = window.TRANSITIONS;

  const innerHeight = height - topPad - bottomPad;
  const scale = innerHeight / (120 + 8 /* gap allowance */);
  const n40Height = 40 * scale;
  const ft120Height = 80 * scale;
  const totalBarHeight = n40Height + segmentGap + ft120Height;

  const leftPad = 22;
  const rightPad = 22;
  const innerWidth = width - leftPad - rightPad;
  const colSpacing = innerWidth / (cohorts.length - 1);

  // Compute each column's geometry
  const columns = cohorts.map((c, i) => {
    const x = leftPad + i * colSpacing - barWidth / 2;
    const n40Top = topPad;
    const n40Bot = n40Top + n40Height;
    const ft120Top = n40Bot + segmentGap;
    const ft120Bot = ft120Top + ft120Height;
    return { ...c, x, n40Top, n40Bot, ft120Top, ft120Bot, idx: i };
  });

  // Build ribbons
  const ribbons = [];
  transitions.forEach((t, idx) => {
    const src = columns[idx];
    const tgt = columns[idx + 1];

    // Source N40 stack (top→bot): retainedN40, demoted, exitedN40
    const srcN40_retained = src.n40Top;
    const srcN40_demoted = srcN40_retained + t.retainedN40 * scale;

    // Source FT120 stack (top→bot): promoted, retainedFT120, exitedFT120
    const srcFT120_promoted = src.ft120Top;
    const srcFT120_retained = srcFT120_promoted + t.promoted * scale;

    // Target N40 stack (top→bot): newToN40, retainedN40, promoted
    const tgtN40_new = tgt.n40Top;
    const tgtN40_retained = tgtN40_new + t.newToN40 * scale;
    const tgtN40_promoted = tgtN40_retained + t.retainedN40 * scale;

    // Target FT120 stack (top→bot): demoted, retainedFT120, newToFT120
    const tgtFT120_demoted = tgt.ft120Top;
    const tgtFT120_retained = tgtFT120_demoted + t.demoted * scale;

    const sx = src.x + barWidth;
    const tx = tgt.x;

    const isCurrent = tgt.year === highlightYear;
    const opacity = tonal === "spot"
      ? (isCurrent ? 0.85 : 0.32)
      : tonal === "muted"
        ? 0.55
        : 0.78;

    ribbons.push({
      kind: "retained-n40",
      sx, sy0: srcN40_retained, sy1: srcN40_retained + t.retainedN40 * scale,
      tx, ty0: tgtN40_retained, ty1: tgtN40_retained + t.retainedN40 * scale,
      count: t.retainedN40,
      color: "var(--color-primary)",
      opacity: opacity * 0.7,
      transition: idx,
    });
    ribbons.push({
      kind: "retained-ft120",
      sx, sy0: srcFT120_retained, sy1: srcFT120_retained + t.retainedFT120 * scale,
      tx, ty0: tgtFT120_retained, ty1: tgtFT120_retained + t.retainedFT120 * scale,
      count: t.retainedFT120,
      color: "var(--color-secondary)",
      opacity: opacity * 0.55,
      transition: idx,
    });
    ribbons.push({
      kind: "promoted",
      sx, sy0: srcFT120_promoted, sy1: srcFT120_promoted + t.promoted * scale,
      tx, ty0: tgtN40_promoted, ty1: tgtN40_promoted + t.promoted * scale,
      count: t.promoted,
      color: "#114563",
      opacity: opacity,
      transition: idx,
      bold: true,
    });
    ribbons.push({
      kind: "demoted",
      sx, sy0: srcN40_demoted, sy1: srcN40_demoted + t.demoted * scale,
      tx, ty0: tgtFT120_demoted, ty1: tgtFT120_demoted + t.demoted * scale,
      count: t.demoted,
      color: "#b8862c",
      opacity: opacity,
      transition: idx,
      bold: true,
    });
  });

  function ribbonPath(r) {
    const dx = (r.tx - r.sx) * 0.5;
    return `M ${r.sx} ${r.sy0} C ${r.sx + dx} ${r.sy0}, ${r.tx - dx} ${r.ty0}, ${r.tx} ${r.ty0} L ${r.tx} ${r.ty1} C ${r.tx - dx} ${r.ty1}, ${r.sx + dx} ${r.sy1}, ${r.sx} ${r.sy1} Z`;
  }

  // New / exit strips
  // For year i > 0, "new entrants" = transitions[i-1].newToN40 + newToFT120
  // For year i, "exits" = transitions[i].exitedN40 + exitedFT120
  // The inaugural year (i=0) doesn't get an "arrivals" strip — we show an
  // inline "INAUGURAL · 120" label instead so the strip can't overflow above the chart.
  const yearMeta = cohorts.map((c, i) => {
    const newCount = i > 0
      ? transitions[i - 1].newToN40 + transitions[i - 1].newToFT120
      : 0; // inaugural — handled separately as a label
    const exitCount = i < cohorts.length - 1
      ? transitions[i].exitedN40 + transitions[i].exitedFT120
      : 0;
    const isInaugural = i === 0;
    return { ...c, newCount, exitCount, isInaugural };
  });

  // Heights of strips
  function stripHeight(count) { return count * scale; }

  return (
    <svg
      className="flow-svg"
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
    >
      <defs>
        <linearGradient id="newGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#3c6840" stopOpacity="0" />
          <stop offset="40%" stopColor="#3c6840" stopOpacity="0.18" />
          <stop offset="100%" stopColor="#3c6840" stopOpacity="0.62" />
        </linearGradient>
        <linearGradient id="exitGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#963d3d" stopOpacity="0.62" />
          <stop offset="60%" stopColor="#963d3d" stopOpacity="0.18" />
          <stop offset="100%" stopColor="#963d3d" stopOpacity="0" />
        </linearGradient>
      </defs>

      {/* Ribbons (drawn first so columns sit on top) */}
      {ribbons.map((r, i) => (
        <path
          key={i}
          d={ribbonPath(r)}
          fill={r.color}
          opacity={r.opacity}
        />
      ))}

      {/* Year columns */}
      {columns.map((c, i) => {
        const isCurrent = c.year === highlightYear;
        return (
          <g key={c.year}>
            {/* New entrants strip (above) — skipped for inaugural year */}
            {yearMeta[i].newCount > 0 && !yearMeta[i].isInaugural && (
              <g>
                <rect
                  x={c.x}
                  y={c.n40Top - stripHeight(yearMeta[i].newCount) - 4}
                  width={barWidth}
                  height={stripHeight(yearMeta[i].newCount)}
                  fill="url(#newGrad)"
                />
                {showLabels && (
                  <text
                    x={c.x + barWidth / 2}
                    y={c.n40Top - stripHeight(yearMeta[i].newCount) - 12}
                    fontSize="9.5"
                    fontFamily="JetBrains Mono"
                    fontWeight="600"
                    textAnchor="middle"
                    fill="#3c6840"
                    letterSpacing="0.04em"
                  >
                    +{yearMeta[i].newCount}
                  </text>
                )}
              </g>
            )}

            {/* Inaugural-cohort badge: a small chip above the column */}
            {yearMeta[i].isInaugural && showLabels && (
              <g>
                <rect
                  x={c.x - 30}
                  y={c.n40Top - 32}
                  width={74}
                  height={20}
                  fill="#3c6840"
                  opacity={0.92}
                />
                <text
                  x={c.x + barWidth / 2}
                  y={c.n40Top - 18}
                  fontSize="9"
                  fontFamily="Public Sans"
                  fontWeight="700"
                  textAnchor="middle"
                  fill="#fef9ee"
                  letterSpacing="0.12em"
                >
                  INAUGURAL · 120
                </text>
              </g>
            )}

            {/* Exit strip (below) */}
            {yearMeta[i].exitCount > 0 && (
              <g>
                <rect
                  x={c.x}
                  y={c.ft120Bot + 4}
                  width={barWidth}
                  height={stripHeight(yearMeta[i].exitCount)}
                  fill="url(#exitGrad)"
                />
                {showLabels && (
                  <text
                    x={c.x + barWidth / 2}
                    y={c.ft120Bot + stripHeight(yearMeta[i].exitCount) + 16}
                    fontSize="9.5"
                    fontFamily="JetBrains Mono"
                    fontWeight="600"
                    textAnchor="middle"
                    fill="#963d3d"
                    letterSpacing="0.04em"
                  >
                    −{yearMeta[i].exitCount}
                  </text>
                )}
              </g>
            )}

            {/* N40 bar */}
            <rect
              x={c.x}
              y={c.n40Top}
              width={barWidth}
              height={n40Height}
              fill={isCurrent ? "#114563" : "#114563"}
              opacity={isCurrent ? 1 : 0.92}
            />
            {/* FT120 bar */}
            <rect
              x={c.x}
              y={c.ft120Top}
              width={barWidth}
              height={ft120Height}
              fill={isCurrent ? "#3c6840" : "#3c6840"}
              opacity={isCurrent ? 1 : 0.85}
            />

            {/* Year label below */}
            {showLabels && yearAtBottom && (
              <g>
                <text
                  x={c.x + barWidth / 2}
                  y={c.ft120Bot + stripHeight(yearMeta[i].exitCount) + 38}
                  fontSize="13"
                  fontFamily="Newsreader"
                  fontWeight={isCurrent ? "600" : "500"}
                  textAnchor="middle"
                  fill={isCurrent ? "#114563" : "#1d1c15"}
                  letterSpacing="-0.01em"
                >
                  {c.year}
                </text>
                <text
                  x={c.x + barWidth / 2}
                  y={c.ft120Bot + stripHeight(yearMeta[i].exitCount) + 52}
                  fontSize="9"
                  fontFamily="Public Sans"
                  fontWeight="500"
                  textAnchor="middle"
                  fill="#41474d"
                  letterSpacing="0.1em"
                >
                  {c.label.toUpperCase()} PROMO
                </text>
                {isCurrent && (
                  <text
                    x={c.x + barWidth / 2}
                    y={c.ft120Bot + stripHeight(yearMeta[i].exitCount) + 70}
                    fontSize="8.5"
                    fontFamily="Public Sans"
                    fontWeight="700"
                    textAnchor="middle"
                    fill="#114563"
                    letterSpacing="0.15em"
                  >
                    JUST ANNOUNCED
                  </text>
                )}
              </g>
            )}

            {/* Tier counts beside column on first and last */}
            {showLabels && (i === 0 || i === columns.length - 1) && (
              <g>
                <text
                  x={i === 0 ? c.x - 8 : c.x + barWidth + 8}
                  y={c.n40Top + n40Height / 2 + 3}
                  fontSize="10"
                  fontFamily="JetBrains Mono"
                  fontWeight="600"
                  textAnchor={i === 0 ? "end" : "start"}
                  fill="#114563"
                >
                  40
                </text>
                <text
                  x={i === 0 ? c.x - 8 : c.x + barWidth + 8}
                  y={c.ft120Top + ft120Height / 2 + 3}
                  fontSize="10"
                  fontFamily="JetBrains Mono"
                  fontWeight="600"
                  textAnchor={i === 0 ? "end" : "start"}
                  fill="#3c6840"
                >
                  80
                </text>
              </g>
            )}
          </g>
        );
      })}

      {/* Tier labels (left side of chart) */}
      {showLabels && (
        <g>
          <text
            x={2}
            y={topPad - 6}
            fontSize="9"
            fontFamily="Public Sans"
            fontWeight="600"
            letterSpacing="0.15em"
            fill="#41474d"
          >
            NEW ENTRANTS
          </text>
          <text
            x={2}
            y={columns[0].ft120Bot + 16}
            fontSize="9"
            fontFamily="Public Sans"
            fontWeight="600"
            letterSpacing="0.15em"
            fill="#41474d"
          >
            EXITS
          </text>
        </g>
      )}
    </svg>
  );
}


// ─── Sector bar chart (horizontal) ───────────────────────
function SectorBars({ data, max, accent = "var(--color-primary)", showDelta = true, compact = false }) {
  const maxValue = max || Math.max(...data.map((d) => d.count));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: compact ? 2 : 4 }}>
      {data.map((d, i) => (
        <div key={d.sector} className="bar-row" style={{
          gridTemplateColumns: compact ? "140px 1fr 40px 32px" : "170px 1fr 44px 36px",
          fontSize: compact ? 11 : 12,
        }}>
          <div className="label" style={{ fontSize: compact ? 11 : 12, color: "#1d1c15" }}>
            {d.sector}
          </div>
          <div className="bar-wrap">
            <div className="bar" style={{ width: `${(d.count / maxValue) * 100}%`, background: accent }} />
          </div>
          <div className="val" style={{ fontSize: compact ? 11 : 12, color: "#1d1c15" }}>
            {d.count}
          </div>
          {showDelta && (
            <div className="num" style={{
              fontSize: compact ? 10 : 11,
              textAlign: "right",
              color: d.delta > 0 ? "#3c6840" : d.delta < 0 ? "#963d3d" : "#72787e",
            }}>
              {d.delta > 0 ? `+${d.delta}` : d.delta === 0 ? "·" : d.delta}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}


// ─── Treemap (squarified, simple) ────────────────────────
function SectorTreemap({ data, width = 480, height = 280 }) {
  // Simple slice-and-dice treemap (1-d split rows)
  const total = data.reduce((s, d) => s + d.count, 0);
  const cells = [];
  let cursorY = 0;
  let i = 0;
  // 4 rows
  const rowSplits = [4, 3, 3, 2];
  let used = 0;
  for (let rowIdx = 0; rowIdx < rowSplits.length; rowIdx++) {
    const rowCount = Math.min(rowSplits[rowIdx], data.length - used);
    if (rowCount <= 0) break;
    const rowItems = data.slice(used, used + rowCount);
    used += rowCount;
    const rowSum = rowItems.reduce((s, d) => s + d.count, 0);
    const rowHeight = (rowSum / total) * height;
    let cursorX = 0;
    rowItems.forEach((d) => {
      const w = (d.count / rowSum) * width;
      cells.push({
        ...d,
        x: cursorX, y: cursorY, w, h: rowHeight,
        rowIdx,
      });
      cursorX += w;
    });
    cursorY += rowHeight;
  }

  const palette = ["#114563", "#2f5d7c", "#3c6840", "#503863", "#5e8c61", "#7c8c9e", "#b8862c", "#963d3d", "#9fccef", "#a2d3a2", "#c4b894", "#dabbef"];

  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} style={{ display: "block" }}>
      {cells.map((c, i) => {
        const isWide = c.w > 80 && c.h > 40;
        const isMedium = c.w > 50 && c.h > 28;
        return (
          <g key={c.sector}>
            <rect
              x={c.x} y={c.y} width={c.w} height={c.h}
              fill={palette[i % palette.length]}
              opacity={0.88}
              stroke="#fef9ee" strokeWidth="2"
            />
            {isWide && (
              <>
                <text
                  x={c.x + 10} y={c.y + 22}
                  fontSize="12"
                  fontFamily="Public Sans"
                  fontWeight="600"
                  fill="white"
                  letterSpacing="0.01em"
                >
                  {c.sector}
                </text>
                <text
                  x={c.x + 10} y={c.y + c.h - 12}
                  fontSize="22"
                  fontFamily="Newsreader"
                  fontWeight="500"
                  fill="white"
                  style={{ fontVariantNumeric: "tabular-nums" }}
                >
                  {c.count}
                </text>
              </>
            )}
            {!isWide && isMedium && (
              <>
                <text
                  x={c.x + 7} y={c.y + 16}
                  fontSize="9.5"
                  fontFamily="Public Sans"
                  fontWeight="600"
                  fill="white"
                >
                  {c.sector.length > 14 ? c.sector.slice(0, 12) + "…" : c.sector}
                </text>
                <text
                  x={c.x + 7} y={c.y + c.h - 8}
                  fontSize="14"
                  fontFamily="Newsreader"
                  fill="white"
                  style={{ fontVariantNumeric: "tabular-nums" }}
                >
                  {c.count}
                </text>
              </>
            )}
            {!isWide && !isMedium && (
              <text
                x={c.x + c.w / 2} y={c.y + c.h / 2 + 3}
                fontSize="10"
                fontFamily="JetBrains Mono"
                fontWeight="600"
                fill="white"
                textAnchor="middle"
              >
                {c.count}
              </text>
            )}
          </g>
        );
      })}
    </svg>
  );
}


// ─── France map ──────────────────────────────────────────
// Simplified hexagon-ish outline of mainland France with city bubbles.
function FranceMap({ width = 480, height = 560, regions, accent = "#114563" }) {
  // viewBox is sized to a 720x640 design; we scale to width/height
  const designW = 800, designH = 640;
  const FRANCE_PATH = `
    M 396 22
    L 432 18
    L 478 28
    L 510 42
    L 545 56
    L 580 78
    L 616 95
    L 645 86
    L 682 92
    L 705 118
    L 720 145
    L 712 178
    L 745 198
    L 768 232
    L 752 268
    L 712 285
    L 690 320
    L 700 360
    L 738 402
    L 716 440
    L 695 478
    L 678 506
    L 650 540
    L 615 558
    L 568 565
    L 530 562
    L 488 568
    L 445 562
    L 402 568
    L 358 558
    L 318 542
    L 280 555
    L 245 542
    L 220 510
    L 232 478
    L 210 440
    L 175 422
    L 145 395
    L 122 360
    L 96 330
    L 70 295
    L 48 258
    L 65 225
    L 102 198
    L 125 168
    L 110 138
    L 138 110
    L 175 95
    L 205 110
    L 240 92
    L 268 70
    L 305 62
    L 340 50
    L 372 32
    Z
  `;

  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${designW} ${designH}`}
      style={{ display: "block" }}
    >
      {/* France outline */}
      <path
        d={FRANCE_PATH}
        fill="#fef9ee"
        stroke="#1d1c15"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />

      {/* Faint inland subdivision rule for elegance */}
      <path
        d={FRANCE_PATH}
        fill="none"
        stroke="rgba(193, 199, 206, 0.65)"
        strokeWidth="6"
      />

      {/* City bubbles */}
      {regions.map((r) => {
        const radius = 6 + Math.sqrt(r.count) * 4.5;
        const isParis = r.city === "Paris";
        return (
          <g key={r.city} transform={`translate(${r.x}, ${r.y})`}>
            <circle
              r={radius}
              fill={isParis ? "#114563" : accent}
              opacity={isParis ? 0.92 : 0.78}
            />
            <circle
              r={radius}
              fill="none"
              stroke="#fef9ee"
              strokeWidth="1.5"
              opacity={0.6}
            />
            <text
              x={radius + 6}
              y={4}
              fontSize="11"
              fontFamily="Public Sans"
              fontWeight="600"
              fill="#1d1c15"
            >
              {r.city}
            </text>
            <text
              x={radius + 6}
              y={18}
              fontSize="10"
              fontFamily="JetBrains Mono"
              fill="#41474d"
              style={{ fontVariantNumeric: "tabular-nums" }}
            >
              {r.count}{r.delta !== 0 ? ` (${r.delta > 0 ? "+" : ""}${r.delta})` : ""}
            </text>
          </g>
        );
      })}
    </svg>
  );
}


// ─── Sparkline (small year-over-year mini chart) ────────
function CohortMiniSpark({ width = 180, height = 38, accent = "#114563" }) {
  const cohorts = window.COHORTS;
  const transitions = window.TRANSITIONS;
  const newCounts = [120, ...transitions.map(t => t.newToN40 + t.newToFT120)];
  const exitCounts = [...transitions.map(t => t.exitedN40 + t.exitedFT120), 0];
  const max = 120;

  const pts = cohorts.map((c, i) => {
    const x = (i / (cohorts.length - 1)) * (width - 8) + 4;
    const yNew = height - 4 - (newCounts[i] / max) * (height - 8);
    const yExit = height - 4 - (exitCounts[i] / max) * (height - 8);
    return { x, yNew, yExit, year: c.year };
  });

  const pathNew = pts.map((p, i) => `${i === 0 ? "M" : "L"} ${p.x} ${p.yNew}`).join(" ");
  const pathExit = pts.map((p, i) => `${i === 0 ? "M" : "L"} ${p.x} ${p.yExit}`).join(" ");

  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
      <path d={pathExit} fill="none" stroke="#963d3d" strokeWidth="1.5" opacity="0.7" />
      <path d={pathNew} fill="none" stroke="#3c6840" strokeWidth="1.5" />
      {pts.map((p, i) => (
        <g key={i}>
          <circle cx={p.x} cy={p.yNew} r="2" fill="#3c6840" />
          <circle cx={p.x} cy={p.yExit} r="2" fill="#963d3d" />
        </g>
      ))}
    </svg>
  );
}


// ─── Page chrome (sidebar + topbar from Navigator) ──────
function NavChrome({ children, pageLabel = "Programs · French Tech Next 40/120" }) {
  return (
    <div className="page-canvas">
      <aside className="nav-sidebar">
        <div className="masthead">
          <h1>The Navigator</h1>
          <p className="diplomatic-label" style={{ marginTop: 4 }}>Institutional Intelligence</p>
        </div>

        <nav style={{ flex: 1, padding: "0 12px" }}>
          <ul style={{ listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: 2 }}>
            {[
              { n: "Ecosystem Atlas", i: "public" },
              { n: "Entity Explorer", i: "domain" },
              { n: "People", i: "person" },
              { n: "Funding Tracker", i: "payments" },
              { n: "Institutions", i: "school" },
              { n: "Research Intel", i: "science" },
              { n: "Network Navigator", i: "share" },
            ].map((item) => (
              <li key={item.n}>
                <a href="#" className="nav-item">
                  <span className="material-symbols-outlined">{item.i}</span>
                  {item.n}
                </a>
              </li>
            ))}
          </ul>
        </nav>

        <a href="#" className="institutional-cta">New Analysis</a>

        <div className="nav-section">
          <p className="nav-section-label">Programs</p>
          <ul style={{ listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: 0 }}>
            <li><a href="#" className="nav-item active">
              <span className="material-symbols-outlined">emoji_events</span>
              French Tech Next 40/120
            </a></li>
            <li><a href="#" className="nav-item">
              <span className="material-symbols-outlined">science</span>
              i-Lab Laureates
            </a></li>
            <li><a href="#" className="nav-item">
              <span className="material-symbols-outlined">rocket_launch</span>
              i-Nov Laureates
            </a></li>
          </ul>
        </div>

        <div className="nav-section">
          <ul style={{ listStyle: "none", margin: 0, padding: 0 }}>
            {[
              { n: "Export", i: "download" },
              { n: "Settings", i: "tune" },
              { n: "Support", i: "help_outline" },
            ].map((item) => (
              <li key={item.n}>
                <a href="#" className="nav-item" style={{ padding: "8px 14px" }}>
                  <span className="material-symbols-outlined icon-18">{item.i}</span>
                  {item.n}
                </a>
              </li>
            ))}
          </ul>
        </div>
      </aside>

      <div className="page-main">
        <div className="nav-topbar">
          <div className="scope-toggle">
            <span className="active">National</span>
            <span>Regional</span>
            <span>Cluster</span>
            <span>Entity</span>
          </div>
          <div className="search-stub">
            <span className="material-symbols-outlined icon-16">search</span>
            Search entities…
          </div>
          <div className="actions">
            <span className="material-symbols-outlined icon-20">notifications</span>
            <span className="material-symbols-outlined icon-20">account_circle</span>
          </div>
        </div>
        <div className="page-content">
          {children}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  CohortFlow,
  SectorBars,
  SectorTreemap,
  FranceMap,
  CohortMiniSpark,
  NavChrome,
});
