## Context

Good Timer 目前是 Swift Package Manager 的 `executableTarget`，build 產物為純 Unix binary。要製作可分發的 DMG 安裝檔，需要先組裝符合規範的 `.app` bundle，再用 `hdiutil` 封裝為 DMG。個人使用，不需要 code signing 或 Notarization。

## Goals / Non-Goals

**Goals:**
- 產生帶版本號的 `GoodTimer-<version>.dmg`，使用者拖曳即可安裝
- 設計翻牌風格 app icon 並輸出為 `.icns`
- 一鍵腳本完成 build → 組裝 bundle → 產出 DMG 全流程

**Non-Goals:**
- Apple Developer ID 簽名或 Notarization
- 建立 Xcode project
- 自動上傳或推送 DMG

## Decisions

### Icon 以 Swift CoreGraphics 腳本程式化產生

使用獨立的 `generate-icon.swift` 腳本，透過 CoreGraphics 繪製翻牌卡片圖形，輸出 10 種尺寸的 PNG，再由 `iconutil` 合成 `.icns`。

**為何不用設計工具（Sketch/Figma）匯出**：避免對外部設計工具產生依賴，腳本可重複執行、納入版本控制，修改設計只需改腳本。

**Icon 視覺規格：**
- 深色圓角卡片（`#1A1A1F`），佔畫布約 75%
- 水平細縫（4pt）將卡片分為上下兩半
- 上下各顯示「0」，使用白色粗體系統字型（SF Pro / .default）
- 整體比例模擬 FlipCard 元件

### .app bundle 手動組裝，不依賴 Xcode

`package.sh` 直接建立 `.app` bundle 目錄結構，複製 binary 與資源：

```
GoodTimer.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   └── GoodTimer        ← release binary
│   └── Resources/
│       └── AppIcon.icns
```

**為何不用 xcodebuild**：整個專案無 `.xcodeproj`，引入 Xcode project 會改變現有開發流程，成本過高。

### DMG 以 hdiutil 製作，版本號從 Info.plist 讀取

用 `hdiutil create` 將 `.app` bundle 封裝為 DMG。DMG 內放 `.app` 與一個指向 `/Applications` 的 symlink，實現經典「拖曳安裝」體驗。

```
GoodTimer-1.0.0.dmg
└── GoodTimer.app
└── Applications → /Applications  (symlink)
```

版本號由 `Info.plist` 的 `CFBundleShortVersionString` 決定，`package.sh` 用 `/usr/libexec/PlistBuddy` 讀取後帶入 DMG 檔名，確保版本號單一來源。

**為何不用 create-dmg 工具**：`hdiutil` 是 macOS 內建工具，無外部依賴；`create-dmg` 雖能產生更精美的背景，但需要 Homebrew 安裝，增加環境依賴。

### 不做 ad-hoc code signing

個人自用，從 DMG 安裝後在本機啟動，macOS Gatekeeper 不會攔截（quarantine 屬性只在從網路下載時附加，本機 build 的 DMG 無此屬性）。無需 `codesign`。

## Risks / Trade-offs

- **CoreGraphics 字型渲染差異** → 腳本使用 `.systemFont` fallback，確保跨 macOS 版本相容
- **hdiutil 產生 DMG 格式** → 使用 `UDZO`（壓縮）格式，檔案較小；若需要可讀寫 DMG 改用 `UDRW`
- **每次執行 package.sh 會覆蓋舊 DMG** → 舊版 DMG 如需保留，應在執行前手動備份
