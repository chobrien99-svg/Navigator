import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";

// A Supabase client for server code that acts as the signed-in visitor,
// using the login cookie that src/proxy.ts checks. Database rules that only
// let the Navigator team read some tables therefore apply on the server too.
// Pages without a login cookie (e.g. /embed/*) read as an anonymous visitor.
export async function createServerSupabase() {
  const cookieStore = await cookies();
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-key",
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll() {
          // Server Components can't write cookies; src/proxy.ts refreshes them.
        },
      },
    }
  );
}
