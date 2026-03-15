# MistakeNote 내부 리팩토링 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** MistakeNote 모듈 내 중복 코드 제거, 에러 처리 개선, 뷰 컴포넌트 분리를 통해 코드 품질을 높인다.

**Architecture:** 공통 String extension 추출 → ViewModel 로직 통합 → 에러 처리 Logger 교체 → FilterBarView 컴포넌트 분리 순으로 진행. 각 단계는 독립적이며 순서대로 커밋.

**Tech Stack:** Swift 6.0, SwiftUI, Combine, os.Logger, SPM local package

---

### Task 1: String+Concept extension 추출

중복된 `normalizeConceptName` 로직을 패키지 내부 공유 extension으로 추출한다.

**Files:**
- Create: `MistakeNote/Sources/MistakeNote/Extensions/String+Concept.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/FilterSectionView.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`

**Step 1: String+Concept.swift 생성**

패키지 내부에서만 쓰이므로 `internal` (public 불필요):

```swift
//
//  String+Concept.swift
//  MistakeNote
//

extension String {
    /// 개념 이름 정규화 — 공백 제거하여 비교 시 사용
    func normalizingConcept() -> String {
        replacingOccurrences(of: " ", with: "")
    }
}
```

**Step 2: FilterSectionView.swift 수정**

`normalizeConceptName` 메서드 제거, `normalizingConcept()` 호출로 교체:

```swift
// 제거
private func normalizeConceptName(_ name: String) -> String {
    name.replacingOccurrences(of: " ", with: "")
}

// filteredConcepts 변경 전
let normalizedAvailableConcepts = Set(availableConcepts.map { normalizeConceptName($0) })
return chapter.concepts.filter { normalizedAvailableConcepts.contains(normalizeConceptName($0)) }

// 변경 후
let normalizedAvailableConcepts = Set(availableConcepts.map { $0.normalizingConcept() })
return chapter.concepts.filter { normalizedAvailableConcepts.contains($0.normalizingConcept()) }
```

**Step 3: SubjectFilterSheetViewModel.swift 수정**

`normalizeConceptName` 메서드 제거, `normalizingConcept()` 호출로 교체:

```swift
// 제거
public func normalizeConceptName(_ name: String) -> String {
    name.replacingOccurrences(of: " ", with: "")
}

// availableChapters computed property 변경 전
let normalizedAvailableConcepts = Set(availableConcepts.map { normalizeConceptName($0) })
return selectedSubject.chapters.filter { chapter in
    chapter.concepts.contains { normalizedAvailableConcepts.contains(normalizeConceptName($0)) }
}

// 변경 후
let normalizedAvailableConcepts = Set(availableConcepts.map { $0.normalizingConcept() })
return selectedSubject.chapters.filter { chapter in
    chapter.concepts.contains { normalizedAvailableConcepts.contains($0.normalizingConcept()) }
}
```

**Step 4: MistakeNoteListViewModel.swift 수정**

`normalizeConceptName` 메서드 제거, `normalizingConcept()` 호출로 교체:

```swift
// 제거
private func normalizeConceptName(_ name: String) -> String {
    name.replacingOccurrences(of: " ", with: "")
}

// displayedQuestions 변경 전
let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { normalizeConceptName($0) })
questions = questions.filter { question in
    let questionConcepts = question.keyConcepts
        .components(separatedBy: ",")
        .map { normalizeConceptName($0.trimmingCharacters(in: .whitespaces)) }
    return questionConcepts.contains { normalizedSelectedConcepts.contains($0) }
}

// 변경 후
let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { $0.normalizingConcept() })
questions = questions.filter { question in
    let questionConcepts = question.keyConcepts
        .components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespaces).normalizingConcept() }
    return questionConcepts.contains { normalizedSelectedConcepts.contains($0) }
}

// hasFilterForSubject 변경 전
let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { normalizeConceptName($0) })
let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { normalizeConceptName($0) }

// 변경 후
let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { $0.normalizingConcept() })
let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { $0.normalizingConcept() }
```

**Step 5: 빌드 확인**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug -destination 'generic/platform=iOS' build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

---

### Task 2: QuestionFilter enum 도입 + 로딩 메서드 통합

