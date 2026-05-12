# 叮咚到號 — Tech Stack & 專案結構

## 技術選型

| 層次 | 技術 | 原因 |
|------|------|------|
| UI | SwiftUI | 原生 iOS，開發效率高，Widget/通知整合順暢 |
| 最低 iOS | 16.0 | BGTaskScheduler API 完整支援、Swift Concurrency (async/await) |
| 語言 | Swift 5.9+ | structured concurrency、macros |
| 網路 | URLSession (async/await) | 原生，不需要第三方依賴 |
| 本地儲存 | UserDefaults + Keychain | 設定用 UserDefaults，guest_id 用 Keychain |
| 通知 | UNUserNotificationCenter | 本地通知，不需後端 APNs（MVP） |
| 背景任務 | BGAppRefreshTask | iOS 背景輪詢 |
| Widget | WidgetKit | 主畫面 / 鎖定螢幕小工具 |
| 架構 | MVVM | SwiftUI 原生搭配，ViewModel 對應每個畫面 |
| 後端 | dd.dl-app.com (FastAPI) | 現有服務，不修改後端 |

**不使用第三方套件（MVP 階段）**，保持零依賴，方便 App Store 審核。

---

## 專案資料夾結構

```
DingDong/                              # Xcode 專案根目錄
│
├── DingDong/                          # 主 Target
│   │
│   ├── App/
│   │   ├── DingDongApp.swift          # @main 入口，AppDelegate 設定，BGTask 註冊
│   │   └── ContentView.swift          # TabView 根畫面（首頁 / 搜尋 / 設定）
│   │
│   ├── Core/
│   │   │
│   │   ├── Network/
│   │   │   ├── APIClient.swift        # URLSession 封裝，統一 base URL、header、error 處理
│   │   │   ├── APIEndpoints.swift     # 所有 endpoint 常數定義（enum）
│   │   │   └── NetworkError.swift     # 自訂 Error 型別（serverError / noData / decoding）
│   │   │
│   │   ├── Models/                    # Codable 資料模型（對應 API response）
│   │   │   ├── Hospital.swift         # 醫院資料（code, name, city, is_active）
│   │   │   ├── ClinicProgress.swift   # 看診進度（department, doctor_name, clinic_room, current_number…）
│   │   │   ├── Department.swift       # 科別（name, category）
│   │   │   ├── Doctor.swift           # 醫師（name, department, title）
│   │   │   └── TrackingTask.swift     # 本地追蹤任務（含 userNumber, threshold, status）
│   │   │
│   │   ├── Services/
│   │   │   ├── TrackingService.swift       # 追蹤任務管理（新增/停止/輪詢，最多 3 個）
│   │   │   ├── NotificationService.swift   # 通知排程、權限請求、通知內容組裝
│   │   │   ├── BackgroundService.swift     # BGAppRefreshTask 註冊與執行邏輯
│   │   │   ├── PersistenceService.swift    # UserDefaults 存讀設定；Keychain 存 guest_id
│   │   │   └── HospitalService.swift       # 醫院列表快取（記憶體 + UserDefaults，避免每次重抓）
│   │   │
│   │   └── Extensions/
│   │       ├── Color+App.swift             # App 自訂色票（主色、背景色）
│   │       ├── Date+Format.swift           # 時間格式化（「剛剛更新」「xx 秒前」）
│   │       └── View+Modifiers.swift        # 常用 ViewModifier（卡片樣式、載入中遮罩）
│   │
│   ├── Features/                      # 每個功能一個資料夾，各含 View + ViewModel
│   │   │
│   │   ├── Home/
│   │   │   ├── HomeView.swift              # 首頁：追蹤卡片列表 + 無追蹤時的引導入口
│   │   │   ├── TrackingCardView.swift      # 單一追蹤卡片元件（醫師/號碼/剩餘）
│   │   │   └── HomeViewModel.swift         # 首頁狀態管理（追蹤清單、刷新觸發）
│   │   │
│   │   ├── Hospital/
│   │   │   ├── HospitalListView.swift      # 依地區顯示醫院列表
│   │   │   ├── HospitalSearchView.swift    # 搜尋列 + 即時結果
│   │   │   ├── HospitalRowView.swift       # 單一醫院列表項目元件
│   │   │   └── HospitalViewModel.swift     # 醫院列表載入、地區分類、搜尋過濾
│   │   │
│   │   ├── Progress/
│   │   │   ├── DepartmentListView.swift    # 選定醫院後的科別列表（含醫師數量）
│   │   │   ├── DoctorListView.swift        # 選定科別後的醫師列表（含即時看診號）
│   │   │   ├── DoctorProgressCard.swift    # 醫師進度卡片元件（號碼大字顯示）
│   │   │   └── ProgressViewModel.swift     # 進度查詢（呼叫 /api/progress/{code}）、30 秒刷新
│   │   │
│   │   ├── Tracking/
│   │   │   ├── TrackingSetupView.swift     # 設定追蹤：輸入掛號號碼、選提醒閾值
│   │   │   ├── TrackingDetailView.swift    # 追蹤詳情：完整資訊、手動刷新、停止按鈕
│   │   │   └── TrackingViewModel.swift     # 追蹤建立/停止、號碼比對、通知觸發
│   │   │
│   │   └── Settings/
│   │       ├── SettingsView.swift          # 設定頁：通知閾值、背景刷新、關於 App
│   │       └── SettingsViewModel.swift     # 讀寫使用者設定
│   │
│   └── Resources/
│       ├── Assets.xcassets               # 圖示、顏色、圖片資源
│       ├── Info.plist                     # App 設定（BGModes、通知 usage description）
│       └── Localizable.strings            # 多語言字串（目前僅繁體中文）
│
├── DingDongWidget/                    # Widget Target
│   ├── TrackingWidget.swift           # Widget 主體（@main、Timeline Provider）
│   ├── TrackingWidgetView.swift       # Widget 畫面（小/中尺寸）
│   ├── TrackingWidgetEntry.swift      # Timeline Entry 資料結構
│   └── WidgetBundle.swift             # 多個 Widget 的集合入口
│
└── DingDongTests/                     # 單元測試 Target
    ├── APIClientTests.swift           # API 解析測試（mock response）
    ├── TrackingServiceTests.swift     # 追蹤邏輯測試（上限、重複、過號）
    └── NotificationTests.swift        # 通知觸發條件測試
```

