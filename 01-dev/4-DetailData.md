# 叮咚到號 — 詳細資料結構

## API Response Models（對應後端 JSON）

### Hospital（醫院）
**來源：** `GET /api/hospitals`

```json
{
  "hospitals": [
    {
      "code": "ntuh",
      "name": "台大醫院",
      "short_name": "台大",
      "city": "台北市",
      "district": "中正區",
      "level": "medical_center",
      "is_active": true,
      "adapter_name": "ntuh"
    }
  ]
}
```

```swift
struct Hospital: Codable, Identifiable {
    var id: String { code }
    let code: String          // "ntuh"，用於後續 API 呼叫
    let name: String          // "台大醫院"
    let shortName: String?    // "台大"
    let city: String          // "台北市"
    let district: String?     // "中正區"
    let level: String?        // "medical_center" / "regional"
    let isActive: Bool        // false = 暫時停止抓取

    enum CodingKeys: String, CodingKey {
        case code, name, city, district, level
        case shortName = "short_name"
        case isActive = "is_active"
    }
}
```

---

### ClinicProgress（看診進度）
**來源：** `GET /api/progress/{hospital_code}`

```json
{
  "hospital": "台大醫院",
  "code": "ntuh",
  "count": 2,
  "data": [
    {
      "department": "家庭醫學部",
      "doctor_name": "江建勰",
      "clinic_room": "04 診",
      "current_number": 40,
      "next_number": 41,
      "is_current_skipped": false,
      "is_next_skipped": false
    }
  ]
}
```

```swift
struct ProgressResponse: Codable {
    let hospital: String
    let code: String
    let count: Int
    let data: [ClinicProgress]
}

struct ClinicProgress: Codable, Identifiable {
    var id: String { "\(department)-\(doctorName)-\(clinicRoom)" }
    let department: String          // "家庭醫學部"
    let doctorName: String          // "江建勰"
    let clinicRoom: String          // "04 診"
    let currentNumber: Int          // 目前叫號
    let nextNumber: Int             // 下一號
    let isCurrentSkipped: Bool      // 目前號碼是否為過號
    let isNextSkipped: Bool         // 下一號是否為過號

    enum CodingKeys: String, CodingKey {
        case department
        case doctorName = "doctor_name"
        case clinicRoom = "clinic_room"
        case currentNumber = "current_number"
        case nextNumber = "next_number"
        case isCurrentSkipped = "is_current_skipped"
        case isNextSkipped = "is_next_skipped"
    }
}
```

---

### Department（科別）
**來源：** `GET /api/departments/{hospital_code}`

```json
{
  "departments": [
    {
      "name": "家庭醫學部",
      "category": "一般科"
    }
  ]
}
```

```swift
struct Department: Codable, Identifiable {
    var id: String { name }
    let name: String        // "家庭醫學部"
    let category: String?   // "一般科" / "外科" / "內科"…
}
```

---

### Doctor（醫師）
**來源：** `GET /api/doctors/{hospital_code}?department=家庭醫學部`

```json
{
  "doctors": [
    {
      "name": "江建勰",
      "department": "家庭醫學部",
      "title": "主治醫師",
      "specialty": "一般內科、預防醫學"
    }
  ]
}
```

```swift
struct Doctor: Codable, Identifiable {
    var id: String { "\(department)-\(name)" }
    let name: String
    let department: String
    let title: String?      // "主治醫師" / "教授"
    let specialty: String?  // 專長描述
}
```

---

### TrackStart Request / Response
**來源：** `POST /api/track/start`

```json
// Request Body
{
  "guest_id": "g_abc123_xyz",
  "hospital_code": "ntuh",
  "department": "家庭醫學部",
  "doctor_name": "江建勰",
  "clinic_room": "04 診",
  "session": null,
  "user_number": 55
}

// Response
{
  "ok": true,
  "track_id": 1234
}
```

```swift
struct TrackStartRequest: Encodable {
    let guestId: String
    let hospitalCode: String
    let department: String
    let doctorName: String
    let clinicRoom: String
    let session: String?
    let userNumber: Int         // 0 = 僅追蹤，不設掛號號碼

    enum CodingKeys: String, CodingKey {
        case guestId = "guest_id"
        case hospitalCode = "hospital_code"
        case department
        case doctorName = "doctor_name"
        case clinicRoom = "clinic_room"
        case session
        case userNumber = "user_number"
    }
}

struct TrackStartResponse: Codable {
    let ok: Bool
    let trackId: Int?

    enum CodingKeys: String, CodingKey {
        case ok
        case trackId = "track_id"
    }
}
```

---

## 本地資料結構（App 內部狀態）

### TrackingTask（追蹤任務 — 本地）

App 本地管理追蹤狀態，不依賴後端保持連線。

```swift
struct TrackingTask: Codable, Identifiable {
    let id: UUID                        // 本地唯一 ID
    var dbId: Int?                      // 後端回傳的 track_id（用於 stop 呼叫）

    // 選擇的醫師資訊
    let hospitalCode: String            // "ntuh"
    let hospitalName: String            // "台大醫院"
    let department: String              // "家庭醫學部"
    let doctorName: String              // "江建勰"
    let clinicRoom: String              // "04 診"

    // 追蹤參數
    let userNumber: Int?                // 使用者掛號號碼，nil = 僅追蹤
    let threshold: Int                  // 差幾號通知（預設 5）

    // 即時狀態（更新時覆寫）
    var currentNumber: Int             // 最新叫號號碼
    var lastUpdated: Date              // 最後成功更新時間
    var status: TrackingStatus         // 追蹤狀態

    // 通知計數（過號提醒用）
    var skippedReminderCount: Int = 0
}

enum TrackingStatus: String, Codable {
    case active       // 追蹤中
    case notified     // 已通知輪到
    case skipped      // 已過號
    case finished     // 看診結束（醫師下診）
    case cancelled    // 使用者主動停止
}
```

