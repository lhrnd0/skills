# Issue tracker: Backlog.md

Issues and specs live in Backlog.md under `<backlog-directory>`.

<!-- shared -->
Share the backlog through normal Git commits and pushes.
<!-- /shared -->
<!-- local -->
Keep the backlog files and task references local.
<!-- /local -->

Run `backlog instructions overview` before working with tasks.

## Conventions

- Publish an issue or spec with `backlog task create "<title>" --desc "<body>"`.
- Fetch a ticket with `backlog task view <id> --plain`.
- List tickets with `backlog task list --plain`.
- Create a child task with `backlog task create "<title>" --parent <id>`.
- Set blockers with `backlog task edit <id> --dep <comma-separated-blocker-ids>`. Include any existing blockers that still apply.
- Add or remove labels with `backlog task edit <id> --add-label <label>` or `backlog task edit <id> --remove-label <label>`.
- Add a comment with `backlog task edit <id> --comment "<text>"`.
- Mark verified work done with `backlog task edit <id> --status "<final-status>"`. Read the configured statuses with `backlog config get statuses`.

## Wayfinding operations

Use a task labelled `wayfinder:map` for the map. Keep Notes, Decisions-so-far, and Fog in its description.

- Create child tasks with `--parent <map-id>` and label them `wayfinder:<type>`.
- List child tasks with `backlog task list --parent <map-id> --plain`. Choose the first open and unclaimed task whose blockers reached the final status.
- Claim the task by setting its status to `In Progress` or the repo's equivalent.
- Record the answer with `backlog task edit <id> --final-summary "<answer>"`. Set the final status and add a reference to the answer in the map.
