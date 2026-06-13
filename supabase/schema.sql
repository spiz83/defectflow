-- ============================================================================
--  DefectFlow — multi-tenant schema
--  Every builder ("organization") is fully isolated by Row-Level Security.
--  A user only ever sees data for organizations they belong to.
--  Apply to a FRESH Supabase project (NOT the Creation Homes one).
-- ============================================================================

-- ── Profiles (mirror of auth.users) ─────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  email       text,
  created_at  timestamptz not null default now()
);

-- ── Organizations (one per builder/company) ─────────────────────────────────
create table if not exists public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_by  uuid references auth.users(id),
  created_at  timestamptz not null default now()
);

-- ── Membership: who belongs to which org, and their role ─────────────────────
create type public.org_role as enum ('owner','admin','supervisor');

create table if not exists public.org_members (
  org_id      uuid not null references public.organizations(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  role        public.org_role not null default 'supervisor',
  created_at  timestamptz not null default now(),
  primary key (org_id, user_id)
);

-- ── Helper functions (used by every RLS policy) ─────────────────────────────
-- SECURITY DEFINER so policies can check membership without recursive RLS.
create or replace function public.is_org_member(p_org uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from org_members m where m.org_id = p_org and m.user_id = auth.uid());
$$;

create or replace function public.org_role_of(p_org uuid)
returns public.org_role language sql stable security definer set search_path = public as $$
  select role from org_members m where m.org_id = p_org and m.user_id = auth.uid();
$$;

create or replace function public.is_org_manager(p_org uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(org_role_of(p_org) in ('owner','admin'), false);
$$;

-- ── Domain tables — every one carries org_id and is RLS-scoped ───────────────
create table if not exists public.jobs (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references public.organizations(id) on delete cascade,
  lot           text,
  street        text,
  suburb        text,
  job_number    text,
  status        text not null default 'active',   -- active | on_hold | completed
  supervisor_id uuid references auth.users(id),
  created_by    uuid references auth.users(id),
  created_at    timestamptz not null default now()
);

create table if not exists public.trades (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations(id) on delete cascade,
  name        text not null,
  code        text
);

create table if not exists public.contractors (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations(id) on delete cascade,
  name        text not null,
  email       text,
  phone       text,
  is_shared   boolean not null default true,      -- false = private to added_by until shared
  added_by    uuid references auth.users(id),
  created_at  timestamptz not null default now()
);

create table if not exists public.contractor_trades (
  contractor_id uuid not null references public.contractors(id) on delete cascade,
  trade_id      uuid not null references public.trades(id) on delete cascade,
  primary key (contractor_id, trade_id)
);

create table if not exists public.defects (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references public.organizations(id) on delete cascade,
  job_id        uuid references public.jobs(id) on delete cascade,
  contractor_id uuid references public.contractors(id),
  description   text not null,
  location      text,
  status        text not null default 'open',     -- open | pending | completed
  booking_at    date,
  created_by    uuid references auth.users(id),
  created_at    timestamptz not null default now(),
  completed_at  timestamptz
);

create table if not exists public.defect_photos (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references public.organizations(id) on delete cascade,
  defect_id    uuid not null references public.defects(id) on delete cascade,
  storage_path text not null,
  bytes        integer,
  created_at   timestamptz not null default now()
);

-- ── Invites (email a teammate into the org) ─────────────────────────────────
create table if not exists public.org_invites (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations(id) on delete cascade,
  email       text not null,
  role        public.org_role not null default 'supervisor',
  created_by  uuid references auth.users(id),
  created_at  timestamptz not null default now(),
  accepted_at timestamptz
);

-- ── Enable RLS everywhere ───────────────────────────────────────────────────
alter table public.profiles         enable row level security;
alter table public.organizations    enable row level security;
alter table public.org_members       enable row level security;
alter table public.jobs              enable row level security;
alter table public.trades            enable row level security;
alter table public.contractors        enable row level security;
alter table public.contractor_trades  enable row level security;
alter table public.defects            enable row level security;
alter table public.defect_photos      enable row level security;
alter table public.org_invites        enable row level security;

-- ── Policies ────────────────────────────────────────────────────────────────
-- Profiles: you can read/update your own.
create policy profiles_self on public.profiles for all to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Organizations: members can read; only managers update; any authed user can create.
create policy orgs_read   on public.organizations for select to authenticated using (is_org_member(id));
create policy orgs_create on public.organizations for insert to authenticated with check (created_by = auth.uid());
create policy orgs_update on public.organizations for update to authenticated using (is_org_manager(id));

-- Membership: members of an org can see its roster; managers manage it.
create policy members_read   on public.org_members for select to authenticated using (is_org_member(org_id));
create policy members_manage on public.org_members for all    to authenticated using (is_org_manager(org_id)) with check (is_org_manager(org_id));

-- Generic org-scoped read for the data tables.
create policy jobs_rw         on public.jobs         for all to authenticated using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy trades_rw       on public.trades       for all to authenticated using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy defects_rw      on public.defects      for all to authenticated using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy defphotos_rw    on public.defect_photos for all to authenticated using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy invites_rw      on public.org_invites  for all to authenticated using (is_org_manager(org_id)) with check (is_org_manager(org_id));

-- Contractors: visible if shared OR you added it OR you're a manager (within your org).
create policy contractors_read  on public.contractors for select to authenticated
  using (is_org_member(org_id) and (is_shared or added_by = auth.uid() or is_org_manager(org_id)));
create policy contractors_write on public.contractors for all to authenticated
  using (is_org_member(org_id)) with check (is_org_member(org_id));

-- contractor_trades: scoped through the parent contractor's org.
create policy ctrades_rw on public.contractor_trades for all to authenticated
  using (exists (select 1 from contractors c where c.id = contractor_id and is_org_member(c.org_id)))
  with check (exists (select 1 from contractors c where c.id = contractor_id and is_org_member(c.org_id)));

-- ── On signup: auto-create a profile row ────────────────────────────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email), new.email)
  on conflict (id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Create-org helper: make the creator the owner in one call ───────────────
create or replace function public.create_organization(p_name text)
returns uuid language plpgsql security definer set search_path = public as $$
declare new_id uuid;
begin
  insert into public.organizations (name, created_by) values (p_name, auth.uid()) returning id into new_id;
  insert into public.org_members (org_id, user_id, role) values (new_id, auth.uid(), 'owner');
  return new_id;
end; $$;

-- Indexes for the common org-scoped lookups.
create index if not exists idx_jobs_org        on public.jobs(org_id);
create index if not exists idx_trades_org       on public.trades(org_id);
create index if not exists idx_contractors_org  on public.contractors(org_id);
create index if not exists idx_defects_org      on public.defects(org_id);
create index if not exists idx_defects_job      on public.defects(job_id);
create index if not exists idx_members_user     on public.org_members(user_id);
