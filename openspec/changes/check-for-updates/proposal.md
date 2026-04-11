## Why

使用者目前無法得知是否有新版本的 Good Timer 可以下載。因為 app 透過 DMG 手動安裝，沒有 App Store 的自動更新機制，使用者只能自己去 GitHub 看——多數人不會這麼做。加入版本檢查功能讓使用者在日常使用中就能發現新版本。

## What Changes

- 新增 `UpdateChecker`：啟動時呼叫 GitHub Releases API（`GET https://api.github.com/repos/lindsayrain/good-timer/releases/latest`），比對 `tag_name` 與 `CFBundleShortVersionString` 的 semver 版號
- 自動檢查節流：用 `UserDefaults` 記錄上次檢查時間，每 24 小時最多自動查一次
- MenuBarView 底部新增提示：有新版時顯示「v1.x.x available — Download」藍色文字連結，點擊用 `NSWorkspace.shared.open()` 開啟 GitHub release 頁面
- MenuBarView 底部新增「Check for Updates」手動按鈕，隨時可觸發檢查

## Non-Goals

- 不做自動下載 DMG 或自動安裝（方案 B/C）
- 不整合 Sparkle 框架
- 不需要 code signing 或 notarization
- 不在主視窗（ContentView）顯示更新提示

## Capabilities

### New Capabilities

- `version-check`: 透過 GitHub Releases API 檢查新版本並在 menu bar panel 中提示使用者

### Modified Capabilities

- `menu-bar-panel`: 新增更新提示列和手動檢查按鈕

## Impact

- Affected specs: `version-check`（新增）、`menu-bar-panel`（修改）
- Affected code:
  - 新增 `Sources/GoodTimer/UpdateChecker.swift`（API 呼叫、版號比對、節流邏輯）
  - 修改 `Sources/GoodTimer/MenuBarView.swift`（新增提示 UI 和手動按鈕）
  - 修改 `Sources/GoodTimer/GoodTimerApp.swift`（啟動時觸發檢查）
