// Prints "playable <first frame size> <last frame size>" when AVFoundation, which QuickTime
// Player plays with, calls the file playable and decodes its first and last frame:
//   swift tools/playable.swift <file>
import AVFoundation

let asset = AVURLAsset(url: URL(fileURLWithPath: CommandLine.arguments[1]))
let done = DispatchSemaphore(value: 0)
Task {
    defer { done.signal() }
    do {
        let (playable, duration) = try await asset.load(.isPlayable, .duration)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.requestedTimeToleranceBefore = .zero
        gen.requestedTimeToleranceAfter = .zero
        let first = try await gen.image(at: .zero).image
        let last = try await gen.image(at: CMTime(seconds: max(duration.seconds - 0.1, 0), preferredTimescale: 600)).image
        print("\(playable ? "playable" : "not-playable") \(first.width)x\(first.height) \(last.width)x\(last.height)")
    } catch {
        print("error: \(error.localizedDescription)")
    }
}
done.wait()
