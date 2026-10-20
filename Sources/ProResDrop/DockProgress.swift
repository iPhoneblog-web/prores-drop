import AppKit

/// The Dock icon while files wait or run: a progress bar for the file running now, and a badge
/// with the number of files not yet done (the running one included).
@MainActor
final class DockProgress {
    private let tile = NSApp.dockTile
    private lazy var view = DockTileView(frame: NSRect(origin: .zero, size: tile.size))
    private var shownProgress: Double?
    private var shownOpen = 0

    func update(progress: Double?, open: Int) {
        guard progress != shownProgress || open != shownOpen else { return }
        shownProgress = progress
        shownOpen = open
        tile.badgeLabel = open > 0 ? String(open) : nil
        if let progress {
            view.progress = progress
            if tile.contentView !== view { tile.contentView = view }
        } else {
            tile.contentView = nil
        }
        tile.display()
    }
}

final class DockTileView: NSView {
    var progress = 0.0

    override func draw(_ dirtyRect: NSRect) {
        NSApp.applicationIconImage?.draw(in: bounds)
        let inset = bounds.width * 0.12
        let height = max(bounds.height * 0.1, 8)
        let track = NSRect(x: inset, y: bounds.height * 0.1, width: bounds.width - 2 * inset, height: height)
        let radius = height / 2
        NSColor.black.withAlphaComponent(0.55).setFill()
        NSBezierPath(roundedRect: track, xRadius: radius, yRadius: radius).fill()
        let inner = track.insetBy(dx: 2, dy: 2)
        let fill = NSRect(x: inner.minX, y: inner.minY,
                          width: max(inner.height, inner.width * min(max(progress, 0), 1)), height: inner.height)
        NSColor.white.setFill()
        NSBezierPath(roundedRect: fill, xRadius: inner.height / 2, yRadius: inner.height / 2).fill()
    }
}
