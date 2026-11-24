---
name: setup-issue-tracker
description: "Set up, switch, or repair a repo's issue tracker in shared or local mode. Use from /setup-project or when configuring Backlog.md, GitHub, GitLab, or markdown issue tracking."
---

# Setup Issue Tracker

Configure where this repo's issues live and where its issue tracking guidance lives. Two independent choices:

- **Mode** decides where the tracker guidance lives. **Shared** guidance is tracked in Git. **Local** guidance is excluded through `.git/info/exclude`.
- **Tracker** decides where the issues live. Read the procedure for [Backlog.md](backlog.md), [GitHub](github.md), [GitLab](gitlab.md), or [markdown](markdown.md).

This is a prompt-driven skill, not a script. Explore, present what you found, confirm with the user, then write.

## Layout per mode

| | shared | local |
|---|---|---|
| Tracker pointer | `AGENTS.md` under `## Agents workflow` | Global instructions direct the agent to `.docs-local/` |
| Project import | `CLAUDE.md` imports `AGENTS.md` | None |
| Contribution guide | `CONTRIBUTING.md` | `.docs-local/CONTRIBUTING.md` |
| Excluded from git | Nothing | `.docs-local/` and the tracker's own paths |

In both modes, a contribution guide section identifies the tracker.
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
- Root instruction files: `AGENTS.md` and `CLAUDE.md`. Check `AGENTS.override.md`, `CLAUDE.local.md`, and `AGENTS.local.md` for older tracker setups.
- Existing imports, `## Agents workflow` blocks, and legacy `## Agent skills` blocks in those files.
- `<git-common-dir>/info/exclude`.
- Tracker signs include `backlog/config.yml`, `.backlog/config.yml`, `backlog.config.yml`, `.scratch/`, and tracker guidance in the repo.
- Check for open issues on the host (`gh issue list --limit 5` for GitHub, `glab issue list --per-page 5` for GitLab).
- Is the `triage` skill installed (a `triage` skill folder, or `triage` among your available skills)? Use this finding in step 4.

### 2. Present findings, then ask the mode

Before any question or write, report the tracker this repo uses today:

- **Tracker**: name every tracker found and give the evidence for each. If the repo has no tracker, say so.
- **Setup**: the document path and section, mode, and tracker, or none.

Then summarise what else is present and what is missing. Existing setup → ask whether to keep it, repair it, or switch mode or tracker (see **Switching**).

Then ask the mode. Lead with the recommendation, and explain both choices first:

> **shared**: the tracker docs and the `## Agents workflow` block are committed. Every collaborator's agent reads the same rules. Use it for repos you own or where the team agrees to these files.
>
> **local**: tracker guidance stays on this machine through `.git/info/exclude`. Backlog.md and markdown issues also stay local. Issues on GitHub or GitLab stay visible to people with access to that tracker. Run the local setup again on each machine.

Recommend **shared** when the user owns the repo, **local** otherwise.

### 3. Ask the tracker

Explain the four, then recommend:

- **Backlog.md**: Markdown tasks with a CLI, board, and dependencies. Keep the files local or share them through normal Git commits.
- **github**: GitHub Issues through `gh`.
- **gitlab**: GitLab Issues through `glab`.
- **markdown**: one file per issue under `.scratch/`. For quick work with no tooling.

If the repo already uses a supported tracker, propose that tracker. Otherwise propose Backlog.md.

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

- **Shared**: the `## Agents workflow` block in `AGENTS.md` and the import in `CLAUDE.md`.
- **Local**: check whether the agents' global instructions already direct them to `.docs-local/`. If the rule is missing, include it in the draft for their global instructions.
- Any legacy migration.
- Tracker guidance from the chosen template in [templates/](templates/).
  Show the target contribution guide section and its edits for the chosen mode.
- Triage labels from [templates/triage-labels.md](templates/triage-labels.md), only when step 4 configured labels.
  Show them beneath the tracker section.
- The exclude lines (local).
- The tracker commands from its **Commands** section.

Let them edit before anything is written.

### 6. Write

Use `CONTRIBUTING.md` in shared mode and `.docs-local/CONTRIBUTING.md` in local mode.
Find a suitable existing section in that guide before creating one.
Use its purpose, not an exact heading match, to select the section.
Merge tracker guidance there; create `## Issue tracker` only when no suitable section exists.
Create the guide if absent. Preserve unrelated content and existing heading structure.
Place configured triage labels beneath the tracker section, reusing an existing label subsection when suitable.
Preserve existing label mappings when step 4 skips label configuration.
In local mode, link to shared contribution rules when relevant instead of copying them.
State local additions and overrides explicitly. Keep shared contribution guidance unchanged.

