import Link from "next/link";
import type { BulletinData } from "./cohort-data";
import { capitalize, numberToWords } from "./cohort-transform";
import { CohortFlow } from "./charts/cohort-flow";
import { SectorTreemap } from "./charts/sector-treemap";

const LEGEND = [
  { label: "Next 40", c: "#114563" },
  { label: "FT 120", c: "#3c6840" },
  { label: "Promoted", c: "#114563" },
  { label: "Demoted", c: "#b8862c" },
  { label: "New entrants", c: "#3c6840" },
  { label: "Exited", c: "#963d3d" },
];

function BulletinShell({
  children,
  embed = false,
}: {
  children: React.ReactNode;
  embed?: boolean;
}) {
  return (
    <div
      className="dir-b"
      style={{
        background: "var(--color-background)",
        minHeight: "100%",
        minWidth: 1040,
        width: embed ? "100%" : undefined,
        padding: embed ? "24px 32px 40px 32px" : "32px 48px 56px 48px",
        fontFamily: "var(--font-body)",
      }}
    >
      {children}
    </div>
  );
}

// Renders an entity reference as a navigable link on the live site, or as
// plain text in embed mode (so external embeds never pull readers off-site).
function MaybeLink({
  embed,
  href,
  className,
  style,
  children,
}: {
  embed: boolean;
  href: string;
  className?: string;
  style?: React.CSSProperties;
  children: React.ReactNode;
}) {
  if (embed) {
    return (
      <span className={className} style={style}>
        {children}
      </span>
    );
  }
  return (
    <Link href={href} className={className} style={style}>
      {children}
    </Link>
  );
}

