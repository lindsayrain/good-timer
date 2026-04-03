# Good Timer

<img src="icon.png" width="128" alt="Good Timer Icon" />

一款 macOS 計時器應用程式，以復古的火車站翻牌時鐘為設計靈感，提供流暢的倒數與正數計時體驗。

![Good Timer 預覽](preview.png)

---

## 功能特色

- **翻牌時鐘動畫**：採用雙葉片機制，搭配 Chakra Petch Bold 切角字形，忠實重現台灣鐵路局機械翻牌顯示器的視覺效果
- **倒數計時 / 正數計時**：支援兩種計時模式，切換自如
- **快速預設時間**：提供 5 秒、5、10、15、25、45 分鐘等常用快選，一鍵設定
- **計時結束提醒**：倒數歸零時發出「叮叮叮」三聲提示音
- **深色 / 淺色主題**：右上角可一鍵切換，適應不同使用情境
- **進度條顯示**：視覺化呈現計時進度
- **小計時模式**：可收起為精簡視圖，不佔用桌面空間

---

## 下載安裝

**[⬇ 下載 GoodTimer-1.0.0.dmg](https://github.com/lindsayrain/good-timer/releases/download/v1.0.0/GoodTimer-1.0.0.dmg)**

1. 下載 DMG 並開啟
2. 將 `GoodTimer.app` 拖曳至 Applications 資料夾
3. 首次開啟若出現安全性提示，前往「系統設定 > 隱私權與安全性」點選「仍要開啟」

所有版本：[Releases](https://github.com/lindsayrain/good-timer/releases)

---

## 系統需求

- macOS 13 Ventura 以上

---

## 從原始碼執行

```bash
git clone https://github.com/lindsayrain/good-timer.git
cd good-timer
swift run
```

---

## 操作說明

| 操作 | 說明 |
|------|------|
| **SET TIME** | 手動輸入計時時間（時 / 分 / 秒） |
| **START / PAUSE** | 開始或暫停計時 |
| **RESET** | 重設計時器 |
| **快選時間** | 點擊下方分鐘數快速設定 |
| **COUNTDOWN / COUNT UP** | 切換倒數或正數模式 |
| ☀ / 🌙 | 切換深色 / 淺色介面主題 |

---

## 技術架構

- **SwiftUI** — 原生 macOS 介面框架
- **Swift Package Manager** — 套件管理
- **rotation3DEffect** — 翻牌動畫（雙葉片同步）
- **AppTheme** 結構 — 統一管理深色 / 淺色主題色票
