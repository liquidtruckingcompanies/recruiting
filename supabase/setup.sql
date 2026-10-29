-- Liquid Trucking Hiring Map: database setup.
-- Run once in Supabase: SQL Editor -> New query -> paste all of this -> Run.

-- People allowed to change counties. Add or remove rows to manage editors.
create table if not exists public.editors (
  email text primary key check (email = lower(email)),
  name  text not null,
  added_at timestamptz not null default now()
);

-- Current status of each county (FIPS code). Counties with no row have no color.
create table if not exists public.county_status (
  fips       text primary key,
  level      text not null check (level in ('green','yellow','orange','red')),
  hiring     boolean not null default true,
  note       text not null default '',
  updated_by_name text not null,
  updated_at timestamptz not null default now()
);

-- Every change, written only by set_county() below. Nobody can edit or delete these rows from the website.
create table if not exists public.county_changes (
  id          bigint generated always as identity primary key,
  fips        text not null,
  level       text not null check (level in ('green','yellow','orange','red')),
  hiring      boolean not null,
  note        text not null default '',
  prev_level  text,
  prev_hiring boolean,
  reason      text not null default '',
  changed_by  uuid,
  changed_by_name text not null,
  changed_at  timestamptz not null default now()
);
create index if not exists county_changes_at on public.county_changes (changed_at desc);

alter table public.editors        enable row level security;
alter table public.county_status  enable row level security;
alter table public.county_changes enable row level security;

-- Anyone can read the map and its history. Editor emails stay private.
drop policy if exists "public read status"  on public.county_status;
drop policy if exists "public read changes" on public.county_changes;
create policy "public read status"  on public.county_status  for select using (true);
create policy "public read changes" on public.county_changes for select using (true);
drop policy if exists "editors read self" on public.editors;
create policy "editors read self" on public.editors for select to authenticated
  using (email = lower(auth.jwt() ->> 'email'));
-- No insert/update/delete policies: all writes go through set_county().

-- The only way to change a county. Checks the signed-in email against editors and stamps who and when.
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
  select name into v_name from public.editors where email = v_email;
  if v_name is null then
    raise exception 'Not an approved editor' using errcode = '42501';
  end if;
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

revoke all on function public.set_county(text[], text, boolean, text, text) from public, anon;
grant execute on function public.set_county(text[], text, boolean, text, text) to authenticated;

