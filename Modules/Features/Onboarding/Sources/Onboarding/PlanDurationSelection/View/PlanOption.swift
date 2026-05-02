import UIKit
import DesignSystem

enum PlanOption: Int, CaseIterable, Identifiable {
    case sevenDay = 7
    case fourteenDay = 14
    case thirtyDay = 30

    var id: Int { rawValue }

    var planType: Int { rawValue }

    var dayLabel: String { "\(rawValue)일" }

    var icon: UIImage {
        switch self {
        case .sevenDay: return .planIcon7Day
        case .fourteenDay: return .planIcon14Day
        case .thirtyDay: return .planIcon30Day
        }
    }

    var description: String {
        switch self {
        case .sevenDay: return "핵심만 빠르게, 고빈출 문제 집중"
        case .fourteenDay: return "균형있는 단기완성"
        case .thirtyDay: return "꼼꼼하게 가장 높은 완성도로 학습"
        }
    }
}
