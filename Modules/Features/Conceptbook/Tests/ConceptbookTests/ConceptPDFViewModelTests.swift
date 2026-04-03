//
//  ConceptPDFViewModelTests.swift
//  ConceptbookTests
//

import Testing
import Foundation
import Combine
@testable import Conceptbook
import QRIZUtils

@MainActor
@Suite("ConceptPDFViewModel 테스트", .serialized)
struct ConceptPDFViewModelTests {

    @Test("viewDidLoad → 1과목 챕터는 '1과목' subject로 헤더 구성")
    func viewDidLoadEmitsConfigureHeaderForSubject1() async {
        let chapter = Chapter.dataModeling
        let conceptItem = chapter.conceptItems[0]
        let sut = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
        var received: [ConceptPDFViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()

        guard case .configureHeader(let subject, let chapterTitle, let concept) = received.first else {
            Issue.record("Expected .configureHeader")
            return
        }
        #expect(subject == "1과목")
        #expect(chapterTitle == chapter.cardTitle)
        #expect(concept == conceptItem.title)
    }

    @Test("viewDidLoad → 2과목 챕터는 '2과목' subject로 헤더 구성")
    func viewDidLoadEmitsConfigureHeaderForSubject2() async {
        let chapter = Chapter.sqlBasic
        let conceptItem = chapter.conceptItems[0]
        let sut = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
        var received: [ConceptPDFViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()

        guard case .configureHeader(let subject, let chapterTitle, let concept) = received.first else {
            Issue.record("Expected .configureHeader")
            return
        }
        #expect(subject == "2과목")
        #expect(chapterTitle == chapter.cardTitle)
        #expect(concept == conceptItem.title)
    }

    @Test("viewDidLoad → 테스트 번들에 PDF 없으면 에러 알림 emit")
    func viewDidLoadEmitsErrorWhenPDFNotFoundInTestBundle() async {
        let chapter = Chapter.dataModeling
        let conceptItem = chapter.conceptItems[0]
        let sut = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
        var received: [ConceptPDFViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()
        await waitForMainQueue() // Task { await loadPDF() } 완료 대기

        let hasErrorAlert = received.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }

    @Test("viewDidLoad → 번들에 PDF 있으면 pdfLoaded emit")
    func viewDidLoadEmitsPDFLoadedWhenPDFExists() async throws {
        _ = try #require(
            Bundle.module.url(forResource: "UnderstandOfDataModel", withExtension: "pdf"),
            "Bundle.module에 PDF 없음 — Package.swift 수정 후 Clean Build 필요"
        )

        let chapter = Chapter.dataModeling
        let conceptItem = chapter.conceptItems[0]
        let sut = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem, bundle: .module)
        let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
        var received: [ConceptPDFViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        // readData가 global executor에서 실행되므로 실제 대기 시간 필요
        try await Task.sleep(nanoseconds: 200_000_000)
        await waitForMainQueue()

        let hasPDFLoaded = received.contains {
            if case .pdfLoaded = $0 { return true }
            return false
        }
        #expect(hasPDFLoaded)
    }

    @Test("viewDidLoad → configureHeader가 showErrorAlert보다 먼저 emit")
    func configureHeaderEmittedBeforeErrorAlert() async {
        let chapter = Chapter.sqlAdvanced
        let conceptItem = chapter.conceptItems[0]
        let sut = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
        var received: [ConceptPDFViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()
        await waitForMainQueue()

        guard received.count >= 2 else {
            Issue.record("Expected at least 2 outputs")
            return
        }
        guard case .configureHeader = received[0] else {
            Issue.record("First output should be .configureHeader")
            return
        }
        guard case .showErrorAlert = received[1] else {
            Issue.record("Second output should be .showErrorAlert")
            return
        }
    }
}
