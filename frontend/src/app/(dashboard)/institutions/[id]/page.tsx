import Link from "next/link";
import { notFound } from "next/navigation";
import { queryMESR, DATASETS } from "@/lib/mesr";

interface InstitutionDetail {
  etablissement_id_paysage: string | null;
  uo_lib: string;
  nom_court: string | null;
  sigle: string | null;
  type_d_etablissement: string | null;
  typologie_d_universites_et_assimiles: string | null;
  secteur_d_etablissement: string | null;
  vague_contractuelle: string | null;
  url: string | null;
  coordonnees: { lat: number; lon: number } | null;
  uai: string | null;
  siren: string | null;
  siret: string | null;
  identifiant_ror: string | null;
  identifiant_wikidata: string | null;
  identifiant_idref: string | null;
  date_creation: string | null;
  texte_de_ref_creation_lib: string | null;
  com_nom: string | null;
  dep_nom: string | null;
  reg_nom: string | null;
  adresse_uai: string | null;
  code_postal_uai: string | null;
  numero_telephone_uai: string | null;
  statut_juridique_long: string | null;
  compte_linkedin: string | null;
  compte_twitter: string | null;
  compte_instagram: string | null;
  compte_facebook: string | null;
  compte_youtube: string | null;
  inscrits: number | null;
  mention_distribution: string | null;
}

