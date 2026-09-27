import {
  getPublicSummary,
  parseYear,
  publicError,
  PUBLIC_API_HEADERS,
} from "@/lib/public-funding";

export const dynamic = "force-dynamic";

// GET /api/public/v1/funding/summary?year=2026
export async function GET(request: Request) {
  const year = parseYear(new URL(request.url).searchParams.get("year"));
  if (year == null) return publicError("Invalid year", 400);

  try {
    const summary = await getPublicSummary(year);
    return Response.json(summary, { headers: PUBLIC_API_HEADERS });
  } catch (e) {
    console.error("[public-funding] summary failed", e);
    return publicError("Funding data temporarily unavailable", 503);
  }
}

export function OPTIONS() {
  return new Response(null, { status: 204, headers: PUBLIC_API_HEADERS });
}
