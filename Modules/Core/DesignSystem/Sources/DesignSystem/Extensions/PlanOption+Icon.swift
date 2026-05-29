import UIKit
import QRIZUtils

public extension PlanOption {
    var icon: UIImage {
        switch self {
        case .sevenDay: return .planIcon7Day
        case .fourteenDay: return .planIcon14Day
        case .thirtyDay: return .planIcon30Day
        }
    }

    var disabledIcon: UIImage {
        switch self {
        case .sevenDay: return .planIcon7DayDisabled
        case .fourteenDay: return .planIcon14DayDisabled
        case .thirtyDay: return .planIcon30DayDisabled
        }
    }
}
