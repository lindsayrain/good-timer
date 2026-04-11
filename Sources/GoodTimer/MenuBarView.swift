import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var vm: TimerViewModel
    @EnvironmentObject var updateChecker: UpdateChecker
    @State private var showUpToDate = false

    private let accentBlue   = Color(red: 0.3,  green: 0.7,  blue: 1.0)
    private let accentGreen  = Color(red: 0.2,  green: 0.85, blue: 0.5)
    private let accentOrange = Color(red: 1.0,  green: 0.55, blue: 0.2)
    private let accentRed    = Color(red: 1.0,  green: 0.3,  blue: 0.3)

    private let presets: [(label: String, seconds: Int)] = [
        ("5m", 300), ("10m", 600), ("15m", 900), ("25m", 1500)
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Timer display
            timerDisplay

            // Progress bar (countdown only)
            if vm.mode == .countdown {
                progressBar
            }

            // Control buttons
            controlButtons

            // Quick presets (countdown idle only)
            if vm.mode == .countdown && vm.state != .running {
                Divider()
                presetButtons
            }

            Divider()

            // Update notification
            if updateChecker.isUpdateAvailable, let version = updateChecker.latestVersion {
                Button {
                    if let url = updateChecker.releaseURL {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 11))
                        Text("v\(version) available — Download")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .foregroundColor(accentBlue)
            }

            // Check for updates button
            Button {
                let wasAvailable = updateChecker.isUpdateAvailable
                updateChecker.manualCheck()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if !updateChecker.isUpdateAvailable && !wasAvailable {
                        showUpToDate = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showUpToDate = false
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                    Text(showUpToDate ? "Up to date" : "Check for Updates")
                        .font(.system(size: 11, weight: .medium))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .disabled(updateChecker.isChecking)

            // Open main window
            Button {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                    window.makeKeyAndOrderFront(nil)
                }
            } label: {
                HStack {
                    Image(systemName: "macwindow")
                    Text("Open Main Window")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundColor(accentBlue)
        }
        .padding(16)
        .frame(width: 240)
    }

    // MARK: - Timer display

    private var timerDisplay: some View {
        let total = vm.displaySeconds
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60

        return VStack(spacing: 2) {
            if h > 0 {
                Text(String(format: "%d:%02d:%02d", h, m, s))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(digitColor)
                HStack(spacing: 24) {
                    Text("HOURS").frame(width: 50)
                    Text("MIN").frame(width: 30)
                    Text("SEC").frame(width: 30)
                }
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
            } else {
                Text(String(format: "%02d:%02d", m, s))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(digitColor)
                HStack(spacing: 32) {
                    Text("MINUTES")
                    Text("SECONDS")
                }
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
            }
        }
    }

    private var digitColor: Color {
        switch vm.warningLevel {
        case .none:    return .primary
        case .caution: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case .danger:  return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
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
                    .fill(Color.primary.opacity(0.1))
                RoundedRectangle(cornerRadius: 2)
                    .fill(vm.warningLevel == .none
                          ? LinearGradient(colors: [accentBlue, accentGreen], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [progressBarColor, progressBarColor], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * (1 - vm.progressFraction))
            }
            .frame(height: 3)
        }
        .frame(height: 3)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 8) {
            // Reset
            Button {
                vm.reset()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .semibold))
                    Text("RESET")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            // Start / Pause / Restart
            if vm.state == .running {
                Button {
                    vm.pause()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("PAUSE")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(accentOrange)
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    if vm.isFinished { vm.reset() }
                    vm.start()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(vm.isFinished ? "RESTART" : "START")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(vm.isFinished ? accentOrange : accentGreen)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!vm.canStart && !vm.isFinished)
            }
        }
    }

    // MARK: - Presets

    private var presetButtons: some View {
        HStack(spacing: 6) {
            ForEach(Array(presets.enumerated()), id: \.offset) { _, preset in
                let isActive = vm.countdownTarget == preset.seconds
                Button {
                    let h = preset.seconds / 3600
                    let m = (preset.seconds % 3600) / 60
                    let s = preset.seconds % 60
                    vm.setCountdown(hours: h, minutes: m, seconds: s)
                } label: {
                    Text(preset.label)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(isActive ? accentBlue : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
