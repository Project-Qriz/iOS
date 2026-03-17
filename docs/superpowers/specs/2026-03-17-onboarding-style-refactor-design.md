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

**예외**: PreviewTest는 ExamKit UIKit 컴포넌트 의존성으로 View는 UIKit 유지, ViewModel만 패턴 변경.

### 처리 순서

BeginOnboarding → BeginPreviewTest → Greeting → CheckConcept → PreviewTest → PreviewResult

### 내비게이션 바 커스터마이징 처리

일부 화면(PreviewResult)은 UIHostingController를 직접 사용하면서 내비게이션 아이템을 설정해야 함.
UIHostingController 서브클래스를 만들어 `viewDidLoad()`에서 `navigationItem` 설정.

---

## 섹션 2: ViewModel 패턴

### 기본 원칙

- 네트워크/비동기 → `async func` + `@Published` 상태 직접 업데이트
- 화면 전환 → 클로저로 Coordinator에 위임
- `@MainActor` 모든 ViewModel에 적용
- `ObservableObject` 채택으로 SwiftUI View와 바인딩
- Timer 콜백에서 내비게이션 클로저 호출 시 `MainActor.assumeIsolated` 불필요 — `@MainActor` 클래스 내에서 Timer 사용하므로 메인 스레드 보장

### Coordinator 클로저 주입 방식

모든 `show*` 메서드는 기존과 동일하게 `guardNavigation { ... }` 래퍼를 유지해 중복 push 방지.

```swift
func showBeginOnboarding() {
    guardNavigation {
        let vm = BeginOnboardingViewModel()
        vm.onNavigate = { [weak self] in self?.showCheckConcept() }
        let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
```

### 화면별 ViewModel 설계

#### BeginOnboarding

```swift
@MainActor
final class BeginOnboardingViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
```

#### BeginPreviewTest

```swift
@MainActor
final class BeginPreviewTestViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
```

#### Greeting

타이머로 자동 내비게이션 + 닉네임 표시.

```swift
@MainActor
final class GreetingViewModel: ObservableObject {
    @Published var nickname: String = ""
    var onNavigate: (() -> Void)?

    private let userInfoService: UserInfoService
    private var timer: Timer?

    init(userInfoService: UserInfoService) {
        self.userInfoService = userInfoService
    }

    func onAppear() {
        nickname = UserInfoManager.shared.name
        Task { await fetchUserInfo() }
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.onNavigate?()
            self?.timer?.invalidate()
        }
    }

    private func fetchUserInfo() async {
        // 유저 정보 갱신, 실패해도 화면 전환은 타이머가 처리
        guard let response = try? await userInfoService.getUserInfo() else { return }
        let user = response.data
        UserInfoManager.shared.update(name: user.name, userId: user.userId, email: user.email, previewTestStatus: user.previewTestStatus, provider: user.provider)
        nickname = UserInfoManager.shared.name
    }
}
```

#### CheckConcept

`SurveyCheckList.list`는 30개 항목의 **플랫 배열**. 섹션 구조 없음.
선택 상태를 `@Published var selectedSet: Set<Int>`(전역 인덱스)으로 관리.
네트워크 결과에 따라 두 목적지 중 하나로 전환.

```swift
@MainActor
final class CheckConceptViewModel: ObservableObject {
    @Published var selectedSet: Set<Int> = []
    @Published var isDoneButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var onNavigateToPreviewTest: (() -> Void)?
    var onNavigateToGreeting: (() -> Void)?

    private let onboardingService: OnboardingService

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    func didTapAll() {
        if selectedSet.count == SurveyCheckList.list.count {
            selectedSet.removeAll()
        } else {
            selectedSet = Set(0..<SurveyCheckList.list.count)
        }
        updateDoneButton()
    }

    func didTapNone() {
        selectedSet.removeAll()
        isDoneButtonEnabled = true
    }

    // idx는 SurveyCheckList.list 전역 인덱스
    func didTapConcept(idx: Int) {
        if selectedSet.contains(idx) { selectedSet.remove(idx) }
        else { selectedSet.insert(idx) }
        updateDoneButton()
    }

    func didTapDone() {
        guard isDoneButtonEnabled else { return }
        Task { await sendSurvey() }
    }

    private func updateDoneButton() {
        isDoneButtonEnabled = !selectedSet.isEmpty
    }

    private func sendSurvey() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let keyConcepts = selectedSet.map { SurveyCheckList.list[$0] }
            _ = try await onboardingService.sendSurvey(keyConcepts: keyConcepts)
            UserInfoManager.shared.previewTestStatus = .surveyCompleted
            if selectedSet.isEmpty {
                onNavigateToGreeting?()
            } else {
                onNavigateToPreviewTest?()
            }
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
```

