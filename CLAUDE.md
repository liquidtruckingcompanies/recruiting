# Notes for Claude

## Every site update gets a What's New entry

Whenever a change ships to the site (any PR that changes what people see or can do), add an entry at the TOP of
`entries` in `data/whats-new.json` in the same PR. The What's New page (`/whats-new`) reads that file; nobody can
edit it on the site, so this is the only way it gets updated.

- `id`: `YYYY-MM-DD-short-slug`, unique, never reused or renamed (people's "read" state and links use it).
- `date`: the day it ships, Central time. `area`: Hiring Map, Driver FAQ, Admin, Feedback, Sign-in, Site-wide, or a
  new department/page name. `type`: new, improved or fixed.
- `title`: a plain-English headline of what changed for the people using the site, not code names.
- `summary`: one or two sentences. `details`: short bullets (can be empty). `link`: the page to try it on.
- `refs`: the PR link (`{ "label": "PR #N", "href": "https://github.com/liquidtruckingcompanies/recruiting/pull/N" }`).
- Behind-the-scenes changes with nothing visible (refactors, README edits) don't need an entry. Fold small follow-up
  fixes into one entry for the same day when it reads better.
