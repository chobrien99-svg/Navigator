// ─── App entry — mount design canvas with three direction artboards ───

const { DesignCanvas, DCSection, DCArtboard, DCPostIt } = window;
const { DirectionA, DirectionB, DirectionC } = window;

function App() {
  return (
    <DesignCanvas
      title="French Tech Next 40 / 120 — Redesign Directions"
      subtitle="Three editorial takes on the 6th-cohort announcement · 22 May 2025"
    >
      <DCSection
        id="directions"
        title="Editorial directions"
        subtitle="All three lean institutional / FT-style; cohort flow as hero. Each tells a different story with the same data."
      >
        <DCArtboard
          id="dir-a"
          label="A · The Class of 2025 — Annual report"
          width={1440}
          height={2700}
          style={{ background: "#1d1c15" }}
        >
          <DirectionA />
        </DCArtboard>

        <DCArtboard
          id="dir-b"
          label="B · Bulletin Nº 6 — Newspaper grid"
          width={1440}
          height={2480}
          style={{ background: "#1d1c15" }}
        >
          <DirectionB />
        </DCArtboard>

        <DCArtboard
          id="dir-c"
          label="C · Working Paper — Ministerial dossier"
          width={1280}
          height={3200}
          style={{ background: "#1d1c15" }}
        >
          <DirectionC />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);
