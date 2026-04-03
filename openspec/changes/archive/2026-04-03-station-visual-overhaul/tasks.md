## 1. 打包字型資源（字型以 SPM Resource 打包，SwiftUI 用 Font.custom 載入）

- [x] 1.1 複製 `ChakraPetch-Bold.ttf` 從 `/Users/lindsayhsieh/Library/Fonts/ChakraPetch-Bold.ttf` 至 `Sources/GoodTimer/Resources/ChakraPetch-Bold.ttf`，實作 font matches train station display style
- [x] 1.2 修改 `Package.swift`：在 `executableTarget` 加入 `resources: [.process("Resources")]`，完成字型以 SPM Resource 打包
- [x] 1.3 確認字型打包正確：build 後確認 app bundle 內含 `ChakraPetch-Bold.ttf`

## 2. 更新翻牌時鐘字型與視覺（卡片圓角 10 → 3，AppTheme.dark 卡片色改純黑）

- [x] 2.1 修改 `Sources/GoodTimer/FlipClockView.swift`：`ClockLayout.corner` 從 10 改為 3，實作卡片圓角 10 → 3
- [x] 2.2 修改 `HalfCard` 的 `.font(...)` 從 `.system(size: F, weight: .black, design: .default)` 改為 `.custom("ChakraPetch-Bold", size: F)`，完成 font matches train station display style
- [x] 2.3 修改 `AppTheme.dark` 卡片色改純黑：`cardTop` 改為 `Color(red:0.13,green:0.13,blue:0.15)`、`cardMid` 改為 `Color(red:0.09,green:0.09,blue:0.11)`、`cardBottom` 改為 `Color(red:0.06,green:0.06,blue:0.08)`，實作 dark theme uses pure-black card colors
- [x] 2.4 執行 `swift run` 目視確認：數字顯示 Chakra Petch Bold 切角字形、卡片為近黑色

## 3. 更新 App Icon（generate-icon.swift 移除 Y 軸翻轉，改用標準 CoreText 座標系）

- [x] 3.1 重寫 `generate-icon.swift`：移除 Y 軸翻轉（`ctx.scaleBy(x:1, y:-1)`），改用標準底部原點座標系；下半卡片 `y = margin`，上半卡片 `y = margin + halfH + gap`；每次 CTLineDraw 前設定 `ctx.textMatrix = .identity`，實作 app icon uses flip-card visual design
- [x] 3.2 `generate-icon.swift` 中數字改為「9」，字型改為 `CTFontCreateWithName("ChakraPetch-Bold" as CFString, fontSize, nil)`
- [x] 3.3 執行 `swift generate-icon.swift` 產生 `AppIcon.iconset/`，目視確認「9」方向正確（圓圈在上、尾巴在下）
- [x] 3.4 執行 `iconutil -c icns AppIcon.iconset -o AppIcon.icns`，確認 `AppIcon.icns` 產生成功

## 4. 重新打包 DMG

- [x] 4.1 執行 `./package.sh`，確認新 `GoodTimer-1.0.0.dmg` 包含更新後的 app（新字型 + 新 icon）
- [x] 4.2 開啟 DMG 安裝後確認 Dock/Finder 顯示新 icon（數字「9」，Chakra Petch Bold）

## 5. 翻牌動畫移除透視位移（perspective 0.5 → 0，實作 flip animation uses orthographic projection）

- [x] 5.1 修改 `Sources/GoodTimer/FlipClockView.swift`：`FlipCard.body` 中上葉片與下葉片的 `rotation3DEffect` 的 `perspective` 從 `0.5` 改為 `0`，實作 flip animation uses orthographic projection
- [x] 5.2 執行 `swift build` 確認編譯通過

## 6. 計時結束音效修正（實作 timer completion plays three audible dings）

- [x] 6.1 修改 `Sources/GoodTimer/TimerViewModel.swift`：`triggerFinishAlert()` 中每次播放改用 `NSSound(named: "Glass")?.copy() as? NSSound` 建立獨立副本，實作 timer completion plays three audible dings
- [x] 6.2 修改延遲間隔從 `[0, 0.65, 1.3]` 改為 `[0, 0.2, 0.4]`，實作 timer completion plays three audible dings
- [x] 6.3 重啟 app 確認計時結束可聽到三聲「叮叮叮」

## 7. 快捷時間預設列新增 5 SEC（實作 preset bar includes a 5-second quick option）

- [x] 7.1 修改 `Sources/GoodTimer/ContentView.swift`：`presets` 從 `[5, 10, 15, 25, 45]` 改為 `[(label: String, seconds: Int)]` 元組陣列，首項為 `("5 SEC", 5)`，實作 preset bar includes a 5-second quick option
- [x] 7.2 更新 `presetBar` 的 `ForEach` 使用 `preset.label` 和 `preset.seconds`，實作 preset bar includes a 5-second quick option
- [x] 7.3 執行 `swift build` 確認編譯通過
