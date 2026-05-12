import SwiftUI

struct StopFeedbackSheet: View {
    let task: TrackingTask
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.appBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            Text("停止追蹤")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.bottom, 4)

            Text("\(task.doctorName) · \(task.clinicRoom)")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.bottom, 24)

            VStack(spacing: 10) {
                reasonButton(
                    icon: "checkmark.circle.fill",
                    label: "已成功看診",
                    reason: "arrived",
                    color: Color.appGreen
                )
                reasonButton(
                    icon: "arrow.forward.circle.fill",
                    label: "號碼已過",
                    reason: "passed",
                    color: Color.appUrgency
                )
                reasonButton(
                    icon: "xmark.circle.fill",
                    label: "放棄掛號",
                    reason: "cancelled",
                    color: Color.appTextSecondary
                )
            }
            .padding(.horizontal, 20)

            Button {
                dismiss()
            } label: {
                Text("取消")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .background(Color.appBackground)
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.hidden)
    }

    private func reasonButton(icon: String, label: String, reason: String, color: Color) -> some View {
        Button {
            onConfirm(reason)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }
            .padding(16)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
