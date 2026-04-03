## ADDED Requirements

### Requirement: App bundle has valid macOS structure

The system SHALL produce a `GoodTimer.app` directory with the standard macOS bundle layout: `Contents/MacOS/GoodTimer` (executable), `Contents/Info.plist`, and `Contents/Resources/AppIcon.icns`.

#### Scenario: Bundle structure is correct

- **WHEN** `package.sh` completes successfully
- **THEN** `GoodTimer.app/Contents/MacOS/GoodTimer` SHALL be an executable binary
- **THEN** `GoodTimer.app/Contents/Info.plist` SHALL exist and be a valid property list
- **THEN** `GoodTimer.app/Contents/Resources/AppIcon.icns` SHALL exist

### Requirement: Info.plist contains required metadata

The `Info.plist` SHALL define `CFBundleIdentifier` as `com.goodtimer.app`, `CFBundleName` as `GoodTimer`, `CFBundleExecutable` as `GoodTimer`, `LSMinimumSystemVersion` as `13.0`, `CFBundleShortVersionString` as `1.0.0`, and `NSHighResolutionCapable` as `true`.

#### Scenario: App is recognized by macOS

- **WHEN** the `.app` bundle is placed in `/Applications`
- **THEN** Spotlight SHALL index GoodTimer by name
- **THEN** the app SHALL appear with its custom icon in Finder

### Requirement: App icon uses flip-card visual design

The `AppIcon.icns` SHALL be generated programmatically from `generate-icon.swift`. The icon SHALL depict a dark rounded-rectangle card (`#1A1A1F` fill) with a horizontal center gap dividing it into two halves, each displaying the digit "0" in white bold system font. The icon SHALL be exported at 10 standard macOS sizes: 16, 32, 64, 128, 256, 512, 1024 px (including @2x variants).

#### Scenario: Icon renders at all required sizes

- **WHEN** `generate-icon.swift` is executed
- **THEN** `AppIcon.iconset/` SHALL contain PNG files for all 10 required sizes
- **THEN** `iconutil` SHALL successfully convert the iconset to `AppIcon.icns`

#### Scenario: Icon visual matches flip-card design

- **WHEN** the icon is displayed at 512px or larger
- **THEN** the card background SHALL be dark (`#1A1A1F`)
- **THEN** a horizontal gap SHALL visually separate the upper and lower halves
- **THEN** white bold digit "0" SHALL be visible in both halves

