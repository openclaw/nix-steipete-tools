# nix-stepiete-tools

Nix packaging for Peter Steinberger's tools, with per-tool clawdbot plugins.

Darwin-only for now (aarch64-darwin).

## Usage (clawdbot plugins)

Each tool is a subflake under `tools/<tool>` and exposes `clawdbotPlugin`.

Example (summarize):

```nix
plugins = [
  { source = "github:clawdbot/nix-stepiete-tools?dir=tools/summarize"; }
];
```

## Skills sync (latest main)

To keep skills aligned with `clawdbot/clawdbot` without pinning:

```bash
scripts/sync-skills.sh
```

This pulls `main` (sparse checkout) and only updates files when contents change.

## Packages (root flake)

You can also import packages directly from the root flake:

```nix
inputs.nix-stepiete-tools.packages.${pkgs.system}.summarize
```
