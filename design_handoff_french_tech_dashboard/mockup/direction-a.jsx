// ─── Direction A: "The Class of 2025" ────────────────────
// Editorial special-edition / annual-report layout.
// Big alluvial flow as hero; arrivals/promotions in editorial grids;
// sector + geography split; exits narrative.

function DirectionA() {
  const arrivals = window.ARRIVALS_2026;
  const promotions = window.PROMOTIONS_2026;
  const exits = window.EXITS_2026;
  const sectors = window.SECTORS_2026;
  const regions = window.REGIONS_2026;
  const stats = window.HEADLINE_2026;

  return (
    <window.NavChrome>
      <div className="dir-a" style={{
        background: "var(--color-background)",
        minHeight: "100%",
        padding: "40px 56px 64px 56px",
        fontFamily: "var(--font-body)",
      }}>

        {/* ─── Editorial Masthead ─────────────────────── */}
        <div className="masthead-rule" style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          fontSize: 11,
          letterSpacing: "0.18em",
          textTransform: "uppercase",
          color: "var(--color-on-surface-variant)",
          fontWeight: 600,
        }}>
          <span>Bulletin Nº 6 · Édition spéciale · 25 mai 2025</span>
          <span>French Tech Next 40 / 120 · Six years on</span>
          <span className="num" style={{ letterSpacing: "0.06em" }}>FOLIO 01 / 12</span>
        </div>

        {/* ─── Headline ─────────────────────────────── */}
        <div style={{ marginTop: 40, display: "grid", gridTemplateColumns: "1fr 320px", gap: 56, alignItems: "end" }}>
          <div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>
              The Sixth Promotion · Announced 22 May 2025
            </div>
            <h1 className="editorial-h1" style={{
              fontSize: 96,
              marginTop: 18,
              marginBottom: 0,
            }}>
              The Class of <span style={{ fontStyle: "italic", fontWeight: 400 }}>2025</span>
            </h1>
            <div className="editorial-dek" style={{
              fontSize: 22,
              marginTop: 22,
              maxWidth: 720,
            }}>
              Forty arrivals, seven promotions, forty exits. The cohort tilts decisively
              toward artificial intelligence, sovereign cybersecurity, and climate
              infrastructure &mdash; with Paris consolidating its share.
            </div>
            <div className="editorial-byline" style={{ marginTop: 28 }}>
              The Navigator · Institutional Research · Compiled from official sources
              <span style={{ margin: "0 10px", color: "var(--color-outline-variant)" }}>·</span>
              lafrenchtech.gouv.fr ↗
            </div>
          </div>

          <div className="ghost-border" style={{
            background: "white",
            padding: "20px 22px",
            display: "flex",
            flexDirection: "column",
            gap: 14,
          }}>
            <div className="editorial-overline" style={{ fontSize: 10 }}>By the numbers · 2025</div>
            {[
              { label: "Total cohort", v: "120", sub: "40 + 80" },
              { label: "Cumulative since 2020", v: "312", sub: "tracked" },
              { label: "Capital raised", v: stats.totalRaised, sub: "across active cohort" },
              { label: "Unicorns", v: "28", sub: "valued ≥ €1B" },
            ].map((row) => (
              <div key={row.label} className="hairline-bot" style={{
                paddingBottom: 12,
                display: "flex",
                alignItems: "baseline",
                justifyContent: "space-between",
                borderBottomColor: "rgba(29,28,21,0.18)",
              }}>
                <span style={{ fontSize: 11, color: "var(--color-on-surface-variant)", letterSpacing: "0.06em", textTransform: "uppercase", fontWeight: 600 }}>
                  {row.label}
                </span>
                <span className="num" style={{ fontFamily: "var(--font-headline)", fontSize: 28, fontWeight: 500, color: "var(--color-on-surface)" }}>
                  {row.v}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* ─── Stat Band (the 4 movements) ────────────── */}
        <div style={{ marginTop: 56 }} className="hairline">
          <div style={{
            display: "grid",
            gridTemplateColumns: "repeat(4, 1fr)",
            paddingTop: 28,
          }}>
            {[
              { label: "Arrivals", v: "40", sub: "+11% on 2024", color: "#3c6840" },
              { label: "Promotions to Next 40", v: "7", sub: "from FT 120", color: "#114563" },
              { label: "Retained", v: "71", sub: "of 120 prior cohort", color: "#1d1c15" },
              { label: "Exits", v: "40", sub: "graduations, M&A, criteria", color: "#963d3d" },
            ].map((d, i) => (
              <div key={d.label} style={{
                paddingLeft: i === 0 ? 0 : 28,
                borderLeft: i === 0 ? "none" : "1px solid rgba(29,28,21,0.18)",
                paddingRight: 28,
              }}>
                <div className="diplomatic-label" style={{ color: d.color }}>{d.label}</div>
                <div className="stat-figure" style={{ color: d.color, marginTop: 12 }}>{d.v}</div>
                <div style={{ fontSize: 12, color: "var(--color-on-surface-variant)", marginTop: 6, fontStyle: "italic", fontFamily: "var(--font-headline)" }}>
                  {d.sub}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ─── Hero: Cohort Flow Viz ──────────────────── */}
        <div style={{ marginTop: 72 }}>
          <div style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "baseline",
          }}>
            <div>
              <div className="editorial-overline">Figure 1 · Cohort Flow</div>
              <h2 style={{
                fontFamily: "var(--font-headline)",
                fontSize: 36,
                fontWeight: 500,
                letterSpacing: "-0.015em",
                margin: "12px 0 0 0",
                color: "var(--color-on-surface)",
              }}>
                Six Cohorts
              </h2>
              <p className="editorial-dek" style={{ fontSize: 16, marginTop: 8, maxWidth: 560 }}>
                Companies entering, retained within tiers, promoted, demoted, and exiting the
                program across the 2020 &ndash; 2025 cohorts.
              </p>
            </div>

            <div style={{
              display: "flex",
              gap: 22,
              fontSize: 11,
              letterSpacing: "0.05em",
              fontWeight: 600,
              color: "var(--color-on-surface-variant)",
              textTransform: "uppercase",
            }}>
              {[
                { c: "#114563", l: "Next 40 / Retained · Promoted" },
                { c: "#3c6840", l: "FT 120 / Retained" },
                { c: "#b8862c", l: "Demoted" },
                { c: "#3c6840", l: "New entrants ↑", op: 0.55 },
                { c: "#963d3d", l: "Exited ↓" },
              ].map((d, i) => (
                <span key={i} style={{ display: "inline-flex", alignItems: "center", gap: 7 }}>
                  <span style={{ width: 18, height: 6, background: d.c, opacity: d.op || 1, display: "inline-block" }}></span>
                  {d.l}
                </span>
              ))}
            </div>
          </div>

          <div style={{ marginTop: 32, background: "white", padding: "32px 22px 18px 22px", border: "1px solid rgba(193,199,206,0.55)" }}>
            <window.CohortFlow width={1240} height={520} highlightYear={2025} tonal="full" />
          </div>

          <div style={{
            marginTop: 14,
            display: "grid",
            gridTemplateColumns: "1fr auto",
            gap: 16,
            alignItems: "baseline",
          }}>
            <p style={{
              fontFamily: "var(--font-headline)",
              fontStyle: "italic",
              fontSize: 13,
              color: "var(--color-on-surface-variant)",
              maxWidth: 880,
              margin: 0,
              lineHeight: 1.5,
            }}>
              <strong style={{ fontWeight: 600, fontStyle: "normal", color: "var(--color-on-surface)" }}>Reading the chart.</strong>
              {" "}Each annual cohort is fixed at 120 companies — 40 in the Next 40 tier (dark blue) and 80 in
              FT 120 (green). Inter-year ribbons show <em>retentions</em> within the same tier, with
              promotions from FT 120 to Next 40 (bold blue) and demotions in the reverse direction
              (ochre). Strips above and below each column quantify new arrivals and exits respectively.
            </p>
            <div style={{ fontSize: 10.5, fontFamily: "var(--font-mono)", color: "var(--color-on-surface-variant)", letterSpacing: "0.04em", textAlign: "right" }}>
              Source: La French Tech, MESR<br />
              Updated 22 May 2025
            </div>
          </div>
        </div>

        {/* ─── Section: Arrivals ────────────────────── */}
        <SectionHeading
          overline="§ 1 · Arrivals"
          headline="Forty new entrants"
          dek="The intake widens. Of the 40 new members, 22 sit at the intersection of AI, sovereign cyber, and climate infrastructure — the three vectors France's industrial policy now treats as inseparable."
          fig="Figure 2"
        />

        <div style={{
          marginTop: 32,
          display: "grid",
          gridTemplateColumns: "repeat(4, 1fr)",
          gap: 1,
          background: "rgba(29,28,21,0.18)",
        }}>
          {arrivals.slice(0, 12).map((a, i) => (
            <EntrantCard key={a.name} a={a} />
          ))}
        </div>

        <div style={{
          marginTop: 24,
          padding: "16px 22px",
          background: "var(--color-surface-container-low)",
          fontFamily: "var(--font-headline)",
          fontStyle: "italic",
          fontSize: 13.5,
          color: "var(--color-on-surface-variant)",
        }}>
          And <span className="num" style={{ fontStyle: "normal", fontWeight: 600, color: "var(--color-on-surface)" }}>28</span> further arrivals: Stoik · Defacto · Gourmey · Innovafeed Aqua · Lemon Way · Ostrum AI · Vianova · Carbonable · Akimbo · Holistik · Loft Orbital · Constellr · Skello · Ramify · Lumio · Verkor Mobility · Aledia · Diabeloop · Lifen · Cardiologs · Verteego · Kuna AI · Naco Travel · Onestock · Klima · Carbon Maps · Atmen · Ÿnsect ·
        </div>

        {/* ─── Section: Promotions ────────────────── */}
        <SectionHeading
          overline="§ 2 · Promotions"
          headline="Seven graduate to Next 40"
          dek="Akeneo, Aqemia, Pasqal, Swan, Greenly, Filigran, Wandercraft — the bench of FT 120 alumni who cross the line in 2025."
          fig="Figure 3"
        />

        <div style={{
          marginTop: 32,
          display: "grid",
          gridTemplateColumns: "repeat(4, 1fr)",
          gap: 14,
        }}>
          {promotions.map((p, i) => (
            <PromotionCard key={p.name} p={p} index={i} />
          ))}
        </div>

        {/* ─── Section: Sector & Geography Split ─── */}
        <div style={{ marginTop: 80, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 56 }}>
          <div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>§ 3 · Sector composition</div>
            <h2 style={{ fontFamily: "var(--font-headline)", fontSize: 30, fontWeight: 500, letterSpacing: "-0.015em", margin: "10px 0 6px 0" }}>
              The shape of the 6th cohort
            </h2>
            <p className="editorial-dek" style={{ fontSize: 14.5, marginBottom: 28, maxWidth: 460 }}>
              AI consolidates its lead. Climate accelerates. Cybersecurity finally crosses the
              double-digit threshold.
            </p>
            <window.SectorBars data={window.SECTORS_2026} accent="#114563" />
          </div>

          <div>
            <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>§ 4 · Geographic distribution</div>
            <h2 style={{ fontFamily: "var(--font-headline)", fontSize: 30, fontWeight: 500, letterSpacing: "-0.015em", margin: "10px 0 6px 0" }}>
              Where the cohort sits
            </h2>
            <p className="editorial-dek" style={{ fontSize: 14.5, marginBottom: 8, maxWidth: 480 }}>
              Paris holds 65% of the cohort. Toulouse and Grenoble each rise on deep-tech entries.
            </p>
            <window.FranceMap width={520} height={460} regions={window.REGIONS_2026} />
          </div>
        </div>

        {/* ─── Section: Notable Exits ───────────── */}
        <SectionHeading
          overline="§ 5 · Exits"
          headline="Forty companies leave the cohort"
          dek="The largest exit class to date. Two IPOs, three acquisitions, the rest by revenue-threshold reassessment or graduation."
          fig="Figure 5"
        />

        <div style={{
          marginTop: 32,
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: 1,
          background: "rgba(29,28,21,0.18)",
        }}>
          {exits.map((e, i) => (
            <div key={e.name} style={{
              background: "var(--color-background)",
              padding: "18px 22px",
            }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
                <div className="font-headline" style={{ fontSize: 18, fontWeight: 600, color: "var(--color-on-surface)" }}>
                  {e.name}
                </div>
                <div className="num" style={{ fontSize: 10.5, color: "var(--color-on-surface-variant)", letterSpacing: "0.08em" }}>
                  {e.from} · since {e.since}
                </div>
              </div>
              <div style={{ marginTop: 6, fontSize: 12, color: "var(--color-on-surface-variant)", fontStyle: "italic", fontFamily: "var(--font-headline)" }}>
                {e.reason}
              </div>
              <div style={{ marginTop: 10, display: "inline-block", padding: "2px 8px", fontSize: 10, fontWeight: 600, letterSpacing: "0.1em", textTransform: "uppercase", background: "rgba(150,61,61,0.12)", color: "#963d3d" }}>
                {e.sector}
              </div>
            </div>
          ))}
        </div>

        {/* ─── Footer ───────────────────────────── */}
        <div style={{ marginTop: 80, paddingTop: 24, borderTop: "1px solid rgba(29,28,21,0.35)", display: "grid", gridTemplateColumns: "2fr 1fr 1fr", gap: 32 }}>
          <div>
            <div className="editorial-overline">Methodology</div>
            <p style={{ fontFamily: "var(--font-headline)", fontSize: 12, color: "var(--color-on-surface-variant)", lineHeight: 1.55, marginTop: 8 }}>
              Movement classifications are derived from comparison of consecutive annual rosters
              published by La French Tech (DGE). Sector taxonomy is The Navigator's; raised capital
              figures are sourced from primary disclosures and validated against PitchBook and
              Crunchbase. Geographic attribution reflects company headquarters at announcement.
            </p>
          </div>
          <div>
            <div className="editorial-overline">Sources</div>
            <ul style={{ listStyle: "none", padding: 0, margin: "8px 0 0 0", fontSize: 12, color: "var(--color-on-surface)", lineHeight: 1.6, fontFamily: "var(--font-headline)" }}>
              <li>· La French Tech / DGE</li>
              <li>· Ministry of Economy &amp; Finance</li>
              <li>· INSEE — employment classifications</li>
              <li>· The Navigator entity graph</li>
            </ul>
          </div>
          <div style={{ textAlign: "right" }}>
            <div className="editorial-overline">Publication</div>
            <div style={{ marginTop: 8, fontFamily: "var(--font-headline)", fontSize: 13, color: "var(--color-on-surface)", lineHeight: 1.55 }}>
              The Navigator<br />
              <em>French Innovation Intelligence</em><br />
              <span className="num" style={{ fontSize: 11, color: "var(--color-on-surface-variant)" }}>navigator.fr · 25 / 05 / 2025</span>
            </div>
          </div>
        </div>
      </div>
    </window.NavChrome>
  );
}


// ─── Helpers ──────────────────────────────────────────────

function SectionHeading({ overline, headline, dek, fig }) {
  return (
    <div style={{ marginTop: 80 }} className="hairline">
      <div style={{ paddingTop: 28, display: "grid", gridTemplateColumns: "1fr auto", gap: 24, alignItems: "baseline" }}>
        <div>
          <div className="editorial-overline" style={{ color: "var(--color-primary)" }}>{overline}</div>
          <h2 style={{
            fontFamily: "var(--font-headline)",
            fontSize: 44,
            fontWeight: 500,
            letterSpacing: "-0.02em",
            margin: "14px 0 0 0",
            lineHeight: 1.05,
          }}>
            {headline}
          </h2>
          <p className="editorial-dek" style={{ fontSize: 18, marginTop: 12, maxWidth: 720 }}>
            {dek}
          </p>
        </div>
        {fig && (
          <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)" }}>{fig}</div>
        )}
      </div>
    </div>
  );
}

