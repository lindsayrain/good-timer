## Why

模式切換按鈕目前標示為「COUNTDOWN」和「COUNT UP」，與業界慣例不一致。Apple Clock 和 Google Clock 都使用「Timer」（倒數）和「Stopwatch」（計時）作為標準用語，使用者更熟悉這組詞彙。

## What Changes

- 將 ContentView 中模式切換的標籤從 `COUNTDOWN` 改為 `TIMER`
- 將 ContentView 中模式切換的標籤從 `COUNT UP` 改為 `STOPWATCH`

## Non-Goals

- 不改變 enum 值（`.countdown` / `.countup`）——這是內部命名，不影響使用者
- 不改變功能行為，僅修改 UI 顯示文字

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `responsive-layout`: 模式切換按鈕的顯示文字從 COUNTDOWN/COUNT UP 改為 TIMER/STOPWATCH

## Impact

- Affected specs: `responsive-layout`（修改）
- Affected code:
  - 修改 `Sources/GoodTimer/ContentView.swift`（mode toggle label 文字）
