import Link from "next/link";
import { getAllFundingRounds, formatEur, formatStage } from "@/lib/queries";
import type { FundingRound } from "@/lib/types";

export default async function FundingPage() {
  let rounds: FundingRound[] = [];
  let error: string | null = null;

  try {
    rounds = await getAllFundingRounds({ limit: 200 });
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load funding data";
  }

  // Quick stats
  const totalCapital = rounds.reduce(
    (sum, r) => sum + (r.amount_eur ?? 0),
    0
  );
  const verifiedCount = rounds.filter((r) => r.is_verified).length;
  const stageBreakdown = rounds.reduce(
    (acc, r) => {
      acc[r.stage] = (acc[r.stage] ?? 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );
  const topStages = Object.entries(stageBreakdown)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5);

  return (
    <div className="px-10 py-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Funding Tracker
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {rounds.length} funding events tracked across the ecosystem
          </p>
        </div>

        {/* Summary stats */}
        <div className="flex gap-10">
          <div className="text-right">
            <p className="diplomatic-label">Total Capital</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {formatEur(totalCapital)}
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Rounds</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {rounds.length}
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Verified</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {verifiedCount}
            </p>
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {/* Stage Breakdown chips */}
      {topStages.length > 0 && (
        <div className="mt-6 flex flex-wrap gap-2">
          {topStages.map(([stage, count]) => (
            <span
              key={stage}
              className="bg-primary-fixed/60 px-2.5 py-1 text-xs font-medium text-on-primary-fixed"
            >
              {formatStage(stage)}: {count}
            </span>
          ))}
        </div>
      )}

      {/* Funding Table */}
      <div className="mt-8">
        {/* Table Header */}
        <div className="flex items-center gap-4 px-5 py-3 text-xs">
          <div className="flex-1">
            <span className="diplomatic-label">Company</span>
          </div>
          <div className="w-28">
            <span className="diplomatic-label">Stage</span>
          </div>
          <div className="w-28 text-right">
            <span className="diplomatic-label">Amount</span>
          </div>
          <div className="w-28 text-right">
            <span className="diplomatic-label">Date</span>
          </div>
          <div className="w-48">
            <span className="diplomatic-label">Lead Investor</span>
          </div>
          <div className="w-16 text-center">
            <span className="diplomatic-label">Verified</span>
          </div>
        </div>

        {/* Rows */}
        <div className="space-y-1">
          {rounds.map((round) => {
            const company = round.organizations as {
              name: string;
              slug: string;
              organization_type: string;
            } | null;
            const investors = round.funding_round_investors ?? [];
            const lead = investors.find((i) => i.is_lead);
            const leadOrg = lead?.organizations as {
              name: string;
              slug: string;
            } | null;
            const leadName =
              leadOrg?.name ?? lead?.investor_name ?? "—";

            return (
              <div
                key={round.id}
                className="flex items-center gap-4 bg-surface-container-lowest px-5 py-4 transition-colors duration-200 hover:bg-surface-container-low"
              >
                {/* Company */}
                <div className="flex-1 min-w-0">
                  {company ? (
                    <Link
                      href={`/entities/${company.slug}`}
                      className="text-sm font-medium text-on-surface hover:text-primary"
                    >
                      {company.name}
                    </Link>
                  ) : (
                    <span className="text-sm text-on-surface-variant">—</span>
                  )}
                </div>

                {/* Stage */}
                <div className="w-28">
                  <span className="text-sm text-on-surface">
                    {formatStage(round.stage)}
                  </span>
                </div>

                {/* Amount */}
                <div className="w-28 text-right">
                  <span className="text-sm font-medium text-on-surface">
                    {formatEur(round.amount_eur)}
                  </span>
                  {round.is_estimated && (
                    <span className="ml-1 text-[0.6rem] text-on-surface-variant">
                      est.
                    </span>
                  )}
                </div>

                {/* Date */}
                <div className="w-28 text-right">
                  <span className="text-sm text-on-surface-variant">
                    {round.announced_date
                      ? new Date(round.announced_date).toLocaleDateString(
                          "en-GB",
                          {
                            month: "short",
                            year: "numeric",
                          }
                        )
                      : "—"}
                  </span>
                </div>

                {/* Lead Investor */}
                <div className="w-48 min-w-0">
                  {leadOrg ? (
                    <Link
                      href={`/entities/${leadOrg.slug}`}
                      className="truncate text-sm text-on-surface hover:text-primary"
                    >
                      {leadName}
                    </Link>
                  ) : (
                    <span className="truncate text-sm text-on-surface-variant">
                      {leadName}
                    </span>
                  )}
                  {investors.length > 1 && (
                    <span className="ml-1 text-[0.6rem] text-on-surface-variant">
                      +{investors.length - 1}
                    </span>
                  )}
                </div>

                {/* Verified */}
                <div className="w-16 text-center">
                  {round.is_verified ? (
                    <span className="material-symbols-outlined text-[16px] text-secondary">
                      verified
                    </span>
                  ) : (
                    <span className="material-symbols-outlined text-[16px] text-outline-variant">
                      pending
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {rounds.length === 0 && !error && (
          <div className="py-20 text-center">
            <p className="font-headline text-lg italic text-on-surface-variant">
              No funding rounds found in the database yet.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
