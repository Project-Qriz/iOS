//
//  ChapterDetailViewModelTests.swift
//  ConceptbookTests
//

import Testing
import Combine
@testable import Conceptbook
import QRIZUtils

@MainActor
@Suite("ChapterDetailViewModel 테스트", .serialized)
struct ChapterDetailViewModelTests {

    @Test("viewDidLoad → 챕터와 개념 목록 emit")
    func viewDidLoadEmitsConfigureChapter() async {
        let chapter = Chapter.dataModeling
        let sut = ChapterDetailViewModel(chapter: chapter)
        let inputSubject = PassthroughSubject<ChapterDetailViewModel.Input, Never>()
        var received: [ChapterDetailViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        await waitForMainQueue()

        #expect(received.count == 1)
        guard case .configureChapter(let receivedChapter, let items) = received[0] else {
            Issue.record("Expected .configureChapter")
            return
        }
        #expect(receivedChapter == chapter)
        #expect(items == chapter.conceptItems)
    }

    @Test("conceptTapped → 챕터와 개념 아이템으로 PDF 화면 이동 emit")
    func conceptTappedEmitsNavigation() async {
        let chapter = Chapter.sqlBasic
        let sut = ChapterDetailViewModel(chapter: chapter)
        let inputSubject = PassthroughSubject<ChapterDetailViewModel.Input, Never>()
        var received: [ChapterDetailViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        let conceptItem = chapter.conceptItems[0]
        inputSubject.send(.conceptTapped(conceptItem))
        await waitForMainQueue()

        #expect(received.count == 1)
        guard case .navigateToConceptPDFView(let receivedChapter, let receivedItem) = received[0] else {
            Issue.record("Expected .navigateToConceptPDFView")
            return
        }
        #expect(receivedChapter == chapter)
        #expect(receivedItem == conceptItem)
    }

    @Test("각 챕터별 conceptItems 수가 올바름")
    func eachChapterHasCorrectConceptItemCount() async {
        for chapter in Chapter.allCases {
            let sut = ChapterDetailViewModel(chapter: chapter)
            let inputSubject = PassthroughSubject<ChapterDetailViewModel.Input, Never>()
            var received: [ChapterDetailViewModel.Output] = []
            var cancellables = Set<AnyCancellable>()

            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { received.append($0) }
                .store(in: &cancellables)

            inputSubject.send(.viewDidLoad)
            await waitForMainQueue()

            if case .configureChapter(_, let items) = received.first {
                #expect(items.count == chapter.conceptItems.count, "챕터 \(chapter)의 개념 수 불일치")
            } else {
                Issue.record("Expected .configureChapter for \(chapter)")
            }
        }
    }
}
