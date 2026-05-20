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
}
