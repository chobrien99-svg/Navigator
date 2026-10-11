import { getPublicRounds, getPublicSummary, parseYear } from "@/lib/public-funding";
import { renderEmbedDocument, renderPaidModule } from "@/lib/funding-hub/render.mjs";
import config from "@/lib/funding-hub/config.json";

export const dynamic = "force-dynamic";

// Paid-member data module for frenchtechjournal.com/funding/, embedded with
// an iframe (see scripts/ftj-funding-hub/embed-snippet.html). Same rendering
// code as the free module the sync writes into Ghost.
export async function GET(request: Request) {
  const year = parseYear(new URL(request.url).searchParams.get("year"));
  if (year == null) return new Response("Invalid year", { status: 400 });

  try {
    const [summary, latest, largest] = await Promise.all([
      getPublicSummary(year),
      getPublicRounds({ year, limit: config.latestLimit, sort: "announcement_date:desc" }),
      getPublicRounds({ year, limit: config.largestLimit, sort: "amount_eur:desc" }),
    ]);
    const html = renderEmbedDocument({
      title: `French startup funding ${year}: rounds, stages and sectors`,
      body: renderPaidModule({ summary, latest, largest, config }),
    });
    return new Response(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Cache-Control": "public, s-maxage=1800, stale-while-revalidate=86400, stale-if-error=86400",
        "X-Robots-Tag": "noindex, nofollow",
      },
    });
  } catch (e) {
    console.error("[embed/funding-hub] failed", e);
    // Short, quiet fallback: the CDN keeps serving the last good copy
    // (stale-if-error) and the parent page stays intact.
    return new Response(
      renderEmbedDocument({ body: `<p style="font:15px Inter,sans-serif;color:#4E5965">Funding data is temporarily unavailable. Please check back shortly.</p>` }),
      { status: 503, headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" } }
    );
  }
}
