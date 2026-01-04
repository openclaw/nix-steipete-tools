# nix-steipete-tools

> Core tools for clawdbot. Batteries included. Always fresh.

Nix packaging for [Peter Steinberger's](https://github.com/steipete) tools, with per-tool clawdbot plugins. Part of the [nix-clawdbot](https://github.com/clawdbot/nix-clawdbot) ecosystem.

Darwin/aarch64 only (Apple Silicon Macs).

## Why this exists

These tools are essential for a capable clawdbot instance - screen capture, camera access, TTS, messaging. Packaging them as Nix flakes with clawdbot plugin metadata means:

- **Reproducible**: Pinned versions, no Homebrew drift
- **Declarative**: Add a plugin, `home-manager switch`, done
- **Fresh**: CI keeps tools and skills at latest automatically
- **Integrated**: Skills teach your bot how to use each tool

## What's included

| Tool | What it does |
|------|--------------|
| [**summarize**](https://summarize.sh) | Summarize URLs, PDFs, images, audio, YouTube |
| [**gogcli**](https://gogcli.sh) | Google Workspace CLI (Gmail, Calendar, Drive, Contacts, Sheets, Docs) |
| [**camsnap**](https://camsnap.ai) | Capture snapshots/clips from RTSP/ONVIF cameras |
| [**sonoscli**](https://sonoscli.sh) | Control Sonos speakers |
| [**bird**](https://bird.fast) | X/Twitter CLI (read, search, post) |
| [**peekaboo**](https://peekaboo.boo) | macOS screen capture + UI automation |
| **poltergeist** | File watcher with auto-rebuild |
| [**sag**](https://sag.sh) | ElevenLabs text-to-speech |
| [**imsg**](https://imsg.to) | iMessage/SMS CLI |
| [**oracle**](https://askoracle.dev) | Bundle prompts + files for AI queries |

## Usage (as clawdbot plugins)

Each tool is a subflake under `tools/<tool>/` exporting `clawdbotPlugin`. Point your nix-clawdbot config at the tool you want:

```nix
programs.clawdbot.plugins = [
  { source = "github:clawdbot/nix-steipete-tools?dir=tools/camsnap"; }
  { source = "github:clawdbot/nix-steipete-tools?dir=tools/peekaboo"; }
  { source = "github:clawdbot/nix-steipete-tools?dir=tools/summarize"; }
];
```

Each plugin bundles:
- The tool binary (on PATH)
- A skill (SKILL.md) so your bot knows how to use it
- Any required state dirs / env declarations

## Usage (packages only)

If you just want the binaries without the plugin wrapper:

```nix
inputs.nix-steipete-tools.url = "github:clawdbot/nix-steipete-tools";

# Then use:
inputs.nix-steipete-tools.packages.aarch64-darwin.camsnap
inputs.nix-steipete-tools.packages.aarch64-darwin.peekaboo
# etc.
```

## Skills syncing

Skills are vendored from [clawdbot/clawdbot](https://github.com/clawdbot/clawdbot) main branch. No pinning - we track latest.

```bash
scripts/sync-skills.sh
```

Pulls latest main via sparse checkout, only updates files when contents actually change.

## Tool updates

Tools track upstream GitHub releases directly (not Homebrew).

```bash
scripts/update-tools.sh
```

Fetches latest release versions/URLs/hashes and updates the Nix expressions. Oracle uses pnpm and auto-derives its hash via build mismatch.

## CI

| Workflow | Schedule | What it does |
|----------|----------|--------------|
| **sync-skills** | Every 30 min | Pulls latest skills from clawdbot main |
| **update-tools** | Every 10 min | Checks for new tool releases |
| **Garnix** | On push | Builds all packages via `checks.*` |

Automated PRs keep everything fresh without manual intervention.

## License

Tools are packaged as-is from upstream. See individual tool repos for their licenses.

Nix packaging: MIT
