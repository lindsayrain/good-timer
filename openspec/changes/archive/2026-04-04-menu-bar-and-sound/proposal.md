## Why

目前 Good Timer 只能透過主視窗操作，當視窗被其他應用程式遮住或最小化時，使用者無法查看倒數進度或控制計時器。此外，計時結束的提示音固定為三聲 Glass，缺乏層次感。

## What Changes

- 新增 Menu Bar 迷你控制台：在 macOS menu bar 顯示計時器狀態（idle 時顯示 ⏱ icon，running 時顯示剩餘時間如 `04:23`），點擊展開 popover 可查看時間、進度條、開始/暫停/重設、快速預設選擇，以及開啟主視窗的按鈕
- 將 `TimerViewModel` 從 `ContentView` 提升至 App 層級，讓 Menu Bar 和主視窗共用同一個計時器狀態
- 計時結束音效從 Glass × 3 改為 Glass → Glass → Ping 組合，增加層次感

## Non-Goals

- 不做 Menu Bar only 模式（隱藏 Dock icon 只保留 menu bar）
- 不做自訂音效選擇器 UI — 本次僅更換固定的音效組合
- Menu Bar popover 不包含翻牌動畫，保持輕量

## Capabilities

### New Capabilities

- `menu-bar-panel`: Menu Bar 迷你控制台，包含計時器狀態顯示、popover 操作面板、與主視窗共用狀態

### Modified Capabilities

- `timer-alert`: 計時結束音效從三聲 Glass 改為 Glass → Glass → Ping 組合

## Impact

- 受影響的 specs：`menu-bar-panel`（新增）、`timer-alert`（修改音效序列）
- 受影響的程式碼：
  - `Sources/GoodTimer/GoodTimerApp.swift` — 新增 `MenuBarExtra` scene，提升 ViewModel 至 App 層級
  - `Sources/GoodTimer/ContentView.swift` — 改為接收外部注入的 ViewModel
  - `Sources/GoodTimer/TimerViewModel.swift` — 修改 `triggerFinishAlert()` 音效序列
  - `Sources/GoodTimer/MenuBarView.swift` — 新增 Menu Bar popover 視圖
