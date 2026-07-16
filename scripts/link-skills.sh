#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$target_root"

find "$repo_root/skills" "$repo_root/skills-private" -mindepth 3 -maxdepth 3 -name SKILL.md -print 2>/dev/null | sort | while read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  target="$target_root/$skill_name"

  if [[ -e "$target" && ! -L "$target" ]]; then
    printf 'Refusing to replace existing non-symlink: %s\n' "$target" >&2
    exit 1
  fi

  ln -sfn "$skill_dir" "$target"
  printf 'Linked %s -> %s\n' "$target" "$skill_dir"
done
