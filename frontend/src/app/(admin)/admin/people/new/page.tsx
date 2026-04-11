"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

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

export default function NewPersonPage() {
  const router = useRouter();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    full_name: "",
    slug: "",
    first_name: "",
    last_name: "",
    linkedin_url: "",
    twitter_url: "",
    email: "",
    bio: "",
    has_phd: false,
    is_repeat_founder: false,
    has_big_tech_background: false,
    big_tech_employer: "",
    academic_lab: "",
    previous_exits: "0",
  });
  const [slugManuallyEdited, setSlugManuallyEdited] = useState(false);

  function updateField<K extends keyof typeof form>(
    key: K,
    value: (typeof form)[K]
  ) {
    setForm((f) => {
      const next = { ...f, [key]: value };
      // Auto-slug from full_name unless user has manually touched slug
      if (key === "full_name" && !slugManuallyEdited) {
        next.slug = slugify(value as string);
      }
      // Also auto-derive first/last if empty
      if (key === "full_name" && !f.first_name && !f.last_name) {
        const parts = (value as string).trim().split(/\s+/);
        if (parts.length >= 2) {
          next.first_name = parts[0];
          next.last_name = parts.slice(1).join(" ");
        } else if (parts.length === 1 && parts[0]) {
          next.last_name = parts[0];
        }
      }
      return next;
    });
  }

  async function handleCreate() {
    if (!form.full_name.trim()) {
      setError("Full name is required.");
      return;
    }
    const slug = form.slug.trim() || slugify(form.full_name);
    if (!slug) {
      setError("Could not derive a valid slug from the full name.");
      return;
    }

    setSaving(true);
    setError(null);

    try {
      const { data: inserted, error: insErr } = await supabase
        .from("people")
        .insert({
          full_name: form.full_name.trim(),
          slug,
          first_name: form.first_name.trim() || null,
          last_name: form.last_name.trim() || null,
          linkedin_url: form.linkedin_url || null,
          twitter_url: form.twitter_url || null,
          email: form.email || null,
          bio: form.bio || null,
          has_phd: form.has_phd,
          is_repeat_founder: form.is_repeat_founder,
          has_big_tech_background: form.has_big_tech_background,
          big_tech_employer: form.big_tech_employer || null,
          academic_lab: form.academic_lab || null,
          previous_exits: parseInt(form.previous_exits) || 0,
        })
        .select("id")
        .single();

      if (insErr) throw insErr;

      if (inserted) {
        router.push(`/admin/people/${inserted.id}`);
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to create person");
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
        <Link href="/admin/people" className="hover:text-on-surface">
          People
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">New</span>
      </div>

      <div className="mt-6 flex items-start justify-between">
        <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
          New Person
        </h1>
        <div className="flex items-center gap-3">
          <Link
            href="/admin/people"
            className="px-4 py-2 text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            Cancel
          </Link>
          <button
            onClick={handleCreate}
            disabled={saving || !form.full_name.trim()}
            className="institutional-gradient px-6 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {saving ? "Creating..." : "Create Person"}
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-4 bg-error-container px-4 py-2.5 text-sm text-on-error-container">
          {error}
        </div>
      )}

      <div className="mt-8 max-w-2xl space-y-6">
        <h2 className="diplomatic-label">Identity</h2>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Full Name <span className="text-error">*</span>
          </label>
          <input
            type="text"
            value={form.full_name}
            onChange={(e) => updateField("full_name", e.target.value)}
            placeholder="e.g. Arthur Mensch"
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            autoFocus
          />
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Slug{" "}
            <span className="text-outline-variant font-normal">
              (auto-derived)
            </span>
          </label>
          <input
            type="text"
            value={form.slug}
            onChange={(e) => {
              setSlugManuallyEdited(true);
              updateField("slug", e.target.value);
            }}
            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              First Name
            </label>
            <input
              type="text"
              value={form.first_name}
              onChange={(e) => updateField("first_name", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Last Name
            </label>
            <input
              type="text"
              value={form.last_name}
              onChange={(e) => updateField("last_name", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Bio
          </label>
          <textarea
            value={form.bio}
            onChange={(e) => updateField("bio", e.target.value)}
            rows={3}
            className="w-full border border-outline-variant/15 bg-surface-container-lowest p-3 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        <h2 className="diplomatic-label pt-4">Links</h2>

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

        <h2 className="diplomatic-label pt-4">Background</h2>

        <div className="space-y-3">
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={form.has_phd}
              onChange={(e) => updateField("has_phd", e.target.checked)}
              className="accent-primary"
            />
            <span className="text-sm text-on-surface">Has PhD</span>
          </label>
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={form.is_repeat_founder}
              onChange={(e) =>
                updateField("is_repeat_founder", e.target.checked)
              }
              className="accent-primary"
            />
            <span className="text-sm text-on-surface">Repeat founder</span>
          </label>
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={form.has_big_tech_background}
              onChange={(e) =>
                updateField("has_big_tech_background", e.target.checked)
              }
              className="accent-primary"
            />
            <span className="text-sm text-on-surface">
              Big Tech background
            </span>
          </label>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Big Tech Employer
            </label>
            <input
              type="text"
              value={form.big_tech_employer}
              onChange={(e) => updateField("big_tech_employer", e.target.value)}
              placeholder="e.g. Google, Meta"
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
          <div>
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Academic Lab
            </label>
            <input
              type="text"
              value={form.academic_lab}
              onChange={(e) => updateField("academic_lab", e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
            />
          </div>
        </div>

        <div>
          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
            Previous Exits
          </label>
          <input
            type="number"
            value={form.previous_exits}
            onChange={(e) => updateField("previous_exits", e.target.value)}
            min="0"
            className="w-32 border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
          />
        </div>

        <p className="text-xs italic text-on-surface-variant">
          After creating, you&apos;ll land on the edit page where you can
          refine details and link the person to organizations.
        </p>
      </div>
    </div>
  );
}
