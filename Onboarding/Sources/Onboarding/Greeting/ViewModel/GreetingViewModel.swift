import Foundation
import QRIZUtils
import Network

@MainActor
final class GreetingViewModel: ObservableObject {
    @Published var nickname: String = ""

    var onNavigate: (() -> Void)?

    private let userInfoService: UserInfoService
    private var timer: Timer?

    init(userInfoService: UserInfoService) {
        self.userInfoService = userInfoService
    }

    func onAppear() {
        nickname = UserInfoManager.shared.name  // 최신 닉네임을 화면에 즉시 반영
        Task { await fetchUserInfo() }          // 서버에서 갱신 (실패해도 타이머가 화면 전환 처리)
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.onNavigate?()
            self?.timer?.invalidate()
        }
    }

    private func fetchUserInfo() async {
        // 실패해도 에러 알럿 없음 — 기존 UIKit 버전의 fetchFailed 알럿은 의도적으로 제거.
        // 타이머가 2.5초 후 화면 전환을 처리하므로 서버 에러는 무시해도 무방.
        guard let response = try? await userInfoService.getUserInfo() else { return }
        let user = response.data
        UserInfoManager.shared.update(name: user.name, userId: user.userId, email: user.email, previewTestStatus: user.previewTestStatus, provider: user.provider)
        nickname = UserInfoManager.shared.name
    }
}
