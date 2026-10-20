import AppKit
import Observation

/// The one setting: where finished files go. Kept as a bookmark, so a folder Alex renames or
/// moves is still found. The app is not sandboxed, so the bookmark needs no security scope.
@MainActor
@Observable
final class Destination {
    private static let key = "destinationBookmark"

    static var defaultFolder: URL {
        let movies = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Movies")
        return movies.appendingPathComponent("iPhoneBlog Uploads", isDirectory: true)
    }

    private(set) var folder: URL

    init() {
        // `-destinationPath <dir>` on the command line wins and is not stored: a test run of the
        // app writes where the tester says, never into ~/Movies (AGENTS.md, "Try the app").
        if let path = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)["destinationPath"] as? String {
            folder = URL(fileURLWithPath: path, isDirectory: true)
        } else {
            folder = Self.resolve() ?? Self.defaultFolder
        }
    }

    var isDefault: Bool { folder.standardizedFileURL == Self.defaultFolder.standardizedFileURL }

    /// The folder as a person reads it: `~/Movies/iPhoneBlog Uploads`.
    var displayPath: String {
        (folder.path as NSString).abbreviatingWithTildeInPath
    }

    func set(_ url: URL) {
        folder = url
        if let data = try? url.bookmarkData() {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    func reset() {
        folder = Self.defaultFolder
        UserDefaults.standard.removeObject(forKey: Self.key)
    }

    func choose() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = folder
        panel.prompt = "Auswählen"
        panel.message = "Wohin sollen die fertigen Dateien?"
        if panel.runModal() == .OK, let url = panel.url { set(url) }
    }

    func reveal() {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        NSWorkspace.shared.activateFileViewerSelecting([folder])
    }

    private static func resolve() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &stale) else { return nil }
        if stale, let fresh = try? url.bookmarkData() {
            UserDefaults.standard.set(fresh, forKey: key)
        }
        return url
    }
}
