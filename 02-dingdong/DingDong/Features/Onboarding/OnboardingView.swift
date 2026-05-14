import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @EnvironmentObject var notificationService: NotificationService
    @State private var page = 0

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            TabView(selection: $page) {
                welcomePage.tag(0)
                notificationPage.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: page)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(
                        colors: [Color.appAccent, Color.appAccentD],
                        startPoint: .top, endPoint: .bottom))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.appAccentDD.opacity(0.8), radius: 0, x: 0, y: 6)
                Image(systemName: "bell.fill")
                    .font(.system(size: 52, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 36)

            Text("叮咚到號")
                .font(.system(size: 36, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color.appInk)
                .padding(.bottom, 10)

            Text("不用守在醫院\n叫到號立刻通知您")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.appInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 44)

            VStack(alignment: .leading, spacing: 20) {
                stepRow(number: "1", text: "選擇您要去的醫院")
                stepRow(number: "2", text: "選科別與醫師")
                stepRow(number: "3", text: "輸入您的候診號碼")
                stepRow(number: "4", text: "叫到號立刻通知")
            }
            .padding(.horizontal, 40)

            Spacer()

            SimplePrimaryButton(title: "下一步") {
                withAnimation { page = 1 }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 56)
        }
    }

    private var notificationPage: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.appAccentS)
                    .frame(width: 140, height: 140)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(Color.appAccent)
            }
            .padding(.bottom, 36)

            Text("開啟通知")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Color.appInk)
                .padding(.bottom, 10)

            Text("叫到號時需要傳送通知給您\n請允許叮咚到號傳送通知")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            Spacer()

            VStack(spacing: 12) {
                SimplePrimaryButton(title: "允許通知") {
                    Task {
                        await notificationService.requestAuthorization()
                        onComplete()
                    }
                }
                Button { onComplete() } label: {
                    Text("稍後再說")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appInkSoft)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 56)
        }
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.appAccent)
                .clipShape(Circle())
                .shadow(color: Color.appAccentD, radius: 0, x: 0, y: 2)
            Text(text)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.appInk)
        }
    }
}
