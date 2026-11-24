# Tracker procedure: Backlog.md

Backlog.md stores tasks as Markdown files. In shared mode, Git commits carry tasks and configuration. In local mode, Git excludes the tasks and configuration.

## Explore

- Run `backlog --version`. If the CLI is missing, use `npx --yes backlog.md` in place of `backlog`.
- Look for `backlog/config.yml`, `.backlog/config.yml`, and `backlog.config.yml`. A root config can specify a custom task folder through `backlog_directory`.
- If a backlog exists, record its folder and config paths. Check both paths with `git ls-files` and `git check-ignore`.
- For an existing setup, read `backlog config get filesystemOnly` and confirm that `backlog task list --plain` reads its tasks.

## Ask

For shared mode, explain that anyone with access to the pushed commits can read the tasks. For local mode, explain that `--no-git` disables Backlog.md Git integration. The exclude rule keeps its files out of Git.

If an existing setup requires untracking files or changing a shared ignore rule, include that change in the parent skill's draft. Explain that previously pushed files remain in Git history.

## Commands

For a new setup, run the command for the chosen mode from the repo root. The parent skill writes the agent guidance. The CLI skips its own agent setup.

- **Shared**: `backlog init "<project>" --defaults --integration-mode none --backlog-dir backlog --config-location folder`. Track `backlog/`, including `backlog/config.yml`, in Git.
- **Local**: add `/.backlog/` to the Git common directory's `info/exclude`, then run `backlog init "<project>" --defaults --integration-mode none --backlog-dir .backlog --config-location folder --no-git`.

For an existing setup, keep the current folder, configuration path, and tasks. Apply the approved tracking changes to those paths. Set `backlog config set filesystemOnly true` for local mode or `backlog config set filesystemOnly false` for shared mode. Remove local exclude rules for those paths when switching to shared mode.

Keep `autoCommit` off. Share tasks by committing and pushing the Markdown files and config through the normal Git workflow. `remoteOperations` controls remote branch reads. It does not publish tasks.

## Template

Use [issue-tracker-backlog.md](templates/issue-tracker-backlog.md). Replace `<backlog-directory>` with the actual task folder. Keep the sentence for the chosen mode and remove all mode markers.

## Exclude lines (local)

Exclude the actual task folder with a root-relative rule such as `/.backlog/`. If the config lives outside that folder, also exclude its path, such as `/backlog.config.yml`.

## Labels

Backlog.md accepts labels on tasks without pre-creating them. Use the existing triage mapping, if one is configured.

## Verify

- `backlog instructions overview` and `backlog task list --plain` succeed.
- `backlog config get autoCommit` prints `false`.
- **Shared**: `backlog config get filesystemOnly` prints `false`. Confirm the config and task paths are tracked or can be staged.
- **Local**: `backlog config get filesystemOnly` prints `true`. Confirm `git check-ignore` covers the config and task paths, and `git ls-files` lists none of them.
