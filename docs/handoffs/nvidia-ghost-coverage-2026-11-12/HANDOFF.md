# Handoff: Nvidia coverage in the FTJ Ghost archive

**Produced:** 12 November 2026, in a Claude Code session on branch `claude/beautiful-einstein-7j80lm`.
**Purpose:** merge these results with a second Nvidia query run in another Navigator environment.

## Files in this folder

| File | What it is |
|---|---|
| `HANDOFF.md` | This document: method, schema, and how to merge |
| `analysis.md` | The written editorial analysis (phases, themes, gaps) |
| `nvidia_articles.json` | **Main merge file.** One record per matching article, with context snippets |
| `nvidia_articles.csv` | The same records without snippets, for spreadsheets |
| `fetch.mjs` | The exact script used to pull the data (read-only) |

## What this query did

- **Source:** Ghost Admin API (`/ghost/api/admin/posts/`, `Accept-Version: v5.0`). Credentials come from the `GHOST_ADMIN_URL` and `GHOST_ADMIN_API_KEY` env vars. None are stored here.
- **Scope:** `filter=status:published`, all pages (`limit=100`), `formats=plaintext`, `include=tags,authors`. **Posts only**: no pages, drafts, or scheduled posts.
- **Snapshot:** 1,040 published posts, dated 2014-12-09 to 2026-11-12.
- **Match rule:** case-insensitive regex `nvidia` on title and plaintext body. **136 posts matched.**
- **Not matched:** "NVentures", "Jensen Huang" alone, "GTC" alone, "CUDA", "Hugging Face deal" without the word Nvidia, excerpt or meta fields, and image alt text. If the other query uses a wider term list, its extra hits are expected and legitimate. This one is narrower.
- **Read-only:** only GET requests were made, so nothing in Ghost was changed.

To rerun it: `node fetch.mjs` (Node 18+, env vars set). It writes `all.json` and `nvidia.json` to the current directory.

## Record schema (`nvidia_articles.json`)

| Field | Type | Notes |
|---|---|---|
| `ghost_id` | string | Ghost post ID. **Use this as the merge key.** |
| `slug` | string | Fallback key |
| `url` | string | Canonical URL. Second fallback key |
| `published_at` / `updated_at` | ISO datetime | From Ghost |
| `title` | string | |
| `authors`, `tags` | string[] | Display names |
| `nvidia_mentions` | int | Count of "nvidia" in title and body |
| `boilerplate_mentions` | int | Mentions inside recurring ads or ICYMI blurbs (patterns below) |
| `boilerplate_only` | bool | True if every mention is boilerplate (17 posts) |
| `in_title` | bool | 6 posts |
| `word_count` | int | Plaintext words |
| `snippets` | string[] | About 440 characters of context around each mention (mentions closer than 250 characters are merged) |

**Boilerplate patterns counted:** the VivaTech 10th-anniversary sponsor blurb ("Expect world-class speakers from companies like/such as NVIDIA"), the VSORA ICYMI link, the GTC Paris sponsored ad, the Orange Agentic AI Challenge blurb, the ai-PULSE Tech Talk blurb, and the Quandela related-post card.

## How to merge

1. **Join on `ghost_id`.** If the other result set has no Ghost IDs, use `slug`, then the `url` with trailing slash and query string removed. Don't join on titles: newsletters reuse near-identical titles.
2. **Check the snapshot date.** Posts published or edited after 2026-11-12 will appear only in the other set. Compare `updated_at` before trusting either version of a body.
3. **Check that the scopes match.** If the other query included pages, drafts or the Content API, label those records with their source rather than mixing them in silently.
4. **Reconcile the counts.** Expect: in both / only here (should be close to 0 if the other query is a wider search) / only there. List every "only here" post — that points to a filter difference worth understanding.
5. **Deduplicate the stories, not just the posts.** The same item often runs in La Machine, French Tech Wire and the Funding Wire. When counting *stories* rather than posts, group by snippet similarity.
6. **Keep both analyses' editorial categories** and record which run produced each label.

## Headline numbers from this run (for sanity-checking)

- 136 / 1,040 posts mention Nvidia. 18 have 5+ mentions, 44 have 2–4, and 74 have exactly 1.
- By year: 2023 = 4, 2024 = 12, 2025 = 48, 2026 = 72. Nothing before 2023.
- Most mentions in one post: *Jensen Huang's Nvidia Paris Pitch…* (2026-10-14), 17 mentions.

## Open items to resolve together

- Coverage gaps from `analysis.md` §6: the antitrust outcome, the $2bn "AI factory" plan from GTC Berlin, the progress of the MGX/Mistral campus, and an interview with an Nvidia France executive.
- The Nvidia investment list (`analysis.md` §2, Phase 3) was compiled by hand from snippets. Check it against the other run and the Navigator funding database before publishing.
