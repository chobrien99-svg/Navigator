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

interface FundingRoundInvestorRow {
  id: string;
  investor_name: string | null;
  is_lead: boolean;
  funding_round_id: string;
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
  funding_round_investors?: FundingRoundInvestorRow[];
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
  const [editingRoundId, setEditingRoundId] = useState<string | null>(null);
  const [showAddRound, setShowAddRound] = useState(false);
  const [newRound, setNewRound] = useState({
    stage: "seed",
    amount_eur: "",
    announced_date: "",
    notes: "",
    investors: "",
  });
  const [addingRound, setAddingRound] = useState(false);
  const [investorSuggestions, setInvestorSuggestions] = useState<string[]>([]);
  const [newInvestorName, setNewInvestorName] = useState("");
  const [newInvestorIsLead, setNewInvestorIsLead] = useState(false);
  const [filteredSuggestions, setFilteredSuggestions] = useState<string[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);

  // Sectors state
  interface OrgSectorRow {
    id: string;
    sector_id: string;
    is_primary: boolean;
    sectors: { id: string; name: string; slug: string } | null;
  }
  interface SectorOption {
    id: string;
    name: string;
    slug: string;
  }
  const [orgSectors, setOrgSectors] = useState<OrgSectorRow[]>([]);
  const [allSectors, setAllSectors] = useState<SectorOption[]>([]);
  const [newSectorId, setNewSectorId] = useState("");
  const [newSectorIsPrimary, setNewSectorIsPrimary] = useState(false);

  // Delete state
  const [deleting, setDeleting] = useState(false);

