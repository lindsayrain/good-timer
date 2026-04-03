## ADDED Requirements

### Requirement: package.sh produces a versioned DMG in one command

The `package.sh` script SHALL: (1) build the release binary via `swift build -c release`, (2) generate the app icon if `AppIcon.icns` does not exist, (3) assemble the `.app` bundle, (4) read the version from `Info.plist`'s `CFBundleShortVersionString` using `/usr/libexec/PlistBuddy`, and (5) produce `GoodTimer-<version>.dmg` in the project root directory using `hdiutil`.

#### Scenario: Fresh DMG creation

- **WHEN** the user runs `./package.sh`
- **THEN** the script SHALL complete without error
- **THEN** a file named `GoodTimer-<version>.dmg` SHALL exist in the project root
- **THEN** the version in the DMG filename SHALL match `CFBundleShortVersionString` in `Info.plist`

#### Scenario: DMG overwrites previous build

- **WHEN** the user runs `./package.sh` and a DMG with the same version already exists
- **THEN** the old DMG SHALL be removed before the new one is created


<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->

### Requirement: DMG contains app and Applications symlink

The DMG SHALL contain `GoodTimer.app` and a symlink named `Applications` pointing to `/Applications`, enabling the standard drag-to-install experience.

#### Scenario: User installs from DMG

- **WHEN** the user opens the DMG
- **THEN** both `GoodTimer.app` and an `Applications` folder shortcut SHALL be visible
- **WHEN** the user drags `GoodTimer.app` onto the `Applications` shortcut
- **THEN** the app SHALL be copied to `/Applications` and be launchable


<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->

### Requirement: Version is managed from a single source

The version number SHALL be defined only in `Info.plist`'s `CFBundleShortVersionString`. The `package.sh` script SHALL read the version from `Info.plist` at build time rather than hardcoding it in the script.

#### Scenario: Version bump propagates to DMG filename

- **WHEN** `CFBundleShortVersionString` in `Info.plist` is changed to a new value (e.g., `1.1.0`)
- **THEN** running `./package.sh` SHALL produce `GoodTimer-1.1.0.dmg`
- **THEN** no other file besides `Info.plist` SHALL need to be edited to update the version

## Requirements


<!-- @trace
source: create-app-bundle
updated: 2026-04-03
code:
  - Info.plist
  - generate-icon.swift
  - package.sh
  - README.md
-->

### Requirement: package.sh produces a versioned DMG in one command

The `package.sh` script SHALL: (1) build the release binary via `swift build -c release`, (2) generate the app icon if `AppIcon.icns` does not exist, (3) assemble the `.app` bundle, (4) read the version from `Info.plist`'s `CFBundleShortVersionString` using `/usr/libexec/PlistBuddy`, and (5) produce `GoodTimer-<version>.dmg` in the project root directory using `hdiutil`.

#### Scenario: Fresh DMG creation

- **WHEN** the user runs `./package.sh`
- **THEN** the script SHALL complete without error
- **THEN** a file named `GoodTimer-<version>.dmg` SHALL exist in the project root
- **THEN** the version in the DMG filename SHALL match `CFBundleShortVersionString` in `Info.plist`

#### Scenario: DMG overwrites previous build

- **WHEN** the user runs `./package.sh` and a DMG with the same version already exists
- **THEN** the old DMG SHALL be removed before the new one is created

---
### Requirement: DMG contains app and Applications symlink

The DMG SHALL contain `GoodTimer.app` and a symlink named `Applications` pointing to `/Applications`, enabling the standard drag-to-install experience.

#### Scenario: User installs from DMG

- **WHEN** the user opens the DMG
- **THEN** both `GoodTimer.app` and an `Applications` folder shortcut SHALL be visible
- **WHEN** the user drags `GoodTimer.app` onto the `Applications` shortcut
- **THEN** the app SHALL be copied to `/Applications` and be launchable

---
### Requirement: Version is managed from a single source

The version number SHALL be defined only in `Info.plist`'s `CFBundleShortVersionString`. The `package.sh` script SHALL read the version from `Info.plist` at build time rather than hardcoding it in the script.

#### Scenario: Version bump propagates to DMG filename

- **WHEN** `CFBundleShortVersionString` in `Info.plist` is changed to a new value (e.g., `1.1.0`)
- **THEN** running `./package.sh` SHALL produce `GoodTimer-1.1.0.dmg`
- **THEN** no other file besides `Info.plist` SHALL need to be edited to update the version