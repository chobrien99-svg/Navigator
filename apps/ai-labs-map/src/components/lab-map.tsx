"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

// ── Color palette ──────────────────────────────────────────────────────
const COLORS = {
  tier1: "#1d4ed8",      // blue-700 — core public AI labs
  tier2: "#7c3aed",      // violet-600 — strong AI presence
  private: "#dc2626",    // red-600 — private R&D
};

const CATEGORY_ICONS: Record<string, string> = {
  "Computer Science": "CS",
  "AI-Dedicated": "AI",
  "Engineering & Robotics": "ER",
  "Mathematics": "MA",
  "Private R&D": "PR",
};

// ── Types ──────────────────────────────────────────────────────────────
interface LabProperties {
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
}

interface GeoJSONFeature {
  type: "Feature";
  geometry: { type: "Point"; coordinates: [number, number] };
  properties: LabProperties;
}

interface GeoJSON {
  type: "FeatureCollection";
  features: GeoJSONFeature[];
}

// ── Filter state ───────────────────────────────────────────────────────
type FilterKey = "all" | "public" | "private" | "tier1" | "tier2";

const FILTERS: { key: FilterKey; label: string; color?: string }[] = [
  { key: "all", label: "All Labs" },
  { key: "public", label: "Public" },
  { key: "private", label: "Private R&D", color: COLORS.private },
  { key: "tier1", label: "Core AI", color: COLORS.tier1 },
  { key: "tier2", label: "AI-Active", color: COLORS.tier2 },
];

function matchesFilter(props: LabProperties, filter: FilterKey): boolean {
  switch (filter) {
    case "all":
      return true;
    case "public":
      return props.sector !== "private";
    case "private":
      return props.sector === "private";
    case "tier1":
      return props.tier === "tier1";
    case "tier2":
      return props.tier === "tier2";
  }
}

// ── Popup HTML ─────────────────────────────────────────────────────────

function buildPopupHTML(props: LabProperties): string {
  const title = props.acronym
    ? `<strong>${props.acronym}</strong>`
    : `<strong>${props.name}</strong>`;

  const subtitle =
    props.acronym && props.name !== props.acronym
      ? `<div style="font-size:12px;color:#555;margin-top:2px">${props.name}</div>`
      : "";

  const umr = props.umr
    ? `<div style="font-size:11px;color:#888;margin-top:1px">${props.umr}</div>`
    : "";

  const tierBadge =
    props.sector === "private"
      ? `<span style="background:${COLORS.private};color:#fff;padding:1px 6px;border-radius:9px;font-size:10px;font-weight:600">Private R&D</span>`
      : props.tier === "tier1"
        ? `<span style="background:${COLORS.tier1};color:#fff;padding:1px 6px;border-radius:9px;font-size:10px;font-weight:600">Core AI</span>`
        : `<span style="background:${COLORS.tier2};color:#fff;padding:1px 6px;border-radius:9px;font-size:10px;font-weight:600">AI-Active</span>`;

  const catBadge = `<span style="background:#e5e7eb;color:#374151;padding:1px 6px;border-radius:9px;font-size:10px">${props.category}</span>`;

  const affiliation = props.sector === "private"
    ? props.parent_company
      ? `<div style="margin-top:6px;font-size:12px"><span style="color:#888">Company:</span> ${props.parent_company}</div>`
      : ""
    : props.tutelles
      ? `<div style="margin-top:6px;font-size:12px"><span style="color:#888">Tutelles:</span> ${props.tutelles}</div>`
      : "";

  const city = props.city
    ? `<div style="font-size:12px"><span style="color:#888">City:</span> ${props.city}</div>`
    : "";

  const year = props.year_created
    ? `<div style="font-size:12px"><span style="color:#888">Est.:</span> ${props.year_created}</div>`
    : "";

  const links = [];
  if (props.website)
    links.push(`<a href="${props.website}" target="_blank" rel="noopener" style="color:#2563eb;font-size:12px">Website</a>`);
  if (props.rnsr_url)
    links.push(`<a href="${props.rnsr_url}" target="_blank" rel="noopener" style="color:#2563eb;font-size:12px">RNSR</a>`);

  const linksRow = links.length
    ? `<div style="margin-top:6px;display:flex;gap:10px">${links.join("")}</div>`
    : "";

  return `
    <div style="min-width:220px;max-width:320px;font-family:system-ui,sans-serif;line-height:1.4">
      <div>${title}</div>
      ${subtitle}
      ${umr}
      <div style="margin-top:6px;display:flex;gap:4px;flex-wrap:wrap">${tierBadge} ${catBadge}</div>
      ${affiliation}
      ${city}
      ${year}
      ${linksRow}
    </div>
  `;
}

