## ADDED Requirements

### Requirement: Time adjust buttons in top bar

The top bar SHALL display two small buttons labeled "-15s" and "+15s" to the left of the theme toggle button. The buttons SHALL use monospaced font at size 10pt with pill-shaped background matching the theme's control style.

#### Scenario: Buttons visible in top bar

- **WHEN** the app is displayed
- **THEN** two buttons "-15s" and "+15s" SHALL appear in the top bar, positioned to the left of the theme toggle button

### Requirement: Time adjust modifies countdown target during idle

When the timer is in countdown mode and idle, pressing "+15s" SHALL increase the countdown target by 15 seconds. Pressing "-15s" SHALL decrease the countdown target by 15 seconds, with a minimum of 0.

#### Scenario: Add 15 seconds while idle in countdown

- **WHEN** the timer is in countdown mode, idle, with a target of 300 seconds
- **THEN** pressing "+15s" SHALL set the target to 315 seconds and update the digit display

#### Scenario: Subtract 15 seconds while idle in countdown

- **WHEN** the timer is in countdown mode, idle, with a target of 300 seconds
- **THEN** pressing "-15s" SHALL set the target to 285 seconds and update the digit display

#### Scenario: Subtract below zero is clamped

- **WHEN** the timer is in countdown mode, idle, with a target of 10 seconds
- **THEN** pressing "-15s" SHALL set the target to 0 seconds (not negative)

### Requirement: Time adjust modifies countdown target during running

When the timer is in countdown mode and running, pressing "+15s" SHALL increase the countdown target by 15 seconds. Pressing "-15s" SHALL decrease the countdown target by 15 seconds (minimum 0), and elapsed seconds SHALL be clamped to not exceed the new target.

#### Scenario: Add 15 seconds while running

- **WHEN** the timer is running in countdown mode with target 300 and 200 elapsed
- **THEN** pressing "+15s" SHALL change the target to 315 while elapsed remains 200

#### Scenario: Subtract 15 seconds while running near end

- **WHEN** the timer is running in countdown mode with target 300 and 295 elapsed
- **THEN** pressing "-15s" SHALL change the target to 285 and clamp elapsed to 285

### Requirement: Time adjust modifies elapsed time in count-up mode

When the timer is in count-up mode, pressing "+15s" SHALL increase elapsed seconds by 15. Pressing "-15s" SHALL decrease elapsed seconds by 15, with a minimum of 0.

#### Scenario: Add 15 seconds in count-up mode

- **WHEN** the timer is in count-up mode with 60 elapsed seconds
- **THEN** pressing "+15s" SHALL set elapsed to 75 seconds

#### Scenario: Subtract 15 seconds in count-up mode

- **WHEN** the timer is in count-up mode with 10 elapsed seconds
- **THEN** pressing "-15s" SHALL set elapsed to 0 seconds (clamped)
