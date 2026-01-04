#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

# Mapping: tool -> upstream skill dir (relative to clawdbot repo)
declare -A SKILLS
SKILLS[summarize]="skills/summarize"
SKILLS[gogcli]="skills/gog"
SKILLS[camsnap]="skills/camsnap"
SKILLS[sonoscli]="skills/sonoscli"
SKILLS[bird]="skills/bird"
SKILLS[peekaboo]="skills/peekaboo"
SKILLS[sag]="skills/sag"
SKILLS[imsg]="skills/imsg"
SKILLS[oracle]="skills/oracle"

# Clone only the needed paths from latest main.
# Note: no pinning; this is explicitly "latest main".
git -c advice.detachedHead=false clone --depth 1 --filter=blob:none --sparse \
  https://github.com/clawdbot/clawdbot.git "${workdir}/clawdbot" >/dev/null

pushd "${workdir}/clawdbot" >/dev/null
  git sparse-checkout set "${SKILLS[@]}" >/dev/null
popd >/dev/null

updated=0
for tool in "${!SKILLS[@]}"; do
  src_dir="${workdir}/clawdbot/${SKILLS[$tool]}"
  dest_dir="${repo_root}/tools/${tool}/skills/$(basename "${SKILLS[$tool]}")"

  if [[ ! -d "${src_dir}" ]]; then
    echo "[sync-skills] missing upstream skill: ${SKILLS[$tool]} (skip)" >&2
    continue
  fi

  mkdir -p "${dest_dir}"

  # Copy only if content changed (avoid noisy commits).
  if ! cmp -s "${src_dir}/SKILL.md" "${dest_dir}/SKILL.md" 2>/dev/null; then
    cp "${src_dir}/SKILL.md" "${dest_dir}/SKILL.md"
    updated=1
    echo "[sync-skills] updated ${tool}" >&2
  fi

  # If upstream has extra files in the skill dir, sync them too.
  rsync -a --delete --exclude SKILL.md "${src_dir}/" "${dest_dir}/" >/dev/null
  if [[ -n "$(git -C "${repo_root}" status --porcelain "${dest_dir}" 2>/dev/null)" ]]; then
    updated=1
  fi

done

if [[ $updated -eq 0 ]]; then
  echo "[sync-skills] no changes" >&2
fi
