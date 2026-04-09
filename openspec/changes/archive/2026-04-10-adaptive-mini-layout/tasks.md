## 1. 加入 mini 斷點狀態

- [x] 1.1 在 `ContentView` 新增 `private var mini: Bool { windowWidth < 400 }` computed property，與既有的 `compact`（< 400）並存
- [x] 1.2 確認 `windowWidth` 的 `onChange` 會在 window resize 時正確更新，mini 狀態可即時反應

## 2. Mini mode provides maximum digit space below 400pt width

- [x] 2.1 實作「Mini mode provides maximum digit space below 400pt width」需求：修改 `topBar`，在 mini 模式下隱藏 "-15s"、"+15s"、主題切換（sun/moon）、opacity 切換、mode toggle（COUNTDOWN/COUNT UP 分段），僅保留釘選（pin）按鈕
- [x] 2.2 修改 `topBar` 的 padding：mini 模式下進一步壓縮 horizontal 與 top padding，避免留白吃掉數字空間
- [x] 2.3 修改 `controlBar`：在 mini 模式下隱藏 `SET TIME` 與 `RESET` 按鈕，僅保留 START/PAUSE/RESTART 的主要按鈕
- [x] 2.4 修改 `UnitLabels` 的呼叫處：在 mini 模式下將其從 VStack 移除（使 flip clock 往下延伸）
- [x] 2.5 修改 preset bar 的出現條件：在 mini 模式下完全不佔 layout（用條件移除而非 `opacity(0)`），讓 flip clock 在 mini 模式下能完全撐滿
- [x] 2.6 進一步移除 mini 模式下整個 `topBar` 渲染，改成在 VStack 最上方保留 22pt `Color.clear` 作為 pin overlay 預留空間
- [x] 2.7 把 pin 按鈕抽成共用的 `pinButton` computed view，非 mini 在 top bar 內、mini 以 `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)` 浮在右上角
- [x] 2.8 `CtrlBtn` 新增 `mini: Bool` 參數（預設 false），在 mini 模式下使用更小的 icon 尺寸（10pt）、padding（h:7 v:5）、corner radius（6pt）
- [x] 2.9 `ClockSeparator` 與 `FlipClockDisplay` 加上 `width` / `separatorWidth` 參數，讓 mini 模式能把 separator 縮到 4pt，翻卡進一步放大

## 3. Flip clock cards are the primary content and occupy at least 60% of window height

- [x] 3.1 新增 `@State private var windowHeight: CGFloat = 480`，並在 overlay `GeometryReader` 的 `onAppear` / `onChange` 同時更新 `windowWidth` 與 `windowHeight`
- [x] 3.2 新增 `CardMetrics` 結構與 `cardMetrics()` 函式，根據「Flip clock cards are the primary content and occupy at least 60% of window height」需求計算 baseW / baseH / scale
- [x] 3.3 在 `cardMetrics()` 中實作高度預算：`cardHBudget = max(windowHeight − reservedChromeHeight, windowHeight × 0.6)`，其中 reservedChromeHeight 是 topReserve + progressReserve + presetReserve + controlReserve
- [x] 3.4 計算 `scale = min(scaleByW, scaleByH)` 並設定 floor `max(0.05, …)` 以避免除零或負值
- [x] 3.5 在 body 中移除主層 `GeometryReader`，改以 `FlipClockDisplay(...).frame(baseW, baseH).scaleEffect(scale).frame(scaledW, scaledH).frame(maxWidth: .infinity)` 三段式渲染，讓 VStack 看到真實縮放後尺寸
- [x] 3.6 從 body 與 `miniFlipClock`（舊版）中完全移除 `UnitLabels` 呼叫，實現「unit labels row is hidden in all modes」
- [x] 3.7 body VStack 內加入 `Spacer(minLength: 0)` 於翻卡與 preset/control bar 之間，把彈性空間放到翻卡下方，確保翻卡不因置中而留下頂部空白
- [x] 3.8 把進度條與翻卡間距統一為 1pt（兩種模式皆然），同步更新 `cardMetrics()` 內的 `progressReserve`

## 4. 進度條與控制列細節調整

- [x] 4.1 進度條高度再減半：非 mini 3pt → 1.5pt、mini 1.5pt → 0.75pt
- [x] 4.2 mini 模式下進度條移除 horizontal padding（原為 28pt），讓進度條貼齊視窗兩側
- [x] 4.3 control bar 底部 padding 在 mini 模式為 6pt、非 mini 為 14pt

## 5. 移除原先「Top bar auto-hides during countdown when window is compact」需求

