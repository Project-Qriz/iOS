# Onboarding 스타일 리팩토링 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Onboarding 모듈의 Input/Output+Combine 패턴을 @Published+클로저 콜백으로, UIKit View를 SwiftUI+UIHostingController로 전환

**Architecture:** 6개 화면 각각 ViewModel(@Published+클로저)과 SwiftUI View를 새로 작성하고 기존 ViewController를 삭제. Coordinator의 show* 메서드에서 UIHostingController로 직접 push. PreviewTest는 ExamKit UIKit 의존성으로 View는 유지하고 ViewModel만 패턴 변경.

**Tech Stack:** Swift 5, SwiftUI, UIKit(PreviewTest), Combine(제거), UIHostingController

**Spec:** `docs/superpowers/specs/2026-03-17-onboarding-style-refactor-design.md`

**Base path:** `/Users/hun/iOS/Onboarding/Sources/Onboarding/`

---

## 빌드 확인 명령어

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ -configuration Debug build \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED" | tail -20
```

---

## Chunk 1: 단순 화면 3개 (BeginOnboarding, BeginPreviewTest, Greeting)

### Task 1: BeginOnboarding 리팩토링

**Files:**
- Modify: `BeginOnboarding/ViewModel/BeginOnboardingViewModel.swift`
- Create: `BeginOnboarding/View/BeginOnboardingView.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showBeginOnboarding만)
- Delete: `BeginOnboarding/ViewController/BeginOnboardingViewController.swift`

- [ ] **Step 1: ViewModel을 @Published 패턴으로 교체**

`BeginOnboarding/ViewModel/BeginOnboardingViewModel.swift` 전체를 아래로 교체:

```swift
import Foundation

@MainActor
final class BeginOnboardingViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
```

- [ ] **Step 2: SwiftUI View 생성**

`BeginOnboarding/View/BeginOnboardingView.swift` 새 파일 생성:

```swift
import SwiftUI
import DesignSystem

struct BeginOnboardingView: View {
    @ObservedObject var viewModel: BeginOnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SQLD를 어느정도\n알고 계신가요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 50)
                .padding(.horizontal, 24)

            Text("선택하신 체크사항을 기반으로\n맞춤 프리뷰 테스트를 제공해 드려요!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            Image(uiImage: .onboarding1)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            Spacer()

            Button {
                viewModel.didTapButton()
            } label: {
                Text("시작하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.customBlue500))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}
```

