import Foundation

/// The top-level boxes of an MP4 file, in order, read from their 8- or 16-byte headers.
public enum MP4Boxes {
    public struct Box: Equatable, Sendable {
        public var type: String
        public var offset: UInt64
        public var size: UInt64
    }

    public static func topLevel(of url: URL) throws -> [Box] {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let end = try handle.seekToEnd()
        var offset: UInt64 = 0
        var boxes: [Box] = []
        while offset + 8 <= end {
            try handle.seek(toOffset: offset)
            guard let header = try handle.read(upToCount: 16), header.count >= 8 else { break }
            var size = header.prefix(4).reduce(UInt64(0)) { $0 << 8 | UInt64($1) }
            let type = String(bytes: header[4..<8], encoding: .ascii) ?? "????"
            if size == 1, header.count >= 16 {
                size = header[8..<16].reduce(UInt64(0)) { $0 << 8 | UInt64($1) }
            } else if size == 0 {
                size = end - offset
            }
            guard size >= 8 else { break }
            boxes.append(Box(type: type, offset: offset, size: size))
            offset += size
        }
        return boxes
    }

    /// True when the index (`moov`) comes before the media (`mdat`): a browser can start
    /// playing before the whole file is there.
    public static func isFastStart(_ url: URL) throws -> Bool {
        let types = try topLevel(of: url).map(\.type)
        guard let moov = types.firstIndex(of: "moov"), let mdat = types.firstIndex(of: "mdat") else {
            return false
        }
        return moov < mdat
    }
}