- [x] 5.1 從 spec delta 移除「Top bar auto-hides during countdown when window is compact」requirement（原先規劃的 hover 淡出機制撤銷，mini 模式直接不渲染 top bar 已達成同等效果）
- [x] 5.2 從 `ContentView` 移除 `topBarHovering` state、`topBarVisible` / `topBarCollapsed` 相關 computed、hover 感應區 overlay
- [x] 5.3 在 proposal.md 的 Non-Goals 標註此需求從 scope 撤銷

## 6. App title is centered on the traffic light row in both modes

- [x] 6.A.1 實作「App title is centered on the traffic light row in both modes」需求：在 `GoodTimerApp.swift` 的 `AppDelegate.applicationDidFinishLaunching` 對 `NSApp.windows` 加入 `.fullSizeContentView` style mask，設 `titlebarAppearsTransparent = true`、`titleVisibility = .hidden`、`isMovableByWindowBackground = true`
- [x] 6.A.2 從 `ContentView.topBar` 的 leading `HStack` 移除原 "GOOD TIMER" `Text`，讓 top bar 只剩右側按鈕
- [x] 6.A.3 在 `ContentView.body` 的主 ZStack 加入置中 "GOOD TIMER" Text overlay：`font(.system(size: 13, weight: .semibold, design: .monospaced))`、`tracking(4)`、`foregroundColor(theme.dim)`、`padding(.top, 8)`、`frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)`、`ignoresSafeArea(.all, edges: .top)`、`allowsHitTesting(false)`、`zIndex(3)`
- [x] 6.A.4 確認非 mini 與 mini 兩種模式下標籤都可見、不擋互動、不隨視窗高度拉高而垂直飄移

## 7. Flip clock digits are rendered at native point size

- [x] 7.1 實作「Flip clock digits are rendered at native point size」需求：`FlipClockView.HalfCard` 新增 `scale: CGFloat = 1` 參數，把 `cardW` / `halfH` / `fontSize` / `corner` 等 `ClockLayout` 常數乘上 `scale`
- [x] 7.2 `FlipClockView.FlipCard` 新增 `scale: CGFloat = 1` 參數，把 `W` / `H` / `gap` 乘上 `scale`，並把 `scale` 傳給內部 `HalfCard`
- [x] 7.3 `FlipClockView.ClockSeparator` 新增 `scale: CGFloat = 1` 參數，把 dot 大小、`VStack` spacing、`offset(y:)` 全部乘上 `scale`
- [x] 7.4 `FlipClockView.FlipClockDisplay` 新增 `scale: CGFloat = 1` 參數，內部 `HStack(spacing: ClockLayout.digitGap * scale)`、`frame(width: ClockLayout.pairW * scale)`，並把 `scale` 傳給 `FlipCard` 與 `ClockSeparator`（`ClockSeparator` 的 `width` 也改成 `separatorWidth * scale`）
- [x] 7.5 `ContentView.body` 的 flip clock 渲染改為 `FlipClockDisplay(vm: ..., digitColor: ..., theme: ..., separatorWidth: metrics.sepW, scale: metrics.scale).frame(width: metrics.width, height: metrics.height)`，完全移除 `.scaleEffect(metrics.scale, anchor: .center)` 與原先的 `frame(width: metrics.baseW, height: metrics.baseH)`

## 8. 回歸測試

- [x] 8.1 用 `swift build -c release` 確認無編譯警告
- [x] 8.2 在 width ≥ 400 的預設大小下執行一輪 countdown，確認既有行為不受影響（top bar 全亮、control bar 全部按鈕可用、pin 按鈕在 top bar 內）
- [x] 8.3 切到 count up 模式在 mini 視窗測試，確認 START/PAUSE 仍能運作、mode toggle 雖被隱藏但可透過放大視窗切換
- [x] 8.4 在 mini 視窗下測試 pin 釘選 + 透明度（先在 ≥ 400 設好 75%/50% 再縮小），確認視窗仍保持釘選與透明度狀態
- [x] 8.5 將視窗拖至 width < 400，確認 flip clock 數字明顯放大、top bar 完全不見、pin 浮在右上角、control bar 只剩播放鈕
- [x] 8.6 將視窗從 < 400 拖回 ≥ 400，確認 top bar 立即恢復、pin 回到 top bar 內、SET TIME 與 RESET 按鈕回來
- [x] 8.7 在非 mini 的預設視窗下確認：翻卡緊貼進度條（1pt 間距）、翻卡下方剩餘空間在 preset bar / control bar 上方、無「翻卡被控制列蓋住」現象
- [x] 8.8 將視窗拉高（≥ 500pt tall）確認翻卡隨高度增長而放大（若寬度允許），實際測試「翻卡 ≥ 60% 高度」規則
- [x] 8.9 視窗拉高時確認 "GOOD TIMER" 標籤仍精準對齊紅綠燈水平線、不隨高度飄移（使用者已手動驗證）
- [x] 8.10 視窗寬度 > 600pt 時確認翻卡數字清晰無模糊（使用者已手動驗證）
