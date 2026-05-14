# 後端需求：iOS App APNs 推播支援

**日期：** 2026-05-13  
**請求方：** iOS App 開發  
**優先級：** 高

---

## 背景

叮咚到號 iOS App 目前透過每 30 秒 polling `/api/progress/{code}` 來自行判斷是否要推本地通知。這個做法有兩個問題：

1. App 必須一直在背景跑，被 iOS 系統殺掉就沒通知
2. 後端的 `check_and_notify()` Celery 任務已經有完整的通知判斷邏輯，App 等於在重複做同一件事

**目標：** 後端直接透過 APNs 推通知給 iOS App，App 不需要輪詢，完全關掉也能收到通知。

---

## 需要後端做的事（共 3 項）

---

### 1. 修改 `POST /api/track/start`，接受 `apns_token`

**現有 request body：**
```json
{
  "guest_id": "g_abc123",
  "hospital_code": "ntuh",
  "department": "內科",
  "doctor_name": "王小明",
  "clinic_room": "診間 03",
  "session": null,
  "user_number": 25
}
```

**新增一個欄位（選填）：**
```json
{
  "guest_id": "g_abc123",
  "hospital_code": "ntuh",
  "department": "內科",
  "doctor_name": "王小明",
  "clinic_room": "診間 03",
  "session": null,
  "user_number": 25,
  "apns_token": "abc123def456..."   // ← 新增，iOS device token，沒有就傳 null
}
```

**DB 變更：** `tracking_tasks` 表加一個欄位：
```sql
ALTER TABLE tracking_tasks
ADD COLUMN apns_token VARCHAR(200) NULL DEFAULT NULL;
```

---

### 2. 修改 `check_and_notify()` Celery 任務，加入 APNs 推送

現有任務在決定要通知時，只推 LINE。請在同一個地方加一路：**如果該任務有 `apns_token`，就同時發 APNs 推播**。

**通知時機不變**（沿用現有邏輯）：
- 差 N 號時（根據 threshold）
- 輪到號碼
- 過號
- 醫師已無看診

**APNs 推送實作：**

```python
import httpx
import jwt  # pip install PyJWT
import time

# 環境變數（見第 3 項）
APNS_KEY_ID       = os.environ["APNS_KEY_ID"]
APNS_TEAM_ID      = os.environ["APNS_TEAM_ID"]
APNS_BUNDLE_ID    = os.environ["APNS_BUNDLE_ID"]   # com.ajz.dingdong
APNS_PRIVATE_KEY  = os.environ["APNS_PRIVATE_KEY"]  # .p8 檔案內容（多行字串）
APNS_USE_SANDBOX  = os.environ.get("APNS_USE_SANDBOX", "false") == "true"

def _make_apns_jwt() -> str:
    """產生 APNs 認證用的 JWT（10 分鐘有效，可快取）"""
    payload = {
        "iss": APNS_TEAM_ID,
        "iat": int(time.time()),
    }
    headers = {
        "alg": "ES256",
        "kid": APNS_KEY_ID,
    }
    return jwt.encode(payload, APNS_PRIVATE_KEY, algorithm="ES256", headers=headers)


async def send_apns(device_token: str, title: str, body: str, data: dict = None):
    """發送 APNs 推播"""
    host = "api.sandbox.push.apple.com" if APNS_USE_SANDBOX else "api.push.apple.com"
    url = f"https://{host}/3/device/{device_token}"

    payload = {
        "aps": {
            "alert": {"title": title, "body": body},
            "sound": "default",
        }
    }
    if data:
        payload.update(data)

    headers = {
        "authorization": f"bearer {_make_apns_jwt()}",
        "apns-topic": APNS_BUNDLE_ID,
        "apns-push-type": "alert",
        "apns-priority": "10",
    }

    async with httpx.AsyncClient(http2=True) as client:
        resp = await client.post(url, json=payload, headers=headers)
        if resp.status_code == 410:
            # device token 已失效，從 DB 清除
            # tracking_tasks.apns_token = NULL WHERE apns_token = device_token
            pass
        return resp.status_code == 200
```

**在 `check_and_notify()` 裡，現有 LINE 推送的地方旁邊加：**

```python
# 原有 LINE 推送
if task.user_id:
    await line_service.push_message(task.user_id, message)

# 新增：APNs 推送
if task.apns_token:
    await send_apns(
        device_token=task.apns_token,
        title=apns_title,   # 例如 "叮咚到號"
        body=apns_body,     # 例如 "快到了！差 3 號，王小明醫師"
    )
```

各通知情境的文案建議：

| 情境 | title | body |
|------|-------|------|
| 差 N 號 | `叮咚到號` | `快到了！差 {N} 號，{doctor_name}` |
| 輪到 | `輪到您了 🔔` | `#{user_number} 號，{doctor_name} 請準備` |
| 過號 | `號碼已過` | `#{user_number} 號已過，{doctor_name}` |
| 醫師已無看診 | `診已結束` | `{doctor_name} 今日看診已結束` |

---

### 3. 新增環境變數

請在 `.env` / Docker 環境加入以下變數：

```bash
# APNs Token-based Auth (使用 .p8 金鑰，不用憑證)
APNS_KEY_ID=XXXXXXXXXX          # 10 碼，Apple Developer → Keys 頁面
APNS_TEAM_ID=XXXXXXXXXX         # 10 碼，Apple Developer → 右上角 Team ID
APNS_BUNDLE_ID=com.ajz.dingdong # iOS App 的 Bundle ID
APNS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
APNS_USE_SANDBOX=false          # 開發測試時設 true，正式上線設 false
```

---

## iOS 這邊會做什麼

App 取得 APNs device token 之後，會在呼叫 `POST /api/track/start` 時帶上 `apns_token`。後端存起來，之後就由後端負責推通知。

App 的 30 秒輪詢在確認後端推播正常後會移除，改為只在 App 開啟時做一次 UI 更新。

---

## 需要的 Apple 憑證取得方式

請告知 iOS 開發者，需要在 **Apple Developer Console** 完成以下步驟：

1. 登入 [developer.apple.com](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → **Keys**
3. 建立一個新 Key，勾選 **Apple Push Notifications service (APNs)**
4. 下載 `.p8` 檔案（只能下載一次）
5. 記下 **Key ID**（10 碼）和頁面右上角的 **Team ID**

這些資訊提供給後端開發者設定環境變數即可。

---

## 相依套件

後端需要安裝：
```
PyJWT>=2.8.0
httpx[http2]>=0.28.0   # httpx 應該已安裝，確認有 http2 extra
```

---

## 不影響現有功能

- LINE Bot 通知邏輯完全不變
- Web 版追蹤完全不變
- `apns_token` 欄位選填，無 token 的任務走原有邏輯
- 只有 iOS App 建立的追蹤任務才會帶 token

---

## 問題聯絡

如有問題請回覆此文件，或直接與 iOS 開發者確認。
