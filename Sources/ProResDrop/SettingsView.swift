import SwiftUI

/// The one setting: the destination folder.
struct SettingsView: View {
    @Environment(Destination.self) private var destination

    var body: some View {
        Form {
            LabeledContent("Zielordner") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(destination.displayPath)
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                    HStack {
                        Button("Ändern …") { destination.choose() }
                        Button("Im Finder zeigen") { destination.reveal() }
                        if !destination.isDefault {
                            Button("Standard") { destination.reset() }
                                .help("Zurück zu ~/Movies/ProRes Drop")
                        }
                    }
                }
            }
            Text("Hier landen die fertigen MP4-Dateien. Fehlt der Ordner, legt die App ihn an.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 500)
    }
}
