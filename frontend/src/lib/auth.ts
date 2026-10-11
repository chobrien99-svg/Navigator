import { supabase } from "./supabase";

export async function signInWithEmail(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  if (error) throw error;
  return data;
}

// "global" (Supabase's default) ends the account's sessions everywhere,
// including on other sites sharing this Supabase project; "local" only
// ends this browser's session.
export async function signOut(scope: "global" | "local" = "global") {
  const { error } = await supabase.auth.signOut({ scope });
  if (error) throw error;
}

export async function getSession() {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  return session;
}

export async function getUser() {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
}
