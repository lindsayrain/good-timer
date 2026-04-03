## ADDED Requirements

### Requirement: Timer display scales dynamically with window size

The flip clock display area SHALL use a `GeometryReader` with `scaleEffect` to scale proportionally based on available window space.
The scale factor SHALL be calculated as `min(availableWidth / baseW, availableHeight / baseH)` where `baseW` and `baseH` are the natural dimensions of the unscaled timer content.
All elements within the scaled container (digit cards, separators, unit labels, preset bar) SHALL scale uniformly.

#### Scenario: Window enlarged

- **WHEN** the user drags the window to a larger size
- **THEN** the timer display scales up proportionally to fill the available space

#### Scenario: Window shrunk

- **WHEN** the user drags the window to a smaller size
- **THEN** the timer display scales down proportionally to fit the available space

#### Scenario: Scaled content does not overflow

- **WHEN** the timer display is scaled
- **THEN** the scaled content SHALL NOT visually overlap the top bar or control bar
- **THEN** the GeometryReader container SHALL apply `.clipped()` to prevent overflow

---

### Requirement: Compact mode hides button labels below 400pt width

When the window width is less than 400pt, the UI SHALL enter compact mode:
- The "GOOD TIMER" title text SHALL be hidden
- Mode toggle segments (COUNTDOWN/COUNT UP) SHALL show only their SF Symbol icons ("timer"/"stopwatch"), hiding text labels
- The always-on-top toggle SHALL show only the pin icon, hiding the "ON"/"OFF" text
- Control bar buttons (SET TIME, RESET, PAUSE, START, RESTART) SHALL show only their icons, hiding text labels
- Preset bar labels SHALL split the number from the unit, rendering the unit (SEC/MIN) at a smaller font size (8pt vs 11pt)

When the window width is 400pt or greater, all button labels SHALL be fully visible.

#### Scenario: Window narrowed below 400pt

- **WHEN** the window width decreases below 400pt
- **THEN** all button text labels are hidden, only SF Symbol icons remain visible
- **THEN** the mode toggle shows a timer icon for countdown and a stopwatch icon for count up

#### Scenario: Window widened to 400pt or more

- **WHEN** the window width increases to 400pt or more
- **THEN** all button text labels are restored alongside their icons

---

### Requirement: Minimum window dimensions

The window SHALL allow resizing down to a minimum of 200pt wide and 100pt tall.
The default window size on launch SHALL be 623pt wide and 377pt tall.

#### Scenario: Window at minimum size

- **WHEN** the user resizes the window to its minimum dimensions
- **THEN** the window SHALL NOT shrink below 200pt × 100pt
- **THEN** the timer display SHALL still be visible at a reduced scale

#### Scenario: App launch

- **WHEN** the app launches
- **THEN** the window SHALL open at 623pt × 377pt

---

### Requirement: Preset bar uses stable layout during timer run

The preset bar SHALL always occupy layout space within the scaled container regardless of timer state.
When the preset bar is not applicable (timer running or count-up mode), it SHALL be hidden using `opacity(0)` instead of conditional removal.

#### Scenario: Timer starts in countdown mode

- **WHEN** the user presses START in countdown mode
- **THEN** the preset bar becomes invisible but retains its layout space
- **THEN** the timer display SHALL NOT shift position

#### Scenario: Timer resets in countdown mode

- **WHEN** the user presses RESET in countdown mode
- **THEN** the preset bar becomes visible again at the same position

---

### Requirement: Timer display is vertically and horizontally centered

The scaled timer display SHALL be centered within the GeometryReader area using `.position(x: width/2, y: height/2)`.

#### Scenario: Any window size

- **WHEN** the window is displayed at any size
- **THEN** the timer display SHALL appear centered both vertically and horizontally within the available space

---

### Requirement: App activates on launch

The app SHALL call `NSApp.activate(ignoringOtherApps: true)` during `applicationDidFinishLaunching` to bring the window to the foreground automatically.

#### Scenario: App launched from terminal

- **WHEN** the app is launched via `swift run` or other means
- **THEN** the app window SHALL appear in the foreground without requiring manual activation