export default async function InstitutionDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  // Try to find by UAI code first, then by SIREN
  let inst: InstitutionDetail | null = null;
  try {
    const byUai = await queryMESR<InstitutionDetail>(DATASETS.institutions, {
      where: `uai = "${id}"`,
      limit: 1,
    });
    if (byUai.results[0]) {
      inst = byUai.results[0];
    } else {
      const bySiren = await queryMESR<InstitutionDetail>(
        DATASETS.institutions,
        { where: `siren = "${id}"`, limit: 1 }
      );
      inst = bySiren.results[0] ?? null;
    }
  } catch {
    // fall through
  }

  if (!inst) notFound();

  // Try to find research labs linked to this institution
  let linkedLabs: { libelle: string; sigle: string | null; domaine_scientifique: string | null; type_de_structure: string | null }[] = [];
  try {
    if (inst.uo_lib) {
      const labRes = await queryMESR<typeof linkedLabs[0]>(
        DATASETS.researchStructures,
        {
          where: `search(tutelles, "${inst.nom_court ?? inst.uo_lib}")`,
          limit: 20,
        }
      );
      linkedLabs = labRes.results;
    }
  } catch {
    // Labs lookup is best-effort
  }

  const socialLinks = [
    { name: "Website", url: inst.url, icon: "language" },
    { name: "LinkedIn", url: inst.compte_linkedin, icon: "link" },
    { name: "Twitter / X", url: inst.compte_twitter, icon: "link" },
    { name: "Instagram", url: inst.compte_instagram, icon: "link" },
    { name: "Facebook", url: inst.compte_facebook, icon: "link" },
    { name: "YouTube", url: inst.compte_youtube, icon: "link" },
  ].filter((l) => l.url);

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <Link href="/institutions" className="hover:text-on-surface">
          Institutions
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">
          {inst.nom_court ?? inst.uo_lib}
        </span>
      </div>

      {/* Header */}
      <div className="mt-6 flex items-start justify-between">
        <div className="max-w-3xl">
          <p className="diplomatic-label">Institution Profile</p>
          <h1 className="mt-2 font-headline text-4xl font-semibold tracking-tight text-on-surface">
            {inst.nom_court ?? inst.uo_lib}
          </h1>
          {inst.sigle && (
            <p className="mt-1 text-sm text-on-surface-variant">
              {inst.sigle}
            </p>
          )}
          {inst.uo_lib !== inst.nom_court && inst.nom_court && (
            <p className="mt-1 font-headline text-base italic text-on-surface-variant">
              {inst.uo_lib}
            </p>
          )}
        </div>
        {inst.inscrits != null && inst.inscrits > 0 && (
          <div className="text-right">
            <p className="diplomatic-label">Enrolled Students</p>
            <p className="mt-1 font-headline text-4xl font-bold text-primary">
              {inst.inscrits.toLocaleString()}
            </p>
          </div>
        )}
      </div>

      {/* Vitality Bar */}
      <div className="mt-8 flex flex-wrap items-center gap-6 bg-surface-container-low px-6 py-4">
        {inst.type_d_etablissement && (
          <div>
            <span className="diplomatic-label">Type</span>
            <span className="ml-2 text-sm text-on-surface">
              {inst.type_d_etablissement}
            </span>
          </div>
        )}
        {inst.secteur_d_etablissement && (
          <div>
            <span className="diplomatic-label">Sector</span>
            <span className="ml-2 text-sm text-on-surface">
              {inst.secteur_d_etablissement}
            </span>
          </div>
        )}
        {inst.com_nom && (
          <div>
            <span className="diplomatic-label">City</span>
            <span className="ml-2 text-sm text-on-surface">
              {inst.com_nom}
            </span>
          </div>
        )}
        {inst.reg_nom && (
          <div>
            <span className="diplomatic-label">Region</span>
            <span className="ml-2 text-sm text-on-surface">
              {inst.reg_nom}
            </span>
          </div>
        )}
        {inst.date_creation && (
          <div>
            <span className="diplomatic-label">Founded</span>
            <span className="ml-2 text-sm text-on-surface">
              {new Date(inst.date_creation).toLocaleDateString("en-GB", {
                day: "numeric",
                month: "long",
                year: "numeric",
              })}
            </span>
          </div>
        )}
        {inst.vague_contractuelle && (
          <div>
            <span className="diplomatic-label">Contract Wave</span>
            <span className="ml-2 text-sm text-on-surface">
              {inst.vague_contractuelle}
            </span>
          </div>
        )}
      </div>

      {/* Main Content */}
      <div className="mt-10 grid grid-cols-5 gap-10">
        {/* Left Column */}
        <div className="col-span-3 space-y-10">
          {/* About */}
          {(inst.statut_juridique_long || inst.texte_de_ref_creation_lib || inst.typologie_d_universites_et_assimiles) && (
            <section>
              <h2 className="diplomatic-label mb-4">About</h2>
              <div className="space-y-3">
                {inst.statut_juridique_long && (
                  <div>
                    <p className="text-xs text-on-surface-variant">Legal Status</p>
                    <p className="text-sm text-on-surface">{inst.statut_juridique_long}</p>
                  </div>
                )}
                {inst.typologie_d_universites_et_assimiles && (
                  <div>
                    <p className="text-xs text-on-surface-variant">University Type</p>
                    <p className="text-sm text-on-surface">{inst.typologie_d_universites_et_assimiles}</p>
                  </div>
                )}
                {inst.texte_de_ref_creation_lib && (
                  <div>
                    <p className="text-xs text-on-surface-variant">Founding Decree</p>
                    <p className="text-sm text-on-surface">{inst.texte_de_ref_creation_lib}</p>
                  </div>
                )}
              </div>
            </section>
          )}

          {/* Location */}
          <section>
            <h2 className="diplomatic-label mb-4">Location</h2>
            <div className="space-y-2">
              {inst.adresse_uai && (
                <p className="text-sm text-on-surface">{inst.adresse_uai}</p>
              )}
              <p className="text-sm text-on-surface">
                {[inst.code_postal_uai, inst.com_nom].filter(Boolean).join(" ")}
              </p>
              {inst.numero_telephone_uai && (
                <p className="text-sm text-on-surface-variant">
                  Tel: {inst.numero_telephone_uai}
                </p>
              )}
              {inst.coordonnees && (
                <p className="text-xs text-outline">
                  {inst.coordonnees.lat.toFixed(4)}°N,{" "}
                  {inst.coordonnees.lon.toFixed(4)}°E
                </p>
              )}
            </div>
          </section>

          {/* Linked Research Labs */}
          {linkedLabs.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-4">
                Linked Research Structures ({linkedLabs.length})
              </h2>
              <div className="space-y-2">
                {linkedLabs.map((lab, i) => (
                  <div
                    key={i}
                    className="flex items-center justify-between bg-surface-container-lowest p-4"
                  >
                    <div>
                      <p className="text-sm font-medium text-on-surface">
                        {lab.libelle}
                      </p>
                      {lab.sigle && (
                        <span className="text-xs text-on-surface-variant">
                          {lab.sigle}
                        </span>
                      )}
                    </div>
                    <div className="flex items-center gap-4 text-xs text-on-surface-variant">
                      {lab.type_de_structure && <span>{lab.type_de_structure}</span>}
                      {lab.domaine_scientifique && (
                        <span className="bg-primary/10 px-1.5 py-0.5 text-primary">
                          {lab.domaine_scientifique}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}
        </div>

        {/* Right Column */}
        <div className="col-span-2 space-y-8">
          {/* Identifiers */}
          <section className="bg-surface-container-low p-6">
            <h2 className="diplomatic-label mb-4">Identifiers</h2>
            <div className="space-y-2 text-sm">
              {inst.uai && (
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">UAI</span>
                  <span className="font-mono text-on-surface">{inst.uai}</span>
                </div>
              )}
              {inst.siren && (
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">SIREN</span>
                  <span className="font-mono text-on-surface">{inst.siren}</span>
                </div>
              )}
              {inst.siret && (
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">SIRET</span>
                  <span className="font-mono text-on-surface">{inst.siret}</span>
                </div>
              )}
              {inst.identifiant_ror && (
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">ROR</span>
                  <span className="font-mono text-on-surface">{inst.identifiant_ror}</span>
                </div>
              )}
              {inst.identifiant_wikidata && (
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">Wikidata</span>
                  <a
                    href={`https://www.wikidata.org/wiki/${inst.identifiant_wikidata}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline"
                  >
                    {inst.identifiant_wikidata}
                  </a>
                </div>
              )}
            </div>
          </section>

          {/* Links */}
          {socialLinks.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-3">Links</h2>
              <div className="space-y-2">
                {socialLinks.map((link) => (
                  <a
                    key={link.name}
                    href={link.url!}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm text-primary hover:underline"
                  >
                    <span className="material-symbols-outlined text-[16px]">
                      {link.icon}
                    </span>
                    {link.name}
                  </a>
                ))}
                {inst.siren && (
                  <a
                    href={`https://scanr.enseignementsup-recherche.gouv.fr/entite/${inst.siren}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm text-primary hover:underline"
                  >
                    <span className="material-symbols-outlined text-[16px]">
                      open_in_new
                    </span>
                    View on scanR
                  </a>
                )}
              </div>
            </section>
          )}

          {/* Cross-reference to Navigator entities */}
          {inst.siren && (
            <section className="bg-surface-container-lowest p-6 ambient-shadow">
              <h2 className="diplomatic-label mb-3">Navigator Cross-Reference</h2>
              <p className="text-xs text-on-surface-variant">
                SIREN {inst.siren} can be matched against organizations
                in the Navigator database for funding lineage and network mapping.
              </p>
              <Link
                href={`/entities?search=${encodeURIComponent(inst.nom_court ?? inst.uo_lib)}`}
                className="mt-3 inline-block text-sm font-medium text-primary hover:underline"
              >
                Search in Entity Explorer →
              </Link>
            </section>
          )}
        </div>
      </div>
    </div>
  );
}
