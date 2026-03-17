# Onboarding 코드 스타일 리팩토링 설계

## 목표

Onboarding 모듈의 코드 스타일을 사용자 선호 스타일(MistakeNote 기반)로 통일.
Input/Output+transform Combine 패턴 → @Published+클로저 콜백 패턴,
UIKit+AutoLayout → SwiftUI+UIHostingController 전환.

---

## 섹션 1: 아키텍처 개요

### 변경 범위

| 레이어 | 현재 | 변경 후 |
|--------|------|---------|
| Coordinator | OnboardingCoordinatorImpl (UIKit 기반) | **유지** |
| ViewController | UIViewController 서브클래스 | **삭제** → UIHostingController로 대체 |
| ViewModel | Input/Output enum + transform() | @Published + 클로저 콜백 |
| View | UIKit + NSLayoutConstraint | SwiftUI View |
| 공유 컴포넌트 | OnboardingTitleLabel, OnboardingSubtitleLabel | **삭제** (SwiftUI Text 인라인 처리) |

### 삭제 파일

- `OnboardingComponents/OnboardingTitleLabel.swift`
- `OnboardingComponents/OnboardingSubtitleLabel.swift`

SwiftUI에서는 `Text(...)` + 수식어로 충분하므로 별도 컴포넌트 불필요.

### 처리 순서

BeginOnboarding → BeginPreviewTest → Greeting → CheckConcept → PreviewTest → PreviewResult

PreviewResult는 이미 SwiftUI View가 일부 존재하므로 마지막에 정리.

---

## 섹션 2: ViewModel 패턴

### Before

```swift
final class BeginOnboardingViewModel {
    enum Input { case didTapButton }
    enum Output { case moveToCheckConcept }

    private let output = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .didTapButton: self?.output.send(.moveToCheckConcept)
            }
        }.store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
```

### After

```swift
@MainActor
final class BeginOnboardingViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
```

### 원칙

- 네트워크/비동기 → `async func` + `@Published` 상태 직접 업데이트
- 화면 전환 → `onNavigate`, `onComplete` 등 클로저로 Coordinator에 위임
- `@MainActor` 기본 적용
- `ObservableObject` 채택으로 SwiftUI View와 바인딩

### Coordinator에서 클로저 주입 방식

```swift
func showBeginOnboarding() {
    let vm = BeginOnboardingViewModel()
    vm.onNavigate = { [weak self] in self?.showCheckConcept() }
    let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
    navigationController?.pushViewController(vc, animated: true)
}
```

---

## 섹션 3: View 레이어

### Before

```swift
final class BeginOnboardingViewController: UIViewController {
    private let viewModel: BeginOnboardingViewModel
    private let input = PassthroughSubject<BeginOnboardingViewModel.Input, Never>()
    private let button = OnboardingButton("시작하기")

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
}
```

### After

```swift
struct BeginOnboardingView: View {
    @ObservedObject var viewModel: BeginOnboardingViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("개념 학습 범위를\n설정해볼게요")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))

            Spacer()

            Button(action: { viewModel.didTapButton() }) {
                Text("시작하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.customBlue500))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 18)
    }
}
```

### OnboardingButton 처리

DesignSystem의 `OnboardingButton`(UIButton 서브클래스)은 SwiftUI 네이티브 `Button`으로 동일 스타일 직접 적용.
`UIViewRepresentable` 래핑 없이 SwiftUI로 통일.

### 각 화면별 특이사항

| 화면 | 특이사항 |
|------|---------|
| BeginOnboarding | 단순 텍스트 + 버튼, 변환 용이 |
| BeginPreviewTest | 단순 텍스트 + 버튼, 변환 용이 |
| Greeting | 단순 텍스트 + 버튼, 변환 용이 |
| CheckConcept | UICollectionView → SwiftUI List/LazyVStack, CheckAllOrNoneButton/CheckListCell/CheckListFoldButton 대체 필요 |
| PreviewTest | ExamKit 컴포넌트 의존 (QuestionOptionLabel, TestButton), UIKit 유지 또는 UIViewRepresentable 래핑 검토 |
| PreviewResult | 이미 SwiftUI View 존재, HostingController/ViewController 구조 정리 |

---

## 파일 구조 변경

### 삭제

```
OnboardingComponents/OnboardingTitleLabel.swift
OnboardingComponents/OnboardingSubtitleLabel.swift
[Feature]/ViewController/[Feature]ViewController.swift  (6개)
```

### 추가/변경

```
[Feature]/View/[Feature]View.swift          (SwiftUI View 신규)
[Feature]/ViewModel/[Feature]ViewModel.swift (패턴 변경)
Coordinator/OnboardingCoordinatorImpl.swift  (show* 메서드 변경)
```

---

## 제약 사항

- Coordinator 인터페이스(OnboardingCoordinator, OnboardingNavigating) 변경 없음
- ExamKit 컴포넌트 의존 화면(PreviewTest)은 UIViewRepresentable 또는 최소 변경으로 처리
- Swift 5 language mode 유지 (Package.swift의 swiftLanguageMode(.v5))
