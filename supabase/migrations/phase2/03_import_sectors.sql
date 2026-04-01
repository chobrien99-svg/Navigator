-- =============================================================================
-- PHASE 2 - IMPORT 2: Sectors
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 2 from 01_export_from_funding_tracker.sql in your Funding
--    Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $$[
      {
        "id": "6fca2c10-a80c-4a5b-95bb-189bb2f9d61e",
        "name": "AgriTech",
        "slug": "agritech",
        "description": null,
        "icon": null,
        "color": "#16a34a",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "b68c35c3-f137-4411-a909-727287a218ce",
        "name": "AgriTech & FoodTech",
        "slug": "agritech-and-foodtech",
        "description": null,
        "icon": null,
        "color": "#22c55e",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:28.561745+00:00"
      },
      {
        "id": "957f88d4-cef3-434f-9e97-d32430a0b3d1",
        "name": "AI & Machine Learning",
        "slug": "ai-and-machine-learning",
        "description": null,
        "icon": null,
        "color": "#8b5cf6",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:13.28444+00:00"
      },
      {
        "id": "271bbba6-b4b2-4eba-8620-27c76ad45a44",
        "name": "BioTech",
        "slug": "biotech",
        "description": null,
        "icon": null,
        "color": "#10b981",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "7e361422-b8c7-4bf9-a790-d72d80a02e71",
        "name": "CleanTech",
        "slug": "cleantech",
        "description": null,
        "icon": null,
        "color": "#84cc16",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "fe555b51-b028-4b3f-b224-236f995e29de",
        "name": "CleanTech & Energy",
        "slug": "cleantech-and-energy",
        "description": null,
        "icon": null,
        "color": "#84cc16",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:12.814233+00:00"
      },
      {
        "id": "bdef8de3-86df-4ec4-8b89-09f8383a3c7c",
        "name": "ClimateTech",
        "slug": "climatetech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-02-08T05:51:06.852295+00:00"
      },
      {
        "id": "85d97fce-0fdc-4d77-8495-306739ee2718",
        "name": "Cybersecurity",
        "slug": "cybersecurity",
        "description": null,
        "icon": null,
        "color": "#f43f5e",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:10.752444+00:00"
      },
      {
        "id": "46c56169-b321-49b6-9aca-7087ce4ed8e6",
        "name": "DeepTech",
        "slug": "deeptech",
        "description": null,
        "icon": null,
        "color": "#a855f7",
        "parent_sector_id": null,
        "created_at": "2026-01-26T17:05:39.826157+00:00"
      },
      {
        "id": "c54d430a-bb85-4716-a9dc-5bd8c77c3890",
        "name": "DeepTech & Hardware",
        "slug": "deeptech-and-hardware",
        "description": null,
        "icon": null,
        "color": "#6366f1",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:17.741502+00:00"
      },
      {
        "id": "79a9b568-874e-4ef9-a161-47112af11a97",
        "name": "DefenseTech",
        "slug": "defensetech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T22:19:42.339341+00:00"
      },
      {
        "id": "b4ae34bc-6645-4394-9170-d19e3cc75172",
        "name": "Drones",
        "slug": "drones",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:44:33.969317+00:00"
      },
      {
        "id": "bd5b2291-c1ee-4c6a-94ce-854ac35c98d1",
        "name": "E-commerce & Retail",
        "slug": "e-commerce-and-retail",
        "description": null,
        "icon": null,
        "color": "#f59e0b",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:13.695293+00:00"
      },
      {
        "id": "a2529dbc-56e9-438c-b9e8-73e29942fda9",
        "name": "Energy",
        "slug": "energy",
        "description": null,
        "icon": null,
        "color": "#facc15",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "d0b667b7-f381-463a-9b33-d0f4ba031237",
        "name": "Energy Hardware",
        "slug": "energy-hardware",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-02-27T10:14:07.863901+00:00"
      },
      {
        "id": "5e4453a0-3d62-4c89-ba21-255ae3e93865",
        "name": "Entertainment",
        "slug": "entertainment",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:55:46.455743+00:00"
      },
      {
        "id": "4a3bb002-bae4-453b-9b37-db710032443a",
        "name": "FinTech",
        "slug": "fintech",
        "description": null,
        "icon": null,
        "color": "#eab308",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:14.205875+00:00"
      },
      {
        "id": "9cf882db-6892-4b7d-8bf2-e091ce425866",
        "name": "FoodTech",
        "slug": "foodtech",
        "description": null,
        "icon": null,
        "color": "#22c55e",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "c0bf8c8f-e7ac-4501-9637-01137b9cbae4",
        "name": "Gaming",
        "slug": "gaming",
        "description": null,
        "icon": null,
        "color": "#a855f7",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:27:42.54534+00:00"
      },
      {
        "id": "cee357a7-0076-4678-9290-ab07819260b5",
        "name": "Hardware",
        "slug": "hardware",
        "description": null,
        "icon": null,
        "color": "#6366f1",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "0cd71bc5-82ee-428b-904b-67b4e7e4293c",
        "name": "HealthTech",
        "slug": "healthtech",
        "description": null,
        "icon": null,
        "color": "#10b981",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      },
      {
        "id": "2dea7360-f624-422e-a622-3b1dbc52da02",
        "name": "HealthTech & BioTech",
        "slug": "healthtech-and-biotech",
        "description": null,
        "icon": null,
        "color": "#10b981",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:18.872904+00:00"
      },
      {
        "id": "687ee8c4-ace9-45a7-b3b7-024ff3c490a2",
        "name": "Industrial Decarbonization",
        "slug": "industrial-decarbonization",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-02-27T10:14:07.604797+00:00"
      },
      {
        "id": "b706652c-b45f-44a6-beff-9147a89597fc",
        "name": "LegalTech",
        "slug": "legaltech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:55:46.243982+00:00"
      },
      {
        "id": "65b54846-05f9-466f-ae5a-41e1219883d9",
        "name": "MarTech",
        "slug": "martech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:44:34.174091+00:00"
      },
      {
        "id": "6429db8f-7a92-42b0-8657-18bf05a38336",
        "name": "MedTech",
        "slug": "medtech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-02-27T10:14:03.780979+00:00"
      },
      {
        "id": "71f8d11b-5caf-4af1-86ef-6bfb9d81272c",
        "name": "Mobility & Transportation",
        "slug": "mobility-and-transportation",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:51.847572+00:00"
      },
      {
        "id": "d91b44f7-3a42-44a2-8a24-ad8145f2e637",
        "name": "Other",
        "slug": "other",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:27:36.483614+00:00"
      },
      {
        "id": "a88ce2c8-7544-4d71-b774-6b82805b7070",
        "name": "PropTech",
        "slug": "proptech-and-real-estate",
        "description": null,
        "icon": null,
        "color": "#06b6d4",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:12.343651+00:00"
      },
      {
        "id": "65642bbc-57fc-4fda-b468-055ba2336b85",
        "name": "Robotics",
        "slug": "robotics",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:44:33.74934+00:00"
      },
      {
        "id": "50d276bc-d0d5-4c1b-812d-8d2a1bbb2662",
        "name": "SaaS & Enterprise",
        "slug": "saas-and-enterprise",
        "description": null,
        "icon": null,
        "color": "#3b82f6",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:10.573237+00:00"
      },
      {
        "id": "c9460d00-f17f-49ba-8562-721d8ff30daf",
        "name": "SpaceTech & Aerospace",
        "slug": "spacetech-and-aerospace",
        "description": null,
        "icon": null,
        "color": "#1e3a8a",
        "parent_sector_id": null,
        "created_at": "2026-01-24T23:26:21.241807+00:00"
      },
      {
        "id": "dfc2a6bc-56f2-405e-96ea-dcd7d23011b2",
        "name": "TravelTech",
        "slug": "traveltech",
        "description": null,
        "icon": null,
        "color": "#64748b",
        "parent_sector_id": null,
        "created_at": "2026-03-28T21:44:34.396936+00:00"
      },
      {
        "id": "84b033fb-d763-4c73-8923-1aac83823dd7",
        "name": "Web3",
        "slug": "web3",
        "description": null,
        "icon": null,
        "color": "#fb923c",
        "parent_sector_id": null,
        "created_at": "2026-02-07T23:03:53.875071+00:00"
      }
]$$::json
  ) AS (
    id               UUID,
    name             TEXT,
    slug             TEXT,
    description      TEXT,
    icon             TEXT,
    color            TEXT,
    parent_sector_id UUID,
    created_at       TIMESTAMPTZ
  )
)
INSERT INTO sectors (
  id,
  name,
  slug,
  description,
  icon,
  color,
  parent_id,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.name,
  s.slug,
  s.description,
  s.icon,
  s.color,
  s.parent_sector_id,
  COALESCE(s.created_at, NOW()),
  NOW()
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Verify
SELECT COUNT(*) AS sectors_imported FROM sectors;
