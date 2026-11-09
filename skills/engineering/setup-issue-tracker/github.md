# Tracker procedure: GitHub

Read during `/setup-issue-tracker` when the tracker is `github`. The mode is already chosen.

In both modes the issues live on GitHub, visible to everyone with access to the repo. The mode only decides where this repo's tracker docs live.

## Explore

- `gh auth status`. Not logged in → ask the user to run `! gh auth login`.
- The GitHub remote and its `owner/repo`. No GitHub remote → help the user add one before going on; the tracker cannot work without it.
- `gh repo view <owner/repo> --json hasIssuesEnabled,viewerPermission`. Issues disabled → tell the user; enabling them is their call.

## Ask

Nothing beyond the shared sections.

## Commands

None.

## Template

`templates/issue-tracker-github.md`. Leave the "PRs as a request surface" flag at **no** and do not raise it.

Identify GitHub as the tracker in the contribution guide section for the chosen mode.

## Exclude lines (local)

None.

## Labels

When triage labels were configured, create each missing one: `gh label list --json name`, then `gh label create "<label>"` for each absent label. Creating labels needs triage permission or higher; without it, tell the user which labels are missing.

## Verify

- `gh issue list --repo <owner/repo> --limit 1` succeeds.
- Every configured triage label appears in `gh label list`.
