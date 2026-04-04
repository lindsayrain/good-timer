## ADDED Requirements

### Requirement: Opacity toggle button in top bar

The top bar SHALL display an opacity toggle button to the right of the theme toggle button. The button SHALL display the current opacity level as text: "100%", "75%", "50%", or "25%". When opacity is not 100%, the button text and border SHALL use the accent blue color to indicate an active state.

#### Scenario: Button shows current opacity

- **WHEN** the window opacity is at 75%
- **THEN** the button SHALL display "75%" with blue text and blue border

#### Scenario: Button at default opacity

- **WHEN** the window opacity is at 100% (default)
- **THEN** the button SHALL display "100%" with dim text matching other inactive controls

### Requirement: Opacity cycles through four levels

Clicking the opacity button SHALL cycle through four opacity levels in order: 100% → 75% → 50% → 25% → 100%. The window's `alphaValue` SHALL be set to the corresponding value (1.0, 0.75, 0.5, 0.25).

#### Scenario: Cycle from 100% to 75%

- **WHEN** the current opacity is 100% and the user clicks the opacity button
- **THEN** the window opacity SHALL change to 75% and the button SHALL display "75%"

#### Scenario: Cycle from 25% back to 100%

- **WHEN** the current opacity is 25% and the user clicks the opacity button
- **THEN** the window opacity SHALL change to 100% and the button SHALL display "100%"

### Requirement: Opacity applies to main window only

The opacity setting SHALL apply to the main application window via `NSWindow.alphaValue`. The menu bar popover SHALL NOT be affected by the opacity setting.

#### Scenario: Menu bar popover unaffected

- **WHEN** the main window opacity is set to 50%
- **THEN** the menu bar popover SHALL remain at full opacity when opened
