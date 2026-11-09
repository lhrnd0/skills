---
name: setup-issue-tracker
description: "Set up a repo's issue tracking: the mode (shared or local) and the tracker (beads, GitHub, GitLab, markdown). Use when /setup-project runs, or the user asks to set up, switch, or repair a repo's issue tracker."
---

# Setup Issue Tracker

Configure where this repo's issues live and where the agent-facing tracker docs live. Two independent choices:

- **Mode** decides where the config lives. **shared**: committed, visible to collaborators. **local**: on this machine only, kept out of git with `.git/info/exclude`.
- **Tracker** decides where the issues live: `beads`, `github`, `gitlab` or `markdown`. Each has a procedure file in this folder: [beads.md](beads.md), [github.md](github.md), [gitlab.md](gitlab.md), [markdown.md](markdown.md).

This is a prompt-driven skill, not a script. Explore, present what you found, confirm with the user, then write.

## Layout per mode

| | shared | local |
|---|---|---|
| `## Agents workflow` block | `AGENTS.md` | `AGENTS.override.md` |
| Import at the top | `CLAUDE.md`: `@AGENTS.md` | `AGENTS.override.md`: `@AGENTS.md`; `CLAUDE.local.md`: `@AGENTS.override.md` |
| Tracker docs | `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md` | `.issue-tracker/issue-tracker.md`, `.issue-tracker/triage-labels.md` |
| Excluded from git | nothing | `AGENTS.override.md`, `CLAUDE.local.md`, `.issue-tracker/`, plus the tracker's own lines |

`issue-tracker.md` opens with frontmatter recording the choice (`mode`, `tracker`, and `role` for beads). That frontmatter is the marker of a configured repo.

## Process

### 1. Explore

Read whatever exists; assume nothing:

- `git rev-parse --show-toplevel` and `git rev-parse --git-common-dir`. Not a git repo → stop and tell the user: local mode needs `.git/info/exclude`, and every tracker here assumes git.
- `git remote -v`: which hosts (GitHub, GitLab, other), and which remotes belong to the user.
- An existing setup: `docs/agents/issue-tracker.md` or `.issue-tracker/issue-tracker.md` and its frontmatter; an older one without frontmatter counts too.
- Root instruction files: `AGENTS.md`, `CLAUDE.md`, `AGENTS.override.md`, `CLAUDE.local.md`, and legacy `AGENTS.local.md`.
- Existing imports, `## Agents workflow` blocks, and legacy `## Agent skills` blocks in those files.
- `<git-common-dir>/info/exclude`.
- Tracker signs: `.beads/`, `.scratch/`, an issue-tracker line in the repo's own docs, open issues on the host (`gh issue list --limit 5` for GitHub, `glab issue list --per-page 5` for GitLab).
- Is the `triage` skill installed (a `triage` skill folder, or `triage` among your available skills)? Use this finding in step 4.

### 2. Present findings, then ask the mode

Before any question or write, report the tracker this repo uses today:

- **Tracker**: `beads`, `github`, `gitlab`, `markdown`, several, or none. Name the evidence for each (`.beads/` exists, 12 open GitHub issues, a docs line).
- **Setup**: the `issue-tracker.md` path, its frontmatter (`mode`, `tracker`, `role`), or none.

Then summarise what else is present and what is missing. Existing setup → ask whether to keep it, repair it, or switch mode or tracker (see **Switching**).

Then ask the mode. Lead with the recommendation, and explain both choices first:

> **shared**: the tracker docs and the `## Agents workflow` block are committed. Every collaborator's agent reads the same rules. Use it for repos you own or where the team agrees to these files.
>
> **local**: everything stays on this machine, hidden through `.git/info/exclude`; the repo's tracked files do not change. Use it for repos where you cannot or do not want to commit agent config: someone else's project, a work repo, a fork. The config does not travel: on another machine, run the setup again.

Recommend **shared** when the user owns the repo, **local** otherwise.

### 3. Ask the tracker

Explain the four, then recommend:

- **beads**: a local issue database (`bd`) with dependencies, `bd ready` and epics. Can sync between machines through a git remote.
- **github**: GitHub Issues through `gh`.
- **gitlab**: GitLab Issues through `glab`.
- **markdown**: one file per issue under `.scratch/`. For quick work with no tooling.

Repo already tracks work somewhere (its docs name GitHub Issues, open issues exist, `.beads/` or `.scratch/` exists) → propose that. Otherwise propose `beads`.

Then read the chosen tracker's procedure file and run its **Explore** and **Ask** sections.

### 4. Optional triage skill and labels

