## Context

GoodTimer 目前的翻牌時鐘在整個倒數過程中保持固定的文字顏色（米白色）。計時器的邏輯集中在 `TimerViewModel`，視覺呈現分散於 `FlipClockView`（數字）和 `ContentView`（進度條）。需要在不破壞現有翻牌動畫邏輯的前提下，加入動態顏色警示。

## Goals / Non-Goals

**Goals:**
- 剩餘時間低於目標的 20% 時，數字與進度條轉為黃色
- 剩餘時間低於目標的 10% 時，數字與進度條轉為紅色
- 顏色轉換有平滑過渡動畫（0.4s ease）
- 僅在倒數模式下觸發；正數模式不受影響

**Non-Goals:**
- 不新增聲音或震動警示（已有三聲鈴聲）
- 不支援使用者自訂閾值或顏色
- 不在 idle 狀態（未開始）時顯示警示色

## Decisions

### 警示等級由 ViewModel 計算，View 只讀取

將 `warningLevel` 作為 `@Published` 屬性放在 `TimerViewModel`，View 僅根據此值決定顯示顏色。

**理由**：閾值邏輯（10% / 20%）屬於業務邏輯，不應散落在 View 層。View 保持純顯示責任，未來若需要調整閾值只改一處。

**替代方案考慮**：直接在 View 內計算（`progressFraction` 已是 `@Published`），但這會讓兩個 View（FlipClockView 和 ContentView）各自重複計算，較難維護。

### 數字顏色透過傳入參數控制，不修改 FlipCard 內部結構

`FlipClockDisplay` 接受一個 `digitColor: Color` 參數，向下傳遞給 `FlipCard` → `HalfCard`，替換原本寫死的 `cardText` 常數。

**理由**：保持翻牌動畫邏輯不變，顏色只是外觀參數，符合最小修改原則。

### 進度條直接在 `ContentView` 根據 `warningLevel` 切換漸層顏色

進度條的顏色目前是藍→綠漸層，警示時改為對應的單色（黃色或紅色）。

## Risks / Trade-offs

- [動畫閃爍] 翻牌動畫途中若顏色切換，flap 的前後面顏色可能短暫不一致 → 接受此 trade-off，過渡動畫 0.4s 遠長於翻牌 0.3s，視覺上不明顯
- [idle 狀態] 倒數未開始時 progressFraction = 0，不應顯示警示色 → 以 `state == .running || state == .paused` 作為顏色警示的前提條件
