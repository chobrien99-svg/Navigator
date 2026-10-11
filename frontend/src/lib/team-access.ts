// Who may use The Navigator while it is team-only.
// Anyone with a confirmed email at one of these domains, or one of the
// individual addresses below, can sign in. Everyone else is turned away,
// even if they have an account in Supabase (e.g. from France AI Radar).
export const TEAM_EMAIL_DOMAINS = ["frenchtechjournal.com"];

// Extra individual addresses outside those domains, all in lowercase,
// e.g. "someone@gmail.com".
export const TEAM_EMAILS: string[] = [];

type UserLike = {
  email?: string | null;
  email_confirmed_at?: string | null;
};

export function isTeamMember(user: UserLike | null | undefined): boolean {
  // An unconfirmed address could belong to anyone, so it never counts.
  if (!user?.email || !user.email_confirmed_at) return false;
  const email = user.email.trim().toLowerCase();
  const domain = email.split("@").pop() ?? "";
  return TEAM_EMAILS.includes(email) || TEAM_EMAIL_DOMAINS.includes(domain);
}
