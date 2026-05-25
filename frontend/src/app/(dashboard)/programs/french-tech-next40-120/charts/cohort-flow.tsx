import type { Cohort, Transition } from "../cohort-data";

type Tonal = "full" | "muted" | "spot";

type CohortFlowProps = {
  cohorts: Cohort[];
  transitions: Transition[];
  width?: number;
  height?: number;
  barWidth?: number;
  segmentGap?: number;
  showLabels?: boolean;
  highlightYear?: number;
  tonal?: Tonal;
  topPad?: number;
  bottomPad?: number;
};

type Ribbon = {
  kind: string;
  sx: number;
  sy0: number;
  sy1: number;
  tx: number;
  ty0: number;
  ty1: number;
  count: number;
  color: string;
  opacity: number;
};

export function CohortFlow({
  cohorts,
  transitions,
  width = 1000,
  height = 480,
  barWidth = 14,
  segmentGap = 18,
  showLabels = true,
  highlightYear = 2025,
  tonal = "full",
  topPad = 60,
  bottomPad = 60,
}: CohortFlowProps) {
  const innerHeight = height - topPad - bottomPad;
  const scale = innerHeight / (120 + 8); // gap allowance
  const n40Height = 40 * scale;
  const ft120Height = 80 * scale;

  const leftPad = 22;
  const rightPad = 22;
  const innerWidth = width - leftPad - rightPad;
  const colSpacing = innerWidth / (cohorts.length - 1);

  const columns = cohorts.map((c, i) => {
    const x = leftPad + i * colSpacing - barWidth / 2;
    const n40Top = topPad;
    const n40Bot = n40Top + n40Height;
    const ft120Top = n40Bot + segmentGap;
    const ft120Bot = ft120Top + ft120Height;
    return { ...c, x, n40Top, n40Bot, ft120Top, ft120Bot, idx: i };
  });

  const ribbons: Ribbon[] = [];
  transitions.forEach((t, idx) => {
    const src = columns[idx];
    const tgt = columns[idx + 1];

    const srcN40_retained = src.n40Top;
    const srcN40_demoted = srcN40_retained + t.retainedN40 * scale;

    const srcFT120_promoted = src.ft120Top;
    const srcFT120_retained = srcFT120_promoted + t.promoted * scale;

    const tgtN40_new = tgt.n40Top;
    const tgtN40_retained = tgtN40_new + t.newToN40 * scale;
    const tgtN40_promoted = tgtN40_retained + t.retainedN40 * scale;

    const tgtFT120_demoted = tgt.ft120Top;
    const tgtFT120_retained = tgtFT120_demoted + t.demoted * scale;

    const sx = src.x + barWidth;
    const tx = tgt.x;

    const isCurrent = tgt.year === highlightYear;
    const opacity =
      tonal === "spot"
        ? isCurrent
          ? 0.85
          : 0.32
        : tonal === "muted"
          ? 0.55
          : 0.78;

    ribbons.push({
      kind: "retained-n40",
      sx,
      sy0: srcN40_retained,
      sy1: srcN40_retained + t.retainedN40 * scale,
      tx,
      ty0: tgtN40_retained,
      ty1: tgtN40_retained + t.retainedN40 * scale,
      count: t.retainedN40,
      color: "var(--color-primary)",
      opacity: opacity * 0.7,
    });
    ribbons.push({
      kind: "retained-ft120",
      sx,
      sy0: srcFT120_retained,
      sy1: srcFT120_retained + t.retainedFT120 * scale,
      tx,
      ty0: tgtFT120_retained,
      ty1: tgtFT120_retained + t.retainedFT120 * scale,
      count: t.retainedFT120,
      color: "var(--color-secondary)",
      opacity: opacity * 0.55,
    });
    ribbons.push({
      kind: "promoted",
      sx,
      sy0: srcFT120_promoted,
      sy1: srcFT120_promoted + t.promoted * scale,
      tx,
      ty0: tgtN40_promoted,
      ty1: tgtN40_promoted + t.promoted * scale,
      count: t.promoted,
      color: "#114563",
      opacity,
    });
    ribbons.push({
      kind: "demoted",
      sx,
      sy0: srcN40_demoted,
      sy1: srcN40_demoted + t.demoted * scale,
      tx,
      ty0: tgtFT120_demoted,
      ty1: tgtFT120_demoted + t.demoted * scale,
      count: t.demoted,
      color: "#b8862c",
      opacity,
    });
  });

  function ribbonPath(r: Ribbon) {
    const dx = (r.tx - r.sx) * 0.5;
    return `M ${r.sx} ${r.sy0} C ${r.sx + dx} ${r.sy0}, ${r.tx - dx} ${r.ty0}, ${r.tx} ${r.ty0} L ${r.tx} ${r.ty1} C ${r.tx - dx} ${r.ty1}, ${r.sx + dx} ${r.sy1}, ${r.sx} ${r.sy1} Z`;
  }

  const stripHeight = (count: number) => count * scale;
  const n40TopY = topPad;
  const ft120BotY = columns[0].ft120Bot;

  return (
    <svg className="flow-svg" width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
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

      {ribbons.map((r, i) => (
        <path key={i} d={ribbonPath(r)} fill={r.color} opacity={r.opacity} />
      ))}

      {/* New-entrant / exit strips, placed in the gap between the two years they bridge. */}
      {transitions.map((t, idx) => {
        const src = columns[idx];
        const tgt = columns[idx + 1];
        const gapX = (src.x + barWidth + tgt.x) / 2 - barWidth / 2;
        const newCount = t.newToN40 + t.newToFT120;
        const exitCount = t.exitedN40 + t.exitedFT120;
        return (
          <g key={`gap-${idx}`}>
            {newCount > 0 && (
              <g>
                <rect
                  x={gapX}
                  y={n40TopY - stripHeight(newCount) - 4}
                  width={barWidth}
                  height={stripHeight(newCount)}
                  fill="url(#newGrad)"
                />
                {showLabels && (
                  <text
                    x={gapX + barWidth / 2}
                    y={n40TopY - stripHeight(newCount) - 12}
                    fontSize="9.5"
                    fontFamily="JetBrains Mono"
                    fontWeight="600"
                    textAnchor="middle"
                    fill="#3c6840"
                    letterSpacing="0.04em"
                  >
                    +{newCount}
                  </text>
                )}
              </g>
            )}
            {exitCount > 0 && (
              <g>
                <rect
                  x={gapX}
                  y={ft120BotY + 4}
                  width={barWidth}
                  height={stripHeight(exitCount)}
                  fill="url(#exitGrad)"
                />
                {showLabels && (
                  <text
                    x={gapX + barWidth / 2}
                    y={ft120BotY + stripHeight(exitCount) + 16}
                    fontSize="9.5"
                    fontFamily="JetBrains Mono"
                    fontWeight="600"
                    textAnchor="middle"
                    fill="#963d3d"
                    letterSpacing="0.04em"
                  >
                    −{exitCount}
                  </text>
                )}
              </g>
            )}
          </g>
        );
      })}

      {columns.map((c, i) => {
        const isCurrent = c.year === highlightYear;
        return (
          <g key={c.year}>
            {i === 0 && showLabels && (
              <g>
                <rect x={c.x - 30} y={c.n40Top - 32} width={74} height={20} fill="#3c6840" opacity={0.92} />
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

            <rect x={c.x} y={c.n40Top} width={barWidth} height={n40Height} fill="#114563" opacity={isCurrent ? 1 : 0.92} />
            <rect x={c.x} y={c.ft120Top} width={barWidth} height={ft120Height} fill="#3c6840" opacity={isCurrent ? 1 : 0.85} />

            {showLabels && (
              <g>
                <text
                  x={c.x + barWidth / 2}
                  y={c.ft120Bot + 38}
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
                  y={c.ft120Bot + 52}
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
                    y={c.ft120Bot + 70}
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

      {showLabels && (
        <g>
          <text x={2} y={topPad - 6} fontSize="9" fontFamily="Public Sans" fontWeight="600" letterSpacing="0.15em" fill="#41474d">
            NEW ENTRANTS
          </text>
          <text x={2} y={columns[0].ft120Bot + 16} fontSize="9" fontFamily="Public Sans" fontWeight="600" letterSpacing="0.15em" fill="#41474d">
            EXITS
          </text>
        </g>
      )}
    </svg>
  );
}