Coordinator에서 (`guardNavigation` 래퍼 유지):
```swift
func showCheckConcept() {
    guardNavigation {
        let vm = CheckConceptViewModel(onboardingService: self.onboardingService)
        vm.onNavigateToPreviewTest = { [weak self] in self?.showBeginPreviewTest() }
        vm.onNavigateToGreeting = { [weak self] in self?.showGreeting() }
        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
```

#### PreviewTest (ViewModel만 변경, View는 UIKit 유지)

ExamKit 컴포넌트(QuestionOptionLabel, TestButton, TestPageIndicatorLabel)가 UIKit이므로 View는 UIKit ViewController 유지.
ViewModel만 @Published 패턴으로 변경.

문제별 선택 답안은 `selectedList: [Int?]` 배열로 내부 관리. 현재 문제 업데이트 시 선택 상태를
클로저 `onUpdateQuestion: ((PreviewTestListQuestion, Int, Int?) -> Void)?` 로 ViewController에 전달.
(Output enum의 `updateQuestion(question:curNum:selectedOption:)` 역할을 클로저로 대체)

```swift
@MainActor
final class PreviewTestViewModel: ObservableObject {
    // ViewController가 구독할 Published 상태
    @Published var timeRemaining: Int = 0
    @Published var timeLimit: Int = 0
    @Published var totalNum: Int = 0
    @Published var showSubmitAlert: Bool = false
    @Published var errorMessage: String? = nil

    // 현재 문제+선택지는 클로저로 전달 (배열 상태 동기화 복잡성 회피)
    var onUpdateQuestion: ((_ question: PreviewTestListQuestion, _ curNum: Int, _ selectedOption: Int?) -> Void)?
    var onNavigateToResult: (() -> Void)?
    var onNavigateToHome: (() -> Void)?

    private var questionList: [PreviewTestListQuestion] = []
    private var submitList: [TestSubmitData] = []
    private var selectedList: [Int?] = []
    private var currentNumber: Int? = nil
    private var timer: Timer?
    private var startTime: Date?

    private let onboardingService: OnboardingService

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    deinit { timer?.invalidate() }

    func onViewDidLoad() { Task { await fetchQuestions() } }
    func didTapPrev(selectedOption: Int?) { updateAnswer(selectedOption); navigatePage(offset: -1) }
    func didTapNext(selectedOption: Int?) {
        updateAnswer(selectedOption)
        if currentNumber ?? 0 >= questionList.count { showSubmitAlert = true }
        else { navigatePage(offset: 1) }
    }
    func didTapEscape() { stopTimer(); onNavigateToHome?() }
    func didConfirmSubmit() { Task { await submit() } }
    func didCancelSubmit() { showSubmitAlert = false }
    // ... private methods (fetchQuestions, navigatePage, submit, timer logic)
}
```

ViewController 바인딩:
```swift
viewModel.$timeRemaining.sink { [weak self] in ... }.store(in: &cancellables)
viewModel.$showSubmitAlert.sink { [weak self] in ... }.store(in: &cancellables)
viewModel.onUpdateQuestion = { [weak self] question, curNum, selectedOption in ... }
viewModel.onNavigateToResult = { [weak self] in self?.coordinator?.showPreviewResult() }
viewModel.onNavigateToHome = { [weak self] in self?.coordinator?.delegate?.didFinishOnboarding(...) }
```

