# DefectFlow

A universal **site-defect tracking app for builders** — log defects against jobs
and trades, attach photos, generate reports. Multi-tenant SaaS: every builder
gets their own private, isolated workspace.

> Forked from the Creation Homes "Defect Manager" internal tool (2026-06-13) and
> being productised. The Creation Homes app keeps running untouched; this is a
> clean, separate product with its **own backend**.

## Status — Phase 1 (prototype foundation)

- ✅ Forked from the proven Defect Manager codebase (UI + defect workflow intact)
- ✅ **Decoupled from Creation Homes** — no CH Tracker job feed, no `qwqw`
  backdoor, no `@creationhomes` login domain, neutral branding (DefectFlow)
- ✅ Runs **local-only** out of the box (no backend needed to demo the UI)
- ✅ **Multi-tenant database blueprint** — `supabase/schema.sql`
  (organizations + members + RLS so each builder is fully isolated)

## Run it (local prototype)

It's a static app — no build step.

```powershell
# any static server, e.g.
npx serve .
# then open the printed URL
```

With `SUPABASE_CONFIG` left as the `YOUR_…` placeholders (in `index.html`), it
runs **local-only**: no login, data stays on the device. Good for showing the
flow without standing up a backend.

## Going live (Phase 2 — multi-tenant backend)

1. **Create a NEW Supabase project** (not the Creation Homes one). Free tier is fine.
2. Apply the schema: run `supabase/schema.sql` in the SQL editor.
3. Create a Storage bucket `defect-photos` (private) with RLS scoped by org.
4. Paste the project **URL + anon key** into `window.SUPABASE_CONFIG` in `index.html`.
5. Re-point `cloud-sync.js` at the new org-scoped tables (jobs/trades/contractors/
   defects with `org_id`) instead of the old `dm_*` / CH `jobs` tables.

## Roadmap

| Phase | What | Status |
|-------|------|--------|
| 1 | Fork, decouple, rebrand, schema blueprint, runs local-only | **done** |
| 2 | New Supabase backend + org-scoped sync + **company sign-up / onboarding** | next |
| 3 | Roles & invites UI, in-app **job/site management**, starter trade list | |
| 4 | Account deletion, privacy policy, billing (Stripe), per-company report branding | |
| 5 | Native wrapper (Capacitor) → TestFlight → App Store | |

The big architectural lift is Phase 2 (multi-tenancy). Everything the supervisors
already love about the workflow carries over from the fork.

## What was removed vs. the Creation Homes app

- CH Tracker job/supervisor feed (jobs become first-class, builder-entered)
- `qwqw/qwqw` master-login backdoor, `@creationhomes.com.au` default domain
- Creation Homes branding (now "DefectFlow")
- Shared Supabase project (DefectFlow gets its own, isolated per org)
