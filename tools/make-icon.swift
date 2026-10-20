// Draws the app icon at 1024 px: swift tools/make-icon.swift <out.png>
// bin/make-icon turns it into Resources/AppIcon.icns. Shapes only; SF Symbols may not be used
// in an app icon.
import AppKit

let size = 1024.0
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// The tile: Apple's grid, 824 px with a 100 px margin.
let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let shape = NSBezierPath(roundedRect: tile, xRadius: 185, yRadius: 185)
NSGraphicsContext.current?.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowBlurRadius = 20
shadow.set()
NSColor.black.setFill()
shape.fill()
NSGraphicsContext.current?.restoreGraphicsState()
NSGradient(starting: NSColor(srgbRed: 0.98, green: 0.36, blue: 0.24, alpha: 1),
           ending: NSColor(srgbRed: 0.80, green: 0.10, blue: 0.36, alpha: 1))!.draw(in: shape, angle: -90)

// A film frame: white body, sprocket holes down both sides, a dark picture window.
let film = NSRect(x: 292, y: 330, width: 440, height: 480)
NSColor.white.setFill()
NSBezierPath(roundedRect: film, xRadius: 36, yRadius: 36).fill()
let hole = NSColor(srgbRed: 0.86, green: 0.18, blue: 0.32, alpha: 1)
hole.setFill()
for i in 0..<6 {
    let y = film.minY + 30 + Double(i) * 74
    NSBezierPath(roundedRect: NSRect(x: film.minX + 22, y: y, width: 36, height: 40), xRadius: 8, yRadius: 8).fill()
    NSBezierPath(roundedRect: NSRect(x: film.maxX - 58, y: y, width: 36, height: 40), xRadius: 8, yRadius: 8).fill()
}
let window = NSRect(x: film.minX + 84, y: film.minY + 30, width: film.width - 168, height: film.height - 60)
NSColor(srgbRed: 0.16, green: 0.10, blue: 0.20, alpha: 1).setFill()
NSBezierPath(roundedRect: window, xRadius: 14, yRadius: 14).fill()

// A downward arrow over the frame and into a tray: the file drops in, a smaller one comes out.
let arrow = NSBezierPath()
let cx = 512.0
arrow.move(to: NSPoint(x: cx - 46, y: 720))
arrow.line(to: NSPoint(x: cx + 46, y: 720))
arrow.line(to: NSPoint(x: cx + 46, y: 500))
arrow.line(to: NSPoint(x: cx + 120, y: 500))
arrow.line(to: NSPoint(x: cx, y: 370))
arrow.line(to: NSPoint(x: cx - 120, y: 500))
arrow.line(to: NSPoint(x: cx - 46, y: 500))
arrow.close()
NSColor.white.setFill()
arrow.fill()
let tray = NSBezierPath()
tray.lineWidth = 34
tray.lineCapStyle = .round
tray.lineJoinStyle = .round
tray.move(to: NSPoint(x: 300, y: 290))
tray.line(to: NSPoint(x: 300, y: 200))
tray.line(to: NSPoint(x: 724, y: 200))
tray.line(to: NSPoint(x: 724, y: 290))
NSColor.white.setStroke()
tray.stroke()

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
