## ADDED Requirements

### Requirement: Preset bar includes a 5-second quick option

The preset bar SHALL include a "5 SEC" option as the first entry, followed by the existing minute-based presets (5 MIN, 10 MIN, 15 MIN, 25 MIN, 45 MIN).

The `presets` data structure SHALL use `(label: String, seconds: Int)` tuples to support both second-level and minute-level presets.

#### Scenario: User selects 5 SEC preset

- **WHEN** the user clicks the "5 SEC" preset button
- **THEN** the countdown timer SHALL be set to 5 seconds
- **THEN** the "5 SEC" label SHALL be highlighted as the active preset
