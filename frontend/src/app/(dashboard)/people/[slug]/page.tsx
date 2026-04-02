import Link from "next/link";
import { notFound } from "next/navigation";
import {
  getPersonBySlug,
  getPersonOrganizations,
  getPersonExperience,
} from "@/lib/queries";

export default async function PersonProfilePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  let person;
  try {
    person = await getPersonBySlug(slug);
  } catch {
    notFound();
  }

  const [orgRoles, experience] = await Promise.all([
    getPersonOrganizations(person.id),
    getPersonExperience(person.id),
  ]);

  const currentRoles = orgRoles.filter((r) => r.is_current);
  const pastRoles = orgRoles.filter((r) => !r.is_current);

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <Link href="/people" className="hover:text-on-surface">
          People
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">{person.full_name}</span>
      </div>

      {/* Header */}
      <div className="mt-6 flex items-start gap-8">
        {/* Avatar */}
        <div className="flex h-24 w-24 shrink-0 items-center justify-center bg-primary-fixed text-2xl font-semibold text-on-primary-fixed">
          {person.full_name
            .split(" ")
            .map((n) => n[0])
            .join("")
            .slice(0, 2)}
        </div>

        <div className="flex-1">
          <p className="diplomatic-label">Dossier Personnel</p>
          <h1 className="mt-2 font-headline text-4xl font-semibold tracking-tight text-on-surface">
            {person.full_name}
          </h1>
          {person.bio && (
            <p className="mt-2 max-w-2xl font-headline text-base italic text-on-surface-variant">
              {person.bio}
            </p>
          )}

          {/* Badges */}
          <div className="mt-4 flex flex-wrap items-center gap-3">
            {person.has_phd && (
              <span className="bg-research/15 px-2 py-1 text-xs font-semibold text-research">
                PhD
              </span>
            )}
            {person.is_repeat_founder && (
              <span className="bg-secondary/10 px-2 py-1 text-xs font-semibold text-secondary">
                Repeat Founder
              </span>
            )}
            {person.has_big_tech_background && (
              <span className="bg-primary/10 px-2 py-1 text-xs font-semibold text-primary">
                Ex-{person.big_tech_employer ?? "Big Tech"}
              </span>
            )}
            {person.academic_lab && (
              <span className="bg-tertiary/10 px-2 py-1 text-xs font-semibold text-tertiary">
                {person.academic_lab}
              </span>
            )}
            {person.previous_exits > 0 && (
              <span className="bg-secondary/10 px-2 py-1 text-xs font-semibold text-secondary">
                {person.previous_exits} previous exit
                {person.previous_exits !== 1 ? "s" : ""}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="mt-10 grid grid-cols-5 gap-10">
        {/* Left Column — Current Roles & Experience Timeline */}
        <div className="col-span-3 space-y-10">
          {/* Current Positions */}
          {currentRoles.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">Current Positions</h2>
              <div className="space-y-4">
                {currentRoles.map((role) => {
                  const org = role.organizations as {
                    name: string;
                    slug: string;
                    organization_type: string;
                    cities?: { name: string } | null;
                  } | null;
                  return (
                    <div
                      key={role.id}
                      className="flex items-start justify-between bg-surface-container-lowest p-5"
                    >
                      <div>
                        {org ? (
                          <Link
                            href={`/entities/${org.slug}`}
                            className="font-headline text-base font-semibold text-on-surface hover:text-primary"
                          >
                            {org.name}
                          </Link>
                        ) : (
                          <p className="text-sm text-on-surface-variant">
                            Unknown organization
                          </p>
                        )}
                        <p className="mt-0.5 text-sm text-on-surface-variant">
                          {role.title ?? role.role ?? "—"}
                        </p>
                        {role.is_founder && (
                          <span className="mt-1 inline-block bg-primary/10 px-1.5 py-0.5 text-[0.6rem] font-semibold text-primary">
                            FOUNDER
                          </span>
                        )}
                      </div>
                      {role.start_date && (
                        <p className="text-xs text-on-surface-variant">
                          Since{" "}
                          {new Date(role.start_date).toLocaleDateString(
                            "en-GB",
                            { month: "short", year: "numeric" }
                          )}
                        </p>
                      )}
                    </div>
                  );
                })}
              </div>
            </section>
          )}

          {/* Experience Timeline */}
          {experience.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">Experience Timeline</h2>
              <div className="relative space-y-6 pl-6">
                {/* Vertical line */}
                <div className="absolute top-0 left-[3px] h-full w-px bg-outline-variant/30" />

                {experience.map((exp) => {
                  const org = exp.organizations as {
                    name: string;
                    slug: string;
                  } | null;
                  return (
                    <div key={exp.id} className="relative">
                      {/* Dot */}
                      <div
                        className={`absolute -left-6 top-1.5 h-1.5 w-1.5 ${
                          exp.is_current ? "bg-primary" : "bg-outline-variant"
                        }`}
                      />
                      <div>
                        <p className="text-sm font-medium text-on-surface">
                          {exp.title ?? exp.role ?? "—"}
                        </p>
                        <p className="text-xs text-on-surface-variant">
                          {org ? (
                            <Link
                              href={`/entities/${org.slug}`}
                              className="hover:text-primary"
                            >
                              {org.name}
                            </Link>
                          ) : (
                            exp.company_name ?? "—"
                          )}
                        </p>
                        <p className="mt-0.5 text-xs text-outline">
                          {exp.start_date
                            ? new Date(exp.start_date).toLocaleDateString(
                                "en-GB",
                                { month: "short", year: "numeric" }
                              )
                            : "?"}
                          {" — "}
                          {exp.is_current
                            ? "Present"
                            : exp.end_date
                              ? new Date(exp.end_date).toLocaleDateString(
                                  "en-GB",
                                  { month: "short", year: "numeric" }
                                )
                              : "?"}
                        </p>
                        {exp.description && (
                          <p className="mt-1 text-xs leading-relaxed text-on-surface-variant">
                            {exp.description}
                          </p>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </section>
          )}

          {/* Past Roles */}
          {pastRoles.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">Past Positions</h2>
              <div className="space-y-3">
                {pastRoles.map((role) => {
                  const org = role.organizations as {
                    name: string;
                    slug: string;
                  } | null;
                  return (
                    <div
                      key={role.id}
                      className="flex items-start justify-between"
                    >
                      <div>
                        <p className="text-sm text-on-surface">
                          {org ? (
                            <Link
                              href={`/entities/${org.slug}`}
                              className="hover:text-primary"
                            >
                              {org.name}
                            </Link>
                          ) : (
                            "—"
                          )}
                        </p>
                        <p className="text-xs text-on-surface-variant">
                          {role.title ?? role.role ?? "—"}
                        </p>
                      </div>
                      <p className="text-xs text-on-surface-variant">
                        {role.start_date
                          ? new Date(role.start_date).getFullYear()
                          : "?"}
                        {" — "}
                        {role.end_date
                          ? new Date(role.end_date).getFullYear()
                          : "?"}
                      </p>
                    </div>
                  );
                })}
              </div>
            </section>
          )}
        </div>

        {/* Right Column */}
        <div className="col-span-2 space-y-8">
          {/* Contact & Links */}
          <section>
            <h2 className="diplomatic-label mb-3">Links</h2>
            <div className="space-y-2">
              {person.linkedin_url && (
                <a
                  href={person.linkedin_url}
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
              {person.twitter_url && (
                <a
                  href={person.twitter_url}
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
              {person.email && (
                <a
                  href={`mailto:${person.email}`}
                  className="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    mail
                  </span>
                  {person.email}
                </a>
              )}
            </div>
          </section>

          {/* Quick Facts */}
          <section className="bg-surface-container-low p-6">
            <h2 className="diplomatic-label mb-4">Quick Facts</h2>
            <div className="space-y-3 text-sm">
              {person.academic_lab && (
                <div>
                  <p className="text-xs text-on-surface-variant">
                    Academic Lab
                  </p>
                  <p className="text-on-surface">{person.academic_lab}</p>
                </div>
              )}
              {person.big_tech_employer && (
                <div>
                  <p className="text-xs text-on-surface-variant">
                    Big Tech Background
                  </p>
                  <p className="text-on-surface">{person.big_tech_employer}</p>
                </div>
              )}
              {person.previous_exits > 0 && (
                <div>
                  <p className="text-xs text-on-surface-variant">
                    Previous Exits
                  </p>
                  <p className="text-on-surface">{person.previous_exits}</p>
                </div>
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
