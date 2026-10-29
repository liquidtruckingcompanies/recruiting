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

Highway lines come from Natural Earth (public domain) 1:10m roads. State outlines come from the us-atlas package (U.S. Census Bureau data).

City dots and population bands come from GeoNames (places of 1,000+ people, via the all-the-cities package), stored in `data/cities.json` as `[name, state, lon, lat, population]`.

## Editors

Editing needs a Supabase account and a row in `public.editors`:
1. Supabase → Authentication → Users → Add user → Create new user, with the person's work email and a starting password, and "Auto Confirm User" checked.
2. SQL Editor: `insert into public.editors (email, name) values ('their.email@company.com', 'Their Name');`
To remove someone, delete their row from `editors` (and the user, if you like).

## Pages

- `index.html`: home page with editor sign-in and a name-only tile for each page.
- `hiring-map.html`: the county hiring map.
- `assets/site.css`: shared brand styles (header, footer, colors, fonts) for new pages.

To add a page, copy the header, sub-bar and footer from `index.html`, link `assets/site.css`, add the page to the nav on every page, and add a tile on the home page.
