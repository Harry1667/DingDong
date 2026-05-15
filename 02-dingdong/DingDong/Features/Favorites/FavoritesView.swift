import SwiftUI

struct HistoryView: View {
    @State private var records: [TrackingRecord] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    if records.isEmpty {
                        emptyState
                    } else {
                        recordList
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear { loadRecords() }
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                Text("叮咚到號")
                    .font(.system(size: 18, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.appInk)
                Spacer()
            }
            .frame(height: 44)
            Text("我的看診紀錄")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.3)
                .foregroundStyle(Color.appInk)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private func loadRecords() {
        records = PersistenceService.shared.trackingHistory.reversed()
    }

    private var recordList: some View {
        List {
            ForEach(records) { record in
                recordCard(record)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteRecord(record)
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.appBg)
    }

    private func deleteRecord(_ record: TrackingRecord) {
        var all = PersistenceService.shared.trackingHistory
        all.removeAll { $0.id == record.id }
        PersistenceService.shared.trackingHistory = all
        withAnimation { records.removeAll { $0.id == record.id } }
    }

    private func recordCard(_ record: TrackingRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.doctorName)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color.appInk)
                Text("\(record.hospitalName) · \(record.clinicRoom)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
                Text(record.date, style: .date)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.appInk3)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(reasonLabel(record.endReason))
                    .font(.system(size: 12, weight: .heavy))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(reasonColor(record.endReason).opacity(0.15))
                    .foregroundStyle(reasonColor(record.endReason))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(reasonColor(record.endReason).opacity(0.5), lineWidth: 1.5)
                    )
                if let userNumber = record.userNumber {
                    Text("掛號 #\(userNumber)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.appInk3)
                }
            }
        }
        .padding(14)
        .simpleCard(radius: 16)
    }

    private func reasonLabel(_ reason: String) -> String {
        switch reason {
        case "notified", "arrived": return "已叫號"
        case "finished":            return "診已結束"
        case "skipped", "passed":   return "已過號"
        case "cancelled":           return "已取消"
        default:                    return "已結束"
        }
    }

    private func reasonColor(_ reason: String) -> Color {
        switch reason {
        case "notified", "arrived": return .appOk
        case "skipped", "passed":   return .appDanger
        default:                    return .appInk2
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle().fill(Color.appAccentS).frame(width: 110, height: 110)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 54))
                    .foregroundStyle(Color.appAccent.opacity(0.7))
            }
            VStack(spacing: 8) {
                Text("尚無看診紀錄")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appInk)
                Text("完成追蹤後，紀錄會自動儲存在這裡")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
    }
}
