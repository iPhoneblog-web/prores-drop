# ProRes Drop: Anleitung

ProRes Drop macht aus einem ProRes-Export von Final Cut eine MP4-Datei fürs Web: HEVC in 4K mit
etwa 4,5 Mbit/s, so klein, dass ein Videoserver sie ohne neues Kodieren veröffentlichen kann.
Die App rechnet auf dem Media-Chip des Macs; auf einem M2 Max dauert eine Minute 4K etwa
20 Sekunden.

## Installieren

1. [ProRes-Drop.dmg](../../../releases/latest/download/ProRes-Drop.dmg) laden und öffnen.
2. **ProRes Drop** auf **Programme** ziehen. Danach das Fenster schließen und „ProRes Drop“ in
   der Finder-Seitenleiste auswerfen.
3. Einmal doppelklicken. macOS sagt, es könne die App nicht prüfen, weil sie nicht von einem
   registrierten Entwickler kommt. Auf **Fertig** klicken.
4. **Systemeinstellungen → Datenschutz & Sicherheit**, ganz nach unten: bei „ProRes Drop wurde
   blockiert“ auf **Dennoch öffnen** klicken und mit dem Passwort bestätigen.
5. Beim ersten Start fragt die App, ob sie Mitteilungen senden darf: **Erlauben**. Ohne
   Mitteilungen erfährst du nicht, wann eine Datei fertig ist; das Fenster zeigt dann einen
   Hinweis mit **Einschalten …**.

Danach startet die App wie jede andere. Für eine neue Version: wieder die DMG laden und die App
in Programme ersetzen; die Einstellung bleibt.

Die App braucht einen Mac mit Apple-Chip (M1 oder neuer) und macOS 14 oder neuer.

## Benutzen

- In Final Cut wie gewohnt als ProRes exportieren (ProRes 422 oder 422 HQ, 4K).
- Die Datei aufs Fenster ziehen oder aufs Symbol im Dock. Mehrere Dateien gehen auch; sie
  laufen nacheinander.
- Das Dock-Symbol zeigt den Fortschritt, die Zahl daran, wie viele Dateien noch offen sind.
- Ist eine Datei fertig, kommt eine Mitteilung. **Im Finder zeigen** öffnet den Ordner mit der
  fertigen Datei.
- Die fertige `.mp4` hochladen. Die ProRes-Datei brauchst du dafür nicht mehr.

Der Mac schläft während der Umwandlung nicht ein.

## Einstellung

Es gibt genau eine: **ProRes Drop → Einstellungen …** (⌘,) legt fest, wohin die fertigen
Dateien kommen. Vorgabe ist `Filme/ProRes Drop`; fehlt der Ordner, legt die App ihn an. Eine
vorhandene Datei wird nie überschrieben: die zweite heißt dann `Folge 123 2.mp4`.

## Wenn etwas schiefgeht

- **„Das ist keine Videodatei.“** oder **„Dieses Videoformat (…) kann der Mac nicht lesen.“**:
  Die Datei ist kein Video, das macOS öffnen kann. Neu aus Final Cut exportieren.
- **„Der Zielordner ist nicht erreichbar“**: Der Ordner liegt auf einem Laufwerk, das nicht
  angeschlossen ist. In den Einstellungen einen anderen wählen.
- Alles andere: ein [Issue](../../../issues) öffnen, mit einem Bildschirmfoto der Meldung.
