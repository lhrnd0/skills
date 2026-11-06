---
name: setup-project
description: "Set up this repo for agent work: today its issue tracking (shared or local mode; beads, GitHub, GitLab or markdown). Run once per repo, or again to switch or repair."
disable-model-invocation: true
---

# Setup Project

Entry point for per-repo agent setup. Nothing in a repo is configured until the user runs this skill.

## Process

1. Invoke the `setup-issue-tracker` skill and follow it through its final report.
2. Done when that skill's **Verify** step passes. Tell the user the project setup is complete.
