## 1. ±15 秒快速調整

- [x] 1.1 在 TimerViewModel 新增 `adjustTime(by:)` 方法，支援 countdown 調整 target、countup 調整 elapsed，數值 clamp 至 0（Time adjust modifies countdown target during idle、Time adjust modifies countdown target during running、Time adjust modifies elapsed time in count-up mode）
- [x] 1.2 在 ContentView topBar 深淺色切換按鈕左側新增 -15s 和 +15s 兩顆 pill 按鈕（Time adjust buttons in top bar）

## 2. 視窗透明度切換

- [x] 2.1 在 ContentView 新增 @State opacityLevel，透過按鈕循環切換 100%/75%/50%/25%，設定 NSWindow.alphaValue（Opacity cycles through four levels、Opacity applies to main window only）
- [x] 2.2 在 topBar 深淺色切換按鈕右側新增透明度按鈕，顯示目前百分比，啟用時亮藍色（Opacity toggle button in top bar）

## 3. 淺色模式警告色修正

- [x] 3.1 修改 ContentView digitColor 依 isDark 區分 caution/danger 顏色：淺色用深琥珀色和深紅色（Digit color reflects warning level）
