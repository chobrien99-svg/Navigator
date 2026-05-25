import {
  ALL_TIME,
  ARRIVALS,
  COHORTS,
  HEADLINE,
  LEDGER,
  REGIONS,
  SECTORS,
  TAPE_NAMES,
  TRANSITIONS,
} from "./cohort-data";
import { CohortFlow } from "./charts/cohort-flow";
import { SectorTreemap } from "./charts/sector-treemap";
import { FranceMap } from "./charts/france-map";

const MINI_STATS = [
  { label: "New", v: "40", c: "#3c6840" },
  { label: "Promoted", v: "7", c: "#114563" },
  { label: "Demoted", v: "2", c: "#b8862c" },
  { label: "Exited", v: "40", c: "#963d3d" },
];

const LEGEND = [
  { label: "Next 40", c: "#114563" },
  { label: "FT 120", c: "#3c6840" },
  { label: "Promoted", c: "#114563" },
  { label: "Demoted", c: "#b8862c" },
  { label: "New entrants", c: "#3c6840" },
  { label: "Exited", c: "#963d3d" },
];

const NUMBERS_BAND = [
  { label: "Total cohort", v: String(HEADLINE.total) },
  { label: "Cumulative since 2020", v: String(ALL_TIME.totalTracked) },
  { label: "Capital raised", v: HEADLINE.totalRaised },
  { label: "Unicorns", v: String(HEADLINE.unicorns) },
];