#### PreviewResult

`ResultScoresData`와 `PreviewConceptsData`는 이미 `ObservableObject`이므로 `PreviewResultView`에 직접 전달.
ViewModel은 이 두 객체를 프로퍼티로 소유하고 데이터를 채워 넣음.
`fetchResult()` 완료 시 화면 전환 없음 — 사용자가 닫기(xmark) 버튼을 눌러야 전환.

```swift
@MainActor
final class PreviewResultViewModel: ObservableObject {
    let previewScoresData = ResultScoresData()
    let previewConceptsData = PreviewConceptsData()
    @Published var errorMessage: String? = nil

    // xmark 버튼 → Greeting으로 진행
    var onNavigateToGreeting: (() -> Void)?

    private let onboardingService: OnboardingService

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    func onViewDidLoad() {
        Task { await fetchResult() }
    }

    func didTapClose() {
        onNavigateToGreeting?()
    }

    private func fetchResult() async {
        do {
            let response = try await onboardingService.analyzePreview()
            // previewScoresData, previewConceptsData 업데이트 (기존 updateData 로직과 동일)
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
```

`PreviewResultView` 시그니처는 **변경 없음** — `previewScoresData`와 `previewConceptsData`를 그대로 전달.
`PreviewResultHostingController`에서 `viewModel.previewScoresData`, `viewModel.previewConceptsData` 주입.

---

## 섹션 3: View 레이어

### 기본 패턴

UIViewController + UIView 삭제, SwiftUI View + UIHostingController로 대체.

```swift
struct BeginOnboardingView: View {
    @ObservedObject var viewModel: BeginOnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    .font(.system(size: 16, weight: .bold))
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

### CheckConcept View 설계

UICollectionView + 커스텀 UIKit 셀 → SwiftUI `LazyVStack` (폴드는 `DisclosureGroup`)

`SurveyCheckList.list`는 플랫 배열(30개). 인덱스는 전역 인덱스(0~29) 그대로 사용.
폴드 섹션은 챕터 범위 기준으로 View 내에서 정의(별도 타입 불필요).

```swift
private let sections: [(title: String, range: Range<Int>)] = [
    ("데이터 모델링의 이해", 0..<5),
    ("데이터 모델과 SQL", 5..<10),
    ("SQL 기본", 10..<18),
    ("SQL 활용", 18..<26),
    ("SQL 명령어", 26..<30),
]

struct CheckConceptView: View {
    @ObservedObject var viewModel: CheckConceptViewModel
    @State private var expandedSections: Set<Int> = Set(0..<5)  // 기본 전체 펼침

    var body: some View {
        VStack {
            HStack {
                Button("전체 선택") { viewModel.didTapAll() }
                Spacer()
                Button("전체 해제") { viewModel.didTapNone() }
            }
            .padding(.horizontal, 18)

            ScrollView {
                LazyVStack {
                    ForEach(sections.indices, id: \.self) { sectionIdx in
                        let section = sections[sectionIdx]
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedSections.contains(sectionIdx) },
                                set: { expanded in
                                    if expanded { expandedSections.insert(sectionIdx) }
                                    else { expandedSections.remove(sectionIdx) }
                                }
                            ),
                            content: {
                                ForEach(section.range, id: \.self) { globalIdx in
                                    ConceptRowView(
                                        title: SurveyCheckList.list[globalIdx],
                                        isSelected: viewModel.selectedSet.contains(globalIdx)
                                    ) {
                                        viewModel.didTapConcept(idx: globalIdx)
                                    }
                                }
                            },
                            label: { Text(section.title) }
                        )
                    }
                }
            }

            Button(action: { viewModel.didTapDone() }) {
                Text("완료")
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(viewModel.isDoneButtonEnabled ? Color(.customBlue500) : Color(.coolNeutral200))
                    .foregroundColor(viewModel.isDoneButtonEnabled ? .white : Color(.coolNeutral500))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isDoneButtonEnabled)
            .padding(.horizontal, 18)
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
```

삭제: `CheckAllOrNoneButton.swift`, `CheckListCell.swift`, `CheckListFoldButton.swift`

### PreviewTest View 처리

**UIKit ViewController 유지** — ExamKit의 UIKit 컴포넌트를 직접 사용.
ViewController 내부 바인딩만 Combine sink → `$published` 구독으로 변경.
coordinator 레퍼런스 제거, 대신 ViewModel 클로저 주입.

### PreviewResult View 처리

현재 구조:
- `PreviewResultViewController` (UIKit)
- `PreviewResultViewHostingController` (UIHostingController 서브클래스, 5줄)
- `PreviewResultView` (SwiftUI)

변경 후:
- `PreviewResultViewController` **삭제**
- `PreviewResultViewHostingController` **삭제**
- `PreviewResultHostingController` (UIHostingController 서브클래스, 내비게이션 아이템 설정)

```swift
final class PreviewResultHostingController: UIHostingController<PreviewResultView> {
    private let viewModel: PreviewResultViewModel

