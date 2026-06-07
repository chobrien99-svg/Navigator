// ─── Direction B: "Bulletin Nº 6" ────────────────────────
// Newspaper / front-page grid. Multi-column body, ledger, tape.

function DirectionB() {
  const arrivals = window.ARRIVALS_2026;
  const promotions = window.PROMOTIONS_2026;
  const exits = window.EXITS_2026;
  const sectors = window.SECTORS_2026;
  const regions = window.REGIONS_2026;
  const stats = window.HEADLINE_2026;

  // 50 listed companies for the bottom tape (a sampling)
  const tapeNames = [
    ...arrivals.slice(0, 14).map(a => a.name),
    "Alan", "Doctolib", "Mistral AI", "Qonto", "Ledger", "Back Market", "Contentsquare",
    "Brevo", "Pennylane", "Pigment", "Verkor", "Innovafeed", "Alice & Bob", "Electra",
    "Chapsvision", "Spendesk", "Mirakl", "Akeneo", "Aqemia", "Pasqal", "Swan", "Greenly",
    "Filigran", "Wandercraft", "BlaBlaCar", "EcoVadis", "ekWateur", "Vestiaire Collective",
    "Malt", "PayFit", "Exotec", "Flying Whales", "Voodoo",
  ];

  return (
    <window.NavChrome>
      <div className="dir-b" style={{
        background: "var(--color-background)",
        minHeight: "100%",
        padding: "32px 48px 56px 48px",
        fontFamily: "var(--font-body)",
      }}>

        {/* ─── Masthead ─────────────────────── */}
        <div className="masthead-thick">
          <div style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            fontSize: 10, letterSpacing: "0.2em", textTransform: "uppercase",
            color: "var(--color-on-surface-variant)", fontWeight: 600, padding: "6px 0",
          }}>
            <span>The Navigator · Institutional Intelligence</span>
            <span>Vol. VI · Bulletin Nº 6</span>
            <span className="num" style={{ letterSpacing: "0.06em" }}>25 May 2025 · Paris</span>
          </div>
          <div style={{ padding: "10px 0 14px 0", borderTop: "1px solid var(--color-on-surface)", borderBottom: "1px solid var(--color-on-surface)" }}>
            <div style={{
              fontFamily: "var(--font-headline)",
              fontSize: 64,
              fontWeight: 500,
              letterSpacing: "-0.02em",
              lineHeight: 1,
              textAlign: "center",
            }}>
              French Tech <span style={{ fontStyle: "italic", fontWeight: 400 }}>Next 40 / 120</span>
            </div>
            <div style={{
              marginTop: 8, textAlign: "center",
              fontSize: 11, letterSpacing: "0.4em", textTransform: "uppercase",
              color: "var(--color-on-surface-variant)", fontWeight: 600,
            }}>
              The Sixth Promotion · Special Edition
            </div>
          </div>
        </div>

        {/* ─── Lead Spread (3 columns) ─────────── */}
        <div style={{ marginTop: 32, display: "grid", gridTemplateColumns: "5fr 4fr 3fr", gap: 36 }}>

          {/* Lead column */}
          <div className="news-col">
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>Top of the bulletin</div>
            <h1 style={{
              fontFamily: "var(--font-headline)",
              fontSize: 48,
              fontWeight: 500,
              lineHeight: 1.02,
              letterSpacing: "-0.02em",
              margin: "12px 0 0 0",
              color: "var(--color-on-surface)",
            }}>
              Sixth cohort lands: <span style={{ fontStyle: "italic" }}>forty in,
              forty out</span> &mdash; AI tilts the balance
            </h1>
            <p className="editorial-dek" style={{ fontSize: 17, margin: "14px 0 24px 0" }}>
              The Class of 2025 marks the program's largest renewal cycle since 2020 &mdash; with
              arrivals concentrated in artificial intelligence, sovereign cybersecurity, and
              climate infrastructure.
            </p>
            <div className="editorial-byline" style={{ marginBottom: 18 }}>
              The Navigator · Institutional Research
              <span style={{ margin: "0 8px", color: "var(--color-outline-variant)" }}>·</span>
              22 May 2025 · 14h35
            </div>

            <p className="dropcap" style={{
              fontFamily: "var(--font-headline)", fontSize: 14.5, lineHeight: 1.6,
              color: "var(--color-on-surface)", margin: 0, columnCount: 2, columnGap: 24, columnRule: "1px solid rgba(29,28,21,0.2)",
              textAlign: "justify", hyphens: "auto",
            }}>
              La French Tech released the sixth promotion of its flagship Next 40 / 120
              programme on Thursday afternoon. Forty new companies enter the cohort, seven graduate
              from FT 120 into Next 40, two are demoted in the opposite direction, and forty exit
              the programme entirely &mdash; the largest single-year turnover since the
              programme's inception. Artificial-intelligence specialists account for 22% of the
              cohort, up from 16% one year earlier, with the entry of Dust, Linkup, LightOn, and
              Photoroom &mdash; alongside the promotion to Next 40 of generative-biology firm
              Aqemia and quantum hardware leader Pasqal. Climate-infrastructure companies
              continue their multi-year ascent, now reaching 11% of the active cohort.
              Cybersecurity, sustained by procurement policy, crosses the double-digit threshold
              for the first time with the arrival of Cosmian, Tehtris, and HarfangLab. Paris
              remains the dominant headquarters location, holding 65% of cohort members.
              Provincial representation is led by Lyon, Toulouse, and Grenoble &mdash; the latter
              gaining ground on the strength of deep-tech entries in batteries, microLED displays,
              and quantum hardware.
            </p>
          </div>

          {/* Flow viz column */}
          <div>
            <div className="editorial-overline">Figure A · Cohort Flow</div>
            <h3 style={{
              fontFamily: "var(--font-headline)",
              fontSize: 22, fontWeight: 500, letterSpacing: "-0.01em",
              margin: "10px 0 4px 0", lineHeight: 1.1,
            }}>
              Six cohorts at a glance
            </h3>
            <p style={{
              fontFamily: "var(--font-headline)", fontStyle: "italic",
              fontSize: 12.5, color: "var(--color-on-surface-variant)",
              lineHeight: 1.45, margin: "0 0 14px 0",
            }}>
              Movement between tiers, 2020 — 2025.
            </p>

            <div style={{ background: "white", padding: "16px 12px 8px 12px", border: "1px solid rgba(29,28,21,0.35)" }}>
              <window.CohortFlow width={420} height={460} highlightYear={2025} tonal="spot" barWidth={11} />
            </div>

            <div style={{ marginTop: 10, fontSize: 10.5, fontFamily: "var(--font-mono)", color: "var(--color-on-surface-variant)", letterSpacing: "0.04em", lineHeight: 1.5 }}>
              SOURCE: LA FRENCH TECH, MESR<br />
              READING: 2024 → 2025 TRANSITION HIGHLIGHTED;<br />
              EARLIER YEARS DESATURATED FOR EMPHASIS.
            </div>
          </div>

          {/* Movements ledger column */}
          <div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>Movements ledger</div>
            <h3 style={{
              fontFamily: "var(--font-headline)",
              fontSize: 20, fontWeight: 500, letterSpacing: "-0.01em",
              margin: "10px 0 4px 0", lineHeight: 1.1,
            }}>
              The 2025 changes
            </h3>
            <p style={{
              fontFamily: "var(--font-headline)", fontStyle: "italic",
              fontSize: 12.5, color: "var(--color-on-surface-variant)",
              lineHeight: 1.45, margin: "0 0 16px 0",
            }}>
              All inter-cohort transitions, 2024 → 2025.
            </p>

            {/* Mini stat strip */}
            <div style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr 1fr 1fr",
              gap: 6,
              marginBottom: 18,
            }}>
              {[
                { label: "New", v: "40", c: "#3c6840" },
                { label: "Promoted", v: "7", c: "#114563" },
                { label: "Demoted", v: "2", c: "#b8862c" },
                { label: "Exited", v: "40", c: "#963d3d" },
              ].map((d) => (
                <div key={d.label} style={{ padding: "8px 6px", background: "white", border: "1px solid rgba(193,199,206,0.55)" }}>
                  <div className="diplomatic-label" style={{ fontSize: 8.5, color: d.c }}>{d.label}</div>
                  <div className="num" style={{ fontFamily: "var(--font-headline)", fontSize: 26, fontWeight: 500, color: d.c, lineHeight: 1, marginTop: 2 }}>
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
              {[
                { sym: "↑", name: "Akeneo", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Aqemia", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Pasqal", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Swan", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Greenly", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Filigran", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↑", name: "Wandercraft", from: "FT 120", to: "Next 40", c: "#114563" },
                { sym: "↓", name: "Shift Technology", from: "Next 40", to: "FT 120", c: "#b8862c" },
                { sym: "↓", name: "Worldia", from: "Next 40", to: "FT 120", c: "#b8862c" },
                { sym: "+", name: "Dust", from: "—", to: "Next 40", c: "#3c6840" },
                { sym: "+", name: "Owkin", from: "—", to: "Next 40", c: "#3c6840" },
                { sym: "+", name: "Photoroom", from: "—", to: "Next 40", c: "#3c6840" },
                { sym: "+", name: "Sweep", from: "FT 120", to: "Next 40", c: "#3c6840" },
                { sym: "+", name: "Linkup", from: "—", to: "FT 120", c: "#3c6840" },
                { sym: "+", name: "LightOn", from: "—", to: "FT 120", c: "#3c6840" },
                { sym: "+", name: "Cosmian", from: "—", to: "FT 120", c: "#3c6840" },
                { sym: "+", name: "Tehtris", from: "—", to: "FT 120", c: "#3c6840" },
                { sym: "+", name: "HarfangLab", from: "—", to: "FT 120", c: "#3c6840" },
                { sym: "−", name: "Mirakl", from: "Next 40", to: "Exit", c: "#963d3d" },
                { sym: "−", name: "Doctolib", from: "Next 40", to: "IPO", c: "#963d3d" },
                { sym: "−", name: "Voodoo", from: "Next 40", to: "Exit", c: "#963d3d" },
                { sym: "−", name: "Equativ", from: "Next 40", to: "M&A", c: "#963d3d" },
                { sym: "−", name: "Brut", from: "FT 120", to: "Exit", c: "#963d3d" },
                { sym: "−", name: "Yubo", from: "FT 120", to: "M&A", c: "#963d3d" },
              ].map((r, i) => (
                <div className="ledger-row" key={i}>
                  <span style={{ color: r.c, fontWeight: 700, fontSize: 13 }}>{r.sym}</span>
                  <span style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}>{r.name}</span>
                  <span className="num" style={{ fontSize: 10.5, color: "var(--color-on-surface-variant)", textAlign: "right" }}>{r.from}</span>
                  <span className="num" style={{ fontSize: 10.5, color: r.c, textAlign: "right", fontWeight: 600 }}>{r.to}</span>
                </div>
              ))}
              <div style={{ marginTop: 8, fontSize: 10.5, fontFamily: "var(--font-headline)", fontStyle: "italic", color: "var(--color-on-surface-variant)" }}>
                Showing 24 of 89 movements. <a href="#" style={{ color: "var(--color-primary)" }}>View full ledger ↗</a>
              </div>
            </div>
          </div>
        </div>

        {/* ─── Strip Dividers ─────────────────── */}
        <div style={{
          marginTop: 56,
          height: 0,
          borderTop: "4px double var(--color-on-surface)",
        }}></div>

        {/* ─── Arrivals section ────────────────── */}
        <div style={{ marginTop: 36, display: "grid", gridTemplateColumns: "1fr auto", alignItems: "baseline", gap: 24 }}>
          <div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>Inside · Arrivals</div>
            <h2 style={{
              fontFamily: "var(--font-headline)", fontSize: 40, fontWeight: 500, letterSpacing: "-0.02em",
              margin: "12px 0 0 0", lineHeight: 1.02,
            }}>
              The forty newcomers, in brief
            </h2>
          </div>
          <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)" }}>
            Figure B · Eight to the top, thirty-two below
          </div>
        </div>

        <div style={{
          marginTop: 32,
          columnCount: 4,
          columnGap: 28,
          columnRule: "1px solid rgba(29,28,21,0.2)",
        }}>
          {arrivals.slice(0, 20).map((a, i) => (
            <div key={a.name} style={{
              breakInside: "avoid",
              marginBottom: 22,
              display: "flex",
              flexDirection: "column",
              gap: 6,
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span className={`tier-tag ${a.tier === "Next 40" ? "next40" : "ft120"}`} style={{ fontSize: 8.5, padding: "2px 5px" }}>
                  {a.tier === "Next 40" ? "N40" : "120"}
                </span>
                <span style={{ fontFamily: "var(--font-headline)", fontSize: 17, fontWeight: 600, color: "var(--color-on-surface)" }}>
                  {a.name}
                </span>
              </div>
              <div style={{ fontSize: 9.5, letterSpacing: "0.1em", textTransform: "uppercase", color: "var(--color-on-surface-variant)", fontWeight: 600 }}>
                {a.sector} · {a.city}
              </div>
              <p style={{
                fontFamily: "var(--font-headline)", fontSize: 12.5, lineHeight: 1.45,
                margin: 0, color: "var(--color-on-surface)",
              }}>
                {a.note}
              </p>
              <div style={{ fontSize: 10.5, fontFamily: "var(--font-mono)", color: "var(--color-primary)", fontWeight: 600 }}>
                {a.raised} raised
              </div>
            </div>
          ))}
        </div>

        <div style={{
          marginTop: 24,
          padding: "12px 16px",
          background: "var(--color-on-surface)",
          color: "var(--color-background)",
          fontSize: 11, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 600,
        }}>
          + 20 more arrivals continue overleaf →
        </div>

        {/* ─── Sector + Geography row ───────────────── */}
        <div style={{
          marginTop: 48,
          display: "grid",
          gridTemplateColumns: "5fr 7fr",
          gap: 36,
        }}>
          <div>
            <div style={{ height: 0, borderTop: "2px solid var(--color-on-surface)", marginBottom: 16 }}></div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>Figure C · Sectors</div>
            <h2 style={{
              fontFamily: "var(--font-headline)", fontSize: 32, fontWeight: 500, letterSpacing: "-0.015em",
              margin: "8px 0 16px 0", lineHeight: 1.05,
            }}>
              AI consolidates, climate surges
            </h2>
            <window.SectorTreemap data={window.SECTORS_2026} width={520} height={420} />
            <div style={{ marginTop: 10, fontFamily: "var(--font-headline)", fontStyle: "italic", fontSize: 12, color: "var(--color-on-surface-variant)", lineHeight: 1.5 }}>
              Area proportional to count. <strong style={{ fontStyle: "normal", color: "var(--color-on-surface)" }}>Twenty-two</strong>
              {" "}AI-classified members; FinTech and SaaS remain anchor sectors.
            </div>
          </div>

          <div>
            <div style={{ height: 0, borderTop: "2px solid var(--color-on-surface)", marginBottom: 16 }}></div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr auto", alignItems: "baseline", gap: 16, marginBottom: 16 }}>
              <div>
                <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>Figure D · Where they sit</div>
                <h2 style={{
                  fontFamily: "var(--font-headline)", fontSize: 32, fontWeight: 500, letterSpacing: "-0.015em",
                  margin: "8px 0 0 0", lineHeight: 1.05,
                }}>
                  Geography of the cohort
                </h2>
              </div>
              <div style={{
                display: "flex", gap: 16, fontSize: 11, color: "var(--color-on-surface-variant)",
                fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase",
              }}>
                <span><strong style={{ color: "var(--color-on-surface)" }}>78</strong> Paris</span>
                <span><strong style={{ color: "var(--color-on-surface)" }}>42</strong> Province</span>
              </div>
            </div>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 220px", gap: 18 }}>
              <window.FranceMap width={560} height={500} regions={window.REGIONS_2026} />

              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                <div className="diplomatic-label" style={{ marginBottom: 6 }}>City Ranking</div>
                {window.REGIONS_2026.slice(0, 10).map((r, i) => (
                  <div key={r.city} className="hairline-bot" style={{
                    paddingBottom: 6, display: "grid", gridTemplateColumns: "20px 1fr 32px 28px",
                    alignItems: "baseline", gap: 8, fontSize: 12,
                  }}>
                    <span className="num" style={{ fontSize: 10, color: "var(--color-on-surface-variant)" }}>
                      {String(i + 1).padStart(2, "0")}
                    </span>
                    <span style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}>{r.city}</span>
                    <span className="num" style={{ textAlign: "right", fontWeight: 600 }}>{r.count}</span>
                    <span className="num" style={{ textAlign: "right", fontSize: 10, color: r.delta > 0 ? "#3c6840" : r.delta < 0 ? "#963d3d" : "#72787e" }}>
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
          <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)", marginBottom: 8 }}>The Tape · Active cohort, alphabetical</div>
          <div className="tape">
            <div style={{
              padding: "0 24px",
              fontFamily: "var(--font-mono)",
              fontSize: 12.5,
              letterSpacing: "0.04em",
              fontWeight: 500,
            }}>
              {tapeNames.join("  ·  ")}  ·  + 73 more
            </div>
          </div>
        </div>

        {/* ─── Footer ────────────────────────── */}
        <div style={{ marginTop: 56, display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 24, fontSize: 11, color: "var(--color-on-surface-variant)", paddingTop: 18, borderTop: "1px solid rgba(29,28,21,0.35)" }}>
          <div>
            <div className="editorial-overline" style={{ marginBottom: 6 }}>Edition</div>
            <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55 }}>
              The Navigator · Bulletin Nº 6<br />Published 25 May 2025 · Paris
            </p>
          </div>
          <div>
            <div className="editorial-overline" style={{ marginBottom: 6 }}>Sources</div>
            <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55 }}>
              La French Tech / DGE · Ministère de l'Économie · INSEE · Navigator entity graph
            </p>
          </div>
          <div style={{ textAlign: "right" }}>
            <div className="editorial-overline" style={{ marginBottom: 6 }}>Continued inside</div>
            <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontSize: 12, lineHeight: 1.55, fontStyle: "italic" }}>
              Sector deep-dives · Alumni outcomes · Funding trajectories · Methodology
            </p>
          </div>
        </div>
      </div>
    </window.NavChrome>
  );
}

Object.assign(window, { DirectionB });
