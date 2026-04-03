## Summary

將翻牌時鐘的字型改為 Chakra Petch Bold（台灣鐵路局機械翻牌風格），同步更新深色主題配色為純黑卡片，並重新產生採用新字型的 App Icon（顯示數字「9」）。

## Motivation

現有字型（SF Pro Black）過於現代圓潤，與機械翻牌板的工業感不符。Chakra Petch Bold 具備切角八邊形字形，視覺上更接近台鐵車站翻牌顯示器的數字風格。App Icon 也應同步使用新字型以維持一致性。

## Proposed Solution

- 打包 `ChakraPetch-Bold.ttf` 至 `Sources/GoodTimer/Resources/`，在 `Package.swift` 宣告為資源
- `FlipClockView.swift` 的數字字型改為 `Font.custom("ChakraPetch-Bold", size:)`
- `ClockLayout.corner` 從 10 降至 3，強化機械感
- `AppTheme.dark` 卡片色改為純黑（`#0D0D0D`），加大視覺對比
- `generate-icon.swift` 改用 Chakra Petch Bold 繪製數字「9」，修正座標系（移除 Y 軸翻轉，改用標準底部原點）
- 重新產生 `AppIcon.icns` 並更新 DMG
- 翻牌動畫的 `perspective` 從 0.5 改為 0，消除翻牌時數字往下位移的視覺瑕疵
- 修正計時結束音效：每次播放需用 `NSSound.copy()` 建立獨立副本，間隔從 0.65 秒縮短至 0.2 秒
- 在快捷時間預設列新增「5 SEC」選項，方便快速測試

## Non-Goals

- 不修改淺色主題（light theme）
- 不修改 UI 排版或視窗尺寸
- 不更新 GitHub Release（僅本機產出新 DMG）

## Impact

- Affected specs: `flip-clock-visuals`（字型、卡片視覺、翻牌動畫需求變更）、`app-bundle`（icon 產生邏輯變更）、`timer-alert`（音效播放邏輯變更）、`time-presets`（快捷時間預設列變更）
- Affected code: `Package.swift`、`Sources/GoodTimer/FlipClockView.swift`、`Sources/GoodTimer/TimerViewModel.swift`、`Sources/GoodTimer/ContentView.swift`、`generate-icon.swift`、`package.sh`（重新執行產生新 DMG）
- 新增檔案：`Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf`
