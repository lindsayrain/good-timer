#!/usr/bin/env swift
// generate-icon.swift — Programmatically generates GoodTimer's flip-card app icon
// Run: swift generate-icon.swift
// Output: AppIcon.iconset/ (PNG files) + AppIcon.icns

import Cocoa
import CoreGraphics

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

    // Coordinate system: flip Y so 0,0 is top-left
    ctx.translateBy(x: 0, y: size)
    ctx.scaleBy(x: 1, y: -1)

    // --- Background: transparent (icon has rounded rect only) ---
    ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

    // --- Card dimensions ---
    let margin    = size * 0.08
    let cardW     = size - margin * 2
    let cardH     = size - margin * 2
    let cardX     = margin
    let cardY     = margin
    let radius    = size * 0.14

    // Gap between top and bottom half (the center seam)
    let gapPx     = max(2, size * 0.025)
    let halfH     = (cardH - gapPx) / 2

    // --- Draw top half ---
    let topRect = CGRect(x: cardX, y: cardY, width: cardW, height: halfH)
    let topPath = CGMutablePath()
    topPath.addRoundedRect(
        in: topRect,
        cornerWidth: radius, cornerHeight: radius
    )
    // Clip to top half (only round top corners)
    let topClip = CGMutablePath()
    topClip.move(to: CGPoint(x: cardX, y: cardY + halfH))
    topClip.addLine(to: CGPoint(x: cardX, y: cardY + radius))
    topClip.addQuadCurve(to: CGPoint(x: cardX + radius, y: cardY),
                         control: CGPoint(x: cardX, y: cardY))
    topClip.addLine(to: CGPoint(x: cardX + cardW - radius, y: cardY))
    topClip.addQuadCurve(to: CGPoint(x: cardX + cardW, y: cardY + radius),
                         control: CGPoint(x: cardX + cardW, y: cardY))
    topClip.addLine(to: CGPoint(x: cardX + cardW, y: cardY + halfH))
    topClip.closeSubpath()

    // Top half gradient: slightly lighter at top
    ctx.saveGState()
    ctx.addPath(topClip)
    ctx.clip()
    let topColors = [
        CGColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1),
        CGColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
    ] as CFArray
    let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0, 1])!
    ctx.drawLinearGradient(
        topGrad,
        start: CGPoint(x: cardX, y: cardY),
        end: CGPoint(x: cardX, y: cardY + halfH),
        options: []
    )
    ctx.restoreGState()

    // --- Draw bottom half ---
    let bottomY = cardY + halfH + gapPx
    let bottomRect = CGRect(x: cardX, y: bottomY, width: cardW, height: halfH)
    let bottomClip = CGMutablePath()
    bottomClip.move(to: CGPoint(x: cardX, y: bottomY))
    bottomClip.addLine(to: CGPoint(x: cardX + cardW, y: bottomY))
    bottomClip.addLine(to: CGPoint(x: cardX + cardW, y: bottomY + halfH - radius))
    bottomClip.addQuadCurve(to: CGPoint(x: cardX + cardW - radius, y: bottomY + halfH),
                            control: CGPoint(x: cardX + cardW, y: bottomY + halfH))
    bottomClip.addLine(to: CGPoint(x: cardX + radius, y: bottomY + halfH))
    bottomClip.addQuadCurve(to: CGPoint(x: cardX, y: bottomY + halfH - radius),
                            control: CGPoint(x: cardX, y: bottomY + halfH))
    bottomClip.closeSubpath()

    ctx.saveGState()
    ctx.addPath(bottomClip)
    ctx.clip()
    let botColors = [
        CGColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
        CGColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1),
    ] as CFArray
    let botGrad = CGGradient(colorsSpace: colorSpace, colors: botColors, locations: [0, 1])!
    ctx.drawLinearGradient(
        botGrad,
        start: CGPoint(x: cardX, y: bottomY),
        end: CGPoint(x: cardX, y: bottomY + halfH),
        options: []
    )
    ctx.restoreGState()

    // --- Draw "0" digit in each half ---
    let fontSize = halfH * 0.72
    let font = CTFontCreateWithName("SF Pro Display" as CFString, fontSize, nil)
            ?? CTFontCreateWithName(".AppleSystemUIFont" as CFString, fontSize, nil)

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: CGColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1),
    ]

    func drawDigit(in rect: CGRect) {
        let attrStr = NSAttributedString(string: "0", attributes: attrs)
        let line = CTLineCreateWithAttributedString(attrStr)
        let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        let tx = rect.midX - bounds.width / 2 - bounds.minX
        let ty = rect.midY - bounds.height / 2 - bounds.minY
        ctx.saveGState()
        // Clip to the half rect to avoid bleed
        ctx.clip(to: rect)
        ctx.textPosition = CGPoint(x: tx, y: ty)
        CTLineDraw(line, ctx)
        ctx.restoreGState()
    }

    // Top half: show top half of the "0" glyph (upper half card)
    drawDigit(in: CGRect(x: cardX, y: cardY, width: cardW, height: halfH * 2))
    // Bottom half: show bottom half of the "0" glyph
    // Shift drawing origin so bottom half of digit aligns to bottom card
    let fullDigitRect = CGRect(x: cardX, y: bottomY - halfH, width: cardW, height: halfH * 2)
    drawDigit(in: CGRect(x: cardX, y: bottomY, width: cardW, height: halfH))

    // Suppress unused warning
    _ = fullDigitRect

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
print("Run: iconutil -c icns \(iconsetPath)")
