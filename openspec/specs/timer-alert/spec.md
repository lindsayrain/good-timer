## Requirements

### Requirement: Timer completion plays three audible dings

When the countdown reaches zero, `triggerFinishAlert()` SHALL play the macOS system sound "Glass" three times with 0.2-second intervals.

Each playback SHALL use an independent `NSSound` instance created via `NSSound(named: "Glass")?.copy() as? NSSound` to avoid the issue where `play()` is ignored on an already-playing instance.

The delays SHALL be `[0, 0.2, 0.4]` seconds from the trigger moment.

#### Scenario: Countdown finishes

- **WHEN** the countdown timer reaches zero
- **THEN** three "Glass" system sounds SHALL play in rapid succession
- **THEN** each sound SHALL be audible as a distinct ding
- **THEN** the total sequence duration SHALL be approximately 0.4 seconds

<!-- @trace
source: station-visual-overhaul
updated: 2026-04-03
code:
  - generate-icon.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Package.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
-->