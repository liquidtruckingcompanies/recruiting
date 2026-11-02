# Liquid Trucking Recruiting: Hiring Map

Recruiting site for Liquid Trucking: home page, Hiring Map and admin.

Live at https://recruiting.liquidtrucking.io . It's hosted on Cloudflare (Worker "recruiting" with static assets), which redeploys automatically on every push to `main`. `.assetsignore` keeps README and SQL files off the live site.

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

Search uses the city list plus `data/zips.json` (`[zip, town, state, lon, lat]`, from the zipcodes package / free ZIP code database), which also supplies small-town names. Road distances are straight-line miles to the nearest line in `data/roads.json`.

City dots and population bands come from GeoNames (places of 1,000+ people, via the all-the-cities package), stored in `data/cities.json` as `[name, state, lon, lat, population]`.

## Users and admins

Run `supabase/setup.sql`, then `supabase/02-admin.sql`, then `supabase/03-clear-county.sql`, then `supabase/04-owner.sql`, then `supabase/05-feedback.sql`, each once (Supabase → SQL Editor).
After that, admins manage everything on `admin.html`: add users by email, set each person's level (User or Admin), turn accounts active or inactive, give per-page access (No access, View, View + edit), and choose whether each page is public or sign-in only.
People sign in on the Home page with an emailed 6-digit code. Every account change is listed under Account history.
New pages get a row in `public.site_pages` (id, name, public_view, sort), a Home tile with a matching `data-page`, and a hidden menu link with the same `data-page` on every page. `assets/nav.js` decides what shows: only Home before sign-in, then the pages each account can see.

Every page also loads `assets/feedback.js`, which adds the "Got an idea or spot a problem?" button for signed-in users (set `window.ltSb` to the page's Supabase client; a page can add details with `window.ltFeedbackContext = () => ({...})`). Submissions, screenshots and videos (private `feedback` storage bucket) show up in `feedback.html`: admins get the Feedback Center (status with reasons, priority, internal notes, full history); everyone else sees their own submissions and status.

## Pages

- `index.html`: home page with editor sign-in and a name-only tile for each page.
- `hiring-map.html`: the county hiring map.
- `assets/site.css`: shared brand styles (header, footer, colors, fonts) for new pages.

To add a page, copy the header, sub-bar and footer from `index.html`, link `assets/site.css`, add the page to the nav on every page, and add a tile on the home page.
