import Foundation

public enum Naming {
    /// `Folge 123.mov` becomes `Folge 123.mp4` in `folder`. An existing file is never
    /// overwritten: the next free name is `Folge 123 2.mp4`, as Finder counts.
    public static func outputURL(for source: URL, in folder: URL,
                                 exists: (URL) -> Bool = { FileManager.default.fileExists(atPath: $0.path) }) -> URL {
        let base = source.deletingPathExtension().lastPathComponent
        var candidate = folder.appendingPathComponent(base).appendingPathExtension("mp4")
        var n = 2
        while exists(candidate) || candidate.standardizedFileURL == source.standardizedFileURL {
            candidate = folder.appendingPathComponent("\(base) \(n)").appendingPathExtension("mp4")
            n += 1
        }
        return candidate
    }

    /// The four characters of a codec type, `apch` for ProRes 422 HQ, with a name where we know one.
    public static func codecName(_ code: FourCharCode) -> String {
        let known: [String: String] = [
            "apco": "ProRes 422 Proxy", "apcs": "ProRes 422 LT", "apcn": "ProRes 422",
            "apch": "ProRes 422 HQ", "ap4h": "ProRes 4444", "ap4x": "ProRes 4444 XQ",
            "aprn": "ProRes RAW", "aprh": "ProRes RAW HQ",
            "avc1": "H.264", "hvc1": "HEVC", "hev1": "HEVC",
            "lpcm": "PCM", "aac ": "AAC",
        ]
        let s = fourCC(code)
        if let name = known[s] { return name }
        return s.trimmingCharacters(in: .whitespaces).isEmpty ? "unbekannt" : s
    }

    public static func fourCC(_ code: FourCharCode) -> String {
        let bytes = [24, 16, 8, 0].map { UInt8((code >> $0) & 0xff) }
        let printable = bytes.allSatisfy { $0 >= 0x20 && $0 < 0x7f }
        return printable ? String(bytes: bytes, encoding: .ascii) ?? "?" : String(format: "0x%08x", code)
    }
}
