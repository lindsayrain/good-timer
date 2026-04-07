## 1. 視窗層級與行為修改

- [x] 1.1 修改 ContentView.swift 中釘選按鈕的 action：啟用時將視窗層級設為 `.screenSaver`，停用時恢復為 `.normal`（Pin button sets window level above fullscreen applications）
- [x] 1.2 修改釘選按鈕的 action：啟用時設定 `collectionBehavior` 為 `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`，停用時重設為空（Pin button configures collection behavior for cross-space and fullscreen overlay）
- [x] 1.3 確認釘選操作使用 `canBecomeMain` 定位主視窗，避免影響 menu bar popover（Pin targets the main application window）

## 2. 驗證

- [x] 2.1 手動測試：開啟 Pin → 啟動全螢幕應用（如 PowerPoint 簡報模式）→ 確認計時器仍顯示在最上層
- [x] 2.2 手動測試：關閉 Pin → 確認視窗恢復正常層級，不再覆蓋全螢幕應用
- [x] 2.3 手動測試：Pin 啟用時切換桌面空間，確認計時器在所有空間可見
