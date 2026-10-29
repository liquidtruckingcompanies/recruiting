# Liquid Trucking Recruiting: Hiring Map

Public, view-only map of driver home-time zones for recruiting.

- Green: about 1 week out
- Yellow: 1–2 weeks (St. Louis runs 2)
- Orange: 2–3 weeks
- Red: 3+ weeks

Unless a driver lives firmly inside a green area, double-check with Planners before promising home time.

## How changes work

Every zone change is a new entry appended to `data/changes.json` (zone, color, hiring on/off, note, reason, who, and when).
The newest entry for each zone is what the map shows today, and the "View the map as of" date picker replays the file to show any past day.
The git history of that file is the permanent audit trail.

The map covers all 48 lower states and every county (3,108). Highway lines come from Natural Earth (public domain) 1:10m roads, in `data/roads.json`. State and county outlines come from the us-atlas package (U.S. Census Bureau data), in `data/states.json` and `data/counties.json`.

City dots and population bands come from GeoNames (places of 1,000+ people, via the all-the-cities package), stored in `data/cities.json` as `[name, state, lon, lat, population]`.

## Users and admins

Run `supabase/setup.sql` once, then `supabase/02-admin.sql` once (Supabase → SQL Editor).
After that, admins manage everything on `admin.html`: add users by email, set each person's level (User or Admin), turn accounts active or inactive, give per-page access (No access, View, View + edit), and choose whether each page is public or sign-in only.
People sign in on the Home page with an emailed 6-digit code. Every account change is listed under Account history.
New pages get a row in `public.site_pages` (id, name, public_view, sort) and a tile on the Home page with a matching `data-page`.

## Pages

- `index.html`: home page with editor sign-in and a name-only tile for each page.
- `hiring-map.html`: the county hiring map.
- `assets/site.css`: shared brand styles (header, footer, colors, fonts) for new pages.

To add a page, copy the header, sub-bar and footer from `index.html`, link `assets/site.css`, add the page to the nav on every page, and add a tile on the home page.
