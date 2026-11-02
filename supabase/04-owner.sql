-- Liquid Trucking recruiting site: protect the owner's account and control who can make admins.
-- Run once in Supabase after 02-admin.sql: SQL Editor -> New query -> paste all of this -> Run.
-- Safe to run again. No users, counties or history are removed.

-- One owner (Jason). Only changed here in SQL, never from the website.
alter table public.editors add column if not exists owner boolean not null default false;
create unique index if not exists editors_one_owner on public.editors ((true)) where owner;
update public.editors set owner = true, role = 'admin', active = true where email = 'jason@liquidtrucking.com';

create or replace function public.is_owner()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.editors
                 where email = lower(auth.jwt() ->> 'email') and owner and active);
$$;
grant execute on function public.is_owner() to authenticated;

-- Same as before, plus the owner checks.
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

  -- Owner protection: only the owner can change the owner's account or any admin account,
  -- and only the owner can make someone an admin or take admin away.
  if not public.is_owner() then
    if v_prev.owner then raise exception 'Only the owner can change the owner''s account' using errcode = '42501'; end if;
    if v_prev.role = 'admin' and v_email <> v_me then raise exception 'Only the owner can change another admin''s account' using errcode = '42501'; end if;
    if p_role = 'admin' and v_prev.role is distinct from 'admin' then raise exception 'Only the owner can make someone an admin' using errcode = '42501'; end if;
  end if;

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

