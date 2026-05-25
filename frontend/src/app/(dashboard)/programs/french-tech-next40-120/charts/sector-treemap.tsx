import type { Sector } from "../cohort-data";

type SectorTreemapProps = {
  data: Sector[];
  width?: number;
  height?: number;
};

const PALETTE = [
  "#114563", "#2f5d7c", "#3c6840", "#503863", "#5e8c61", "#7c8c9e",
  "#b8862c", "#963d3d", "#9fccef", "#a2d3a2", "#c4b894", "#dabbef",
];

// Slice-and-dice treemap (1-D split rows).
export function SectorTreemap({ data, width = 480, height = 280 }: SectorTreemapProps) {
  const total = data.reduce((s, d) => s + d.count, 0);
  const cells: (Sector & { x: number; y: number; w: number; h: number; rowIdx: number })[] = [];

  const rowSplits = [4, 3, 3, 2];
  let cursorY = 0;
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
      cells.push({ ...d, x: cursorX, y: cursorY, w, h: rowHeight, rowIdx });
      cursorX += w;
    });
    cursorY += rowHeight;
  }

  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      style={{ display: "block", width: "100%", height: "auto" }}
    >
      {cells.map((c, i) => {
        const isWide = c.w > 80 && c.h > 40;
        const isMedium = c.w > 50 && c.h > 28;
        return (
          <g key={c.sector}>
            <rect
              x={c.x}
              y={c.y}
              width={c.w}
              height={c.h}
              fill={PALETTE[i % PALETTE.length]}
              opacity={0.88}
              stroke="#fef9ee"
              strokeWidth="2"
            />
            {isWide && (
              <>
                <text x={c.x + 10} y={c.y + 22} fontSize="12" fontFamily="Public Sans" fontWeight="600" fill="white" letterSpacing="0.01em">
                  {c.sector}
                </text>
                <text
                  x={c.x + 10}
                  y={c.y + c.h - 12}
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
                <text x={c.x + 7} y={c.y + 16} fontSize="9.5" fontFamily="Public Sans" fontWeight="600" fill="white">
                  {c.sector.length > 14 ? c.sector.slice(0, 12) + "…" : c.sector}
                </text>
                <text x={c.x + 7} y={c.y + c.h - 8} fontSize="14" fontFamily="Newsreader" fill="white" style={{ fontVariantNumeric: "tabular-nums" }}>
                  {c.count}
                </text>
              </>
            )}
            {!isWide && !isMedium && (
              <text x={c.x + c.w / 2} y={c.y + c.h / 2 + 3} fontSize="10" fontFamily="JetBrains Mono" fontWeight="600" fill="white" textAnchor="middle">
                {c.count}
              </text>
            )}
          </g>
        );
      })}
    </svg>
  );
}
