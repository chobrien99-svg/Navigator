// Minimal Ghost Admin API client (no dependencies).
// Docs: https://ghost.org/docs/admin-api/

import { createHmac } from "node:crypto";
import { START_MARKER } from "./render.mjs";

function base64url(input) {
  return Buffer.from(input).toString("base64url");
}

// Admin API keys look like "<id>:<hex secret>". Ghost expects a short-lived
// HS256 JWT signed with the secret. https://ghost.org/docs/admin-api/#token-authentication
function adminToken(adminApiKey) {
  const [id, secret] = String(adminApiKey).split(":");
  if (!id || !secret) throw new Error("GHOST_ADMIN_API_KEY must look like <id>:<secret>");
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "HS256", typ: "JWT", kid: id }));
  const payload = base64url(JSON.stringify({ iat: now, exp: now + 300, aud: "/admin/" }));
  const signature = createHmac("sha256", Buffer.from(secret, "hex"))
    .update(`${header}.${payload}`)
    .digest("base64url");
  return `${header}.${payload}.${signature}`;
}

export function createGhostClient({ url, adminApiKey }) {
  const root = String(url).replace(/\/+$/, "") + "/ghost/api/admin";

  async function request(method, path, body) {
    const res = await fetch(root + path, {
      method,
      headers: {
        Authorization: `Ghost ${adminToken(adminApiKey)}`,
        "Accept-Version": "v5.0",
        ...(body ? { "Content-Type": "application/json" } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    const text = await res.text();
    if (!res.ok) throw new Error(`Ghost ${method} ${path} -> ${res.status}: ${text.slice(0, 500)}`);
    return text ? JSON.parse(text) : {};
  }

  return {
    async getPageBySlug(slug) {
      const json = await request("GET", `/pages/slug/${encodeURIComponent(slug)}/?formats=lexical`);
      return json.pages?.[0];
    },

    async updatePageLexical(page, lexical) {
      const json = await request("PUT", `/pages/${page.id}/`, {
        pages: [{ lexical: JSON.stringify(lexical), updated_at: page.updated_at }],
      });
      return json.pages?.[0];
    },

    async getRecentPostsByTag(tag, limit) {
      const filter = encodeURIComponent(`tag:${tag}+status:published`);
      const json = await request(
        "GET",
        `/posts/?filter=${filter}&limit=${limit}&order=published_at%20desc&fields=title,url,published_at`
      );
      return json.posts ?? [];
    },
  };
}

// Replace the Funding Hub HTML card inside a page's Lexical document, leaving
// every other card (intro, methodology, images…) untouched. If the card does
// not exist yet it is appended at the end of the page; editors can then drag
// it wherever they want and later syncs keep that position.
export function upsertHubCard(lexical, html) {
  const doc = structuredClone(lexical);
  const children = doc?.root?.children;
  if (!Array.isArray(children)) throw new Error("Page has no Lexical content (is it an old Mobiledoc page?)");

  const index = children.findIndex((n) => n.type === "html" && String(n.html ?? "").includes(START_MARKER));
  if (index >= 0 && children[index].html === html) return { doc, changed: false, created: false };

  const card = { type: "html", version: 1, html };
  if (index >= 0) children[index] = { ...children[index], html };
  else children.push(card);
  return { doc, changed: true, created: index < 0 };
}
