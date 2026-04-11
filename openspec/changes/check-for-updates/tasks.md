## 1. 核心邏輯：UpdateChecker

- [x] 1.1 建立 `Sources/GoodTimer/UpdateChecker.swift`，實作 `UpdateChecker` 為 `ObservableObject`，包含 `@Published` 屬性：`isUpdateAvailable: Bool`、`latestVersion: String?`、`releaseURL: URL?`、`isChecking: Bool`
- [x] 1.2 實作 `checkForUpdates()` 方法：對 `https://api.github.com/repos/lindsayrain/good-timer/releases/latest` 發送 GET request，解析 JSON 取得 `tag_name` 和 `html_url`，strip 掉 `v` prefix 後與 `CFBundleShortVersionString` 做 semver 比對，網路錯誤時靜默失敗（App checks for new versions via GitHub Releases API）
- [x] 1.3 實作 24 小時節流邏輯：用 `UserDefaults` 儲存 `lastUpdateCheckDate`，`checkOnLaunch()` 方法只在距上次檢查超過 24 小時或從未檢查時才觸發（Automatic check is throttled to once per 24 hours）
- [x] 1.4 實作手動檢查方法 `manualCheck()`：無視節流限制立即執行檢查，完成後更新 `lastUpdateCheckDate`（Manual check bypasses throttle）

## 2. App 整合

- [x] 2.1 在 `GoodTimerApp.swift` 中建立 `UpdateChecker` 為 `@StateObject`，注入到 `MenuBarExtra` 的 `MenuBarView` 作為 `environmentObject`
- [x] 2.2 在 MenuBarExtra 的 `.task` modifier 中觸發 `UpdateChecker.checkOnLaunch()`

## 3. Menu Bar UI

- [x] 3.1 在 `MenuBarView.swift` 新增更新提示列：有新版時在「Open Main Window」按鈕下方顯示「v{version} available — Download」藍色文字，點擊用 `NSWorkspace.shared.open()` 開啟 release 頁面；無新版時隱藏（Menu bar popover displays update availability notification）
- [x] 3.2 在 `MenuBarView.swift` 新增「Check for Updates」手動按鈕，放在「Open Main Window」按鈕下方，點擊觸發 `manualCheck()`，檢查中 disable 按鈕，無新版時短暫顯示「Up to date」（Menu bar popover provides manual Check for Updates button）

## 4. 驗證

- [x] 4.1 編譯確認無錯誤，啟動 app 驗證版本檢查功能正常運作
