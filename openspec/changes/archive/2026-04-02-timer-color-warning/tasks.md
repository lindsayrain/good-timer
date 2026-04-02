## 1. ViewModel — 警示等級計算

- [x] 1.1 在 `TimerViewModel` 加入 `WarningLevel` enum（`none` / `caution` / `danger`）；依設計「警示等級由 ViewModel 計算，View 只讀取」，新增 `@Published var warningLevel: WarningLevel`，remaining fraction ≤ 0.10 → `danger`，≤ 0.20 → `caution`，否則 `none`（符合 Requirement: Warning level computed from remaining fraction）
- [x] 1.2 在 `tick()` 與 `reset()` 中同步更新 `warningLevel`；idle 狀態與正數模式強制為 `none`

## 2. 翻牌數字顏色

- [x] 2.1 依設計「數字顏色透過傳入參數控制，不修改 FlipCard 內部結構」，將 `HalfCard` 的 `cardText` 改為可傳入的 `digitColor: Color` 參數，並逐層透過 `FlipCard` → `FlipClockDisplay` 傳遞（符合 Requirement: Digit color reflects warning level）
- [x] 2.2 在 `ContentView` 根據 `vm.warningLevel` 計算 `digitColor`（none=米白、caution=黃、danger=紅），以 `withAnimation(.easeInOut(duration: 0.4))` 驅動切換；reset 後回到預設色

## 3. 進度條顏色

- [x] 3.1 依設計「進度條直接在 `contentview` 根據 `warninglevel` 切換漸層顏色」，none 保持藍→綠漸層，caution 改為純黃，danger 改為純紅，套用 0.4s ease 動畫（符合 Requirement: Progress bar color reflects warning level）
