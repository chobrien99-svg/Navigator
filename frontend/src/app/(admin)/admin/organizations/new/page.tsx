"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

const ORG_TYPES = [
  "startup",
  "corporate",
  "investor",
  "accelerator",
  "incubator",
  "university",
  "research_lab",
  "public_agency",
  "nonprofit",
  "media",
  "other",
];

const STATUSES = [
  "active",
  "inactive",
  "acquired",
  "closed",
  "ipo",
  "stealth",
  "unknown",
];

function slugify(name: string): string {
  return name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export default function NewOrganizationPage() {
  const router = useRouter();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    name: "",
    slug: "",
    organization_type: "startup",
    status: "active",
    short_description: "",
    description: "",
    country: "France",
    website: "",
    linkedin_url: "",
    twitter_url: "",
    email: "",
    siren: "",
  });
  const [slugManuallyEdited, setSlugManuallyEdited] = useState(false);

  function updateField<K extends keyof typeof form>(
    key: K,
    value: (typeof form)[K]
  ) {
    setForm((f) => {
      const next = { ...f, [key]: value };
      // Auto-slug from name unless user has manually touched slug
      if (key === "name" && !slugManuallyEdited) {
        next.slug = slugify(value as string);
      }
      return next;
    });
  }

  async function handleCreate() {
    if (!form.name.trim()) {
      setError("Name is required.");
      return;
    }
    const slug = form.slug.trim() || slugify(form.name);
    if (!slug) {
      setError("Could not derive a valid slug from the name.");
      return;
    }

    setSaving(true);
    setError(null);

    try {
      const { data: inserted, error: insErr } = await supabase
        .from("organizations")
        .insert({
          name: form.name.trim(),
          slug,
          organization_type: form.organization_type,
          status: form.status,
          short_description: form.short_description || null,
          description: form.description || null,
          country: form.country || "France",
          website: form.website || null,
          linkedin_url: form.linkedin_url || null,
          twitter_url: form.twitter_url || null,
          email: form.email || null,
          legacy_source: "admin_manual",
        })
        .select("id")
        .single();

      if (insErr) throw insErr;

      // If SIREN was provided, create a legal_entities row
      if (form.siren.trim() && inserted) {
        const siren = form.siren.trim();
        await supabase.from("legal_entities").insert({
          organization_id: inserted.id,
          legal_name: form.name.trim(),
          siren,
          country: "France",
          is_primary: true,
        });
      }

      if (inserted) {
        router.push(`/admin/organizations/${inserted.id}`);
      }
    } catch (e) {
      setError(
        e instanceof Error ? e.message : "Failed to create organization"
      );
      setSaving(false);
    }
  }

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <Link href="/admin" className="hover:text-on-surface">
          Admin
        </Link>
        <span className="mx-2">›</span>
        <Link href="/admin/organizations" className="hover:text-on-surface">
          Organizations
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">New</span>
      </div>

      <div className="mt-6 flex items-start justify-between">
        <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
          New Organization
        </h1>
        <div className="flex items-center gap-3">
          <Link
            href="/admin/organizations"
            className="px-4 py-2 text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            Cancel
          </Link>
          <button
            onClick={handleCreate}
            disabled={saving || !form.name.trim()}
            className="institutional-gradient px-6 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {saving ? "Creating..." : "Create Organization"}
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-4 bg-error-container px-4 py-2.5 text-sm text-on-error-container">
          {error}
        </div>
      )}

      <div className="mt-8 max-w-2xl space-y-6">
        <h2 className="diplomatic-label">Core Information</h2>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Name <span className="text-error">*</span>
          </label>
          <input
            type="text"
            value={form.name}
            onChange={(e) => updateField("name", e.target.value)}
            placeholder="e.g. Mistral AI"
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            autoFocus
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Slug{" "}
            <span className="text-outline-variant font-normal">
              (auto-derived from name)
            </span>
          </label>
          <input
            type="text"
            value={form.slug}
            onChange={(e) => {
              setSlugManuallyEdited(true);
              updateField("slug", e.target.value);
            }}
            placeholder="e.g. mistral-ai"
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Type
            </label>
            <select
              value={form.organization_type}
              onChange={(e) => updateField("organization_type", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
            >
              {ORG_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t.replace(/_/g, " ")}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Status
            </label>
            <select
              value={form.status}
              onChange={(e) => updateField("status", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Short Description
          </label>
          <input
            type="text"
            value={form.short_description}
            onChange={(e) => updateField("short_description", e.target.value)}
            placeholder="One-line summary"
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Full Description
          </label>
          <textarea
            value={form.description}
            onChange={(e) => updateField("description", e.target.value)}
            rows={3}
            className="w-full border border-outline-variant/15 bg-surface-container-lowest p-3 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Country
            </label>
            <input
              type="text"
              value={form.country}
              onChange={(e) => updateField("country", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              SIREN{" "}
              <span className="text-outline-variant font-normal">
                (optional)
              </span>
            </label>
            <input
              type="text"
              value={form.siren}
              onChange={(e) => updateField("siren", e.target.value)}
              placeholder="e.g. 952418325"
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
        </div>

        <h2 className="diplomatic-label pt-4">Links</h2>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Website
          </label>
          <input
            type="text"
            value={form.website}
            onChange={(e) => updateField("website", e.target.value)}
            placeholder="https://..."
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            LinkedIn URL
          </label>
          <input
            type="text"
            value={form.linkedin_url}
            onChange={(e) => updateField("linkedin_url", e.target.value)}
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Twitter URL
          </label>
          <input
            type="text"
            value={form.twitter_url}
            onChange={(e) => updateField("twitter_url", e.target.value)}
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Email
          </label>
          <input
            type="email"
            value={form.email}
            onChange={(e) => updateField("email", e.target.value)}
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <p className="text-xs italic text-on-surface-variant">
          After creating, you&apos;ll land on the edit page where you can add
          the intelligence profile, sectors, funding rounds, and more.
        </p>
      </div>
    </div>
  );
}
