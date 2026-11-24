---
name: setup-project
description: "Set up a repo for agent work with Backlog.md, GitHub, GitLab or markdown issue tracking in shared or local mode. Use again to switch or repair the setup."
disable-model-invocation: true
---

# Setup Project

Entry point for per-repo agent setup. Nothing in a repo is configured until the user runs this skill.

## Process

1. Invoke the `setup-issue-tracker` skill and follow it through its final report.
2. Done when that skill's **Verify** step passes. Tell the user the project setup is complete.
