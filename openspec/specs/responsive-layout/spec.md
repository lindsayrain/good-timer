# responsive-layout Specification

## Purpose

TBD - created by archiving change 'responsive-timer-layout'. Update Purpose after archive.

## Requirements

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


<!-- @trace
source: responsive-timer-layout
updated: 2026-04-03
code:
  - icon.png
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
  - generate-icon.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
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


<!-- @trace
source: rename-mode-labels
updated: 2026-04-11
code:
  - Tests/GoodTimerTests/UpdateCheckerTests.swift
  - Package.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/UpdateChecker.swift
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/ContentView.swift
-->

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


<!-- @trace
source: responsive-timer-layout
updated: 2026-04-03
code:
  - icon.png
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
  - generate-icon.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

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


<!-- @trace
source: responsive-timer-layout
updated: 2026-04-03
code:
  - icon.png
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
  - generate-icon.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Timer display is vertically and horizontally centered

The scaled timer display SHALL be centered within the GeometryReader area using `.position(x: width/2, y: height/2)`.

#### Scenario: Any window size

- **WHEN** the window is displayed at any size
- **THEN** the timer display SHALL appear centered both vertically and horizontally within the available space


<!-- @trace
source: responsive-timer-layout
updated: 2026-04-03
code:
  - icon.png
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
  - generate-icon.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: App activates on launch

The app SHALL call `NSApp.activate(ignoringOtherApps: true)` during `applicationDidFinishLaunching` to bring the window to the foreground automatically.

#### Scenario: App launched from terminal

- **WHEN** the app is launched via `swift run` or other means
- **THEN** the app window SHALL appear in the foreground without requiring manual activation

<!-- @trace
source: responsive-timer-layout
updated: 2026-04-03
code:
  - icon.png
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
  - Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf
  - generate-icon.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Flip clock cards are the primary content and occupy at least 60% of window height

The flip clock cards SHALL be treated as the primary content of the window. The layout SHALL compute a card height budget as `max(windowHeight − reservedChromeHeight, windowHeight × 0.6)`, where `reservedChromeHeight` is the sum of fixed heights reserved for the top bar (or mini pin reserve), progress bar, preset bar (when visible), and control bar. The card scale SHALL then be `min(widthLimitedScale, heightBudgetScale)` so the cards never overflow the window width.

When the window width and the card aspect ratio permit, the cards SHALL occupy at least 60% of the window height. When the aspect ratio prevents this (i.e. the width-limited scale cannot reach the 60% height budget), the cards SHALL use the largest width-limited scale instead, and the 60% target SHALL NOT be enforced at the cost of horizontal clipping.

The flip clock SHALL be rendered at its exact computed scaled dimensions using a fixed-size container (no greedy `GeometryReader` in the main layout). The VStack SHALL receive the cards' true scaled size so there is no hidden padding above or below the top or bottom card edges.

The unit labels row (HR / MIN / SEC) SHALL NOT be rendered in any mode, so its vertical space can be reclaimed by the flip cards.

#### Scenario: Window with room for 60% card height

- **WHEN** the window width and aspect ratio allow the cards to reach at least 60% of window height
- **THEN** the cards are scaled to occupy at least 60% of the window height
- **AND** the cards never overflow the window width

#### Scenario: Wide or short window where 60% is unreachable

- **WHEN** the window width is insufficient for the cards to reach 60% of the window height without overflowing horizontally
- **THEN** the cards fall back to the width-limited scale
- **AND** the cards occupy less than 60% of window height without being clipped horizontally

#### Scenario: Progress bar is flush with the top card edge

- **WHEN** the progress bar is visible above the cards
- **THEN** the vertical gap between the progress bar and the top edge of the flip cards is 1pt
- **AND** no additional padding is inserted between the progress bar and the cards

#### Scenario: Unit labels row is hidden in all modes

- **WHEN** the flip clock is rendered
- **THEN** the HR / MIN / SEC unit labels row is not shown
- **AND** the vertical space it would have occupied is given to the flip cards

<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->


<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Mini mode provides maximum digit space below 400pt width

When the window width is less than 400pt, the UI SHALL enter mini mode in addition to compact mode. In mini mode:

- The top bar SHALL NOT be rendered. The main VStack SHALL reserve a 22pt tall blank area at the top so that the pin button overlay has room above the progress bar.
- The always-on-top (pin) toggle SHALL be rendered as a floating overlay anchored to the top-right corner of the window (using `frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)`), visually aligned with the macOS traffic light button row.
- The control bar SHALL hide the "SET TIME" button and the "RESET" button, keeping only the start/pause/restart button.
- The play/pause button SHALL use a reduced-size style (smaller icon, padding, and corner radius) via the `mini` parameter on the shared control button component.
- The preset bar SHALL be hidden and SHALL NOT reserve layout space.
- The separator width between digit pairs SHALL be reduced (to 4pt) so the digits can scale up further to fill the narrow window.
- The progress bar SHALL be rendered at reduced height (0.75pt) with no horizontal padding so it spans the full window width and does not dominate the layout visually.

When the window width is 400pt or greater, mini mode SHALL NOT apply and the UI SHALL show the full-size layout with the top bar inline (including the pin toggle in the top bar), the full control bar, and the preset bar when applicable.

