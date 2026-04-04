## Why

講師使用計時器時需要快速微調時間（如偷偷快轉），以及在投影場景下調整視窗透明度讓背景內容透出。此外，淺色模式下倒數警告色（黃色/紅色）在淺色背景上辨識度不足，需要針對淺色主題調整色彩。

## What Changes

- 新增 ±15 秒快速調整按鈕，放在 topBar 深淺色切換按鈕的左側，計時器在任何狀態下都可調整時間
- 新增視窗透明度切換按鈕，放在 topBar 深淺色切換按鈕的右側，循環切換 100% → 75% → 50% → 25%
- 修正淺色模式下 caution（≤20%）和 danger（≤10%）的字體顏色，使用深琥珀色和深紅色以提高對比度

## Non-Goals

- 不做自訂快轉秒數（固定 15 秒）
- 不做透明度數值的持久化儲存
- 不做透明度滑桿 UI — 僅提供循環切換按鈕

## Capabilities

### New Capabilities

- `time-adjust`: ±15 秒快速調整按鈕，支援 countdown 和 countup 兩種模式的時間微調
- `window-opacity`: 視窗透明度循環切換（100%/75%/50%/25%），透過 NSWindow.alphaValue 控制

### Modified Capabilities

- `countdown-color-warning`: 淺色模式下 caution 和 danger 警告色改為深琥珀色和深紅色，提高在淺色背景上的對比度

## Impact

- 受影響的 specs：`time-adjust`（新增）、`window-opacity`（新增）、`countdown-color-warning`（修改色彩）
- 受影響的程式碼：
  - `Sources/GoodTimer/ContentView.swift` — 新增 ±15s 按鈕、透明度按鈕、修正 digitColor 邏輯
  - `Sources/GoodTimer/TimerViewModel.swift` — 新增 `adjustTime(by:)` 方法
