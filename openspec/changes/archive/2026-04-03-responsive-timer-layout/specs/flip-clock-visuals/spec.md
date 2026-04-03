## MODIFIED Requirements

### Requirement: Font matches train station display style

Digit text SHALL use `Font.custom("ChakraPetch-Bold", size: 50)` (Chakra Petch Bold, bundled in app resources).
The font file `ChakraPetch-Bold.ttf` SHALL be placed in `Sources/GoodTimer/Resources/` and declared as `.process("Resources")` in `Package.swift`.
The card corner radius (`ClockLayout.corner`) SHALL be 3pt.
The card width (`ClockLayout.cardW`) SHALL be 62pt.
The card half-height (`ClockLayout.halfH`) SHALL be 46pt.
The digit gap (`ClockLayout.digitGap`) SHALL be 4pt.
The separator width (`ClockLayout.sepW`) SHALL be 28pt.

#### Scenario: Digit rendered on card

- **WHEN** any digit is displayed on a flip card
- **THEN** the digit SHALL be rendered in Chakra Petch Bold at size 50
- **THEN** the font SHALL use the bundled `ChakraPetch-Bold.ttf` resource, NOT the system font
- **WHEN** the font resource fails to load
- **THEN** SwiftUI SHALL fall back to the system font (acceptable degradation)

---

### Requirement: Dark theme uses pure-black card colors

The dark `AppTheme` card colors SHALL be:
- `cardTop`: `Color(red: 0.09, green: 0.09, blue: 0.11)`
- `cardMid`: `Color(red: 0.09, green: 0.09, blue: 0.11)`
- `cardBottom`: `Color(red: 0.09, green: 0.09, blue: 0.11)`

All three card colors SHALL be identical, producing a flat solid background with no visible gradient.

#### Scenario: Dark theme card at rest

- **WHEN** the clock is displayed in dark mode
- **THEN** each card half SHALL render with a uniform solid color
- **THEN** the digit SHALL appear in high contrast against the near-black background

---

### Requirement: Card gradient provides depth

Each flip card half SHALL render with a LinearGradient fill:
- Top half: from `cardTop` color to `cardMid` color
- Bottom half: from `cardMid` color to `cardBottom` color

The gradient colors SHALL be determined by the active theme. When `cardTop`, `cardMid`, and `cardBottom` are identical, the result SHALL be a flat solid fill.

#### Scenario: Card at rest

- **WHEN** the clock is displayed
- **THEN** each half shows the appropriate gradient or flat fill based on theme colors

## ADDED Requirements

### Requirement: HalfCard clips content to card bounds

Each HalfCard view SHALL apply `.clipped()` on its outer `.frame(width: W, height: H)` to prevent digit glyphs from visually extending beyond the card boundary.

#### Scenario: Card with reduced height

- **WHEN** the card half-height is smaller than the font's ascender/descender extent
- **THEN** the digit glyph SHALL be clipped at the card boundary
- **THEN** no part of the digit SHALL be visible outside the card rectangle

---

### Requirement: Bottom card half has no shadow

The HalfCard view SHALL NOT apply any `.shadow()` modifier. Both top and bottom halves SHALL render without drop shadows.

#### Scenario: Card at rest

- **WHEN** the clock is displayed
- **THEN** no shadow artifact SHALL be visible on or around any card half
