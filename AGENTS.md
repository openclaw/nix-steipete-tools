# AGENTS.md — nix-openclaw-tools

This repo packages OpenClaw-adjacent CLI tools and plugin metadata. It is part of the public OpenClaw Nix packaging boundary, not Josh's private machine config.

## Boundary Model

- OpenClaw owns product/runtime behavior.
- nix-openclaw owns the batteries-included Nix module surface, runtime injection, launchd/systemd wiring, and package-contract checks.
- nix-openclaw-tools owns reproducible packages for tool CLIs and the plugin metadata/skills that describe them.
- nixos-config and other downstream machine repos should only choose hosts, secrets, accounts, and which plugins are enabled. If a downstream repo has to build a tool, copy a tool package, or hand-wire a tool into an agent PATH, fix this repo or nix-openclaw instead.

## Packaging Rules

- Packages must be Garnix-cacheable for supported systems. Do not rely on Homebrew, globally installed Node/Python, Xcode state outside Nix, or runtime `npm`/`npx`/`uvx`.
- Prefer upstream release assets when they exist. Build from source only when release assets do not exist or are not suitable.
- If a tool is a first-party OpenClaw battery, add/update package, plugin metadata, checks, and auto-update logic together.
- QMD belongs here when packaged for Nix OpenClaw. The package should provide the `qmd` CLI; nix-openclaw decides how to inject it into the OpenClaw runtime.
- Do not expose tools globally by policy from this repo. Export packages and plugin metadata; let nix-openclaw place them on the correct agent/runtime PATH.

## Automation

- `cmd/update-tools` is the release-asset updater. Keep it resilient: one upstream tool changing asset names should not silently rot the whole repo.
- QMD freshness should be checked by automation too. Josh should not have to remember a separate QMD bump path.
- `cmd/sync-skills` tracks OpenClaw skills from upstream main.
- Garnix should build package checks for every supported package/system after update commits.

## Workflow

- Trunk-based development on `main`.
- Keep commits small and logical.
- Run targeted package checks before committing; use CI/Garnix for expensive cross-platform proof.
