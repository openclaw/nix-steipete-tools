# Changelog

## Unreleased

**Highlights:** Restore automatic tool updates and refresh the packaged releases.

- Restore summarize updates with pnpm 11 lockfiles using the maintained reproducible dependency fetcher and Node 24, and show Nix diagnostics when hash discovery fails.
- Update summarize to 0.21.13, discrawl to 0.14.0, wacrawl to 0.3.11, Peekaboo to 4.3.3, poltergeist to 2.1.7, and imsg to 0.15.3.
- Preserve imsg's resource bundles and bridge helper, and Peekaboo's bundled Swift compatibility library when installing macOS release assets.
- Restore automatic goplaces and imsg skill updates from OpenClaw's current upstream paths (thanks @SebTardif, #20).
- Bound Git and Nix maintenance commands, clean up their subprocesses on timeout or interruption, and allow deadline overrides or unlimited execution (thanks @SebTardif, #21; incorporates #22).
- Bound GitHub response-header waits while allowing valid slow response bodies to finish (thanks @SebTardif, #17).
- Refresh nixpkgs and the CI installer while preserving upstream Nix; build package checks on all supported systems and test summarize article extraction.
