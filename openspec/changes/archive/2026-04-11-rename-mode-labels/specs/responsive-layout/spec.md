## MODIFIED Requirements

### Requirement: Compact mode hides button labels below 400pt width

When the window width is less than 400pt, the UI SHALL enter compact mode:
- The "GOOD TIMER" title text SHALL be hidden
- Mode toggle segments (TIMER/STOPWATCH) SHALL show only their SF Symbol icons ("timer"/"stopwatch"), hiding text labels
- The always-on-top toggle SHALL show only the pin icon, hiding the "ON"/"OFF" text
- Control bar buttons (SET TIME, RESET, PAUSE, START, RESTART) SHALL show only their icons, hiding text labels
- Preset bar labels SHALL split the number from the unit, rendering the unit (SEC/MIN) at a smaller font size (8pt vs 11pt)

When the window width is 400pt or greater, all button labels SHALL be fully visible.

#### Scenario: Window narrowed below 400pt

- **WHEN** the window width decreases below 400pt
- **THEN** all button text labels are hidden, only SF Symbol icons remain visible
- **THEN** the mode toggle shows a timer icon for Timer mode and a stopwatch icon for Stopwatch mode

#### Scenario: Window widened to 400pt or more

- **WHEN** the window width increases to 400pt or more
- **THEN** all button text labels are restored alongside their icons
- **THEN** the mode toggle SHALL display "TIMER" and "STOPWATCH" as text labels
