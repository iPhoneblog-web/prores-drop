import AppKit
import DropCore
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(JobQueue.self) private var queue
    @Environment(Destination.self) private var destination
    @Environment(Notifier.self) private var notifier
    @State private var targeted = false

    var body: some View {
        VStack(spacing: 0) {
            dropZone
                .padding(16)
            if !queue.jobs.isEmpty {
                Divider()
                List {
                    ForEach(queue.jobs) { job in
                        JobRow(job: job)
                    }
                }
                .listStyle(.inset)
            } else {
                Spacer(minLength: 0)
            }
            if !notifier.allowed {
                Divider()
                notificationsOff
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            Divider()
            footer
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .frame(minWidth: 420, minHeight: 320)
    }

    private var dropZone: some View {
        VStack(spacing: 8) {
            Image(systemName: "film.stack")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(targeted ? Color.accentColor : .secondary)
            Text("ProRes-Datei hierher ziehen")
                .font(.headline)
            Text("oder aufs Symbol im Dock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Datei wählen …") { (NSApp.delegate as? AppDelegate)?.chooseFiles() }
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                .foregroundStyle(targeted ? Color.accentColor : Color.secondary.opacity(0.5))
                .background(RoundedRectangle(cornerRadius: 12).fill(targeted ? Color.accentColor.opacity(0.08) : .clear))
        )
        .onDrop(of: [.fileURL], isTargeted: $targeted) { providers in
            load(providers)
            return true
        }
    }

    private var notificationsOff: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .foregroundStyle(.orange)
            Text("Mitteilungen sind aus. Die App kann dann nicht melden, wenn eine Datei fertig ist.")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button("Einschalten …") { notifier.openSettings() }
        }
        .font(.callout)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder")
                .foregroundStyle(.secondary)
            Button(destination.displayPath) { destination.reveal() }
                .buttonStyle(.link)
                .lineLimit(1)
                .truncationMode(.middle)
                .help("Zielordner im Finder zeigen. Ändern unter Einstellungen (⌘,).")
            Spacer()
            if queue.hasFinished {
                Button("Liste leeren") { queue.clearFinished() }
            }
        }
        .font(.callout)
    }

    private func load(_ providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url, url.isFileURL else { return }
                Task { @MainActor in queue.add([url]) }
            }
        }
    }
}

struct JobRow: View {
    @Environment(JobQueue.self) private var queue
    let job: Job

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            icon
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 4) {
                Text(job.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                status
            }
            Spacer(minLength: 8)
            actions
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder private var icon: some View {
        switch job.state {
        case .waiting:
            Image(systemName: "clock").foregroundStyle(.secondary)
        case .running:
            Image(systemName: "gearshape.2").foregroundStyle(Color.accentColor)
        case .done:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        case .cancelled:
            Image(systemName: "xmark.circle").foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var status: some View {
        switch job.state {
        case .waiting:
            Text("Wartet").font(.caption).foregroundStyle(.secondary)
        case .running(let progress):
            HStack(spacing: 8) {
                ProgressView(value: progress)
                Text(progress.formatted(.percent.precision(.fractionLength(0))))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
        case .done(let result):
            Text("Fertig: \(result.output.lastPathComponent) · \(Format.bitRate(result.bitRate)) · in \(Format.duration(result.elapsed))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        case .failed(let message):
            Text(message)
                .font(.caption)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
        case .cancelled:
            Text("Abgebrochen").font(.caption).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var actions: some View {
        switch job.state {
        case .waiting, .running:
            Button {
                queue.cancel(job)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help("Abbrechen")
        case .done(let result):
            Button("Im Finder zeigen") {
                NSWorkspace.shared.activateFileViewerSelecting([result.output])
            }
            .controlSize(.small)
        case .failed, .cancelled:
            Button {
                queue.remove(job)
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help("Aus der Liste nehmen")
        }
    }
}

enum Format {
    /// `4,5 Mbit/s`, in the reader's locale.
    static func bitRate(_ bps: Int) -> String {
        (Double(bps) / 1_000_000).formatted(.number.precision(.fractionLength(1))) + " Mbit/s"
    }

    /// `1:05 min` or `42 s`.
    static func duration(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        return s < 60 ? "\(s) s" : String(format: "%d:%02d min", s / 60, s % 60)
    }
}
