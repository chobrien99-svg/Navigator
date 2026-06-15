import { getFrenchTechNextMembers } from "@/lib/queries";
import { buildBulletinData } from "@/app/(dashboard)/programs/french-tech-next40-120/cohort-transform";
import { CohortFlow } from "@/app/(dashboard)/programs/french-tech-next40-120/charts/cohort-flow";
import type { BulletinData } from "@/app/(dashboard)/programs/french-tech-next40-120/cohort-data";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "French Tech Next 40/120 — Cohort Flow",
  robots: { index: false, follow: false },
};

const LEGEND = [
  { label: "Next 40", c: "#114563" },
  { label: "FT 120", c: "#3c6840" },
  { label: "Promoted", c: "#114563" },
  { label: "Demoted", c: "#b8862c" },
  { label: "New entrants", c: "#3c6840" },
  { label: "Exited", c: "#963d3d" },
];

// Chrome-free embed of Figure A — the cohort flow chart, ribbons across
// every promotion year — for iframing into the French Tech Journal site.
export default async function CohortFlowEmbedPage() {
  let data: BulletinData | null = null;
  let error: string | null = null;

  try {
    const rows = await getFrenchTechNextMembers();
    data = buildBulletinData(rows);
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load cohort data";
  }

  const shellStyle: React.CSSProperties = {
    background: "var(--color-background)",
    minHeight: "100vh",
    padding: "24px clamp(16px, 3vw, 40px) 32px",
    fontFamily: "var(--font-body)",
  };

  if (!data || data.cohorts.length === 0) {
    return (
      <main className="dir-b" style={shellStyle}>
        <div
          style={{
            border: "1px solid rgba(29,28,21,0.35)",
            padding: "48px 32px",
            textAlign: "center",
            fontFamily: "var(--font-headline)",
          }}
        >
          <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
            French Tech Next 40 / 120
          </div>
          <h2 style={{ fontSize: 24, fontWeight: 500, margin: "12px 0 8px 0" }}>
            Cohort data unavailable
          </h2>
          <p style={{ fontSize: 13, color: "var(--color-on-surface-variant)", margin: 0 }}>
            {error ?? "No cohort editions were returned from the Navigator database."}
          </p>
        </div>
      </main>
    );
  }

  const { cohorts, transitions, meta } = data;
  const firstYear = cohorts[0].year;
  const latestYear = meta.latestYear;
  const prevYear =
    cohorts.length > 1 ? cohorts[cohorts.length - 2].year : firstYear;

  return (
    <main className="dir-b" style={shellStyle}>
      <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
        Figure · Cohort Flow
      </div>
      <h2
        style={{
          fontFamily: "var(--font-headline)",
          fontSize: 28,
          fontWeight: 500,
          letterSpacing: "-0.015em",
          margin: "8px 0 4px 0",
          lineHeight: 1.1,
        }}
      >
        French Tech Next 40 / 120 · {firstYear}–{latestYear}
      </h2>
      <p
        style={{
          fontFamily: "var(--font-headline)",
          fontStyle: "italic",
          fontSize: 13,
          color: "var(--color-on-surface-variant)",
          lineHeight: 1.45,
          margin: "0 0 16px 0",
        }}
      >
        Each annual cohort holds forty in the Next 40 and eighty in FT 120; ribbons
        trace retentions, promotions, and demotions between adjacent years, with
        strips above and below quantifying new arrivals and exits.
      </p>

      <div
        style={{
          background: "white",
          padding: "20px 16px 12px 16px",
          border: "1px solid rgba(29,28,21,0.35)",
        }}
      >
        <CohortFlow
          cohorts={cohorts}
          transitions={transitions}
          width={900}
          height={520}
          barWidth={18}
          highlightYear={latestYear}
          tonal="spot"
          announce
          fluid
        />
      </div>

      <div
        style={{
          marginTop: 14,
          display: "flex",
          flexWrap: "wrap",
          gap: "8px 22px",
          paddingTop: 12,
          borderTop: "1px solid rgba(29,28,21,0.35)",
        }}
      >
        {LEGEND.map((l) => (
          <span key={l.label} style={{ display: "inline-flex", alignItems: "center", gap: 7 }}>
            <span style={{ width: 12, height: 12, background: l.c, display: "inline-block" }} />
            <span
              style={{
                fontSize: 10,
                fontWeight: 600,
                letterSpacing: "0.12em",
                textTransform: "uppercase",
                color: "var(--color-on-surface-variant)",
              }}
            >
              {l.label}
            </span>
          </span>
        ))}
      </div>

      <div
        style={{
          marginTop: 18,
          fontSize: 10.5,
          fontFamily: "var(--font-mono)",
          color: "var(--color-on-surface-variant)",
          letterSpacing: "0.04em",
          lineHeight: 1.5,
        }}
      >
        SOURCE: LA FRENCH TECH, MESR · NAVIGATOR ENTITY GRAPH
        <br />
        READING: {prevYear} → {latestYear} TRANSITION HIGHLIGHTED; EARLIER YEARS DESATURATED FOR EMPHASIS.
        <br />
        FRENCH TECH JOURNAL / NAVIGATOR
      </div>
    </main>
  );
}
