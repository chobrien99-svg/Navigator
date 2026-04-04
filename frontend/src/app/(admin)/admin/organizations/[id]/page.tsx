"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

interface OrgForm {
  name: string;
  slug: string;
  organization_type: string;
  status: string;
  description: string;
  short_description: string;
  website: string;
  linkedin_url: string;
  twitter_url: string;
  email: string;
  country: string;
  employee_range: string;
  founded_year: string;
  total_raised_eur: string;
  last_round: string;
  fundraising_status: string;
  technology_layer: string;
}

const orgTypes = [
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

const statusOptions = [
  "active",
  "inactive",
  "acquired",
  "closed",
  "ipo",
  "stealth",
  "unknown",
];

const fundraisingOptions = [
  "unknown",
  "not_raising",
  "exploring",
  "actively_raising",
  "closing",
  "recently_closed",
];

const techLayers = [
  "",
  "infrastructure",
  "model",
  "application",
  "tooling",
  "data",
  "other",
];

// ─── Profile form fields ─────────────────────────────────

interface ProfileForm {
  what_they_are_building: string;
  why_it_matters: string;
  investor_brief: string;
  analyst_note: string;
  product_description: string;
  target_market: string;
  competitive_landscape: string;
  current_strategy: string;
  business_model_hypothesis: string;
  technical_thesis: string;
}

interface FundingRoundRow {
  id: string;
  stage: string;
  amount_eur: number | null;
  currency_original: string | null;
  amount_original: number | null;
  announced_date: string | null;
  source_name: string | null;
  notes: string | null;
  funding_round_investors?: { investor_name: string | null; is_lead: boolean }[];
}

const stageOptions = [
  "pre_seed",
  "seed",
  "series_a",
  "series_b",
  "series_c",
  "series_d",
  "series_e",
  "series_f",
  "growth",
  "bridge",
  "debt",
  "grant",
  "ipo",
  "secondary",
  "undisclosed",
  "other",
];

const AMOUNT_MULTIPLIER = 1_000_000;

function formatEurDisplay(amountInMillions: number | null): string {
  if (amountInMillions == null) return "—";
  const raw = amountInMillions * AMOUNT_MULTIPLIER;
  if (raw >= 1_000_000_000) return `€${(raw / 1_000_000_000).toFixed(1)}B`;
  if (raw >= 1_000_000) return `€${(raw / 1_000_000).toFixed(1)}M`;
  if (raw >= 1_000) return `€${(raw / 1_000).toFixed(0)}K`;
  return `€${raw.toLocaleString()}`;
}

const emptyProfile: ProfileForm = {
  what_they_are_building: "",
  why_it_matters: "",
  investor_brief: "",
  analyst_note: "",
  product_description: "",
  target_market: "",
  competitive_landscape: "",
  current_strategy: "",
  business_model_hypothesis: "",
  technical_thesis: "",
};

export default function EditOrganizationPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [form, setForm] = useState<OrgForm>({
    name: "",
    slug: "",
    organization_type: "startup",
    status: "active",
    description: "",
    short_description: "",
    website: "",
    linkedin_url: "",
    twitter_url: "",
    email: "",
    country: "France",
    employee_range: "",
    founded_year: "",
    total_raised_eur: "",
    last_round: "",
    fundraising_status: "unknown",
    technology_layer: "",
  });
  const [profile, setProfile] = useState<ProfileForm>(emptyProfile);
  const [hasProfile, setHasProfile] = useState(false);
  const [fundingRounds, setFundingRounds] = useState<FundingRoundRow[]>([]);
  const [showAddRound, setShowAddRound] = useState(false);
  const [newRound, setNewRound] = useState({
    stage: "seed",
    amount_eur: "",
    announced_date: "",
    notes: "",
  });
  const [addingRound, setAddingRound] = useState(false);

  useEffect(() => {
    async function load() {
      const { data: org, error: orgErr } = await supabase
        .from("organizations")
        .select("*")
        .eq("id", id)
        .single();

      if (orgErr || !org) {
        setError("Organization not found");
        setLoading(false);
        return;
      }

      setForm({
        name: org.name ?? "",
        slug: org.slug ?? "",
        organization_type: org.organization_type ?? "startup",
        status: org.status ?? "active",
        description: org.description ?? "",
        short_description: org.short_description ?? "",
        website: org.website ?? "",
        linkedin_url: org.linkedin_url ?? "",
        twitter_url: org.twitter_url ?? "",
        email: org.email ?? "",
        country: org.country ?? "France",
        employee_range: org.employee_range ?? "",
        founded_year: org.founded_year?.toString() ?? "",
        total_raised_eur: org.total_raised_eur?.toString() ?? "",
        last_round: org.last_round ?? "",
        fundraising_status: org.fundraising_status ?? "unknown",
        technology_layer: org.technology_layer ?? "",
      });

      // Load profile
      const { data: profileData } = await supabase
        .from("organization_profiles")
        .select("*")
        .eq("organization_id", id)
        .single();

      if (profileData) {
        setHasProfile(true);
        setProfile({
          what_they_are_building:
            profileData.what_they_are_building ?? "",
          why_it_matters: profileData.why_it_matters ?? "",
          investor_brief: profileData.investor_brief ?? "",
          analyst_note: profileData.analyst_note ?? "",
          product_description: profileData.product_description ?? "",
          target_market: profileData.target_market ?? "",
          competitive_landscape:
            profileData.competitive_landscape ?? "",
          current_strategy: profileData.current_strategy ?? "",
          business_model_hypothesis:
            profileData.business_model_hypothesis ?? "",
          technical_thesis: profileData.technical_thesis ?? "",
        });
      }

      // Load funding rounds
      const { data: roundsData } = await supabase
        .from("funding_rounds")
        .select("*, funding_round_investors(investor_name, is_lead)")
        .eq("organization_id", id)
        .order("announced_date", { ascending: false });

      if (roundsData) {
        setFundingRounds(roundsData as FundingRoundRow[]);
      }

      setLoading(false);
    }
    load();
  }, [id]);

  function updateField(field: keyof OrgForm, value: string) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  function updateProfile(field: keyof ProfileForm, value: string) {
    setProfile((p) => ({ ...p, [field]: value }));
  }

  async function handleSave() {
    setSaving(true);
    setError(null);
    setSuccess(false);

    try {
      const { error: orgErr } = await supabase
        .from("organizations")
        .update({
          name: form.name,
          slug: form.slug,
          organization_type: form.organization_type,
          status: form.status,
          description: form.description || null,
          short_description: form.short_description || null,
          website: form.website || null,
          linkedin_url: form.linkedin_url || null,
          twitter_url: form.twitter_url || null,
          email: form.email || null,
          country: form.country,
          employee_range: form.employee_range || null,
          founded_year: form.founded_year
            ? parseInt(form.founded_year)
            : null,
          total_raised_eur: form.total_raised_eur
            ? parseFloat(form.total_raised_eur)
            : null,
          last_round: form.last_round || null,
          fundraising_status: form.fundraising_status || "unknown",
          technology_layer: form.technology_layer || null,
        })
        .eq("id", id);

      if (orgErr) throw orgErr;

      // Upsert profile
      const profileData = {
        organization_id: id,
        ...Object.fromEntries(
          Object.entries(profile).map(([k, v]) => [k, v || null])
        ),
      };

      if (hasProfile) {
        const { error: profErr } = await supabase
          .from("organization_profiles")
          .update(profileData)
          .eq("organization_id", id);
        if (profErr) throw profErr;
      } else {
        const { error: profErr } = await supabase
          .from("organization_profiles")
          .insert(profileData);
        if (profErr && profErr.code !== "23505") throw profErr;
        setHasProfile(true);
      }

      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  }

  async function handleAddRound() {
    setAddingRound(true);
    setError(null);
    try {
      const amountEur = newRound.amount_eur
        ? parseFloat(newRound.amount_eur) / AMOUNT_MULTIPLIER
        : null;

      const { data: inserted, error: insertErr } = await supabase
        .from("funding_rounds")
        .insert({
          organization_id: id,
          stage: newRound.stage,
          amount_eur: amountEur,
          announced_date: newRound.announced_date || null,
          notes: newRound.notes || null,
          is_estimated: false,
          is_verified: false,
          source_name: "admin_manual",
        })
        .select("*, funding_round_investors(investor_name, is_lead)")
        .single();

      if (insertErr) throw insertErr;
      if (inserted) {
        setFundingRounds((prev) => [inserted as FundingRoundRow, ...prev]);
      }
      setShowAddRound(false);
      setNewRound({ stage: "seed", amount_eur: "", announced_date: "", notes: "" });
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to add funding round");
    } finally {
      setAddingRound(false);
    }
  }

  async function handleDeleteRound(roundId: string) {
    const { error: delErr } = await supabase
      .from("funding_rounds")
      .delete()
      .eq("id", roundId);

    if (delErr) {
      setError(delErr.message);
    } else {
      setFundingRounds((prev) => prev.filter((r) => r.id !== roundId));
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
        <Link href="/admin/organizations" className="hover:text-on-surface">
          Organizations
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">{form.name}</span>
      </div>

      <div className="mt-6 flex items-start justify-between">
        <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
          Edit: {form.name}
        </h1>
        <div className="flex items-center gap-3">
          <Link
            href={`/entities/${form.slug}`}
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
        {/* Left: Core Fields */}
        <div className="space-y-6">
          <h2 className="diplomatic-label">Core Information</h2>

          <Field label="Name" value={form.name} onChange={(v) => updateField("name", v)} />
          <Field label="Slug" value={form.slug} onChange={(v) => updateField("slug", v)} />

          <div className="grid grid-cols-2 gap-4">
            <SelectField
              label="Type"
              value={form.organization_type}
              options={orgTypes}
              onChange={(v) => updateField("organization_type", v)}
            />
            <SelectField
              label="Status"
              value={form.status}
              options={statusOptions}
              onChange={(v) => updateField("status", v)}
            />
          </div>

          <Field label="Short Description" value={form.short_description} onChange={(v) => updateField("short_description", v)} />
          <TextArea label="Full Description" value={form.description} onChange={(v) => updateField("description", v)} />

          <div className="grid grid-cols-2 gap-4">
            <Field label="Country" value={form.country} onChange={(v) => updateField("country", v)} />
            <Field label="Employee Range" value={form.employee_range} onChange={(v) => updateField("employee_range", v)} placeholder="e.g. 11-50" />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Founded Year" value={form.founded_year} onChange={(v) => updateField("founded_year", v)} type="number" />
            <Field label="Total Raised (EUR)" value={form.total_raised_eur} onChange={(v) => updateField("total_raised_eur", v)} type="number" />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Last Round" value={form.last_round} onChange={(v) => updateField("last_round", v)} placeholder="e.g. series_a" />
            <SelectField
              label="Fundraising Status"
              value={form.fundraising_status}
              options={fundraisingOptions}
              onChange={(v) => updateField("fundraising_status", v)}
            />
          </div>

          <SelectField
            label="Technology Layer"
            value={form.technology_layer}
            options={techLayers}
            onChange={(v) => updateField("technology_layer", v)}
          />

          <h2 className="diplomatic-label pt-4">Links</h2>
          <Field label="Website" value={form.website} onChange={(v) => updateField("website", v)} placeholder="https://..." />
          <Field label="LinkedIn URL" value={form.linkedin_url} onChange={(v) => updateField("linkedin_url", v)} />
          <Field label="Twitter URL" value={form.twitter_url} onChange={(v) => updateField("twitter_url", v)} />
          <Field label="Email" value={form.email} onChange={(v) => updateField("email", v)} />
        </div>

        {/* Right: Profile / Intelligence */}
        <div className="space-y-6">
          <h2 className="diplomatic-label">Intelligence Profile</h2>

          <TextArea label="What They're Building" value={profile.what_they_are_building} onChange={(v) => updateProfile("what_they_are_building", v)} />
          <TextArea label="Why It Matters" value={profile.why_it_matters} onChange={(v) => updateProfile("why_it_matters", v)} />
          <TextArea label="Investor Brief" value={profile.investor_brief} onChange={(v) => updateProfile("investor_brief", v)} />
          <TextArea label="Analyst Note" value={profile.analyst_note} onChange={(v) => updateProfile("analyst_note", v)} />
          <TextArea label="Product Description" value={profile.product_description} onChange={(v) => updateProfile("product_description", v)} />
          <TextArea label="Target Market" value={profile.target_market} onChange={(v) => updateProfile("target_market", v)} />
          <TextArea label="Competitive Landscape" value={profile.competitive_landscape} onChange={(v) => updateProfile("competitive_landscape", v)} />
          <TextArea label="Current Strategy" value={profile.current_strategy} onChange={(v) => updateProfile("current_strategy", v)} />
          <TextArea label="Business Model Hypothesis" value={profile.business_model_hypothesis} onChange={(v) => updateProfile("business_model_hypothesis", v)} />
          <TextArea label="Technical Thesis" value={profile.technical_thesis} onChange={(v) => updateProfile("technical_thesis", v)} />
        </div>
      </div>

      {/* Funding Rounds Section */}
      <div className="mt-12">
        <div className="flex items-center justify-between">
          <h2 className="diplomatic-label">Funding Rounds ({fundingRounds.length})</h2>
          <button
            onClick={() => setShowAddRound(!showAddRound)}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-primary hover:bg-primary/5 transition-colors"
          >
            <span className="material-symbols-outlined text-[16px]">
              {showAddRound ? "close" : "add"}
            </span>
            {showAddRound ? "Cancel" : "Add Round"}
          </button>
        </div>

        {/* Add Round Form */}
        {showAddRound && (
          <div className="mt-4 bg-surface-container-lowest p-5 space-y-4">
            <div className="grid grid-cols-3 gap-4">
              <SelectField
                label="Stage"
                value={newRound.stage}
                options={stageOptions}
                onChange={(v) => setNewRound((r) => ({ ...r, stage: v }))}
              />
              <Field
                label="Amount (EUR, raw)"
                value={newRound.amount_eur}
                onChange={(v) => setNewRound((r) => ({ ...r, amount_eur: v }))}
                type="number"
                placeholder="e.g. 5000000"
              />
              <Field
                label="Announced Date"
                value={newRound.announced_date}
                onChange={(v) => setNewRound((r) => ({ ...r, announced_date: v }))}
                type="date"
              />
            </div>
            <Field
              label="Notes"
              value={newRound.notes}
              onChange={(v) => setNewRound((r) => ({ ...r, notes: v }))}
              placeholder="Optional notes about this round"
            />
            <button
              onClick={handleAddRound}
              disabled={addingRound}
              className="institutional-gradient px-5 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90 disabled:opacity-50"
            >
              {addingRound ? "Adding..." : "Add Funding Round"}
            </button>
          </div>
        )}

        {/* Rounds List */}
        <div className="mt-4 space-y-2">
          {fundingRounds.map((round) => {
            const investors = round.funding_round_investors ?? [];
            const leadInvestors = investors.filter((i) => i.is_lead).map((i) => i.investor_name).filter(Boolean);
            const otherInvestors = investors.filter((i) => !i.is_lead).map((i) => i.investor_name).filter(Boolean);

            return (
              <div
                key={round.id}
                className="flex items-start gap-4 bg-surface-container-lowest p-4"
              >
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-3">
                    <span className="px-2 py-0.5 text-[0.65rem] font-semibold bg-primary/10 text-primary">
                      {round.stage?.replace(/_/g, " ") ?? "—"}
                    </span>
                    <span className="text-sm font-medium text-on-surface">
                      {formatEurDisplay(round.amount_eur)}
                    </span>
                    <span className="text-xs text-on-surface-variant">
                      {round.announced_date ?? "No date"}
                    </span>
                    {round.currency_original && round.currency_original !== "EUR" && (
                      <span className="text-[0.6rem] text-outline-variant">
                        (original: {round.amount_original?.toLocaleString()} {round.currency_original})
                      </span>
                    )}
                  </div>
                  {investors.length > 0 && (
                    <p className="mt-1.5 text-xs text-on-surface-variant">
                      {leadInvestors.length > 0 && (
                        <span>
                          <strong>Lead:</strong> {leadInvestors.join(", ")}
                          {otherInvestors.length > 0 && " · "}
                        </span>
                      )}
                      {otherInvestors.join(", ")}
                    </p>
                  )}
                  {round.notes && (
                    <p className="mt-1 text-[0.7rem] italic text-outline-variant">
                      {round.notes}
                    </p>
                  )}
                </div>
                <button
                  onClick={() => handleDeleteRound(round.id)}
                  className="shrink-0 p-1 text-outline-variant hover:text-error transition-colors"
                  title="Delete round"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    delete
                  </span>
                </button>
              </div>
            );
          })}

          {fundingRounds.length === 0 && (
            <p className="py-6 text-center text-sm italic text-on-surface-variant">
              No funding rounds recorded for this organization.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Reusable form components ─────────────────────────────

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
        rows={3}
        className="w-full border border-outline-variant/15 bg-surface-container-lowest p-3 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
      />
    </div>
  );
}

function SelectField({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string;
  options: string[];
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
        {label}
      </label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
      >
        {options.map((opt) => (
          <option key={opt} value={opt}>
            {opt ? opt.replace(/_/g, " ") : "— none —"}
          </option>
        ))}
      </select>
    </div>
  );
}
