# Tracker procedure: markdown

Read during `/setup-issue-tracker` when the tracker is `markdown`. The mode is already chosen.

Issues live as files under `.scratch/<feature-slug>/`. Good for solo work, quick projects, and repos without a remote.

## Explore

- `.scratch/` exists? Then it is already in use; keep its files.
- `git check-ignore .scratch` and `git ls-files .scratch` to see whether it is ignored or tracked now.

## Ask

Nothing beyond the shared sections.

## Commands

`mkdir -p .scratch`.

- **shared**: `.scratch/` is committed. If a `.gitignore` rule ignores it, tell the user and remove the rule only with their agreement.
- **local**: `.scratch/` stays out of git (exclude line below). If files under it are already tracked, tell the user; untracking them (`git rm -r --cached .scratch`) is their call.

## Template

`templates/issue-tracker-markdown.md`.

Identify markdown as the tracker in the contribution guide section for the chosen mode.

## Exclude lines (local)

`.scratch/`.

## Labels

Nothing to create: triage state is a `Status:` line in each issue file.

## Verify

- `.scratch/` exists.
- **local**: `git check-ignore .scratch` prints it.
- **shared**: `git check-ignore .scratch` prints nothing.
