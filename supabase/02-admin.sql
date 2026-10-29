-- Liquid Trucking recruiting site: user accounts, admins and page access.
-- Run once in Supabase after setup.sql: SQL Editor -> New query -> paste all of this -> Run.
-- Safe to run again.

-- 1. Accounts. The existing editors table becomes the user list.
--    role:   'admin' (manages users, can view and edit every page) or 'user'
--    active: inactive accounts can't view private pages or edit anything
--    pages:  per-page access, e.g. {"hiring-map":"edit"}; each value is 'view', 'edit' or 'none'
alter table public.editors add column if not exists role   text    not null default 'user';
alter table public.editors add column if not exists active boolean not null default true;
alter table public.editors add column if not exists pages  jsonb   not null default '{}'::jsonb;
alter table public.editors drop constraint if exists editors_role_check;
alter table public.editors add constraint editors_role_check check (role in ('admin','user'));

-- Everyone who could edit before keeps edit access to the Hiring Map.
update public.editors set pages = pages || '{"hiring-map":"edit"}'::jsonb where not pages ? 'hiring-map';
update public.editors set role = 'admin' where email = 'jason@liquidtrucking.com';

-- 2. Site pages. public_view = anyone with the link can view without signing in.
create table if not exists public.site_pages (
  id          text primary key,
  name        text not null,
  public_view boolean not null default true,
  sort        integer not null default 0
);
insert into public.site_pages (id, name, public_view, sort) values ('hiring-map', 'Hiring Map', true, 10)
on conflict (id) do nothing;
alter table public.site_pages enable row level security;
drop policy if exists "public read pages" on public.site_pages;
create policy "public read pages" on public.site_pages for select using (true);

-- 3. Account change history (who added or changed whom).
create table if not exists public.account_changes (
  id         bigint generated always as identity primary key,
  target     text not null,
  summary    text not null,
  changed_by_name text not null,
  changed_at timestamptz not null default now()
);
alter table public.account_changes enable row level security;

-- 4. Access helpers. They read the signed-in email from the login token.
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.editors
                 where email = lower(auth.jwt() ->> 'email') and role = 'admin' and active);
$$;

create or replace function public.page_access(p_page text)
returns text language sql stable security definer set search_path = public as $$
  select coalesce((
    select case when not active then 'none'
                when role = 'admin' then 'edit'
                else coalesce(pages ->> p_page, 'none') end
    from public.editors where email = lower(auth.jwt() ->> 'email')
  ), 'none');
$$;

create or replace function public.can_view(p_page text)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select public_view from public.site_pages where id = p_page), false)
      or public.page_access(p_page) in ('view','edit');
$$;

grant execute on function public.is_admin(), public.page_access(text), public.can_view(text) to anon, authenticated;

-- 5. Hiring Map data follows the page's access setting.
drop policy if exists "public read status"  on public.county_status;
drop policy if exists "public read changes" on public.county_changes;
create policy "public read status"  on public.county_status  for select using (public.can_view('hiring-map'));
create policy "public read changes" on public.county_changes for select using (public.can_view('hiring-map'));

-- Admins can see every account and the account history; others still see only their own row.
drop policy if exists "admins read all" on public.editors;
create policy "admins read all" on public.editors for select to authenticated using (public.is_admin());
drop policy if exists "admins read account changes" on public.account_changes;
create policy "admins read account changes" on public.account_changes for select to authenticated using (public.is_admin());

