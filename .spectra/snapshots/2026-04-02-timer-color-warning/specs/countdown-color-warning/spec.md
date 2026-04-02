### Requirement: Warning level computed from remaining fraction

The system SHALL compute a `warningLevel` enum (`none`, `caution`, `danger`) in `TimerViewModel` based on the remaining fraction of the countdown target.
- `none`: remaining fraction > 0.20, or timer is idle, or mode is count-up
- `caution`: remaining fraction ≤ 0.20 AND > 0.10, and timer is running or paused
- `danger`: remaining fraction ≤ 0.10, and timer is running or paused

#### Scenario: No warning at start

- **WHEN** a countdown of 10 minutes has just started and 9 minutes remain (90% left)
- **THEN** `warningLevel` SHALL be `none`

#### Scenario: Caution threshold crossed

- **WHEN** a countdown of 10 minutes has 1 minute 59 seconds remaining (≈ 19.8% left)
- **THEN** `warningLevel` SHALL be `caution`

#### Scenario: Danger threshold crossed

- **WHEN** a countdown of 10 minutes has 59 seconds remaining (≈ 9.8% left)
- **THEN** `warningLevel` SHALL be `danger`

#### Scenario: Idle state produces no warning

- **WHEN** the timer is idle (not started) and a countdown target is set
- **THEN** `warningLevel` SHALL be `none` regardless of the target value

#### Scenario: Count-up mode produces no warning

- **WHEN** the timer is in count-up mode and running
- **THEN** `warningLevel` SHALL be `none`

---

### Requirement: Digit color reflects warning level

The flip clock digit color SHALL change based on `warningLevel`:
- `none` → off-white (rgb 0.95, 0.95, 0.92)
- `caution` → yellow (rgb 1.0, 0.85, 0.2)
- `danger` → red (rgb 1.0, 0.35, 0.35)

The color transition SHALL use a 0.4-second ease animation.

#### Scenario: Digits turn yellow at caution

- **WHEN** `warningLevel` becomes `caution`
- **THEN** all six flip clock digits SHALL animate to yellow within 0.4 seconds

#### Scenario: Digits turn red at danger

- **WHEN** `warningLevel` becomes `danger`
- **THEN** all six flip clock digits SHALL animate to red within 0.4 seconds

#### Scenario: Digits return to default on reset

- **WHEN** the user resets the timer
- **THEN** all six flip clock digits SHALL return to off-white

---

### Requirement: Progress bar color reflects warning level

The progress bar gradient SHALL change color based on `warningLevel`:
- `none` → blue-to-green gradient (existing behavior)
- `caution` → solid yellow (rgb 1.0, 0.85, 0.2)
- `danger` → solid red (rgb 1.0, 0.35, 0.35)

The color transition SHALL use a 0.4-second ease animation.

#### Scenario: Progress bar turns yellow at caution

- **WHEN** `warningLevel` becomes `caution`
- **THEN** the progress bar SHALL animate to yellow within 0.4 seconds

#### Scenario: Progress bar turns red at danger

- **WHEN** `warningLevel` becomes `danger`
- **THEN** the progress bar SHALL animate to red within 0.4 seconds
