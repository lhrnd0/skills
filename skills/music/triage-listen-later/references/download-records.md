# Download record format

Render one canonical record body for both the Reader document note and the optional wishlist entry. Omit unknown scalar fields and empty list sections rather than guessing. Preserve every useful source, listening, acquisition, and evidence link.

## Canonical record body

Follow this order and field wording:

```markdown
### {position}/{total} · {artist — track or source title}

**Original source:** [{host or descriptive label}]({source_url})
**Reader:** [App](wiseread://read/{document_id}) · [Web]({reader_url})
{source author/channel · duration when known · saved relative date}
**Queued for download:** {YYYY-MM-DD}

**What it is:** {2–4 sentence identification and listening context}

**Release context:** {release/album title · original release date · label · catalog number · country · format, as supported; explain conflicting dates or editions}

**Why it may be worth acquiring:** {specific musical, historical, label, scene, version, format, or availability rationale grounded in the sources}

**Why pass:** {honest reason the item or available edition may not justify the user's time or money}

**Listen:** [{source label}]({source_url}) · [{alternate official stream}]({URL})

**Download search suggestions:**

- Soulseek or equivalent: `{artist} - {track title}`
- Release search: `{artist} {release title} {label}`
- Catalog search: `{artist} {release title} {catalog number}`

**Find online:**

- [{store or source}]({direct URL}) — {purchase/download formats and useful availability details}
- [{store or source}]({direct URL}) — {purchase/download formats and useful availability details}

**Release evidence:**

- [{database, artist, label, distributor, or store}]({URL}) — {identity, tracklist, date, label, catalog, format, or availability evidence}
- [{database, artist, label, distributor, or store}]({URL}) — {identity, tracklist, date, label, catalog, format, or availability evidence}

**Match confidence:** {High | Medium | Low} — {agreement across artist, title, duration, release, label, and catalog evidence; name unresolved conflicts}
```

Use the local calendar date for `Queued for download`. Keep the original date when refreshing an existing wishlist entry. Keep search suggestions in inline code so they remain copyable.

## Reader note

Preserve the existing document note. Append the rendered canonical body with one blank line of separation and these exact wrapper markers, or replace the existing marked block in place:

```markdown
<!-- triage-listen-later:download -->
{canonical record body}
<!-- /triage-listen-later:download -->
```

## Wishlist entry

Key entries by Reader document ID. Append a rendered canonical body with two blank lines of separation and these exact wrapper markers, or replace the entry enclosed by the matching markers. Preserve unrelated file content. When the file is empty, begin it with `# Music Download Wishlist` followed by a blank line.

```markdown
<!-- triage-listen-later:wishlist:{document_id} -->
{canonical record body}
<!-- /triage-listen-later:wishlist:{document_id} -->
```

Keep field labels, section order, and marker syntax exact so humans can scan records consistently and agents can locate or update them deterministically.
