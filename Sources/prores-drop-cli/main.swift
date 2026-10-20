import DropCore
import Foundation

// The app's encode from the terminal, for bin/test-encode and for trying other rates:
//   prores-drop-cli <source> [--out DIR] [--avg BPS] [--peak BPS] [--window SECONDS]
// Prints the result as JSON on stdout; progress goes to stderr.

var args = Array(CommandLine.arguments.dropFirst())
func take(_ flag: String) -> String? {
    guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
    let value = args[i + 1]
    args.removeSubrange(i...(i + 1))
    return value
}
let out = take("--out").map { URL(fileURLWithPath: $0) }
let avg = take("--avg").flatMap(Int.init)
let peak = take("--peak").flatMap(Int.init)
let window = take("--window").flatMap(Double.init)
guard args.count == 1 else {
    FileHandle.standardError.write("usage: prores-drop-cli <source> [--out DIR] [--avg BPS] [--peak BPS] [--window S]\n".data(using: .utf8)!)
    exit(64)
}
let source = URL(fileURLWithPath: args[0])
let folder = out ?? source.deletingLastPathComponent()
let job = Transcoder(source: source, destinationFolder: folder)
if avg != nil || peak != nil || window != nil {
    job.adjustPlan = { plan in
        var p = plan
        if let avg { p.averageBitRate = avg }
        if let peak { p.peakBitRate = peak }
        if let window { p.peakWindow = window }
        return p
    }
}

let lastShown = LockedDouble()
let sem = DispatchSemaphore(value: 0)
var exitCode: Int32 = 0
Task {
    do {
        let r = try await job.run { fraction in
            if lastShown.advance(to: fraction, by: 0.1) {
                FileHandle.standardError.write(String(format: "%3.0f %%\n", fraction * 100).data(using: .utf8)!)
            }
        }
        let report: [String: Any] = [
            "output": r.output.path, "source_codec": r.sourceCodec,
            "width": r.plan.width, "height": r.plan.height, "frame_rate": r.plan.frameRate,
            "average_bit_rate": r.plan.averageBitRate, "peak_bit_rate": r.plan.peakBitRate,
            "peak_window": r.plan.peakWindow,
            "source_duration": r.sourceDuration, "duration": r.duration,
            "bytes": r.bytes, "bit_rate": r.bitRate, "elapsed": NSDecimalNumber(string: String(format: "%.1f", r.elapsed)),
        ]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        print(String(data: data, encoding: .utf8)!)
    } catch {
        FileHandle.standardError.write("error: \(error.localizedDescription)\n".data(using: .utf8)!)
        exitCode = 1
    }
    sem.signal()
}
sem.wait()
exit(exitCode)

final class LockedDouble: @unchecked Sendable {
    private let lock = NSLock()
    private var value = -1.0
    func advance(to v: Double, by step: Double) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard v >= value + step || (v >= 1 && value < 1) else { return false }
        value = v
        return true
    }
}
