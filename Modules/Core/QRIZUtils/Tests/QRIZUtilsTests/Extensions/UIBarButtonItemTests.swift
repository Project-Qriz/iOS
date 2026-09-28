import Testing
import UIKit
@testable import QRIZUtils

@MainActor
@Suite("UIBarButtonItem.hidingSharedBackground 테스트")
struct UIBarButtonItemTests {

    @Test("시스템 glass를 쓰면 공유 배경(glass 캡슐)을 숨긴다")
    func hidesSharedBackgroundWhenGlassSupported() {
        guard #available(iOS 26.0, *) else { return }

        let item = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
            .hidingSharedBackground(usesSystemGlass: true)

        #expect(item.hidesSharedBackground == true)
    }

    @Test("시스템 glass를 쓰지 않으면 아무것도 바꾸지 않는다")
    func doesNothingWhenGlassUnsupported() {
        guard #available(iOS 26.0, *) else { return }

        let item = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
            .hidingSharedBackground(usesSystemGlass: false)

        #expect(item.hidesSharedBackground == false)
    }
}