**儲存方式：** JSON 序列化後存入 `UserDefaults`，key = `"tracking_tasks"`

---

### AppSettings（使用者設定）

```swift
struct AppSettings: Codable {
    var notifyThreshold: Int = 5        // 差幾號發通知（1-20）
    var notifyMode: NotifyMode = .light // 通知頻率
    var backgroundRefreshEnabled: Bool = true
    var guestId: String                 // UUID，儲存於 Keychain
}

enum NotifyMode: String, Codable, CaseIterable {
    case light = "light"    // 只在 10、5、3、1、0 號時通知（預設）
    case normal = "normal"  // 每次號碼更新都通知
    case final_ = "final"   // 只在最後 3 號通知
    
    var displayName: String {
        switch self {
        case .light:  return "重要時機提醒"
        case .normal: return "每次更新提醒"
        case .final_: return "輪到時才提醒"
        }
    }
}
```

---

## 通知內容規格

### 通知類型與觸發條件

| 類型 | 觸發條件 | 標題 | 內容 |
|------|----------|------|------|
| 進度更新 | `remaining` 符合 threshold 且在 lightMode 觸發點 | 「叮咚到號」| 「江建勰 04診：還差 N 號」|
| 輪到了 | `currentNumber == userNumber` | 「輪到您了！」| 「江建勰 04診 現在叫 #55，請前往候診」|
| 過號 | `currentNumber > userNumber` | 「⚠️ 可能過號」| 「您是 55 號，目前叫 58 號，請洽詢護理站」|
| 看診結束 | API 找不到此醫師資料 | 「看診已結束」| 「江建勰 04診 今日看診已結束」|

### Light Mode 觸發點（`remaining` 值）
`remaining = userNumber - currentNumber`

觸發：remaining ∈ {10, 5, 3, 2, 1, 0}

---

## API Client 規格

### 基礎設定

```swift
// APIClient.swift
let baseURL = "https://dd.dl-app.com"
let timeoutInterval: TimeInterval = 15
// 無需 Authorization header（後端未啟用 API token）
```

### 錯誤處理

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case serverError(statusCode: Int)
    case decodingError(Error)
    case offline

    var errorDescription: String? {
        switch self {
        case .serverError(let code): return "伺服器錯誤（\(code)）"
        case .offline:               return "網路連線中斷，顯示最後資料"
        case .decodingError:         return "資料格式錯誤，請稍後再試"
        default:                     return "查詢失敗，請稍後再試"
        }
    }
}
```

### Retry 策略

- 一般查詢：失敗後 3 秒 retry，最多 2 次
- 背景輪詢：失敗不 retry，等下一個排程週期
- Rate limit（429）：等待 60 秒後 retry

---

## 地區分類（醫院列表分組）

```swift
enum HospitalArea: String, CaseIterable {
    case taipei     = "台北市"
    case newTaipei  = "新北市"
    case keelung    = "基隆"
    case taoyuan    = "桃園"
    case taichung   = "台中"
    case yunjiaNan  = "雲嘉南"
    case kaohsiung  = "高雄"
    case other      = "其他"
}
```

**分類規則**（對應後端 hospital.js groupByArea）：
- 台北市：台大、三軍總、台北榮總、台北長庚、國泰、馬偕(台北)、新光、萬芳、振興、台大癌醫、台大兒童
- 新北市：亞東、慈濟、輔大、臺北醫院
- 桃園：林口長庚、桃園長庚
- 台中：台中榮總
- 高雄：高雄長庚

---

## Widget 資料結構

```swift
// WidgetKit Timeline Entry
struct TrackingWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [TrackingWidgetData]    // 最多 3 筆
    let isPlaceholder: Bool
}

struct TrackingWidgetData {
    let doctorName: String      // "江建勰"
    let clinicRoom: String      // "04 診"
    let currentNumber: Int      // 40
    let userNumber: Int?        // 55（無掛號號碼則 nil）
    let remaining: Int?         // 15（nil = 未設掛號號碼）
    let status: TrackingStatus
    let updatedAt: Date
}
```

**Widget 刷新頻率：**
- 追蹤中：每 15 分鐘（WidgetKit 限制，實際由系統決定）
- 無追蹤任務：顯示靜態空白狀態，不刷新

---

## Keychain 儲存規格

| Key | 值 | 說明 |
|-----|----|------|
| `com.ajz.dingdong.guestId` | UUID String `"g_xxxx_yyyy"` | 匿名用戶識別碼，對應後端 guest_id |

格式與後端 web 版一致：`"g_" + timestamp_base36 + "_" + random_6chars`

---

## UserDefaults 儲存規格

| Key | 型別 | 預設值 | 說明 |
|-----|------|--------|------|
| `tracking_tasks` | Data (JSON) | `[]` | TrackingTask 陣列 |
| `notify_threshold` | Int | `5` | 提醒閾值 |
| `notify_mode` | String | `"light"` | 通知模式 |
| `hospitals_cache` | Data (JSON) | nil | 醫院列表快取 |
| `hospitals_cache_date` | Date | nil | 快取建立時間（24 小時過期）|
| `onboarding_done` | Bool | false | 是否已完成首次引導 |
