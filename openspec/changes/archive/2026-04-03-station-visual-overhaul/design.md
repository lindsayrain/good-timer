## Context

Good Timer 的翻牌時鐘目前使用 SF Pro Black（系統字型），卡片圓角 10pt，深色主題採深灰漸層。本次將字型改為 Chakra Petch Bold，需要在 Swift Package Manager 專案中打包自訂字型資源，並同步更新 icon 產生腳本的座標系邏輯。

## Goals / Non-Goals

**Goals:**
- 在 SPM 專案中正確打包並載入 Chakra Petch Bold
- 翻牌數字、icon 視覺一致採用新字型
- 修正 generate-icon.swift 的 CoreText 座標系 bug（文字倒置問題）

**Non-Goals:**
- 不修改動畫邏輯
- 不修改淺色主題
- 不更新 GitHub Release

## Decisions

### 字型以 SPM Resource 打包，SwiftUI 用 Font.custom 載入

將 `ChakraPetch-Bold.ttf` 放至 `Sources/GoodTimer/Resources/`，在 `Package.swift` 的 target 中加入 `.process("Resources")`。SwiftUI 用 `Font.custom("ChakraPetch-Bold", size: F)` 載入。

**無需修改 Info.plist**：SPM 打包的字型資源在 app bundle 內，macOS 會自動注冊，不需要 `UIAppFonts`（iOS 限定），也不需要 `ATSApplicationFontsPath`（已廢棄）。

**字型 PostScript 名稱**：`ChakraPetch-Bold`（與檔名不含副檔名一致，可用 `CTFontCopyPostScriptName` 驗證）。

### generate-icon.swift 移除 Y 軸翻轉，改用標準 CoreText 座標系

原腳本用 `ctx.translateBy + scaleBy(y:-1)` 翻轉座標系，導致 CTLineDraw 繪製的文字上下倒置（「0」因對稱未被發現，「9」暴露問題）。

修正方式：**移除 Y 軸翻轉**，改用 CoreGraphics 標準底部原點（y=0 在底部）。路徑與漸層的 Y 座標全部以底部為基準重新計算：
- 下半卡片 `y = margin`（靠近底部）
- 上半卡片 `y = margin + halfH + gap`（靠近頂部）
- 文字用 `ctx.textMatrix = .identity` 確保不受 context transform 影響

### 卡片圓角 10 → 3，AppTheme.dark 卡片色改純黑

`ClockLayout.corner` 從 10 改為 3。`AppTheme.dark` 的 `cardTop`、`cardMid`、`cardBottom` 改為：
- `cardTop`: `Color(red: 0.13, green: 0.13, blue: 0.15)`
- `cardMid`: `Color(red: 0.09, green: 0.09, blue: 0.11)`
- `cardBottom`: `Color(red: 0.06, green: 0.06, blue: 0.08)`

### 翻牌動畫移除透視位移

`FlipCard` 的 `rotation3DEffect` 中 `perspective` 從 `0.5` 改為 `0`。原因：perspective > 0 時，3D 旋轉產生透視投影位移，翻牌瞬間數字會視覺上往下移動一格。設為 0（正交投影）後翻牌為純粹的 Y 軸壓縮效果，無位移瑕疵。

修改位置：`FlipClockView.swift` 的 `FlipCard.body` 中兩處 `rotation3DEffect`（上葉片、下葉片各一）。

### 計時結束音效修正

`TimerViewModel.triggerFinishAlert()` 播放三聲「Glass」系統音效。

**問題修正**：`NSSound(named: "Glass")?.play()` 在同一實例播放中再次呼叫 `play()` 會被忽略，導致只聽到一聲。修正：每次用 `NSSound(named: "Glass")?.copy() as? NSSound` 建立獨立副本。

**間隔調整**：三聲延遲從 `[0, 0.65, 1.3]` 調整為 `[0, 0.2, 0.4]`，節奏更急促。

### 快捷時間預設列新增 5 SEC

`ContentView` 的 `presets` 從分鐘陣列 `[5, 10, 15, 25, 45]` 改為 `(label, seconds)` 元組陣列：`[("5 SEC", 5), ("5 MIN", 300), ("10 MIN", 600), ("15 MIN", 900), ("25 MIN", 1500), ("45 MIN", 2700)]`。

`presetBar` 的 `ForEach` 對應更新為使用 `preset.label` 和 `preset.seconds`。

## Risks / Trade-offs

- **字型名稱不符** → `Font.custom` 載入失敗時 SwiftUI 靜默 fallback 到系統字型，視覺無變化但不報錯；實作後需目視確認字型已生效
- **generate-icon.swift 座標重算** → 路徑與漸層方向全部重新計算，需執行腳本後目視確認 icon 正確
- **perspective 0 視覺差異** → 正交投影的翻牌缺少 3D 深度感，但消除位移瑕疵，整體更乾淨