#### Scenario: Window narrowed below 400pt

- **WHEN** the window width decreases below 400pt
- **THEN** the top bar is not rendered
- **AND** a 22pt blank area is reserved at the top of the VStack
- **AND** the pin toggle is rendered as a floating overlay in the top-right corner
- **AND** the control bar shows only the start/pause/restart button
- **AND** the preset bar is hidden and does not reserve layout space
- **AND** the flip clock digits occupy the maximum available vertical space

#### Scenario: Window widened to 400pt or more

- **WHEN** the window width increases to 400pt or more
- **THEN** the top bar is restored inline at the top of the VStack
- **AND** the pin toggle returns to the top bar (the floating overlay is removed)
- **AND** the control bar restores the SET TIME and RESET buttons
- **AND** the preset bar is restored when applicable (countdown mode, timer not running)

#### Scenario: Pin toggle remains accessible in mini mode

- **WHEN** the window is in mini mode
- **THEN** the always-on-top (pin) toggle is visible as a floating overlay in the top-right corner
- **THEN** pressing the pin toggle continues to toggle the window level as in non-mini mode

<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->


<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: App title is centered on the traffic light row in both modes

The window SHALL enable `.fullSizeContentView` on `NSWindow` (with `titlebarAppearsTransparent = true` and `titleVisibility = .hidden`) so that the SwiftUI content view extends to the top edge of the window, beneath the standard traffic light buttons. The window SHALL also set `isMovableByWindowBackground = true` so the title strip remains draggable.

A single "GOOD TIMER" text label SHALL be rendered as an overlay on the main `ZStack`, horizontally centered via `frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)`, vertically anchored to the top with `padding(.top, 8)`, and SHALL apply `ignoresSafeArea(.all, edges: .top)` so the label sits precisely on the traffic light row regardless of macOS safe area insets.

The label SHALL be rendered in both mini and non-mini modes. The label SHALL use `font(.system(size: 13, weight: .semibold, design: .monospaced))`, `tracking(4)`, `foregroundColor(theme.dim)`, and SHALL apply `allowsHitTesting(false)` so it does not intercept clicks intended for views beneath it. The previous "GOOD TIMER" label inside the top bar's leading `HStack` SHALL be removed to avoid duplication.

#### Scenario: Content view extends under the traffic lights

- **WHEN** the app finishes launching
- **THEN** every `NSApp.windows` entry has `.fullSizeContentView` inserted into its `styleMask`
- **AND** `titlebarAppearsTransparent` is `true` and `titleVisibility` is `.hidden`
- **AND** the SwiftUI content view's origin (y = 0) is at the top edge of the window

#### Scenario: Title label is aligned with the traffic light row

- **WHEN** the main window is shown
- **THEN** the "GOOD TIMER" text label is horizontally centered in the window
- **AND** the label is vertically aligned with the traffic light buttons (approximately 8pt from the top edge of the content view)
- **AND** the label is visible in both mini (< 400pt) and non-mini (≥ 400pt) modes
- **AND** the label does not intercept pointer events

#### Scenario: Window height changes do not displace the title

- **WHEN** the window height is increased or decreased
- **THEN** the "GOOD TIMER" label remains anchored at the top of the content view and does not drift vertically
- **AND** the label stays horizontally centered

#### Scenario: Title bar strip remains draggable

- **WHEN** the user presses on the background of the title bar strip and drags
- **THEN** the window moves with the pointer because `isMovableByWindowBackground` is `true`

<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->


<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

---
### Requirement: Flip clock digits are rendered at native point size

The flip clock view hierarchy (`FlipClockDisplay`, `FlipCard`, `HalfCard`, `ClockSeparator`) SHALL accept a `scale: CGFloat` parameter and multiply the shared `ClockLayout` constants (`cardW`, `halfH`, `fontSize`, `corner`, `digitGap`, `pairW`, separator dot size, separator vertical offset, flip card inter-half gap, separator width) by that `scale` inside each view's body, so that text and shapes are drawn at their final point size in a single rendering pass.

The main layout in `ContentView` SHALL render the flip clock as `FlipClockDisplay(..., scale: metrics.scale).frame(width: metrics.width, height: metrics.height)` and SHALL NOT apply `.scaleEffect` to the flip clock view. This avoids bitmap up-scaling blur at wide window widths (> 600pt), because the font is rasterized at the correct size directly rather than being sampled from a smaller pre-rendered raster.

#### Scenario: Flip clock text is crisp at wide window widths

- **WHEN** the window is wider than 600pt and the flip clock `scale` is greater than 1
- **THEN** the digit glyphs are rendered at their final point size without bitmap sampling artifacts
- **AND** `.scaleEffect` is not applied to `FlipClockDisplay`

#### Scenario: Flip clock still scales down in mini mode

- **WHEN** the window is in mini mode (< 400pt) and `cardMetrics()` produces a `scale` less than 1
- **THEN** `FlipClockDisplay` receives the reduced `scale` and renders at the smaller point size
- **AND** the final on-screen size matches `metrics.width` × `metrics.height`

<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/FlipClockView.swift
-->

<!-- @trace
source: adaptive-mini-layout
updated: 2026-04-10
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/FlipClockView.swift
-->