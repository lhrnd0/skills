---
name: tag-music-release
description: Guide the user through a Rekordbox star rating and set-phase, mood, vibe, and instrument tags for a release or track, written so Rekordbox search finds it by feel.
disable-model-invocation: true
---

# Tag Music Release

Turn the user's own impressions of each track into a star **rating** and a **tag line**: one searchable line in the comment. Later, a Rekordbox search such as `afro dirty congas` narrows the library to the tracks that share that feel.

The user dictates every tag. Words come only from [references/vocabulary.md](references/vocabulary.md), the single source of truth for the rating scale and the four tag categories.

## Requirements

- `metaflac` and `flac` from Homebrew package `flac`, to write and test FLAC files.
- `ffmpeg` and `ffprobe` from Homebrew package `ffmpeg`, to read audio and write other containers.
- `uv`, to run [scripts/mp3-tags.py](scripts/mp3-tags.py) for MP3 files.

If a tool is missing, stop and tell the user to run `brew install flac ffmpeg uv`.

## Rating

Write the stars to three places:

- MP3: `scripts/mp3-tags.py` writes the ID3 `POPM` byte. 0 stars removes the frame.
- FLAC: one `RATING` field on the 0–100 scale: 20, 40, 60, 80, 100 for 1 to 5 stars. 0 stars removes the field.
- Every format: a `Rating:<stars>` token at the start of the tag line, so Rekordbox search finds it.

Rekordbox shows stars in its Rating column only from the MP3 `POPM` frame. It reads no FLAC rating field, and it writes stars to no file (tested with rekordbox 7.2.16). For every format except MP3, list the stars in the output, so the user sets them in Rekordbox.

## Tag line

Build the tag line in vocabulary order: the `Rating:<stars>` token, set phase, mood, vibes, instruments, and file order within each category. Join every item with `; `. Omit a category the user leaves empty.

```text
Rating:4; Build; Floating / Dreamy; Afro; Arpeggiated; Dirty; Electro; Congas; Sweeps; Pads; Chanting
```

When the existing comment holds a provenance note (see the `format-music-release` archive rules), keep it after the tag line, separated by ` | `. When it holds an older tag line, replace that part only.

## Genre

The genre round overrides `GENRE` and `STYLE`, which `format-music-release` sets from researched classification. Show each track's current `GENRE` and `STYLE`, and flag a track where they differ. `keep` is the default. An override is free text with classifications joined by `; `, such as `House; Deep House`, and writes the same value to both fields. The vocabulary has no genre list; offer the genres already on the release's tracks as numbered choices.

## Guided tagging

Run one round per category, in this order: rating, genre, set phase, mood, vibes, instruments. Each round is one message to the user, then one answer back.

1. Show the round, the numbered track list with each track's current value, and the category's full numbered vocabulary. Read the vocabulary from `references/vocabulary.md` at the start of every round, so new words appear.

   ```text
   Round 4 of 6: Mood (any number per track)

   Tracks: 1. Ngeke (Andhim Remix) [none]   2. Yeke Yeke [Happy]

   1. Aggressive   2. Dark   3. Emotional / Introspective   4. Floating / Dreamy   5. Happy

   Reply with numbers or words, for all tracks or per track:
   all: 4   2: +5   — or a custom word, or skip
   ```

2. Take the answer. `all:` applies to every track; `<n>:` sets one track; `+` adds to the `all:` value. Rating takes exactly one value per track, from 0 to 5. Genre takes `keep` or one override per track. The other rounds take any number of words, or `skip`.

3. Map each word to the vocabulary:
   - A number or an exact or case-different match uses the vocabulary spelling.
   - A synonym of an existing word uses the existing word. Name the mapping in the round result.
   - A custom word needs the user's approval. Tags name qualities of the track; when a word is a verdict (`fire`, `banger`), ask which quality it means. When approved, add it to its category in `references/vocabulary.md`. The rating scale takes no custom words.

