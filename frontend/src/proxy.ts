import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

// Paths anyone can reach without logging in. Everything else requires a
// signed-in Supabase user.
//  - /login: the sign-in page itself
//  - /api/public/*: JSON feed read by the FTJ Funding Hub sync (GitHub Action)
//  - /embed/*: iframes embedded on frenchtechjournal.com
const PUBLIC_PREFIXES = ["/login", "/api/public/", "/embed/"];

function isPublic(pathname: string) {
  return PUBLIC_PREFIXES.some(
    (prefix) => pathname === prefix.replace(/\/$/, "") || pathname.startsWith(prefix)
  );
}

export async function proxy(request: NextRequest) {
  const { pathname, search } = request.nextUrl;

  if (isPublic(pathname)) return NextResponse.next();

  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-key",
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // getUser() checks the session with Supabase, so a forged cookie won't pass.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("next", pathname + search);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}

export const config = {
  matcher: [
    // Run on everything except Next.js internals and top-level static files
    // (favicon, public/*.svg). Only single-segment paths are skipped, so a
    // page like /entities/foo.svg still goes through the login check.
    "/((?!_next/static|_next/image|[^/]+\\.(?:ico|png|jpg|jpeg|gif|svg|webp|txt|xml)$).*)",
  ],
};
