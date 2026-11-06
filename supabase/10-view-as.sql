-- Liquid Trucking Operations Center: "View as" for admins (read-only).
-- Run once in Supabase after 09-faq-load.sql: SQL Editor -> New query -> paste all of this -> Run. Safe to run again.
-- Nothing is changed in users, pages, counties, FAQs or feedback. This only adds one function.
--
-- What it does: an admin picks a user on the Admin page and the site loads with that user's level and page access,
-- so the admin sees exactly what they see. The website blocks every change while viewing as someone.
-- This function is the server-side check behind it:
--   * only active admins can use it, and only the owner can view as another admin;
--   * you can't view as yourself;
--   * every start and end is written to Account history ("View as started (read-only)" / "View as ended").

create or replace function public.admin_view_as(p_email text, p_action text default 'check')
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_me    text := lower(auth.jwt() ->> 'email');
  v_email text := lower(trim(coalesce(p_email, '')));
  v_by    text;
  v_t     public.editors%rowtype;
begin
  if not public.is_admin() then raise exception 'Only admins can use View as' using errcode = '42501'; end if;
  if p_action not in ('start', 'check', 'stop') then raise exception 'Unknown action %', p_action; end if;
  if v_email = v_me then raise exception 'You can''t view as yourself'; end if;

  select * into v_t from public.editors where email = v_email;
  if p_action <> 'stop' then
    if v_t.email is null then raise exception 'No user has the email %', v_email; end if;
    if (v_t.role = 'admin' or v_t.owner) and not public.is_owner() then
      raise exception 'Only the owner can view as another admin' using errcode = '42501';
    end if;
  end if;

  -- 'check' runs on every page load while viewing as someone, so it isn't logged.
  if p_action in ('start', 'stop') then
    select name into v_by from public.editors where email = v_me;
    insert into public.account_changes (target, summary, changed_by_name)
      values (v_email, case when p_action = 'start' then 'View as started (read-only)' else 'View as ended' end, coalesce(v_by, v_me));
  end if;

  if v_t.email is null then return null; end if;
  return jsonb_build_object('email', v_t.email, 'name', v_t.name, 'role', v_t.role,
                            'active', v_t.active, 'pages', v_t.pages, 'owner', v_t.owner);
end $$;

revoke all on function public.admin_view_as(text, text) from public, anon;
grant execute on function public.admin_view_as(text, text) to authenticated;