- [ ] **Step 3: Coordinator의 showBeginOnboarding 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showBeginOnboarding()` 메서드 교체:

```swift
func showBeginOnboarding() {
    guardNavigation {
        let vm = BeginOnboardingViewModel()
        vm.onNavigate = { [weak self] in self?.showCheckConcept() }
        let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 4: 기존 ViewController 삭제**

`BeginOnboarding/ViewController/BeginOnboardingViewController.swift` 파일 삭제

- [ ] **Step 5: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: BeginOnboarding UIKit → SwiftUI + @Published 패턴 전환"
```

---

### Task 2: BeginPreviewTest 리팩토링

**Files:**
- Modify: `BeginPreviewTest/ViewModel/BeginPreviewTestViewModel.swift`
- Create: `BeginPreviewTest/View/BeginPreviewTestView.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showBeginPreviewTest만)
- Delete: `BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift`

- [ ] **Step 1: ViewModel 교체**

`BeginPreviewTest/ViewModel/BeginPreviewTestViewModel.swift` 전체 교체:

```swift
import Foundation

@MainActor
final class BeginPreviewTestViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
```

- [ ] **Step 2: SwiftUI View 생성**

`BeginPreviewTest/View/BeginPreviewTestView.swift` 새 파일 생성:

```swift
import SwiftUI
import DesignSystem

struct BeginPreviewTestView: View {
    @ObservedObject var viewModel: BeginPreviewTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("테스트를\n진행해볼까요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 100)
                .padding(.horizontal, 24)

            Text("간단한 프리뷰 테스트로 실력을 점검하고\n이후 맞춤형 개념과 데일리 테스트를 경험해 보세요!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            Image(uiImage: .onboarding2)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            Spacer()

            Button {
                viewModel.didTapButton()
            } label: {
                Text("간단한 테스트 시작")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.customBlue500))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}
```

- [ ] **Step 3: Coordinator의 showBeginPreviewTest 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showBeginPreviewTest()` 교체:

```swift
func showBeginPreviewTest() {
    guardNavigation {
        let vm = BeginPreviewTestViewModel()
        vm.onNavigate = { [weak self] in self?.showPreviewTest() }
        let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 4: 기존 ViewController 삭제**

`BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift` 파일 삭제

- [ ] **Step 5: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: BeginPreviewTest UIKit → SwiftUI + @Published 패턴 전환"
```

---

### Task 3: Greeting 리팩토링

**Files:**
- Modify: `Greeting/ViewModel/GreetingViewModel.swift`
- Create: `Greeting/View/GreetingView.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showGreeting만)
- Delete: `Greeting/ViewController/GreetingViewController.swift`

기존 `GreetingViewModel`의 핵심 동작:
- `viewDidLoad`: 유저 정보 가져오기 + 닉네임 업데이트
- `viewDidAppear`: 타이머 시작 (2.5초 후 `moveToHome`)
- SwiftUI에서는 `onAppear`가 `viewDidAppear`보다 약간 빠르게 호출되지만 onboarding 플로우에서 허용 가능한 차이

- [ ] **Step 1: ViewModel 교체**

`Greeting/ViewModel/GreetingViewModel.swift` 전체 교체:

```swift
import Foundation
import QRIZUtils
import Network

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
        nickname = UserInfoManager.shared.name  // 최신 닉네임을 화면에 즉시 반영
        Task { await fetchUserInfo() }          // 서버에서 갱신 (실패해도 타이머가 화면 전환 처리)
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
        // 실패해도 에러 알럿 없음 — 기존 UIKit 버전의 fetchFailed 알럿은 의도적으로 제거.
        // 타이머가 2.5초 후 화면 전환을 처리하므로 서버 에러는 무시해도 무방.
        guard let response = try? await userInfoService.getUserInfo() else { return }
        let user = response.data
        UserInfoManager.shared.update(
            name: user.name,
            userId: user.userId,
            email: user.email,
            previewTestStatus: user.previewTestStatus,
            provider: user.provider
        )
        nickname = UserInfoManager.shared.name
    }
}
```

- [ ] **Step 2: SwiftUI View 생성**

`Greeting/View/GreetingView.swift` 새 파일 생성:

```swift
import SwiftUI
import DesignSystem

struct GreetingView: View {
    @ObservedObject var viewModel: GreetingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.nickname)님\n환영합니다")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 40)
                .padding(.horizontal, 24)

            Text("준비되어 있는 오늘의 공부와, 모의고사로\n시험을 같이 준비해봐요!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.horizontal, 24)

            Image(uiImage: .onboarding3)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
```

- [ ] **Step 3: Coordinator의 showGreeting 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showGreeting()` 교체:

```swift
func showGreeting() {
    guardNavigation {
        let vm = GreetingViewModel(userInfoService: userInfoService)
        vm.onNavigate = { [weak self] in
            guard let self else { return }
            self.delegate?.didFinishOnboarding(self)
        }
        let vc = UIHostingController(rootView: GreetingView(viewModel: vm))
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 4: 기존 ViewController 삭제**

`Greeting/ViewController/GreetingViewController.swift` 파일 삭제

- [ ] **Step 5: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: Greeting UIKit → SwiftUI + @Published 패턴 전환"
```

---

### Task 4: 공유 컴포넌트 삭제

**Files:**
- Delete: `OnboardingComponents/OnboardingTitleLabel.swift`
- Delete: `OnboardingComponents/OnboardingSubtitleLabel.swift`

Task 1~3 완료 후 더 이상 참조되지 않으므로 삭제 가능.

- [ ] **Step 1: OnboardingTitleLabel, OnboardingSubtitleLabel 파일 삭제**

두 파일 삭제:
- `OnboardingComponents/OnboardingTitleLabel.swift`
- `OnboardingComponents/OnboardingSubtitleLabel.swift`

- [ ] **Step 2: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인 (참조 없으면 에러 없음)

- [ ] **Step 3: 커밋**

```bash
git add -A
git commit -m "remove: 미사용 OnboardingTitleLabel, OnboardingSubtitleLabel 삭제"
```

---

## Chunk 2: 복잡 화면 (CheckConcept, PreviewTest, PreviewResult)

### Task 5: CheckConcept 리팩토링

**Files:**
- Modify: `CheckConcept/ViewModel/CheckConceptViewModel.swift`
- Create: `CheckConcept/View/CheckConceptView.swift`
- Create: `CheckConcept/View/ConceptRowView.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showCheckConcept만)
- Delete: `CheckConcept/ViewController/CheckConceptViewController.swift`
- Delete: `CheckConcept/View/CheckAllOrNoneButton.swift`
- Delete: `CheckConcept/View/CheckListCell.swift`
- Delete: `CheckConcept/View/CheckListFoldButton.swift`

핵심 로직:
- `SurveyCheckList.list`: 30개 플랫 배열, 인덱스 0~29
- 섹션 범위: (0..<5), (5..<10), (10..<18), (18..<26), (26..<30) — `SurveyCheckList.getChapter` 범위와 일치
- "전체 해제" 후 Done 버튼 활성화 + selectedSet 비어있으면 → Greeting으로 라우팅

- [ ] **Step 1: ViewModel 교체**

`CheckConcept/ViewModel/CheckConceptViewModel.swift` 전체 교체:

```swift
import Foundation
import QRIZUtils
import Network

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

    func didTapConcept(idx: Int) {
        if selectedSet.contains(idx) {
            selectedSet.remove(idx)
        } else {
            selectedSet.insert(idx)
        }
        updateDoneButton()
    }

    func didTapDone() {
        guard isDoneButtonEnabled, !isLoading else { return }
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

- [ ] **Step 2: ConceptRowView 생성**

`CheckConcept/View/ConceptRowView.swift` 새 파일 생성:

```swift
import SwiftUI
import DesignSystem

struct ConceptRowView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? Color(.customBlue500) : Color(.coolNeutral400))
                    .font(.system(size: 20))

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.coolNeutral800))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color(.customBlue100).opacity(0.7), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
    }
}
```

- [ ] **Step 3: CheckConceptView 생성**

`CheckConcept/View/CheckConceptView.swift` 새 파일 생성:

```swift
import SwiftUI
import DesignSystem
import QRIZUtils

