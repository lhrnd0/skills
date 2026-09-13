---
name: brewfile-refresher
description: Refresh a Brewfile from explicitly installed Homebrew packages while preserving its organization and comments.
---

# Brewfile Refresher

Use only when explicitly invoked as `brewfile-refresher` or `brewfile-refresher [brewfile-path]`.

## Workflow

1. Resolve the target:
   - With no path, use `./Brewfile` in the current working directory.
   - With a path, use that exact file after normal shell path expansion.
   - Require an existing regular file. Follow an existing symlink without replacing the link itself.

   Read the entire Brewfile before changing it. Map every active or commented package entry to its surrounding headings, explanatory comments, and blank-line grouping. Completion criterion: every existing entry and comment has a known place in the file's organization.

2. Build a comparison snapshot in a temporary directory with `brew bundle dump --no-describe --file=<temporary-Brewfile>`. Use it as inventory and syntax reference, never as replacement content.

   Register only formulae and casks. Treat only formulae reported by `brew list --formula --installed-on-request --full-name` as explicitly installed. Build a set of installed cask tokens with `brew list --cask`. For a cask in the snapshot, read its modern receipt under `$(brew --caskroom)/<token>/.metadata/INSTALL_RECEIPT.json`; add it as a new entry only when `installed_on_request` is `true`. A missing receipt is an unknown explicitness classification, never proof that a cask is absent. Do not use `brew leaves`: a formula can be explicitly installed and also serve as another package's dependency. Ignore every other snapshot entry type: do not add, classify, or reactivate it from the installed inventory.

   Match supported entries by package type and canonical identity, accounting for aliases and fully qualified names. For every active cask already in the target, classify it from the installed-cask set: absent; installed and explicitly requested when its modern receipt says `installed_on_request: true`; installed but not explicitly requested when that receipt says `false`; or installed with explicitness unknown when its receipt is missing or legacy. Do not infer absence from either a missing receipt or omission from the snapshot. Do not add a previously unrepresented cask whose only evidence is missing or legacy metadata; report it as installed with explicitness unknown. Preserve existing entries of other types unchanged. Completion criterion: every formula or cask snapshot entry is classified as already active, intentionally commented by the user, disabled by a prior refresh, or new; every active existing formula or cask is classified as currently installed or absent; and every active existing cask has a presence and explicitness classification.

3. Merge into the existing file in place:
   - Keep every heading, explanatory comment, blank-line grouping, entry order, and option on retained entries.
   - Insert each new entry into the best matching existing category, following that category's ordering and comment style. Create a minimal new category only when the file consistently uses categories and none fits.
   - Convert an active formula absent from its installed inventory into a comment. Convert an active cask only when its canonical token is absent from `brew list --cask`. Preserve its full original text and append ` | brewfile-refresher: not installed at refresh YYYY-MM-DD`, using the local refresh date. Never delete the entry.
   - Retain every active cask listed by `brew list --cask`; report one with missing or legacy receipt metadata as `installed, explicitness unknown`.
   - Keep user-authored commented entries unchanged. When a formula or cask disabled by a prior refresh is installed again, reactivate its original text and remove only the `brewfile-refresher` marker.
   - Avoid duplicate entries. A user-authored commented entry counts as an intentional representation and should not also be added as active.

4. Validate the edited file with `brew bundle list --all --file=<target>`. Then inspect the complete diff against the pre-refresh content. Completion criterion: the Brewfile parses; every explicitly installed formula and eligible cask is represented without duplicates; every previously active cask still listed by `brew list --cask` is represented; every previously active absent formula or cask is commented with today's marker; no pre-existing comment, category, or package line was removed; and changes are confined to the target.

5. Report the target path, additions, reactivations, newly commented entries, active casks retained with unknown explicitness, and unchanged user-commented entries. State when no changes were needed.

A refresh changes only the Brewfile. Leave installed packages and Homebrew configuration unchanged.
