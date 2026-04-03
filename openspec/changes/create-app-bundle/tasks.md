## 1. 產生 App Icon

- [x] 1.1 建立 `generate-icon.swift`：icon 以 Swift CoreGraphics 腳本程式化產生，實作 app icon uses flip-card visual design — 深色背景（`#1A1A1F`）圓角卡片、水平中央縫隙、上下各顯示白色粗體「0」
- [x] 1.2 腳本輸出 10 種標準尺寸 PNG（16, 32, 64, 128, 256, 512, 1024 px 含 @2x）至 `AppIcon.iconset/` 目錄，確認 icon renders at all required sizes
- [x] 1.3 執行 `iconutil -c icns AppIcon.iconset` 產生 `AppIcon.icns`，確認 icon visual matches flip-card design

## 2. 建立 Info.plist（版本號單一來源）

- [x] 2.1 建立 `Info.plist` 實作 Info.plist contains required metadata：設定 `CFBundleIdentifier: com.goodtimer.app`、`CFBundleName: GoodTimer`、`CFBundleExecutable: GoodTimer`、`LSMinimumSystemVersion: 13.0`、`CFBundleShortVersionString: 1.0.0`、`NSHighResolutionCapable: true`、`CFBundleIconFile: AppIcon`；version is managed from a single source — 版本號僅在此定義

## 3. 建立打包腳本（.app bundle 手動組裝，不依賴 Xcode）

- [x] 3.1 建立 `package.sh`：執行 `swift build -c release` 產生 release binary；若 `AppIcon.icns` 不存在則先執行 `generate-icon.swift`
- [x] 3.2 `package.sh` 中組裝 app bundle has valid macOS structure：建立 `GoodTimer.app/Contents/MacOS/`、`Contents/Resources/`，複製 binary、`AppIcon.icns`、`Info.plist`
- [x] 3.3 `package.sh` 中用 `/usr/libexec/PlistBuddy` 從 `Info.plist` 讀取版本號，實作 version is managed from a single source
- [x] 3.4 `package.sh` 中以 `hdiutil` 製作 DMG（UDZO 壓縮格式）— DMG 以 hdiutil 製作，版本號從 Info.plist 讀取 — DMG 內含 `GoodTimer.app` 與指向 `/Applications` 的 symlink，實作 DMG contains app and Applications symlink；輸出為 `GoodTimer-<version>.dmg`
- [x] 3.5 `package.sh` 中加入：若同版本 DMG 已存在則先刪除，實作 package.sh produces a versioned DMG in one command
- [x] 3.6 賦予 `package.sh` 執行權限（`chmod +x`）
- [x] 3.7 不做 ad-hoc code signing（個人自用，本機 build 無 quarantine）

## 4. 驗收

- [x] 4.1 執行 `./package.sh`，確認專案根目錄出現 `GoodTimer-1.0.0.dmg`
- [x] 4.2 開啟 DMG，確認 `GoodTimer.app` 與 `Applications` 捷徑均顯示正確
- [ ] 4.3 拖曳安裝後確認 App 可正常啟動、Spotlight 可搜尋、Dock 顯示翻牌 icon
- [x] 4.4 修改 `Info.plist` 版本號為 `1.1.0`，重新執行 `./package.sh`，確認產出 `GoodTimer-1.1.0.dmg`
