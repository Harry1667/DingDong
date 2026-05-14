import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    policySection(
                        title: "我們收集哪些資料",
                        body: "本應用程式為提供候診追蹤服務，會收集以下資料：\n\n• 匿名訪客識別碼（隨機產生，不含個人資訊）\n• 您主動輸入的掛號號碼與選擇的醫師資訊\n• 裝置 APNs 推播識別碼（僅用於傳送通知）\n\n我們不收集您的姓名、身分證字號、電話或任何可識別個人身分的資料。"
                    )
                    policySection(
                        title: "資料用途",
                        body: "所收集的資料僅用於：\n\n• 向後端伺服器查詢即時叫號進度\n• 在輪到您時發送推播通知\n• 改善應用程式體驗"
                    )
                    policySection(
                        title: "資料儲存",
                        body: "您的追蹤設定與偏好儲存於本機裝置。匿名識別碼與追蹤任務狀態會同步至本應用程式的後端伺服器，並在任務結束後自動清除。我們不會將您的資料出售或提供予第三方。"
                    )
                    policySection(
                        title: "推播通知",
                        body: "應用程式使用 Apple 推播通知服務（APNs）傳送叫號提醒。推播識別碼僅傳送給本應用程式後端，不與任何第三方廣告平台共享。您可隨時在 iOS 設定中關閉通知。"
                    )
                    policySection(
                        title: "資料查詢與刪除",
                        body: "由於本應用程式不收集可識別個人身分的資料，無法提供個人資料查詢服務。如需完全清除裝置上的所有資料，可在「設定」頁面執行「清除所有追蹤任務」，並刪除應用程式。"
                    )
                    policySection(
                        title: "聯絡我們",
                        body: "如對本隱私政策有任何疑問，請透過設定頁面的「意見回饋」聯絡我們。"
                    )

                    Text("最後更新：2026 年 5 月")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .navigationTitle("隱私政策")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text(body)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }
}
