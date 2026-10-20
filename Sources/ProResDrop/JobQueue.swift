import DropCore
import Foundation
import Observation

@MainActor
@Observable
final class Job: Identifiable {
    enum State {
        case waiting
        case running(progress: Double)
        case done(EncodeResult)
        case failed(String)
        case cancelled
    }

    let id = UUID()
    let source: URL
    var state: State = .waiting
    @ObservationIgnored var transcoder: Transcoder?

    init(source: URL) { self.source = source }

    var name: String { source.lastPathComponent }

    var isOpen: Bool {
        switch state {
        case .waiting, .running: return true
        default: return false
        }
    }
}

/// One encode at a time; the rest wait in the order they came. The media engine does one file
/// fastest alone, and one at a time keeps the order Alex dropped them in.
@MainActor
@Observable
final class JobQueue {
    private(set) var jobs: [Job] = []
    @ObservationIgnored private let destination: Destination
    @ObservationIgnored private let notifier: Notifier
    @ObservationIgnored private let dock: DockProgress
    @ObservationIgnored private var running: Job?

    init(destination: Destination, notifier: Notifier, dock: DockProgress) {
        self.destination = destination
        self.notifier = notifier
        self.dock = dock
    }

    var isBusy: Bool { running != nil }
    var openCount: Int { jobs.filter(\.isOpen).count }
    var hasFinished: Bool { jobs.contains { !$0.isOpen } }

    /// Files only; folders are skipped. A file already waiting or running is not added twice.
    func add(_ urls: [URL]) {
        for url in urls {
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), !isDir.boolValue else { continue }
            if jobs.contains(where: { $0.isOpen && $0.source.standardizedFileURL == url.standardizedFileURL }) { continue }
            jobs.append(Job(source: url))
        }
        updateDock()
        startNext()
    }

    func cancel(_ job: Job) {
        switch job.state {
        case .waiting:
            job.state = .cancelled
        case .running:
            job.transcoder?.cancel()
        default:
            break
        }
        updateDock()
    }

    func cancelAll() {
        for job in jobs where job.isOpen { cancel(job) }
    }

    func remove(_ job: Job) {
        guard !job.isOpen else { return }
        jobs.removeAll { $0.id == job.id }
    }

    func clearFinished() {
        jobs.removeAll { !$0.isOpen }
    }

    private func startNext() {
        guard running == nil, let job = jobs.first(where: { if case .waiting = $0.state { return true }; return false }) else {
            updateDock()
            return
        }
        running = job
        job.state = .running(progress: 0)
        updateDock()
        let transcoder = Transcoder(source: job.source, destinationFolder: destination.folder)
        job.transcoder = transcoder
        let gate = ProgressGate()
        Task {
            let outcome: Job.State
            do {
                let result = try await transcoder.run { fraction in
                    guard gate.pass(fraction) else { return }
                    Task { @MainActor in
                        guard case .running = job.state else { return }
                        job.state = .running(progress: fraction)
                        self.updateDock()
                    }
                }
                outcome = .done(result)
            } catch DropError.cancelled {
                outcome = .cancelled
            } catch let error as DropError {
                outcome = .failed(error.message)
            } catch {
                outcome = .failed(error.localizedDescription)
            }
            self.finish(job, outcome)
        }
    }

    private func finish(_ job: Job, _ outcome: Job.State) {
        job.state = outcome
        switch outcome {
        case .done(let r):
            log.notice("done \(job.name, privacy: .public) -> \(r.output.lastPathComponent, privacy: .public), \(r.bitRate) bit/s, \(r.elapsed, format: .fixed(precision: 1)) s")
        case .failed(let message):
            log.notice("failed \(job.name, privacy: .public): \(message, privacy: .public)")
        case .cancelled:
            log.notice("cancelled \(job.name, privacy: .public)")
        default:
            break
        }
        job.transcoder = nil
        running = nil
        switch outcome {
        case .done(let result):
            notifier.done(source: job.source, result: result)
        case .failed(let message):
            notifier.failed(source: job.source, message: message)
        default:
            break
        }
        startNext()
    }

    private func updateDock() {
        var progress: Double?
        if let running, case .running(let p) = running.state { progress = p }
        dock.update(progress: progress, open: openCount)
    }
}

/// Lets a progress value through when it moved by half a percent or reached the end, so the
/// main thread and the Dock redraw a few hundred times a file, not once per frame.
final class ProgressGate: @unchecked Sendable {
    private let lock = NSLock()
    private var last = -1.0

    func pass(_ value: Double) -> Bool {
        lock.withLock {
            guard value - last >= 0.005 || (value >= 1 && last < 1) else { return false }
            last = value
            return true
        }
    }
}
