## Why

計時器的翻牌動畫不夠自然，缺乏真實火車站翻牌板的質感；同時整體 UI 只有深色版，無法切換主題，快選按鈕樣式也過於搶眼。

## What Changes

- **翻牌動畫重構**：採用雙 flap 架構（上半舊數字 0°→-90°、下半新數字 90°→0°），對應 CSS 翻牌板參考實作邏輯，讓動畫更自然
- **深色/淺色主題系統**：新增 `AppTheme` struct，統一管理所有顏色，右上角加入 ☀/🌙 切換按鈕，全 UI 即時跟著切換
- **卡片視覺調整**：移除卡片頂端多餘的 highlight 線與半卡邊緣的 divider 線，改用 FlipCard 的中央 gap（4pt）作為唯一的分隔縫，與真實翻牌板一致
- **字型強化**：從 `.bold, .monospaced` 改為 `.black, .default`（SF Pro Display Black），呈現日本車站翻牌板的飽滿粗體風格
- **快選按鈕低調化**：縮減 padding、移除填色背景，僅以文字顏色區分 active/inactive

## Non-Goals

- 不支援 system appearance 自動跟隨（使用者手動切換）
- 不加入自訂色彩設定

## Capabilities

### New Capabilities

- `flip-clock-visuals`: 翻牌時鐘的視覺呈現規格，涵蓋動畫機制、卡片質感、主題系統與快選按鈕樣式

### Modified Capabilities

(none)

## Impact

- Affected specs: `flip-clock-visuals` (new)
- Affected code:
  - `Sources/GoodTimer/FlipClockView.swift` — AppTheme struct、HalfCard、FlipCard、ClockSeparator、FlipClockDisplay、UnitLabels
  - `Sources/GoodTimer/ContentView.swift` — 主題狀態、切換按鈕、所有顏色參考