**Local**: use the approved global rule for discovery. Create project instruction files only for shared tracker setups.

The global rule directs agents to check `.docs-local/` at the project root. For issue tracking, use the local guide's tracker section when present. Otherwise, follow the project's shared tracker guidance.

**Shared**: write the tracker pointer to `AGENTS.md`. Set `@AGENTS.md` as the first line of `CLAUDE.md`. Keep one copy of the import and preserve other content.

Update an existing `## Agents workflow` block in place.
Rename a legacy `## Agent skills` block to `## Agents workflow` when updating it.
For older shared setups, move the tracker instructions from `CLAUDE.md` to `AGENTS.md`.

The shared block:

```markdown
## Agents workflow

### Issue tracker

[one-line summary of where issues are tracked]. See [tracker guidance](<tracker-target>).

### Triage labels

[one-line summary of the label vocabulary]. See [triage labels](<labels-target>).
```

Use the actual section anchors in `CONTRIBUTING.md`.
Include the `### Triage labels` sub-block only when a label mapping exists.

Adapt the templates to this repo (names, remotes) and drop each `<!-- seed: ... -->` line.
In both modes, nest template headings beneath the selected section and omit document frontmatter.
Record the tracker in the section's text.
Rewrite template cross-references for the destination; use the actual label anchor.
Resolve links relative to the guide's directory, including links from `.docs-local/` to shared documentation.
When no label mapping exists, omit references to it.

When repairing a legacy setup, merge its tracker and label documents into the guide for the chosen mode.
Move any tracker guidance from legacy local instruction files into that guide. Remove the old tracker pointers and imports added solely for the tracker setup.
Preserve unrelated instructions and the imports they need. If a local instruction file contains no remaining instructions, remove it and its unused exclude line.
Update or remove references before deleting the old tracker and label documents.
Preserve unrelated files in legacy directories; remove a directory only if empty.
Remove the old `.issue-tracker/` exclude line only when that directory no longer needs exclusion.

Then run the tracker's **Commands** and **Labels** sections.

**Local**: add `/.docs-local/` and the tracker's **Exclude lines** to `<git-common-dir>/info/exclude`. Add only missing entries. Worktrees share these rules.

### 7. Verify

Done when every check passes:

- **Shared**: the tracker pointer exists once in `AGENTS.md`.
- Tracker guidance exists once in a suitable section of the chosen guide, with labels beneath it when configured.
- Guidance links resolve to the actual documents and section anchors; no references point to removed tracker documents.
- **shared**: `CLAUDE.md` starts with `@AGENTS.md`, present exactly once.
- **Local**: the global rule points to the local guide, and the setup has no project instruction file for local tracker discovery.
- Imports resolve when their targets exist; no import cycle exists.
- Existing unrelated content remains intact after imports and legacy migrations.
- The section identifies the chosen tracker.
- **local**: shared contribution guidance remains unchanged, except during an approved shared-to-local migration.
- **local**: `git status --porcelain` lists none of the written paths, and `git check-ignore` prints each one.
- **shared**: `git status --porcelain` lists only the written paths and the tracker's setup files.
- The tracker procedure's **Verify** checks pass.

### 8. Report

Tell the user where the tracker guidance lives and which commands ran.
In shared mode, list the files ready to commit. In local mode, identify the global rule and the local guide it points to.

## Switching

Mode switch, same tracker:

- **shared → local**: move tracker guidance and labels into a suitable `.docs-local/CONTRIBUTING.md` section.
  Remove the shared tracker pointers and preserve unrelated instructions.
  Verify global discovery and add the local exclude lines.
  Explain that removing tracked tracker instructions and docs requires a commit.
- **local → shared**: merge local tracker guidance and labels into a suitable `CONTRIBUTING.md` section as described in step 6.
  Add the shared pointer and import. Remove local tracker guidance and preserve unrelated local content.
  Remove this skill's exclude lines only for paths no longer used locally.

Then re-run the tracker procedure. For Backlog.md and markdown, check how Git tracks the task files.

When switching trackers, tell the user where existing issues will stay. Run the new tracker's procedure from step 3. Preserve existing issue data unless the user requests a migration or removal.
