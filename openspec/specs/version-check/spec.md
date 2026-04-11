# version-check Specification

## Purpose

TBD - created by archiving change 'check-for-updates'. Update Purpose after archive.

## Requirements

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
### Requirement: Version reading falls back to Info.plist file

The system SHALL first attempt to read the app version from `Bundle.main.infoDictionary["CFBundleShortVersionString"]`. If this returns nil (e.g., when running as an SPM debug binary without a .app bundle), the system SHALL walk up the directory tree from the executable location and attempt to read `Info.plist` from each parent directory, extracting `CFBundleShortVersionString` via `PropertyListSerialization`. If no version is found after 5 levels, the system SHALL fall back to `"0.0.0"`.

#### Scenario: Running as .app bundle

- **WHEN** the app runs as a properly assembled .app bundle
- **THEN** the system SHALL read the version from `Bundle.main.infoDictionary`

#### Scenario: Running as SPM debug binary

- **WHEN** the app runs from `.build/debug/GoodTimer` without a .app bundle
- **THEN** the system SHALL find and read `Info.plist` from the project root directory

#### Scenario: No Info.plist found anywhere

- **WHEN** neither `Bundle.main` nor any parent directory contains a readable `Info.plist`
- **THEN** the system SHALL use `"0.0.0"` as the local version


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
### Requirement: Manual check bypasses throttle

When the user triggers a manual version check, the system SHALL perform the check immediately regardless of the last check timestamp. The system SHALL update the last check timestamp after a manual check.

#### Scenario: Manual check within throttle window

- **WHEN** the user triggers a manual check and the last automatic check was 1 hour ago
- **THEN** the system SHALL perform the version check immediately
- **THEN** the system SHALL update the last check timestamp

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