export function FrenchTechBulletin() {
  return (
    <div
      className="dir-b"
      style={{
        background: "var(--color-background)",
        minHeight: "100%",
        minWidth: 1040,
        padding: "32px 48px 56px 48px",
        fontFamily: "var(--font-body)",
      }}
    >
      {/* ─── Masthead ─────────────────────── */}
      <div className="masthead-thick">
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            fontSize: 10,
            letterSpacing: "0.2em",
            textTransform: "uppercase",
            color: "var(--color-on-surface-variant)",
            fontWeight: 600,
            padding: "6px 0",
          }}
        >
          <span>The Navigator · Institutional Intelligence</span>
          <span>Vol. VI · Bulletin Nº 6</span>
          <span className="num" style={{ letterSpacing: "0.06em" }}>
            25 May 2025 · Paris
          </span>
        </div>
        <div
          style={{
            padding: "10px 0 14px 0",
            borderTop: "1px solid var(--color-on-surface)",
            borderBottom: "1px solid var(--color-on-surface)",
          }}
        >
          <div
            style={{
              fontFamily: "var(--font-headline)",
              fontSize: 64,
              fontWeight: 500,
              letterSpacing: "-0.02em",
              lineHeight: 1,
              textAlign: "center",
            }}
          >
            French Tech{" "}
            <span style={{ fontStyle: "italic", fontWeight: 400 }}>Next 40 / 120</span>
          </div>
          <div
            style={{
              marginTop: 8,
              textAlign: "center",
              fontSize: 11,
              letterSpacing: "0.4em",
              textTransform: "uppercase",
              color: "var(--color-on-surface-variant)",
              fontWeight: 600,
            }}
          >
            The Sixth Promotion · Special Edition
          </div>
        </div>
      </div>

      {/* ─── Lead spread: wide cohort flow + movements ledger ─── */}
      <div style={{ marginTop: 32, display: "grid", gridTemplateColumns: "2fr 1fr", gap: 36 }}>
        {/* Cohort flow (hero) */}
        <div>
          <div className="editorial-overline">Figure A · Cohort Flow</div>
          <h3
            style={{
              fontFamily: "var(--font-headline)",
              fontSize: 26,
              fontWeight: 500,
              letterSpacing: "-0.015em",
              margin: "10px 0 4px 0",
              lineHeight: 1.1,
            }}
          >
            Six cohorts at a glance
          </h3>
          <p
            style={{
              fontFamily: "var(--font-headline)",
              fontStyle: "italic",
              fontSize: 13,
              color: "var(--color-on-surface-variant)",
              lineHeight: 1.45,
              margin: "0 0 14px 0",
            }}
          >
            Movement between tiers, 2020 — 2025. Each annual cohort holds forty in the Next 40
            and eighty in FT 120; ribbons trace retentions, promotions, and demotions between
            adjacent years, with strips above and below quantifying new arrivals and exits.
          </p>

          <div
            style={{
              background: "white",
              padding: "20px 16px 12px 16px",
              border: "1px solid rgba(29,28,21,0.35)",
            }}
          >
            <CohortFlow
              cohorts={COHORTS}
              transitions={TRANSITIONS}
              width={900}
              height={520}
              barWidth={18}
              highlightYear={2025}
              tonal="spot"
            />
          </div>

          {/* Legend */}
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

          {/* By the numbers */}
          <div
            style={{
              marginTop: 24,
              display: "grid",
              gridTemplateColumns: "repeat(4, 1fr)",
              borderTop: "1px solid var(--color-on-surface)",
            }}
          >
            {NUMBERS_BAND.map((s, i) => (
              <div
                key={s.label}
                style={{
                  padding: "14px 18px 4px 0",
                  borderLeft: i === 0 ? "none" : "1px solid rgba(29,28,21,0.18)",
                  paddingLeft: i === 0 ? 0 : 18,
                }}
              >
                <div className="diplomatic-label" style={{ fontSize: 9 }}>
                  {s.label}
                </div>
                <div
                  className="num"
                  style={{
                    fontFamily: "var(--font-headline)",
                    fontSize: 40,
                    fontWeight: 400,
                    letterSpacing: "-0.02em",
                    lineHeight: 1,
                    marginTop: 8,
                    color: "var(--color-on-surface)",
                  }}
                >
                  {s.v}
                </div>
              </div>
            ))}
          </div>

          <div
            style={{
              marginTop: 24,
              fontSize: 10.5,
              fontFamily: "var(--font-mono)",
              color: "var(--color-on-surface-variant)",
              letterSpacing: "0.04em",
              lineHeight: 1.5,
            }}
          >
            SOURCE: LA FRENCH TECH, MESR
            <br />
            READING: 2024 → 2025 TRANSITION HIGHLIGHTED; EARLIER YEARS DESATURATED FOR EMPHASIS.
          </div>
        </div>

        {/* Movements ledger */}
        <div>
          <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
            Movements ledger
          </div>
          <h3
            style={{
              fontFamily: "var(--font-headline)",
              fontSize: 20,
              fontWeight: 500,
              letterSpacing: "-0.01em",
              margin: "10px 0 4px 0",
              lineHeight: 1.1,
            }}
          >
            The 2025 changes
          </h3>
          <p
            style={{
              fontFamily: "var(--font-headline)",
              fontStyle: "italic",
              fontSize: 12.5,
              color: "var(--color-on-surface-variant)",
              lineHeight: 1.45,
              margin: "0 0 16px 0",
            }}
          >
            All inter-cohort transitions, 2024 → 2025.
          </p>

          {/* Mini stat strip */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr 1fr 1fr",
              gap: 6,
              marginBottom: 18,
            }}
          >
            {MINI_STATS.map((d) => (
              <div
                key={d.label}
                style={{ padding: "8px 6px", background: "white", border: "1px solid rgba(193,199,206,0.55)" }}
              >
                <div className="diplomatic-label" style={{ fontSize: 8.5, color: d.c }}>
                  {d.label}
                </div>
                <div
                  className="num"
                  style={{
                    fontFamily: "var(--font-headline)",
                    fontSize: 26,
                    fontWeight: 500,
                    color: d.c,
                    lineHeight: 1,
                    marginTop: 2,
                  }}
                >
                  {d.v}
                </div>
              </div>
            ))}
          </div>

          {/* Ledger */}
          <div>
            <div className="ledger-row head">
              <span></span>
              <span>Company</span>
              <span style={{ textAlign: "right" }}>From</span>
              <span style={{ textAlign: "right" }}>To</span>
            </div>
            {LEDGER.map((r, i) => (
              <div className="ledger-row" key={i}>
                <span style={{ color: r.color, fontWeight: 700, fontSize: 13 }}>{r.sym}</span>
                <span style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}>{r.name}</span>
                <span className="num" style={{ fontSize: 10.5, color: "var(--color-on-surface-variant)", textAlign: "right" }}>
                  {r.from}
                </span>
                <span className="num" style={{ fontSize: 10.5, color: r.color, textAlign: "right", fontWeight: 600 }}>
                  {r.to}
                </span>
              </div>
            ))}
            <div
              style={{
                marginTop: 8,
                fontSize: 10.5,
                fontFamily: "var(--font-headline)",
                fontStyle: "italic",
                color: "var(--color-on-surface-variant)",
              }}
            >
              Showing 24 of 89 movements.{" "}
              <a href="#" style={{ color: "var(--color-primary)" }}>
                View full ledger ↗
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* ─── Double-rule divider ─────────────────── */}
      <div style={{ marginTop: 56, height: 0, borderTop: "4px double var(--color-on-surface)" }} />

      {/* ─── Arrivals ────────────────── */}
      <div style={{ marginTop: 36, display: "grid", gridTemplateColumns: "1fr auto", alignItems: "baseline", gap: 24 }}>
        <div>
          <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
            Inside · Arrivals
          </div>
          <h2
            style={{
              fontFamily: "var(--font-headline)",
              fontSize: 40,
              fontWeight: 500,
              letterSpacing: "-0.02em",
              margin: "12px 0 0 0",
              lineHeight: 1.02,
            }}
          >
            The forty newcomers, in brief
          </h2>
        </div>
        <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)" }}>
          Figure B · Eight to the top, thirty-two below
        </div>
      </div>

      <div
        style={{
          marginTop: 32,
          columnCount: 4,
          columnGap: 28,
          columnRule: "1px solid rgba(29,28,21,0.2)",
        }}
      >
        {ARRIVALS.slice(0, 20).map((a) => (
          <div
            key={a.name}
            style={{ breakInside: "avoid", marginBottom: 22, display: "flex", flexDirection: "column", gap: 6 }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
              <span
                className={`tier-tag ${a.tier === "Next 40" ? "next40" : "ft120"}`}
                style={{ fontSize: 8.5, padding: "2px 5px" }}
              >
                {a.tier === "Next 40" ? "N40" : "120"}
              </span>
              <span style={{ fontFamily: "var(--font-headline)", fontSize: 17, fontWeight: 600, color: "var(--color-on-surface)" }}>
                {a.name}
              </span>
            </div>
            <div
              style={{
                fontSize: 9.5,
                letterSpacing: "0.1em",
                textTransform: "uppercase",
                color: "var(--color-on-surface-variant)",
                fontWeight: 600,
              }}
            >
              {a.sector} · {a.city}
            </div>
            <p style={{ fontFamily: "var(--font-headline)", fontSize: 12.5, lineHeight: 1.45, margin: 0, color: "var(--color-on-surface)" }}>
              {a.note}
            </p>
            <div style={{ fontSize: 10.5, fontFamily: "var(--font-mono)", color: "var(--color-primary)", fontWeight: 600 }}>
              {a.raised} raised
            </div>
          </div>
        ))}
      </div>

      <div
        style={{
          marginTop: 24,
          padding: "12px 16px",
          background: "var(--color-on-surface)",
          color: "var(--color-background)",
          fontSize: 11,
          letterSpacing: "0.1em",
          textTransform: "uppercase",
          fontWeight: 600,
        }}
      >
        + 20 more arrivals continue overleaf →
      </div>

      {/* ─── Sectors + Geography ───────────────── */}
      <div style={{ marginTop: 48, display: "grid", gridTemplateColumns: "5fr 7fr", gap: 36 }}>
        <div>
          <div style={{ height: 0, borderTop: "2px solid var(--color-on-surface)", marginBottom: 16 }} />
          <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
            Figure C · Sectors
          </div>
          <h2
            style={{
              fontFamily: "var(--font-headline)",
              fontSize: 32,
              fontWeight: 500,
              letterSpacing: "-0.015em",
              margin: "8px 0 16px 0",
              lineHeight: 1.05,
            }}
          >
            AI consolidates, climate surges
          </h2>
          <SectorTreemap data={SECTORS} width={520} height={420} />
          <div
            style={{
              marginTop: 10,
              fontFamily: "var(--font-headline)",
              fontStyle: "italic",
              fontSize: 12,
              color: "var(--color-on-surface-variant)",
              lineHeight: 1.5,
            }}
          >
            Area proportional to count.{" "}
            <strong style={{ fontStyle: "normal", color: "var(--color-on-surface)" }}>Twenty-two</strong> AI-classified
            members; FinTech and SaaS remain anchor sectors.
          </div>
        </div>

        <div>
          <div style={{ height: 0, borderTop: "2px solid var(--color-on-surface)", marginBottom: 16 }} />
          <div style={{ display: "grid", gridTemplateColumns: "1fr auto", alignItems: "baseline", gap: 16, marginBottom: 16 }}>
            <div>
              <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
                Figure D · Where they sit
              </div>
              <h2
                style={{
                  fontFamily: "var(--font-headline)",
                  fontSize: 32,
                  fontWeight: 500,
                  letterSpacing: "-0.015em",
                  margin: "8px 0 0 0",
                  lineHeight: 1.05,
                }}
              >
                Geography of the cohort
              </h2>
            </div>
            <div
              style={{
                display: "flex",
                gap: 16,
                fontSize: 11,
                color: "var(--color-on-surface-variant)",
                fontWeight: 600,
                letterSpacing: "0.06em",
                textTransform: "uppercase",
              }}
            >
              <span>
                <strong style={{ color: "var(--color-on-surface)" }}>78</strong> Paris
              </span>
              <span>
                <strong style={{ color: "var(--color-on-surface)" }}>42</strong> Province
              </span>
            </div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 220px", gap: 18 }}>
            <FranceMap regions={REGIONS} width={560} height={500} />

            <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
              <div className="diplomatic-label" style={{ marginBottom: 6 }}>
                City Ranking
              </div>
              {REGIONS.slice(0, 10).map((r, i) => (
                <div
                  key={r.city}
                  className="hairline-bot"
                  style={{
                    paddingBottom: 6,
                    display: "grid",
                    gridTemplateColumns: "20px 1fr 32px 28px",
                    alignItems: "baseline",
                    gap: 8,
                    fontSize: 12,
                  }}
                >
                  <span className="num" style={{ fontSize: 10, color: "var(--color-on-surface-variant)" }}>
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <span style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}>{r.city}</span>
                  <span className="num" style={{ textAlign: "right", fontWeight: 600 }}>
                    {r.count}
                  </span>
                  <span
                    className="num"
                    style={{
                      textAlign: "right",
                      fontSize: 10,
                      color: r.delta > 0 ? "#3c6840" : r.delta < 0 ? "#963d3d" : "#72787e",
                    }}
                  >
                    {r.delta > 0 ? `+${r.delta}` : r.delta === 0 ? "·" : r.delta}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* ─── The Tape ─────────────────────────── */}
      <div style={{ marginTop: 56 }}>
        <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)", marginBottom: 8 }}>
          The Tape · Active cohort, alphabetical
        </div>
        <div className="tape">
          <div style={{ padding: "0 24px", fontFamily: "var(--font-mono)", fontSize: 12.5, letterSpacing: "0.04em", fontWeight: 500 }}>
            {TAPE_NAMES.join("  ·  ")}  ·  + 73 more
          </div>
        </div>
      </div>

      {/* ─── Footer ────────────────────────── */}
      <div
        style={{
          marginTop: 56,
          display: "grid",
          gridTemplateColumns: "1fr 1fr 1fr",
          gap: 24,
          fontSize: 11,
          color: "var(--color-on-surface-variant)",
          paddingTop: 18,
          borderTop: "1px solid rgba(29,28,21,0.35)",
        }}
      >
        <div>
          <div className="editorial-overline" style={{ marginBottom: 6 }}>
            Edition
          </div>
          <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55 }}>
            The Navigator · Bulletin Nº 6
            <br />
            Published 25 May 2025 · Paris
          </p>
        </div>
        <div>
          <div className="editorial-overline" style={{ marginBottom: 6 }}>
            Sources
          </div>
          <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55 }}>
            La French Tech / DGE · Ministère de l&apos;Économie · INSEE · Navigator entity graph
          </p>
        </div>
        <div style={{ textAlign: "right" }}>
          <div className="editorial-overline" style={{ marginBottom: 6 }}>
            Continued inside
          </div>
          <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55, fontStyle: "italic" }}>
            Sector deep-dives · Alumni outcomes · Funding trajectories · Methodology
          </p>
        </div>
      </div>
    </div>
  );
}
