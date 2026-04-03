import SwiftUI
import Combine

enum TimerMode {
    case countdown
    case countup
}

enum TimerState {
    case idle
    case running
    case paused
}

enum WarningLevel {
    case none
    case caution  // ≤ 20% remaining
    case danger   // ≤ 10% remaining
}

class TimerViewModel: ObservableObject {
    // MARK: - Published state
    @Published var mode: TimerMode = .countdown
    @Published var state: TimerState = .idle
    @Published var elapsedSeconds: Int = 0
    @Published var countdownTarget: Int = 300  // default 5 minutes

    // Digit values published individually so flip cards can animate only changed digits
    @Published var digits: [Int] = [0, 0, 0, 0, 0, 0]  // HH MM SS (6 digits)
    @Published var previousDigits: [Int] = [0, 0, 0, 0, 0, 0]
    @Published var warningLevel: WarningLevel = .none

    // MARK: - Private
    private var timer: AnyCancellable?
    private var startDate: Date?
    private var accumulatedSeconds: Int = 0

    // MARK: - Computed
    var displaySeconds: Int {
        switch mode {
        case .countdown:
            return max(0, countdownTarget - elapsedSeconds)
        case .countup:
            return elapsedSeconds
        }
    }

    var isFinished: Bool {
        mode == .countdown && elapsedSeconds >= countdownTarget
    }

    var canStart: Bool {
        if mode == .countdown {
            return countdownTarget > 0 && !isFinished
        }
        return true
    }

    var progressFraction: Double {
        guard mode == .countdown, countdownTarget > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(countdownTarget)
    }

    private func computeWarningLevel() -> WarningLevel {
        guard mode == .countdown,
              state == .running || state == .paused,
              countdownTarget > 0 else { return .none }
        let remaining = 1.0 - progressFraction
        if remaining <= 0.10 { return .danger }
        if remaining <= 0.20 { return .caution }
        return .none
    }

    // MARK: - Controls
    func start() {
        guard state != .running else { return }
        state = .running
        startDate = Date()
        scheduleTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        accumulatedSeconds = elapsedSeconds
        timer?.cancel()
        timer = nil
    }

    func reset() {
        timer?.cancel()
        timer = nil
        state = .idle
        accumulatedSeconds = 0
        elapsedSeconds = 0
        startDate = nil
        warningLevel = .none
        updateDigits(for: displaySeconds)
    }

    func toggleMode() {
        reset()
        mode = (mode == .countdown) ? .countup : .countdown
        updateDigits(for: displaySeconds)
    }

    func setCountdown(hours: Int, minutes: Int, seconds: Int) {
        let total = (hours * 3600) + (minutes * 60) + seconds
        countdownTarget = total
        if state != .running {
            reset()
            updateDigits(for: displaySeconds)
        }
    }

    // MARK: - Private helpers
    private func scheduleTimer() {
        startDate = Date()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard let startDate = startDate else { return }
        let newElapsed = accumulatedSeconds + Int(Date().timeIntervalSince(startDate))

        if mode == .countdown && newElapsed >= countdownTarget {
            elapsedSeconds = countdownTarget
            updateDigits(for: displaySeconds)
            timer?.cancel()
            timer = nil
            state = .paused
            triggerFinishAlert()
        } else {
            elapsedSeconds = newElapsed
            updateDigits(for: displaySeconds)
            warningLevel = computeWarningLevel()
        }
    }

    private func triggerFinishAlert() {
        let delays: [Double] = [0, 0.2, 0.4]
        for delay in delays {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard let sound = NSSound(named: "Glass")?.copy() as? NSSound else { return }
                sound.play()
            }
        }
    }

    func updateDigits(for totalSeconds: Int) {
        let clamped = max(0, min(totalSeconds, 359999)) // max 99:59:59
        let h = clamped / 3600
        let m = (clamped % 3600) / 60
        let s = clamped % 60

        let newDigits = [
            h / 10, h % 10,
            m / 10, m % 10,
            s / 10, s % 10
        ]

        previousDigits = digits
        digits = newDigits
    }
}
