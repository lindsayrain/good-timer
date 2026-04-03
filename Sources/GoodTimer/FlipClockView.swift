import SwiftUI

// MARK: - Theme

struct AppTheme {
    let isDark: Bool
    let bg: Color
    let cardTop: Color
    let cardMid: Color
    let cardBottom: Color
    let divider: Color
    let highlight: Color
    let cardShadow: Color
    let separator: Color
    let label: Color
    let dim: Color
    let digitNormal: Color
    let progressTrack: Color
    let controlBg: Color

    static let dark = AppTheme(
        isDark: true,
        bg:            Color(red: 0.06,  green: 0.06,  blue: 0.08),
        cardTop:       Color(red: 0.09,  green: 0.09,  blue: 0.11),
        cardMid:       Color(red: 0.09,  green: 0.09,  blue: 0.11),
        cardBottom:    Color(red: 0.09,  green: 0.09,  blue: 0.11),
        divider:       Color(red: 0.03,  green: 0.03,  blue: 0.04),
        highlight:     Color.white.opacity(0.15),
        cardShadow:    Color.black.opacity(0.55),
        separator:     Color(red: 0.50,  green: 0.50,  blue: 0.55),
        label:         Color(red: 0.45,  green: 0.45,  blue: 0.50),
        dim:           Color(red: 0.40,  green: 0.40,  blue: 0.45),
        digitNormal:   Color(red: 0.95,  green: 0.95,  blue: 0.92),
        progressTrack: Color.white.opacity(0.07),
        controlBg:     Color.white.opacity(0.06)
    )

    static let light = AppTheme(
        isDark: false,
        bg:            Color(red: 0.90,  green: 0.89,  blue: 0.87),
        cardTop:       Color(red: 0.93,  green: 0.92,  blue: 0.90),
        cardMid:       Color(red: 0.88,  green: 0.87,  blue: 0.85),
        cardBottom:    Color(red: 0.78,  green: 0.77,  blue: 0.75),
        divider:       Color(red: 0.65,  green: 0.64,  blue: 0.62),
        highlight:     Color.white.opacity(0.60),
        cardShadow:    Color.black.opacity(0.15),
        separator:     Color(red: 0.50,  green: 0.49,  blue: 0.47),
        label:         Color(red: 0.50,  green: 0.49,  blue: 0.47),
        dim:           Color(red: 0.50,  green: 0.49,  blue: 0.47),
        digitNormal:   Color(red: 0.14,  green: 0.13,  blue: 0.12),
        progressTrack: Color.black.opacity(0.08),
        controlBg:     Color.black.opacity(0.06)
    )
}

// MARK: - Layout constants (shared across all components)

enum ClockLayout {
    static let cardW: CGFloat = 62
    static let halfH: CGFloat = 46
    static let cardH: CGFloat = halfH * 2 + 2
    static let digitGap: CGFloat = 4
    static let pairW: CGFloat = cardW * 2 + digitGap
    static let sepW: CGFloat = 28
    static let fontSize: CGFloat = 50
    static let corner: CGFloat = 3

    // Base dimensions for dynamic scaling
    static let baseW: CGFloat = pairW * 3 + sepW * 2
    static let baseH: CGFloat = halfH * 2 + 4 + 10 + 15 + 20 + 20  // cards + gap + label padding + labels + preset padding + preset
}

// MARK: - Single half-card (top or bottom)

private struct HalfCard: View {
    let digit: Int
    let isTop: Bool
    let digitColor: Color
    let theme: AppTheme

    var body: some View {
        let W = ClockLayout.cardW
        let H = ClockLayout.halfH
        let F = ClockLayout.fontSize
        let R = ClockLayout.corner

        ZStack {
            UnevenRoundedRectangle(
                topLeadingRadius: isTop ? R : 0,
                bottomLeadingRadius: isTop ? 0 : R,
                bottomTrailingRadius: isTop ? 0 : R,
                topTrailingRadius: isTop ? R : 0
            )
            .fill(LinearGradient(
                colors: isTop ? [theme.cardTop, theme.cardMid] : [theme.cardMid, theme.cardBottom],
                startPoint: .top,
                endPoint: .bottom
            ))

            Text(String(digit))
                .font(.custom("ChakraPetch-Bold", size: F))
                .foregroundColor(digitColor)
                .offset(y: isTop ? H / 2 : -H / 2)
                .frame(width: W, height: H * 2)
                .clipped()
        }
        .frame(width: W, height: H)
        .clipped()
    }
}

