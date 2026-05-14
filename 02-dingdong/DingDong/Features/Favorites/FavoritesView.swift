import SwiftUI

struct HistoryView: View {
    @State private var records: [TrackingRecord] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("我的看診紀錄")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .onAppear { loadRecords() }
    }

    private func loadRecords() {
        records = PersistenceService.shared.trackingHistory.reversed()
    }

    // MARK: - List

    private var recordList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(records) { record in
                    recordCard(record)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func recordCard(_ record: TrackingRecord) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(record.doctorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(record.hospitalName) · \(record.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
                Text(record.date, style: .date)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.6))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(reasonLabel(record.endReason))
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(reasonColor(record.endReason).opacity(0.12))
                    .foregroundStyle(reasonColor(record.endReason))
                    .clipShape(Capsule())
                if let userNumber = record.userNumber {
                    Text("掛號 #\(userNumber)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                }
            }
        }
        .padding(14)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }

    private func reasonLabel(_ reason: String) -> String {
        switch reason {
        case "notified":  return "已叫號"
        case "finished":  return "診已結束"
        case "skipped":   return "已過號"
        case "cancelled": return "已取消"
        default:          return "已結束"
        }
    }

    private func reasonColor(_ reason: String) -> Color {
        switch reason {
        case "notified": return Color.appGreen
        case "skipped":  return Color.appUrgency
        default:         return Color.appTextSecondary
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Color.appGreen.opacity(0.25))
            VStack(spacing: 8) {
                Text("尚無看診紀錄")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("完成追蹤後，紀錄會自動儲存在這裡")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
    }
}
