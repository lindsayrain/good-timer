## Why

上課時把 timer 縮小釘在螢幕角落監看，發現兩個問題：
1. 視窗縮小後數字還是被 top bar（6 顆按鈕）與 control bar（3 顆按鈕）擠壓，無法一眼看清剩餘時間
2. 計時進行中大部分控制列其實沒在用，但仍佔據版面

原本的 `compact` 斷點（< 400pt）只把按鈕文字縮掉、圖示仍全數保留；`GeometryReader` 置中也讓翻卡與進度條之間留下約 17pt 的空白，翻卡始終無法變大到一眼就能看見。

## What Changes

### 以翻卡為主角的尺寸規則

- **翻卡高度優先**：翻卡在版面中為最重要的元素，高度預算取 `max(視窗高 − 其他元素固定保留, 視窗高 × 0.6)`，並以 `min(寬度限制, 高度預算限制)` 算出最終 scale，盡可能讓翻卡佔據視窗高度 60% 以上
- **移除主層 `GeometryReader`**：直接從 `@State windowWidth` 與新加的 `@State windowHeight` 計算尺寸，避免原本「GeometryReader 貪婪吃掉剩餘高度再置中」造成的上下空白
- **翻卡以 `.frame → .scaleEffect → .frame(scaledW, scaledH)` 三段式渲染**，讓 VStack 看到的就是實際縮放後尺寸，上下沒有隱藏 padding
- **Unit labels（HOURS / MINUTES / SECONDS）完全移除**（非 mini 也移除），把空間讓給翻卡
- **進度條與翻卡的距離固定 1pt**（兩種模式皆然），翻卡直接緊貼進度條
- **進度條高度再減半**：非 mini 3pt → 1.5pt、mini 1.5pt → 0.75pt，mini 模式並移除 horizontal padding 讓進度條貼齊邊緣

### Mini 斷點（windowWidth < 400）

- Top bar 完全不渲染；改以 `Color.clear.frame(height: 22)` 為 pin 預留高度
- **Pin 按鈕以 overlay 浮在視窗右上角**（與 macOS 紅綠燈同一水平線），用 `.frame(maxWidth/maxHeight: .infinity, alignment: .topTrailing)` 實作
- Control bar 僅保留 START/PAUSE/RESTART；`SET TIME` 與 `RESET` 隱藏
- Preset bar 完全不佔 layout（非 `opacity(0)`）
- `CtrlBtn` 新增 `mini: Bool` 參數，在 mini 模式下使用更小的 icon（10pt）、padding（h:7 v:5）與 corner radius（6pt）

### 自訂 title bar row 與置中 app 名稱

- **視窗啟用 `fullSizeContentView`**：在 `AppDelegate.applicationDidFinishLaunching` 對每個 window 插入 `.fullSizeContentView` style mask、`titlebarAppearsTransparent = true`、`titleVisibility = .hidden`、`isMovableByWindowBackground = true`，讓 SwiftUI content view 實際延伸到視窗最頂端（紅綠燈那一列）
- **"GOOD TIMER" 標籤改置中於 title bar 列**：從原 `topBar` 左側的標籤位置移除，改以主 ZStack 上層 overlay 渲染，透過 `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)` 置中、`padding(.top, 8)`、`ignoresSafeArea(.all, edges: .top)` 讓它精確落在紅綠燈水平線
- **字體規格**：`.system(size: 13, weight: .semibold, design: .monospaced)`、`tracking(4)`、`foregroundColor(theme.dim)`、`allowsHitTesting(false)`（不擋下方互動）
- **兩種模式皆顯示**：mini 與非 mini 都會看到置中的 "GOOD TIMER"，避免 mini 模式下的視覺落差

### 翻卡以原生解析度渲染（取代 `.scaleEffect` bitmap 縮放）

