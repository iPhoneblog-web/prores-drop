# prores-drop

ProRes Drop is a small macOS app for Alex's Mac. He drops a ProRes export from Final Cut on its
window or its Dock icon; it makes the HEVC MP4 that iPhoneBlog.de's video pipeline takes as it is,
on the Mac's media engine, and says so with a notification. One setting: the folder where
finished files go.

**Download:** [ProRes-Drop.dmg](https://github.com/iPhoneblog-web/prores-drop/releases/latest/download/ProRes-Drop.dmg), the newest release, for Macs with Apple Silicon and
macOS 14 or later. All releases: [Releases](https://github.com/iPhoneblog-web/prores-drop/releases).
How to install it: [docs/anleitung.md](docs/anleitung.md), in German.

The server side is ADR-0005 in `iphoneblog-wordpress` and the encoder in `infra`
(`docs/video.md`, "The encode pipeline"). This app reads nothing from the server; it makes the
file the server's rule asks for.

| Page | Read it for |
|---|---|
| [docs/encoding.md](docs/encoding.md) | What comes out and why, the rate choice, the measurements |
| [docs/anleitung.md](docs/anleitung.md) | Alex's guide, in German: install, use, the one setting, errors |
| [docs/TODO.md](docs/TODO.md) | Open work |

## The code

Swift 6 (language mode 5), SwiftUI, AVFoundation and VideoToolbox, macOS 14 or later, Apple
Silicon. Swift Package Manager builds it; there is no Xcode project, so everything runs from the
terminal. No dependency outside Apple's frameworks.

```
bin/package          tests, release build, ProRes Drop.app signed ad hoc, dist/ProRes-Drop.dmg and .zip
bin/test-encode      a 4K ProRes sample through the app's encode, checked with ffprobe
swift test           the tests (needs the fixtures below, which are committed)
bin/make-icon        Resources/AppIcon.icns from tools/make-icon.swift
```

```
Sources/DropCore/          the encode: Plan (size, rates), Transcoder, Naming, DropError, MP4Boxes
Sources/ProResDrop/        the app: window, queue, Dock tile, notifications, Settings, destination
Sources/prores-drop-cli/   the same encode from the terminal, for bin/test-encode and experiments
Tests/DropCoreTests/       XCTest; fixtures/ holds small ffmpeg-made files (fixtures/make.sh)
Resources/                 Info.plist, the icon, de.lproj
tools/                     the icon drawing, the playability check
```

`prores-drop-cli <file> --out <dir>` encodes one file and prints the result as JSON;
`--avg`, `--peak` and `--window` try other rates without touching the app.

## Releases

A tag `v<major>.<minor>` on `main` is a release. `.github/workflows/build.yml` tests and builds
every push on a GitHub macOS runner; on a tag it also publishes `ProRes-Drop.dmg`,
`ProRes-Drop.zip` and `SHA256SUMS` as the release of that tag. The names carry no version, so
the download link above always gets the newest. `bin/package` builds the same files locally.

Alex downloads the DMG and follows [docs/anleitung.md](docs/anleitung.md). The app is signed ad
hoc, not with a Developer ID, so Gatekeeper blocks it once and Alex lets it in through System
Settings → Privacy & Security. Notarisation is in [docs/TODO.md](docs/TODO.md).

Nothing in this repository installs anything; an agent never installs the app on Alex's Mac.

## Where it logs

```
/usr/bin/log show --last 1h --predicate 'subsystem == "de.iphoneblog.prores-drop"'
```

One line per finished, failed or cancelled file, and whether macOS allows notifications. Type
`/usr/bin/log`, not `log`: zsh has a builtin of that name.
