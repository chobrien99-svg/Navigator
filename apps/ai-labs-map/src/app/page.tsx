"use client";

import { useEffect, useState } from "react";
import { LabMap } from "@/components/lab-map";

interface GeoJSONFeature {
  type: "Feature";
  geometry: { type: "Point"; coordinates: [number, number] };
  properties: {
    name: string;
    acronym: string | null;
    umr: string | null;
    type: string | null;
    sector: string;
    tier: string;
    category: string;
    city: string;
    tutelles: string | null;
    parent_company: string | null;
    year_created: string | null;
    website: string | null;
    ai_score: number;
    rnsr_url: string | null;
  };
}

interface GeoJSON {
  type: "FeatureCollection";
  features: GeoJSONFeature[];
}

export default function Home() {
  const [data, setData] = useState<GeoJSON | null>(null);

  useEffect(() => {
    fetch("/data/ai-labs.geojson")
      .then((r) => r.json())
      .then(setData);
  }, []);

  if (!data) {
    return (
      <div
        style={{
          height: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily: "system-ui, sans-serif",
          color: "#666",
        }}
      >
        Loading map data...
      </div>
    );
  }

  return <LabMap data={data} />;
}
