## 1. 翻牌動畫強化

- [x] 1.1 在 `FlipCard` 中將 `.linear(duration: 0.3)` 替換為 `.timingCurve(0.4, 0, 0.2, 1, duration: 0.35)`，使翻牌動畫符合「flip animation feels physical」規格的 ease-in-out 要求
- [x] 1.2 將 `rotation3DEffect` 的 `perspective` 值從 `0.5` 調高至 `0.8`，符合規格要求
- [x] 1.3 在 `FlipCard` 的動畫 flap 上加入動態陰影：進入 `flipping` 狀態時漸入 shadow，動畫結束後漸出，符合「dynamic drop shadow SHALL appear on the falling flap」規格

## 2. 卡片視覺質感

- [x] 2.1 實作「card gradient provides depth」：在 `HalfCard` 的背景填色改為線性漸層（上端色值 `(0.17, 0.17, 0.20)`、下端色值 `(0.10, 0.10, 0.12)`），符合「card has depth and texture」規格的 gradient 要求
- [x] 2.2 在 `HalfCard` 的上半（`isTop == true`）最頂端加入 1pt 高的白色 highlight overlay（opacity 0.15），符合規格的 top highlight line 要求
- [x] 2.3 將 `dividerCol` 的色值調暗至 `(0.03, 0.03, 0.04)`，使分隔線視覺上更為凹陷，符合「center divider line is darker than the card face」規格

## 3. 快選按鈕低調化（Quick-preset buttons use a low-profile style）

- [x] 3.1 實作「quick-preset buttons use a low-profile style」：在 `ContentView.presetBar` 中移除 `RoundedRectangle.fill(...)` 背景，符合「quick-preset buttons SHALL NOT use a filled background」規格
- [x] 3.2 將按鈕 padding 改為 `.horizontal, 8` 和 `.vertical, 4`，符合規格的 ≤ 10pt / ≤ 5pt 要求
- [x] 3.3 非 active 的 preset label 顏色改為 `dim.opacity(0.45)`；active 的 preset label 改為 `accentBlue`（全 opacity），移除填色 pill，符合「active preset SHALL be indicated by a subtle color change on the text only」規格

## 4. 翻牌動畫重構（雙 flap 架構）

- [x] 4.1 重構 `FlipCard`：採用「dual-flap mechanism」架構，分離 `upperFlapDeg`（0→-90°，anchor .bottom）與 `lowerFlapDeg`（90→0°，anchor .top）兩個獨立動畫狀態
- [x] 4.2 上半 flap 顯示舊數字（`flapOld`），下半 flap 顯示新數字（`flapNew`），靜態底部在翻牌期間顯示舊數字，結束後切換為新數字
- [x] 4.3 兩個 flap 同步以 `.easeInOut(duration: 0.45)` 動畫，`perspective: 0.5`，符合「flip animation uses dual-flap mechanism」規格

## 5. 卡片視覺修正（card center seam）

- [x] 5.1 移除 `HalfCard` 中 `if isTop { Rectangle()...highlight }` 頂端 highlight 線，符合「no highlight line SHALL be drawn at the top edge」規格
- [x] 5.2 移除 `HalfCard` 中兩條 `Rectangle()...divider` 邊緣線，改用 `FlipCard` 的 `gap = 4pt` 作為唯一分隔縫，符合「card center seam is the only divider」規格
- [x] 5.3 字型從 `.bold, .monospaced` 改為 `.black, .default`（SF Pro Display Black），符合「font matches train station display style」規格

## 6. 深色/淺色主題系統

- [x] 6.1 在 `FlipClockView.swift` 定義 `AppTheme` struct，包含 `isDark`、`bg`、`cardTop/Mid/Bottom`、`divider`、`cardShadow`、`separator`、`label`、`dim`、`digitNormal`、`progressTrack`、`controlBg` 等欄位，並提供 `.dark` 與 `.light` 靜態實例
- [x] 6.2 更新 `HalfCard`、`FlipCard`、`ClockSeparator`、`FlipClockDisplay`、`UnitLabels` 接受 `theme: AppTheme` 參數，將所有硬編碼顏色替換為 `theme.*` 屬性
- [x] 6.3 在 `ContentView` 加入 `@State private var isDark = true`，計算屬性 `var theme: AppTheme`，將所有顏色參考（bg、dim、digitColor 等）替換為 `theme.*`
- [x] 6.4 在 top bar 新增主題切換按鈕（☀/🌙 icon），點擊以 `.easeInOut(duration: 0.25)` 動畫切換 `isDark`，符合「dark and light themes are supported」規格
- [x] 6.5 將 `.preferredColorScheme(.dark)` 改為動態 `.preferredColorScheme(isDark ? .dark : .light)`
