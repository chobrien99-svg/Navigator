import Link from "next/link";
import { getPeople } from "@/lib/queries";
import type { Person } from "@/lib/types";

export default async function PeoplePage() {
  let people: Person[] = [];
  let error: string | null = null;

  try {
    people = await getPeople();
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load people";
  }

  return (
    <div className="px-10 py-8">
      <div>
        <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
          People
        </h1>
        <p className="mt-1 text-sm text-on-surface-variant">
          {people.length} individuals in the intelligence network
        </p>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      <div className="mt-8 space-y-3">
        {people.map((person) => (
          <Link
            key={person.id}
            href={`/people/${person.slug}`}
            className="group flex items-center gap-5 bg-surface-container-lowest p-5 transition-colors duration-200 hover:bg-surface-container-low"
          >
            {/* Avatar */}
            <div className="flex h-12 w-12 shrink-0 items-center justify-center bg-primary-fixed text-base font-semibold text-on-primary-fixed">
              {person.full_name
                .split(" ")
                .map((n) => n[0])
                .join("")
                .slice(0, 2)}
            </div>

            {/* Identity */}
            <div className="flex-1 min-w-0">
              <h2 className="font-headline text-lg font-semibold text-on-surface group-hover:text-primary">
                {person.full_name}
              </h2>
              {person.bio && (
                <p className="mt-1 max-w-2xl truncate text-sm text-on-surface-variant">
                  {person.bio}
                </p>
              )}
              <div className="mt-2 flex items-center gap-3 text-xs text-on-surface-variant">
                {person.has_phd && (
                  <span className="bg-research/15 px-1.5 py-0.5 text-research">
                    PhD
                  </span>
                )}
                {person.is_repeat_founder && (
                  <span className="bg-secondary/10 px-1.5 py-0.5 text-secondary">
                    Repeat Founder
                  </span>
                )}
                {person.has_big_tech_background && (
                  <span className="bg-primary/10 px-1.5 py-0.5 text-primary">
                    Ex-{person.big_tech_employer ?? "Big Tech"}
                  </span>
                )}
                {person.previous_exits > 0 && (
                  <span className="bg-tertiary/10 px-1.5 py-0.5 text-tertiary">
                    {person.previous_exits} exit
                    {person.previous_exits !== 1 ? "s" : ""}
                  </span>
                )}
              </div>
            </div>
          </Link>
        ))}

        {people.length === 0 && !error && (
          <div className="py-20 text-center">
            <p className="font-headline text-lg italic text-on-surface-variant">
              No people found in the database yet.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
