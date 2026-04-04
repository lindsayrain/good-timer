## MODIFIED Requirements

### Requirement: Digit color reflects warning level

The flip clock digit color SHALL change based on `warningLevel` and the current theme:

**Dark theme:**
- `none` → off-white (rgb 0.95, 0.95, 0.92)
- `caution` → yellow (rgb 1.0, 0.85, 0.2)
- `danger` → red (rgb 1.0, 0.35, 0.35)

**Light theme:**
- `none` → dark (rgb 0.14, 0.13, 0.12)
- `caution` → deep amber (rgb 0.85, 0.55, 0.0)
- `danger` → deep red (rgb 0.85, 0.15, 0.15)

The color transition SHALL use a 0.4-second ease animation.

#### Scenario: Digits turn yellow at caution in dark theme

- **WHEN** `warningLevel` becomes `caution` and dark theme is active
- **THEN** all six flip clock digits SHALL animate to yellow (rgb 1.0, 0.85, 0.2) within 0.4 seconds

#### Scenario: Digits turn deep amber at caution in light theme

- **WHEN** `warningLevel` becomes `caution` and light theme is active
- **THEN** all six flip clock digits SHALL animate to deep amber (rgb 0.85, 0.55, 0.0) within 0.4 seconds

#### Scenario: Digits turn red at danger in dark theme

- **WHEN** `warningLevel` becomes `danger` and dark theme is active
- **THEN** all six flip clock digits SHALL animate to red (rgb 1.0, 0.35, 0.35) within 0.4 seconds

#### Scenario: Digits turn deep red at danger in light theme

- **WHEN** `warningLevel` becomes `danger` and light theme is active
- **THEN** all six flip clock digits SHALL animate to deep red (rgb 0.85, 0.15, 0.15) within 0.4 seconds

#### Scenario: Digits return to default on reset

- **WHEN** the user resets the timer
- **THEN** all six flip clock digits SHALL return to the theme's default digit color
