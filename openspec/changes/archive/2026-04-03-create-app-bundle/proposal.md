## Why

目前 Good Timer 只能透過 `swift run` 或直接執行 binary 來啟動，無法以標準安裝方式分發。需要將其打包為帶版本號的 DMG 安裝檔，讓使用者能以熟悉的「拖曳至 Applications」方式安裝。

## What Changes

- 新增 `AppIcon.iconset/` — 使用 CoreGraphics 腳本程式化產生翻牌風格 icon（深色圓角卡片、中央縫隙、白色粗體「0」數字）並輸出為 `.icns`
- 新增 `Info.plist` — 定義 bundle ID、版本號、最低系統需求、icon 等 app 元數據
- 新增 `package.sh` — 一鍵腳本：build release binary → 組裝 `.app` bundle → 製作帶版本號的 DMG（`GoodTimer-<version>.dmg`）
- 版本號統一由 `Info.plist` 的 `CFBundleShortVersionString` 管理，DMG 檔名自動帶入
- 建立 GitHub Release v1.0.0，附上 DMG 供下載
- 更新 `README.md`，加入下載連結與安裝說明

## Non-Goals

- 不進行 Apple Developer ID 簽名或 Notarization
- 不上架 Mac App Store
- 不建立 Xcode project

## Capabilities

### New Capabilities

- `app-bundle`: 將 GoodTimer 打包為標準 macOS `.app` bundle，含翻牌風格 icon 與完整元數據
- `dmg-installer`: 將 `.app` bundle 封裝為帶版本號的 DMG 安裝檔

### Modified Capabilities

(none)

## Impact

- 新增檔案：`Info.plist`、`package.sh`、`generate-icon.swift`、`AppIcon.iconset/`
- 修改檔案：`README.md`（新增下載連結）、`.gitignore`（排除 DMG 與 icon 產出物）
- 產出物（不納入版控）：`GoodTimer-<version>.dmg`
- GitHub Release：https://github.com/lindsayrain/good-timer/releases/tag/v1.0.0
- 不修改任何現有 Swift 原始碼
