import SwiftUI

// MARK: - Layout constants (shared across all components)
enum ClockLayout {
    static let cardW: CGFloat = 100
    static let halfH: CGFloat = 62
    static let cardH: CGFloat = halfH * 2 + 2   // 126, includes 2pt divider gap
    static let digitGap: CGFloat = 6             // between two digits in a pair
    static let pairW: CGFloat = cardW * 2 + digitGap  // 206
    static let sepW: CGFloat = 40               // separator (colon) area width
    static let fontSize: CGFloat = 76
    static let corner: CGFloat = 10
}

// MARK: - Colors

private let cardBG     = Color(red: 0.13, green: 0.13, blue: 0.16)
private let dividerCol = Color(red: 0.05, green: 0.05, blue: 0.07)
private let shadowCol  = Color.black.opacity(0.55)

// MARK: - Single half-card (top or bottom)

private struct HalfCard: View {
    let digit: Int
    let isTop: Bool
    let digitColor: Color

    var body: some View {
        let W = ClockLayout.cardW
        let H = ClockLayout.halfH
        let F = ClockLayout.fontSize
        let R = ClockLayout.corner

        ZStack {
            // Background with correct corner rounding
            UnevenRoundedRectangle(
                topLeadingRadius: isTop ? R : 0,
                bottomLeadingRadius: isTop ? 0 : R,
                bottomTrailingRadius: isTop ? 0 : R,
                topTrailingRadius: isTop ? R : 0
            )
            .fill(cardBG)

            // Digit clipped to this half
            Text(String(digit))
                .font(.system(size: F, weight: .bold, design: .monospaced))
                .foregroundColor(digitColor)
                .offset(y: isTop ? H / 2 : -H / 2)
                .frame(width: W, height: H * 2)
                .clipped()

            // Divider line on the cut edge
            Rectangle()
                .fill(dividerCol)
                .frame(height: 1.5)
                .frame(maxHeight: .infinity, alignment: isTop ? .bottom : .top)
        }
        .frame(width: W, height: H)
        .shadow(
            color: isTop ? Color.clear : shadowCol,
            radius: 6, x: 0, y: 4
        )
    }
}

// MARK: - Flip card (one digit, animated)

struct FlipCard: View {
    let digit: Int
    let prevDigit: Int
    let digitColor: Color

    @State private var flipping = false
    @State private var progress: CGFloat = 0
    @State private var flapOld: Int = 0
    @State private var flapNew: Int = 0

    var body: some View {
        let W = ClockLayout.cardW
        let H = ClockLayout.halfH
        let gap = CGFloat(2)

        ZStack(alignment: .top) {
            // --- Static background ---
            // Top half: always shows NEW digit
            HalfCard(digit: digit, isTop: true, digitColor: digitColor)

            // Bottom half: shows OLD digit until flip reaches halfway, then NEW
            HalfCard(digit: flipping ? flapOld : digit, isTop: false, digitColor: digitColor)
                .offset(y: H + gap)

            // --- Animated flap ---
            if flipping {
                Group {
                    if progress <= 0.5 {
                        // Front of flap: old digit top, rotating 0→-90°
                        HalfCard(digit: flapOld, isTop: true, digitColor: digitColor)
                            .rotation3DEffect(
                                .degrees(-180 * Double(progress)),
                                axis: (1, 0, 0),
                                anchor: .bottom,
                                anchorZ: 0,
                                perspective: 0.5
                            )
                    } else {
                        // Back of flap: new digit top, rotating +90→0°
                        HalfCard(digit: flapNew, isTop: true, digitColor: digitColor)
                            .rotation3DEffect(
                                .degrees(-180 * Double(progress) + 180),
                                axis: (1, 0, 0),
                                anchor: .bottom,
                                anchorZ: 0,
                                perspective: 0.5
                            )
                    }
                }
                .zIndex(2)
            }
        }
        .frame(width: W, height: H * 2 + gap)
        .onChange(of: digit) { newVal in
            guard newVal != prevDigit else { return }
            flapOld = prevDigit
            flapNew = newVal
            flipping = true
            progress = 0
            withAnimation(.linear(duration: 0.3)) {
                progress = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                flipping = false
            }
        }
    }
}

// MARK: - Separator (colon dots)

struct ClockSeparator: View {
    @State private var on = true

    var body: some View {
        let dot = ClockLayout.halfH * 0.14

        VStack(spacing: ClockLayout.halfH * 0.22) {
            Circle().fill(Color(red: 0.5, green: 0.5, blue: 0.55)).frame(width: dot, height: dot)
            Circle().fill(Color(red: 0.5, green: 0.5, blue: 0.55)).frame(width: dot, height: dot)
        }
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

    var body: some View {
        HStack(spacing: 0) {
            digitPair(a: 0, b: 1)
            ClockSeparator()
            digitPair(a: 2, b: 3)
            ClockSeparator()
            digitPair(a: 4, b: 5)
        }
    }

    @ViewBuilder
    private func digitPair(a: Int, b: Int) -> some View {
        HStack(spacing: ClockLayout.digitGap) {
            FlipCard(digit: vm.digits[a], prevDigit: vm.previousDigits[a], digitColor: digitColor)
            FlipCard(digit: vm.digits[b], prevDigit: vm.previousDigits[b], digitColor: digitColor)
        }
        .frame(width: ClockLayout.pairW)
    }
}

// MARK: - Unit labels (must align with FlipClockDisplay)

struct UnitLabels: View {
    private let labelColor = Color(red: 0.45, green: 0.45, blue: 0.5)

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
        .foregroundColor(labelColor)
        .tracking(2)
    }
}
