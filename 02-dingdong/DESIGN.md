# Design System — 叮咚到號

## Product Context
- **What this is:** 台灣醫院候診追蹤 iOS App，讓病患即時掌握看診進度，不用一直盯著診間
- **Who it's for:** 在台灣醫院候診的病患（全年齡）
- **Space/industry:** 醫療健康 / 候診管理
- **Project type:** Native iOS App (SwiftUI)

## Memorable Thing
「像鄰居藥局的手寫取號票——功能清楚，但你感覺到有人在乎你。」
清楚快速放心 + 有溫度的等待，兩個都要。

## Aesthetic Direction
- **Direction:** Warm Utilitarian（暖實用主義）
- **Decoration level:** minimal（字型與色彩做所有工作）
- **Mood:** 沉穩、有機、不像政府入口。讓候診這件焦慮的事情感覺被照顧到。
- **Anti-pattern:** 不做冷藍醫療風、不做霓虹綠、不做純白政府感

## Typography
- **Display / 號碼:** Noto Serif TC Bold 700 — 給號碼「儀式感」，沒有台灣醫療 app 這樣做
- **Body / UI:** Noto Sans TC Regular 400 / Medium 500 — 所有說明、標籤、導航
- **Data / Mono:** DM Mono Regular 400 — 時間戳、ticket 號碼、剩餘號數
- **Loading:** Google Fonts CDN（預覽用）；SwiftUI 使用 CTFontDescriptor 或 bundle 字型
- **Scale:**
  - hero-number: 88-120pt, Noto Serif TC Bold
  - title: 28pt, Noto Sans TC 600
  - headline: 17pt, Noto Sans TC 600
  - body: 15-16pt, Noto Sans TC 400
  - caption: 12-13pt, Noto Sans TC 400
  - mono-data: 11-13pt, DM Mono

## Color
- **Approach:** restrained（accent 是稀有且有意義的）
- **Background:** #F5F0E8 — 奶油米色，殺死醫療白，所有競品用純白
- **Surface（卡片）:** #FDFAF4 — 比底色更亮一點，靠暖色而非灰色製造層次
- **Primary text:** #1C1A16 — 帶暖底調的近黑，不是純 #000000
- **Secondary text:** #8C7E6A — 暖灰，不是冷灰 #999999
- **Accent / active:** #2D6A4F — 深森林綠，用於按鈕、active 指示點、CTA
- **Progress fill:** #3DAB7A — 中綠，用於進度條
- **Urgency（差 3 號以內）:** #E8A020 — 琥珀金；不是冷紅警告，傳遞「注意」不傳遞「恐慌」
- **Border:** rgba(28,26,22,0.08) — 極細暖色邊框
- **Shadow:** 0 2px 12px rgba(139,110,80,0.12) — 暖色陰影，不是冷灰陰影

## Spacing
- **Base unit:** 8px
- **Density:** comfortable
- **Scale:** 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48

## Layout
- **Approach:** grid-disciplined（卡片式，iOS 標準，用戶習慣）
- **Key rule:** 號碼是主角，佔畫面 30%，120pt，居中
- **Border radius:** sm=8px md=16px lg=24px full=9999px
- **Card style:** surface color + warm shadow，不用冷灰 border

## Motion
- **Approach:** intentional
- **Breathing（候診中）:** 背景極細微亮度呼吸，4 秒一週期，opacity 1.0 ↔ 0.94。生理研究：緩慢視覺節律降低焦慮
- **Number update:** 號碼更新時 0.3s ease-in-out transition，不硬切
- **Urgency transition:** 進入緊急狀態（差 3 號）顏色以 0.5s 過渡到琥珀金
- **Standard easing:** enter=easeOut exit=easeIn move=easeInOut
- **Duration:** micro=100ms short=200ms medium=350ms

## Decisions Log
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-05-13 | Noto Serif TC 作為號碼字體 | 無台灣醫療 app 用 Serif；儀式感 > 數位感；兩個獨立 AI 方向一致指向此 |
| 2026-05-13 | 奶油底 #F5F0E8 | 所有競品用純白；單一顏色決定脫離政府入口感 |
| 2026-05-13 | 琥珀金 #E8A020 做緊急色 | 降焦慮；台灣醫療 app 清一色用冷紅，此為差異化 |
| 2026-05-13 | 呼吸動畫 | 唯一動態元素，對應「有溫度的等待」；不是裝飾，是生理設計 |
