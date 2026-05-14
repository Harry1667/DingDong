import SwiftUI

struct StopFeedbackSheet: View {
    let task: TrackingTask
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.appBorder)
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 18)

            Text("停止追蹤")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appInk)
                .padding(.bottom, 4)

            Text("\(task.doctorName) · \(task.clinicRoom)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appInkSoft)
                .padding(.bottom, 20)

            VStack(spacing: 10) {
                reasonButton(icon: "checkmark.circle.fill", label: "已成功看診",
                             reason: "arrived", color: .appOk)
                reasonButton(icon: "arrow.forward.circle.fill", label: "號碼已過",
                             reason: "passed", color: .appAccent)
                reasonButton(icon: "xmark.circle.fill", label: "放棄掛號",
                             reason: "cancelled", color: .appInk2)
            }
            .padding(.horizontal, 20)

            Button {
                dismiss()
            } label: {
                Text("取消")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.appInkSoft)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .background(Color.appBg)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.hidden)
    }

    private func reasonButton(icon: String, label: String, reason: String, color: Color) -> some View {
        Button {
            onConfirm(reason)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color.appInk)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.appInk3.opacity(0.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 16)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
