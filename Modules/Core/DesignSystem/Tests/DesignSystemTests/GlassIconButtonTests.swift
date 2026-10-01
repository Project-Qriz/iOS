import Testing
import UIKit
@testable import DesignSystem

@MainActor
@Suite("GlassIconButton 테스트")
struct GlassIconButtonTests {

    @Test("지정한 지름으로 정사각형 제약을 갖는다 (원형이 되기 위한 전제조건)")
    func hasSquareSizeConstraintsMatchingDiameter() {
        let button = GlassIconButton(systemImageName: "chevron.left", diameter: 36)

        let widthConstraint = button.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = button.constraints.first { $0.firstAttribute == .height }

        #expect(widthConstraint?.constant == 36)
        #expect(heightConstraint?.constant == 36)
    }

    @Test("iOS 26 미만에서는 glass 설정을 쓰지 않는다")
    func doesNotUseConfigurationBelowGlassAvailability() {
        guard #unavailable(iOS 26.0) else { return }

        let button = GlassIconButton(systemImageName: "chevron.left")

        #expect(button.configuration == nil)
    }

    @Test("cornerStyle이 capsule이라 정사각형 프레임에서 완전한 원이 된다")
    func usesCapsuleCornerStyle() {
        guard #available(iOS 26.0, *) else { return }

        let button = GlassIconButton(systemImageName: "chevron.left")

        #expect(button.configuration?.cornerStyle == .capsule)
    }

    @Test("지정한 시스템 이미지가 설정된다")
    func setsSystemImage() {
        guard #available(iOS 26.0, *) else { return }

        let button = GlassIconButton(systemImageName: "xmark")

        #expect(button.configuration?.image != nil)
    }

    @Test("탭하면 전달한 액션이 실행된다")
    func firesActionOnTap() {
        var tapped = false
        let button = GlassIconButton(systemImageName: "chevron.left") { tapped = true }

        button.sendActions(for: .touchUpInside)

        #expect(tapped == true)
    }
}
