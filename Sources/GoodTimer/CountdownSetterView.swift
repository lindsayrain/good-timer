import SwiftUI

struct CountdownSetterView: View {
    @ObservedObject var vm: TimerViewModel
    @Binding var isPresented: Bool

    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    @State private var seconds: Int = 0

    private let accent  = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let cardBG  = Color(red: 0.12, green: 0.12, blue: 0.16)
    private let overlay = Color.black.opacity(0.75)

    var body: some View {
        ZStack {
            overlay
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 28) {
                Text("Set Countdown")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    TimePickerColumn(label: "HRS", value: $hours, range: 0...99)
                    colonSep
                    TimePickerColumn(label: "MIN", value: $minutes, range: 0...59)
                    colonSep
                    TimePickerColumn(label: "SEC", value: $seconds, range: 0...59)
                }

                HStack(spacing: 16) {
                    Button("Cancel") { isPresented = false }
                        .buttonStyle(GhostButtonStyle())

                    Button("Set") {
                        vm.setCountdown(hours: hours, minutes: minutes, seconds: seconds)
                        isPresented = false
                    }
                    .buttonStyle(AccentButtonStyle(color: accent))
                    .disabled(hours == 0 && minutes == 0 && seconds == 0)
                }
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(cardBG)
                    .shadow(color: .black.opacity(0.6), radius: 40, x: 0, y: 20)
            )
            .frame(maxWidth: 400)
        }
        .onAppear {
            let t = vm.countdownTarget
            hours   = t / 3600
            minutes = (t % 3600) / 60
            seconds = t % 60
        }
    }

    private var colonSep: some View {
        Text(":")
            .font(.system(size: 28, weight: .bold, design: .monospaced))
            .foregroundColor(.white.opacity(0.4))
            .padding(.top, 18)   // align with number area
    }
}

// MARK: - Individual time picker column

struct TimePickerColumn: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    private let fieldBG  = Color(red: 0.18, green: 0.18, blue: 0.24)
    private let btnColor = Color(red: 0.6, green: 0.6, blue: 0.65)

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            VStack(spacing: 8) {
                // Up button
                stepBtn(icon: "chevron.up") {
                    if value < range.upperBound { value += 1 }
                    else { value = range.lowerBound }
                }

                // Number display
                Text(String(format: "%02d", value))
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 70)
                    .multilineTextAlignment(.center)

                // Down button
                stepBtn(icon: "chevron.down") {
                    if value > range.lowerBound { value -= 1 }
                    else { value = range.upperBound }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(fieldBG)
            )
        }
    }

    @ViewBuilder
    private func stepBtn(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(btnColor)
                .frame(width: 44, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button styles

struct AccentButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(configuration.isPressed ? color.opacity(0.7) : color)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
