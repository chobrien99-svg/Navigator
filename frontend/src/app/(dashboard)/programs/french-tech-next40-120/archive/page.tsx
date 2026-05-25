import Link from "next/link";
import { getFrenchTechNextMembers } from "@/lib/queries";
import { buildEditionIndex } from "../cohort-transform";
import type { EditionSummary } from "../cohort-data";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "French Tech Next 40/120 — Editions Archive | The Navigator",
};

export default async function FrenchTechArchivePage() {
  let editions: EditionSummary[] = [];
  let error: string | null = null;

  try {
    const rows = await getFrenchTechNextMembers();
    editions = buildEditionIndex(rows);
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load French Tech editions";
  }

  const firstYear = editions[0]?.year;
  const latestYear = editions[editions.length - 1]?.year;
  const ordered = [...editions].reverse();

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
      {/* Masthead */}
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
          <span>Editions Archive</span>
          {latestYear && (
            <Link href={`/programs/french-tech-next40-120/${latestYear}`} className="entity-link" style={{ fontWeight: 600 }}>
              Latest edition →
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
              fontSize: 56,
              fontWeight: 500,
              letterSpacing: "-0.02em",
              lineHeight: 1,
              textAlign: "center",
            }}
          >
            French Tech <span style={{ fontStyle: "italic", fontWeight: 400 }}>Next 40 / 120</span>
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
            Every Promotion {firstYear && latestYear ? `· ${firstYear} — ${latestYear}` : ""}
          </div>
        </div>
      </div>

      {error || editions.length === 0 ? (
        <div
          style={{
            marginTop: 40,
            border: "1px solid rgba(29,28,21,0.35)",
            padding: "40px 32px",
            textAlign: "center",
            fontFamily: "var(--font-headline)",
          }}
        >
          <h2 style={{ fontSize: 24, fontWeight: 500, margin: "0 0 8px 0" }}>No editions available</h2>
          <p style={{ fontSize: 13, color: "var(--color-on-surface-variant)", margin: 0 }}>
            {error ?? "No promotion years were returned from the Navigator database."}
          </p>
        </div>
      ) : (
        <div
          style={{
            marginTop: 36,
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            gap: 20,
          }}
        >
          {ordered.map((ed) => (
            <Link
              key={ed.year}
              href={`/programs/french-tech-next40-120/${ed.year}`}
              className="edition-card"
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
                <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
                  Bulletin Nº {ed.roman}
                </div>
                {ed.current && (
                  <span className="tier-tag next40" style={{ fontSize: 8 }}>
                    Current
                  </span>
                )}
              </div>

              <div
                style={{
                  fontFamily: "var(--font-headline)",
                  fontSize: 44,
                  fontWeight: 500,
                  letterSpacing: "-0.02em",
                  lineHeight: 1,
                  margin: "10px 0 2px 0",
                }}
              >
                {ed.year}
              </div>
              <div
                style={{
                  fontSize: 10,
                  letterSpacing: "0.12em",
                  textTransform: "uppercase",
                  color: "var(--color-on-surface-variant)",
                  fontWeight: 600,
                }}
              >
                The {ed.ordinalWord} Promotion
              </div>

              <div
                style={{
                  marginTop: 16,
                  paddingTop: 12,
                  borderTop: "1px solid rgba(29,28,21,0.2)",
                  display: "grid",
                  gridTemplateColumns: "1fr 1fr 1fr",
                  gap: 8,
                }}
              >
                {[
                  { k: "Cohort", v: ed.total },
                  { k: "Next 40", v: ed.next40 },
                  { k: "FT 120", v: ed.ft120 },
                ].map((s) => (
                  <div key={s.k}>
                    <div className="diplomatic-label" style={{ fontSize: 8 }}>
                      {s.k}
                    </div>
                    <div
                      className="num"
                      style={{ fontFamily: "var(--font-headline)", fontSize: 22, fontWeight: 500, lineHeight: 1, marginTop: 3 }}
                    >
                      {s.v}
                    </div>
                  </div>
                ))}
              </div>

              <div
                style={{
                  marginTop: 14,
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  fontSize: 11,
                  fontWeight: 600,
                  letterSpacing: "0.06em",
                  textTransform: "uppercase",
                  color: "var(--color-on-surface-variant)",
                }}
              >
                <span style={{ color: "var(--color-secondary)" }}>+{ed.newCount} new</span>
                <span>Read edition →</span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
