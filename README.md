# Music Metadata Skills

Private skills repository for music archive workflows.

## Skills

- [`format-music-release`](./skills/music/format-music-release/SKILL.md) - Format a music release folder or loose audio file path using archive rules and verified release metadata.

## Install Locally

Symlink every skill in this repository into your Codex skills directory:

```sh
./scripts/link-skills.sh
```

List available skills:

```sh
./scripts/list-skills.sh
```

## Metadata Tools

The `format-music-release` skill works best with:

```sh
brew install flac ffmpeg exiftool
```
