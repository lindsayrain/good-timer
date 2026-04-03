## Why

計時器目前使用固定尺寸的翻牌鐘佈局，無法隨視窗大小動態調整。當使用者希望在不同螢幕大小下使用計時器（例如小視窗釘在角落或放大到全螢幕），固定佈局無法滿足需求。此外，翻牌卡片尺寸需要調整為更緊湊的比例。

## What Changes

- 翻牌鐘區域使用 `GeometryReader` + `scaleEffect` 實現等比例動態縮放
- 卡片尺寸調整：寬度 100→62pt、半高 62→46pt、字型 76→50pt、間距與分隔符等比縮小
- 視窗最小尺寸從 780×460pt 改為 200×100pt，允許極小視窗
- 新增 compact 模式（視窗寬度 < 400pt 時）：按鈕與模式切換只顯示 icon，隱藏文字標籤
- 卡片漸層移除（三色統一為同一色值），移除下半卡片陰影
- HalfCard 外框加入 `.clipped()` 防止字型溢出
- 快速設定時間 preset bar 移入縮放區域，跟隨計時器等比例變化
- preset bar 在運行時使用 `opacity(0)` 隱藏而非條件移除，避免佈局跳動
- 預設視窗大小設為 623×377pt
- App 啟動時自動跳到最前面（`NSApp.activate`）
- App icon 更新：移除漸層改為純色填充、放大數字、調整數字位置，與 app 內翻牌風格一致

## Non-Goals

- 不更換字型（維持 Chakra Petch Bold）
- 不改變翻牌動畫邏輯（保持 dual-flap mechanism）
- 不實作個別元素的獨立縮放（統一等比例縮放）

## Capabilities

### New Capabilities

- `responsive-layout`: 翻牌鐘佈局動態縮放與 compact 模式

### Modified Capabilities

- `flip-clock-visuals`: 卡片尺寸、漸層、陰影等視覺參數變更

## Impact

- 受影響的 spec：`flip-clock-visuals`（尺寸與色值參數更新）、新增 `responsive-layout`
- 受影響的程式碼：
  - `Sources/GoodTimer/FlipClockView.swift`（ClockLayout 常數、HalfCard clipped、漸層/陰影移除）
  - `Sources/GoodTimer/ContentView.swift`（GeometryReader 縮放、compact 模式、preset bar 佈局）
  - `Sources/GoodTimer/GoodTimerApp.swift`（預設視窗大小、NSApp.activate）
  - `generate-icon.swift`（icon 純色填充、數字放大與位置調整）
  - `AppIcon.icns`、`AppIcon.iconset/`、`icon.png`（重新生成的 icon 檔案）