export function FrenchTechBulletin({
  data,
  error,
  archiveHref,
  isHistoric = false,
  embed = false,
}: {
  data: BulletinData | null;
  error?: string | null;
  archiveHref?: string;
  isHistoric?: boolean;
  embed?: boolean;
}) {
  if (!data || data.cohorts.length === 0) {
    return (
      <BulletinShell embed={embed}>
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
          <h2 style={{ fontSize: 28, fontWeight: 500, margin: "12px 0 8px 0" }}>
            Cohort data unavailable
          </h2>
          <p style={{ fontSize: 13, color: "var(--color-on-surface-variant)", margin: 0 }}>
            {error ?? "No cohort editions were returned from the Navigator database."}
          </p>
        </div>
      </BulletinShell>
    );
  }

  const {
    meta,
    cohorts,
    transitions,
    arrivals,
    arrivalsMeta,
    sectors,
    sectorsMeta,
    regions,
    geo,
    ledger,
    ledgerMeta,
    miniStats,
    numbers,
    tape,
    roster,
  } = data;

  const firstYear = cohorts[0].year;
  const latestYear = meta.latestYear;
  const prevYear = cohorts.length > 1 ? cohorts[cohorts.length - 2].year : firstYear;

  const miniStatCards = [
    { label: "New", v: String(miniStats.newCount), c: "#3c6840" },
    { label: "Promoted", v: String(miniStats.promoted), c: "#114563" },
    { label: "Demoted", v: String(miniStats.demoted), c: "#b8862c" },
    { label: "Exited", v: String(miniStats.exited), c: "#963d3d" },
  ];

  const numbersBand = [
    { label: "Total cohort", v: String(numbers.total) },
    { label: `Cumulative since ${firstYear}`, v: String(numbers.cumulative) },
    { label: "Next 40", v: String(numbers.next40) },
    { label: "FT 120", v: String(numbers.ft120) },
  ];

  const sectorLeaderCount = sectors[0]?.count ?? 0;
  const classifiedTotal = sectors.reduce((s, d) => s + d.count, 0);
  const sectorsTitle = sectorsMeta.gainer
    ? `${sectorsMeta.leader} leads, ${sectorsMeta.gainer} climbs`
    : `${sectorsMeta.leader} leads the cohort`;

  return (
    <BulletinShell embed={embed}>
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
          <span>
            Vol. {meta.roman} · Bulletin Nº {meta.bulletinNo}
          </span>
          <span className="num" style={{ letterSpacing: "0.06em" }}>
            Promotion {latestYear} · Paris
          </span>
          {archiveHref && !embed && (
            <Link href={archiveHref} className="entity-link" style={{ fontWeight: 600 }}>
              All editions →
            </Link>
          )}
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
            The {meta.ordinalWord} Promotion · {isHistoric ? "Archived Edition" : "Special Edition"}
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
            {capitalize(numberToWords(cohorts.length))} cohorts at a glance
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
            Movement between tiers, {firstYear} — {latestYear}. Each annual cohort holds forty in
            the Next 40 and eighty in FT 120; ribbons trace retentions, promotions, and demotions
            between adjacent years, with strips above and below quantifying new arrivals and exits.
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
              announce={!isHistoric}
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
            {numbersBand.map((s, i) => (
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
            SOURCE: LA FRENCH TECH, MESR · NAVIGATOR ENTITY GRAPH
            <br />
            READING: {prevYear} → {latestYear} TRANSITION HIGHLIGHTED; EARLIER YEARS DESATURATED FOR
            EMPHASIS.
          </div>

          {/* Newcomers — compact list */}
          <div style={{ marginTop: 28, paddingTop: 18, borderTop: "2px solid var(--color-on-surface)" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 16, marginBottom: 14 }}>
              <div>
                <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
                  Figure B · Arrivals
                </div>
                <h3
                  style={{
                    fontFamily: "var(--font-headline)",
                    fontSize: 20,
                    fontWeight: 500,
                    letterSpacing: "-0.01em",
                    margin: "10px 0 0 0",
                    lineHeight: 1.1,
                  }}
                >
                  The {numberToWords(arrivalsMeta.total)} newcomers
                </h3>
              </div>
              <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)", textAlign: "right" }}>
                {capitalize(numberToWords(arrivalsMeta.toNext40))} to the top,{" "}
                {numberToWords(arrivalsMeta.toFt120)} below
              </div>
            </div>

            <div style={{ columnCount: 2, columnGap: 24, columnRule: "1px solid rgba(29,28,21,0.2)" }}>
              {arrivals.map((a) => (
                <div
                  key={a.name}
                  style={{ breakInside: "avoid", marginBottom: 14, display: "flex", flexDirection: "column", gap: 4 }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
                    <span
                      className={`tier-tag ${a.tier === "Next 40" ? "next40" : "ft120"}`}
                      style={{ fontSize: 8, padding: "1px 4px" }}
                    >
                      {a.tier === "Next 40" ? "N40" : "120"}
                    </span>
                    <MaybeLink
                      embed={embed}
                      href={`/entities/${a.slug}`}
                      className="entity-link"
                      style={{ fontFamily: "var(--font-headline)", fontSize: 16, fontWeight: 600, color: "var(--color-on-surface)" }}
                    >
                      {a.name}
                    </MaybeLink>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 6, flexWrap: "wrap" }}>
                    {a.sector !== "—" && <span className="sector-tag">{a.sector}</span>}
                    <span
                      style={{
                        fontSize: 9,
                        letterSpacing: "0.08em",
                        textTransform: "uppercase",
                        color: "var(--color-on-surface-variant)",
                        fontWeight: 600,
                      }}
                    >
                      {a.city}
                    </span>
                  </div>
                  {a.note && (
                    <p
                      style={{
                        margin: 0,
                        fontFamily: "var(--font-headline)",
                        fontSize: 11.5,
                        lineHeight: 1.4,
                        color: "var(--color-on-surface)",
                        display: "-webkit-box",
                        WebkitLineClamp: 2,
                        WebkitBoxOrient: "vertical",
                        overflow: "hidden",
                      }}
                    >
                      {a.note}
                    </p>
                  )}
                </div>
              ))}
            </div>
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
            The {latestYear} changes
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
            All inter-cohort transitions, {prevYear} → {latestYear}.
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
            {miniStatCards.map((d) => (
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
            {ledger.map((r, i) => (
              <div className="ledger-row" key={`${r.name}-${i}`}>
                <span style={{ color: r.color, fontWeight: 700, fontSize: 13 }}>{r.sym}</span>
                <MaybeLink
                  embed={embed}
                  href={`/entities/${r.slug}`}
                  className="entity-link"
                  style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}
                >
                  {r.name}
                </MaybeLink>
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
              {capitalize(numberToWords(ledgerMeta.total))} movements in all.
            </div>
          </div>
        </div>
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
            {sectorsTitle}
          </h2>
          <SectorTreemap data={sectors} width={520} height={420} />
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
            <strong style={{ fontStyle: "normal", color: "var(--color-on-surface)" }}>
              {capitalize(numberToWords(sectorLeaderCount))}
            </strong>{" "}
            {sectorsMeta.leader}-classified members lead; composition shown for {classifiedTotal} of{" "}
            {numbers.total} members with a recorded sector.
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
                <strong style={{ color: "var(--color-on-surface)" }}>{geo.paris}</strong> Paris
              </span>
              <span>
                <strong style={{ color: "var(--color-on-surface)" }}>{geo.province}</strong> Province
              </span>
            </div>
          </div>

          <div>
            <div className="diplomatic-label" style={{ marginBottom: 10 }}>
              City Ranking
            </div>
            <div style={{ columnCount: 2, columnGap: 32 }}>
              {regions.slice(0, 10).map((r, i) => (
                <div
                  key={r.city}
                  className="hairline-bot"
                  style={{
                    paddingBottom: 6,
                    marginBottom: 6,
                    breakInside: "avoid",
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
            <div
              style={{
                marginTop: 8,
                fontSize: 10,
                fontFamily: "var(--font-headline)",
                fontStyle: "italic",
                color: "var(--color-on-surface-variant)",
                lineHeight: 1.4,
              }}
            >
              Located: {geo.located} of {geo.total} members with a recorded city.
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
            {tape.names.map((t, i) => (
              <span key={t.slug || t.name}>
                {i > 0 ? "  ·  " : ""}
                <MaybeLink embed={embed} href={`/entities/${t.slug}`} className="entity-link">
                  {t.name}
                </MaybeLink>
              </span>
            ))}
            {tape.remaining > 0 ? `  ·  + ${tape.remaining} more` : ""}
          </div>
        </div>
      </div>

      {/* ─── The Promotion · Full Cohort ─────────── */}
      <div style={{ marginTop: 56 }}>
        <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
          Figure E · The Promotion
        </div>
        <h2
          style={{
            fontFamily: "var(--font-headline)",
            fontSize: 32,
            fontWeight: 500,
            letterSpacing: "-0.015em",
            margin: "8px 0 4px 0",
            lineHeight: 1.05,
          }}
        >
          The {latestYear} cohort in full
        </h2>
        <p
          style={{
            fontFamily: "var(--font-headline)",
            fontStyle: "italic",
            fontSize: 13,
            color: "var(--color-on-surface-variant)",
            lineHeight: 1.45,
            margin: "0 0 4px 0",
          }}
        >
          All {numbers.total} members of Promotion {latestYear}, by tier and alphabetical.
        </p>

        {(["Next 40", "FT 120"] as const).map((tier) => {
          const list = tier === "Next 40" ? roster.next40 : roster.ft120;
          if (list.length === 0) return null;
          return (
            <div
              key={tier}
              style={{
                marginTop: 28,
                paddingTop: 16,
                borderTop: "2px solid var(--color-on-surface)",
              }}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "baseline",
                  marginBottom: 14,
                }}
              >
                <h3
                  style={{
                    fontFamily: "var(--font-headline)",
                    fontSize: 22,
                    fontWeight: 500,
                    letterSpacing: "-0.01em",
                    margin: 0,
                    lineHeight: 1.1,
                  }}
                >
                  {tier}{" "}
                  <span
                    className="num"
                    style={{
                      fontFamily: "var(--font-mono)",
                      fontSize: 13,
                      color: "var(--color-on-surface-variant)",
                      fontWeight: 500,
                      letterSpacing: "0.04em",
                    }}
                  >
                    · {list.length}
                  </span>
                </h3>
              </div>

              <div
                style={{
                  columnCount: tier === "Next 40" ? 3 : 4,
                  columnGap: 28,
                }}
              >
                {list.map((m, i) => (
                  <div
                    key={m.slug || m.name}
                    className="hairline-bot"
                    style={{
                      paddingBottom: 7,
                      marginBottom: 7,
                      breakInside: "avoid",
                      display: "grid",
                      gridTemplateColumns: "22px 1fr",
                      columnGap: 8,
                      alignItems: "baseline",
                    }}
                  >
                    <span
                      className="num"
                      style={{
                        fontSize: 9,
                        color: "var(--color-on-surface-variant)",
                        fontVariantNumeric: "tabular-nums",
                      }}
                    >
                      {String(i + 1).padStart(2, "0")}
                    </span>
                    <div style={{ minWidth: 0 }}>
                      <MaybeLink
                        embed={embed}
                        href={`/entities/${m.slug}`}
                        className="entity-link"
                        style={{
                          display: "block",
                          fontFamily: "var(--font-headline)",
                          fontSize: 13,
                          fontWeight: 600,
                          color: "var(--color-on-surface)",
                          lineHeight: 1.2,
                        }}
                      >
                        {m.name}
                      </MaybeLink>
                      <div
                        style={{
                          marginTop: 2,
                          fontSize: 9,
                          color: "var(--color-on-surface-variant)",
                          letterSpacing: "0.08em",
                          textTransform: "uppercase",
                          fontWeight: 600,
                          lineHeight: 1.3,
                        }}
                      >
                        {m.sector !== "—" ? m.sector : ""}
                        {m.sector !== "—" && m.city !== "—" ? " · " : ""}
                        {m.city !== "—" ? m.city : ""}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
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
            The Navigator · Bulletin Nº {meta.bulletinNo}
            <br />
            Promotion {latestYear} · Paris
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
    </BulletinShell>
  );
}
