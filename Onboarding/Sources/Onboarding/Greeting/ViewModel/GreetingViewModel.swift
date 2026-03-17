import Foundation
import QRIZUtils
import Network

@MainActor
final class GreetingViewModel: ObservableObject {

    // MARK: - Properties

    @Published var nickname: String = ""

    private let onNavigate: () -> Void
    private let userInfoService: UserInfoService
    private var timer: Timer?

    // MARK: - Initializer

    init(userInfoService: UserInfoService, onNavigate: @escaping () -> Void) {
        self.userInfoService = userInfoService
        self.onNavigate = onNavigate
    }

    // MARK: - Methods

    func onAppear() {
        nickname = UserInfoManager.shared.name
        Task { await fetchUserInfo() }
        startTimer()
    }

    // MARK: - Private

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onNavigate()
                self?.timer?.invalidate()
            }
        }
    }

    private func fetchUserInfo() async {
        guard let response = try? await userInfoService.getUserInfo() else { return }
        let user = response.data
        UserInfoManager.shared.update(
            name: user.name,
            userId: user.userId,
            email: user.email,
            previewTestStatus: user.previewTestStatus,
            provider: user.provider
        )
        nickname = user.name
    }
}
