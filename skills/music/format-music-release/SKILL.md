---
name: format-music-release
description: Format a music release folder or loose audio file using verified release metadata, consistent embedded tags, artwork, track filenames, and archive naming rules. Use when explicitly invoked with a path to inspect, tag, rename, or organize music files.
---

# Format Music Release

Use this skill only when explicitly invoked with a release folder or file path, for example:

```text
Use $format-music-release on /path/to/release
```

## Requirements

Use these local metadata tools for full inspection:

- `metaflac` and `flac` from Homebrew package `flac`, for FLAC tags and audio-integrity tests.
- `ffprobe` from Homebrew package `ffmpeg`, for audio/video container tags.
- `exiftool` from Homebrew package `exiftool`, for broad media and artwork metadata.

If a required tool is unavailable, report it in the output and continue with the remaining local evidence. Install missing tools with:

```sh
brew install flac ffmpeg exiftool
```

## Workflow

1. Confirm the target path exists, classify it as a release folder, loose audio file, or ambiguous input, and check whether `metaflac`, `ffprobe`, and `exiftool` are available. Completion criterion: the target type, immediate contents, and metadata-tool availability are known.

2. Inspect local evidence before searching: filenames, directory names, embedded tags with `metaflac`, `ffprobe`, or `exiftool` as appropriate, artwork metadata, cue/log files, playlists, and existing metadata files. Completion criterion: candidate values for every field in the metadata checklist are extracted or marked unknown.

3. Read [references/archive-rules.md](references/archive-rules.md), including its embedded metadata checklist, then apply its evidence, tagging, naming, and ambiguity rules. Completion criterion: every proposed tag value and folder or file name is justified by local evidence plus cited metadata sources.

4. Look up release metadata when required. Prefer structured or primary sources in this order:
   - MusicBrainz for artist/title/release date/tracklist.
   - Discogs for label, catalog number, format, country, and marketplace-style release variants.
   - Bandcamp, label pages, artist pages, or distributor pages for direct release evidence.
   - Other sources only as supporting evidence.

5. Build one metadata plan for the entire release before changing files. Include the shared release fields and the per-track title, artist, track number, and BPM. Mark optional unknown fields for omission; do not replace them with guesses or placeholder text.

6. Resolve the release name:
   - Use the folder format `[Label] Artist - Release Title (Year) [Catalog]`.
   - Use `VA` for compilations.
   - Keep loose audio files loose only for standalone tracks or when no broader release folder can be verified.

7. Present the proposed tag and move/rename plan before editing files when there is any uncertainty or more than one file/folder will change. Completion criterion: the plan names the source path, destination path, tag values, and unresolved fields.

8. Write the embedded metadata before or alongside the filesystem changes. Preserve the audio stream and source format; do not transcode merely to edit tags. Apply consistent shared fields to every track, embed the selected front cover in every tag-capable audio file, and remove stale or duplicate values for fields being normalized. For FLAC, apply the compatibility mappings in the archive rules exactly; do not rely on `ffprobe`'s normalized field names as proof that the stored Vorbis comments are correct.

9. Verify every changed audio file using the format-native reader first and a different reader second. For FLAC, read the raw Vorbis comments and PICTURE blocks with `metaflac`, then cross-check with `ffprobe` or `exiftool`. Check exact stored names, values, and occurrence counts; required scalar fields must occur once, with no duplicate titles or conflicting aliases. Verify track/disc totals, compilation state, label/year/style compatibility fields, and exactly one selected front cover. Compare the pre-write and post-write FLAC STREAMINFO MD5 values and run `flac --test` on every file. Completion criterion: both readbacks match the plan, audio checksums are unchanged, integrity tests pass, filenames and folder name conform to the archive rules, and unrelated files remain untouched.

## Output

Report:

- Final path or proposed path.
- Metadata written or proposed, including any per-track differences.
- Metadata sources used, with links when web lookup was needed.
- Any fields left unknown.
- Tag readback result and any formats that could not store a requested field.
- Any required metadata tools that were unavailable.
- Any files intentionally left in place.
