struct PlanOptionViewState: Equatable {
    enum Status: Equatable {
        case current      // 현재 플랜 — 배지 표시, 탭 불가
        case available    // 선택 가능
        case unavailable  // 비활성 — disabled 스타일, 탭 불가
    }
    let status: Status
    let isSelected: Bool  // .current 일 때는 항상 false
}
