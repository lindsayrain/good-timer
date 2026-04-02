import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TimerViewModel()
    @State private var showSetTime = false
    @State private var alwaysOnTop = false

    // Colors
    private let bg           = Color(red: 0.06, green: 0.06, blue: 0.08)
    private let accentBlue   = Color(red: 0.3,  green: 0.7,  blue: 1.0)
    private let accentGreen  = Color(red: 0.2,  green: 0.85, blue: 0.5)
    private let accentOrange = Color(red: 1.0,  green: 0.55, blue: 0.2)
    private let accentRed    = Color(red: 1.0,  green: 0.3,  blue: 0.3)
    private let dim          = Color(red: 0.4,  green: 0.4,  blue: 0.45)

    // Quick-preset minutes available in countdown mode
    private let presets = [5, 10, 15, 25, 45]

    // Digit color based on warning level (spec: none=off-white, caution=yellow, danger=red)
    private var digitColor: Color {
        switch vm.warningLevel {
        case .none:    return Color(red: 0.95, green: 0.95, blue: 0.92)
        case .caution: return Color(red: 1.0,  green: 0.85, blue: 0.2)
        case .danger:  return Color(red: 1.0,  green: 0.35, blue: 0.35)
        }
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                if vm.mode == .countdown {
                    progressBar.padding(.bottom, 20)
                }

                FlipClockDisplay(vm: vm, digitColor: digitColor)
                    .animation(.easeInOut(duration: 0.4), value: vm.warningLevel)

                UnitLabels()
                    .padding(.top, 10)

                // Quick presets (countdown mode, idle/paused only)
                if vm.mode == .countdown && vm.state != .running {
                    presetBar.padding(.top, 20)
                }

                Spacer()

                controlBar
                    .padding(.bottom, 28)
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
        .frame(minWidth: 780, minHeight: 460)
        .preferredColorScheme(.dark)
        .onAppear { vm.updateDigits(for: vm.displaySeconds) }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Text("GOOD TIMER")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(dim)
                .tracking(4)

            Spacer()

            // Always-on-top toggle
            Button {
                alwaysOnTop.toggle()
                NSApp.windows.first?.level = alwaysOnTop ? .floating : .normal
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                    Text(alwaysOnTop ? "ON" : "OFF")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(alwaysOnTop ? .black : dim)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(alwaysOnTop ? accentBlue : Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(alwaysOnTop ? Color.clear : dim.opacity(0.25), lineWidth: 1)
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
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(dim.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func modeSegment(label: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 10))
                Text(label).font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(isActive ? .black : dim)
            .padding(.horizontal, 12)
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
        case .none:    return accentBlue  // will use gradient below
        case .caution: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case .danger:  return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.07))
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
            ForEach(presets, id: \.self) { min in
                let isActive = vm.countdownTarget == min * 60

                Button {
                    vm.setCountdown(hours: 0, minutes: min, seconds: 0)
                } label: {
                    Text("\(min) MIN")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(isActive ? .black : dim)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isActive ? accentBlue : Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isActive ? Color.clear : dim.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Control bar

    private var controlBar: some View {
        HStack(spacing: 16) {
            if vm.mode == .countdown {
                CtrlBtn("SET TIME", icon: "slider.horizontal.3", color: accentBlue, filled: false) {
                    withAnimation { showSetTime = true }
                }
            }

            CtrlBtn("RESET", icon: "arrow.counterclockwise", color: dim, filled: false) {
                withAnimation { vm.reset() }
            }

            if vm.state == .running {
                CtrlBtn("PAUSE", icon: "pause.fill", color: accentOrange, filled: true) {
                    vm.pause()
                }
            } else {
                CtrlBtn(
                    vm.isFinished ? "RESTART" : "START",
                    icon: "play.fill",
                    color: vm.isFinished ? accentOrange : accentGreen,
                    filled: true
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
    let action: () -> Void

    @State private var hovered = false

    init(_ label: String, icon: String, color: Color, filled: Bool, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.color = color
        self.filled = filled; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).tracking(2)
            }
            .foregroundColor(filled ? .black : (hovered ? color : color.opacity(0.7)))
            .padding(.horizontal, 20)
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