- **問題**：視窗寬度 > 600pt 時，原先以 `.frame(baseW, baseH).scaleEffect(scale).frame(scaledW, scaledH)` 三段式渲染會把「渲染後的點陣」放大，導致翻卡字體模糊
- **解法**：把 `scale` 參數往下傳給 `FlipClockDisplay` / `FlipCard` / `HalfCard` / `ClockSeparator`，各 view 在 body 中把 `ClockLayout` 常數（`cardW`、`halfH`、`fontSize`、`corner`、`digitGap`、`pairW`、dot 大小、`offset(y:)`、`gap`、separator 寬度）直接乘上 `scale`，文字在繪製階段就是原生點大小，放大也不會糊
- ContentView 中 flip clock 渲染改為 `FlipClockDisplay(..., scale: metrics.scale).frame(width: metrics.width, height: metrics.height)`，完全移除 `.scaleEffect`

### 原先「計時中 top bar 自動淡出」需求撤銷

- 原先規劃在 `vm.state == .running` 且 compact 時讓 top bar 淡出、hover 再淡入
- 實作發現：mini 模式下 top bar 根本整個被替換成 pin overlay，已達到「計時中最大化數字空間」的目的
- Hover 淡出/淡入機制增加複雜度而收益有限，**此需求從 scope 中移除**

## Non-Goals

- **不改預設視窗大小**：launch 仍是 623×377，使用者手動縮小才會觸發 mini
- **不改最小視窗尺寸**：仍維持 200×100 下限
- **不做可配置的偏好**：mini 模式行為固定、不提供 settings
- **不做 top bar hover 自動淡出**：原先規劃撤銷
- **不在 mini 模式加入右鍵選單替代隱藏按鈕**：被隱藏的功能需放大視窗才能使用
- **不處理極端長寬比**（例如極寬極矮）：當 aspect 不允許時，翻卡 60% 高度目標可能無法達成，以「寬度限制下盡可能大」為回退

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `responsive-layout`: 新增 mini 斷點（< 400pt）、mini 模式 pin 浮動於右上角、翻卡為主角的 60% 高度優先規則、unit labels 不再顯示、"GOOD TIMER" 標籤置中於紅綠燈水平列、翻卡以原生點大小渲染避免 bitmap 放大模糊

## Impact

- Affected specs: `responsive-layout`
- Affected code:
  - `Sources/GoodTimer/ContentView.swift`
    - 新增 `mini` / `windowHeight` state 與 `CardMetrics` 結構、`cardMetrics()` 計算函式
    - body 重寫：取消主層 `GeometryReader`，改用顯式尺寸計算
    - `topBar` 在 mini 模式下完全不渲染；新增 `pinButton` 共用 computed view 於 overlay
    - `controlBar` 在 mini 模式下隱藏 SET TIME / RESET
    - `progressBar` 高度與 padding 調整
    - `CtrlBtn` 新增 `mini: Bool` 參數
    - 移除 `topBar` 左側原 "GOOD TIMER" 標籤；在主 ZStack 新增置中 Text overlay，搭配 `ignoresSafeArea(.all, edges: .top)` 坐落於 title bar 水平列
    - flip clock 渲染改為將 `metrics.scale` 直接傳給 `FlipClockDisplay`，移除 `.scaleEffect`
  - `Sources/GoodTimer/FlipClockView.swift`
    - `ClockSeparator` 加上 `width` 參數
    - `FlipClockDisplay` 加上 `separatorWidth` 參數
    - `HalfCard` / `FlipCard` / `ClockSeparator` / `FlipClockDisplay` 全部加上 `scale: CGFloat = 1` 參數，body 中將 `ClockLayout` 相關常數（`cardW`、`halfH`、`fontSize`、`corner`、`digitGap`、`pairW`、dot、offset、gap、separator width）乘上 `scale` 以原生點大小渲染
  - `Sources/GoodTimer/GoodTimerApp.swift`
    - `AppDelegate.applicationDidFinishLaunching` 對 `NSApp.windows` 插入 `.fullSizeContentView` style mask、設 `titlebarAppearsTransparent = true`、`titleVisibility = .hidden`、`isMovableByWindowBackground = true`
