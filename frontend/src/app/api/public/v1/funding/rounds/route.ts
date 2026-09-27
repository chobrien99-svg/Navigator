import {
  getPublicRounds,
  parseYear,
  publicError,
  PUBLIC_API_HEADERS,
  type RoundSort,
} from "@/lib/public-funding";

export const dynamic = "force-dynamic";

const SORTS: RoundSort[] = ["announcement_date:desc", "amount_eur:desc"];
const MAX_LIMIT = 100;

// GET /api/public/v1/funding/rounds?year=2026&limit=50&sort=announcement_date:desc
export async function GET(request: Request) {
  const params = new URL(request.url).searchParams;
  const year = parseYear(params.get("year"));
  const limit = Number(params.get("limit") ?? 50);
  const sort = (params.get("sort") ?? "announcement_date:desc") as RoundSort;

  if (year == null) return publicError("Invalid year", 400);
  if (!Number.isInteger(limit) || limit < 1 || limit > MAX_LIMIT)
    return publicError(`limit must be between 1 and ${MAX_LIMIT}`, 400);
  if (!SORTS.includes(sort))
    return publicError(`sort must be one of: ${SORTS.join(", ")}`, 400);

  try {
    const data = await getPublicRounds({ year, limit, sort });
    const updated_at = data.reduce<string | null>(
      (max, r) => (!max || r.updated_at > max ? r.updated_at : max),
      null
    );
    return Response.json(
      { data, meta: { count: data.length, limit, sort, year, updated_at } },
      { headers: PUBLIC_API_HEADERS }
    );
  } catch (e) {
    console.error("[public-funding] rounds failed", e);
    return publicError("Funding data temporarily unavailable", 503);
  }
}

export function OPTIONS() {
  return new Response(null, { status: 204, headers: PUBLIC_API_HEADERS });
}
