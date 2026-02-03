---
name: goplaces
description: Google Places API (New) CLI and Go client.
homepage: https://github.com/steipete/goplaces
metadata: {"openclaw":{"emoji":"📍","requires":{"bins":["goplaces"],"env":["GOOGLE_PLACES_API_KEY"]},"primaryEnv":"GOOGLE_PLACES_API_KEY","install":[{"id":"brew","kind":"brew","formula":"steipete/tap/goplaces","bins":["goplaces"],"label":"Install goplaces (brew)"}]}}
---

# goplaces

Use `goplaces` for the Google Places API (New).

API key
- `GOOGLE_PLACES_API_KEY`

Quick start
- `goplaces search "coffee" --lat 40.8065 --lng -73.9719 --radius-m 3000 --limit 5`
- `goplaces autocomplete "cof" --session-token "goplaces-demo" --limit 5`
- `goplaces details <placeId> --photos --reviews`
- `goplaces nearby --lat 47.6062 --lng -122.3321 --radius-m 1500 --type cafe --limit 5`
- `goplaces route "coffee" --from "Seattle, WA" --to "Portland, OR"`

Output tips
- Use `--json` for machine output.
- Add `--no-color` when piping.

Notes
- Long flags accept `--flag=value` or `--flag value`.
- Routes API must be enabled for `route` searches.
