-- Liquid Trucking Operations Center: the What's New page (/whats-new).
-- Run once in Supabase after 10-view-as.sql: SQL Editor -> New query -> paste all of this -> Run. Safe to run again.
--
-- Adds What's New to the Admin page's page list so admins can choose who sees it, like every other page.
-- It starts as admins only: "Public" is off and nobody has View access until an admin gives it on the Admin page.
-- Running this again never changes a setting an admin already made.
-- There is nothing to edit on the site: the updates live in data/whats-new.json, written by Claude with each update.

insert into public.site_pages (id, name, public_view, sort) values ('whats-new', 'What''s New', false, 90)
on conflict (id) do nothing;

select id, name, public_view as public, sort from public.site_pages order by sort;
