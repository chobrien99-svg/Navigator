// ─── Direction C: "Working Paper" ────────────────────────
// Ministerial / policy-paper aesthetic. Numbered sections,
// narrow centered column, marginalia, monospace ledger.

function DirectionC() {
  const arrivals = window.ARRIVALS_2026;
  const promotions = window.PROMOTIONS_2026;
  const exits = window.EXITS_2026;
  const sectors = window.SECTORS_2026;
  const regions = window.REGIONS_2026;
  const stats = window.HEADLINE_2026;

  return (
    <window.NavChrome>
      <div className="dir-c" style={{
        background: "#faf6ea",
        minHeight: "100%",
        padding: "48px 64px 64px 64px",
        fontFamily: "var(--font-body)",
      }}>

        {/* ─── Cartouche / header ──────────────── */}
        <div style={{ display: "grid", gridTemplateColumns: "auto 1fr auto", gap: 32, alignItems: "start" }}>
          <div className="cartouche" style={{ fontSize: 10, letterSpacing: "0.16em", textTransform: "uppercase", lineHeight: 1.65 }}>
            <div style={{ color: "var(--color-primary)", fontWeight: 700 }}>The Navigator</div>
            <div style={{ color: "var(--color-on-surface-variant)" }}>Working Paper Series</div>
            <div className="num" style={{ color: "var(--color-on-surface-variant)", marginTop: 4, letterSpacing: "0.06em" }}>Nº 2025-06</div>
          </div>

          <div></div>

          <div style={{ fontSize: 10.5, letterSpacing: "0.12em", textTransform: "uppercase", textAlign: "right", color: "var(--color-on-surface-variant)", lineHeight: 1.7, fontWeight: 600 }}>
            <div>Internal · Pre-publication</div>
            <div className="num" style={{ letterSpacing: "0.06em" }}>25 / V / 2025</div>
            <div>Paris · 12<sup>e</sup></div>
          </div>
        </div>

        {/* ─── Title block ───────────────────── */}
        <div style={{ marginTop: 48, marginBottom: 12, textAlign: "center" }}>
          <div className="editorial-overline" style={{ color: "var(--color-on-surface-variant)" }}>
            Programme French Tech Next 40 / 120 · Sixième promotion · 2025
          </div>
          <h1 style={{
            fontFamily: "var(--font-headline)",
            fontSize: 52,
            fontWeight: 500,
            letterSpacing: "-0.02em",
            lineHeight: 1.04,
            margin: "20px auto 0 auto",
            maxWidth: 760,
          }}>
            <span style={{ fontStyle: "italic", fontWeight: 400 }}>Note d'analyse</span> sur la
            6<sup>e</sup> promotion : trajectoires, secteurs, géographie
          </h1>
          <div style={{
            marginTop: 24, fontFamily: "var(--font-headline)", fontStyle: "italic", fontSize: 16,
            color: "var(--color-on-surface-variant)", lineHeight: 1.5, maxWidth: 680, margin: "24px auto 0 auto",
          }}>
            Une synthèse des mouvements entre cohortes, de la composition sectorielle, et des
            implantations territoriales — préparée à l'occasion de l'annonce officielle du
            22 mai 2025.
          </div>
          <div style={{ marginTop: 32, fontSize: 11, color: "var(--color-on-surface-variant)", letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600 }}>
            The Navigator · Department of Research
          </div>
        </div>

        <div style={{
          height: 0, borderTop: "1px solid var(--color-on-surface)", margin: "40px auto 0 auto", width: "100%",
        }}></div>

        {/* ─── Abstract band ───────────────────── */}
        <div style={{ margin: "24px auto 0 auto", maxWidth: 900, display: "grid", gridTemplateColumns: "120px 1fr", gap: 24 }}>
          <div className="diplomatic-label" style={{ paddingTop: 4 }}>Résumé</div>
          <div className="body-prose">
            La sixième promotion du programme renouvelle 40 entreprises sur 120 — la rotation la
            plus importante observée depuis 2020. Sept passages du FT 120 vers le Next 40 et
            deux mouvements inverses témoignent d'une mobilité accrue entre les deux étages.
            L'intelligence artificielle (22 entreprises, +6), la cybersécurité souveraine
            (10, +3) et les technologies climatiques (13, +5) consolident leur poids dans
            la cohorte. Paris conserve une part de 65 %, en léger recul (−2 points). L'analyse
            qui suit décompose ces mouvements, propose une lecture sectorielle et géographique,
            et discute des sorties — en majorité par graduation ou opération capitalistique.
          </div>
        </div>

        {/* ─── §1 Synthèse ───────────────────── */}
        <Section c="1" title="Synthèse des mouvements 2024 → 2025">
          <Body>
            <p style={{ margin: "0 0 14px 0" }}>
              Au 22 mai 2025, la composition de la cohorte se présente comme suit : 40 entreprises
              dans le Next 40, 80 dans le FT 120. Parmi les 120 membres précédents (cohorte 2024),
              71 sont reconduits, 7 promus vers le Next 40 et 2 rétrogradés vers le FT 120 ; 40
              entreprises sortent du programme. Les 40 nouvelles entrées se répartissent en 4
              admissions directes au Next 40 et 36 au FT 120.
            </p>
            <p style={{ margin: 0 }}>
              La rotation annuelle (entrants ÷ cohorte) atteint 33 %, contre 30 % en 2024 et
              une moyenne historique de 26 %. Cette accélération s'explique en partie par
              l'effet de cohorte des Sept Pôles d'IA Stratégique annoncés en 2024.
            </p>
          </Body>

          {/* ledger of summary numbers in margin */}
          <Marginalia>
            <div className="ledger-mono">
              <Row k="Total cohorte" v="120" />
              <Row k="Next 40" v="40" />
              <Row k="FT 120" v="80" />
              <RowSep />
              <Row k="Maintien N40" v="29" />
              <Row k="Maintien 120" v="42" />
              <Row k="Promotions" v="7" />
              <Row k="Rétrogradations" v="2" />
              <RowSep />
              <Row k="Nouvelles entrées" v="40" c="#3c6840" />
              <Row k="Sorties" v="40" c="#963d3d" />
              <RowSep />
              <Row k="Capital cumulé" v="€34,2 Mds" />
              <Row k="Licornes" v="28" />
            </div>
          </Marginalia>
        </Section>

        {/* ─── §2 Flux ───────────────────── */}
        <Section c="2" title="Flux entre promotions, 2020 — 2025" fullWidth>
          <Body>
            <p style={{ margin: 0 }}>
              La figure ci-après suit le devenir des 120 membres entre les six promotions du
              programme. Chaque colonne représente une cohorte annuelle. Les rubans figurent les
              mouvements entre les deux étages — maintiens, promotions du FT 120 vers le Next 40
              et rétrogradations en sens inverse. Les arrivées et sorties sont indiquées par
              les barreaux verticaux en haut et en bas de chaque colonne.
            </p>
          </Body>

          <div style={{ marginTop: 28, background: "white", padding: "24px 18px 14px 18px", border: "1px solid rgba(29,28,21,0.35)" }}>
            <window.CohortFlow width={1040} height={460} highlightYear={2025} tonal="full" />
          </div>

          <div style={{ marginTop: 12, display: "grid", gridTemplateColumns: "auto 1fr", gap: 18, alignItems: "baseline" }}>
            <span style={{ fontSize: 9.5, fontFamily: "var(--font-mono)", letterSpacing: "0.06em", color: "var(--color-on-surface-variant)" }}>FIG. 1</span>
            <span style={{ fontFamily: "var(--font-headline)", fontStyle: "italic", fontSize: 12.5, color: "var(--color-on-surface-variant)", lineHeight: 1.45 }}>
              Diagramme de flux entre les six cohortes annuelles du programme. Sources :
              La French Tech, DGE ; traitements The Navigator.
            </span>
          </div>
        </Section>

        {/* ─── §3 Arrivées ─────────────────── */}
        <Section c="3" title="Les 40 entreprises entrantes" fullWidth>
          <Body>
            <p style={{ margin: 0 }}>
              Les arrivées se concentrent dans trois familles : intelligence artificielle
              (12 entreprises), cybersécurité souveraine (6), technologies du climat (8). On
              relève la promotion directe au Next 40 de quatre opérateurs — Dust, Owkin,
              Photoroom et Sweep — révélateurs d'une priorisation explicite des champions
              de l'IA appliquée et de la décarbonation industrielle.
            </p>
          </Body>

          <div style={{
            marginTop: 24,
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            columnGap: 30,
            rowGap: 14,
          }}>
            {arrivals.slice(0, 18).map((a, i) => (
              <div key={a.name} style={{ display: "grid", gridTemplateColumns: "26px 1fr auto", gap: 8, alignItems: "baseline", paddingBottom: 10, borderBottom: "1px dotted rgba(29,28,21,0.3)" }}>
                <span className="num" style={{ fontSize: 10, color: "var(--color-on-surface-variant)" }}>
                  {String(i + 1).padStart(2, "0")}
                </span>
                <div>
                  <span style={{ fontFamily: "var(--font-headline)", fontSize: 15, fontWeight: 600, color: "var(--color-on-surface)" }}>
                    {a.name}
                  </span>
                  <span style={{ marginLeft: 6, fontSize: 9.5, letterSpacing: "0.1em", textTransform: "uppercase", color: a.tier === "Next 40" ? "var(--color-primary)" : "var(--color-secondary)", fontWeight: 700 }}>
                    {a.tier === "Next 40" ? "[N40]" : "[120]"}
                  </span>
                  <div style={{ fontSize: 10.5, letterSpacing: "0.04em", color: "var(--color-on-surface-variant)", textTransform: "uppercase", fontWeight: 500, marginTop: 2 }}>
                    {a.sector} · {a.city}
                  </div>
                </div>
                <div className="num" style={{ fontSize: 11, color: "var(--color-primary)", fontWeight: 600 }}>
                  {a.raised}
                </div>
              </div>
            ))}
          </div>

          <div style={{ marginTop: 20, fontFamily: "var(--font-headline)", fontStyle: "italic", fontSize: 12.5, color: "var(--color-on-surface-variant)", lineHeight: 1.55 }}>
            Suivent 22 autres admissions au FT 120 — listées en annexe A.1. La répartition
            sectorielle complète figure en §6.
          </div>
        </Section>

        {/* ─── §4 Promotions ─────────────── */}
        <Section c="4" title="Promotions vers le Next 40">
          <Body>
            <p style={{ margin: 0 }}>
              Sept entreprises franchissent l'étage supérieur en 2025 — six de la cohorte 2024,
              et Wandercraft, qui revient au programme après une année de sortie pour
              restructuration. Les profils relèvent d'une diversité notable : SaaS B2B, biotechnologie
              quantique, banque embarquée, comptabilité carbone, cybersécurité ouverte, robotique
              médicale.
            </p>
          </Body>

          <table style={{ width: "100%", borderCollapse: "collapse", marginTop: 24, fontFamily: "var(--font-body)", fontSize: 12.5 }}>
            <thead>
              <tr style={{ borderBottom: "1.5px solid var(--color-on-surface)", fontSize: 10, letterSpacing: "0.1em", textTransform: "uppercase", color: "var(--color-on-surface-variant)", fontWeight: 600 }}>
                <th style={{ textAlign: "left", padding: "8px 8px 8px 0", width: "20%" }}>Entreprise</th>
                <th style={{ textAlign: "left", padding: 8 }}>Secteur</th>
                <th style={{ textAlign: "left", padding: 8 }}>Ville</th>
                <th style={{ textAlign: "right", padding: 8, width: 90 }}>Capital levé</th>
                <th style={{ textAlign: "left", padding: 8, width: "32%" }}>Justification</th>
              </tr>
            </thead>
            <tbody>
              {promotions.map((p) => (
                <tr key={p.name} style={{ borderBottom: "1px dotted rgba(29,28,21,0.3)" }}>
                  <td style={{ padding: "12px 8px 12px 0", fontFamily: "var(--font-headline)", fontWeight: 600, fontSize: 14 }}>{p.name}</td>
                  <td style={{ padding: "12px 8px", color: "var(--color-on-surface-variant)" }}>{p.sector}</td>
                  <td style={{ padding: "12px 8px", color: "var(--color-on-surface-variant)" }}>{p.city}</td>
                  <td className="num" style={{ padding: "12px 8px", textAlign: "right", fontWeight: 600, color: "var(--color-primary)" }}>{p.raised}</td>
                  <td style={{ padding: "12px 8px", color: "var(--color-on-surface)", fontStyle: "italic", fontFamily: "var(--font-headline)", fontSize: 12.5, lineHeight: 1.45 }}>{p.note}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Section>

        {/* ─── §5 Sorties ───────────────── */}
        <Section c="5" title="Sorties du programme">
          <Body>
            <p style={{ margin: 0 }}>
              Quarante entreprises quittent la cohorte en 2025 — 9 du Next 40 et 31 du FT 120.
              Les motifs se répartissent comme suit : 2 introductions en bourse (Doctolib, IPO
              programmée Q2 2025), 5 opérations de croissance externe ou de cession, 6
              graduations par dépassement du plafond d'effectifs, 27 sorties par non-satisfaction
              des critères de croissance.
            </p>
          </Body>

          <div style={{ marginTop: 24, display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: 0 }}>
            {exits.map((e, i) => (
              <div key={e.name} style={{
                padding: "10px 14px",
                borderBottom: "1px dotted rgba(29,28,21,0.3)",
                borderRight: i % 2 === 0 ? "1px dotted rgba(29,28,21,0.3)" : "none",
                display: "grid",
                gridTemplateColumns: "24px 1fr auto",
                gap: 10,
                alignItems: "baseline",
              }}>
                <span className="num" style={{ fontSize: 10, color: "var(--color-on-surface-variant)" }}>{String(i + 1).padStart(2, "0")}</span>
                <div>
                  <div style={{ fontFamily: "var(--font-headline)", fontSize: 14, fontWeight: 600 }}>{e.name}</div>
                  <div style={{ fontSize: 11, color: "var(--color-on-surface-variant)", fontStyle: "italic", fontFamily: "var(--font-headline)" }}>
                    {e.reason}
                  </div>
                </div>
                <div style={{ fontSize: 10, color: "var(--color-on-surface-variant)", letterSpacing: "0.06em", textTransform: "uppercase", textAlign: "right" }}>
                  {e.from}<br/><span className="num">{e.since}</span>
                </div>
              </div>
            ))}
          </div>
        </Section>

        {/* ─── §6 Sectors ──────────────────── */}
        <Section c="6" title="Composition sectorielle">
          <Body>
            <p style={{ margin: 0 }}>
              La cohorte 2025 confirme la triple convergence IA — cyber — climat. L'intelligence
              artificielle (18 % de la cohorte, +6 entreprises) dépasse pour la première fois la
              FinTech historiquement dominante (15 %, −1). La cybersécurité atteint 10 entreprises,
              en lien direct avec les commandes publiques liées à NIS 2 et la stratégie
              Cybersecurity de la DGNUM.
            </p>
          </Body>

          <div style={{ marginTop: 28, maxWidth: 820 }}>
            <window.SectorBars data={window.SECTORS_2026} accent="#114563" />
          </div>
        </Section>

        {/* ─── §7 Geography ───────────────── */}
        <Section c="7" title="Implantation géographique" fullWidth>
          <Body>
            <p style={{ margin: 0 }}>
              Paris demeure le centre de gravité de la cohorte (78 entreprises, −2 par rapport
              à 2024). La province progresse marginalement : Lyon (+1), Grenoble (+1) et
              Bordeaux (+1) tirent leur épingle du jeu, notamment via l'arrivée d'Aledia,
              Diabeloop et Tehtris. La diagonale du vide reste structurellement sous-représentée.
            </p>
          </Body>

          <div style={{ marginTop: 32, display: "grid", gridTemplateColumns: "1fr 320px", gap: 36, alignItems: "start" }}>
            <window.FranceMap width={620} height={520} regions={window.REGIONS_2026} />

            <div style={{ paddingTop: 16 }}>
              <div className="diplomatic-label" style={{ marginBottom: 10 }}>Classement par ville</div>
              {window.REGIONS_2026.map((r, i) => (
                <div key={r.city} style={{
                  display: "grid", gridTemplateColumns: "20px 1fr 32px 36px",
                  gap: 8, alignItems: "baseline",
                  borderBottom: "1px dotted rgba(29,28,21,0.3)",
                  padding: "5px 0",
                  fontSize: 11.5,
                }}>
                  <span className="num" style={{ fontSize: 9.5, color: "var(--color-on-surface-variant)" }}>{String(i + 1).padStart(2, "0")}</span>
                  <span style={{ fontFamily: "var(--font-headline)", fontWeight: 600 }}>{r.city}</span>
                  <span className="num" style={{ textAlign: "right", fontWeight: 600 }}>{r.count}</span>
                  <span className="num" style={{ textAlign: "right", fontSize: 10, color: r.delta > 0 ? "#3c6840" : r.delta < 0 ? "#963d3d" : "#72787e" }}>
                    {r.delta > 0 ? `+${r.delta}` : r.delta === 0 ? "·" : r.delta}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </Section>

        {/* ─── §8 Methodology ───────────── */}
        <Section c="8" title="Méthodologie et sources">
          <Body smaller>
            <p style={{ margin: "0 0 10px 0" }}>
              Les classifications de mouvement (nouveau, promu, rétrogradé, maintenu, sortant) sont
              dérivées de la comparaison des listes officielles publiées par La French Tech (DGE)
              entre deux promotions successives. La taxonomie sectorielle est celle de The Navigator,
              alignée sur les nomenclatures INSEE / NACE. Les montants levés sont issus des
              déclarations primaires des entreprises, croisées avec PitchBook et Crunchbase ;
              les valeurs antérieures à 2022 ont fait l'objet d'un re-calcul à parité euro 2025.
            </p>
            <p style={{ margin: 0 }}>
              L'attribution géographique reflète le siège social déclaré au moment de
              l'annonce. Les sorties par opération capitalistique sont qualifiées sur la base
              d'annonces publiques ; les graduations sont calculées à partir des seuils
              d'effectif et de chiffre d'affaires publiés au Journal Officiel.
            </p>
          </Body>
        </Section>

        {/* ─── Footer / signature ───────── */}
        <div style={{ marginTop: 80, paddingTop: 20, borderTop: "1px solid var(--color-on-surface)" }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 24, fontSize: 11, color: "var(--color-on-surface-variant)", letterSpacing: "0.08em", textTransform: "uppercase", fontWeight: 600 }}>
            <div>
              The Navigator<br />
              <span style={{ fontStyle: "italic", textTransform: "none", letterSpacing: 0, color: "var(--color-on-surface)" }}>French Innovation Intelligence</span>
            </div>
            <div style={{ textAlign: "center" }}>
              Working Paper · Nº 2025-06<br />
              <span style={{ textTransform: "none", letterSpacing: 0, fontFamily: "var(--font-headline)", fontStyle: "italic", color: "var(--color-on-surface)" }}>
                Pour diffusion restreinte
              </span>
            </div>
            <div style={{ textAlign: "right" }}>
              <span className="num" style={{ letterSpacing: "0.06em" }}>25 / V / 2025</span><br />
              <span style={{ textTransform: "none", letterSpacing: 0, color: "var(--color-on-surface)" }}>Folio 12 sur 12</span>
            </div>
          </div>
        </div>
      </div>
    </window.NavChrome>
  );
}


// ─── Helpers ──────────────────────────────────────────────

function Section({ c, title, children, fullWidth = false }) {
  const [bodyChildren, marginChildren] = React.Children.toArray(children).reduce((acc, child) => {
    if (child && child.type && child.type.displayName === "Marginalia") {
      acc[1].push(child);
    } else {
      acc[0].push(child);
    }
    return acc;
  }, [[], []]);

  return (
    <div style={{ marginTop: 56 }}>
      <div style={{ display: "grid", gridTemplateColumns: "auto 1fr", gap: 18, alignItems: "baseline", paddingBottom: 14, borderBottom: "1px solid var(--color-on-surface)" }}>
        <h2 className="section-title">
          <span className="section-num">§ {c}</span>
          {title}
        </h2>
      </div>

      {fullWidth ? (
        <div style={{ marginTop: 22 }}>{bodyChildren}</div>
      ) : (
        <div style={{ marginTop: 22, display: "grid", gridTemplateColumns: "1fr 220px", gap: 36 }}>
          <div>{bodyChildren}</div>
          <div>{marginChildren}</div>
        </div>
      )}
    </div>
  );
}

function Body({ children, smaller = false }) {
  return (
    <div className="body-prose" style={smaller ? { fontSize: 12.5 } : {}}>
      {children}
    </div>
  );
}

function Marginalia({ children }) {
  return <div className="margin-note">{children}</div>;
}
Marginalia.displayName = "Marginalia";

function Row({ k, v, c }) {
  return (
    <div style={{ display: "grid", gridTemplateColumns: "1fr auto", padding: "3px 0", borderBottom: "1px dotted rgba(29,28,21,0.3)" }}>
      <span style={{ fontFamily: "var(--font-body)", fontStyle: "normal", fontSize: 10.5, color: "var(--color-on-surface-variant)", letterSpacing: "0.04em", textTransform: "uppercase", fontWeight: 600 }}>{k}</span>
      <span className="num" style={{ fontStyle: "normal", fontWeight: 700, color: c || "var(--color-on-surface)", fontSize: 12 }}>{v}</span>
    </div>
  );
}

function RowSep() {
  return <div style={{ height: 8 }}></div>;
}

Object.assign(window, { DirectionC });
