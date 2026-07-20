# Archive Rules

## Embedded Metadata Checklist

Normalize embedded metadata in every audio file when the container supports tags. Use the same spelling, capitalization, and punctuation across all shared release fields.

Set these fields for every track:

| Field        | Rule                                                                                                                                                                                                                                                        |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Title        | Track title only. Do not include the track number or artist.                                                                                                                                                                                                |
| Artist       | Credited performer for that track. Preserve featured-artist credits when verified.                                                                                                                                                                          |
| Album Artist | Primary release artist; use `Various Artists` for a compilation.                                                                                                                                                                                            |
| Album        | Release title exactly as verified, without label, year, or catalog decorations.                                                                                                                                                                             |
| Catalog      | Label catalog number, preserving meaningful punctuation and spacing. Omit when genuinely unknown or not applicable.                                                                                                                                         |
| Label        | Imprint that issued the specific release variant. Omit when unknown or self-released without a named imprint. For FLAC, write the same value to both `ORGANIZATION` and `LABEL` for reader compatibility.                                                   |
| Year         | Four-digit year of the specific release variant. For FLAC, store the year in both `DATE` and `YEAR`; store a verified full date separately in `RELEASEDATE` as `YYYY-MM-DD`. Do not put the full date in `DATE`.                                            |
| Track        | Disc-local track number plus total, such as `1/4`. Preserve vinyl positions such as `A1` in the filename, but use numeric embedded track numbers unless the tag format explicitly supports positions.                                                       |
| BPM          | Verified or consistently analyzed tempo as a number. Omit rather than guess; do not silently round a known decimal value.                                                                                                                                   |
| Genre        | Broad musical category. Use a concise, consistent value or list supported by the release evidence.                                                                                                                                                          |
| Style        | More specific style or subgenre. Store as a custom `STYLE` field where no native field exists. For FLAC, use one `STYLE` comment; join multiple verified styles with `; ` rather than writing repeated `STYLE` comments. Do not duplicate Genre by default. |
| Comment      | Only provenance or release-specific notes that are useful in the archive. Remove downloader, encoder, marketplace, URL, and promotional boilerplate unless the user asks to retain it.                                                                      |
| Composer     | Verified songwriter or composer credit. Omit when unknown; do not copy Artist into Composer without evidence.                                                                                                                                               |
| Disc Number  | Disc number plus total, such as `1/2`. Use `1/1` for a single-disc release when supported consistently by the target format.                                                                                                                                |
| Compilation  | Set true only for a various-artists compilation; otherwise set false or remove a stale true value.                                                                                                                                                          |
| Artwork      | Embed the selected front cover in every tag-capable track. Prefer the highest-quality genuine cover available locally; identify it as front cover and avoid embedding unrelated scans as the primary image.                                                 |

Title, Artist, Album Artist, Album, Year, Track, Disc Number, Compilation, and Artwork are required for a fully formatted release. Catalog and Label are also required when the release has them. BPM, Genre, Style, Comment, and Composer are conditional: preserve or set them only from defensible evidence. Never write `Unknown`, `N/A`, an empty string, or inferred credits merely to populate a field.

Map canonical fields to the format's native tags where possible. Use conventional custom fields such as `CATALOGNUMBER` and `STYLE` when a container has no native equivalent. Preserve multi-value artist and genre data when supported instead of flattening it inconsistently. The FLAC compatibility aliases above are intentional exceptions: keep their values identical and verify each alias explicitly. If a format cannot represent a field reliably, keep a sidecar only when one already exists or the user requests it, and report the limitation.

Before writing, record the original tags and, for FLAC, the STREAMINFO MD5. Preserve unrelated useful fields such as ISRC, MusicBrainz identifiers, purchase metadata, and replay-gain values unless they conflict with verified release data. Never transcode audio to change metadata.

## Verification

Treat verification as a comparison against the approved metadata plan, not as a tag dump that merely completed without error.

For every changed FLAC:

1. Read raw Vorbis comments with `metaflac --list --block-type=VORBIS_COMMENT` or `metaflac --export-tags-to=-`. Use this native readback to verify exact field names and occurrence counts. Do not infer storage correctness solely from ffprobe aliases such as `track` or `disc`.
2. Require exactly one value for scalar fields such as `TITLE`, `ARTIST`, `ALBUMARTIST`, `ALBUM`, `TRACKNUMBER`, `TRACKTOTAL`, `DISCNUMBER`, `DISCTOTAL`, `COMPILATION`, and `CATALOGNUMBER`. Remove duplicate identical values as well as conflicting ones.
3. When known, require `ORGANIZATION` and `LABEL` to occur once each with identical label values. Require `DATE` and `YEAR` to occur once each with the same four-digit year. If the full date is known, require one ISO `RELEASEDATE`. Require one `STYLE` comment containing the planned semicolon-separated value.
4. Inspect PICTURE blocks with `metaflac --list --block-type=PICTURE`. Require exactly one type-3 front cover unless the plan explicitly calls for additional artwork; verify its MIME type, dimensions, and description or role.
5. Cross-check the tags with `ffprobe` or `exiftool`. Account for reader normalization, but treat disagreement with the native readback as a failure to investigate.
6. Compare the post-write STREAMINFO MD5 with the recorded pre-write value and run `flac --test` on the file. Any changed audio checksum or failed integrity test is a failure.

After per-file checks, compare shared fields across the release, compare per-track fields and totals with the plan, inspect final filenames and folder naming, confirm the destination does not contain unintended files, and list sidecars intentionally retained.

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

When sources disagree, prefer the source that best covers the disputed field. If the release variant remains ambiguous, do not guess a tag value, catalog number, or label. Propose conservative metadata and naming with unknown optional parts omitted, and mention the ambiguity.

## Safe Rename Policy

Before moving or renaming, check whether the destination already exists. If it does, stop and report the conflict unless the user explicitly asks to merge.

For ambiguous inputs, propose a path instead of editing. Ambiguity includes multiple plausible releases, missing year, conflicting label/catalog evidence, or a folder containing files from more than one release.
