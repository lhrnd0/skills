# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `lhrnd0/skills`.

## Conventions

Use the `gh` CLI with `--repo lhrnd0/skills`.

- Create issues with `gh issue create`. Pass multiline content through `--body-file`.
- Read issues with `gh issue view`.
- List issues with `gh issue list`.
- Apply or remove labels with `gh issue edit`.
- Add comments with `gh issue comment`.
- Explain closure in a comment before running `gh issue close`.

Use native sub-issues and dependencies when available.
Otherwise, record parent and blocker issue links in the issue body.
An issue is unblocked when all its blockers are closed.

When a skill requests publication, create a GitHub issue.
When a skill requests a ticket, read the corresponding GitHub issue.
Use the label mapping in `docs/agents/triage-labels.md`.

Never publish this project's issues into a skill provider's repository.

## Pull requests as a triage surface

**PRs as a request surface: no.**
