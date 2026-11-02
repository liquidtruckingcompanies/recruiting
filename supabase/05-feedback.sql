-- Liquid Trucking recruiting site: product feedback (button on every page + Feedback Center).
-- Run once in Supabase after 04-owner.sql: SQL Editor -> New query -> paste all of this -> Run.
-- Safe to run again. Nothing existing is changed or deleted.

-- 1. Submissions. Written only through submit_feedback(); status/priority only through the admin functions below.
create table if not exists public.feedback (
  id          bigint generated always as identity primary key,
  kind        text not null check (kind in ('idea','bug','other')),
  message     text not null check (length(message) between 1 and 5000),
  page        text not null default '',
  context     jsonb not null default '{}'::jsonb,
  attachments jsonb not null default '[]'::jsonb,   -- [{path, name, type, size}]
  status      text not null default 'new'
              check (status in ('new','triage','planned','in_progress','shipped','wont_fix','duplicate','needs_info')),
  priority    text check (priority in ('low','medium','high','critical')),
  submitted_by    uuid,
  submitted_email text not null,
  submitted_name  text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists feedback_created on public.feedback (created_at desc);

-- 2. History: every status change, priority change and internal note. Admins only; never edited or deleted.
create table if not exists public.feedback_events (
  id          bigint generated always as identity primary key,
  feedback_id bigint not null references public.feedback(id),
  kind        text not null check (kind in ('created','status','priority','note')),
  from_value  text,
  to_value    text,
  body        text not null default '',
  by_name     text not null,
  at          timestamptz not null default now()
);
create index if not exists feedback_events_item on public.feedback_events (feedback_id, at);

alter table public.feedback        enable row level security;
alter table public.feedback_events enable row level security;

-- People see their own submissions (status only, no notes); admins see everything.
drop policy if exists "feedback read" on public.feedback;
create policy "feedback read" on public.feedback for select to authenticated
  using (public.is_admin() or submitted_email = lower(auth.jwt() ->> 'email'));
drop policy if exists "feedback events admins" on public.feedback_events;
create policy "feedback events admins" on public.feedback_events for select to authenticated
  using (public.is_admin());

-- 3. Submitting: any active user on the site.
create or replace function public.submit_feedback(p_kind text, p_message text, p_page text, p_context jsonb, p_attachments jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := lower(auth.jwt() ->> 'email');
  v_name  text;
  v_id    bigint;
begin
  select name into v_name from public.editors where email = v_email and active;
  if v_name is null then raise exception 'Only active users can send feedback' using errcode = '42501'; end if;
  if coalesce(trim(p_message),'') = '' then raise exception 'Please write a message'; end if;
  if jsonb_array_length(coalesce(p_attachments,'[]'::jsonb)) > 5 then raise exception 'Up to 5 attachments'; end if;
  insert into public.feedback (kind, message, page, context, attachments, submitted_by, submitted_email, submitted_name)
    values (p_kind, trim(p_message), coalesce(p_page,''), coalesce(p_context,'{}'::jsonb), coalesce(p_attachments,'[]'::jsonb), auth.uid(), v_email, v_name)
    returning id into v_id;
  insert into public.feedback_events (feedback_id, kind, to_value, by_name) values (v_id, 'created', 'new', v_name);
  return v_id;
end $$;

-- 4. Admin actions. Each is logged in feedback_events.
create or replace function public.feedback_set_status(p_id bigint, p_status text, p_reason text)
returns void language plpgsql security definer set search_path = public as $$
declare v_by text; v_prev text;
begin
  if not public.is_admin() then raise exception 'Admins only' using errcode = '42501'; end if;
  if coalesce(trim(p_reason),'') = '' then raise exception 'Please give a reason for the status change'; end if;
  select status into v_prev from public.feedback where id = p_id;
  if v_prev is null then raise exception 'Feedback % not found', p_id; end if;
  if v_prev = p_status then return; end if;
  update public.feedback set status = p_status, updated_at = now() where id = p_id;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  insert into public.feedback_events (feedback_id, kind, from_value, to_value, body, by_name) values (p_id, 'status', v_prev, p_status, trim(p_reason), v_by);
end $$;

create or replace function public.feedback_set_priority(p_id bigint, p_priority text)
returns void language plpgsql security definer set search_path = public as $$
declare v_by text; v_prev text; v_found boolean;
begin
  if not public.is_admin() then raise exception 'Admins only' using errcode = '42501'; end if;
  select true, priority into v_found, v_prev from public.feedback where id = p_id;
  if v_found is null then raise exception 'Feedback % not found', p_id; end if;
  if v_prev is not distinct from nullif(p_priority,'') then return; end if;
  update public.feedback set priority = nullif(p_priority,''), updated_at = now() where id = p_id;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  insert into public.feedback_events (feedback_id, kind, from_value, to_value, by_name) values (p_id, 'priority', v_prev, nullif(p_priority,''), v_by);
end $$;

create or replace function public.feedback_add_note(p_id bigint, p_body text)
returns void language plpgsql security definer set search_path = public as $$
declare v_by text;
begin
  if not public.is_admin() then raise exception 'Admins only' using errcode = '42501'; end if;
  if coalesce(trim(p_body),'') = '' then raise exception 'Note is empty'; end if;
  if not exists (select 1 from public.feedback where id = p_id) then raise exception 'Feedback % not found', p_id; end if;
  update public.feedback set updated_at = now() where id = p_id;
  select name into v_by from public.editors where email = lower(auth.jwt() ->> 'email');
  insert into public.feedback_events (feedback_id, kind, body, by_name) values (p_id, 'note', trim(p_body), v_by);
end $$;

revoke all on function public.submit_feedback(text, text, text, jsonb, jsonb) from public, anon;
revoke all on function public.feedback_set_status(bigint, text, text) from public, anon;
revoke all on function public.feedback_set_priority(bigint, text) from public, anon;
revoke all on function public.feedback_add_note(bigint, text) from public, anon;
grant execute on function public.submit_feedback(text, text, text, jsonb, jsonb) to authenticated;
grant execute on function public.feedback_set_status(bigint, text, text) to authenticated;
grant execute on function public.feedback_set_priority(bigint, text) to authenticated;
grant execute on function public.feedback_add_note(bigint, text) to authenticated;

-- 5. Private file storage for screenshots and videos (50 MB per file).
--    Files go in a folder named after the sender's user id; senders can read their own, admins can read all.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('feedback', 'feedback', false, 52428800, array['image/*','video/*'])
on conflict (id) do nothing;

drop policy if exists "feedback upload own folder" on storage.objects;
create policy "feedback upload own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'feedback' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "feedback read own or admin" on storage.objects;
create policy "feedback read own or admin" on storage.objects for select to authenticated
  using (bucket_id = 'feedback' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
