-- Liquid Trucking Operations Center: let the site OWNER delete feedback items (and restore them).
-- Run once in Supabase after 06-feedback-email.sql: SQL Editor -> New query -> paste all of this -> Run. Safe to run again.
-- "Delete" moves an item to a Deleted list that only the owner can see; nothing is erased, so it can be restored.

alter table public.feedback add column if not exists deleted_at      timestamptz;
alter table public.feedback add column if not exists deleted_by_name text;
alter table public.feedback add column if not exists delete_reason   text;

-- History can now record deletes and restores.
alter table public.feedback_events drop constraint if exists feedback_events_kind_check;
alter table public.feedback_events add constraint feedback_events_kind_check
  check (kind in ('created','status','priority','note','deleted','restored'));

-- Deleted items disappear for everyone (admins and the person who sent it) except the owner.
drop policy if exists "feedback read" on public.feedback;
create policy "feedback read" on public.feedback for select to authenticated
  using (
    (deleted_at is null and (public.is_admin() or submitted_email = lower(auth.jwt() ->> 'email')))
    or (deleted_at is not null and public.is_owner())
  );

create or replace function public.feedback_delete(p_ids bigint[], p_reason text)
returns integer language plpgsql security definer set search_path = public as $$
declare v_by text; v_n integer;
begin
  if not public.is_owner() then raise exception 'Only the site owner can delete feedback' using errcode = '42501'; end if;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  with d as (
    update public.feedback set deleted_at = now(), deleted_by_name = v_by, delete_reason = nullif(trim(coalesce(p_reason,'')), ''), updated_at = now()
    where id = any(p_ids) and deleted_at is null returning id
  ), ev as (
    insert into public.feedback_events (feedback_id, kind, body, by_name)
    select id, 'deleted', coalesce(trim(p_reason), ''), v_by from d returning 1
  ) select count(*) into v_n from ev;
  return v_n;
end $$;

create or replace function public.feedback_restore(p_ids bigint[])
returns integer language plpgsql security definer set search_path = public as $$
declare v_by text; v_n integer;
begin
  if not public.is_owner() then raise exception 'Only the site owner can restore feedback' using errcode = '42501'; end if;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  with r as (
    update public.feedback set deleted_at = null, deleted_by_name = null, delete_reason = null, updated_at = now()
    where id = any(p_ids) and deleted_at is not null returning id
  ), ev as (
    insert into public.feedback_events (feedback_id, kind, by_name) select id, 'restored', v_by from r returning 1
  ) select count(*) into v_n from ev;
  return v_n;
end $$;

revoke all on function public.feedback_delete(bigint[], text) from public, anon;
revoke all on function public.feedback_restore(bigint[]) from public, anon;
grant execute on function public.feedback_delete(bigint[], text) to authenticated;
grant execute on function public.feedback_restore(bigint[]) to authenticated;
