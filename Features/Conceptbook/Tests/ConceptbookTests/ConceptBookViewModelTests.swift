//
//  ConceptBookViewModelTests.swift
//  ConceptbookTests
//

import Testing
import Combine
@testable import Conceptbook
import QRIZUtils

@MainActor
@Suite("ConceptBookViewModel 테스트", .serialized)
struct ConceptBookViewModelTests {

    @Test("viewDidLoad → 전체 과목 목록 emit")
    func viewDidLoadEmitsAllSubjects() async {
        let sut = ConceptBookViewModel()
        let inputSubject = PassthroughSubject<ConceptBookViewModel.Input, Never>()
        var received: [ConceptBookViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()

        #expect(received.count == 1)
        guard case .subjectsLoaded(let subjects) = received[0] else {
            Issue.record("Expected .subjectsLoaded")
            return
        }
        #expect(subjects == Subject.allCases)
    }

    @Test("cardViewTapped → 탭된 챕터로 화면 이동 emit")
    func cardViewTappedEmitsNavigation() async {
        let sut = ConceptBookViewModel()
        let inputSubject = PassthroughSubject<ConceptBookViewModel.Input, Never>()
        var received: [ConceptBookViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        let chapter = Chapter.dataModeling
        inputSubject.send(.cardViewTapped(chapter))
        await waitForMainQueue()

        #expect(received.count == 1)
        guard case .navigateToChapterDetailView(let receivedChapter) = received[0] else {
            Issue.record("Expected .navigateToChapterDetailView")
            return
        }
        #expect(receivedChapter == chapter)
    }

    @Test("viewDidLoad 후 cardViewTapped → 두 개 output emit")
    func multipleInputsEmitMultipleOutputs() async {
        let sut = ConceptBookViewModel()
        let inputSubject = PassthroughSubject<ConceptBookViewModel.Input, Never>()
        var received: [ConceptBookViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        inputSubject.send(.cardViewTapped(.sqlBasic))
        await waitForMainQueue()

        #expect(received.count == 2)
    }
}
