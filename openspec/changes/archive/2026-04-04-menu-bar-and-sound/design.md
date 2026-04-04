## Context

Good Timer 目前是純 `WindowGroup` 架構，`TimerViewModel` 作為 `@StateObject` 生存在 `ContentView` 內。要新增 Menu Bar 功能，需要讓 `MenuBarExtra` scene 和主視窗共享同一個 ViewModel。macOS 的 `MenuBarExtra` 從 macOS 13 開始支援，本專案已要求 macOS 13+。

## Goals / Non-Goals

**Goals:**

- 使用者在主視窗被遮住時仍可查看計時進度與操控計時器
- Menu Bar popover 保持輕量，不複製翻牌動畫
- 計時結束音效有層次感（Glass → Glass → Ping）

**Non-Goals:**

- 不做 Menu Bar only 模式（隱藏 Dock icon）
- 不做音效自訂選擇器 UI
- Popover 不支援深淺色主題切換（跟隨系統）

## Decisions

### 使用 @StateObject + @EnvironmentObject 共享 ViewModel

將 `TimerViewModel` 從 `ContentView` 提升到 `GoodTimerApp`，以 `@StateObject` 持有，透過 `.environmentObject(vm)` 注入到 `WindowGroup` 和 `MenuBarExtra` 兩個 scene。

`ContentView` 改為 `@EnvironmentObject var vm: TimerViewModel`。

替代方案：用 singleton `TimerViewModel.shared`。不採用是因為不利於測試且與 SwiftUI 的 ownership 模型衝突。

### 使用 MenuBarExtra 的 .window style

`MenuBarExtra` 支援兩種 style：`.menu`（系統選單）和 `.window`（自訂 popover）。選擇 `.window` 以支援自訂 UI（進度條、按鈕等），`.menu` 只能放基本的 `Button` / `Toggle`。

### Menu Bar 標題動態切換

Menu Bar item 的標題依狀態變化：
- **idle / paused**：顯示 SF Symbol `timer`（純 icon）
- **running**：顯示剩餘時間文字（如 `04:23`），省略小時除非 ≥ 1 小時

使用 `TimerViewModel` 的 `displaySeconds` 計算，透過 Timer publisher 每秒更新。

### 音效序列改為 Glass → Glass → Ping

修改 `triggerFinishAlert()` 內的音效序列：
- 第 0.0 秒：Glass
- 第 0.3 秒：Glass
- 第 0.6 秒：Ping

間隔從 0.2 秒加大到 0.3 秒，配合不同音色需要稍多的間隔以避免重疊。

## Risks / Trade-offs

- **Menu Bar icon 與 Dock icon 同時存在** → 預期行為，使用者透過 menu bar 快速操控，主視窗仍可正常使用
- **MenuBarExtra 在 macOS 12 不可用** → 專案已限定 macOS 13+，無影響
- **Popover 無法跟隨主視窗的深淺色主題** → 第一版跟隨系統外觀，後續可擴展
