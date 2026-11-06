# Build a skills hub with reviewed installation sources

## Problem Statement

The repository owner keeps useful skills across personal files, external repositories, and agent plugins.
Starting a project requires finding those sources and repeating different installation processes.
The current scripts list local skills or link all of them into Codex's global skills directory.
They cannot select skills, install into a project, target Claude Code, or record project selections.

The owner needs one catalog and one selection workflow.
Third-party skill files must stay outside this repository.
Each third-party source must retain its documented installation process.

## Solution

Provide an interactive terminal workflow for selecting catalog entries and reviewing their installation.
A catalog entry represents an individual skill or a whole plugin.
The initial catalog includes owner-created skills and the 16 repository sources recorded from the owner's GitHub list.
Optional owner-created private skills remain available when their private source is present.

The user chooses a destination, project or global installation, and Codex, Claude Code, or both.
Project installation uses copies by default where the installation method supports copies.
Global installation can offer symlinks for local skills.
Plugins retain their native installation behavior, including separate project enablement where required.
The review must explain any difference between the requested scope and the installer's behavior.

The hub runs the documented installer for selected third-party entries.
It records selections, source revisions, agents, installation scope, and results.
It identifies revision limits before installation and protects existing skills from silent replacement.

Catalog refresh and hub-managed updates require explicit requests and review.
Extra tool installation and service setup remain separate, optional steps.
Sources without verified installation automation remain visible with manual instructions.
Profiles and selection by project type are deferred.

## User Stories

1. As the owner, I want one catalog, so that I can find available skills from one place.
2. As the owner, I want my own skills listed, so that I can reuse work I already maintain.
3. As the owner, I want optional private skills listed when available, so that private skills remain usable.
4. As the owner, I want missing private sources handled clearly, so that public skills remain accessible.
5. As the owner, I want my GitHub list included initially, so that the catalog reflects my chosen sources.
6. As the owner, I want configurable repository sources, so that I can extend the catalog later.
7. As the owner, I want source review before inclusion, so that new sources do not enter silently.
8. As the owner, I want explicit catalog refresh, so that GitHub list changes require my review.
9. As the owner, I want source changes shown, so that I can accept or reject catalog changes.
10. As the owner, I want source identities preserved, so that similarly named skills remain distinguishable.
11. As the owner, I want installation sources recorded separately, so that development repositories can point to published packages.
12. As the owner, I want skills and plugins distinguished, so that I understand what each entry installs.
13. As the owner, I want plugin contents shown, so that included hooks, agents, and servers are visible.
14. As the owner, I want individual skill selection, so that I install only my chosen entries.
15. As the owner, I want additions and removals before installation, so that I can revise the selection.
16. As the owner, I want shared selections deduplicated, so that the same entry is not installed twice.
17. As the owner, I want name conflicts shown, so that I can choose the intended source.
18. As the owner, I want an interactive terminal workflow, so that installation fits my existing tools.
19. As the owner, I want a review before execution, so that I can inspect the planned changes.
20. As the owner, I want project installation, so that each project has its own selection.
21. As the owner, I want global installation available, so that common skills can serve several projects.
22. As the owner, I want to choose Codex, so that selected skills work with that agent.
23. As the owner, I want to choose Claude Code, so that selected skills work with that agent.
24. As the owner, I want both agents selectable, so that a project can support both workflows.
25. As the owner, I want project copies by default, so that projects do not depend on the hub checkout.
26. As the owner, I want optional global symlinks, so that local skill changes can remain available globally.
27. As the owner, I want native scope limits shown, so that plugin storage and project enablement remain clear.
28. As the owner, I want documented third-party installers used, so that supporting components are preserved.
29. As the owner, I want third-party files excluded here, so that this repository does not maintain copied third-party skills.
30. As the owner, I want source-specific installers supported, so that sources need not fit one generic installation command.
31. As the owner, I want alternative installation routes distinguished, so that plugins and copied skills do not create duplicates.
32. As the owner, I want missing installer requirements shown, so that failures have an actionable explanation.
33. As the owner, I want extra setup offered separately, so that selecting a skill does not silently expand setup.
34. As the owner, I want manual approval steps shown, so that hooks and authentication can be completed correctly.
35. As the owner, I want manual installation entries visible, so that incomplete automation does not hide useful sources.
36. As the owner, I want manual entries marked clearly, so that I do not expect automatic installation.
37. As the owner, I want installation results shown, so that I can distinguish success, failure, and remaining actions.
38. As the owner, I want failed installations recorded accurately, so that saved selections do not imply false success.
39. As the owner, I want project selections saved, so that I can repeat the installation later.
40. As the owner, I want target agents saved, so that repeated installation preserves the intended agent selection.
41. As the owner, I want installation scope saved, so that later operations use the correct destination.
42. As the owner, I want resolved revisions recorded, so that reproducible sources can be installed again.
43. As the owner, I want revision limitations shown, so that unsupported pinning never appears guaranteed.
44. As the owner, I want explicit updates, so that the hub does not replace installed skills without my request.
45. As the owner, I want update changes shown, so that I can review replacements before they occur.
46. As the owner, I want existing installations detected, so that unrelated skills are not silently replaced.
47. As the owner, I want local edits detected, so that updates stop before overwriting my changes.
48. As the owner, I want local differences shown, so that I can choose to keep or replace edited skills.
49. As the owner, I want installer update limits explained, so that native automatic updates are not mistaken for hub control.
50. As the owner, I want existing third-party copies migrated carefully, so that verified replacements exist before files are removed.

