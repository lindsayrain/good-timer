# menu-bar-panel Specification

## Purpose

TBD - created by archiving change 'menu-bar-and-sound'. Update Purpose after archive.

## Requirements

### Requirement: Menu bar item displays timer status

The app SHALL show a `MenuBarExtra` item in the macOS menu bar. When the timer is idle or paused, the item SHALL display a timer SF Symbol icon (`timer`). When the timer is running, the item SHALL display the remaining time as text in `MM:SS` format (e.g., `04:23`). When the remaining time is 1 hour or more, the format SHALL be `H:MM:SS`.

#### Scenario: Timer is idle

- **WHEN** the timer is in idle state
- **THEN** the menu bar item SHALL display the SF Symbol `timer` icon

#### Scenario: Timer is running under one hour

- **WHEN** the timer is running with 4 minutes and 23 seconds remaining
- **THEN** the menu bar item SHALL display `04:23`

#### Scenario: Timer is running over one hour

- **WHEN** the timer is running with 1 hour, 5 minutes, and 10 seconds remaining
- **THEN** the menu bar item SHALL display `1:05:10`

#### Scenario: Timer is paused

- **WHEN** the timer is paused
- **THEN** the menu bar item SHALL display the SF Symbol `timer` icon


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover shows timer display

When the menu bar item is clicked, a popover window SHALL appear using `MenuBarExtra` with `.window` style. The popover SHALL display the current timer value in a simple numeric format (not flip-card animation). The popover SHALL display unit labels (HOURS, MINUTES, SECONDS or MINUTES, SECONDS) below the time digits.

#### Scenario: Popover opened while running

- **WHEN** the user clicks the menu bar item while the timer is running
- **THEN** a popover SHALL appear showing the current remaining time in large numeric text
- **THEN** the time SHALL update every second

#### Scenario: Popover opened while idle

- **WHEN** the user clicks the menu bar item while the timer is idle
- **THEN** a popover SHALL appear showing the current countdown target time


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover shows progress bar in countdown mode

When the timer is in countdown mode, the popover SHALL display a progress bar showing elapsed progress. The progress bar SHALL use the same color logic as the main window (blue/green gradient normally, yellow at ≤20% remaining, red at ≤10% remaining).

#### Scenario: Progress bar during countdown

- **WHEN** the popover is open during a countdown with 50% elapsed
- **THEN** the progress bar SHALL be filled to 50%
- **THEN** the progress bar color SHALL be a blue-to-green gradient

#### Scenario: Progress bar at warning level

- **WHEN** the popover is open during a countdown with ≤10% remaining
- **THEN** the progress bar color SHALL be red


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover provides start, pause, and reset controls

The popover SHALL include control buttons: Start (or Restart when finished), Pause (when running), and Reset. These controls SHALL operate on the same `TimerViewModel` instance as the main window.

#### Scenario: Start timer from popover

- **WHEN** the user clicks Start in the popover while timer is idle
- **THEN** the timer SHALL start counting
- **THEN** the main window (if open) SHALL reflect the running state

#### Scenario: Pause timer from popover

- **WHEN** the user clicks Pause in the popover while timer is running
- **THEN** the timer SHALL pause
- **THEN** the main window (if open) SHALL reflect the paused state

#### Scenario: Reset timer from popover

- **WHEN** the user clicks Reset in the popover
- **THEN** the timer SHALL reset to idle state


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover shows quick presets in countdown idle state

When the timer is in countdown mode and not running, the popover SHALL display quick preset buttons (5m, 10m, 15m, 25m). When the timer is running, the presets SHALL be hidden.

#### Scenario: Presets visible when idle

- **WHEN** the popover is open and timer is in countdown mode and idle
- **THEN** quick preset buttons SHALL be visible

#### Scenario: Presets hidden when running

- **WHEN** the popover is open and timer is running
- **THEN** quick preset buttons SHALL NOT be visible


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover provides link to open main window

The popover SHALL include a button to open or bring the main window to the foreground. Clicking this button SHALL activate the app and show the main window.

#### Scenario: Open main window from popover

- **WHEN** the user clicks the "Open Main Window" button in the popover
- **THEN** the main application window SHALL appear and become the active window


<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: TimerViewModel is shared between main window and menu bar

The `TimerViewModel` SHALL be instantiated at the `App` level as a `@StateObject` and injected into both the `WindowGroup` and `MenuBarExtra` scenes via `.environmentObject()`. All timer operations from either UI SHALL operate on the same instance.

#### Scenario: Timer started from main window visible in menu bar

- **WHEN** the user starts a timer from the main window
- **THEN** the menu bar item SHALL immediately reflect the running state and remaining time

#### Scenario: Timer paused from menu bar reflected in main window

- **WHEN** the user pauses the timer from the menu bar popover
- **THEN** the main window SHALL immediately show the paused state

<!-- @trace
source: menu-bar-and-sound
updated: 2026-04-04
code:
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/TimerViewModel.swift
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
-->

---
### Requirement: Menu bar popover displays update availability notification

When a new version is available, the menu bar popover SHALL display a notification row above the "Open Main Window" button. The notification SHALL show the text "v{version} available" followed by a "Download" link, both in the accent blue color. Clicking the notification SHALL open the GitHub release page URL in the default browser using `NSWorkspace.shared.open()`. When no update is available, the notification row SHALL NOT be displayed.

#### Scenario: New version available

- **WHEN** the popover is open and a new version `1.4.0` is available
- **THEN** the popover SHALL display "v1.4.0 available — Download" in accent blue color above the "Open Main Window" button

#### Scenario: User clicks update notification

- **WHEN** the user clicks the update notification row
- **THEN** the system SHALL open the GitHub release page URL in the default browser

#### Scenario: No update available

- **WHEN** the popover is open and the app is up to date
- **THEN** the update notification row SHALL NOT be displayed


<!-- @trace
source: check-for-updates
updated: 2026-04-11
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/UpdateChecker.swift
  - Tests/GoodTimerTests/UpdateCheckerTests.swift
  - Package.swift
-->

---
### Requirement: Menu bar popover provides manual Check for Updates button

The menu bar popover SHALL include a "Check for Updates" button above the "Open Main Window" button. Clicking this button SHALL trigger an immediate version check. While the check is in progress, the button SHALL be disabled. After the check completes, if a new version is found, the update notification row SHALL appear. If no new version is found, the button text SHALL briefly show "Up to date" before reverting.

#### Scenario: Manual check finds new version

- **WHEN** the user clicks "Check for Updates" and a new version is available
- **THEN** the update notification row SHALL appear showing the new version

#### Scenario: Manual check finds no update

- **WHEN** the user clicks "Check for Updates" and the app is up to date
- **THEN** the button SHALL briefly display "Up to date"

#### Scenario: Check in progress

- **WHEN** a version check is in progress
- **THEN** the "Check for Updates" button SHALL be disabled

<!-- @trace
source: check-for-updates
updated: 2026-04-11
code:
  - Sources/GoodTimer/ContentView.swift
  - Sources/GoodTimer/MenuBarView.swift
  - Sources/GoodTimer/GoodTimerApp.swift
  - Sources/GoodTimer/UpdateChecker.swift
  - Tests/GoodTimerTests/UpdateCheckerTests.swift
  - Package.swift
-->