import {
  getPublicAnnual,
  parseYear,
  publicError,
  PUBLIC_API_HEADERS,
} from "@/lib/public-funding";

export const dynamic = "force-dynamic";

const MAX_SPAN = 15;

// GET /api/public/v1/funding/annual?from=2021&to=2026
export async function GET(request: Request) {
  const params = new URL(request.url).searchParams;
  const to = parseYear(params.get("to"));
  const from = parseYear(params.get("from") ?? String((to ?? new Date().getFullYear()) - 5));

  if (from == null || to == null) return publicError("Invalid year", 400);
  if (from > to || to - from > MAX_SPAN)
    return publicError(`from must be <= to, spanning at most ${MAX_SPAN} years`, 400);

  try {
    const data = await getPublicAnnual(from, to);
    return Response.json({ data, meta: { from, to } }, { headers: PUBLIC_API_HEADERS });
  } catch (e) {
    console.error("[public-funding] annual failed", e);
    return publicError("Funding data temporarily unavailable", 503);
  }
}

export function OPTIONS() {
  return new Response(null, { status: 204, headers: PUBLIC_API_HEADERS });
}
