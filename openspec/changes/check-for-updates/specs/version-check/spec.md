## ADDED Requirements

### Requirement: App checks for new versions via GitHub Releases API

The system SHALL check for new versions by sending a GET request to `https://api.github.com/repos/lindsayrain/good-timer/releases/latest`. The system SHALL compare the `tag_name` field (stripping the leading `v` prefix) from the API response against the app's `CFBundleShortVersionString` using semantic versioning comparison. If the remote version is greater than the local version, the system SHALL mark that a new version is available.

#### Scenario: New version available

- **WHEN** the local version is `1.3.0` and the API returns `tag_name: "v1.4.0"`
- **THEN** the system SHALL report that version `1.4.0` is available
- **THEN** the system SHALL store the release page URL (`html_url`) for user navigation

#### Scenario: App is up to date

- **WHEN** the local version is `1.3.0` and the API returns `tag_name: "v1.3.0"`
- **THEN** the system SHALL report that no update is available

#### Scenario: Local version is ahead of release

- **WHEN** the local version is `1.4.0` and the API returns `tag_name: "v1.3.0"`
- **THEN** the system SHALL report that no update is available

#### Scenario: Network error during check

- **WHEN** the API request fails due to network error or non-200 response
- **THEN** the system SHALL silently fail without displaying any error to the user

### Requirement: Automatic check is throttled to once per 24 hours

The system SHALL store the timestamp of the last successful version check in `UserDefaults`. On app launch, the system SHALL perform an automatic version check only if 24 hours or more have elapsed since the last check. If less than 24 hours have elapsed, the system SHALL skip the automatic check.

#### Scenario: First launch (no previous check)

- **WHEN** the app launches and no previous check timestamp exists in `UserDefaults`
- **THEN** the system SHALL perform a version check

#### Scenario: Launch within 24 hours of last check

- **WHEN** the app launches and the last check was 6 hours ago
- **THEN** the system SHALL NOT perform an automatic version check

#### Scenario: Launch after 24 hours since last check

- **WHEN** the app launches and the last check was 25 hours ago
- **THEN** the system SHALL perform an automatic version check

### Requirement: Manual check bypasses throttle

When the user triggers a manual version check, the system SHALL perform the check immediately regardless of the last check timestamp. The system SHALL update the last check timestamp after a manual check.

#### Scenario: Manual check within throttle window

- **WHEN** the user triggers a manual check and the last automatic check was 1 hour ago
- **THEN** the system SHALL perform the version check immediately
- **THEN** the system SHALL update the last check timestamp
