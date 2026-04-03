## Requirements

### Requirement: Flip animation uses dual-flap mechanism

The flip animation SHALL use two independent flaps anchored at the center line:
- Upper flap (old digit top half): SHALL rotate from 0° to -90° around its bottom edge (anchor: bottom)
- Lower flap (new digit bottom half): SHALL rotate from 90° to 0° around its top edge (anchor: top)
Both flaps SHALL animate simultaneously with an easeInOut curve of duration 0.45s.
The perspective value SHALL be 0.

#### Scenario: Digit changes during countdown

- **WHEN** a digit value changes
- **THEN** the upper flap (old digit top half) folds from flat to edge-on (0° → -90°)
- **THEN** simultaneously the lower flap (new digit bottom half) unfolds from edge-on to flat (90° → 0°)
- **THEN** the static new digit is revealed underneath as both flaps animate away

#### Scenario: Multiple digits change simultaneously

- **WHEN** multiple digits change in the same tick
- **THEN** each FlipCard animates independently without visual glitching


<!-- @trace
source: enhance-flip-clock-ui
updated: 2026-04-02
code:
  - .spectra/changes/enhance-flip-clock-ui.started
  - .spectra/spectra.db
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Card center seam is the only divider

The horizontal divider between card halves SHALL be the 4pt gap between the two HalfCard views.
No additional divider line SHALL be drawn inside HalfCard faces.
No highlight line SHALL be drawn at the top edge of the upper half.

#### Scenario: Card at rest

- **WHEN** the clock is displayed
- **THEN** each card shows only a clean center gap with no drawn lines on the card faces
- **THEN** the digit appears split cleanly at the center seam

#### Scenario: Card during flip

- **WHEN** a flip animation is in progress
- **THEN** the center seam gap remains visible between the static bottom half and the animating flaps


<!-- @trace
source: enhance-flip-clock-ui
updated: 2026-04-02
code:
  - .spectra/changes/enhance-flip-clock-ui.started
  - .spectra/spectra.db
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Card gradient provides depth

Each flip card half SHALL render with a subtle top-to-bottom gradient:
- Top half: from `cardTop` color to `cardMid` color
- Bottom half: from `cardMid` color to `cardBottom` color

#### Scenario: Card at rest

- **WHEN** the clock is displayed
- **THEN** each half shows the appropriate gradient slice


<!-- @trace
source: enhance-flip-clock-ui
updated: 2026-04-02
code:
  - .spectra/changes/enhance-flip-clock-ui.started
  - .spectra/spectra.db
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Font matches train station display style

Digit text SHALL use `Font.custom("ChakraPetch-Bold", size: 76)` (Chakra Petch Bold, bundled in app resources).
The font file `ChakraPetch-Bold.ttf` SHALL be placed in `Sources/GoodTimer/Resources/` and declared as `.process("Resources")` in `Package.swift`.
The card corner radius (`ClockLayout.corner`) SHALL be 3pt.

#### Scenario: Digit rendered on card

- **WHEN** any digit is displayed on a flip card
- **THEN** the digit SHALL be rendered in Chakra Petch Bold at size 76
- **THEN** the font SHALL use the bundled `ChakraPetch-Bold.ttf` resource, NOT the system font
- **WHEN** the font resource fails to load
- **THEN** SwiftUI SHALL fall back to the system font (acceptable degradation)


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

---
### Requirement: Dark and light themes are supported

The app SHALL provide dark and light `AppTheme` variants, each defining:
bg, cardTop, cardMid, cardBottom, divider, cardShadow, separator, label, dim, digitNormal, progressTrack, controlBg.
A theme toggle button (☀/🌙) SHALL appear in the top bar.
Clicking the toggle SHALL switch the entire UI between themes with a 0.25s easeInOut animation.

#### Scenario: User switches to light theme

- **WHEN** user clicks the theme toggle while in dark mode
- **THEN** all UI colors transition to the light theme values within 0.25s
- **THEN** the toggle icon changes from ☀ to 🌙

#### Scenario: User switches to dark theme

- **WHEN** user clicks the theme toggle while in light mode
- **THEN** all UI colors transition to the dark theme values within 0.25s
- **THEN** the toggle icon changes from 🌙 to ☀


<!-- @trace
source: enhance-flip-clock-ui
updated: 2026-04-02
code:
  - .spectra/changes/enhance-flip-clock-ui.started
  - .spectra/spectra.db
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Quick-preset buttons use a low-profile style

Quick-preset buttons SHALL NOT use a filled background.
Quick-preset buttons SHALL use horizontal padding ≤ 10pt and vertical padding ≤ 5pt.
Active preset SHALL be indicated by accent color text only (no filled pill).
Inactive presets SHALL use the dim color at ≤ 0.5 opacity.

#### Scenario: No preset selected

- **WHEN** no quick-preset matches the current countdown target
- **THEN** all preset labels are shown in dim color at ≤ 0.5 opacity with no border or fill

#### Scenario: Preset is active

- **WHEN** the current countdown target matches a preset
- **THEN** that preset label is shown in accent color (full opacity), no filled background

<!-- @trace
source: enhance-flip-clock-ui
updated: 2026-04-02
code:
  - .spectra/changes/enhance-flip-clock-ui.started
  - .spectra/spectra.db
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Dark theme uses pure-black card colors

The dark `AppTheme` card colors SHALL be:
- `cardTop`: `Color(red: 0.13, green: 0.13, blue: 0.15)` (near-black, slightly lighter)
- `cardMid`: `Color(red: 0.09, green: 0.09, blue: 0.11)` (near-black)
- `cardBottom`: `Color(red: 0.06, green: 0.06, blue: 0.08)` (near-black, darkest)

#### Scenario: Dark theme card at rest

- **WHEN** the clock is displayed in dark mode
- **THEN** each card half SHALL render with near-black gradient (cardTop → cardMid for top half, cardMid → cardBottom for bottom half)
- **THEN** the digit SHALL appear in high contrast against the near-black background

---
### Requirement: Flip animation uses orthographic projection

The `FlipCard` view's `rotation3DEffect` SHALL use `perspective: 0` (orthographic projection) for both the upper and lower flap animations.

#### Scenario: Digit flips during countdown

- **WHEN** a digit changes during countdown
- **THEN** the flip animation SHALL NOT cause any vertical position shift of the digit
- **THEN** the rotation SHALL appear as a flat vertical compression without 3D perspective distortion

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