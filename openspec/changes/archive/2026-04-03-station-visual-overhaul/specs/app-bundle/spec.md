## MODIFIED Requirements

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
