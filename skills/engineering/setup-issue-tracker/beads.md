# Tracker procedure: beads

Read during `/setup-issue-tracker` when the tracker is `beads`. The mode is already chosen.

## Explore

- `bd version`. If `bd` is missing, stop and tell the user; install it only after they agree (`brew install beads`).
- `.beads/` exists? Then run `bd info`, `bd dolt remote list`, `bd config get sync.remote`, and read `.beads/config.yaml` for `repos.additional` and `routing.mode`. This is an existing workspace: re-initialising destroys its data, so adjust it instead of running `bd init`.
- `git config beads.role` for an existing role.
- Every git remote (`git remote -v`) and its owner. The fork is the remote under the user's own account (`gh api user --jq .login`, or `glab api user` on GitLab) that is not `upstream`/`origin` of someone else.

## Ask

**Role.** Explain before asking:

> The role tells bd how you relate to this repo. **maintainer**: you own the repo or can push to its main branch. **contributor**: it is someone else's repo or a fork you send PRs from. Either way, issues stay in this repo's `.beads/`: routing to a separate planning repo stays off.

Recommend `maintainer` when the user can push to the main branch of the repo they cloned, `contributor` otherwise.

**Sync remote.** The Dolt database syncs between machines through a git remote (bd stores it under `refs/dolt/*`). Propose, then confirm:

- **shared**: the project's own remote (usually `origin`). No remote → sync off.
- **local**: the user's **fork** remote only, never `origin`, even when the user can push to `origin`; anyone with read access to a remote can fetch the beads from it. No fork → sync off.

## Commands

### 1. Snapshot

Record `git status --porcelain`. Copy each of these that exists to a temp dir: `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`, `.codex/hooks.json`, `.codex/config.toml`. Every restore below comes from this copy, so the user's uncommitted edits survive.

### 2. Init

Skip for an existing workspace; apply the **Existing workspace** fixes instead.

- **shared**: `bd init --non-interactive --role <role> --skip-agents`. It writes `.beads/` (setup files committable, data ignored by `.beads/.gitignore`), a root `.gitignore` block for Dolt files, `.beads/hooks/` with `core.hooksPath` pointing there, and adopts the git `origin` as Dolt remote and `sync.remote`.
- **local**: `bd init --non-interactive --stealth --role <role> --skip-agents`. It writes only `.beads/` and adds `.beads/`, `.claude/settings.local.json` and the Dolt patterns to `.git/info/exclude`. No git hooks, no remote.

### 3. Harness hooks

Claude and Codex get a SessionStart hook that primes bd, in both modes:

- **shared**: `bd setup claude` (hook `bd prime --hook-json`), then `bd setup codex`.
- **local**: `bd setup claude --stealth` (hook `bd prime --stealth --hook-json`), then `bd setup codex`.

`bd setup codex` writes `.codex/hooks.json` (`bd codex-hook SessionStart` and three more events), `.codex/config.toml` (`[features] hooks = true`) and the `.agents/skills/beads/` skill. `--skip-agents` exists only on `bd init`: both `bd setup` commands always write a beads section to `CLAUDE.md` / `AGENTS.md`.

### 4. Sort the changes

Compare `git status --porcelain` with the snapshot. For every path bd added or changed:

- **`CLAUDE.md`, `AGENTS.md`** (both modes) → discard bd's section: restore from the snapshot when the file existed, delete it when bd created it. Then preserve the instruction layout from the parent skill: shared workflow in `AGENTS.md`, with `@AGENTS.md` atop `CLAUDE.md`. Local mode leaves both shared files unchanged.
- **shared**: keep everything else; it is committable setup. `.beads.gate.lock` is ignored by the root `.gitignore`.
- **local**, file bd created → add it to the exclude lines.
- **local**, tracked file bd changed:

  | Tracked file | Keep bd's change by |
  |---|---|
  | `.claude/settings.json` | moving the SessionStart hook into `.claude/settings.local.json`, then restoring the file |
  | `.codex/hooks.json`, `.codex/config.toml` | merging bd's entries into the file, then `git update-index --skip-worktree <file>` so git stops showing the change. Codex reads project hooks only from these paths. |
  | anything under `.agents/skills/` | restoring it; the repo ships its own copy |

  A `--skip-worktree` file blocks `git pull` only when upstream changes that same file. Then: `git update-index --no-skip-worktree <file>`, `git stash`, pull, `git stash pop`, set `--skip-worktree` again. Tell the user this once.

Codex asks the user to trust a new project hook the first time it runs; mention it.

### 5. Sync remote

- `bd dolt remote list` and `bd config get sync.remote` show the current state.
- Wrong remote → `bd dolt remote remove <name>` (this also clears `sync.remote`). In local mode that includes the `origin` a shared-mode init adopted earlier.
- Chosen remote → `bd dolt remote add origin <url>`, then `bd config set sync.remote <url>`. If bd refuses because the URL is the git origin, pass `--allow-git-origin` (shared mode only).
- Sync off → no Dolt remote, and `bd config unset sync.remote`.
- `bd dolt push` needs a remote with at least one branch; a fork has one. Run it once to confirm the sync works.

### Existing workspace

- Role differs → `git config beads.role <role>`.
- `repos.additional` or a `routing.mode` other than off → remove them from `.beads/config.yaml`. List any issues in the extra repos first and tell the user, so none are lost.
- Hooks missing → run steps 3–4.

## Template

`templates/issue-tracker-beads.md`. Keep the block for the chosen mode between `<!-- shared -->` / `<!-- local -->` markers, delete the other block, and drop the marker lines. Replace `<sync-remote>` with the chosen sync remote; when sync is off, drop the **Sync** line.

Identify beads as the tracker in the contribution guide section for the chosen mode.
Record the chosen role: `maintainer` or `contributor`.

## Exclude lines (local)

`.beads/` and `.claude/settings.local.json`, which `bd init --stealth` usually adds; add them if missing. Plus every file bd created in step 4: typically `.claude/settings.json`, `.codex/hooks.json`, `.codex/config.toml`, `.agents/skills/beads/` when the repo had none of them.

## Labels

Nothing to create: bd labels are free-form.

## Verify

- `bd info` succeeds and `bd ready` runs.
- `bd dolt remote list` shows exactly the chosen remote, or none when sync is off; `bd config get sync.remote` matches.
- `git config beads.role` prints the chosen role.
- `CLAUDE.md` and `AGENTS.md` match the snapshot, apart from the parent skill’s shared workflow and import changes.
- The parent skill’s instruction-file checks pass in the chosen mode.
- Claude hook: `bd prime --hook-json` (shared) or `bd prime --stealth --hook-json` (local) prints the context. Codex hook: `.codex/hooks.json` holds `bd codex-hook SessionStart`.
- **shared**: beyond the snapshot, `git status --porcelain` shows only `.gitignore`, the `.beads/` setup files (`config.yaml`, `metadata.json`, `README.md`, `.gitignore`, `hooks/`), `.claude/settings.json`, `.codex/hooks.json`, `.codex/config.toml` and `.agents/skills/beads/`; no data directory. `git config core.hooksPath` points at `.beads/hooks`.
- **local**: `git status --porcelain` matches the snapshot exactly. `git check-ignore` prints `.beads` and every excluded file; `git ls-files -v` shows `S` for every `--skip-worktree` file.
