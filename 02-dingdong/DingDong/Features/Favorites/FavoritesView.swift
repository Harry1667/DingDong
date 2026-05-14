import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoriteService: FavoriteService

    @State private var loadingFavoriteId: UUID?
    @State private var quickTrackItem: QuickTrackItem?
    @State private var noDataDoctorName: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                if favoriteService.favorites.isEmpty {
                    emptyState
                } else {
                    favoriteList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("AppIconNav")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("常用醫師")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.appGreen)
                    }
                }
            }
        }
        .sheet(item: $quickTrackItem) { item in
            TrackingSetupView(hospital: item.hospital, progress: item.progress)
        }
        .alert("今日無出診資料", isPresented: Binding(
            get: { noDataDoctorName != nil },
            set: { if !$0 { noDataDoctorName = nil } }
        )) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("\(noDataDoctorName ?? "") 今日無看診資料，請明日再試")
        }
    }

    // MARK: - Favorite List

    private var favoriteList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("長按卡片可取消常用")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                    .padding(.horizontal, 4)

                ForEach(favoriteService.favorites) { fav in
                    favoriteCard(fav)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func favoriteCard(_ fav: FavoriteDoctor) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fav.doctorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(fav.hospitalName) · \(fav.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
                Text(fav.department)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }
            Spacer()
            if loadingFavoriteId == fav.id {
                ProgressView().tint(Color.appGreen)
            } else {
                Button {
                    Task { await quickTrack(fav) }
                } label: {
                    Text("快速追蹤")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appGreenLight)
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
        .contextMenu {
            Button(role: .destructive) {
                favoriteService.remove(fav)
            } label: {
                Label("移除常用", systemImage: "star.slash")
            }
        }
    }

    private func quickTrack(_ fav: FavoriteDoctor) async {
        print("[Favorites] quickTrack: \(fav.doctorName)")
        loadingFavoriteId = fav.id
        defer { loadingFavoriteId = nil }
        guard let response = try? await HospitalService.shared.fetchProgress(hospitalCode: fav.hospitalCode) else {
            print("[Favorites] fetchProgress 失敗: \(fav.hospitalCode)")
            noDataDoctorName = fav.doctorName
            return
        }
        guard let match = response.data.first(where: {
            $0.doctorName == fav.doctorName && $0.clinicRoom == fav.clinicRoom
        }) else {
            print("[Favorites] 找不到 \(fav.doctorName) 的今日資料")
            noDataDoctorName = fav.doctorName
            return
        }
        let hospital = Hospital(code: fav.hospitalCode, name: fav.hospitalName)
        quickTrackItem = QuickTrackItem(hospital: hospital, progress: match)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "star.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.appGreen.opacity(0.25))
                VStack(spacing: 8) {
                    Text("尚無常用醫師")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("在醫師清單頁面點擊星號\n即可加入常用")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            Spacer()
        }
        .padding()
    }
}

private struct QuickTrackItem: Identifiable {
    let id = UUID()
    let hospital: Hospital
    let progress: ClinicProgress
}
