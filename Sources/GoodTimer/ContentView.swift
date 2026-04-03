import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TimerViewModel()
    @State private var showSetTime = false
    @State private var alwaysOnTop = false
    @State private var isDark = true
    @State private var windowWidth: CGFloat = 780

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

    private var digitColor: Color {
        switch vm.warningLevel {
        case .none:    return theme.digitNormal
        case .caution: return Color(red: 1.0,  green: 0.85, blue: 0.2)
        case .danger:  return Color(red: 1.0,  green: 0.35, blue: 0.35)
        }
    }

    var body: some View {
        ZStack {
            theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if vm.mode == .countdown {
                    progressBar.padding(.bottom, 8)
                }

                GeometryReader { geo in
                    let scale = min(
                        geo.size.width / ClockLayout.baseW,
                        geo.size.height / ClockLayout.baseH
                    )
                    VStack(spacing: 0) {
                        FlipClockDisplay(vm: vm, digitColor: digitColor, theme: theme)
                            .animation(.easeInOut(duration: 0.4), value: vm.warningLevel)
                        UnitLabels(theme: theme)
                            .padding(.top, 10)
                        presetBar.padding(.top, 20)
                            .opacity(vm.mode == .countdown && vm.state != .running ? 1 : 0)
                    }
                    .scaleEffect(scale)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .clipped()

                controlBar
                    .padding(.vertical, 12)
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
                .onAppear { windowWidth = geo.size.width }
                .onChange(of: geo.size) { newSize in windowWidth = newSize.width }
        })
        .preferredColorScheme(isDark ? .dark : .light)
        .onAppear { vm.updateDigits(for: vm.displaySeconds) }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            if !compact {
                Text("GOOD TIMER")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(theme.dim)
                    .tracking(4)
            }

            Spacer()

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

            // Always-on-top toggle
            Button {
                alwaysOnTop.toggle()
                NSApp.windows.first?.level = alwaysOnTop ? .floating : .normal
            } label: {
                HStack(spacing: compact ? 0 : 6) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                    if !compact {
                        Text(alwaysOnTop ? "ON" : "OFF")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
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
        .padding(.horizontal, compact ? 8 : 28)
        .padding(.top, compact ? 8 : 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func modeSegment(label: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: compact ? 0 : 5) {
                Image(systemName: icon).font(.system(size: 10))
                if !compact {
                    Text(label).font(.system(size: 11, weight: .semibold, design: .monospaced))
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
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.progressTrack)
                RoundedRectangle(cornerRadius: 2)
                    .fill(vm.warningLevel == .none
                          ? LinearGradient(colors: [accentBlue, accentGreen], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [progressBarColor, progressBarColor], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * (1 - vm.progressFraction))
                    .animation(.easeInOut(duration: 0.4), value: vm.warningLevel)
            }
            .frame(height: 3)
        }
        .frame(height: 3)
        .padding(.horizontal, 28)
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
            if vm.mode == .countdown {
                CtrlBtn("SET TIME", icon: "slider.horizontal.3", color: accentBlue, filled: false, compact: compact) {
                    withAnimation { showSetTime = true }
                }
            }

            CtrlBtn("RESET", icon: "arrow.counterclockwise", color: theme.dim, filled: false, compact: compact) {
                withAnimation { vm.reset() }
            }

            if vm.state == .running {
                CtrlBtn("PAUSE", icon: "pause.fill", color: accentOrange, filled: true, compact: compact) {
                    vm.pause()
                }
            } else {
                CtrlBtn(
                    vm.isFinished ? "RESTART" : "START",
                    icon: "play.fill",
                    color: vm.isFinished ? accentOrange : accentGreen,
                    filled: true,
                    compact: compact
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
    let action: () -> Void

    @State private var hovered = false

    init(_ label: String, icon: String, color: Color, filled: Bool, compact: Bool = false, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.color = color
        self.filled = filled; self.compact = compact; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: compact ? 0 : 7) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                if !compact {
                    Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).tracking(2)
                }
            }
            .foregroundColor(filled ? .black : (hovered ? color : color.opacity(0.7)))
            .padding(.horizontal, compact ? 11 : 20)
            .padding(.vertical, 11)
            .background(Group {
                if filled {
                    RoundedRectangle(cornerRadius: 8).fill(hovered ? color.opacity(0.8) : color)
                } else {
                    RoundedRectangle(cornerRadius: 8).stroke(hovered ? color.opacity(0.7) : color.opacity(0.3), lineWidth: 1.5)
                }
            })
            .scaleEffect(hovered ? 1.02 : 1)
            .animation(.easeOut(duration: 0.1), value: hovered)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