-- Starting colors: each county takes the color of the zone its center fell in on the original map.
insert into public.county_status (fips, level, hiring, note, updated_by_name, updated_at)
select s.fips, s.level, true, '', 'Initial setup', '2026-10-29T12:00:00Z'
from (values
  ('19013','green'),
  ('19081','orange'),
  ('31125','yellow'),
  ('19031','green'),
  ('31035','yellow'),
  ('19089','orange'),
  ('19181','green'),
  ('19185','yellow'),
  ('19127','green'),
  ('31093','yellow'),
  ('19069','orange'),
  ('31143','yellow'),
  ('19055','green'),
  ('31159','green'),
  ('17201','green'),
  ('19019','green'),
  ('19187','green'),
  ('31137','orange'),
  ('31039','green'),
  ('19015','green'),
  ('17037','green'),
  ('19159','yellow'),
  ('19165','green'),
  ('19175','yellow'),
  ('19003','green'),
  ('19123','green'),
  ('19001','green'),
  ('17093','green'),
  ('31167','green'),
  ('31179','green'),
  ('29061','yellow'),
  ('17099','green'),
  ('19079','green'),
  ('19083','green'),
  ('19093','green'),
  ('19125','green'),
  ('19157','green'),
  ('19153','green'),
  ('19121','green'),
  ('19177','yellow'),
  ('20085','yellow'),
  ('19087','yellow'),
  ('31059','yellow'),
  ('29049','yellow'),
  ('17063','green'),
  ('19033','orange'),
  ('31155','green'),
  ('19197','green'),
  ('31151','green'),
  ('31019','orange'),
  ('19105','green'),
  ('19027','green'),
  ('19073','green'),
  ('19063','orange'),
  ('31047','orange'),
  ('19131','orange'),
  ('19137','green'),
  ('19017','orange'),
  ('19183','green'),
  ('19141','orange'),
  ('20201','yellow'),
  ('19151','green'),
  ('19051','yellow'),
  ('31099','orange'),
  ('19047','green'),
  ('19075','green'),
  ('19009','green'),
  ('31133','green'),
  ('31185','yellow'),
  ('31077','yellow'),
  ('19113','green'),
  ('19107','green'),
  ('19161','green'),
  ('29025','yellow'),
  ('19193','green'),
  ('19155','green'),
  ('19139','green'),
  ('19129','green'),
  ('19143','orange'),
  ('19065','orange'),
  ('19099','green'),
  ('29063','green'),
  ('31097','green'),
  ('17141','green'),
  ('31147','green'),
  ('17149','yellow'),
  ('19057','yellow'),
  ('31011','yellow'),
  ('20043','green'),
  ('31079','yellow'),
  ('19169','green'),
  ('19149','orange'),
  ('19007','yellow'),
  ('31131','green'),
  ('17111','green'),
  ('17089','green'),
  ('46127','green'),
  ('29177','yellow'),
  ('29510','yellow'),
  ('20013','green'),
  ('29163','yellow'),
  ('17083','yellow'),
  ('19071','green'),
  ('19053','yellow'),
  ('19191','orange'),
  ('31177','green'),
  ('29107','yellow'),
  ('31037','green'),
  ('19041','orange'),
  ('20149','yellow'),
  ('18089','green'),
  ('29095','yellow'),
  ('19103','green'),
  ('17061','yellow'),
  ('31055','green'),
  ('29005','green'),
  ('29075','green'),
  ('29021','yellow'),
  ('19095','green'),
  ('31053','green'),
  ('19011','green'),
  ('31139','yellow'),
  ('20087','yellow'),
  ('31109','green'),
  ('31081','yellow'),
  ('31119','yellow'),
  ('31121','yellow'),
  ('31025','green'),
  ('19109','orange'),
  ('17119','yellow'),
  ('19163','green'),
  ('29113','yellow'),
  ('31135','red'),
  ('29047','yellow'),
  ('19085','green'),
  ('19115','green'),
  ('19145','green'),
  ('20005','yellow'),
  ('20117','yellow'),
  ('20131','yellow'),
  ('31051','green'),
  ('29081','yellow'),
  ('31067','green'),
  ('19043','orange'),
  ('19091','orange'),
  ('20045','yellow'),
  ('31043','green'),
  ('17103','green'),
  ('31127','green'),
  ('17031','green'),
  ('17091','green'),
  ('29227','green'),
  ('29147','green'),
  ('20103','yellow'),
  ('19101','yellow'),
  ('31049','red'),
  ('29189','yellow'),
  ('19167','orange'),
  ('31173','green'),
  ('19049','green'),
  ('31153','green'),
  ('20209','yellow'),
  ('19029','green'),
  ('20091','yellow'),
  ('19133','green'),
  ('29165','yellow'),
  ('31023','green'),
  ('31169','yellow'),
  ('19025','green'),
  ('17007','green'),
  ('19097','green'),
  ('19037','orange'),
  ('19077','green'),
  ('19189','orange'),
  ('19059','orange'),
  ('17197','green'),
  ('19111','yellow'),
  ('19173','green'),
  ('29087','green'),
  ('19023','green'),
  ('31027','yellow'),
  ('31021','green'),
  ('31095','yellow'),
  ('31111','red'),
  ('17097','green'),
  ('31141','yellow'),
  ('19067','orange'),
  ('17013','yellow'),
  ('19195','orange'),
  ('19035','green'),
  ('19147','orange'),
  ('19171','green'),
  ('19021','orange'),
  ('19119','orange'),
  ('29003','green'),
  ('20161','yellow'),
  ('19005','orange'),
  ('19045','green'),
  ('29183','yellow'),
  ('17043','green'),
  ('31101','red')
) as s(fips, level)
on conflict (fips) do nothing;

insert into public.county_changes (fips, level, hiring, note, reason, changed_by_name, changed_at)
select fips, level, hiring, note, 'Starting counties from the original zone map', 'Initial setup', updated_at
from public.county_status
where updated_by_name = 'Initial setup'
  and not exists (select 1 from public.county_changes c where c.fips = county_status.fips);

-- Editors: replace with your team, then run again whenever someone joins or leaves.
-- insert into public.editors (email, name) values
--   ('jason@example.com', 'Jason Eisenman')
-- on conflict (email) do update set name = excluded.name;