// ── Map Component ──────────────────────────────────────────────────────

export function LabMap({ data }: { data: GeoJSON }) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const [filter, setFilter] = useState<FilterKey>("all");
  const [counts, setCounts] = useState({ total: 0, public: 0, private: 0 });

  // Compute counts
  useEffect(() => {
    const pub = data.features.filter((f) => f.properties.sector !== "private").length;
    const prv = data.features.filter((f) => f.properties.sector === "private").length;
    setCounts({ total: pub + prv, public: pub, private: prv });
  }, [data]);

  // Apply filter to map
  const applyFilter = useCallback(
    (map: maplibregl.Map, f: FilterKey) => {
      if (!map.getSource("labs")) return;
      const filtered = {
        ...data,
        features: data.features.filter((feat) =>
          matchesFilter(feat.properties, f)
        ),
      };
      (map.getSource("labs") as maplibregl.GeoJSONSource).setData(
        filtered as unknown as GeoJSON.FeatureCollection
      );
    },
    [data]
  );

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || mapRef.current) return;

    const map = new maplibregl.Map({
      container: mapContainer.current,
      style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
      center: [2.5, 46.8],
      zoom: 5.3,
      minZoom: 4,
      maxZoom: 14,
      attributionControl: false,
    });

    map.addControl(
      new maplibregl.AttributionControl({ compact: true }),
      "bottom-right"
    );
    map.addControl(new maplibregl.NavigationControl(), "bottom-right");

    map.on("load", () => {
      map.addSource("labs", {
        type: "geojson",
        data: data as unknown as GeoJSON.FeatureCollection,
      });

      // Circle layer
      map.addLayer({
        id: "labs-circles",
        type: "circle",
        source: "labs",
        paint: {
          "circle-radius": [
            "interpolate", ["linear"], ["zoom"],
            4, 5,
            8, 9,
            12, 14,
          ],
          "circle-color": [
            "match", ["get", "tier"],
            "tier1", COLORS.tier1,
            "tier2", COLORS.tier2,
            "private", COLORS.private,
            "#999",
          ],
          "circle-opacity": 0.85,
          "circle-stroke-color": "#fff",
          "circle-stroke-width": [
            "interpolate", ["linear"], ["zoom"],
            4, 1,
            8, 2,
          ],
        },
      });

      // Label layer
      map.addLayer({
        id: "labs-labels",
        type: "symbol",
        source: "labs",
        minzoom: 7,
        layout: {
          "text-field": ["coalesce", ["get", "acronym"], ["get", "name"]],
          "text-size": 11,
          "text-offset": [0, 1.5],
          "text-anchor": "top",
          "text-font": ["Open Sans Regular"],
          "text-max-width": 12,
        },
        paint: {
          "text-color": "#374151",
          "text-halo-color": "#fff",
          "text-halo-width": 1.5,
        },
      });

      // Click interaction
      map.on("click", "labs-circles", (e) => {
        if (!e.features?.[0]) return;
        const feat = e.features[0];
        const coords = (feat.geometry as GeoJSON.Point).coordinates.slice() as [number, number];
        const props = feat.properties as unknown as LabProperties;

        new maplibregl.Popup({ offset: 12, maxWidth: "340px" })
          .setLngLat(coords)
          .setHTML(buildPopupHTML(props))
          .addTo(map);
      });

      // Cursor
      map.on("mouseenter", "labs-circles", () => {
        map.getCanvas().style.cursor = "pointer";
      });
      map.on("mouseleave", "labs-circles", () => {
        map.getCanvas().style.cursor = "";
      });
    });

    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, [data]);

  // Re-apply filter when it changes
  useEffect(() => {
    if (mapRef.current) {
      applyFilter(mapRef.current, filter);
    }
  }, [filter, applyFilter]);

  return (
    <div style={{ position: "relative", width: "100%", height: "100vh" }}>
      {/* Map */}
      <div ref={mapContainer} style={{ width: "100%", height: "100%" }} />

      {/* Header overlay */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          padding: "14px 18px",
          background: "linear-gradient(to bottom, rgba(255,255,255,0.97), rgba(255,255,255,0.85))",
          backdropFilter: "blur(8px)",
          borderBottom: "1px solid #e5e7eb",
          zIndex: 10,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: "8px" }}>
          <div>
            <h1
              style={{
                margin: 0,
                fontSize: 18,
                fontWeight: 700,
                fontFamily: "system-ui, sans-serif",
                color: "#111",
              }}
            >
              France&apos;s AI Research Laboratories
            </h1>
            <p
              style={{
                margin: "2px 0 0",
                fontSize: 12,
                fontFamily: "system-ui, sans-serif",
                color: "#6b7280",
              }}
            >
              {counts.total} labs identified &middot; {counts.public} public &middot;{" "}
              {counts.private} private R&D &middot; Source: MESR RNSR + CNRS INS2I + JDN
            </p>
          </div>

          {/* Filter pills */}
          <div style={{ display: "flex", gap: 4, flexWrap: "wrap" }}>
            {FILTERS.map((f) => (
              <button
                key={f.key}
                onClick={() => setFilter(f.key)}
                style={{
                  padding: "4px 12px",
                  fontSize: 12,
                  fontFamily: "system-ui, sans-serif",
                  fontWeight: filter === f.key ? 600 : 400,
                  border: filter === f.key ? "2px solid #111" : "1px solid #d1d5db",
                  borderRadius: 16,
                  background: filter === f.key ? "#f9fafb" : "#fff",
                  color: "#111",
                  cursor: "pointer",
                }}
              >
                {f.color && (
                  <span
                    style={{
                      display: "inline-block",
                      width: 8,
                      height: 8,
                      borderRadius: 4,
                      background: f.color,
                      marginRight: 4,
                    }}
                  />
                )}
                {f.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Legend */}
      <div
        style={{
          position: "absolute",
          bottom: 36,
          left: 12,
          background: "rgba(255,255,255,0.95)",
          backdropFilter: "blur(8px)",
          borderRadius: 8,
          padding: "10px 14px",
          fontSize: 11,
          fontFamily: "system-ui, sans-serif",
          color: "#374151",
          boxShadow: "0 1px 4px rgba(0,0,0,0.12)",
          zIndex: 10,
          lineHeight: 1.6,
        }}
      >
        <div style={{ fontWeight: 600, marginBottom: 4, fontSize: 12 }}>Legend</div>
        <div>
          <span style={{ display: "inline-block", width: 10, height: 10, borderRadius: 5, background: COLORS.tier1, marginRight: 6 }} />
          Core AI Lab (public)
        </div>
        <div>
          <span style={{ display: "inline-block", width: 10, height: 10, borderRadius: 5, background: COLORS.tier2, marginRight: 6 }} />
          AI-Active Lab (public)
        </div>
        <div>
          <span style={{ display: "inline-block", width: 10, height: 10, borderRadius: 5, background: COLORS.private, marginRight: 6 }} />
          Private R&D Lab
        </div>
        <div style={{ marginTop: 6, fontSize: 10, color: "#9ca3af" }}>
          French Tech Journal / Navigator
        </div>
      </div>
    </div>
  );
}
