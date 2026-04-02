## Why

Instructors projecting the timer need a passive visual cue — students and the instructor should both notice when time is running short without having to read the exact digits. Currently the clock face stays the same color throughout the countdown, providing no urgency signal.

## What Changes

- Flip card digit color shifts from the default off-white to **yellow** when remaining time falls below 20% of the countdown target
- Digit color shifts to **red** when remaining time falls below 10% of the countdown target
- Color transitions use a smooth animation (0.4s ease) so the change is noticeable but not jarring
- Color warning applies only in countdown mode; count-up mode is unaffected
- Progress bar color mirrors the same thresholds (yellow / red) for consistency

## Capabilities

### New Capabilities

- `countdown-color-warning`: Visual color change on flip clock digits and progress bar as countdown approaches zero, with two thresholds (20% → yellow, 10% → red)

### Modified Capabilities

(none)

## Impact

- Affected code: `Sources/GoodTimer/FlipClockView.swift` (digit text color), `Sources/GoodTimer/ContentView.swift` (progress bar gradient), `Sources/GoodTimer/TimerViewModel.swift` (expose warning level)
