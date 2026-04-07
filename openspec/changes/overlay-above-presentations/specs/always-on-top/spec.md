## ADDED Requirements

### Requirement: Pin button sets window level above fullscreen applications

When the user enables the always-on-top pin, the window level SHALL be set to `.screenSaver` (NSWindow.Level, raw value 1000). When the user disables the pin, the window level SHALL be restored to `.normal`.

#### Scenario: Pin enabled overlays fullscreen presentation

- **WHEN** the user clicks the pin button to enable always-on-top
- **THEN** the window level SHALL be set to `.screenSaver` so it appears above fullscreen applications such as PowerPoint or Keynote slideshow mode

#### Scenario: Pin disabled restores normal window level

- **WHEN** the user clicks the pin button to disable always-on-top
- **THEN** the window level SHALL be restored to `.normal`

### Requirement: Pin button configures collection behavior for cross-space and fullscreen overlay

When the user enables the always-on-top pin, the window's `collectionBehavior` SHALL be set to include `.canJoinAllSpaces`, `.fullScreenAuxiliary`, and `.stationary`. When the user disables the pin, the `collectionBehavior` SHALL be reset to the default (empty).

#### Scenario: Pin enabled allows window on all spaces and above fullscreen

- **WHEN** the user enables the pin
- **THEN** the window SHALL appear on all macOS desktop spaces and SHALL be visible above fullscreen applications

#### Scenario: Pin disabled restores default collection behavior

- **WHEN** the user disables the pin
- **THEN** the window's collection behavior SHALL be reset to default, restricting it to the current space and normal layering

### Requirement: Pin targets the main application window

The pin toggle SHALL apply window level and collection behavior changes to the main application window (the window where `canBecomeMain` is true). The menu bar popover SHALL NOT be affected by pin state.

#### Scenario: Menu bar popover unaffected by pin

- **WHEN** the pin is enabled and the user opens the menu bar popover
- **THEN** the menu bar popover SHALL behave normally and SHALL NOT have elevated window level