Magic String `"모두"` / `"오답만"` 을 enum으로 전환하고, 중복된 로딩 메서드를 하나로 통합한다.

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`

**Step 1: QuestionFilter enum 추가**

클래스 선언 바로 위에 추가:

```swift
public enum QuestionFilter: String, CaseIterable, Sendable {
    case all = "모두"
    case incorrectOnly = "오답만"
}
```

**Step 2: filterAll 타입 변경**

```swift
// 변경 전
@Published public var filterAll: String = "모두"

// 변경 후
@Published public var filterAll: QuestionFilter = .all
```

**Step 3: Input enum 케이스 변경**

```swift
// 변경 전
case filterAllChanged(String)

// 변경 후
case filterAllChanged(QuestionFilter)
```

**Step 4: displayedQuestions 변경**

```swift
// 변경 전
if filterAll == "오답만" {

// 변경 후
if filterAll == .incorrectOnly {
```

**Step 5: resetAllFilters 변경**

```swift
// 변경 전
filterAll = "모두"

// 변경 후
filterAll = .all
```

**Step 6: loadClips 메서드로 통합**

`loadDailyQuestions(for:)`와 `loadMockExamQuestions(for:)` 를 하나로 합친다:

```swift
private func loadClips(category: Int, testInfo: String) async {
    isLoading = true
    errorMessage = nil

    do {
        let response = try await service.getClips(category: category, testInfo: testInfo)
        filteredQuestions = response.data.map { clipData in
            MistakeNoteQuestion(
                id: clipData.id,
                questionNum: clipData.questionNum,
                question: clipData.question,
                correction: clipData.correction,
                keyConcepts: clipData.keyConcepts,
                date: clipData.date
            )
        }
    } catch {
        errorMessage = "문제를 불러오는데 실패했습니다."
        print("Failed to load clips (category: \(category)): \(error)")
    }

    isLoading = false
}
```

기존 두 메서드를 제거하고 호출부 교체:

```swift
// loadDailyInitialData 내
await loadClips(category: 2, testInfo: extractTestInfo(from: firstDay))

// handleTabChange - daily 분기
await loadClips(category: 2, testInfo: extractTestInfo(from: selectedDay))

// handleTabChange - mockExam 분기
await loadClips(category: 3, testInfo: extractSessionInfo(from: selectedSession))

// loadMockExamInitialData 내
await loadClips(category: 3, testInfo: extractSessionInfo(from: session))

// transform - daySelected 분기
Task { await self.loadClips(category: 2, testInfo: self.extractTestInfo(from: day)) }

// transform - sessionSelected 분기
Task { await self.loadClips(category: 3, testInfo: self.extractSessionInfo(from: session)) }
```

**Step 7: 빌드 확인**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug -destination 'generic/platform=iOS' build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

---

### Task 3: MistakeNoteMainView — FilterChipButton 호출부 QuestionFilter 반영

Task 2에서 `filterAll` 타입이 `String → QuestionFilter`로 바뀌므로 뷰 호출부도 수정한다.

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`

**Step 1: FilterChipButton options 변경**

```swift
// 변경 전
FilterChipButton(
    title: "모두",
    options: ["모두", "오답만"],
    selectedOption: Binding(
        get: { viewModel.filterAll },
        set: { input.send(.filterAllChanged($0)) }
    ),
    ...
)

// 변경 후
FilterChipButton(
    title: "모두",
    options: QuestionFilter.allCases.map { $0.rawValue },
    selectedOption: Binding(
        get: { viewModel.filterAll.rawValue },
        set: { raw in
            if let filter = QuestionFilter(rawValue: raw) {
                input.send(.filterAllChanged(filter))
            }
        }
    ),
    ...
)
```

**Step 2: 빌드 확인**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug -destination 'generic/platform=iOS' build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

---

### Task 4: Logger로 에러 처리 개선

`print()` 호출을 Account 모듈과 동일한 패턴의 `Logger.make(category:)`로 교체한다.

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`
- Modify: `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewModel/ProblemDetailViewModel.swift`

**Step 1: MistakeNoteListViewModel Logger 추가**

```swift
// import 추가
import os

// 클래스 내 프로퍼티 추가
private let logger = Logger.make(category: "MistakeNoteListViewModel")
```

**Step 2: print() → logger.error() 교체**

4곳의 print() 모두 교체:

```swift
// loadDailyInitialData catch
logger.error("Failed to load daily initial data: \(error)")

// loadMockExamInitialData catch
logger.error("Failed to load mock exam initial data: \(error)")

// loadClips catch (Task 2에서 통합된 메서드)
logger.error("Failed to load clips (category: \(category)): \(error)")
```

**Step 3: ProblemDetailViewModel Logger 추가**

```swift
// import 추가
import os

// 클래스 내 프로퍼티 추가
private let logger = Logger.make(category: "ProblemDetailViewModel")

// catch 블록 변경 전
print("Failed to load problem detail: \(error)")

// 변경 후
logger.error("Failed to load problem detail: \(error)")
```

**Step 4: 빌드 확인**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug -destination 'generic/platform=iOS' build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

---

### Task 5: MistakeNoteFilterBarView 추출

`MistakeNoteMainView`의 filterChipsRow, resetFilterButton, subjectFilterButton 을 별도 컴포넌트로 분리한다.

**Files:**
- Create: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteFilterBarView.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`

**Step 1: MistakeNoteFilterBarView.swift 생성**

```swift
//
//  MistakeNoteFilterBarView.swift
//  MistakeNote
//

import SwiftUI
import DesignSystem
import QRIZUtils

struct MistakeNoteFilterBarView: View {

    // MARK: - Properties

    let filterAll: QuestionFilter
    let hasActiveConceptFilter: Bool
    let hasFilterForSubject: (Subject) -> Bool
    let onFilterAllChanged: (QuestionFilter) -> Void
    let onSubjectTapped: (Subject) -> Void
    let onReset: () -> Void

    @State private var expandedFilter: FilterType? = nil

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            FilterChipButton(
                title: "모두",
                options: QuestionFilter.allCases.map { $0.rawValue },
                selectedOption: Binding(
                    get: { filterAll.rawValue },
                    set: { raw in
                        if let filter = QuestionFilter(rawValue: raw) {
                            onFilterAllChanged(filter)
                        }
                    }
                ),
                isExpanded: Binding(
                    get: { expandedFilter == .all },
                    set: { expandedFilter = $0 ? .all : nil }
                )
            )

            Divider()
                .frame(height: 32)
                .background(Color.coolNeutral200)

            if hasActiveConceptFilter {
                resetButton
            }

            subjectButton(subject: .one, title: "1과목")
            subjectButton(subject: .two, title: "2과목")

            Spacer()
        }
    }

    // MARK: - Subviews

    private var resetButton: some View {
        Button {
            onReset()
        } label: {
            HStack(spacing: 4) {
                Text("초기화")
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundColor(Color.coolNeutral500)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.coolNeutral200, lineWidth: 1)
            )
        }
    }

    private func subjectButton(subject: Subject, title: String) -> some View {
        let isActive = hasFilterForSubject(subject)

        return Button {
            onSubjectTapped(subject)
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isActive ? .white : Color.coolNeutral500)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color.coolNeutral700 : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? Color.clear : Color.coolNeutral200, lineWidth: 1)
            )
        }
    }
}

// MARK: - FilterType

private enum FilterType {
    case all
}
```

**Step 2: MistakeNoteMainView.swift 수정**

- 상단 `@State private var expandedFilter: FilterType? = nil` 제거
- `FilterType` enum 제거 (파일 하단)
- `filterChipsRow`, `resetFilterButton`, `subjectFilterButton` 제거
- `questionSection` 에서 `filterChipsRow` → `MistakeNoteFilterBarView` 호출로 교체:

```swift
var questionSection: some View {
    VStack(spacing: 0) {
        MistakeNoteFilterBarView(
            filterAll: viewModel.filterAll,
            hasActiveConceptFilter: !viewModel.selectedConceptsFilter.isEmpty,
            hasFilterForSubject: { viewModel.hasFilterForSubject($0) },
            onFilterAllChanged: { input.send(.filterAllChanged($0)) },
            onSubjectTapped: { subject in
                sheetSubject = subject
                showSubjectFilterSheet = true
            },
            onReset: { input.send(.resetConceptFilters) }
        )
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .zIndex(1)

        questionCountLabel
            .padding(.horizontal, 18)
            .padding(.top, 16)

        questionListOrEmptyView
    }
}
```

**Step 3: 빌드 확인**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug -destination 'generic/platform=iOS' build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`
