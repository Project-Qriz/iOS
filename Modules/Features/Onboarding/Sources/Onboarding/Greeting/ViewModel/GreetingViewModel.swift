import Foundation
import QRIZUtils
import Network

@MainActor
final class GreetingViewModel: ObservableObject {

    // MARK: - Properties

    @Published var nickname: String = ""

    private let onNavigate: () -> Void
    private let userInfoService: UserInfoService
    private let userInfo: UserInfoManager
    private var timer: Timer?

    // MARK: - Initialization

    init(userInfoService: UserInfoService, onNavigate: @escaping () -> Void, userInfo: UserInfoManager) {
        self.userInfoService = userInfoService
        self.onNavigate = onNavigate
        self.userInfo = userInfo
    }

    deinit {
        MainActor.assumeIsolated {
            timer?.invalidate()
        }
    }

    // MARK: - Methods

    func onAppear() {
        nickname = userInfo.name
        Task { await fetchUserInfo() }
        startTimer()
    }

    // MARK: - Private

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onNavigate()
            }
        }
    }

    private func fetchUserInfo() async {
        guard let response = try? await userInfoService.getUserInfo() else { return }
        let user = response.data
        userInfo.update(
            name: user.name,
            userId: user.userId,
            email: user.email,
            previewTestStatus: user.previewTestStatus,
            provider: user.provider
        )
        nickname = user.name
    }
}
