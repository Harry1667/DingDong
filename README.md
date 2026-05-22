# 叮咚到號

台灣醫院候診進度追蹤 iOS App — 掛完號自由離開，輪到你時推播提醒。

## 功能
- 瀏覽全台 29 家醫院（依地區分類，支援別名搜尋：三總、北榮、台大、長庚…）
- 輸入掛號號碼追蹤，或僅追蹤目前叫號進度
- 最多同時追蹤 3 位醫師，每 30 秒自動更新
- 剩餘 N 號時本地推播通知（N 可自訂，預設 5）
- 輪到時緊急通知（聲音 + 震動）；過號警示通知
- 背景持續監控（BGAppRefreshTask）
- 主畫面 Widget（小尺寸 1 筆 / 中尺寸最多 3 筆）

## 技術棧
- Swift / SwiftUI（iOS 16+）
- 後端：[api-dindon](https://github.com/Harry1667/api-dindon)（dd.dl-app.com）

## 相關
後端 API：[api-dindon](https://github.com/Harry1667/api-dindon)
