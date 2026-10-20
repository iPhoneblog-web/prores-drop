# TODO

Open work, most important first. Delete an item when it is done.

- **Put the repository on GitHub.** It exists only in `~/localprojects/prores-drop` on
  Thorsten's Mac: on 2026-10-20 the agent's `gh repo create` was refused by its permission
  check. Thorsten runs, in that checkout:
  `gh repo create iPhoneblog-web/prores-drop --private --source . --remote origin --push`,
  then `git push origin v1.0` and
  `gh release create v1.0 dist/ProRes-Drop-1.0.zip --title "ProRes Drop 1.0" --notes-file docs/anleitung.md`
  after `bin/package`.
- **Check against the server's acceptance rule once it lands.** The remux of an HEVC 4K upload
  is decided (infra `docs/TODO.md`, "Uploads without a kept master") but not yet in
  `roles/encoder/files/video-encode` (origin/main e26df02, 2026-10-20). Read the rule, run one
  app output through it on `encoder`, and correct [encoding.md](encoding.md) and `Plan.swift`
  if the bound, the audio or the size differs.
- **Look at the Dock tile, the badge and a notification once.** Agents had no screen on
  2026-10-20: the queue, the files and the posting were checked from the shell and the log, the
  progress bar on the Dock icon, the badge and "Im Finder zeigen" were not. macOS on Thorsten's
  Mac holds notifications for `de.iphoneblog.prores-drop` as not allowed, because the first
  prompt was dismissed; allow them in System Settings → Notifications to see one.
- **Alex's first real export**: encode time on his M2, the file's bit rate, and whether the
  server remuxes it. The numbers go into [encoding.md](encoding.md), "Measured".
- **Developer ID and notarisation**, if the Gatekeeper step in [anleitung.md](anleitung.md) is
  too much for Alex. Needs Apple Developer Program membership and Thorsten's yes; then
  `bin/package` signs with the identity and runs `notarytool`.
- **HDR sources** (HLG or PQ from an iPhone timeline) are untested: the colour tags pass
  through, the HDR metadata may not.
