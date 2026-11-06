# Skills hub design

This document records agreed requirements during the design interview.
The design has been synthesized into [the spec](./skills-hub-spec.md). Implementation has not started.

## Agreed requirements

- Include skills created by the repository owner.
- Include skills from a configured list of repositories.
- Install third-party skills through their installation process when requested.
- Keep third-party skill files out of the hub repository.
- Install selected skills into individual projects.
- Offer global installation as an option.
- Allow additions and removals before installation.
- Provide an interactive terminal command for skill selection and review.
- Support Codex and Claude Code in the first version.
- Maintain an explicit list of repository sources.
- Select which skills each repository source contributes.
- Allow review before including skills from a newly added repository source.
- Include the existing private skills submodule in source handling.
- Copy skills into projects by default, so projects do not depend on the hub checkout.
- Offer symlinks as an option for global installation.
- Include each selected skill once in the final selection.
- Let each installation target Codex, Claude Code, or both.
- Keep repository skills at a recorded revision until an explicit update is requested, where the installer supports pinning.
- Show revision limitations before installation when an installer cannot guarantee a pinned revision.
- Show update changes before replacing skills.
- Identify skills by source and name.
- Require an explicit choice when sources provide the same skill name.
- Never silently replace an existing skill.
- Record each project's selected skills, revisions, and target agents.
- Use the project record to repeat installations and detect changes before updates.
- Include whole plugins as selectable catalog entries alongside individual skills.
- Identify each catalog entry as a skill or plugin and show plugin contents before installation.
- Replace existing third-party skill files with installer entries after verifying equivalent installation.
- Stop updates when installed skills have local edits, and show the differences.
- Let the user choose whether to keep or replace edited skills.
- Seed repository sources from the user's GitHub list, together with this repository's own skills.
- Record the initial sources in [skill-sources.md](./skill-sources.md).
- Refresh the GitHub list only on explicit request, and review changes before updating the catalog.
- Keep external tool installation and service setup separate, optional steps.
- Show setup requirements and offer the relevant setup steps separately.
- Keep sources without verified installers visible with manual instructions.
- Clearly mark entries that cannot yet be installed automatically.

## Clarified scope

The initial request included third-party skills stored in this repository.
The user replaced that requirement with installation through tools such as `pnpx skills` and plugin installation commands.
The hub stores selection and source information, rather than third-party skill files.

Profiles were initially accepted, then deferred by the user.
The first version selects individual skills without profiles or selection by project type.

See [GLOSSARY.md](../GLOSSARY.md) for agreed terms.

## Design review

No product decisions remain open from the interview.
Tracker setup and testing review are complete.
The spec is published as [GitHub issue #1](https://github.com/lhrnd0/skills/issues/1) with the `ready-for-agent` label.
The installation boundary is recorded in [ADR 0001](./adr/0001-use-third-party-installers.md).

## Installer constraints

These are research findings, not promises that all installers have the same behavior.

- The [Skills CLI](https://github.com/vercel-labs/skills/blob/main/docs/commands.md) supports individual skills, agent selection, project installation, global installation, and copying.
- Its [source parser](https://github.com/vercel-labs/skills/blob/main/src/source-parser.ts) supports Git references.
- Its [Git implementation](https://github.com/vercel-labs/skills/blob/main/src/git.ts) supports fetching full commit SHAs.
- [Claude Code plugins](https://code.claude.com/docs/en/plugins/install) install whole plugins and support user, project, and local scopes.
- Claude's [marketplace entries](https://code.claude.com/docs/en/plugins/marketplace-reference) can specify source revisions.
- Claude's [plugin CLI](https://code.claude.com/docs/en/plugins/cli-reference) documents no consumer-side version flag for installation.
- Claude's [automatic update settings](https://code.claude.com/docs/en/plugins/install#keep-plugins-updated) must be considered for explicit-update behavior.
- [Codex plugins](https://developers.openai.com/plugins/build/plugins) distinguish installed plugin storage from project enablement.
- Native installers do not provide a uniform file-difference preview. The hub must supply its promised review behavior.

## Deferred

- Profiles and selection by project type.