## Implementation Decisions

- Build a terminal workflow around catalog discovery, selection, review, installation, saved records, and updates.
- Keep these responsibilities separate enough to test through one public CLI boundary.
- Prefer existing local discovery and installation behavior where it satisfies the agreed requirements.
- Preserve the distinction between owner-created skill files and third-party source information.
- Include optional private source discovery without requiring the private source for other entries.
- Seed the external source list from the recorded 16-repository snapshot of the owner's AI - SKILLS GitHub list.
- Make source configuration editable without adding profiles.
- Refresh source membership explicitly; present proposed additions and removals before changing the catalog.
- Represent a selectable entry with its source identity, name, kind, description, supported agents, and installation route.
- Record the listed repository separately from the actual installation source when they differ.
- Identify entries by source and name. Distinguish installation alternatives where one source offers several routes.
- Deduplicate identical entries before execution. Require a choice when distinct sources would collide at the destination.
- Show plugin components and supporting installation behavior before running the plugin installer.
- Use the source's documented installation process rather than assuming every source supports the Skills CLI.
- Support Skills CLI routes, native agent plugin routes, and source-specific installation routes where verified.
- Treat manual installation as an explicit result with instructions, rather than inventing an unsupported command.
- Choose Codex, Claude Code, or both for each installation; validate each entry against the chosen agents.
- Default to copies for project skill installation where supported. Offer local skill symlinks for global installation.
- Preserve native plugin storage and enablement rules. Explain scope limits before execution.
- Separate extra tools, service configuration, authentication, and manual approvals from the skill selection workflow.
- Offer required follow-up actions explicitly and distinguish pending setup from a completed installation.
- Keep third-party skill files outside the hub repository, including during source discovery and refresh.
- Record requested sources, resolved revisions where available, installer routes, scope, target agents, and installation results.
- Preserve the distinction between requested selection, successful installation, failure, and pending manual actions.
- Use saved records to repeat installations and plan updates. Never claim reproducibility without sufficient revision support.
- Initiate hub-managed updates only after an explicit request. Show changes before replacing installed skills.
- Detect destination conflicts and local edits before replacement. Require a keep-or-replace choice for edited skills.
- Disclose native automatic update behavior that the hub cannot guarantee or control.
- Replace existing third-party copies only after their installation route and equivalent installation are verified.
- Honor the ADR that selects third-party installers instead of storing third-party skills in this repository.
- Select concrete libraries, command names, and record formats during implementation. The interview did not settle them.

## Testing Decisions

