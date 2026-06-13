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
4. ✅ Live config wired; auth auto-confirm on; smoke-tested end-to-end (signup → org → job → defect, RLS-scoped). DONE.
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

## Monetization — decided 2026-06-13

**Two tiers only: Free → Paid at $3.49 / user / month.** (No middle tier — one
price that scales with team size: a solo supervisor pays $3.49, a 5-person
builder pays $17.45. Same product; price follows value.)

**Who buys what (same tier, two personas):**
- **Independent supervisors / TSCs** — buy a single seat for themselves.
- **Small builders** — buy multiple seats; the manager gets the cross-crew web
  dashboard. That dashboard + defect statistics is the **moat** — it's why a
  builder buys one team account instead of stacking solo licences.

**Free tier (the funnel — gate scale & output, never the core loop):**
- 2–3 active jobs (a real supervisor outgrows this fast)
- 1 user — *inviting a teammate is the paywall trigger*
- **Unlimited photos** (photos are the magic; never cap them) **but they
  auto-expire**: **28 days after upload, or 14 days after the defect is marked
  complete** (open defects keep the 28-day backstop; completed ones get a
  14-day grace from completion). Show an in-app countdown badge on free photos
  — *"deleted in N days · upgrade to keep forever"* — NOT a silent wipe buried
  in the T&Cs (that's a 1-star-review / trust landmine).
- PDF reports are **watermarked** ("Made with DefectFlow"); clean export is paid.

**Paid ($3.49/seat):** unlimited jobs, photos kept indefinitely, clean
(un-watermarked) PDF, multi-user, and the web dashboard + cross-crew defect
stats for managers.

**Billing mechanics (native phase):** Apple can't bill "per user" natively, so —
- **Solo** → single seat via **Apple IAP** in-app (15% under the Small Business
  Program, not 30%).
- **Teams** → add seats on a **web/Stripe** page, then log into the iOS app
  (allowed as reader-style; no payment button in-app — cleaner per-seat + dodges
  Apple's cut on team revenue).

**Build status:** none of this is wired yet — there is no tier/billing field on
`organizations` today, so everyone currently runs the full app. Enforcement
(tier flag → job cap, single-user lock, watermark, photo-expiry sweep, countdown
badge) lands in the monetization/native phase. The **photo-expiry machinery
already exists** (`sweepExpiredPhotos` in cloud-sync.js, currently a no-op) — it
just needs the expiry rule above + a `tier='free'` gate so it never touches paid
accounts. Also required for App Store review: account deletion, privacy policy
(must disclose the photo-retention rule), and Restore Purchases.
