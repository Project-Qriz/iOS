// MistakeNote/Tests/MistakeNoteTests/UnitTests/SubjectFilterSheetViewModelTests.swift

import Testing
@testable import MistakeNote
import QRIZUtils

@MainActor
@Suite("SubjectFilterSheetViewModel 테스트", .serialized)
struct SubjectFilterSheetViewModelTests {

    private func makeSUT(
        availableConcepts: Set<String> = [],
        initialSubject: Subject = .one,
        initialSelectedConcepts: Set<String> = []
    ) -> SubjectFilterSheetViewModel {
        SubjectFilterSheetViewModel(
            availableConcepts: availableConcepts,
            initialSubject: initialSubject,
            initialSelectedConcepts: initialSelectedConcepts
        )
    }

    // MARK: - hasSelections

    @Test("selectedConcepts 비어있을 때 hasSelections는 false")
    func hasSelections_false_whenEmpty() {
        let sut = makeSUT()
        #expect(sut.hasSelections == false)
    }

    @Test("selectedConcepts 있을 때 hasSelections는 true")
    func hasSelections_true_whenNotEmpty() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        #expect(sut.hasSelections == true)
    }

    // MARK: - hasChanges

    @Test("초기값과 동일하면 hasChanges는 false")
    func hasChanges_false_whenSameAsInitial() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        #expect(sut.hasChanges == false)
    }

    @Test("selectedConcepts 변경하면 hasChanges는 true")
    func hasChanges_true_whenDifferentFromInitial() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        sut.selectedConcepts = ["WHERE절"]
        #expect(sut.hasChanges == true)
    }

    // MARK: - reset

    @Test("reset() 호출 시 selectedConcepts 비워짐")
    func reset_clearsSelectedConcepts() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        sut.reset()
        #expect(sut.selectedConcepts.isEmpty)
    }

    // MARK: - availableChapters

    @Test("availableConcepts에 포함된 chapter만 반환")
    func availableChapters_onlyIncludesChaptersWithAvailableConcepts() {
        let firstChapter = Subject.one.chapters[0]
        let conceptInFirstChapter = firstChapter.concepts[0]

        let sut = makeSUT(
            availableConcepts: [conceptInFirstChapter],
            initialSubject: .one
        )

        #expect(sut.availableChapters.contains(firstChapter))
    }

    @Test("availableConcepts가 비어있으면 availableChapters도 비어있음")
    func availableChapters_emptyWhenNoAvailableConcepts() {
        let sut = makeSUT(availableConcepts: [], initialSubject: .one)
        #expect(sut.availableChapters.isEmpty)
    }
}
