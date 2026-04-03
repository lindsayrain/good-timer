## ADDED Requirements

### Requirement: App bundle has valid macOS structure

The system SHALL produce a `GoodTimer.app` directory with the standard macOS bundle layout: `Contents/MacOS/GoodTimer` (executable), `Contents/Info.plist`, and `Contents/Resources/AppIcon.icns`.

#### Scenario: Bundle structure is correct

- **WHEN** `package.sh` completes successfully
- **THEN** `GoodTimer.app/Contents/MacOS/GoodTimer` SHALL be an executable binary
- **THEN** `GoodTimer.app/Contents/Info.plist` SHALL exist and be a valid property list
- **THEN** `GoodTimer.app/Contents/Resources/AppIcon.icns` SHALL exist


<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->

### Requirement: Info.plist contains required metadata

The `Info.plist` SHALL define `CFBundleIdentifier` as `com.goodtimer.app`, `CFBundleName` as `GoodTimer`, `CFBundleExecutable` as `GoodTimer`, `LSMinimumSystemVersion` as `13.0`, `CFBundleShortVersionString` as `1.0.0`, and `NSHighResolutionCapable` as `true`.

#### Scenario: App is recognized by macOS

- **WHEN** the `.app` bundle is placed in `/Applications`
- **THEN** Spotlight SHALL index GoodTimer by name
- **THEN** the app SHALL appear with its custom icon in Finder


<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->

### Requirement: App icon uses flip-card visual design

The `AppIcon.icns` SHALL be generated from `generate-icon.swift` using Chakra Petch Bold font and displaying the digit "9".
The script SHALL use standard CoreGraphics bottom-left origin (y=0 at bottom) WITHOUT Y-axis context flip, ensuring text renders upright.
The `ctx.textMatrix` SHALL be set to `.identity` before each CTLineDraw call.
All other visual properties remain: dark rounded-rectangle card (`#0D0D0D` fill), horizontal center gap, near-white digit color (`#F7F6F2`), 10 standard macOS sizes.

#### Scenario: Icon renders with correct digit orientation

- **WHEN** `generate-icon.swift` is executed
- **THEN** the digit "9" SHALL appear upright (loop at top, tail descending)
- **THEN** the digit SHALL use Chakra Petch Bold typeface

#### Scenario: Icon visual matches flip-card design

- **WHEN** the icon is displayed at 512px or larger
- **THEN** the card background SHALL be near-black
- **THEN** a horizontal gap SHALL visually separate the upper and lower halves
- **THEN** the digit "9" in Chakra Petch Bold SHALL be visible in both halves

## Requirements

<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->


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

### Requirement: App bundle has valid macOS structure

The system SHALL produce a `GoodTimer.app` directory with the standard macOS bundle layout: `Contents/MacOS/GoodTimer` (executable), `Contents/Info.plist`, and `Contents/Resources/AppIcon.icns`.

#### Scenario: Bundle structure is correct

- **WHEN** `package.sh` completes successfully
- **THEN** `GoodTimer.app/Contents/MacOS/GoodTimer` SHALL be an executable binary
- **THEN** `GoodTimer.app/Contents/Info.plist` SHALL exist and be a valid property list
- **THEN** `GoodTimer.app/Contents/Resources/AppIcon.icns` SHALL exist

---
### Requirement: Info.plist contains required metadata

The `Info.plist` SHALL define `CFBundleIdentifier` as `com.goodtimer.app`, `CFBundleName` as `GoodTimer`, `CFBundleExecutable` as `GoodTimer`, `LSMinimumSystemVersion` as `13.0`, `CFBundleShortVersionString` as `1.0.0`, and `NSHighResolutionCapable` as `true`.

#### Scenario: App is recognized by macOS

- **WHEN** the `.app` bundle is placed in `/Applications`
- **THEN** Spotlight SHALL index GoodTimer by name
- **THEN** the app SHALL appear with its custom icon in Finder

---
### Requirement: App icon uses flip-card visual design

The `AppIcon.icns` SHALL be generated from `generate-icon.swift` using Chakra Petch Bold font and displaying the digit "9".
The script SHALL use standard CoreGraphics bottom-left origin (y=0 at bottom) WITHOUT Y-axis context flip, ensuring text renders upright.
The `ctx.textMatrix` SHALL be set to `.identity` before each CTLineDraw call.
All other visual properties remain: dark rounded-rectangle card (`#0D0D0D` fill), horizontal center gap, near-white digit color (`#F7F6F2`), 10 standard macOS sizes.

#### Scenario: Icon renders with correct digit orientation

- **WHEN** `generate-icon.swift` is executed
- **THEN** the digit "9" SHALL appear upright (loop at top, tail descending)
- **THEN** the digit SHALL use Chakra Petch Bold typeface

#### Scenario: Icon visual matches flip-card design

- **WHEN** the icon is displayed at 512px or larger
- **THEN** the card background SHALL be near-black
- **THEN** a horizontal gap SHALL visually separate the upper and lower halves
- **THEN** the digit "9" in Chakra Petch Bold SHALL be visible in both halves