public enum PlanOption: Int, CaseIterable, Identifiable, Sendable {
    case sevenDay = 7
    case fourteenDay = 14
    case thirtyDay = 30

    public var id: Int { rawValue }

    public var planType: Int { rawValue }

    public var dayLabel: String { "\(rawValue)일" }

    public var description: String {
        switch self {
        case .sevenDay: return "핵심만 빠르게, 고빈출 문제 집중"
        case .fourteenDay: return "균형있는 단기완성"
        case .thirtyDay: return "꼼꼼하게 가장 높은 완성도로 학습"
        }
    }
}
