# Skills

Private repository for reusable Codex skills.

## Skills

- [`check-port-availability`](./skills/network/check-port-availability/SKILL.md) - Check TCP port availability, local listeners, and public internet reachability.
- [`check-soulseek-ports`](./skills/network/check-soulseek-ports/SKILL.md) - Verify SoulseekQt listening and obfuscated ports using the generic port availability workflow.
- [`format-music-release`](./skills/music/format-music-release/SKILL.md) - Format a music release folder or loose audio file path using archive rules and verified release metadata.
- [`key-insights`](./skills/research/key-insights/SKILL.md) - Distill the key insights from a blog post, article, or YouTube video into grounded, non-obvious takeaways.
- [`triage-listen-later`](./skills/music/triage-listen-later/SKILL.md) - Triage Reader items tagged garimpo with music-release research and acquisition links.
- [`triage-read-later`](./skills/research/triage-read-later/SKILL.md) - Triage the Readwise Reader inbox one document at a time.
- [`triage-watch-later`](./skills/youtube/triage-watch-later/SKILL.md) - Triage a YouTube Watch Later queue one video at a time with delete, Reader, browser, and on-demand key-insights actions.
- [`yt-channel-categorizer`](./skills/youtube/yt-channel-categorizer/SKILL.md) - Fetch YouTube channel metadata and categorize channel IDs.

## Private Skills

Optional private skills can live in a separate private repository at `skills-private/`.
The local scripts scan both `skills/` and `skills-private/` when the private directory
is present.

To sync private skills across machines, make `skills-private/` a private Git
repository or submodule:

```sh
git -C skills-private remote add origin <private-repo-url>
git -C skills-private add .
git -C skills-private commit -m "Add private skills"
git -C skills-private push -u origin main
```

Then track it from this public repository as a submodule once the private remote
exists:

```sh
git submodule add <private-repo-url> skills-private
```

## Install Locally

Symlink every skill in this repository into your Codex skills directory:

```sh
./scripts/link-skills.sh
```

List available skills:

```sh
./scripts/list-skills.sh
```

## Skill Requirements

Each skill documents its own setup requirements in its `README.md`.
