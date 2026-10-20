# ProRes Drop: Anleitung für Alex

ProRes Drop macht aus einem ProRes-Export von Final Cut eine MP4-Datei, die der Server von
iPhoneBlog.de so nimmt, wie sie ist. Ein 5-Minuten-Video ist dann wenige Minuten nach dem
Hochladen in 4K online, statt nach einer halben Stunde.

## Installieren

1. `ProRes-Drop-1.0.zip` doppelklicken. Es entsteht `ProRes Drop.app`.
2. `ProRes Drop.app` in den Ordner **Programme** ziehen.
3. Einmal doppelklicken. macOS sagt, es könne die App nicht prüfen, weil sie nicht von einem
   registrierten Entwickler kommt. Auf **Fertig** klicken.
4. **Systemeinstellungen → Datenschutz & Sicherheit**, ganz nach unten: bei „ProRes Drop wurde
   blockiert“ auf **Dennoch öffnen** klicken und mit dem Passwort bestätigen.
5. Beim ersten Start fragt die App, ob sie Mitteilungen senden darf: **Erlauben**. Ohne
   Mitteilungen erfährst du nicht, wann eine Datei fertig ist; das Fenster zeigt dann einen
   Hinweis mit **Einschalten …**.

Danach startet die App wie jede andere.

## Benutzen

- In Final Cut wie gewohnt als ProRes exportieren (ProRes 422 oder 422 HQ, 4K).
- Die Datei aufs Fenster ziehen oder aufs Symbol im Dock. Mehrere Dateien gehen auch; sie
  laufen nacheinander.
- Das Dock-Symbol zeigt den Fortschritt, die Zahl daran, wie viele Dateien noch offen sind.
- Ist eine Datei fertig, kommt eine Mitteilung. **Im Finder zeigen** öffnet den Ordner mit der
  fertigen Datei.
- Die fertige `.mp4` im Upload-Center hochladen (upload.iphoneblog.de). Die ProRes-Datei
  brauchst du dafür nicht mehr.

Auf Thorstens M2 Max brauchte eine Minute 4K 20 Sekunden; auf deinem M2 sollte es ähnlich
schnell gehen. Der Mac schläft während der Umwandlung nicht ein.

## Einstellung

Es gibt genau eine: **ProRes Drop → Einstellungen …** (⌘,) legt fest, wohin die fertigen
Dateien kommen. Vorgabe ist `Filme/iPhoneBlog Uploads`; fehlt der Ordner, legt die App ihn an.
Eine vorhandene Datei wird nie überschrieben: die zweite heißt dann `Folge 123 2.mp4`.

## Wenn etwas schiefgeht

- **„Das ist keine Videodatei.“** oder **„Dieses Videoformat (…) kann der Mac nicht lesen.“**:
  Die Datei ist kein Video, das macOS öffnen kann. Neu aus Final Cut exportieren.
- **„Der Zielordner ist nicht erreichbar“**: Der Ordner liegt auf einem Laufwerk, das nicht
  angeschlossen ist. In den Einstellungen einen anderen wählen.
- Alles andere: die Meldung abfotografieren und an Thorsten schicken.
