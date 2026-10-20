import AppKit
import DropCore
import Observation
import os
@preconcurrency import UserNotifications

/// `log show --predicate 'subsystem == "de.iphoneblog.prores-drop"'` shows what the app did.
let log = Logger(subsystem: "de.iphoneblog.prores-drop", category: "app")

/// A macOS notification when a file is done or failed. "Im Finder zeigen" on a finished one, and
/// a click on the notification itself, select the file in Finder. When Alex has not allowed
/// notifications, `allowed` is false and the window says so.
@MainActor
@Observable
final class Notifier: NSObject {
    nonisolated private static let doneCategory = "done"
    nonisolated private static let revealAction = "reveal"
    nonisolated private static let pathKey = "path"

    /// True until macOS says otherwise, so the hint never flashes at launch.
    private(set) var allowed = true

    @ObservationIgnored private var center: UNUserNotificationCenter { .current() }

    func setUp() {
        center.delegate = self
        let reveal = UNNotificationAction(identifier: Self.revealAction, title: "Im Finder zeigen", options: [.foreground])
        center.setNotificationCategories([
            UNNotificationCategory(identifier: Self.doneCategory, actions: [reveal], intentIdentifiers: []),
        ])
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            log.notice("notifications allowed: \(granted, privacy: .public) \(error?.localizedDescription ?? "", privacy: .public)")
            Task { @MainActor in self.allowed = granted }
        }
        // Alex may switch them on in System Settings while the app runs.
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil,
                                               queue: .main) { _ in
            Task { @MainActor in self.refresh() }
        }
    }

    func refresh() {
        center.getNotificationSettings { settings in
            let ok = [.authorized, .provisional].contains(settings.authorizationStatus)
            Task { @MainActor in self.allowed = ok }
        }
    }

    /// System Settings, Notifications, this app.
    func openSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=de.iphoneblog.prores-drop")!
        NSWorkspace.shared.open(url)
    }

    func done(source: URL, result: EncodeResult) {
        let content = UNMutableNotificationContent()
        content.title = "Fertig: \(result.output.lastPathComponent)"
        content.body = "\(Format.bitRate(result.bitRate)), \(Format.duration(result.duration)). Bereit zum Hochladen."
        content.sound = .default
        content.categoryIdentifier = Self.doneCategory
        content.userInfo = [Self.pathKey: result.output.path]
        post(content)
    }

    func failed(source: URL, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Fehlgeschlagen: \(source.lastPathComponent)"
        content.body = message
        content.sound = .default
        content.userInfo = [Self.pathKey: source.path]
        post(content)
    }

    private func post(_ content: UNNotificationContent) {
        let title = content.title
        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)) { error in
            log.notice("notification \(title, privacy: .public): \(error?.localizedDescription ?? "posted", privacy: .public)")
        }
    }
}

extension Notifier: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        guard [Self.revealAction, UNNotificationDefaultActionIdentifier].contains(response.actionIdentifier),
              let path = response.notification.request.content.userInfo[Self.pathKey] as? String else { return }
        let url = URL(fileURLWithPath: path)
        await MainActor.run {
            if FileManager.default.fileExists(atPath: url.path) {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }
}
