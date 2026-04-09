## Why

在播放簡報（例如 PowerPoint 簡報模式）時，計時器的「釘選置頂」功能無法將視窗顯示在全螢幕簡報上方。原因是目前使用的 `.floating` 視窗層級不足以覆蓋簡報應用的全螢幕視窗。

## What Changes

- 將釘選功能的視窗層級從 `.floating` 提升至 `.screenSaver`，確保能覆蓋全螢幕應用（包含 PowerPoint、Keynote 等簡報軟體）
- 釘選時設定 `collectionBehavior` 為 `.canJoinAllSpaces`、`.fullScreenAuxiliary`、`.stationary`，使視窗能跨桌面並顯示在全螢幕應用上方
- 取消釘選時恢復為預設視窗層級與行為

## Capabilities

### New Capabilities

- `always-on-top`: 釘選置頂功能的視窗層級與跨桌面行為，確保計時器能覆蓋全螢幕應用（如簡報模式）

### Modified Capabilities

（無）

## Impact

- 受影響的程式碼：`Sources/GoodTimer/ContentView.swift`（釘選按鈕的 action 邏輯）
