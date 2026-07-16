#!/usr/bin/env bash
set -euo pipefail

find skills skills-private -mindepth 3 -maxdepth 3 -name SKILL.md -print 2>/dev/null | sort | while read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  printf '%s\t%s\n' "$skill_name" "$skill_dir"
done
