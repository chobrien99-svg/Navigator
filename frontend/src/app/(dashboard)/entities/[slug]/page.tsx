import Link from "next/link";
import { notFound } from "next/navigation";
import {
  getOrganizationBySlug,
  getOrganizationFunding,
  getOrganizationPeople,
  getOrganizationLegalEntities,
  getOrganizationRelationships,
  getOrganizationTags,
  getInvestorPortfolio,
  formatEur,
  formatStage,
} from "@/lib/queries";

export default async function EntityDossierPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  let org;
  try {
    org = await getOrganizationBySlug(slug);
  } catch {
    notFound();
  }

  const [funding, people, legalEntities, relationships, tags] =
    await Promise.all([
      getOrganizationFunding(org.id),
      getOrganizationPeople(org.id),
      getOrganizationLegalEntities(org.id),
      getOrganizationRelationships(org.id),
      getOrganizationTags(org.id),
    ]);

  // If investor, also fetch portfolio
  const portfolio =
    org.organization_type === "investor"
      ? await getInvestorPortfolio(org.id)
      : null;

  const profile = org.organization_profiles?.[0];
  const sectors = org.organization_sectors ?? [];
  const primarySector = sectors.find((s) => s.is_primary) ?? sectors[0];
  const cityName =
    (org.cities as { name: string; region?: string } | null)?.name ?? "—";
  const region =
    (org.cities as { name: string; region?: string } | null)?.region ?? null;
  const founders = people.filter((p) => p.is_founder);
  const team = people.filter((p) => !p.is_founder && p.is_current);
  const primaryLegal = legalEntities.find((l) => l.is_primary) ?? legalEntities[0];
  const allRelationships = [
    ...relationships.outbound.map((r) => ({
      type: r.relationship_type,
      description: r.description,
      org: r.target_org as { name: string; slug: string } | undefined,
      direction: "outbound" as const,
    })),
    ...relationships.inbound.map((r) => ({
      type: r.relationship_type,
      description: r.description,
      org: r.source_org as { name: string; slug: string } | undefined,
      direction: "inbound" as const,
    })),
  ];

  const isInvestor = org.organization_type === "investor";
  const isStartup = org.organization_type === "startup";

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <Link href="/entities" className="hover:text-on-surface">
          Entities
        </Link>
        <span className="mx-2">›</span>
        {primarySector?.sectors?.name && (
          <>
            <span>{primarySector.sectors.name}</span>
            <span className="mx-2">›</span>
          </>
        )}
        <span className="text-on-surface">{org.name}</span>
      </div>

      {/* Dossier Header */}
      <div className="mt-6 flex items-start justify-between">
        <div className="max-w-2xl">
          <p className="diplomatic-label">
            {isInvestor
              ? "Investor Dossier"
              : isStartup
                ? "Startup Dossier"
                : "Entity Dossier"}
          </p>
          <h1 className="mt-2 font-headline text-4xl font-semibold tracking-tight text-on-surface">
            {org.name}
          </h1>
          {(org.short_description ?? org.description) && (
            <p className="mt-2 font-headline text-base italic text-on-surface-variant">
              {org.short_description ?? org.description}
            </p>
          )}
        </div>

        {/* Key number — Total Raised or Signal Count */}
        <div className="text-right">
          {org.total_raised_eur != null && org.total_raised_eur > 0 ? (
            <>
              <p className="diplomatic-label">Total Raised</p>
              <p className="mt-1 font-headline text-4xl font-bold text-primary">
                {formatEur(org.total_raised_eur)}
              </p>
            </>
          ) : (
            org.signal_count != null &&
            org.signal_count > 0 && (
              <>
                <p className="diplomatic-label">Signals</p>
                <p className="mt-1 font-headline text-4xl font-bold text-primary">
                  {org.signal_count}
                </p>
              </>
            )
          )}
        </div>
      </div>

      {/* Vitality Summary Bar */}
      <div className="mt-8 flex flex-wrap items-center gap-6 bg-surface-container-low px-6 py-4">
        <div className="flex items-center gap-2">
          <span
            className={`inline-block h-2 w-2 ${
              org.status === "active" ? "bg-secondary" : "bg-outline"
            }`}
          />
          <span className="text-sm text-on-surface">{org.status}</span>
        </div>
        <div>
          <span className="diplomatic-label">Type</span>
          <span className="ml-2 text-sm text-on-surface">
            {org.organization_type.replace(/_/g, " ")}
          </span>
        </div>
        {primarySector?.sectors?.name && (
          <div>
            <span className="diplomatic-label">Sector</span>
            <span className="ml-2 text-sm text-on-surface">
              {primarySector.sectors.name}
            </span>
          </div>
        )}
        <div>
          <span className="diplomatic-label">Location</span>
          <span className="ml-2 text-sm text-on-surface">
            {cityName}
            {region ? `, ${region}` : ""}
          </span>
        </div>
        {org.employee_range && (
          <div>
            <span className="diplomatic-label">Employees</span>
            <span className="ml-2 text-sm text-on-surface">
              {org.employee_range}
            </span>
          </div>
        )}
        {org.founded_year && (
          <div>
            <span className="diplomatic-label">Founded</span>
            <span className="ml-2 text-sm text-on-surface">
              {org.founded_year}
            </span>
          </div>
        )}
        {org.fundraising_status &&
          org.fundraising_status !== "unknown" && (
            <div>
              <span className="diplomatic-label">Fundraising</span>
              <span className="ml-2 text-sm text-on-surface">
                {org.fundraising_status.replace(/_/g, " ")}
              </span>
            </div>
          )}
      </div>

      {/* Main Content — 3/5 + 2/5 asymmetric */}
      <div className="mt-10 grid grid-cols-5 gap-10">
        {/* Left Column */}
        <div className="col-span-3 space-y-10">
          {/* Profile / Executive Summary */}
          {profile && (
            <section>
              <h2 className="diplomatic-label mb-4">Executive Summary</h2>
              {profile.what_they_are_building && (
                <div className="mb-4">
                  <p className="text-xs font-semibold text-on-surface-variant">
                    What They&apos;re Building
                  </p>
                  <p className="mt-1 text-sm leading-relaxed text-on-surface">
                    {profile.what_they_are_building}
                  </p>
                </div>
              )}
              {profile.why_it_matters && (
                <div className="mb-4">
                  <p className="text-xs font-semibold text-on-surface-variant">
                    Why It Matters
                  </p>
                  <p className="mt-1 text-sm leading-relaxed text-on-surface">
                    {profile.why_it_matters}
                  </p>
                </div>
              )}
              {profile.investor_brief && (
                <div className="mb-4">
                  <p className="text-xs font-semibold text-on-surface-variant">
                    Investor Brief
                  </p>
                  <p className="mt-1 text-sm leading-relaxed text-on-surface">
                    {profile.investor_brief}
                  </p>
                </div>
              )}
              {profile.analyst_note && (
                <div>
                  <p className="text-xs font-semibold text-on-surface-variant">
                    Analyst Note
                  </p>
                  <p className="mt-1 text-sm italic leading-relaxed text-on-surface-variant">
                    {profile.analyst_note}
                  </p>
                </div>
              )}
            </section>
          )}

          {/* Long description fallback */}
          {!profile && org.description && (
            <section>
              <h2 className="diplomatic-label mb-4">About</h2>
              <p className="text-sm leading-relaxed text-on-surface-variant">
                {org.description}
              </p>
            </section>
          )}

          {/* Structural DNA / Legal */}
          {primaryLegal && (
            <section>
              <h2 className="diplomatic-label mb-4">Structural DNA</h2>
              <div className="space-y-3">
                <div>
                  <p className="text-xs text-on-surface-variant">Legal Name</p>
                  <p className="text-sm text-on-surface">
                    {primaryLegal.legal_name}
                  </p>
                </div>
                {primaryLegal.legal_form && (
                  <div>
                    <p className="text-xs text-on-surface-variant">
                      Legal Form
                    </p>
                    <p className="text-sm text-on-surface">
                      {primaryLegal.legal_form}
                    </p>
                  </div>
                )}
                {primaryLegal.siren && (
                  <div>
                    <p className="text-xs text-on-surface-variant">SIREN</p>
                    <p className="text-sm text-on-surface">
                      {primaryLegal.siren}
                    </p>
                  </div>
                )}
                {primaryLegal.capital_eur != null && (
                  <div>
                    <p className="text-xs text-on-surface-variant">
                      Share Capital
                    </p>
                    <p className="text-sm text-on-surface">
                      {formatEur(primaryLegal.capital_eur)}
                    </p>
                  </div>
                )}
              </div>
            </section>
          )}

          {/* Founders & Team */}
          {people.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">
                {isInvestor ? "Key People" : "Founders & Team"}
              </h2>
              <div className="space-y-4">
                {founders.map((op) => (
                  <Link
                    key={op.id}
                    href={`/people/${op.people?.slug}`}
                    className="flex items-center gap-4 transition-colors hover:text-primary"
                  >
                    <div className="flex h-10 w-10 items-center justify-center bg-primary-fixed text-sm font-semibold text-on-primary-fixed">
                      {op.people?.full_name
                        ?.split(" ")
                        .map((n) => n[0])
                        .join("") ?? "?"}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-on-surface">
                        {op.people?.full_name}
                      </p>
                      <p className="text-xs text-on-surface-variant">
                        {op.title ?? op.role ?? "Founder"}
                      </p>
                    </div>
                  </Link>
                ))}
                {team.slice(0, 5).map((op) => (
                  <Link
                    key={op.id}
                    href={`/people/${op.people?.slug}`}
                    className="flex items-center gap-4 transition-colors hover:text-primary"
                  >
                    <div className="flex h-10 w-10 items-center justify-center bg-surface-container-high text-sm font-semibold text-on-surface-variant">
                      {op.people?.full_name
                        ?.split(" ")
                        .map((n) => n[0])
                        .join("") ?? "?"}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-on-surface">
                        {op.people?.full_name}
                      </p>
                      <p className="text-xs text-on-surface-variant">
                        {op.title ?? op.role ?? "Team"}
                      </p>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {/* Investor Portfolio (only for investor type) */}
          {isInvestor && portfolio && portfolio.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">
                Portfolio ({portfolio.length} investments)
              </h2>
              <div className="space-y-3">
                {portfolio.map((inv) => {
                  const round = inv.funding_rounds as FundingRoundWithOrg | null;
                  const company = round?.organizations as { name: string; slug: string } | null;
                  return (
                    <div
                      key={inv.id}
                      className="flex items-center justify-between bg-surface-container-lowest p-4"
                    >
                      <div>
                        {company ? (
                          <Link
                            href={`/entities/${company.slug}`}
                            className="text-sm font-medium text-on-surface hover:text-primary"
                          >
                            {company.name}
                          </Link>
                        ) : (
                          <p className="text-sm text-on-surface-variant">
                            Unknown company
                          </p>
                        )}
                        <p className="text-xs text-on-surface-variant">
                          {round ? formatStage(round.stage) : "—"}
                          {round?.announced_date
                            ? ` · ${new Date(round.announced_date).toLocaleDateString("en-GB", { month: "short", year: "numeric" })}`
                            : ""}
                        </p>
                      </div>
                      <div className="text-right">
                        {inv.is_lead && (
                          <span className="text-[0.6rem] font-semibold text-secondary">
                            LEAD
                          </span>
                        )}
                        <p className="text-sm font-medium text-on-surface">
                          {round ? formatEur(round.amount_eur) : "—"}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>
          )}
        </div>

        {/* Right Column */}
        <div className="col-span-2 space-y-8">
          {/* Tags */}
          {tags.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-3">Tags</h2>
              <div className="flex flex-wrap gap-2">
                {tags.map((t) => (
                  <span
                    key={t.id}
                    className="bg-primary-fixed/60 px-2 py-1 text-xs font-medium text-on-primary-fixed"
                  >
                    {t.tag}
                  </span>
                ))}
              </div>
            </section>
          )}

          {/* Relationships / Network */}
          {allRelationships.length > 0 && (
            <section className="bg-surface-container-low p-6">
              <h2 className="diplomatic-label mb-4">Institutional Lineage</h2>
              <div className="space-y-3">
                {allRelationships.map((rel, i) => (
                  <div key={i}>
                    <p className="diplomatic-label text-[0.6rem]">
                      {rel.type.replace(/_/g, " ")}
                      {rel.direction === "inbound" ? " (by)" : ""}
                    </p>
                    {rel.org ? (
                      <Link
                        href={`/entities/${rel.org.slug}`}
                        className="text-sm text-on-surface hover:text-primary"
                      >
                        {rel.org.name}
                      </Link>
                    ) : (
                      <p className="text-sm text-on-surface-variant">
                        {rel.description ?? "—"}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Funding Lineage */}
          {funding.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">Funding Lineage</h2>
              <div className="space-y-4">
                {funding.map((round) => {
                  const investors =
                    round.funding_round_investors ?? [];
                  const leadInvestor = investors.find((i) => i.is_lead);
                  const investorOrg = leadInvestor?.organizations as
                    | { name: string }
                    | undefined;
                  return (
                    <div
                      key={round.id}
                      className="flex items-start justify-between"
                    >
                      <div>
                        <p className="text-sm font-medium text-on-surface">
                          {formatStage(round.stage)}
                        </p>
                        <p className="text-xs text-on-surface-variant">
                          {investorOrg?.name ??
                            leadInvestor?.investor_name ??
                            `${investors.length} investor${investors.length !== 1 ? "s" : ""}`}
                          {leadInvestor ? " (Lead)" : ""}
                        </p>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-medium text-on-surface">
                          {formatEur(round.amount_eur)}
                        </p>
                        <p className="text-xs text-on-surface-variant">
                          {round.announced_date
                            ? new Date(
                                round.announced_date
                              ).toLocaleDateString("en-GB", {
                                month: "short",
                                year: "numeric",
                              })
                            : "—"}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>
          )}

          {/* Links */}
          <section>
            <h2 className="diplomatic-label mb-3">Links</h2>
            <div className="space-y-2">
              {org.website && (
                <a
                  href={org.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    language
                  </span>
                  Website
                </a>
              )}
              {org.linkedin_url && (
                <a
                  href={org.linkedin_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    link
                  </span>
                  LinkedIn
                </a>
              )}
              {org.twitter_url && (
                <a
                  href={org.twitter_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    link
                  </span>
                  Twitter / X
                </a>
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}

// Local type helper for portfolio query shape
type FundingRoundWithOrg = {
  stage: string;
  amount_eur: number | null;
  announced_date: string | null;
  organizations: { name: string; slug: string } | null;
};
