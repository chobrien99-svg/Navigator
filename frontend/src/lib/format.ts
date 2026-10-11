// ─── Helpers ──────────────────────────────────────────────────

// Amounts in the funding_rounds table are stored in millions (€M).
// e.g. 1818.18 means €1,818.18M = €1,818,180,000
const AMOUNT_MULTIPLIER = 1_000_000;

export function toRawEur(amountInMillions: number | null): number | null {
  if (amountInMillions == null) return null;
  return amountInMillions * AMOUNT_MULTIPLIER;
}

export function formatEur(amount: number | null): string {
  if (amount == null) return "—";
  if (amount >= 1_000_000_000)
    return `€${(amount / 1_000_000_000).toFixed(1)}B`;
  if (amount >= 1_000_000) return `€${(amount / 1_000_000).toFixed(1)}M`;
  if (amount >= 1_000) return `€${(amount / 1_000).toFixed(0)}K`;
  return `€${amount.toLocaleString()}`;
}

/** Format an amount stored in millions (as in the DB) directly to display */
export function formatEurFromDb(amountInMillions: number | null): string {
  return formatEur(toRawEur(amountInMillions));
}

export function formatStage(stage: string): string {
  return stage
    .replace(/_/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}
