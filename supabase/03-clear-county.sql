-- Liquid Trucking recruiting site: let editors clear a county's color completely.
-- Run once in Supabase after 02-admin.sql: SQL Editor -> New query -> paste all of this -> Run.
-- Safe to run again. Nothing existing is changed or deleted.

-- A "cleared" entry in the change log has no color and no hiring value.
alter table public.county_changes alter column level  drop not null;
alter table public.county_changes alter column hiring drop not null;

-- Removes counties from the map (back to "no color") and logs who did it and why.
create or replace function public.clear_county(p_fips text[], p_reason text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name  text;
  v_fips  text;
  v_prev  public.county_status%rowtype;
  v_count integer := 0;
begin
  if public.page_access('hiring-map') <> 'edit' then
    raise exception 'No edit access to the Hiring Map' using errcode = '42501';
  end if;
  select name into v_name from public.editors where email = lower(auth.jwt() ->> 'email');
  foreach v_fips in array p_fips loop
    select * into v_prev from public.county_status where fips = v_fips;
    if not found then continue; end if;
    delete from public.county_status where fips = v_fips;
    insert into public.county_changes (fips, level, hiring, note, prev_level, prev_hiring, reason, changed_by, changed_by_name)
      values (v_fips, null, null, '', v_prev.level, v_prev.hiring, coalesce(p_reason,''), auth.uid(), v_name);
    v_count := v_count + 1;
  end loop;
  return v_count;
end $$;

revoke all on function public.clear_county(text[], text) from public, anon;
grant execute on function public.clear_county(text[], text) to authenticated;
