## MODIFIED Requirements

### Requirement: Timer completion plays three audible dings

When the countdown reaches zero, `triggerFinishAlert()` SHALL play a three-sound sequence: "Glass" at 0.0 seconds, "Glass" at 0.3 seconds, and "Ping" at 0.6 seconds.

Each playback SHALL use an independent `NSSound` instance created via `NSSound(named: <name>)?.copy() as? NSSound` to avoid the issue where `play()` is ignored on an already-playing instance.

The sound names and delays SHALL be `[("Glass", 0.0), ("Glass", 0.3), ("Ping", 0.6)]`.

#### Scenario: Countdown finishes

- **WHEN** the countdown timer reaches zero
- **THEN** two "Glass" sounds and one "Ping" sound SHALL play in sequence
- **THEN** each sound SHALL be audible as a distinct tone
- **THEN** the total sequence duration SHALL be approximately 0.6 seconds