  // Portfolio (for investor-type orgs)
  interface PortfolioEntry {
    id: string;
    is_lead: boolean;
    investment_amount_eur: number | null;
    funding_round: {
      id: string;
      stage: string;
      amount_eur: number | null;
      announced_date: string | null;
      organization: {
        id: string;
        name: string;
        slug: string;
      } | null;
    } | null;
  }
  const [portfolio, setPortfolio] = useState<PortfolioEntry[]>([]);

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
        setFundingRounds(roundsData as unknown as FundingRoundRow[]);
      }

      // Load investor name suggestions for autocomplete
      const { data: investorNames } = await supabase
        .from("organizations")
        .select("name")
        .eq("organization_type", "investor")
        .order("name")
        .limit(2000);

      if (investorNames) {
        setInvestorSuggestions(investorNames.map((i: { name: string }) => i.name));
      }

      // Load organization sectors
      const { data: orgSectorsData } = await supabase
        .from("organization_sectors")
        .select("id, sector_id, is_primary, sectors(id, name, slug)")
        .eq("organization_id", id);
      if (orgSectorsData) {
        setOrgSectors(orgSectorsData as unknown as OrgSectorRow[]);
      }

      // Load all sectors for the dropdown
      const { data: allSectorsData } = await supabase
        .from("sectors")
        .select("id, name, slug")
        .order("name");
      if (allSectorsData) {
        setAllSectors(allSectorsData as SectorOption[]);
      }

      // Load portfolio (only meaningful for investors, but we fetch either way
      // — empty list if the org isn't an investor).
      const { data: portfolioData } = await supabase
        .from("funding_round_investors")
        .select(
          "id, is_lead, investment_amount_eur, funding_round:funding_round_id(id, stage, amount_eur, announced_date, organization:organization_id(id, name, slug))"
        )
        .eq("investor_id", id)
        .order("funding_round(announced_date)", { ascending: false })
        .limit(500);
      if (portfolioData) {
        setPortfolio(portfolioData as unknown as PortfolioEntry[]);
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
        .select("*, funding_round_investors(id, investor_name, is_lead, funding_round_id)")
        .single();

      if (insertErr) throw insertErr;

      // Add investors if provided
      if (inserted && newRound.investors.trim()) {
        const investorNames = newRound.investors.split(",").map((n) => n.trim()).filter(Boolean);
        for (let i = 0; i < investorNames.length; i++) {
          const invName = investorNames[i];
          // Ensure investor org exists
          const invSlug = invName.toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-");
          const { data: existingOrg } = await supabase
            .from("organizations")
            .select("id")
            .eq("slug", invSlug)
            .single();

          let investorOrgId = existingOrg?.id;
          if (!investorOrgId) {
            const { data: newOrg } = await supabase
              .from("organizations")
              .insert({ name: invName, slug: invSlug, organization_type: "investor", status: "active", country: "France" })
              .select("id")
              .single();
            investorOrgId = newOrg?.id;
          }

          if (investorOrgId) {
            await supabase.from("funding_round_investors").insert({
              funding_round_id: inserted.id,
              investor_id: investorOrgId,
              investor_name: invName,
              is_lead: i === 0,
            });
          }
        }
        // Reload the round with investors
        const { data: reloaded } = await supabase
          .from("funding_rounds")
          .select("*, funding_round_investors(id, investor_name, is_lead, funding_round_id)")
          .eq("id", inserted.id)
          .single();
        if (reloaded) {
          setFundingRounds((prev) => [reloaded as unknown as FundingRoundRow, ...prev]);
        }
      } else if (inserted) {
        setFundingRounds((prev) => [inserted as unknown as FundingRoundRow, ...prev]);
      }

      setShowAddRound(false);
      setNewRound({ stage: "seed", amount_eur: "", announced_date: "", notes: "", investors: "" });
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to add funding round");
    } finally {
      setAddingRound(false);
    }
  }

  async function handleUpdateRound(roundId: string, updates: { stage?: string; amount_eur?: number | null; announced_date?: string | null; notes?: string | null }) {
    setError(null);
    const { error: updErr } = await supabase
      .from("funding_rounds")
      .update(updates)
      .eq("id", roundId);

    if (updErr) {
      setError(updErr.message);
    } else {
      setFundingRounds((prev) =>
        prev.map((r) => (r.id === roundId ? { ...r, ...updates } : r))
      );
    }
  }

  async function handleDeleteRound(roundId: string) {
    if (!confirm("Delete this funding round? This cannot be undone.")) return;
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

  async function handleAddInvestor(roundId: string) {
    if (!newInvestorName.trim()) return;
    setError(null);

    const invName = newInvestorName.trim();
    const invSlug = invName.toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-");

    // Find or create investor org
    const { data: existingOrg } = await supabase
      .from("organizations")
      .select("id")
      .eq("slug", invSlug)
      .single();

    let investorOrgId = existingOrg?.id;
    if (!investorOrgId) {
      const { data: newOrg } = await supabase
        .from("organizations")
        .insert({ name: invName, slug: invSlug, organization_type: "investor", status: "active", country: "France" })
        .select("id")
        .single();
      investorOrgId = newOrg?.id;
      if (invName && !investorSuggestions.includes(invName)) {
        setInvestorSuggestions((prev) => [...prev, invName].sort());
      }
    }

    if (!investorOrgId) {
      setError("Failed to create investor organization");
      return;
    }

    const { data: inv, error: invErr } = await supabase
      .from("funding_round_investors")
      .insert({
        funding_round_id: roundId,
        investor_id: investorOrgId,
        investor_name: invName,
        is_lead: newInvestorIsLead,
      })
      .select("id, investor_name, is_lead, funding_round_id")
      .single();

    if (invErr) {
      setError(invErr.message);
    } else if (inv) {
      setFundingRounds((prev) =>
        prev.map((r) =>
          r.id === roundId
            ? { ...r, funding_round_investors: [...(r.funding_round_investors ?? []), inv as FundingRoundInvestorRow] }
            : r
        )
      );
      setNewInvestorName("");
      setNewInvestorIsLead(false);
      setShowSuggestions(false);
    }
  }

  async function handleRemoveInvestor(roundId: string, investorRowId: string) {
    const { error: delErr } = await supabase
      .from("funding_round_investors")
      .delete()
      .eq("id", investorRowId);

    if (delErr) {
      setError(delErr.message);
    } else {
      setFundingRounds((prev) =>
        prev.map((r) =>
          r.id === roundId
            ? { ...r, funding_round_investors: (r.funding_round_investors ?? []).filter((i) => i.id !== investorRowId) }
            : r
        )
      );
    }
  }

  function handleInvestorSearch(value: string) {
    setNewInvestorName(value);
    if (value.trim().length >= 2) {
      const q = value.toLowerCase();
      setFilteredSuggestions(investorSuggestions.filter((s) => s.toLowerCase().includes(q)).slice(0, 8));
      setShowSuggestions(true);
    } else {
      setShowSuggestions(false);
    }
  }

  // ─── Sector handlers ──────────────────────────────────
  async function handleAddSector() {
    if (!newSectorId) return;
    setError(null);
    // If marking primary but another primary already exists, demote the existing one
    if (newSectorIsPrimary) {
      const existingPrimary = orgSectors.find((s) => s.is_primary);
      if (existingPrimary) {
        const { error: demoteErr } = await supabase
          .from("organization_sectors")
          .update({ is_primary: false })
          .eq("id", existingPrimary.id);
        if (demoteErr) {
          setError(demoteErr.message);
          return;
        }
      }
    }

    const { data: inserted, error: insErr } = await supabase
      .from("organization_sectors")
      .insert({
        organization_id: id,
        sector_id: newSectorId,
        is_primary: newSectorIsPrimary,
      })
      .select("id, sector_id, is_primary, sectors(id, name, slug)")
      .single();

    if (insErr) {
      setError(insErr.message);
      return;
    }
    if (inserted) {
      setOrgSectors((prev) => {
        const demoted = newSectorIsPrimary
          ? prev.map((s) => ({ ...s, is_primary: false }))
          : prev;
        return [...demoted, inserted as unknown as OrgSectorRow];
      });
      setNewSectorId("");
      setNewSectorIsPrimary(false);
    }
  }

  async function handleRemoveSector(rowId: string) {
    const { error: delErr } = await supabase
      .from("organization_sectors")
      .delete()
      .eq("id", rowId);
    if (delErr) {
      setError(delErr.message);
    } else {
      setOrgSectors((prev) => prev.filter((s) => s.id !== rowId));
    }
  }

  async function handleDeleteOrg() {
    const prompt = `Delete "${form.name}"? This cannot be undone.\n\nAll linked data (funding rounds, sectors, legal entities, people links, program memberships) will be removed via cascade.\n\nType the organization name to confirm:`;
    const confirmation = window.prompt(prompt);
    if (confirmation == null) return;
    if (confirmation.trim() !== form.name.trim()) {
      setError("Name did not match — deletion cancelled.");
      return;
    }
    setDeleting(true);
    setError(null);
    const { error: delErr } = await supabase
      .from("organizations")
      .delete()
      .eq("id", id);
    if (delErr) {
      setError(delErr.message);
      setDeleting(false);
    } else {
      router.push("/admin/organizations");
    }
  }

  async function handleTogglePrimary(rowId: string) {
    // Demote any existing primary, then mark this one primary
    setError(null);
    const target = orgSectors.find((s) => s.id === rowId);
    if (!target) return;
    if (target.is_primary) {
      // Toggle off
      const { error: updErr } = await supabase
        .from("organization_sectors")
        .update({ is_primary: false })
        .eq("id", rowId);
      if (updErr) {
        setError(updErr.message);
        return;
      }
      setOrgSectors((prev) =>
        prev.map((s) => (s.id === rowId ? { ...s, is_primary: false } : s))
      );
      return;
    }
    // Demote existing primary
    const existing = orgSectors.find((s) => s.is_primary);
    if (existing) {
      await supabase
        .from("organization_sectors")
        .update({ is_primary: false })
        .eq("id", existing.id);
    }
    // Promote this one
    const { error: updErr } = await supabase
      .from("organization_sectors")
      .update({ is_primary: true })
      .eq("id", rowId);
    if (updErr) {
      setError(updErr.message);
      return;
    }
    setOrgSectors((prev) =>
      prev.map((s) => ({
        ...s,
        is_primary: s.id === rowId,
      }))
    );
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
            onClick={handleDeleteOrg}
            disabled={saving || deleting}
            className="px-4 py-2 text-sm text-error transition-colors hover:bg-error-container/50 disabled:opacity-50"
          >
            {deleting ? "Deleting..." : "Delete"}
          </button>
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

        {/* Right: Profile / Intelligence — fields vary by organization type */}
        <div className="space-y-6">
          <h2 className="diplomatic-label">Intelligence Profile</h2>

          {form.organization_type === "investor" ? (
            <>
              <TextArea label="What They Invest In" value={profile.what_they_are_building} onChange={(v) => updateProfile("what_they_are_building", v)} />
              <TextArea label="Why They Matter" value={profile.why_it_matters} onChange={(v) => updateProfile("why_it_matters", v)} />
              <TextArea label="Firm Brief" value={profile.investor_brief} onChange={(v) => updateProfile("investor_brief", v)} />
              <TextArea label="Analyst Note" value={profile.analyst_note} onChange={(v) => updateProfile("analyst_note", v)} />
              <TextArea label="Geographic Focus" value={profile.target_market} onChange={(v) => updateProfile("target_market", v)} />
              <TextArea label="Investment Focus / Stage Preference" value={profile.current_strategy} onChange={(v) => updateProfile("current_strategy", v)} />
              <TextArea label="Sector Thesis" value={profile.technical_thesis} onChange={(v) => updateProfile("technical_thesis", v)} />
            </>
          ) : (
            <>
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
            </>
          )}
        </div>
      </div>

      {/* Sectors Section */}
      <div className="mt-12">
        <h2 className="diplomatic-label">Sectors ({orgSectors.length})</h2>
        <div className="mt-3 flex flex-wrap gap-2">
          {orgSectors.map((s) => (
            <span
              key={s.id}
              className={`inline-flex items-center gap-1.5 px-2.5 py-1 text-xs ${
                s.is_primary
                  ? "bg-primary/15 text-primary"
                  : "bg-surface-container text-on-surface-variant"
              }`}
            >
              {s.is_primary && (
                <span className="material-symbols-outlined text-[12px]">star</span>
              )}
              {s.sectors?.name ?? "?"}
              <button
                onClick={() => handleTogglePrimary(s.id)}
                className="ml-1 text-outline-variant hover:text-primary"
                title={s.is_primary ? "Demote from primary" : "Set as primary"}
              >
                <span className="material-symbols-outlined text-[12px]">
                  {s.is_primary ? "star" : "star_outline"}
                </span>
              </button>
              <button
                onClick={() => handleRemoveSector(s.id)}
                className="ml-0.5 text-outline-variant hover:text-error"
                title="Remove sector"
              >
                <span className="material-symbols-outlined text-[12px]">close</span>
              </button>
            </span>
          ))}
          {orgSectors.length === 0 && (
            <span className="text-xs italic text-outline-variant">
              No sectors assigned
            </span>
          )}
        </div>

        {/* Add sector form */}
        <div className="mt-4 flex items-end gap-3">
          <div className="flex-1 max-w-xs">
            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">
              Add sector
            </label>
            <select
              value={newSectorId}
              onChange={(e) => setNewSectorId(e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
            >
              <option value="">— select —</option>
              {allSectors
                .filter((s) => !orgSectors.find((os) => os.sector_id === s.id))
                .map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
            </select>
          </div>
          <label className="flex items-center gap-2 pb-2">
            <input
              type="checkbox"
              checked={newSectorIsPrimary}
              onChange={(e) => setNewSectorIsPrimary(e.target.checked)}
              className="accent-primary"
            />
            <span className="text-xs text-on-surface-variant">Primary</span>
          </label>
          <button
            onClick={handleAddSector}
            disabled={!newSectorId}
            className="px-3 py-2 text-xs font-medium text-primary hover:bg-primary/5 transition-colors disabled:opacity-30"
          >
            Add
          </button>
        </div>
      </div>

      {/* Portfolio Section — only for investors */}
      {form.organization_type === "investor" && (
        <div className="mt-12">
          <h2 className="diplomatic-label">
            Portfolio ({portfolio.length} {portfolio.length === 1 ? "investment" : "investments"})
          </h2>
          <div className="mt-4 space-y-2">
            {portfolio.length === 0 && (
              <p className="text-xs italic text-on-surface-variant">
                No portfolio investments recorded. As funding rounds are added
                with this firm as an investor, they will appear here.
              </p>
            )}
            {portfolio.map((entry) => {
              const round = entry.funding_round;
              const org = round?.organization;
              if (!round || !org) return null;
              return (
                <Link
                  key={entry.id}
                  href={`/admin/organizations/${org.id}`}
                  className="group flex items-center gap-4 bg-surface-container-lowest px-4 py-3 transition-colors hover:bg-surface-container-low"
                >
                  {entry.is_lead && (
                    <span className="material-symbols-outlined text-[14px] text-primary" title="Lead investor">
                      star
                    </span>
                  )}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3">
                      <p className="text-sm font-medium text-on-surface group-hover:text-primary">
                        {org.name}
                      </p>
                      {round.stage && (
                        <span className="px-1.5 py-0.5 text-[0.6rem] font-semibold bg-primary/10 text-primary">
                          {round.stage.replace(/_/g, " ")}
                        </span>
                      )}
                    </div>
                  </div>
                  <span className="text-xs text-on-surface-variant">
                    {round.announced_date ?? "—"}
                  </span>
                  <span className="text-sm font-medium text-on-surface text-right w-24">
                    {formatEurDisplay(round.amount_eur)}
                  </span>
                </Link>
              );
            })}
          </div>
        </div>
      )}

      {/* Funding Rounds Section */}
      <div className="mt-12">
        <div className="flex items-center justify-between">
          <h2 className="diplomatic-label">Funding Rounds ({fundingRounds.length})</h2>
          <button
            onClick={() => { setShowAddRound(!showAddRound); setEditingRoundId(null); }}
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
              label="Investors (comma-separated)"
              value={newRound.investors}
              onChange={(v) => setNewRound((r) => ({ ...r, investors: v }))}
              placeholder="e.g. Bpifrance, Sequoia Capital, Y Combinator"
            />
            <p className="text-[0.6rem] text-outline-variant -mt-2">First investor listed is marked as lead.</p>
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
        <div className="mt-4 space-y-3">
          {fundingRounds.map((round) => {
            const investors = round.funding_round_investors ?? [];
            const isEditing = editingRoundId === round.id;

            return (
              <div key={round.id} className="bg-surface-container-lowest p-5">
                {/* Round header with edit toggle */}
                <div className="flex items-start gap-4">
                  <div className="flex-1 min-w-0">
                    {isEditing ? (
                      <div className="space-y-3">
                        <div className="grid grid-cols-3 gap-4">
                          <SelectField
                            label="Stage"
                            value={round.stage ?? ""}
                            options={stageOptions}
                            onChange={(v) => handleUpdateRound(round.id, { stage: v })}
                          />
                          <div>
                            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">Amount (EUR, raw)</label>
                            <input
                              type="number"
                              defaultValue={round.amount_eur != null ? Math.round(round.amount_eur * AMOUNT_MULTIPLIER) : ""}
                              onBlur={(e) => {
                                const val = e.target.value;
                                handleUpdateRound(round.id, {
                                  amount_eur: val ? parseFloat(val) / AMOUNT_MULTIPLIER : null,
                                });
                              }}
                              placeholder="e.g. 5000000"
                              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
                            />
                          </div>
                          <div>
                            <label className="diplomatic-label mb-1.5 block text-[0.6rem]">Announced Date</label>
                            <input
                              type="date"
                              defaultValue={round.announced_date ?? ""}
                              onBlur={(e) => handleUpdateRound(round.id, { announced_date: e.target.value || null })}
                              className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface focus:border-primary focus:outline-none"
                            />
                          </div>
                        </div>
                        <div>
                          <label className="diplomatic-label mb-1.5 block text-[0.6rem]">Notes</label>
                          <input
                            type="text"
                            defaultValue={round.notes ?? ""}
                            onBlur={(e) => handleUpdateRound(round.id, { notes: e.target.value || null })}
                            placeholder="Optional notes"
                            className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
                          />
                        </div>
                      </div>
                    ) : (
                      <>
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
                        {round.notes && (
                          <p className="mt-1 text-[0.7rem] italic text-outline-variant">
                            {round.notes}
                          </p>
                        )}
                      </>
                    )}
                  </div>
                  <div className="flex shrink-0 items-center gap-1">
                    <button
                      onClick={() => setEditingRoundId(isEditing ? null : round.id)}
                      className="p-1 text-outline-variant hover:text-primary transition-colors"
                      title={isEditing ? "Done editing" : "Edit round"}
                    >
                      <span className="material-symbols-outlined text-[16px]">
                        {isEditing ? "check" : "edit"}
                      </span>
                    </button>
                    <button
                      onClick={() => handleDeleteRound(round.id)}
                      className="p-1 text-outline-variant hover:text-error transition-colors"
                      title="Delete round"
                    >
                      <span className="material-symbols-outlined text-[16px]">
                        delete
                      </span>
                    </button>
                  </div>
                </div>

                {/* Investors */}
                <div className="mt-3 border-t border-outline-variant/10 pt-3">
                  <p className="text-[0.6rem] uppercase tracking-wider text-on-surface-variant/60 mb-2">
                    Investors ({investors.length})
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {investors.map((inv) => (
                      <span
                        key={inv.id}
                        className={`inline-flex items-center gap-1 px-2 py-1 text-xs ${
                          inv.is_lead ? "bg-primary/10 text-primary" : "bg-surface-container text-on-surface-variant"
                        }`}
                      >
                        {inv.is_lead && (
                          <span className="material-symbols-outlined text-[12px]">star</span>
                        )}
                        {inv.investor_name}
                        {isEditing && (
                          <button
                            onClick={() => handleRemoveInvestor(round.id, inv.id)}
                            className="ml-1 hover:text-error"
                          >
                            <span className="material-symbols-outlined text-[12px]">close</span>
                          </button>
                        )}
                      </span>
                    ))}
                    {investors.length === 0 && !isEditing && (
                      <span className="text-xs italic text-outline-variant">No investors listed</span>
                    )}
                  </div>

                  {/* Add investor (visible when editing) */}
                  {isEditing && (
                    <div className="mt-3 flex items-end gap-3">
                      <div className="relative flex-1 max-w-xs">
                        <label className="diplomatic-label mb-1.5 block text-[0.6rem]">Add Investor</label>
                        <input
                          type="text"
                          value={newInvestorName}
                          onChange={(e) => handleInvestorSearch(e.target.value)}
                          onFocus={() => { if (newInvestorName.length >= 2) setShowSuggestions(true); }}
                          onBlur={() => setTimeout(() => setShowSuggestions(false), 200)}
                          placeholder="Type investor name..."
                          className="w-full border-b border-outline-variant/25 bg-transparent py-2 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
                        />
                        {showSuggestions && filteredSuggestions.length > 0 && (
                          <div className="absolute z-10 mt-1 w-full bg-surface-container-lowest border border-outline-variant/20 shadow-lg max-h-40 overflow-y-auto">
                            {filteredSuggestions.map((s) => (
                              <button
                                key={s}
                                className="w-full px-3 py-2 text-left text-sm text-on-surface hover:bg-surface-container-low"
                                onMouseDown={() => {
                                  setNewInvestorName(s);
                                  setShowSuggestions(false);
                                }}
                              >
                                {s}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                      <label className="flex items-center gap-2 pb-2">
                        <input
                          type="checkbox"
                          checked={newInvestorIsLead}
                          onChange={(e) => setNewInvestorIsLead(e.target.checked)}
                          className="accent-primary"
                        />
                        <span className="text-xs text-on-surface-variant">Lead</span>
                      </label>
                      <button
                        onClick={() => handleAddInvestor(round.id)}
                        className="px-3 py-2 text-xs font-medium text-primary hover:bg-primary/5 transition-colors"
                      >
                        Add
                      </button>
                    </div>
                  )}
                </div>
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
