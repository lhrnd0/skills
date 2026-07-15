# Archive Rules

## Naming

Focus on the release folder or file name. This skill does not choose archive placement.

Use this release folder format:

```text
[Label] Artist - Release Title (Year) [Catalog]
```

Omit `[Label]` only when the label is unknown or not applicable. Omit `[Catalog]` only when the catalog number is unknown or not applicable. Use `VA` as the artist for compilations. Preserve artist and title capitalization from release metadata where practical.

## Track Files

Keep audio files inside the release folder unless the input is a verified standalone track.

Preferred track filename patterns:

```text
01 Artist - Track Title.flac
A1 Artist - Track Title.aiff
```

Prefer `.flac`, `.aiff`, and `.wav`. Keep `.mp3` and `.m4a` when they are the highest available source quality or already present.

## Sidecars

Keep artwork, cue sheets, logs, playlists, and disc folders inside the release folder. Valid sidecar examples include:

```text
cover.jpg
Cover.jpg
folder.jpg
Extra/
Covers/
CD 1/
CD 2/
```

Do not create `.DS_Store` or `Thumbs.db`. Keep artwork and metadata files inside the release folder.

## Metadata Evidence

Treat MusicBrainz and Discogs as complementary, not interchangeable:

- MusicBrainz is strongest for normalized artists, titles, dates, recordings, and tracklists.
- Discogs is strongest for labels, catalog numbers, release variants, formats, and countries.
- Bandcamp, label pages, artist pages, and distributor pages are strong direct evidence, especially for digital releases not fully represented elsewhere.

When sources disagree, prefer the source that best covers the disputed field. If the release variant remains ambiguous, do not guess the catalog number or label. Propose a conservative name with unknown parts omitted and mention the ambiguity.

## Safe Rename Policy

Before moving or renaming, check whether the destination already exists. If it does, stop and report the conflict unless the user explicitly asks to merge.

For ambiguous inputs, propose a path instead of editing. Ambiguity includes multiple plausible releases, missing year, conflicting label/catalog evidence, or a folder containing files from more than one release.