If `triage` is missing, offer [Matt Pocock’s triage skill](https://github.com/mattpocock/skills/tree/main/skills/engineering/triage).
Explain that it helps classify issues and prepare briefs for agents. Ask whether the user wants to install it.
If they accept, use the available skill installer and include the skill’s supporting files.
Respect the chosen mode: keep a local installation outside tracked project files or exclude its new paths.
Verify that `triage` is available before configuring its labels.
If they decline or installation fails, skip label configuration and continue tracker setup.

When `triage` is available, ask:

> Do you want to keep the default triage labels? (recommended: **yes**)

The defaults are the five canonical roles, each label equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Only on **no**, collect the overrides so `triage` reuses existing labels instead of creating duplicates.

### 5. Draft and confirm

Show the user a draft of every write:

- The `## Agents workflow` block and the file it goes in.
- The imports at the top of each instruction file, plus any legacy migration.
- `issue-tracker.md` with its frontmatter, from the tracker's template in [templates/](templates/).
- `triage-labels.md` (only when step 4 configured labels), from [templates/triage-labels.md](templates/triage-labels.md).
- The exclude lines (local).
- The tracker commands from its **Commands** section.

Let them edit before anything is written.

### 6. Write

**shared**: write the block to `AGENTS.md`. Create `CLAUDE.md` if absent, with `@AGENTS.md` as its first line.

**local**: write the block to `AGENTS.override.md`, with `@AGENTS.md` as its first line.
Create `CLAUDE.local.md` if absent, with `@AGENTS.override.md` as its first line.
Keep the shared `AGENTS.md` and `CLAUDE.md` unchanged.
If `AGENTS.md` is absent, retain the import without creating a shared file.

For each required import, move an existing copy to the first line or add it there.
Keep exactly one copy of that import and preserve other content.

Update an existing `## Agents workflow` block in place.
Rename a legacy `## Agent skills` block to `## Agents workflow` when updating it.
For older shared setups, move the tracker instructions from `CLAUDE.md` to `AGENTS.md`.
For older local setups, move them from `AGENTS.local.md` to `AGENTS.override.md`.
Replace `@AGENTS.local.md` in `CLAUDE.local.md` with the required import.
Merge tracker instructions into one block in the destination.
Preserve unrelated sections, including any inside a legacy block.
Remove the old tracker instructions after moving them.
If `AGENTS.local.md` becomes empty, remove it and its exclude line.
Otherwise, preserve it and its exclusion. Import it once below `@AGENTS.md` in `AGENTS.override.md`.

The block:

```markdown
## Agents workflow

### Issue tracker

[one-line summary of where issues are tracked]. See `<docs-dir>/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `<docs-dir>/triage-labels.md`.
```

`<docs-dir>` is `docs/agents` (shared) or `.issue-tracker` (local). Include the `### Triage labels` sub-block, and write `triage-labels.md`, only when step 4 configured labels.

Write the docs from the templates: drop each `<!-- seed: ... -->` line, add the frontmatter the tracker procedure gives, and adjust the text to this repo (names, remotes).

Then run the tracker's **Commands** and **Labels** sections.

**local**: append each missing line to `<git-common-dir>/info/exclude` (the common dir, so every worktree shares it): `AGENTS.override.md`, `CLAUDE.local.md`, `.issue-tracker/`, plus the tracker's **Exclude lines**, including any new files its commands produced. Never add a line that is already there.

### 7. Verify

Done when every check passes:

- The tracker instructions exist once: in `AGENTS.md` (shared) or `AGENTS.override.md` (local).
- **shared**: `CLAUDE.md` starts with `@AGENTS.md`, present exactly once.
- **local**: `AGENTS.override.md` starts with `@AGENTS.md`, present exactly once.
- **local**: `CLAUDE.local.md` starts with `@AGENTS.override.md`, present exactly once.
- Imports resolve when their targets exist; no import cycle exists.
- Existing unrelated content remains intact after imports and legacy migrations.
- `issue-tracker.md` frontmatter matches the choice.
- **local**: `git status --porcelain` lists none of the written paths, and `git check-ignore` prints each one.
- **shared**: `git status --porcelain` lists only the written paths and the tracker's setup files.
- The tracker procedure's **Verify** checks pass.

### 8. Report

Tell the user what was written and where, which commands ran, and that skills like `to-tickets`, `triage`, `to-spec` and `wayfinder` now read these files. Shared mode: the new files are ready to commit; committing is the user's call. Local mode: report `AGENTS.override.md` and the import chain from `CLAUDE.local.md` through it to `AGENTS.md`.

## Switching

Mode switch, same tracker:

- **shared → local**: move the tracker docs to `.issue-tracker/` and the tracker instructions to `AGENTS.override.md`.
  Apply the local imports and exclude lines. Preserve unrelated shared instructions.
  Explain that removing tracked tracker instructions and docs requires a commit.
- **local → shared**: move the tracker docs to `docs/agents/` and the tracker instructions to `AGENTS.md`.
  Apply the shared import. Remove local imports and files only when no unrelated content needs them.
  Remove this skill's exclude lines only for paths no longer used locally.

Then re-run the tracker procedure, since some trackers change per mode (beads: stealth init and sync remote; markdown: `.scratch/` tracking). Tracker switch: run the new tracker's procedure from step 3; issues already in the old tracker stay there, so tell the user before moving on.
