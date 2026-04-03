#!/usr/bin/env swift
// generate-icon.swift — Programmatically generates GoodTimer's flip-card app icon
// Run: swift generate-icon.swift
// Output: AppIcon.iconset/ (PNG files) + AppIcon.icns

import Cocoa
import CoreGraphics
import CoreText

let sizes: [(Int, Int, String)] = [
    (16,   1,  "icon_16x16.png"),
    (16,   2,  "icon_16x16@2x.png"),
    (32,   1,  "icon_32x32.png"),
    (32,   2,  "icon_32x32@2x.png"),
    (64,   1,  "icon_64x64.png"),
    (64,   2,  "icon_64x64@2x.png"),
    (128,  1,  "icon_128x128.png"),
    (128,  2,  "icon_128x128@2x.png"),
    (256,  1,  "icon_256x256.png"),
    (256,  2,  "icon_256x256@2x.png"),
    (512,  1,  "icon_512x512.png"),
    (512,  2,  "icon_512x512@2x.png"),
    (1024, 1,  "icon_512x512@2x.png"),
]

func drawIcon(pixelSize: Int) -> CGImage? {
    let size = CGFloat(pixelSize)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: pixelSize, height: pixelSize,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // Standard CoreGraphics: y=0 at bottom, y=size at top. No Y-axis flip.

    // --- Background: transparent ---
    ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

    // --- Card dimensions ---
    let margin = size * 0.08
    let cardW  = size - margin * 2
    let cardH  = size - margin * 2
    let cardX  = margin
    let radius = size * 0.14

    // Gap between top and bottom half (the center seam)
    let gapPx  = max(2, size * 0.025)
    let halfH  = (cardH - gapPx) / 2

    // Standard bottom-left origin:
    //   bottom half: y = margin
    //   top half:    y = margin + halfH + gapPx
    let bottomY = margin
    let topY    = margin + halfH + gapPx

    // --- Draw bottom half (rounded bottom corners) ---
    let bottomClip = CGMutablePath()
    bottomClip.move(to: CGPoint(x: cardX, y: bottomY + halfH))
    bottomClip.addLine(to: CGPoint(x: cardX + cardW, y: bottomY + halfH))
    bottomClip.addLine(to: CGPoint(x: cardX + cardW, y: bottomY + radius))
    bottomClip.addQuadCurve(to: CGPoint(x: cardX + cardW - radius, y: bottomY),
                            control: CGPoint(x: cardX + cardW, y: bottomY))
    bottomClip.addLine(to: CGPoint(x: cardX + radius, y: bottomY))
    bottomClip.addQuadCurve(to: CGPoint(x: cardX, y: bottomY + radius),
                            control: CGPoint(x: cardX, y: bottomY))
    bottomClip.closeSubpath()

    ctx.saveGState()
    ctx.addPath(bottomClip)
    ctx.clip()
    // Gradient: darker at bottom, lighter at top (in bottom-left coords)
    let botColors = [
        CGColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1),
        CGColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
    ] as CFArray
    let botGrad = CGGradient(colorsSpace: colorSpace, colors: botColors, locations: [0, 1])!
    ctx.drawLinearGradient(
        botGrad,
        start: CGPoint(x: cardX, y: bottomY),
        end:   CGPoint(x: cardX, y: bottomY + halfH),
        options: []
    )
    ctx.restoreGState()

    // --- Draw top half (rounded top corners) ---
    let topClip = CGMutablePath()
    topClip.move(to: CGPoint(x: cardX, y: topY))
    topClip.addLine(to: CGPoint(x: cardX + cardW, y: topY))
    topClip.addLine(to: CGPoint(x: cardX + cardW, y: topY + halfH - radius))
    topClip.addQuadCurve(to: CGPoint(x: cardX + cardW - radius, y: topY + halfH),
                         control: CGPoint(x: cardX + cardW, y: topY + halfH))
    topClip.addLine(to: CGPoint(x: cardX + radius, y: topY + halfH))
    topClip.addQuadCurve(to: CGPoint(x: cardX, y: topY + halfH - radius),
                         control: CGPoint(x: cardX, y: topY + halfH))
    topClip.closeSubpath()

    ctx.saveGState()
    ctx.addPath(topClip)
    ctx.clip()
    // Gradient: lighter at top, darker at bottom
    let topColors = [
        CGColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1),
        CGColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
    ] as CFArray
    let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0, 1])!
    ctx.drawLinearGradient(
        topGrad,
        start: CGPoint(x: cardX, y: topY + halfH),
        end:   CGPoint(x: cardX, y: topY),
        options: []
    )
    ctx.restoreGState()

    // --- Draw "9" digit spanning both halves ---
    let fontSize = halfH * 0.85
    let font = CTFontCreateWithName("ChakraPetch-Bold" as CFString, fontSize, nil)

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: CGColor(red: 0.97, green: 0.96, blue: 0.95, alpha: 1),
    ]
    let attrStr = NSAttributedString(string: "9", attributes: attrs)
    let line = CTLineCreateWithAttributedString(attrStr)
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)

    // Center the digit horizontally and vertically across both halves
    let totalH = halfH * 2 + gapPx
    let digitX = cardX + (cardW - bounds.width) / 2 - bounds.minX
    let digitY = bottomY + (totalH - bounds.height) / 2 - bounds.minY

    // Draw top half of digit (clip to top card)
    ctx.saveGState()
    ctx.clip(to: CGRect(x: cardX, y: topY, width: cardW, height: halfH))
    ctx.textMatrix = .identity
    ctx.textPosition = CGPoint(x: digitX, y: digitY)
    CTLineDraw(line, ctx)
    ctx.restoreGState()

    // Draw bottom half of digit (clip to bottom card)
    ctx.saveGState()
    ctx.clip(to: CGRect(x: cardX, y: bottomY, width: cardW, height: halfH))
    ctx.textMatrix = .identity
    ctx.textPosition = CGPoint(x: digitX, y: digitY)
    CTLineDraw(line, ctx)
    ctx.restoreGState()

    return ctx.makeImage()
}

// Create iconset directory
let iconsetPath = "AppIcon.iconset"
let fm = FileManager.default
try? fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

// Generate each size
var generated = Set<String>()
for (logicalSize, scale, filename) in sizes {
    let pixelSize = logicalSize * scale
    if generated.contains(filename) { continue }
    generated.insert(filename)

    guard let cgImage = drawIcon(pixelSize: pixelSize) else {
        print("❌ Failed to draw icon at \(pixelSize)px")
        continue
    }
    let url = URL(fileURLWithPath: "\(iconsetPath)/\(filename)")
    let bmp = NSBitmapImageRep(cgImage: cgImage)
    bmp.size = NSSize(width: logicalSize, height: logicalSize)
    guard let data = bmp.representation(using: .png, properties: [:]) else {
        print("❌ Failed to encode PNG at \(pixelSize)px")
        continue
    }
    try data.write(to: url)
    print("✓ \(filename) (\(pixelSize)×\(pixelSize)px)")
}

print("\nAll sizes generated in \(iconsetPath)/")
print("Run: iconutil -c icns \(iconsetPath) -o AppIcon.icns")
