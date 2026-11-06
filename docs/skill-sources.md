# Initial skill sources

The initial catalog includes this repository's own skills and the repositories below.
These repositories came from the user's [AI - SKILLS GitHub list](https://github.com/stars/lhrnd0/lists/ai-skills).
The list contained 16 repositories when inspected on 2026-11-01.

This document records sources, not third-party skill files.
Inclusion in the catalog does not install every skill from a source.
Each source's installation process must be verified before use.

## This repository

- Owner-created skills in `skills/`.
- Owner-created private skills from `skills-private/`, when available.
- Existing third-party files will become installer entries after equivalent installation is verified.

## Repository sources

- [jakubkrehel/oklch-skill](https://github.com/jakubkrehel/oklch-skill)
- [pbakaus/impeccable](https://github.com/pbakaus/impeccable)
- [shadcn/improve](https://github.com/shadcn/improve)
- [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)
- [jakubkrehel/make-interfaces-feel-better](https://github.com/jakubkrehel/make-interfaces-feel-better)
- [obra/superpowers](https://github.com/obra/superpowers)
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [GoogleChrome/modern-web-guidance-src](https://github.com/GoogleChrome/modern-web-guidance-src)
- [readwiseio/readwise-skills](https://github.com/readwiseio/readwise-skills)
- [emilkowalski/skills](https://github.com/emilkowalski/skills)
- [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill)
- [dgreenheck/webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill)
- [elayadesign/ai-design-skills](https://github.com/elayadesign/ai-design-skills)
- [jakubkrehel/skills](https://github.com/jakubkrehel/skills)
- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)

## Installation research

These findings come from the repositories' own documentation.
Commands and compatibility must be checked again during implementation.
No installer was run during this research.

| Source | Documented route | Constraint |
| --- | --- | --- |
| [jakubkrehel/oklch-skill](https://github.com/jakubkrehel/oklch-skill#install) | Skills CLI | Individual skill. |
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable#installation) | Impeccable installer | Includes supporting components and hooks; Codex hook approval is manual. |
| [shadcn/improve](https://github.com/shadcn/improve#install) | Skills CLI | Agent Skills format. |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail#install) | Native plugins | Codex requires hook approval and a new thread. |
| [jakubkrehel/make-interfaces-feel-better](https://github.com/jakubkrehel/make-interfaces-feel-better#install) | Skills CLI | Individual skill. |
| [obra/superpowers](https://github.com/obra/superpowers#installation) | Native plugins | Codex README describes installation through its plugin interface. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills#quick-start) | Skills CLI or native plugins | Individual skill installation omits shared repository references. |
| [mattpocock/skills](https://github.com/mattpocock/skills#installation-30-second-setup) | Skills CLI or native plugins | Choose one route per agent to avoid duplicates; project setup is separate. |
| [GoogleChrome/modern-web-guidance-src](https://github.com/GoogleChrome/modern-web-guidance-src/blob/main/README.md) | Dedicated installer, Skills CLI, or native plugins | Installation source is `GoogleChrome/modern-web-guidance`, not the listed development repository. |
| [readwiseio/readwise-skills](https://github.com/readwiseio/readwise-skills/blob/master/README.md) | Skills CLI or Claude plugin | Requires Readwise MCP or CLI setup. |
| [emilkowalski/skills](https://github.com/emilkowalski/skills/blob/main/README.md) | Skills CLI | No native plugin route documented in README. |
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill/blob/main/README.md) | Skills CLI or native plugins | Requires Node 22+ and a supported browser. |
| [dgreenheck/webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill/blob/main/README.md) | Manual copying documented | Runnable installer and Codex compatibility need verification. |
| [elayadesign/ai-design-skills](https://github.com/elayadesign/ai-design-skills/blob/main/README.md) | Skills CLI | README names Claude Code and Codex. |
| [jakubkrehel/skills](https://github.com/jakubkrehel/skills/blob/main/README.md) | Skills CLI or Claude plugin | No native Codex plugin route documented in README. |
| [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser/blob/main/README.md) | Skills CLI | Browser tool and browser download are separate from skill installation. |
