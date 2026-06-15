"use client";

import { useRef, useState } from "react";
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
  announce?: boolean;
  fluid?: boolean;
};

type Ribbon = {
  id: string;
  sx: number;
  sy0: number;
  sy1: number;
  tx: number;
  ty0: number;
  ty1: number;
  color: string;
  opacity: number;
  tipLabel: string;
  tipSub: string;
};

const firms = (n: number) => `${n} ${n === 1 ? "firm" : "firms"}`;

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
  announce = true,
  fluid = false,
}: CohortFlowProps) {
  const [hoverId, setHoverId] = useState<string | null>(null);
  const [tip, setTip] = useState<{ label: string; sub: string } | null>(null);
  const [pos, setPos] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const wrapRef = useRef<HTMLDivElement>(null);

  const onMove = (e: React.MouseEvent) => {
    const r = wrapRef.current?.getBoundingClientRect();
    if (r) setPos({ x: e.clientX - r.left, y: e.clientY - r.top });
  };
  const enter = (id: string, label: string, sub: string) => {
    setHoverId(id);
    setTip({ label, sub });
  };
  const leave = () => {
    setHoverId(null);
    setTip(null);
  };
  const opacityFor = (id: string, base: number) => {
    if (!hoverId) return base;
    return hoverId === id ? Math.max(base, 0.92) : base * 0.2;
  };

  const innerHeight = height - topPad - bottomPad;
  const scale = innerHeight / (120 + 8); // gap allowance
  const n40Height = 40 * scale;
  const ft120Height = 80 * scale;

  const leftPad = 22;
  const rightPad = 22;
  const innerWidth = width - leftPad - rightPad;
  const colSpacing = cohorts.length > 1 ? innerWidth / (cohorts.length - 1) : 0;

  const columns = cohorts.map((c, i) => {
    const x =
      cohorts.length > 1 ? leftPad + i * colSpacing - barWidth / 2 : width / 2 - barWidth / 2;
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
    const span = `${t.from} → ${t.to}`;

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
      id: `retained-n40-${idx}`,
      sx,
      sy0: srcN40_retained,
      sy1: srcN40_retained + t.retainedN40 * scale,
      tx,
      ty0: tgtN40_retained,
      ty1: tgtN40_retained + t.retainedN40 * scale,
      color: "var(--color-primary)",
      opacity: opacity * 0.7,
      tipLabel: "Retained · Next 40",
      tipSub: `${span} · ${firms(t.retainedN40)}`,
    });
    ribbons.push({
      id: `retained-ft120-${idx}`,
      sx,
      sy0: srcFT120_retained,
      sy1: srcFT120_retained + t.retainedFT120 * scale,
      tx,
      ty0: tgtFT120_retained,
      ty1: tgtFT120_retained + t.retainedFT120 * scale,
      color: "var(--color-secondary)",
      opacity: opacity * 0.55,
      tipLabel: "Retained · FT 120",
      tipSub: `${span} · ${firms(t.retainedFT120)}`,
    });
    ribbons.push({
      id: `promoted-${idx}`,
      sx,
      sy0: srcFT120_promoted,
      sy1: srcFT120_promoted + t.promoted * scale,
      tx,
      ty0: tgtN40_promoted,
      ty1: tgtN40_promoted + t.promoted * scale,
      color: "#114563",
      opacity,
      tipLabel: "Promoted to Next 40",
      tipSub: `${span} · ${firms(t.promoted)}`,
    });
    ribbons.push({
      id: `demoted-${idx}`,
      sx,
      sy0: srcN40_demoted,
      sy1: srcN40_demoted + t.demoted * scale,
      tx,
      ty0: tgtFT120_demoted,
      ty1: tgtFT120_demoted + t.demoted * scale,
      color: "#b8862c",
      opacity,
      tipLabel: "Demoted to FT 120",
      tipSub: `${span} · ${firms(t.demoted)}`,
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
    <div ref={wrapRef} style={{ position: "relative" }} onMouseMove={onMove} onMouseLeave={leave}>
      <svg
        className="flow-svg"
        width={width}
        height={height}
        viewBox={
          fluid
            ? `${-40} ${-80} ${width + 80} ${height + 160}`
            : `0 0 ${width} ${height}`
        }
        style={fluid ? { display: "block", width: "100%", height: "auto" } : undefined}
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

        {ribbons.map((r) => (
          <path
            key={r.id}
            d={ribbonPath(r)}
            fill={r.color}
            opacity={opacityFor(r.id, r.opacity)}
            style={{ cursor: "pointer", transition: "opacity 120ms" }}
            onMouseEnter={() => enter(r.id, r.tipLabel, r.tipSub)}
            onMouseLeave={leave}
          />
        ))}

        {/* New-entrant / exit strips, placed in the gap between the two years they bridge. */}
        {transitions.map((t, idx) => {
          const src = columns[idx];
          const tgt = columns[idx + 1];
          const gapX = (src.x + barWidth + tgt.x) / 2 - barWidth / 2;
          const newCount = t.newToN40 + t.newToFT120;
          const exitCount = t.exitedN40 + t.exitedFT120;
          const span = `${t.from} → ${t.to}`;
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
                    opacity={opacityFor(`new-${idx}`, 1)}
                    style={{ cursor: "pointer", transition: "opacity 120ms" }}
                    onMouseEnter={() => enter(`new-${idx}`, "New entrants", `${span} · ${firms(newCount)}`)}
                    onMouseLeave={leave}
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
                      style={{ pointerEvents: "none" }}
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
                    opacity={opacityFor(`exit-${idx}`, 1)}
                    style={{ cursor: "pointer", transition: "opacity 120ms" }}
                    onMouseEnter={() => enter(`exit-${idx}`, "Exits", `${span} · ${firms(exitCount)}`)}
                    onMouseLeave={leave}
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
                      style={{ pointerEvents: "none" }}
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
              <rect
                x={c.x}
                y={c.n40Top}
                width={barWidth}
                height={n40Height}
                fill="#114563"
                opacity={opacityFor(`n40-${i}`, isCurrent ? 1 : 0.92)}
                style={{ cursor: "pointer", transition: "opacity 120ms" }}
                onMouseEnter={() => enter(`n40-${i}`, "Next 40", `${c.year} · ${firms(c.next40)}`)}
                onMouseLeave={leave}
              />
              <rect
                x={c.x}
                y={c.ft120Top}
                width={barWidth}
                height={ft120Height}
                fill="#3c6840"
                opacity={opacityFor(`ft120-${i}`, isCurrent ? 1 : 0.85)}
                style={{ cursor: "pointer", transition: "opacity 120ms" }}
                onMouseEnter={() => enter(`ft120-${i}`, "FT 120", `${c.year} · ${firms(c.ft120)}`)}
                onMouseLeave={leave}
              />

              {showLabels && (
                <g style={{ pointerEvents: "none" }}>
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
                  {isCurrent && announce && (
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
                <g style={{ pointerEvents: "none" }}>
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
          <g style={{ pointerEvents: "none" }}>
            <text x={2} y={topPad - 6} fontSize="9" fontFamily="Public Sans" fontWeight="600" letterSpacing="0.15em" fill="#41474d">
              NEW ENTRANTS
            </text>
            <text x={2} y={columns[0].ft120Bot + 16} fontSize="9" fontFamily="Public Sans" fontWeight="600" letterSpacing="0.15em" fill="#41474d">
              EXITS
            </text>
          </g>
        )}
      </svg>

      {tip && (
        <div
          style={{
            position: "absolute",
            left: pos.x + 14,
            top: pos.y + 14,
            pointerEvents: "none",
            background: "var(--color-on-surface)",
            color: "var(--color-surface)",
            padding: "6px 9px",
            lineHeight: 1.3,
            whiteSpace: "nowrap",
            zIndex: 10,
            boxShadow: "0 2px 8px rgba(0,0,0,0.18)",
          }}
        >
          <div style={{ fontFamily: "var(--font-body)", fontSize: 11, fontWeight: 700, letterSpacing: "0.02em" }}>
            {tip.label}
          </div>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 10, opacity: 0.85, marginTop: 1 }}>
            {tip.sub}
          </div>
        </div>
      )}
    </div>
  );
}
