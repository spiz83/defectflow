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

## Backend — LIVE (provisioned 2026-06-13)

A dedicated Supabase project is up (separate from Creation Homes):

| | |
|---|---|
| Project | **DefectFlow** (org: Homes Dashboard, region ap-southeast-2) |
| Ref | `ghhotxyboqjgrkrlkwkq` |
| URL | `https://ghhotxyboqjgrkrlkwkq.supabase.co` |
| Anon key (public) | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoaG90eHlib3FqZ3Jrcmxrd2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzMjAyOTYsImV4cCI6MjA5Njg5NjI5Nn0.ypbUk0MoMpoHBWqhHJlC68K50sCFnNUtkNTwul-epSU` |
| Schema + RLS | applied (10 tables, 14 policies) |
| Storage bucket | `defect-photos` (private) created |
| DB password | in gitignored `.db_password_SAVE_ME.txt` — **save it elsewhere** |

## Going live (remaining Phase 2 — wire the app to the backend)

1. ✅ New Supabase project + `supabase/schema.sql` applied + storage bucket — DONE.
2. **Wire `cloud-sync.js`** to the org-scoped tables (jobs/trades/contractors/
   defects with `org_id`) instead of the old `dm_*` / CH `jobs` tables.
3. **Onboarding:** on first login, if the user has no org, ask for a company name
   and call the `create_organization()` RPC; then load that org's data.
4. Paste the URL + anon key into `window.SUPABASE_CONFIG` (index.html) to switch
   it from local-only to live — do this *after* step 2 so sync matches the schema.

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