private let sections: [(title: String, range: Range<Int>)] = [
    ("데이터 모델링의 이해", 0..<5),
    ("데이터 모델과 SQL", 5..<10),
    ("SQL 기본", 10..<18),
    ("SQL 활용", 18..<26),
    ("SQL 명령어", 26..<30),
]

struct CheckConceptView: View {
    @ObservedObject var viewModel: CheckConceptViewModel
    @State private var expandedSections: Set<Int> = Set(0..<5)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("아는 개념을 체크해주세요!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 48)
                .padding(.horizontal, 24)

            Text("체크하신 결과를 토대로\n추후 진행할 테스트의 레벨이 조정됩니다!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 20)
                .padding(.horizontal, 24)

            // 전체 해제 버튼
            Button(action: { viewModel.didTapNone() }) {
                HStack {
                    Image(systemName: viewModel.selectedSet.isEmpty ? "checkmark.square.fill" : "square")
                        .foregroundColor(viewModel.selectedSet.isEmpty ? Color(.customBlue500) : Color(.coolNeutral400))
                        .font(.system(size: 20))
                    Text("전체 해제")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.coolNeutral800))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
                .background(Color.white)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 32)

            Divider()
                .background(Color(.customBlue100))
                .frame(height: 2)
                .padding(.horizontal, 18)
                .padding(.top, 16)

            // 전체 선택 + 폴드
            HStack {
                Button(action: { viewModel.didTapAll() }) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedSet_isAll ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedSet_isAll ? Color(.customBlue500) : Color(.coolNeutral400))
                            .font(.system(size: 20))
                        Text("전체 선택")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.coolNeutral800))
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                Button(action: { toggleAllSections() }) {
                    Image(systemName: expandedSections.isEmpty ? "chevron.down" : "chevron.up")
                        .foregroundColor(Color(.coolNeutral600))
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 60)
            .padding(.top, 16)

            // 개념 목록
            ScrollView {
                LazyVStack(spacing: 0) {
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
                            label: {
                                Text(section.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(.coolNeutral700))
                                    .padding(.leading, 24)
                            }
                        )
                        .padding(.horizontal, 18)
                        .accentColor(Color(.coolNeutral600))
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color(.customBlue50))

            Spacer(minLength: 0)

            // 완료 버튼
            Button(action: { viewModel.didTapDone() }) {
                ZStack {
                    Text(viewModel.isLoading ? "" : "선택완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.isDoneButtonEnabled ? .white : Color(.coolNeutral500))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(viewModel.isDoneButtonEnabled ? Color(.customBlue500) : Color(.coolNeutral200))
                        .cornerRadius(8)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .disabled(!viewModel.isDoneButtonEnabled || viewModel.isLoading)
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(Color(.customBlue50))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(
            "오류",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var selectedSet_isAll: Bool {
        viewModel.selectedSet.count == SurveyCheckList.list.count
    }

    private func toggleAllSections() {
        if expandedSections.isEmpty {
            expandedSections = Set(0..<sections.count)
        } else {
            expandedSections.removeAll()
        }
    }
}
```

- [ ] **Step 4: Coordinator의 showCheckConcept 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showCheckConcept()` 교체:

```swift
func showCheckConcept() {
    guardNavigation {
        let vm = CheckConceptViewModel(onboardingService: onboardingService)
        vm.onNavigateToPreviewTest = { [weak self] in self?.showBeginPreviewTest() }
        vm.onNavigateToGreeting = { [weak self] in self?.showGreeting() }
        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 5: 기존 UIKit 파일들 삭제**

아래 4개 파일 삭제:
- `CheckConcept/ViewController/CheckConceptViewController.swift`
- `CheckConcept/View/CheckAllOrNoneButton.swift`
- `CheckConcept/View/CheckListCell.swift`
- `CheckConcept/View/CheckListFoldButton.swift`

- [ ] **Step 6: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "refactor: CheckConcept UIKit → SwiftUI + @Published 패턴 전환"
```

---

### Task 6: PreviewTest ViewModel 리팩토링 (View UIKit 유지)

**Files:**
- Modify: `PreviewTest/ViewModel/PreviewTestViewModel.swift`
- Modify: `PreviewTest/ViewController/PreviewTestViewController.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showPreviewTest만)

기존 ViewController의 핵심 동작은 유지하면서 바인딩 방식만 변경:
- `PassthroughSubject<Input>` → ViewModel 메서드 직접 호출
- `output.sink` → `$published.sink` + 클로저 콜백

- [ ] **Step 1: ViewModel 교체**

`PreviewTest/ViewModel/PreviewTestViewModel.swift` 전체 교체:

```swift
import Foundation
import Combine
import QRIZUtils
import Network

@MainActor
final class PreviewTestViewModel: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var timeLimit: Int = 0
    @Published var totalNum: Int = 0
    @Published var showSubmitAlert: Bool = false
    @Published var errorMessage: String? = nil

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

    deinit {
        timer?.invalidate()
    }

    func onViewDidLoad() {
        Task { await fetchQuestions() }
    }

    func didTapPrev(selectedOption: Int?) {
        updateAnswer(selectedOption: selectedOption)
        navigatePage(offset: -1)
    }

    func didTapNext(selectedOption: Int?) {
        updateAnswer(selectedOption: selectedOption)
        guard let curNum = currentNumber else { return }
        if curNum >= questionList.count {
            showSubmitAlert = true
        } else {
            navigatePage(offset: 1)
        }
    }

    func didTapEscape() {
        stopTimer()
        onNavigateToHome?()
    }

    func didConfirmSubmit() {
        Task { await submit() }
    }

    func didCancelSubmit() {
        showSubmitAlert = false
    }

    private func updateAnswer(selectedOption: Int?) {
        guard let currentNumber else { return }
        selectedList[currentNumber - 1] = selectedOption
        if let opt = selectedOption {
            submitList[currentNumber - 1].optionId = questionList[currentNumber - 1].options[opt - 1].id
        } else {
            submitList[currentNumber - 1].optionId = nil
        }
    }

    private func navigatePage(offset: Int) {
        guard let curNum = currentNumber else { return }
        currentNumber = curNum + offset
        let idx = currentNumber! - 1
        onUpdateQuestion?(questionList[idx], currentNumber!, selectedList[idx])
    }

    private func submit() async {
        do {
            _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
            stopTimer()
            showSubmitAlert = false
            onNavigateToResult?()
        } catch {
            showSubmitAlert = false
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func fetchQuestions() async {
        do {
            let response = try await onboardingService.getPreviewTestList()
            let questions = response.data.questions
            guard !questions.isEmpty else { return }
            currentNumber = 1
            totalNum = questions.count
            timeLimit = response.data.totalTimeLimit
            questionList = questions
            initSubmitList(response)
            selectedList = Array(repeating: nil, count: questions.count)
            startTimerPublishing(totalTimeLimit: response.data.totalTimeLimit)
            onUpdateQuestion?(questionList[0], 1, nil)
        } catch {
            errorMessage = "문제 불러오기 실패"
        }
    }

    private func initSubmitList(_ response: PreviewTestListResponse) {
        response.data.questions.enumerated().forEach { idx, question in
            submitList.append(TestSubmitData(
                question: SubmitQuestionData(questionId: question.questionId, category: question.category),
                questionNum: idx + 1,
                optionId: nil
            ))
        }
    }

    private func startTimerPublishing(totalTimeLimit: Int) {
        timeRemaining = totalTimeLimit
        startTime = Date()
        // @MainActor 클래스에서 #selector 기반 타이머는 strict concurrency 경고 유발.
        // 클로저 기반 타이머 사용.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func tickTimer() {
        guard let start = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        let remaining = timeLimit - elapsed
        if remaining >= 0 {
            timeRemaining = remaining
        } else {
            stopTimer()
            Task { await submit() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
```

- [ ] **Step 2: ViewController 바인딩 변경**

`PreviewTest/ViewController/PreviewTestViewController.swift` 에서 아래 내용을 변경:

1. `import Combine` 유지, `private var subscriptions = Set<AnyCancellable>()` 유지
2. `private let input: PassthroughSubject<PreviewTestViewModel.Input, Never> = .init()` **삭제**
3. `weak var coordinator: (any OnboardingNavigating)?` **삭제**
4. `bind()` 메서드 전체 교체:

```swift
private func bind() {
    // 문제/선택지 업데이트 클로저
    viewModel.onUpdateQuestion = { [weak self] question, curNum, selectedOption in
        self?.updateQuestionUI(question: question, curNum: curNum, selectedOption: selectedOption)
    }

    // 총 문항 수 구독 — lastQuestionNum 동기화
    viewModel.$totalNum
        .receive(on: RunLoop.main)
        .sink { [weak self] num in
            self?.lastQuestionNum = num
        }
        .store(in: &subscriptions)

    // 타이머 구독
    viewModel.$timeRemaining
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            guard let self else { return }
            updateProgress(timeLimit: viewModel.timeLimit, timeRemaining: viewModel.timeRemaining)
        }
        .store(in: &subscriptions)

    // 제출 알럿 구독 (.dropFirst()로 초기값 false에 의한 spurious dismiss 방지)
    viewModel.$showSubmitAlert
        .dropFirst()
        .receive(on: RunLoop.main)
        .sink { [weak self] show in
            guard let self else { return }
            if show {
                present(submitAlertViewController, animated: true)
            } else {
                submitAlertViewController.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)

    // 에러 구독
    viewModel.$errorMessage
        .receive(on: RunLoop.main)
        .compactMap { $0 }
        .sink { [weak self] msg in
            guard let self else { return }
            showOneButtonAlert(with: msg, storingIn: &subscriptions)
        }
        .store(in: &subscriptions)
}
```

5. `setAlertButtonActions()` 교체:

```swift
private func setAlertButtonActions() {
    let confirmAction = UIAction { [weak self] _ in
        self?.viewModel.didConfirmSubmit()
    }
    let cancelAction = UIAction { [weak self] _ in
        self?.viewModel.didCancelSubmit()
    }
    submitAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
}
```

6. `moveToHome()` @objc 메서드 교체:

```swift
@objc private func moveToHome() {
    viewModel.didTapEscape()
}
```

7. `setButtonActions()` 교체:

```swift
private func setButtonActions() {
    previousButton.addAction(UIAction(handler: { [weak self] _ in
        guard let self else { return }
        self.viewModel.didTapPrev(selectedOption: selectedOptionIdx)
    }), for: .touchUpInside)

    nextButton.addAction(UIAction(handler: { [weak self] _ in
        guard let self else { return }
        self.viewModel.didTapNext(selectedOption: selectedOptionIdx)
    }), for: .touchUpInside)
}
```

8. `viewDidLoad()` 내 `input.send(.viewDidLoad)` → `viewModel.onViewDidLoad()` 로 변경

- [ ] **Step 3: Coordinator의 showPreviewTest 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showPreviewTest()` 교체:

```swift
func showPreviewTest() {
    guardNavigation {
        let vm = PreviewTestViewModel(onboardingService: onboardingService)
        let vc = PreviewTestViewController(viewModel: vm)
        vm.onNavigateToResult = { [weak self] in self?.showPreviewResult() }
        vm.onNavigateToHome = { [weak self] in
            guard let self else { return }
            self.delegate?.didFinishOnboarding(self)
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 4: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "refactor: PreviewTest ViewModel @Published 패턴 전환 (View UIKit 유지)"
```

---

### Task 7: PreviewResult 리팩토링

**Files:**
- Modify: `PreviewResult/ViewModel/PreviewResultViewModel.swift`
- Create: `PreviewResult/HostingController/PreviewResultHostingController.swift`
- Modify: `Coordinator/OnboardingCoordinatorImpl.swift` (showPreviewResult만)
- Delete: `PreviewResult/ViewController/PreviewResultViewController.swift`
- Delete: `PreviewResult/HostingController/PreviewResultViewHostingController.swift`

기존 `PreviewResultView`는 `previewScoresData`와 `previewConceptsData`를 직접 받으므로 시그니처 변경 없음.
새 HostingController가 ViewModel의 두 프로퍼티를 View에 전달.

- [ ] **Step 1: ViewModel 교체**

`PreviewResult/ViewModel/PreviewResultViewModel.swift` 전체 교체:

```swift
import Foundation
import Combine
import QRIZUtils
import Network

@MainActor
final class PreviewResultViewModel: ObservableObject {
    let previewScoresData = ResultScoresData()
    let previewConceptsData = PreviewConceptsData()
    @Published var errorMessage: String? = nil

    var onNavigateToGreeting: (() -> Void)?

    private let onboardingService: OnboardingService
    private var incorrectCountDataArr: [IncorrectCountData] = []

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
            updateData(response.data)
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func updateData(_ data: AnalyzePreviewResponse.DataInfo) {
        previewScoresData.nickname = UserInfoManager.shared.name
        previewScoresData.expectScore = data.estimatedScore

        if data.topConceptsToImprove.count >= 2 {
            previewConceptsData.firstConcept = data.topConceptsToImprove[0]
            previewConceptsData.secondConcept = data.topConceptsToImprove[1]
        }
        previewConceptsData.totalQuestions = data.weakAreaAnalysis.totalQuestions

        previewScoresData.subjectScores[0] = Double(data.scoreBreakdown.part1Score)
        previewScoresData.subjectScores[1] = Double(data.scoreBreakdown.part2Score)
        previewScoresData.subjectCount = 2

        updateIncorrectArr(data)
    }

    private func updateIncorrectArr(_ data: AnalyzePreviewResponse.DataInfo) {
        var dic: [Int: [String]] = [:]
        data.weakAreaAnalysis.weakAreas.forEach { item in
            if dic[item.incorrectCount] != nil {
                dic[item.incorrectCount]?.append(item.topic)
            } else {
                dic[item.incorrectCount] = [item.topic]
            }
        }

        dic.sorted { $0.key > $1.key }.enumerated().forEach { idx, item in
            incorrectCountDataArr.append(IncorrectCountData(id: idx + 1, incorrectCount: item.key, topic: item.value))
        }

        previewConceptsData.numOfChartToPresent = incorrectCountDataArr.count
        previewConceptsData.initAnimationChart()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.previewConceptsData.incorrectCountDataArr = self?.incorrectCountDataArr ?? []
        }
    }
}
```

- [ ] **Step 2: PreviewResultHostingController 생성**

`PreviewResult/HostingController/PreviewResultHostingController.swift` 새 파일 생성:

```swift
import UIKit
import SwiftUI
import Combine

final class PreviewResultHostingController: UIHostingController<PreviewResultView> {
    private let viewModel: PreviewResultViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(viewModel: PreviewResultViewModel) {
        self.viewModel = viewModel
        super.init(rootView: PreviewResultView(
            previewScoresData: viewModel.previewScoresData,
            previewConceptsData: viewModel.previewConceptsData
        ))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        viewModel.onViewDidLoad()

        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] msg in
                guard let self else { return }
                // showOneButtonAlert의 storingIn: inout 파라미터는 escaping closure 안에서 사용 불가.
                // UIAlertController로 직접 표시.
                let alert = UIAlertController(title: "오류", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.viewModel.errorMessage = nil
                })
                self.present(alert, animated: true)
            }
            .store(in: &subscriptions)
    }

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "시험 결과"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .coolNeutral700
        navigationItem.titleView = titleLabel

        let xmarkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        xmarkButton.setImage(xmark, for: .normal)
        xmarkButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: xmarkButton)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }
}
```

- [ ] **Step 3: Coordinator의 showPreviewResult 수정**

`Coordinator/OnboardingCoordinatorImpl.swift` 의 `showPreviewResult()` 교체:

```swift
func showPreviewResult() {
    guardNavigation {
        let vm = PreviewResultViewModel(onboardingService: onboardingService)
        vm.onNavigateToGreeting = { [weak self] in self?.showGreeting() }
        let vc = PreviewResultHostingController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- [ ] **Step 4: 기존 파일들 삭제**

아래 2개 파일 삭제:
- `PreviewResult/ViewController/PreviewResultViewController.swift`
- `PreviewResult/HostingController/PreviewResultViewHostingController.swift`

- [ ] **Step 5: 빌드 확인**

빌드 명령어 실행, `BUILD SUCCEEDED` 확인

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "refactor: PreviewResult UIKit ViewController → UIHostingController + @Published 패턴 전환"
```

---

## 완료 확인

모든 Task 완료 후:
- [ ] Onboarding 모듈 전체 빌드 성공 확인
- [ ] 6개 화면 ViewController 파일 모두 삭제 확인
- [ ] Combine `Input/Output` enum이 Onboarding 모듈에 남아있지 않은지 확인:

```bash
grep -r "enum Input\|enum Output\|PassthroughSubject\|func transform" \
  /Users/hun/iOS/Onboarding/Sources/Onboarding/ --include="*.swift"
```

기대 결과: 출력 없음 (PreviewTest 포함, 모두 제거됨)
