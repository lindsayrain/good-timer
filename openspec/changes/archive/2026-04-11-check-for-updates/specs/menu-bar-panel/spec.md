## ADDED Requirements

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
