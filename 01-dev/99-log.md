# 叮咚到號 — 開發日誌

## 2026-05-12 — 專案啟動

### 完成事項
- 探索網站 https://dd.dl-app.com 的完整操作流程
- 分析後端原始碼 (`dindon-web/`)，確認可用 API endpoints
- 確認後端已有完整 REST API，iOS App 可直接呼叫，無需建立 proxy
- 填寫完整開發文件（PRD、User Flow、Tech Stack、Detail Data）

### 關鍵發現
- 後端支援 **29 間**醫院（比網站首頁顯示的 5 間多很多）
- API `/api/progress/{code}` 回傳完整科別 + 醫師 + 即時號碼，不需要模擬網頁操作
- 後端已有 Web Push 基礎設施（VAPID），但 iOS 需要 APNs，MVP 先用本地通知
- 追蹤邏輯全在前端（每 30 秒輪詢），後端 `/api/track/start` 只做分析記錄用
- 後端使用 `guest_id` 識別匿名用戶（格式：`g_{timestamp36}_{random6}`），Keychain 存儲

### 確認的技術決策
- SwiftUI + iOS 16+ + 零第三方依賴
- 本地通知（UNUserNotificationCenter）作為 MVP 通知方案
- BGAppRefreshTask 實現背景輪詢
- MVVM 架構，每個 Feature 資料夾含 View + ViewModel
- Widget Target（WidgetKit）從一開始就建立

### 待辦
- [ ] 建立 Xcode 專案（Bundle ID: com.ajz.dingdong）
- [ ] 實作 APIClient + 所有 Endpoint
- [ ] 實作 HospitalListView + 搜尋
- [ ] 實作 DepartmentListView + DoctorListView
- [ ] 實作 TrackingService + 本地通知
- [ ] 實作 BackgroundService（BGAppRefreshTask）
- [ ] 實作 Widget
- [ ] 測試所有 API endpoints（正式環境）

---

## 2026-05-14 — 長輩版設計系統全面導入

### 完成事項
- 全面套用 https://dd.dl-app.com/simple 的長輩版設計語言（暖奶油底 / 橘色 CTA / 大字級 / 立體 3D 按鈕）
- Color+App.swift 重寫色票系統（appBg / appAccent / appInk / appOk 等 25+ token）
- 新增 SimpleStyles.swift 共用元件庫（SimpleScreen / SimpleTopBar / SimpleStepTitle / SimpleRegionTabs / SimpleTwoColGrid / SimpleGridCard / SimplePrimaryButton / SimpleSecondaryButton / SimpleLiveDot / simpleCard modifier）
- 4 步流程全部重寫：
  - Step 1 HospitalListView (HospitalPicker 重寫：北/中/南 tabs + 兩欄 grid + pickCount ⭐)
  - Step 2 DepartmentListView (兩欄科別卡 + pickCount)
  - Step 3 DoctorListView (兩欄醫師卡 + 「目前看到 N 號」橘框 + 休診頁)
  - Step 4 TrackingSetupView (上方 info 卡 + 自製 4×3 鍵盤)
- HomeView 重寫：橘色立體 CTA、新追蹤卡 TrackingCardView（左資料右橘框，4 狀態色）
- 新增 TrackingDetailView：info-hero + 雙 stat 卡 + 4 步驟 progress + CTA + 追加/停止
- OnboardingView / SettingsView / HistoryView / PrivacyPolicyView / StopFeedbackSheet / AddFavoriteBrowserSheet 全套新風格
- ContentView TabBar tint=appAccent，UITabBarAppearance 暖底
- PersistenceService 新增 pickCount / bumpPick API（hospital/dept/doctor 常用排序）
- 刪除舊檔：DoctorProgressCard.swift、HospitalRowView.swift（被 SimpleGridCard 取代）
- View+Modifiers.swift 清空（modifier 集中到 SimpleStyles.swift）

### 驗證
- xcodegen generate ✓
- xcodebuild DingDong target ✓ BUILD SUCCEEDED
- xcodebuild DingDongWidget target ✓ BUILD SUCCEEDED

### 待辦
- [ ] 模擬器跑 app 視覺確認
- [ ] iOS 暗黑模式（目前色票都是固定值）
- [ ] 常用醫師無出診的標示

<!-- 新增記錄請往下加，格式：
## YYYY-MM-DD — 標題
### 完成事項
### 問題與決策
### 待辦
-->