---

## 後端 API 對應

| 功能 | Endpoint | 呼叫位置 |
|------|----------|----------|
| 醫院列表 | GET /api/hospitals | HospitalService（快取 24 小時）|
| 看診進度 | GET /api/progress/{code} | ProgressViewModel（每 30 秒）|
| 科別列表 | GET /api/departments/{code} | ProgressViewModel |
| 醫師列表 | GET /api/doctors/{code}?department= | ProgressViewModel |
| 搜尋醫院 | GET /api/search/hospital?q= | HospitalViewModel |
| 開始追蹤（記錄用）| POST /api/track/start | TrackingService |
| 停止追蹤（記錄用）| PUT /api/track/{id}/stop | TrackingService |

> `/api/track/start` 和 `/api/track/{id}/stop` 是後端分析用，iOS 追蹤的核心邏輯在本地 TrackingService，不依賴這兩個 API 的回應。

---

## 資料流

```
[API 回應] ──decode──► [Model struct] ──► [ViewModel @Published] ──► [SwiftUI View]
                                               │
                                               └──► [TrackingService] ──► [本地通知]
                                                           │
                                                    [BGAppRefreshTask] ──► 背景輪詢
```

---

## Info.plist 必要項目

```xml
<!-- 背景模式 -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>

<!-- BGTask 識別碼 -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.ajz.dingdong.refresh</string>
</array>

<!-- 通知說明 -->
<key>NSUserNotificationsUsageDescription</key>
<string>輪到您看診時，叮咚到號會即時通知您。</string>
```

---

## 建置環境

| 項目 | 規格 |
|------|------|
| Xcode | 15.0+ |
| Swift | 5.9+ |
| 最低部署目標 | iOS 16.0 |
| 第三方套件 | 無（零依賴）|
| 簽章 | com.ajz.dingdong（已在 App Store Connect 建立）|