- Primary seam: invoke the public CLI against temporary projects and temporary agent directories.
- Exercise discovery, selection, review, installation, recording, refresh, and updates through that boundary.
- Drive interactive selections with scripted terminal input when terminal behavior matters.
- Substitute installer executables at the process boundary. Record arguments and simulate installer results.
- Keep tests independent of real agent directories, paid services, credentials, and changing upstream repositories.
- Use small fixture catalogs and source snapshots for deterministic discovery and refresh behavior.
- Assert visible results, destination contents, invoked installer arguments, exit status, and saved installation records.
- Test the public behavior of catalog discovery, installation coordination, saved records, and update planning.
- Avoid tests of private functions, internal call order, or chosen library details.
- Cover owner-created public and private skills, including an absent optional private source.
- Cover individual skills, whole plugins, dedicated installers, and manual installation entries.
- Cover different listed and installation repositories, including the Modern Web Guidance source mapping.
- Cover project and global installation, each agent independently, and both agents together.
- Confirm project copies remain usable without the hub checkout, where copying is the supported route.
- Verify that requested scope limits are visible before plugin installation.
- Verify deduplication, conflicting source names, existing destinations, and duplicate installation alternatives.
- Verify that cancellation before execution leaves destinations and installation records unchanged.
- Verify installer failure and pending setup never appear as successful, complete installation.
- Verify saved selections can reproduce supported pinned installations without selecting newer revisions silently.
- Verify unsupported revision guarantees appear before execution.
- Verify explicit refresh presents membership changes before changing the catalog.
- Verify updates show changes and stop for local edits until the user chooses keep or replace.
- Verify browsing and refresh do not store third-party skill files in the hub repository.
- Verify migration retains existing third-party files until equivalent installation is verified.
- Use narrow, read-only compatibility checks against official source metadata when verifying real installer routes.
- Do not install all third-party packages into the developer's environment as part of the automated suite.
- Existing prior art consists of two shell scripts for listing and globally linking local skills.
- No automated test suite or test command was found in the current project.
- Introduce one CLI-level harness rather than separate test interfaces for each internal responsibility.

## Out of Scope

- Profiles, profile composition, and selection by project type in the first version.
- Storing or maintaining copies of third-party skill files inside the hub repository.
- Replacing source maintainers' documented installation processes with one universal installation mechanism.
- Automatically applying GitHub list changes without explicit refresh and review.
- Automatically initiating hub-managed skill updates without the user's request.
- Silently replacing existing skills or discarding local edits.
- Installing extra tools or configuring external services implicitly through hub-managed setup steps.
- Guaranteeing exact revisions, project-local storage, or update control that a native installer cannot provide.
- Claiming automated installation for sources whose installation route has not been verified.
- A web interface. The agreed interface for this version is an interactive terminal command.

## Further Notes

- The GitHub list is https://github.com/stars/lhrnd0/lists/ai-skills.
- The initial snapshot contains 16 repositories and was recorded on 2026-11-01.
- The existing project remote points to `lhrnd0/skills` on GitHub.
- Project issue tracker configuration now selects GitHub Issues in `lhrnd0/skills`.
- The five default triage labels are configured and available in the tracker.
- The requested publication label is `ready-for-agent`.
- Installation route research is a starting point. Recheck upstream documentation before implementing each route.
- Impeccable documents a dedicated installer with hooks and supporting components.
- Modern Web Guidance's listed development repository differs from its documented installation repository.
- Individual Addy Osmani skill installations can omit shared repository references available through the plugin route.
- Some plugins require manual hook approval, agent restart, or project setup after installation.
- Installing the agent-browser skill does not install its browser tool.
- The WebGPU source currently needs installer and Codex compatibility verification.
- No prototype was produced during the design interview.
- This spec records the agreed product scope. Implementation has not started.

Initial repository sources:

| Repository source | URL |
| --- | --- |
| jakubkrehel/oklch-skill | https://github.com/jakubkrehel/oklch-skill |
| pbakaus/impeccable | https://github.com/pbakaus/impeccable |
| shadcn/improve | https://github.com/shadcn/improve |
| DietrichGebert/ponytail | https://github.com/DietrichGebert/ponytail |
| jakubkrehel/make-interfaces-feel-better | https://github.com/jakubkrehel/make-interfaces-feel-better |
| obra/superpowers | https://github.com/obra/superpowers |
| addyosmani/agent-skills | https://github.com/addyosmani/agent-skills |
| mattpocock/skills | https://github.com/mattpocock/skills |
| GoogleChrome/modern-web-guidance-src | https://github.com/GoogleChrome/modern-web-guidance-src |
| readwiseio/readwise-skills | https://github.com/readwiseio/readwise-skills |
| emilkowalski/skills | https://github.com/emilkowalski/skills |
| Leonxlnx/taste-skill | https://github.com/Leonxlnx/taste-skill |
| dgreenheck/webgpu-claude-skill | https://github.com/dgreenheck/webgpu-claude-skill |
| elayadesign/ai-design-skills | https://github.com/elayadesign/ai-design-skills |
| jakubkrehel/skills | https://github.com/jakubkrehel/skills |
| vercel-labs/agent-browser | https://github.com/vercel-labs/agent-browser |
