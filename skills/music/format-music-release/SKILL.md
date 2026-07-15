---
name: format-music-release
description: User-invoked workflow for formatting a music release folder or loose file path using archive rules and verified release metadata.
disable-model-invocation: true
---

# Format Music Release

Use this skill only when explicitly invoked with a release folder or file path, for example:

```text
Use $format-music-release on /path/to/release
```

## Requirements

Use these local metadata tools for full inspection:

- `metaflac` from Homebrew package `flac`, for FLAC tags.
- `ffprobe` from Homebrew package `ffmpeg`, for audio/video container tags.
- `exiftool` from Homebrew package `exiftool`, for broad media and artwork metadata.

If a required tool is unavailable, report it in the output and continue with the remaining local evidence. Install missing tools with:

```sh
brew install flac ffmpeg exiftool
```

## Workflow

1. Confirm the target path exists, classify it as a release folder, loose audio file, or ambiguous input, and check whether `metaflac`, `ffprobe`, and `exiftool` are available. Completion criterion: the target type, immediate contents, and metadata-tool availability are known.

2. Inspect local evidence before searching: filenames, directory names, embedded tags with `metaflac`, `ffprobe`, or `exiftool` as appropriate, artwork metadata, cue/log files, playlists, and existing metadata files. Completion criterion: candidate artist, title, track list, label, catalog, and year are either extracted or marked unknown.

3. Read [references/archive-rules.md](references/archive-rules.md), then apply its metadata source, naming, and ambiguity rules. Completion criterion: every proposed folder or file name is justified by the local evidence plus cited metadata sources.

4. Look up release metadata when required. Prefer structured or primary sources in this order:
   - MusicBrainz for artist/title/release date/tracklist.
   - Discogs for label, catalog number, format, country, and marketplace-style release variants.
   - Bandcamp, label pages, artist pages, or distributor pages for direct release evidence.
   - Other sources only as supporting evidence.

5. Resolve the release name:
   - Use the folder format `[Label] Artist - Release Title (Year) [Catalog]`.
   - Use `VA` for compilations.
   - Keep loose audio files loose only for standalone tracks or when no broader release folder can be verified.

6. Present the proposed move/rename plan before editing files when there is any uncertainty or more than one file/folder will move. Completion criterion: the plan names the source path, destination path, and unresolved fields.

7. Make filesystem changes only after the proposal is clear or the user has already requested execution. Keep sidecars inside the release folder and leave unrelated files untouched. Completion criterion: the target path conforms to the archive layout, or the response explains why it cannot be resolved safely.

## Output

Report:

- Final path or proposed path.
- Metadata sources used, with links when web lookup was needed.
- Any fields left unknown.
- Any required metadata tools that were unavailable.
- Any files intentionally left in place.