// MARK: - Flip card (one digit, animated)

struct FlipCard: View {
    let digit: Int
    let prevDigit: Int
    let digitColor: Color
    let theme: AppTheme

    @State private var flipping = false
    @State private var upperFlapDeg: Double = 0   // 0 → -90 (pivot: bottom = centerline)
    @State private var lowerFlapDeg: Double = 90  // 90 → 0  (pivot: top  = centerline)
    @State private var flapOld: Int = 0
    @State private var flapNew: Int = 0

    var body: some View {
        let W = ClockLayout.cardW
        let H = ClockLayout.halfH
        let gap = CGFloat(4)

        ZStack(alignment: .top) {
            // Static top: always shows new digit (revealed as upper flap folds away)
            HalfCard(digit: digit, isTop: true, digitColor: digitColor, theme: theme)

            // Static bottom: shows old digit during flip, new digit at rest
            HalfCard(digit: flipping ? flapOld : digit, isTop: false, digitColor: digitColor, theme: theme)
                .offset(y: H + gap)

            if flipping {
                // Lower flap: NEW digit bottom half — starts edge-on (90°), unfolds to flat (0°)
                HalfCard(digit: flapNew, isTop: false, digitColor: digitColor, theme: theme)
                    .rotation3DEffect(
                        .degrees(lowerFlapDeg),
                        axis: (1, 0, 0),
                        anchor: .top,
                        anchorZ: 0,
                        perspective: 0
                    )
                    .offset(y: H + gap)
                    .zIndex(2)

                // Upper flap: OLD digit top half — starts flat (0°), folds to edge-on (-90°)
                HalfCard(digit: flapOld, isTop: true, digitColor: digitColor, theme: theme)
                    .rotation3DEffect(
                        .degrees(upperFlapDeg),
                        axis: (1, 0, 0),
                        anchor: .bottom,
                        anchorZ: 0,
                        perspective: 0
                    )
                    .zIndex(3)
            }
        }
        .frame(width: W, height: H * 2 + gap)
        .onChange(of: digit) { newVal in
            guard newVal != prevDigit else { return }
            flapOld = prevDigit
            flapNew = newVal
            flipping = true
            upperFlapDeg = 0
            lowerFlapDeg = 90

            withAnimation(.easeInOut(duration: 0.45)) {
                upperFlapDeg = -90
                lowerFlapDeg = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.47) {
                flipping = false
            }
        }
    }
}

// MARK: - Separator (colon dots)

struct ClockSeparator: View {
    let theme: AppTheme
    @State private var on = true

    var body: some View {
        let dot = ClockLayout.halfH * 0.14

        VStack(spacing: ClockLayout.halfH * 0.22) {
            Circle().fill(theme.separator).frame(width: dot, height: dot)
            Circle().fill(theme.separator).frame(width: dot, height: dot)
        }
        .offset(y: 30)
        .frame(width: ClockLayout.sepW)
        .opacity(on ? 1 : 0.25)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                on = false
            }
        }
    }
}

// MARK: - Full flip clock display

struct FlipClockDisplay: View {
    @ObservedObject var vm: TimerViewModel
    let digitColor: Color
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 0) {
            digitPair(a: 0, b: 1)
            ClockSeparator(theme: theme)
            digitPair(a: 2, b: 3)
            ClockSeparator(theme: theme)
            digitPair(a: 4, b: 5)
        }
    }

    @ViewBuilder
    private func digitPair(a: Int, b: Int) -> some View {
        HStack(spacing: ClockLayout.digitGap) {
            FlipCard(digit: vm.digits[a], prevDigit: vm.previousDigits[a], digitColor: digitColor, theme: theme)
            FlipCard(digit: vm.digits[b], prevDigit: vm.previousDigits[b], digitColor: digitColor, theme: theme)
        }
        .frame(width: ClockLayout.pairW)
    }
}

// MARK: - Unit labels

struct UnitLabels: View {
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 0) {
            Text("HOURS")
                .frame(width: ClockLayout.pairW)
            Spacer().frame(width: ClockLayout.sepW)
            Text("MINUTES")
                .frame(width: ClockLayout.pairW)
            Spacer().frame(width: ClockLayout.sepW)
            Text("SECONDS")
                .frame(width: ClockLayout.pairW)
        }
        .font(.system(size: 11, weight: .medium, design: .monospaced))
        .foregroundColor(theme.label)
        .tracking(2)
    }
}
