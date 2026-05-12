import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @EnvironmentObject var notificationService: NotificationService
    @State private var page = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            TabView(selection: $page) {
                welcomePage.tag(0)
                notificationPage.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: page)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            RoundedRectangle(cornerRadius: 28)
                .fill(Color.appGreen)
                .frame(width: 108, height: 108)
                .overlay(
                    Image(systemName: "bell.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                )
                .padding(.bottom, 32)

            Text("叮咚到號")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.bottom, 10)

            Text("不用守在醫院\n叫到號立刻通知您")
                .font(.system(size: 17))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 48)

            VStack(alignment: .leading, spacing: 22) {
                stepRow(number: "1", icon: "cross.case.fill",   text: "選擇醫院和醫師")
                stepRow(number: "2", icon: "number.circle.fill", text: "輸入您的掛號號碼")
                stepRow(number: "3", icon: "bell.badge.fill",    text: "輪到時立即收到通知")
            }
            .padding(.horizontal, 48)

            Spacer()

            Button {
                withAnimation { page = 1 }
            } label: {
                Text("下一步")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 56)
        }
    }

    private var notificationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.appGreen)
                .padding(.bottom, 32)

            Text("開啟通知")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.bottom, 10)

            Text("叫到號時需要傳送通知給您\n請允許叮咚到號傳送通知")
                .font(.system(size: 16))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task {
                        await notificationService.requestAuthorization()
                        onComplete()
                    }
                } label: {
                    Text("允許通知")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                Button { onComplete() } label: {
                    Text("稍後再說")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 56)
        }
    }

    private func stepRow(number: String, icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.appGreen)
                .frame(width: 30)
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
