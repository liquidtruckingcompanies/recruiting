-- Liquid Trucking Operations Center: the How It Works page (/how-it-works).
-- Run once in Supabase after 11-whats-new.sql: SQL Editor -> New query -> paste all of this -> Run. Safe to run again.
--
-- Adds How It Works to the Admin page's page list so admins can choose who sees it, like every other page.
-- It starts as admins only: "Public" is off and nobody has View access until an admin gives it on the Admin page.
-- Running this again never changes a setting an admin already made.
-- There is nothing to edit on the site: the content is written into how-it-works.html by Claude.

insert into public.site_pages (id, name, public_view, sort) values ('how-it-works', 'How It Works', false, 95)
on conflict (id) do nothing;

select id, name, public_view as public, sort from public.site_pages order by sort;
