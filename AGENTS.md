# AGENTS.md

Rules for agents changing this repository. [README.md](README.md) explains what ProRes Drop is
and how to build it; read it next, then only the page your task needs. The server it feeds is
built by the `infra` repository (`~/localprojects/infra`, its own `AGENTS.md`, `docs/video.md`).

## 1. Always

- **Write in English**, through `/anthropic-skills:plain-english`: pages, commit messages,
  answers to Thorsten. The app's screens, its messages and [docs/anleitung.md](docs/anleitung.md)
  are German, because Alex uses them.
- **The server decides the format.** Every number in `Plan.swift` follows infra's
  `roles/encoder/files/video-encode` and its decisions; [docs/encoding.md](docs/encoding.md)
  names the source of each. Change a number there first, with the measurement that justifies it.
  Never guess a different one: ask Thorsten.
- **Run `bin/package` before you push**: the tests, the release build, the signed bundle.
- **Stage named paths.** Never `git add -A`, `git commit -a` or `git stash`.
- **No signing identity without Thorsten's yes.** `bin/package` signs ad hoc. The Apple
  Development certificate on Thorsten's Mac does not get past Gatekeeper on another Mac anyway.
- **Never install anything on Alex's Mac**, and never run the app against `~/Movies` on
  Thorsten's (§4).

## 2. Work in your own worktree

**`~/localprojects/prores-drop`, if it exists, is Thorsten's checkout.** No edits, commits or
branch switches there. Make your own under `~/worktrees` (`~/localprojects` syncs through
Synology Drive, and `/tmp` is empty after a restart):

```bash
git -C <any checkout> fetch origin
git -C <any checkout> worktree add ~/worktrees/prores-drop/<topic> -b <topic> origin/main
```

- **Every change is a pull request onto `main`.** Squash only, so one pull request is one commit.
  Never push to `main`.
- **A release is a tag `v<major>.<minor>`** on `main`; `bin/package` reads it into the bundle's
  version, and the zip goes onto the GitHub release of that tag.
- **When merged:** `git worktree remove ~/worktrees/prores-drop/<topic>` and
  `git branch -d <topic>`.

## 3. Commit messages

English, through `/anthropic-skills:plain-english`. The first line says what changed. The body
says why; where a number cost a measurement, the message keeps the measurement.

## 4. Tests and trying the app

**No change to `DropCore` is finished without a test** (`Tests/DropCoreTests`, XCTest).

- **A guard needs a test in which it fires**: a file that is not a video, a codec the Mac cannot
  decode, a cancel, a name that is taken, an index at the end.
- **Media tests read real files.** `Tests/DropCoreTests/fixtures/make.sh` makes them with
  ffmpeg; they are committed because they are small. Run it only to change them.
- **A change to the encode runs `bin/test-encode`** and puts its numbers into
  [docs/encoding.md](docs/encoding.md), "Measured", with the date and the Mac.
- **Try the app without touching `~/Movies`**: start it with a test folder, then hand it files
  the way the Dock does.

  ```bash
  open -n "dist/ProRes Drop.app" --args -destinationPath /path/to/test-folder
  open -a "$PWD/dist/ProRes Drop.app" some.mov
  /usr/bin/log show --last 5m --predicate 'subsystem == "de.iphoneblog.prores-drop"'
  ```

  `-destinationPath` is not stored. Quit the app by PID when done.

Say in the pull request which tests cover the change and what is still untested; the Dock tile
and the notification need a person looking at the screen.

## 5. Documentation

**A page describes how things are now. Git holds how they got there.**

| kind | where | lives until |
|---|---|---|
| Entry | `AGENTS.md`, `CLAUDE.md` (imports this file), `README.md` | always |
| Reference | `docs/<topic>.md`, one topic per page | the topic ends |
| Queue | `docs/TODO.md`, open work only | each item deleted when done |

No file for handovers, session notes, reviews or status reports. Present tense; a rule carries
its reason in a sentence or two; one fact, one home. **In the same commit**, a change updates
the page that describes it and deletes a finished TODO item.
