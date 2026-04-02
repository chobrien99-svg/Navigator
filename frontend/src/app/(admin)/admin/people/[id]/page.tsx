"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

interface PersonForm {
  full_name: string;
  slug: string;
  first_name: string;
  last_name: string;
  linkedin_url: string;
  twitter_url: string;
  email: string;
  bio: string;
  has_phd: boolean;
  is_repeat_founder: boolean;
  has_big_tech_background: boolean;
  big_tech_employer: string;
  academic_lab: string;
  previous_exits: string;
}

export default function EditPersonPage() {
  const { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [form, setForm] = useState<PersonForm>({
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

  useEffect(() => {
    async function load() {
      const { data, error: err } = await supabase
        .from("people")
        .select("*")
        .eq("id", id)
        .single();

      if (err || !data) {
        setError("Person not found");
        setLoading(false);
        return;
      }

      setForm({
        full_name: data.full_name ?? "",
        slug: data.slug ?? "",
        first_name: data.first_name ?? "",
        last_name: data.last_name ?? "",
        linkedin_url: data.linkedin_url ?? "",
        twitter_url: data.twitter_url ?? "",
        email: data.email ?? "",
        bio: data.bio ?? "",
        has_phd: data.has_phd ?? false,
        is_repeat_founder: data.is_repeat_founder ?? false,
        has_big_tech_background: data.has_big_tech_background ?? false,
        big_tech_employer: data.big_tech_employer ?? "",
        academic_lab: data.academic_lab ?? "",
        previous_exits: (data.previous_exits ?? 0).toString(),
      });
      setLoading(false);
    }
    load();
  }, [id]);

  function updateField(field: keyof PersonForm, value: string | boolean) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSave() {
    setSaving(true);
    setError(null);
    setSuccess(false);

    try {
      const { error: err } = await supabase
        .from("people")
        .update({
          full_name: form.full_name,
          slug: form.slug,
          first_name: form.first_name || null,
          last_name: form.last_name || null,
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
        .eq("id", id);

      if (err) throw err;
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <p className="font-headline italic text-on-surface-variant">
          Loading...
        </p>
      </div>
    );
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
        <span className="text-on-surface">{form.full_name}</span>
      </div>

      <div className="mt-6 flex items-start justify-between">
        <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
          Edit: {form.full_name}
        </h1>
        <div className="flex items-center gap-3">
          <Link
            href={`/people/${form.slug}`}
            className="px-4 py-2 text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            View Public Page
          </Link>
          <button
            onClick={handleSave}
            disabled={saving}
            className="institutional-gradient px-6 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-4 bg-error-container px-4 py-2.5 text-sm text-on-error-container">
          {error}
        </div>
      )}
      {success && (
        <div className="mt-4 bg-secondary-container px-4 py-2.5 text-sm text-on-secondary-container">
          Changes saved successfully.
        </div>
      )}

      <div className="mt-8 grid grid-cols-2 gap-10">
        {/* Left: Identity */}
        <div className="space-y-6">
          <h2 className="diplomatic-label">Identity</h2>

          <Field
            label="Full Name"
            value={form.full_name}
            onChange={(v) => updateField("full_name", v)}
          />
          <Field
            label="Slug"
            value={form.slug}
            onChange={(v) => updateField("slug", v)}
          />
          <div className="grid grid-cols-2 gap-4">
            <Field
              label="First Name"
              value={form.first_name}
              onChange={(v) => updateField("first_name", v)}
            />
            <Field
              label="Last Name"
              value={form.last_name}
              onChange={(v) => updateField("last_name", v)}
            />
          </div>

          <TextArea
            label="Bio"
            value={form.bio}
            onChange={(v) => updateField("bio", v)}
          />

          <h2 className="diplomatic-label pt-4">Links</h2>
          <Field
            label="LinkedIn URL"
            value={form.linkedin_url}
            onChange={(v) => updateField("linkedin_url", v)}
          />
          <Field
            label="Twitter URL"
            value={form.twitter_url}
            onChange={(v) => updateField("twitter_url", v)}
          />
          <Field
            label="Email"
            value={form.email}
            onChange={(v) => updateField("email", v)}
          />
        </div>

        {/* Right: Background */}
        <div className="space-y-6">
          <h2 className="diplomatic-label">Background & Attributes</h2>

          <Checkbox
            label="Has PhD"
            checked={form.has_phd}
            onChange={(v) => updateField("has_phd", v)}
          />
          <Checkbox
            label="Repeat Founder"
            checked={form.is_repeat_founder}
            onChange={(v) => updateField("is_repeat_founder", v)}
          />
          <Checkbox
            label="Big Tech Background"
            checked={form.has_big_tech_background}
            onChange={(v) => updateField("has_big_tech_background", v)}
          />

          <Field
            label="Big Tech Employer"
            value={form.big_tech_employer}
            onChange={(v) => updateField("big_tech_employer", v)}
            placeholder="e.g. Google, Meta"
          />
          <Field
            label="Academic Lab"
            value={form.academic_lab}
            onChange={(v) => updateField("academic_lab", v)}
            placeholder="e.g. Inria, CNRS"
          />
          <Field
            label="Previous Exits"
            value={form.previous_exits}
            onChange={(v) => updateField("previous_exits", v)}
            type="number"
          />
        </div>
      </div>
    </div>
  );
}

// ─── Form components ──────────────────────────────────────

function Field({
  label,
  value,
  onChange,
  type = "text",
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
  placeholder?: string;
}) {
  return (
    <div>
      <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
        {label}
      </label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
      />
    </div>
  );
}

function TextArea({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
        {label}
      </label>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={4}
        className="w-full border border-outline-variant/15 bg-surface-container-lowest p-3 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
      />
    </div>
  );
}

function Checkbox({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <label className="flex cursor-pointer items-center gap-3">
      <input
        type="checkbox"
        checked={checked}
        onChange={(e) => onChange(e.target.checked)}
        className="h-4 w-4 border-outline-variant accent-primary"
      />
      <span className="text-sm text-on-surface">{label}</span>
    </label>
  );
}
