import type { Region } from "../cohort-data";

type FranceMapProps = {
  regions: Region[];
  width?: number;
  height?: number;
  accent?: string;
};

const DESIGN_W = 800;
const DESIGN_H = 640;

const FRANCE_PATH = `
  M 396 22 L 432 18 L 478 28 L 510 42 L 545 56 L 580 78 L 616 95 L 645 86
  L 682 92 L 705 118 L 720 145 L 712 178 L 745 198 L 768 232 L 752 268
  L 712 285 L 690 320 L 700 360 L 738 402 L 716 440 L 695 478 L 678 506
  L 650 540 L 615 558 L 568 565 L 530 562 L 488 568 L 445 562 L 402 568
  L 358 558 L 318 542 L 280 555 L 245 542 L 220 510 L 232 478 L 210 440
  L 175 422 L 145 395 L 122 360 L 96 330 L 70 295 L 48 258 L 65 225
  L 102 198 L 125 168 L 110 138 L 138 110 L 175 95 L 205 110 L 240 92
  L 268 70 L 305 62 L 340 50 L 372 32 Z
`;

export function FranceMap({ regions, width = 480, height = 560, accent = "#114563" }: FranceMapProps) {
  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${DESIGN_W} ${DESIGN_H}`}
      style={{ display: "block", width: "100%", height: "auto" }}
    >
      <path d={FRANCE_PATH} fill="#fef9ee" stroke="#1d1c15" strokeWidth="1.5" strokeLinejoin="round" />
      <path d={FRANCE_PATH} fill="none" stroke="rgba(193, 199, 206, 0.65)" strokeWidth="6" />

      {regions.map((r) => {
        const radius = 6 + Math.sqrt(r.count) * 4.5;
        const isParis = r.city === "Paris";
        return (
          <g key={r.city} transform={`translate(${r.x}, ${r.y})`}>
            <circle r={radius} fill={isParis ? "#114563" : accent} opacity={isParis ? 0.92 : 0.78} />
            <circle r={radius} fill="none" stroke="#fef9ee" strokeWidth="1.5" opacity={0.6} />
            <text x={radius + 6} y={4} fontSize="11" fontFamily="Public Sans" fontWeight="600" fill="#1d1c15">
              {r.city}
            </text>
            <text x={radius + 6} y={18} fontSize="10" fontFamily="JetBrains Mono" fill="#41474d" style={{ fontVariantNumeric: "tabular-nums" }}>
              {r.count}
              {r.delta !== 0 ? ` (${r.delta > 0 ? "+" : ""}${r.delta})` : ""}
            </text>
          </g>
        );
      })}
    </svg>
  );
}
