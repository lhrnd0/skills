# Contributing

## Issue tracker

Issues and specs live in GitHub Issues for `lhrnd0/skills`.

### Conventions

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
Use the label mapping in [Triage labels](#triage-labels).

Never publish this project's issues into a skill provider's repository.

### Pull requests as a triage surface

**PRs as a request surface: no.**

### Triage labels

| Role | Label | Meaning |
| --- | --- | --- |
| needs-triage | needs-triage | Maintainer must evaluate the issue. |
| needs-info | needs-info | More information is required. |
| ready-for-agent | ready-for-agent | Fully specified and ready for an agent. |
| ready-for-human | ready-for-human | Requires human implementation. |
| wontfix | wontfix | Will not be actioned. |

Use these labels whenever an engineering skill names a triage role.

## Domain docs

This repository uses a single-context layout.

### Before exploring

Read the root [GLOSSARY.md](GLOSSARY.md).
Read relevant decisions in [docs/adr/](docs/adr/).

If a document is absent, continue without requesting its creation.
Domain modeling creates documents when terms or decisions are resolved.

### Vocabulary

Use the glossary's terms in specifications, issues, code, and tests.
If a term is missing, identify the gap before inventing a synonym.

### Decisions

Respect relevant ADRs.
If a proposal conflicts with an ADR, state the conflict explicitly.
