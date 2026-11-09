---
name: setup-issue-tracker
description: "Set up a repo's issue tracking: the mode (shared or local) and the tracker (beads, GitHub, GitLab, markdown). Use when /setup-project runs, or the user asks to set up, switch, or repair a repo's issue tracker."
---

# Setup Issue Tracker

Configure where this repo's issues live and where its issue tracking guidance lives. Two independent choices:

- **Mode** decides where the config lives. **shared**: committed, visible to collaborators. **local**: on this machine only, kept out of git with `.git/info/exclude`.
- **Tracker** decides where the issues live: `beads`, `github`, `gitlab` or `markdown`. Each has a procedure file in this folder: [beads.md](beads.md), [github.md](github.md), [gitlab.md](gitlab.md), [markdown.md](markdown.md).

This is a prompt-driven skill, not a script. Explore, present what you found, confirm with the user, then write.

## Layout per mode

| | shared | local |
|---|---|---|
| `## Agents workflow` block | `AGENTS.md` | `AGENTS.override.md` |
| Import at the top | `CLAUDE.md`: `@AGENTS.md` | `AGENTS.override.md`: `@AGENTS.md`; `CLAUDE.local.md`: `@AGENTS.override.md` |
| Contribution guide | `CONTRIBUTING.md` | `.docs-local/CONTRIBUTING.md` |
| Excluded from git | nothing | `AGENTS.override.md`, `CLAUDE.local.md`, `.docs-local/`, plus the tracker's own lines |

In both modes, a contribution guide section identifies the tracker and the beads role when applicable.
Triage labels belong beneath that section.
Its location identifies the mode; existing prose is sufficient to recognize a configured repo.

## Process

### 1. Explore

Read whatever exists; assume nothing:

- `git rev-parse --show-toplevel` and `git rev-parse --git-common-dir`. Not a git repo → stop and tell the user: local mode needs `.git/info/exclude`, and every tracker here assumes git.
- `git remote -v`: which hosts (GitHub, GitLab, other), and which remotes belong to the user.
- Existing issue tracking guidance in `CONTRIBUTING.md` and `.docs-local/CONTRIBUTING.md`, including sections named Issues, Workflow, or Development.
- Legacy tracker files: `.issue-tracker/issue-tracker.md` or `docs/agents/issue-tracker.md`, plus their label documents.
  Read their frontmatter when present; older documents without frontmatter count too.
- Root instruction files: `AGENTS.md`, `CLAUDE.md`, `AGENTS.override.md`, `CLAUDE.local.md`, and legacy `AGENTS.local.md`.
- Existing imports, `## Agents workflow` blocks, and legacy `## Agent skills` blocks in those files.
- `<git-common-dir>/info/exclude`.
- Tracker signs: `.beads/`, `.scratch/`, an issue-tracker line in the repo's own docs, open issues on the host (`gh issue list --limit 5` for GitHub, `glab issue list --per-page 5` for GitLab).
- Is the `triage` skill installed (a `triage` skill folder, or `triage` among your available skills)? Use this finding in step 4.

### 2. Present findings, then ask the mode

Before any question or write, report the tracker this repo uses today:

- **Tracker**: `beads`, `github`, `gitlab`, `markdown`, several, or none. Name the evidence for each (`.beads/` exists, 12 open GitHub issues, a docs line).
- **Setup**: the document path and section, mode, tracker, and beads role when applicable, or none.

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
- Tracker guidance from the chosen template in [templates/](templates/).
  Show the target contribution guide section and its edits for the chosen mode.
- Triage labels from [templates/triage-labels.md](templates/triage-labels.md), only when step 4 configured labels.
  Show them beneath the tracker section.
- The exclude lines (local).
- The tracker commands from its **Commands** section.

Let them edit before anything is written.

### 6. Write

**shared**: write the block to `AGENTS.md`. Create `CLAUDE.md` if absent, with `@AGENTS.md` as its first line.

**local**: write the block to `AGENTS.override.md`, with `@AGENTS.md` as its first line.
Create `CLAUDE.local.md` if absent, with `@AGENTS.override.md` as its first line.
Keep the shared `AGENTS.md` and `CLAUDE.md` unchanged.
If `AGENTS.md` is absent, retain the import without creating a shared file.

