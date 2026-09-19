import Testing
import UIKit
@testable import QRIZUtils

@MainActor
@Suite("UINavigationBar.defaultBackButtonStyle 테스트")
struct UINavigationBarStyleTests {

    // MARK: - 기존 스타일 (iOS 25 이하)

    @Test("시스템 glass를 쓰지 않으면 기본 배경은 흰색이다")
    func legacyUsesWhiteBackgroundByDefault() {
        let appearance = UINavigationBar.defaultBackButtonStyle(usesSystemGlass: false)

        #expect(appearance.backgroundColor == .white)
    }

    @Test("시스템 glass를 쓰지 않으면 전달한 배경색이 적용된다")
    func legacyAppliesGivenBackgroundColor() {
        let appearance = UINavigationBar.defaultBackButtonStyle(
            backgroundColor: .systemBlue,
            usesSystemGlass: false
        )

        #expect(appearance.backgroundColor == .systemBlue)
    }

    @Test("시스템 glass를 쓰지 않으면 hidesShadow가 그림자를 제거한다")
    func legacyHidesShadow() {
        let shown = UINavigationBar.defaultBackButtonStyle(usesSystemGlass: false)
        let hidden = UINavigationBar.defaultBackButtonStyle(
            hidesShadow: true,
            usesSystemGlass: false
        )

        // UIKit은 clear 그림자를 nil로 돌려주므로, 기본값과의 차이로 제거 여부를 검증한다.
        #expect(shown.shadowColor != nil)
        #expect(hidden.shadowColor == nil)
    }

    // MARK: - 시스템 glass (iOS 26+)

    @Test("시스템 glass를 쓰면 배경색을 지정하지 않는다")
    func glassIgnoresBackgroundColor() {
        let appearance = UINavigationBar.defaultBackButtonStyle(
            backgroundColor: .systemBlue,
            usesSystemGlass: true
        )

        #expect(appearance.backgroundColor == nil)
    }

    @Test("시스템 glass를 쓰면 그림자 설정을 덮어쓰지 않는다")
    func glassIgnoresShadowOverride() {
        let baseline = UINavigationBar.defaultBackButtonStyle(usesSystemGlass: true)
        let hidden = UINavigationBar.defaultBackButtonStyle(hidesShadow: true, usesSystemGlass: true)

        #expect(hidden.shadowColor == baseline.shadowColor)
    }

    // MARK: - 공통

    @Test("두 모드 모두 커스텀 뒤로가기 인디케이터 이미지가 적용된다", arguments: [true, false])
    func appliesBackIndicatorImage(usesSystemGlass: Bool) {
        let appearance = UINavigationBar.defaultBackButtonStyle(usesSystemGlass: usesSystemGlass)

        #expect(appearance.backIndicatorImage != nil)
    }
}
