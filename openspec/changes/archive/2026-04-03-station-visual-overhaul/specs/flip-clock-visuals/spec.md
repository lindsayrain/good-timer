## ADDED Requirements

### Requirement: Dark theme uses pure-black card colors

The dark `AppTheme` card colors SHALL be:
- `cardTop`: `Color(red: 0.13, green: 0.13, blue: 0.15)` (near-black, slightly lighter)
- `cardMid`: `Color(red: 0.09, green: 0.09, blue: 0.11)` (near-black)
- `cardBottom`: `Color(red: 0.06, green: 0.06, blue: 0.08)` (near-black, darkest)

#### Scenario: Dark theme card at rest

- **WHEN** the clock is displayed in dark mode
- **THEN** each card half SHALL render with near-black gradient (cardTop → cardMid for top half, cardMid → cardBottom for bottom half)
- **THEN** the digit SHALL appear in high contrast against the near-black background

## ADDED Requirements

### Requirement: Flip animation uses orthographic projection

The `FlipCard` view's `rotation3DEffect` SHALL use `perspective: 0` (orthographic projection) for both the upper and lower flap animations.

#### Scenario: Digit flips during countdown

- **WHEN** a digit changes during countdown
- **THEN** the flip animation SHALL NOT cause any vertical position shift of the digit
- **THEN** the rotation SHALL appear as a flat vertical compression without 3D perspective distortion

## MODIFIED Requirements

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
