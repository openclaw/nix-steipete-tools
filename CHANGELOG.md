# Changelog

## Unreleased

**Highlights:** More reliable tool updates and refreshed packaged skill instructions.

- Restore automatic goplaces and imsg skill updates from OpenClaw's current upstream paths (thanks @SebTardif, #20).
- Bound Git and Nix maintenance commands, clean up their subprocesses on timeout or interruption, and allow deadline overrides or unlimited execution (thanks @SebTardif, #21; incorporates #22).
- Bound GitHub response-header waits while allowing valid slow response bodies to finish (thanks @SebTardif, #17).
- Refresh the CI installer while preserving upstream Nix, and build and run the Linux summarize package in CI.
