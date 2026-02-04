---
name: goplaces
description: Query Google Places API (New) via the goplaces CLI for text search, place details, resolve, and reviews. Use for human-friendly place lookup or JSON output for scripts.
homepage: https://github.com/steipete/goplaces
metadata: {"clawdbot":{"emoji":"📍","requires":{"bins":["goplaces"],"env":["GOOGLE_PLACES_API_KEY"]},"primaryEnv":"GOOGLE_PLACES_API_KEY","install":[{"id":"brew","kind":"brew","formula":"steipete/tap/goplaces","bins":["goplaces"],"label":"Install goplaces (brew)"}]}}
---

# goplaces

Modern Google Places API (New) CLI. Human output by default, `--json` for scripts.

Install
- Homebrew: `brew install steipete/tap/goplaces`

Config
- `GOOGLE_PLACES_API_KEY` required.
- Optional: `GOOGLE_PLACES_BASE_URL` for testing/proxying.

Common commands
- Search: `goplaces search "coffee" --open-now --min-rating 4 --limit 5`
- Bias: `goplaces search "pizza" --lat 40.8 --lng -73.9 --radius-m 3000`
- Pagination: `goplaces search "pizza" --page-token "NEXT_PAGE_TOKEN"`
- Resolve: `goplaces resolve "Soho, London" --limit 5`
- Details: `goplaces details <place_id> --reviews`
- JSON: `goplaces search "sushi" --json`

Closest place to me
- Get coordinates (prefer device location; otherwise ask for a location).
- Use nearby search with a tight radius and limit:
  - `goplaces nearby --lat <lat> --lng <lng> --radius-m 2000 --type cafe --limit 5`
- Pick the top result as the closest match unless distance is explicitly returned in output.

Directions (A → B)
- goplaces does NOT provide directions or ETA between two points.
- `goplaces route` finds places along a route (Routes API) — not a directions/ETA tool.
- For directions, generate a Google Maps link (no guessing):
  - Coordinates: `https://www.google.com/maps/dir/?api=1&origin=<lat>,<lng>&destination=<lat>,<lng>`
  - Place IDs: `https://www.google.com/maps/dir/?api=1&origin_place_id=<id>&destination_place_id=<id>`
- If the user asks for time/distance, provide the link and ask them to open it.

Notes
- `--no-color` or `NO_COLOR` disables ANSI color.
- Price levels: 0..4 (free → very expensive).
- Type filter sends only the first `--type` value (API accepts one).
