# Skills

Private repository for reusable Codex skills.

## Skills

- [`format-music-release`](./skills/music/format-music-release/SKILL.md) - Format a music release folder or loose audio file path using archive rules and verified release metadata.
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

The `format-music-release` skill works best with:

```sh
brew install flac ffmpeg exiftool
```

The `yt-channel-categorizer` skill requires:

```sh
brew install jq yt-dlp
```
