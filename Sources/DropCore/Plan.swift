import Foundation

/// What one file becomes: its size, frame rate and bit rates. Every number here comes from
/// docs/encoding.md; change them there first.
public struct EncodePlan: Equatable, Sendable {
    /// Encoded size in pixels, as stored (before the track's rotation, if any).
    public var width: Int
    public var height: Int
    /// The source's nominal frame rate. Frames keep their own timestamps; this only tells the
    /// encoder what to expect.
    public var frameRate: Double
    /// VideoToolbox's average target, bits per second.
    public var averageBitRate: Int
    /// The hard ceiling over `peakWindow` seconds, bits per second.
    public var peakBitRate: Int
    public var peakWindow: Double

    public static let audioBitRate = 256_000
    public static let audioSampleRate = 48_000.0
    public static let keyFrameInterval = 4.0
}

public enum Plan {
    /// The server's 4K box (infra roles/encoder/files/video-encode, `BOXES["2160"]`). A source
    /// that fits keeps its size; a larger one is scaled into it. Portrait turns the box.
    public static let box = (width: 3840, height: 2160)

    /// The server's 4K rung is x265 `slower` CRF 29 capped at 5 Mbit/s, and it remuxes an HEVC
    /// 4K upload of at most about 6 Mbit/s as it is (infra docs/TODO.md, "Uploads without a kept
    /// master"). VideoToolbox stays well under its peak limit, so these two land a 4K file at
    /// about 4.2 Mbit/s of video, 4.5 with the audio (docs/encoding.md, "Measured").
    public static let averageBitRate4K = 5_000_000
    public static let peakBitRate4K = 6_000_000
    public static let peakWindow = 1.0

    /// Pixels per second that get the full budget: 4K at 25 frames. A 4K source at 25 frames or
    /// more gets all of it; anything smaller gets its share by pixels times frame rate.
    public static let referencePixelRate = 3840.0 * 2160.0 * 25.0

    /// The size the server would make its top rung: kept aspect, even sides, never upscaled.
    public static func fit(width: Int, height: Int) -> (width: Int, height: Int) {
        var bw = Double(box.width), bh = Double(box.height)
        if height > width { swap(&bw, &bh) }
        let w = Double(width), h = Double(height)
        let s = min(bw / w, bh / h, 1.0)
        // Python's round(), as the server computes it: halves go to the even neighbour, so
        // 4096x2160 becomes 3840x2024 on both sides.
        return (Int((w * s / 2).rounded(.toNearestOrEven)) * 2, Int((h * s / 2).rounded(.toNearestOrEven)) * 2)
    }

    public static func make(width: Int, height: Int, frameRate: Double) -> EncodePlan {
        let size = fit(width: width, height: height)
        let fps = frameRate > 0 ? frameRate : 25
        let share = min(1.0, Double(size.width * size.height) * fps / referencePixelRate)
        return EncodePlan(width: size.width, height: size.height, frameRate: fps,
                          averageBitRate: Int((Double(averageBitRate4K) * share).rounded()),
                          peakBitRate: Int((Double(peakBitRate4K) * share).rounded()),
                          peakWindow: peakWindow)
    }
}
