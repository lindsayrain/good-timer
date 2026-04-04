## 1. ViewModel 共享架構

- [x] 1.1 將 TimerViewModel 提升至 GoodTimerApp 層級，使用 @StateObject 持有，並透過 .environmentObject() 注入 WindowGroup（對應設計決策：使用 @StateObject + @EnvironmentObject 共享 ViewModel）
- [x] 1.2 修改 ContentView 從 @StateObject 改為 @EnvironmentObject 接收 TimerViewModel（確保 TimerViewModel is shared between main window and menu bar）

## 2. Menu Bar 基礎建設

- [x] 2.1 在 GoodTimerApp 新增 MenuBarExtra scene，使用 .window style，注入共享的 TimerViewModel（對應設計決策：使用 MenuBarExtra 的 .window style）
- [x] 2.2 建立 MenuBarView.swift，實作 popover 的基本佈局框架

## 3. Menu Bar 狀態顯示

- [x] 3.1 實作 menu bar item 動態標題：idle/paused 時顯示 timer icon，running 時顯示剩餘時間文字（Menu bar item displays timer status，對應設計決策：Menu Bar 標題動態切換）
- [x] 3.2 實作 popover 內的計時器數字顯示與單位標籤（Menu bar popover shows timer display）

## 4. Menu Bar 控制功能

- [x] 4.1 實作 popover 進度條，使用與主視窗相同的顏色邏輯（Menu bar popover shows progress bar in countdown mode）
- [x] 4.2 實作 popover 的 Start/Pause/Reset 控制按鈕（Menu bar popover provides start, pause, and reset controls）
- [x] 4.3 實作 popover 的快速預設按鈕，idle 時顯示、running 時隱藏（Menu bar popover shows quick presets in countdown idle state）
- [x] 4.4 實作「開啟主視窗」按鈕，點擊後啟動並帶出主視窗（Menu bar popover provides link to open main window）

## 5. 音效更新

- [x] 5.1 修改 TimerViewModel.triggerFinishAlert() 音效序列為 Glass → Glass → Ping，間隔 0.3 秒（Timer completion plays three audible dings，對應設計決策：音效序列改為 Glass → Glass → Ping）
