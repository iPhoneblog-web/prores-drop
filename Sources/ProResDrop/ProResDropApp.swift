import AppKit
import SwiftUI

@main
struct ProResDropApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Window("ProRes Drop", id: "main") {
            ContentView()
                .environment(delegate.queue)
                .environment(delegate.destination)
                .environment(delegate.notifier)
        }
        .defaultSize(width: 520, height: 480)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Datei wählen …") { delegate.chooseFiles() }
                    .keyboardShortcut("o")
            }
        }

        Settings {
            SettingsView()
                .environment(delegate.destination)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let destination = Destination()
    let notifier = Notifier()
    private(set) lazy var queue = JobQueue(destination: destination, notifier: notifier, dock: dock)
    private let dock = DockProgress()

    func applicationDidFinishLaunching(_ notification: Notification) {
        notifier.setUp()
    }

    /// Files dropped on the Dock icon, or opened with the app from Finder.
    func application(_ application: NSApplication, open urls: [URL]) {
        queue.add(urls)
    }

    /// The window can close; the app keeps working and keeps taking files on its Dock icon.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard queue.isBusy else { return .terminateNow }
        let alert = NSAlert()
        alert.messageText = "Es läuft noch eine Umwandlung."
        alert.informativeText = "Wenn du jetzt beendest, ist sie verloren und die Warteschlange auch."
        alert.addButton(withTitle: "Weiter umwandeln")
        alert.addButton(withTitle: "Beenden")
        if alert.runModal() == .alertSecondButtonReturn {
            queue.cancelAll()
            return .terminateNow
        }
        return .terminateCancel
    }

    func chooseFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie]
        panel.prompt = "Umwandeln"
        panel.message = "ProRes-Dateien zum Umwandeln wählen"
        if panel.runModal() == .OK { queue.add(panel.urls) }
    }
}
