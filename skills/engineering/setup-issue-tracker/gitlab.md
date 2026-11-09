# Tracker procedure: GitLab

Read during `/setup-issue-tracker` when the tracker is `gitlab`. The mode is already chosen.

In both modes the issues live on GitLab, visible to everyone with access to the project. The mode only decides where this repo's tracker docs live.

## Explore

- `glab auth status`. `glab` missing → stop and tell the user; install it only after they agree (`brew install glab`). Not logged in → ask the user to run `! glab auth login`.
- The GitLab remote (`gitlab.com` or a self-hosted host). No GitLab remote → help the user add one before going on.
- `glab repo view` to confirm the project resolves and issues are enabled.

## Ask

Nothing beyond the shared sections.

## Commands

None.

## Template

`templates/issue-tracker-gitlab.md`. Leave the "MRs as a request surface" flag at **no** and do not raise it.

Identify GitLab as the tracker in the contribution guide section for the chosen mode.

## Exclude lines (local)

None.

## Labels

When triage labels were configured, create each missing one: `glab label list`, then `glab label create --name "<label>"` for each absent label. Without permission, tell the user which labels are missing.

## Verify

- `glab issue list --per-page 1` succeeds.
- Every configured triage label appears in `glab label list`.