function EntrantCard({ a }) {
  return (
    <div style={{
      background: "var(--color-background)",
      padding: "24px 22px",
      display: "flex",
      flexDirection: "column",
      gap: 14,
      minHeight: 230,
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <div className="logo-stub" style={{
          background: a.color,
          color: "white",
          width: 38,
          height: 38,
          fontFamily: "var(--font-headline)",
        }}>
          {a.initial}
        </div>
        <div>
          <div className="font-headline" style={{ fontSize: 19, fontWeight: 600, lineHeight: 1.1, color: "var(--color-on-surface)" }}>
            {a.name}
          </div>
          <div style={{ fontSize: 10, color: "var(--color-on-surface-variant)", letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 600, marginTop: 4 }}>
            {a.city}
          </div>
        </div>
      </div>

      <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
        <span className={`tier-tag ${a.tier === "Next 40" ? "next40" : "ft120"}`}>
          {a.tier}
        </span>
        <span className="tier-tag" style={{ background: "rgba(60,104,64,0.12)", color: "#3c6840" }}>
          New
        </span>
      </div>

      <div style={{ fontSize: 12.5, color: "var(--color-on-surface)", lineHeight: 1.5, fontFamily: "var(--font-headline)", flex: 1 }}>
        {a.note}
      </div>

      <div className="hairline" style={{ paddingTop: 10, display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        <span style={{ fontSize: 10, color: "var(--color-on-surface-variant)", letterSpacing: "0.08em", textTransform: "uppercase", fontWeight: 600 }}>
          {a.sector}
        </span>
        <span className="num" style={{ fontSize: 13, fontWeight: 600, color: "var(--color-primary)" }}>
          {a.raised}
        </span>
      </div>
    </div>
  );
}

function PromotionCard({ p, index }) {
  return (
    <div style={{
      background: "white",
      border: "1px solid rgba(193,199,206,0.55)",
      padding: "18px 20px",
      display: "flex",
      flexDirection: "column",
      gap: 10,
    }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <span className="num" style={{ fontSize: 12, color: "var(--color-on-surface-variant)", letterSpacing: "0.05em" }}>
          {String(index + 1).padStart(2, "0")}
        </span>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 4, color: "var(--color-primary)", fontSize: 10, letterSpacing: "0.12em", fontWeight: 700, textTransform: "uppercase" }}>
          <span className="material-symbols-outlined icon-14">arrow_upward</span>
          PROMOTED
        </span>
      </div>
      <div>
        <div className="font-headline" style={{ fontSize: 22, fontWeight: 600, letterSpacing: "-0.01em", color: "var(--color-on-surface)" }}>
          {p.name}
        </div>
        <div style={{ fontSize: 10.5, color: "var(--color-on-surface-variant)", letterSpacing: "0.06em", textTransform: "uppercase", marginTop: 4, fontWeight: 600 }}>
          {p.sector} · {p.city}
        </div>
      </div>
      <p style={{ margin: 0, fontFamily: "var(--font-headline)", fontStyle: "italic", fontSize: 12.5, color: "var(--color-on-surface-variant)", lineHeight: 1.5 }}>
        {p.note}
      </p>
      <div className="hairline" style={{ paddingTop: 8, display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
        <span style={{ fontSize: 10, color: "var(--color-on-surface-variant)", letterSpacing: "0.05em", textTransform: "uppercase", fontWeight: 600 }}>
          FT 120 → Next 40
        </span>
        <span className="num" style={{ fontSize: 13, fontWeight: 600, color: "var(--color-primary)" }}>
          {p.raised}
        </span>
      </div>
    </div>
  );
}

Object.assign(window, { DirectionA });