    init(viewModel: PreviewResultViewModel) {
        self.viewModel = viewModel
        super.init(rootView: PreviewResultView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        viewModel.onViewDidLoad()
    }

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "시험 결과"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .coolNeutral700
        navigationItem.titleView = titleLabel

        let xmarkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        xmarkButton.setImage(UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal), for: .normal)
        xmarkButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: xmarkButton)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }
}
```

기존 `PreviewResultView` 시그니처 **변경 없음** (`previewScoresData:`, `previewConceptsData:` 파라미터 유지).
`PreviewResultHostingController`에서 `viewModel.previewScoresData`와 `viewModel.previewConceptsData`를 View에 전달.

```swift
init(viewModel: PreviewResultViewModel) {
    self.viewModel = viewModel
    super.init(rootView: PreviewResultView(
        previewScoresData: viewModel.previewScoresData,
        previewConceptsData: viewModel.previewConceptsData
    ))
}
```

---

## 파일 구조 변경

### 삭제

```
OnboardingComponents/OnboardingTitleLabel.swift
OnboardingComponents/OnboardingSubtitleLabel.swift
BeginOnboarding/ViewController/BeginOnboardingViewController.swift
BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift
Greeting/ViewController/GreetingViewController.swift
CheckConcept/ViewController/CheckConceptViewController.swift
CheckConcept/View/CheckAllOrNoneButton.swift
CheckConcept/View/CheckListCell.swift
CheckConcept/View/CheckListFoldButton.swift
PreviewResult/ViewController/PreviewResultViewController.swift
PreviewResult/HostingController/PreviewResultViewHostingController.swift
```

**유지**: `PreviewTest/ViewController/PreviewTestViewController.swift` (UIKit 유지)

### 추가/변경

```
BeginOnboarding/View/BeginOnboardingView.swift        (SwiftUI, 신규)
BeginPreviewTest/View/BeginPreviewTestView.swift      (SwiftUI, 신규)
Greeting/View/GreetingView.swift                      (SwiftUI, 신규)
CheckConcept/View/CheckConceptView.swift              (SwiftUI, 신규)
CheckConcept/View/ConceptRowView.swift                (SwiftUI, 신규)
PreviewResult/HostingController/PreviewResultHostingController.swift  (신규)
[Feature]/ViewModel/[Feature]ViewModel.swift          (패턴 변경, 6개)
Coordinator/OnboardingCoordinatorImpl.swift           (show* 메서드 변경)
```

---

## 제약 사항

- Coordinator 인터페이스(OnboardingCoordinator, OnboardingNavigating) 변경 없음
- PreviewTest View는 UIKit 유지 (ExamKit UIKit 컴포넌트 의존)
- Swift 5 language mode 유지 (Package.swift의 `swiftLanguageMode(.v5)`)
- `@MainActor` 모든 ViewModel에 적용