4. Show the round result per track in one line each, then start the next round.

Round completion criterion: every track has a value, `keep`, or an explicit `skip`, and every custom word is approved or replaced.

## Workflow

1. Confirm the target path exists. List its audio files in track order, and read each file's `TITLE`, `ARTIST`, `GENRE`, `STYLE`, every comment value, and the rating.
   - FLAC: `metaflac --export-tags-to=-`; the rating is in `RATING`. A comment lives in `COMMENT` or `DESCRIPTION`: ffmpeg and some taggers write `DESCRIPTION`.
   - MP3: `scripts/mp3-tags.py read <file>` for comments, rating, `GENRE` (`TCON`), and `STYLE` (`TXXX:STYLE`); it also reports the `TXXX:comment` frame ffmpeg writes. `ffprobe` for the other fields.
   - Other formats: `ffprobe -show_entries format_tags`.

   Completion criterion: every track is listed with its current comment values, the field that holds each, its current stars, and its current `GENRE` and `STYLE`.

2. Run the [guided tagging](#guided-tagging). Completion criterion: all six rounds are done for every track.

3. Present the plan: for each track, the current and planned comment, stars, and genre. Mark tracks whose stars the user must set in Rekordbox. Wait for the user's approval. Completion criterion: the user approved the exact comment, stars, and genre of every track.

4. Record each file's audio checksum: the STREAMINFO MD5 for FLAC (`metaflac --show-md5sum`), and the decoded audio hash (`ffmpeg -i <file> -map 0:a -f md5 -`) for every other format. Then write the approved values, and leave every other field and the audio untouched.
   - FLAC: `metaflac --remove-tag=COMMENT --remove-tag=RATING --set-tag="COMMENT=<value>" --set-tag="RATING=<0-100>"`; omit the `RATING` set for 0 stars. For a genre override, add `--remove-tag=GENRE --remove-tag=STYLE --set-tag="GENRE=<genre>" --set-tag="STYLE=<genre>"`. When step 1 found the comment in `DESCRIPTION`, add `--remove-tag=DESCRIPTION` so one comment remains.
   - MP3: `scripts/mp3-tags.py write <file> --comment "<value>" --stars <n>`, plus `--genre "<genre>"` for an override. It edits the ID3 tag in place.
   - Other formats: write a temporary copy with `ffmpeg -i <src> -map 0 -c copy -map_metadata 0 -metadata comment="<value>" <tmp>`; for a genre override, add `-metadata genre="<genre>" -metadata STYLE="<genre>"`. MP4 containers (M4A) keep `genre` and drop `STYLE`; report that limitation rather than adding `-movflags use_metadata_tags`, which copies container fields such as `major_brand` into the tags. Replace the source only after step 5 passes for the copy.

5. Verify every changed file.
   - FLAC: `metaflac --export-tags-to=-` shows exactly one `COMMENT` with the approved value, exactly one `RATING` with the approved value, or none for 0 stars, and exactly one identical `GENRE` and `STYLE`. The STREAMINFO MD5 is unchanged, and `flac --test` passes.
   - MP3: `scripts/mp3-tags.py read` shows exactly one comment with the approved value, in `COMM::eng`, the approved stars, and identical `GENRE` and `STYLE`. The decoded audio hash is unchanged.
   - Other formats: `ffprobe` shows the approved comment, and the approved genre, plus style outside MP4, for an override. The decoded audio hash of the copy matches the source.

   Completion criterion: every changed file passes its checks, and every other tag keeps its pre-write value.

## Output

Report:

- Each track with its written tag line, stars, and genre, marking genre overrides.
- The tracks whose stars the user must set in Rekordbox by hand, with the stars for each.
- Vocabulary mappings applied and words added to `references/vocabulary.md`.
- Verification result per file.
- A reminder: for tracks already in Rekordbox, select them and run **Reload Tag** so the search sees the new comments and genres.
