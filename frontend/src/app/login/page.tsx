"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { signInWithEmail } from "@/lib/auth";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await signInWithEmail(email, password);
      router.push("/admin");
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Invalid email or password"
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-full items-center justify-center bg-surface px-4">
      <div className="w-full max-w-sm">
        {/* Masthead */}
        <div className="mb-10 text-center">
          <Link href="/">
            <h1 className="font-headline text-2xl font-semibold tracking-tight text-primary">
              The Navigator
            </h1>
          </Link>
          <p className="diplomatic-label mt-2">Team Access</p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label
              htmlFor="email"
              className="diplomatic-label mb-2 block text-[0.65rem]"
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2.5 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
              placeholder="you@team.com"
            />
          </div>

          <div>
            <label
              htmlFor="password"
              className="diplomatic-label mb-2 block text-[0.65rem]"
            >
              Password
            </label>
            <input
              id="password"
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full border-b border-outline-variant/25 bg-transparent py-2.5 text-sm text-on-surface placeholder:text-outline-variant focus:border-primary focus:outline-none"
              placeholder="••••••••"
            />
          </div>

          {error && (
            <div className="bg-error-container px-4 py-2.5 text-sm text-on-error-container">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="institutional-gradient w-full py-3 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <p className="mt-8 text-center text-xs text-on-surface-variant">
          <Link href="/" className="hover:text-on-surface">
            ← Back to The Navigator
          </Link>
        </p>
      </div>
    </div>
  );
}