Use `CONTRIBUTING.md` in shared mode and `.docs-local/CONTRIBUTING.md` in local mode.
Find a suitable existing section in that guide before creating one.
Use its purpose, not an exact heading match, to select the section.
Merge tracker guidance there; create `## Issue tracker` only when no suitable section exists.
Create the guide if absent. Preserve unrelated content and existing heading structure.
Place configured triage labels beneath the tracker section, reusing an existing label subsection when suitable.
Preserve existing label mappings when step 4 skips label configuration.
In local mode, link to shared contribution rules when relevant instead of copying them.
State local additions and overrides explicitly. Keep shared contribution guidance unchanged.

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

[one-line summary of where issues are tracked]. See [tracker guidance](<tracker-target>).

### Triage labels

[one-line summary of the label vocabulary]. See [triage labels](<labels-target>).
```

Shared targets point to the actual section anchors in `CONTRIBUTING.md`.
Local targets point to the actual section anchors in `.docs-local/CONTRIBUTING.md`.
Include the `### Triage labels` sub-block only when a label mapping exists.

Adapt the templates to this repo (names, remotes) and drop each `<!-- seed: ... -->` line.
In both modes, nest template headings beneath the selected section and omit document frontmatter.
Record the tracker and beads role in the section's text.
Rewrite template cross-references for the destination; use the actual label anchor.
Resolve links relative to the guide's directory, including links from `.docs-local/` to shared documentation.
When no label mapping exists, omit references to it.

When repairing a legacy setup, merge its tracker and label documents into the guide for the chosen mode.
Update their instruction pointers and other repository references before removing the old tracker and label documents.
Preserve unrelated files in legacy directories; remove a directory only if empty.
Remove the old `.issue-tracker/` exclude line only when that directory no longer needs exclusion.

Then run the tracker's **Commands** and **Labels** sections.

**local**: append each missing line to `<git-common-dir>/info/exclude` (the common dir, so every worktree shares it): `AGENTS.override.md`, `CLAUDE.local.md`, `.docs-local/`, plus the tracker's **Exclude lines**, including any new files its commands produced. Never add a line that is already there.

### 7. Verify

Done when every check passes:

- Tracker pointers exist once: in `AGENTS.md` (shared) or `AGENTS.override.md` (local).
- Tracker guidance exists once in a suitable section of the chosen guide, with labels beneath it when configured.
- Guidance links resolve to the actual documents and section anchors; no references point to removed tracker documents.
- **shared**: `CLAUDE.md` starts with `@AGENTS.md`, present exactly once.
- **local**: `AGENTS.override.md` starts with `@AGENTS.md`, present exactly once.
- **local**: `CLAUDE.local.md` starts with `@AGENTS.override.md`, present exactly once.
- Imports resolve when their targets exist; no import cycle exists.
- Existing unrelated content remains intact after imports and legacy migrations.
- The section identifies the chosen tracker and beads role when applicable.
- **local**: shared contribution guidance remains unchanged, except during an approved shared-to-local migration.
- **local**: `git status --porcelain` lists none of the written paths, and `git check-ignore` prints each one.
- **shared**: `git status --porcelain` lists only the written paths and the tracker's setup files.
- The tracker procedure's **Verify** checks pass.

### 8. Report

Tell the user what was written and where, which commands ran, and that skills like `to-tickets`, `triage`, `to-spec` and `wayfinder` now read these files. Shared mode: the new files are ready to commit; committing is the user's call. Local mode: report `AGENTS.override.md` and the import chain from `CLAUDE.local.md` through it to `AGENTS.md`.

## Switching

Mode switch, same tracker:

- **shared → local**: move tracker guidance and labels into a suitable `.docs-local/CONTRIBUTING.md` section.
  Move their instruction pointers to `AGENTS.override.md`; preserve unrelated content in `CONTRIBUTING.md` and shared instruction files.
  Legacy shared setups use their existing tracker documents as the source.
  Apply the local imports and exclude lines. Preserve unrelated shared instructions.
  Explain that removing tracked tracker instructions and docs requires a commit.
- **local → shared**: merge local tracker guidance and labels into a suitable `CONTRIBUTING.md` section as described in step 6.
  Move their instruction pointers to `AGENTS.md`.
  Apply the shared import. Remove local imports and files only when no unrelated content needs them.
  Remove this skill's exclude lines only for paths no longer used locally.

Then re-run the tracker procedure, since some trackers change per mode (beads: stealth init and sync remote; markdown: `.scratch/` tracking). Tracker switch: run the new tracker's procedure from step 3; issues already in the old tracker stay there, so tell the user before moving on.
