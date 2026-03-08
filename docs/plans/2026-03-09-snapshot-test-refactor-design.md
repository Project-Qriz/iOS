# Snapshot Test Refactor Design

**Date:** 2026-03-09
**Scope:** Account, Conceptbook 스냅샷 테스트 코드 정리

## 문제점

1. 스냅샷 대상 불일치 — `LoginSnapshotTests`는 `of: vc`, 나머지는 `of: vc.view`
2. `UIScreen.main.bounds` — iOS 16 deprecated, 기기마다 크기 달라 불안정
3. `SignUpFlowViewModel` computed property — 테스트마다 새 인스턴스 생성 의도가 불명확
4. Conceptbook 뷰 사이징 보일러플레이트 3회 반복
5. `__Snapshots___64/` 구버전 레퍼런스 이미지 폴더 잔존

## 결정사항

- 스냅샷 대상: ViewController 전체 (`of: vc`) 통일
- 디바이스 크기: iPhone 16 Pro 고정 (`CGSize(width: 393, height: 852)`)
- 구버전 `__Snapshots___64/` 삭제
- 기존 Account `__Snapshots__/` 레퍼런스 이미지 삭제 후 재생성 필요

## 설계

### Account — `SnapshotTestHelpers.swift`

```swift
@MainActor
func inNav(_ viewController: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: viewController)
}

@MainActor
class AccountSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852)
}
```

### Account — 각 테스트 클래스

- `LoginSnapshotTests`, `SignUpSnapshotTests`, `FindAccountSnapshotTests` 모두 `AccountSnapshotTestCase` 상속
- `UIScreen.main.bounds` → `CGRect(origin: .zero, size: Self.deviceSize)`
- `assertSnapshot(of: vc.view, ...)` → `assertSnapshot(of: vc, ...)`
- `SignUpSnapshotTests.flowVM` computed property → `setUp()`에서 초기화

### Conceptbook — `SnapshotTestHelpers.swift` (신규)

```swift
@MainActor
class ConceptbookSnapshotTestCase: XCTestCase {
    func snapshotView(_ view: UIView, width: CGFloat = 375) -> UIView {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        return view
    }
}
```

### Conceptbook — `ConceptbookSnapshotTests`

- `ConceptbookSnapshotTestCase` 상속
- 반복되는 사이징 로직 → `snapshotView(_:width:)` 헬퍼로 교체