-- 6. County changes now need edit access to the Hiring Map on an active account.
create or replace function public.set_county(p_fips text[], p_level text, p_hiring boolean, p_note text, p_reason text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := lower(auth.jwt() ->> 'email');
  v_name  text;
  v_fips  text;
  v_prev  public.county_status%rowtype;
  v_count integer := 0;
begin
  if public.page_access('hiring-map') <> 'edit' then
    raise exception 'No edit access to the Hiring Map' using errcode = '42501';
  end if;
  select name into v_name from public.editors where email = v_email;
  if p_level not in ('green','yellow','orange','red') then
    raise exception 'Unknown color %', p_level;
  end if;
  foreach v_fips in array p_fips loop
    select * into v_prev from public.county_status where fips = v_fips;
    insert into public.county_status (fips, level, hiring, note, updated_by_name, updated_at)
      values (v_fips, p_level, p_hiring, coalesce(p_note,''), v_name, now())
      on conflict (fips) do update set level = excluded.level, hiring = excluded.hiring,
        note = excluded.note, updated_by_name = excluded.updated_by_name, updated_at = excluded.updated_at;
    insert into public.county_changes (fips, level, hiring, note, prev_level, prev_hiring, reason, changed_by, changed_by_name)
      values (v_fips, p_level, p_hiring, coalesce(p_note,''), v_prev.level, v_prev.hiring, coalesce(p_reason,''), auth.uid(), v_name);
    v_count := v_count + 1;
  end loop;
  return v_count;
end $$;

-- 7. Admin actions. Each checks the caller is an active admin and records the change.
create or replace function public.admin_save_user(p_email text, p_name text, p_role text, p_active boolean, p_pages jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_me    text := lower(auth.jwt() ->> 'email');
  v_by    text;
  v_email text := lower(trim(p_email));
  v_prev  public.editors%rowtype;
  v_k     text;
  v_v     text;
  v_sum   text := '';
begin
  if not public.is_admin() then raise exception 'Admins only' using errcode = '42501'; end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'That email doesn''t look right'; end if;
  if coalesce(trim(p_name),'') = '' then raise exception 'Name is required'; end if;
  if p_role not in ('admin','user') then raise exception 'Unknown role %', p_role; end if;
  for v_k, v_v in select key, value from jsonb_each_text(coalesce(p_pages,'{}'::jsonb)) loop
    if v_v not in ('view','edit','none') then raise exception 'Unknown access %', v_v; end if;
  end loop;
  if v_email = v_me and (p_role <> 'admin' or not p_active) then
    raise exception 'You can''t remove your own admin access or deactivate yourself';
  end if;

  select name into v_by from public.editors where email = v_me;
  select * into v_prev from public.editors where email = v_email;

  insert into public.editors (email, name, role, active, pages)
    values (v_email, trim(p_name), p_role, p_active, coalesce(p_pages,'{}'::jsonb))
    on conflict (email) do update set name = excluded.name, role = excluded.role,
      active = excluded.active, pages = excluded.pages;

  if v_prev.email is null then
    v_sum := 'Added as ' || p_role || case when p_active then '' else ' (inactive)' end;
  else
    if v_prev.name   is distinct from trim(p_name) then v_sum := v_sum || 'Name ' || v_prev.name || ' → ' || trim(p_name) || '. '; end if;
    if v_prev.role   is distinct from p_role       then v_sum := v_sum || 'Role ' || v_prev.role || ' → ' || p_role || '. '; end if;
    if v_prev.active is distinct from p_active     then v_sum := v_sum || case when p_active then 'Activated. ' else 'Deactivated. ' end; end if;
    if v_prev.pages  is distinct from coalesce(p_pages,'{}'::jsonb) then v_sum := v_sum || 'Page access ' || coalesce(p_pages,'{}'::jsonb)::text || '. '; end if;
    if v_sum = '' then return; end if;
  end if;
  insert into public.account_changes (target, summary, changed_by_name) values (v_email, trim(v_sum), coalesce(v_by, v_me));
end $$;

create or replace function public.admin_set_page_public(p_id text, p_public boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_by text;
begin
  if not public.is_admin() then raise exception 'Admins only' using errcode = '42501'; end if;
  update public.site_pages set public_view = p_public where id = p_id;
  if not found then raise exception 'Unknown page %', p_id; end if;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  insert into public.account_changes (target, summary, changed_by_name)
    values ('page:' || p_id, case when p_public then 'Anyone with the link can view' else 'Signed-in users with access only' end, v_by);
end $$;

revoke all on function public.admin_save_user(text, text, text, boolean, jsonb) from public, anon;
revoke all on function public.admin_set_page_public(text, boolean) from public, anon;
grant execute on function public.admin_save_user(text, text, text, boolean, jsonb) to authenticated;
grant execute on function public.admin_set_page_public(text, boolean) to authenticated;
