# Liquid Trucking Operations Center

Internal site for the Liquid Trucking team: one sign-in, an Operations Dashboard, and a section per department (Recruiting first, with the Hiring Map), plus Admin and Product Feedback.

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

Run `supabase/setup.sql`, then `supabase/02-admin.sql`, then `supabase/03-clear-county.sql`, then `supabase/04-owner.sql`, then `supabase/05-feedback.sql`, then `supabase/06-feedback-email.sql` (after saving the Resend API key in Vault as `resend_api_key`), then `supabase/07-feedback-delete.sql` (lets the owner delete and restore feedback), then `supabase/08-faq.sql` (Driver FAQ tables, history and file storage) and `supabase/09-faq-load.sql` (the starting 115 FAQs), each once (Supabase → SQL Editor).
After that, admins manage everything on `admin.html`: add users by email, set each person's level (User or Admin), turn accounts active or inactive, give per-page access (No access, View, View + edit), and choose whether each page is public or sign-in only.
People sign in on the Home page with an emailed 6-digit code. Every account change is listed under Account history.
New pages get a row in `public.site_pages` (id, name, public_view, sort) and an entry in `LT_SITE` in `assets/nav.js`, which decides what shows: only the sign-in page before sign-in, then the departments and pages each account can see.

Every page also loads `assets/feedback.js`, which adds the "Got an idea or spot a problem?" button for signed-in users (set `window.ltSb` to the page's Supabase client; a page can add details with `window.ltFeedbackContext = () => ({...})`). Submissions, screenshots and videos (private `feedback` storage bucket) show up in `feedback.html`: admins get the Feedback Center (status with reasons, priority, internal notes, full history); everyone else sees their own submissions and status.

## Pages

Addresses are clean URLs (Cloudflare serves `/dashboard` from `dashboard.html` and `/recruiting/` from `recruiting/index.html`).

- `/` (`index.html`): sign-in. Signed-in users go straight to `?next=` or the dashboard.
- `/dashboard` (`dashboard.html`): Operations Dashboard, a tile per department the user can see, plus Feedback and Admin.
- `/recruiting/` (`recruiting/index.html`): Recruiting, a tile per page in the department.
- `/recruiting/hiring-map` (`recruiting/hiring-map.html`): the county hiring map. The old `/hiring-map.html` forwards here.
- `/admin`, `/feedback`: admin and the feedback center.
- `assets/nav.js`: the site map (`LT_SITE`: departments and pages), the shared header, breadcrumbs and footer, and the "who can see what" rules.
- `assets/portal.js`: sign-in helpers for the sign-in, dashboard and department pages.
- `assets/site.css`: shared brand styles.

To add a page: put the file in its department's folder, use `<div id="ltTop" data-current="<page id>" data-crumbs="Department|/dept/;Page name">` + `<script src="/assets/nav.js">` at the top of `<body>` and `<div id="ltFoot"></div><script>ltDrawShell()</script>` at the bottom, add it to `LT_SITE.pages` and its department's `pages` list, and add a matching row to `public.site_pages` so admins can grant access. To add a department, add it to `LT_SITE.departments` with a folder like `recruiting/index.html`.

## Driver FAQ

`recruiting/faq.html` (at `/recruiting/faq`). Every active user who can see the page reads it, searches it, opens any FAQ's history and can view the whole FAQ as of a past date. People with Edit access to Driver FAQ on the Admin page (and admins) can add, edit, hide, reorder and restore older versions; every change needs a reason and is saved in `faq_versions` with before and after. Only the owner can delete (soft delete, restorable from the Deleted tab). Each FAQ holds web links (open in a new tab after a "leaving the site" warning) and photos, videos and documents in the private `faq` storage bucket. All writes go through the `faq_*` functions in `08-faq.sql`.
