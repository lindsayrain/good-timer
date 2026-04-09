import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: TimerViewModel
    @State private var showSetTime = false
    @State private var alwaysOnTop = false
    @State private var isDark = true
    @State private var windowWidth: CGFloat = 780
    @State private var windowHeight: CGFloat = 480
    @State private var opacityLevel: Int = 0  // 0=100%, 1=75%, 2=50%, 3=25%

    private var theme: AppTheme { isDark ? .dark : .light }

    // Accent colors (same in both themes)
    private let accentBlue   = Color(red: 0.3,  green: 0.7,  blue: 1.0)
    private let accentGreen  = Color(red: 0.2,  green: 0.85, blue: 0.5)
    private let accentOrange = Color(red: 1.0,  green: 0.55, blue: 0.2)
    private let accentRed    = Color(red: 1.0,  green: 0.3,  blue: 0.3)

    private let presets: [(label: String, seconds: Int)] = [
        ("5 SEC", 5), ("5 MIN", 300), ("10 MIN", 600), ("15 MIN", 900), ("25 MIN", 1500), ("45 MIN", 2700)
    ]

    private var compact: Bool { windowWidth < 400 }
    private var mini: Bool { windowWidth < 400 }
    // When the window is narrower than this, collapse text-heavy top bar
    // buttons to icon-only so nothing wraps.
    private var narrow: Bool { windowWidth < 560 }


    private var digitColor: Color {
        switch vm.warningLevel {
        case .none:    return theme.digitNormal
        case .caution: return isDark
            ? Color(red: 1.0,  green: 0.85, blue: 0.2)
            : Color(red: 0.85, green: 0.55, blue: 0.0)
        case .danger:  return isDark
            ? Color(red: 1.0,  green: 0.35, blue: 0.35)
            : Color(red: 0.85, green: 0.15, blue: 0.15)
        }
    }

    // MARK: - Flip clock sizing rules
    //
    // The flip cards are the primary content. Layout rules:
    // 1. Reserve fixed height for top bar (or pin reserve), progress bar,
    //    preset bar (when shown), and control bar.
    // 2. The cards claim the remaining height, but also target at least 60%
    //    of the window height as a height-budget.
    // 3. Final scale = min(widthLimited, heightLimited).
    //
    // This makes the cards dominate the window vertically whenever the
    // aspect ratio allows, while never overflowing the window width.
    private struct CardMetrics {
        let sepW: CGFloat
        let baseW: CGFloat
        let baseH: CGFloat
        let scale: CGFloat
        var width: CGFloat { baseW * scale }
        var height: CGFloat { baseH * scale }
    }

    private func cardMetrics() -> CardMetrics {
        let sepW: CGFloat = mini ? 4 : ClockLayout.sepW
        let baseW = ClockLayout.pairW * 3 + sepW * 2
        let baseH: CGFloat = ClockLayout.halfH * 2 + 4  // cards only, no labels/preset

        // Minimum reserves for non-card chrome.
        let topReserve: CGFloat     = mini ? 22 : 44
        let progressReserve: CGFloat = (vm.mode == .countdown) ? (mini ? 2.5 : 4) : 0
        let presetReserve: CGFloat  = (!mini && vm.mode == .countdown && vm.state != .running) ? 34 : 0
        let controlReserve: CGFloat = mini ? 30 : 66
        let reservedH = topReserve + progressReserve + presetReserve + controlReserve

        // Height budget after reserving chrome, but never less than 60% of window.
        let remaining = max(0, windowHeight - reservedH)
        let cardHBudget = max(remaining, windowHeight * 0.6)

        let scaleByW = windowWidth / baseW
        let scaleByH = cardHBudget / baseH
        let scale = max(0.05, min(scaleByW, scaleByH))

        return CardMetrics(sepW: sepW, baseW: baseW, baseH: baseH, scale: scale)
    }

    var body: some View {
        let metrics = cardMetrics()

        return ZStack {
            theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar (or pin reserve in mini mode)
                if !mini {
                    topBar
                } else {
                    Color.clear.frame(height: 22)
                }

                // Progress bar — tight against the cards
                if vm.mode == .countdown {
                    progressBar.padding(.bottom, 1)
                }

                // Flip cards — rendered at native pixel size (no bitmap scaling)
                FlipClockDisplay(
                    vm: vm,
                    digitColor: digitColor,
                    theme: theme,
                    separatorWidth: metrics.sepW,
                    scale: metrics.scale
                )
                .animation(.easeInOut(duration: 0.4), value: vm.warningLevel)
                .frame(width: metrics.width, height: metrics.height)
                .frame(maxWidth: .infinity)

                // Flex space pushes the preset/control bars to the bottom
                Spacer(minLength: 0)

                // Preset bar (non-mini, countdown, idle only)
                if !mini && vm.mode == .countdown && vm.state != .running {
                    presetBar.padding(.bottom, 6)
                }

                // Control bar — pinned to bottom
                controlBar
                    .padding(.bottom, mini ? 6 : 14)
            }

            // App title — centered on the traffic light row (both modes).
            // ignoresSafeArea so the title sits in the title bar strip
            // instead of being pushed below it by safe area insets.
            Text("GOOD TIMER")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(theme.dim)
                .tracking(4)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.all, edges: .top)
                .allowsHitTesting(false)
                .zIndex(3)

            // Mini mode: pin floats at the top-right corner
            if mini {
                pinButton
                    .padding(.top, 4)
                    .padding(.trailing, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .zIndex(4)
            }

            if showSetTime {
                CountdownSetterView(vm: vm, isPresented: $showSetTime)
                    .transition(.opacity)
                    .zIndex(10)
            }

            if vm.isFinished && vm.mode == .countdown {
                timesUpOverlay.zIndex(5)
            }
        }
        .frame(minWidth: 200, minHeight: 100)
        .overlay(GeometryReader { geo in
            Color.clear
                .onAppear {
                    windowWidth = geo.size.width
                    windowHeight = geo.size.height
                }
                .onChange(of: geo.size) { newSize in
                    windowWidth = newSize.width
                    windowHeight = newSize.height
                }
        })
        .preferredColorScheme(isDark ? .dark : .light)
        .onAppear { vm.updateDigits(for: vm.displaySeconds) }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Spacer()

            if !mini {
                // Time adjust -15s
                Button { vm.adjustTime(by: -15) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gobackward.15").font(.system(size: 11))
                        if !narrow {
                            Text("-15s")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .foregroundColor(theme.dim)
                    .padding(.horizontal, narrow ? 6 : 7)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.controlBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.dim.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("-15 seconds")

                // Time adjust +15s
                Button { vm.adjustTime(by: 15) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "goforward.15").font(.system(size: 11))
                        if !narrow {
                            Text("+15s")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .foregroundColor(theme.dim)
                    .padding(.horizontal, narrow ? 6 : 7)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.controlBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.dim.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("+15 seconds")

                // Theme toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { isDark.toggle() }
                } label: {
                    Image(systemName: isDark ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.dim)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.controlBg)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.dim.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .help(isDark ? "Switch to Light" : "Switch to Dark")

                // Opacity toggle
                Button {
                    opacityLevel = (opacityLevel + 1) % 4
                    let alpha: CGFloat = [1.0, 0.8, 0.6, 0.4][opacityLevel]
                    NSApp.windows.first(where: { $0.canBecomeMain })?.alphaValue = alpha
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.lefthalf.filled").font(.system(size: 11))
                        if !narrow {
                            Text(["100%", "80%", "60%", "40%"][opacityLevel])
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .foregroundColor(opacityLevel == 0 ? theme.dim : accentBlue)
                    .padding(.horizontal, narrow ? 6 : 7)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.controlBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(opacityLevel == 0 ? theme.dim.opacity(0.25) : accentBlue.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("Window Opacity: \(["100%", "80%", "60%", "40%"][opacityLevel])")
            }

            // Always-on-top toggle (non-mini: inline in top bar)
            if !mini {
                pinButton
            }

            if !mini {
                // Mode toggle — pill with two segments
                HStack(spacing: 0) {
                    modeSegment(label: "COUNTDOWN", icon: "timer", isActive: vm.mode == .countdown) {
                        if vm.mode != .countdown { withAnimation { vm.toggleMode() } }
                    }
                    modeSegment(label: "COUNT UP", icon: "stopwatch", isActive: vm.mode == .countup) {
                        if vm.mode != .countup { withAnimation { vm.toggleMode() } }
                    }
                }
                .background(theme.controlBg)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.dim.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(.horizontal, mini ? 6 : (compact ? 8 : 28))
        .padding(.top, mini ? 6 : (compact ? 8 : 20))
        .padding(.bottom, mini ? 4 : 8)
    }

    // MARK: - Pin button (shared by top bar and mini overlay)

    private var pinButton: some View {
        Button {
            alwaysOnTop.toggle()
            if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                if alwaysOnTop {
                    window.level = .screenSaver
                    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
                } else {
                    window.level = .normal
                    window.collectionBehavior = []
                }
            }
        } label: {
            HStack(spacing: narrow ? 0 : 6) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                if !narrow {
                    Text(alwaysOnTop ? "ON" : "OFF")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .foregroundColor(alwaysOnTop ? .black : theme.dim)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(alwaysOnTop ? accentBlue : theme.controlBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(alwaysOnTop ? Color.clear : theme.dim.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: alwaysOnTop)
        .help("Pin on Top")
    }

    @ViewBuilder
    private func modeSegment(label: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: compact ? 0 : 5) {
                Image(systemName: icon).font(.system(size: 10))
                if !compact {
                    Text(label)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .foregroundColor(isActive ? .black : theme.dim)
            .padding(.horizontal, compact ? 8 : 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isActive ? accentBlue : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    // MARK: - Progress bar

    private var progressBarColor: Color {
        switch vm.warningLevel {
        case .none:    return accentBlue
        case .caution: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case .danger:  return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }

    private var progressBar: some View {
        let h: CGFloat = mini ? 0.75 : 1.5
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: h / 2)
                    .fill(theme.progressTrack)
                RoundedRectangle(cornerRadius: h / 2)
                    .fill(vm.warningLevel == .none
                          ? LinearGradient(colors: [accentBlue, accentGreen], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [progressBarColor, progressBarColor], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * (1 - vm.progressFraction))
                    .animation(.easeInOut(duration: 0.4), value: vm.warningLevel)
            }
            .frame(height: h)
        }
        .frame(height: h)
        .padding(.horizontal, mini ? 0 : 28)
    }

    // MARK: - Quick preset bar

    private var presetBar: some View {
        HStack(spacing: 10) {
            ForEach(Array(presets.enumerated()), id: \.offset) { _, preset in
                let isActive = vm.countdownTarget == preset.seconds

                Button {
                    let h = preset.seconds / 3600
                    let m = (preset.seconds % 3600) / 60
                    let s = preset.seconds % 60
                    vm.setCountdown(hours: h, minutes: m, seconds: s)
                } label: {
                    if compact {
                        let parts = preset.label.split(separator: " ", maxSplits: 1)
                        HStack(spacing: 2) {
                            Text(String(parts[0]))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                            if parts.count > 1 {
                                Text(String(parts[1]))
                                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                            }
                        }
                        .foregroundColor(isActive ? accentBlue : theme.dim.opacity(0.45))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    } else {
                        Text(preset.label)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(isActive ? accentBlue : theme.dim.opacity(0.45))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Control bar

    private var controlBar: some View {
        HStack(spacing: compact ? 8 : 16) {
            if !mini {
                if vm.mode == .countdown {
                    CtrlBtn("SET TIME", icon: "slider.horizontal.3", color: accentBlue, filled: false, compact: compact) {
                        withAnimation { showSetTime = true }
                    }
                }

                CtrlBtn("RESET", icon: "arrow.counterclockwise", color: theme.dim, filled: false, compact: compact) {
                    withAnimation { vm.reset() }
                }
            }

            if vm.state == .running {
                CtrlBtn("PAUSE", icon: "pause.fill", color: accentOrange, filled: true, compact: compact, mini: mini) {
                    vm.pause()
                }
            } else {
                CtrlBtn(
                    vm.isFinished ? "RESTART" : "START",
                    icon: "play.fill",
                    color: vm.isFinished ? accentOrange : accentGreen,
                    filled: true,
                    compact: compact,
                    mini: mini
                ) {
                    if vm.isFinished { vm.reset() }
                    vm.start()
                }
                .disabled(!vm.canStart && !vm.isFinished)
            }
        }
    }

    // MARK: - Time's up overlay

    private var timesUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 32) {
                Text("TIME'S UP")
                    .font(.system(size: 52, weight: .black, design: .monospaced))
                    .foregroundColor(accentRed)
                    .tracking(12)
                    .shadow(color: accentRed.opacity(0.6), radius: 30)
                CtrlBtn("RESTART", icon: "arrow.counterclockwise", color: accentGreen, filled: true) {
                    vm.reset()
                }
            }
        }
    }
}

// MARK: - Reusable control button

struct CtrlBtn: View {
    let label: String
    let icon: String
    let color: Color
    let filled: Bool
    let compact: Bool
    let mini: Bool
    let action: () -> Void

    @State private var hovered = false

    init(_ label: String, icon: String, color: Color, filled: Bool, compact: Bool = false, mini: Bool = false, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.color = color
        self.filled = filled; self.compact = compact; self.mini = mini; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: compact ? 0 : 7) {
                Image(systemName: icon).font(.system(size: mini ? 10 : 12, weight: .semibold))
                if !compact {
                    Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).tracking(2)
                }
            }
            .foregroundColor(filled ? .black : (hovered ? color : color.opacity(0.7)))
            .padding(.horizontal, mini ? 7 : (compact ? 11 : 20))
            .padding(.vertical, mini ? 5 : 11)
            .background(Group {
                if filled {
                    RoundedRectangle(cornerRadius: mini ? 6 : 8).fill(hovered ? color.opacity(0.8) : color)
                } else {
                    RoundedRectangle(cornerRadius: mini ? 6 : 8).stroke(hovered ? color.opacity(0.7) : color.opacity(0.3), lineWidth: 1.5)
                }
            })
            .scaleEffect(hovered ? 1.02 : 1)
            .animation(.easeOut(duration: 0.1), value: hovered)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
