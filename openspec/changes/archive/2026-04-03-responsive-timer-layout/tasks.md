## 1. 卡片尺寸調整

- [x] 1.1 更新 ClockLayout 常數：cardW 100→62、halfH 62→46、fontSize 76→50、digitGap 6→4、sepW 40→28（Font matches train station display style）
- [x] 1.2 在 HalfCard 外框加入 `.clipped()` 防止字型溢出卡片邊界（HalfCard clips content to card bounds）

## 2. 漸層與陰影調整

- [x] 2.1 統一 dark theme 的 cardTop/cardMid/cardBottom 為相同色值 `(0.09, 0.09, 0.11)`，移除漸層效果（Dark theme uses pure-black card colors / Card gradient provides depth）
- [x] 2.2 調整 light theme 的 cardTop 為 `(0.93, 0.92, 0.90)` 降低漸層對比
- [x] 2.3 移除 HalfCard 下半部的 `.shadow()` modifier（Bottom card half has no shadow）

## 3. 動態縮放

- [x] 3.1 在 ClockLayout 新增 baseW/baseH 常數供縮放計算使用
- [x] 3.2 在 ContentView 用 GeometryReader 包裹 FlipClockDisplay + UnitLabels + presetBar，套用 `scaleEffect(scale)` 實現等比例縮放（Timer display scales dynamically with window size）
- [x] 3.3 使用 `.position()` 將縮放後的內容置中（Timer display is vertically and horizontally centered）
- [x] 3.4 在 GeometryReader 加入 `.clipped()` 防止縮放後內容覆蓋 topBar/controlBar

## 4. Compact 模式

- [x] 4.1 新增 windowWidth state 與 compact computed property（寬度 < 400pt）
- [x] 4.2 使用 overlay GeometryReader + onChange 偵測視窗寬度變化
- [x] 4.3 topBar：compact 時隱藏 "GOOD TIMER" 標題、pin toggle 文字、mode segment 文字（Compact mode hides button labels below 400pt width）
- [x] 4.4 controlBar：CtrlBtn 加入 compact 參數，compact 時只顯示 icon
- [x] 4.5 presetBar：compact 時數字與單位(SEC/MIN)分開顯示，單位用 8pt 字型

## 5. 佈局穩定性

- [x] 5.1 presetBar 移入 GeometryReader 縮放區域內，跟隨計時器等比例變化
- [x] 5.2 presetBar 使用 `opacity(0)` 取代條件移除，避免按 START 時佈局跳動（Preset bar uses stable layout during timer run）
- [x] 5.3 移除 VStack 中多餘的 Spacer，讓 GeometryReader 佔滿中間空間

## 6. 視窗設定

- [x] 6.1 設定最小視窗尺寸為 200×100pt（Minimum window dimensions）
- [x] 6.2 設定預設視窗大小為 623×377pt
- [x] 6.3 移除 `.windowResizability(.contentSize)`，改用 `.defaultSize()` 允許自由調整大小
- [x] 6.4 AppDelegate 加入 `NSApp.activate(ignoringOtherApps: true)` 啟動時自動跳到前景（App activates on launch）

## 7. 冒號位置微調

- [x] 7.1 ClockSeparator 加入 `.offset(y: 30)` 將冒號下移至視覺居中位置

## 8. App Icon 更新

- [x] 8.1 generate-icon.swift：將上下半卡片漸層改為純色填充 `(0.09, 0.09, 0.11)`，與 app 內翻牌風格一致（App icon matches flip clock visual style）
- [x] 8.2 generate-icon.swift：放大數字 fontSize 從 `halfH * 0.85` 改為 `halfH * 2.0`
- [x] 8.3 generate-icon.swift：調整數字垂直位置（往上偏移 `size * 0.01`）
- [x] 8.4 重新生成所有 icon 尺寸（AppIcon.iconset/）並編譯為 AppIcon.icns
