import Testing
import Foundation
@testable import MistakeNote
import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("MistakeNoteListViewModel 테스트", .serialized)
struct MistakeNoteListViewModelTests {

    private func makeSUT(service: MockMistakeNoteService = .init()) -> MistakeNoteListViewModel {
        MistakeNoteListViewModel(service: service)
    }

    // MARK: - displayedQuestions 필터

    @Test("필터 없을 때 displayedQuestions는 전체 반환")
    func displayedQuestions_noFilter_returnsAll() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, correction: true),
            .make(id: 2, correction: false),
        ]
        #expect(sut.displayedQuestions.count == 2)
    }

    @Test("incorrectOnly 필터 적용 시 오답만 반환")
    func displayedQuestions_incorrectOnly_excludesCorrect() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, correction: true),
            .make(id: 2, correction: false),
            .make(id: 3, correction: false),
        ]
        sut.filterAllChanged(.incorrectOnly)
        #expect(sut.displayedQuestions.count == 2)
        #expect(sut.displayedQuestions.allSatisfy { !$0.correction })
    }

    @Test("conceptFilter 적용 시 해당 concept 문제만 반환")
    func displayedQuestions_conceptFilter_returnsMatchingOnly() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, keyConcepts: "SELECT문"),
            .make(id: 2, keyConcepts: "WHERE절"),
            .make(id: 3, keyConcepts: "SELECT문, JOIN"),
        ]
        sut.conceptFilterApplied(["SELECT문"], nil)
        #expect(sut.displayedQuestions.count == 2)
    }

    // MARK: - 필터 리셋

    @Test("tabSelected() 호출 시 모든 필터 리셋")
    func tabSelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.tabSelected(.mockExam)

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
        #expect(sut.selectedFilterSubject == nil)
    }

    @Test("resetConceptFilters() 호출 시 concept 필터 리셋")
    func resetConceptFilters_resetsConceptAndSubjectFilter() {
        let sut = makeSUT()
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.resetConceptFilters()

        #expect(sut.selectedConceptsFilter.isEmpty)
        #expect(sut.selectedFilterSubject == nil)
    }

    @Test("daySelected() 호출 시 모든 필터 리셋")
    func daySelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.daySelected("Day1")

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
    }

    @Test("sessionSelected() 호출 시 모든 필터 리셋")
    func sessionSelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.sessionSelected("1회차")

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
    }

    // MARK: - hasFilterForSubject

    @Test("선택된 concept이 해당 subject에 속하면 true")
    func hasFilterForSubject_true_whenSubjectConceptSelected() {
        let sut = makeSUT()
        let subject = Subject.one
        let conceptInSubject = subject.chapters[0].concepts[0]
        sut.conceptFilterApplied([conceptInSubject], subject)

        #expect(sut.hasFilterForSubject(subject) == true)
    }

    @Test("선택된 concept이 없으면 false")
    func hasFilterForSubject_false_whenNoConceptSelected() {
        let sut = makeSUT()
        #expect(sut.hasFilterForSubject(.one) == false)
    }

    // MARK: - 내비게이션

    @Test("questionTapped() → onNavigate(.navigateToClipDetail)")
    func questionTapped_triggersNavigateToClipDetail() {
        let sut = makeSUT()
        var output: MistakeNoteListViewModel.Output?
        sut.onNavigate = { output = $0 }

        sut.questionTapped(.make(id: 42))

        if case .navigateToClipDetail(let clipId) = output {
            #expect(clipId == 42)
        } else {
            Issue.record("Expected navigateToClipDetail")
        }
    }

    @Test("goToExamTapped() → onNavigate(.navigateToExam)")
    func goToExamTapped_triggersNavigateToExam() {
        let sut = makeSUT()
        var output: MistakeNoteListViewModel.Output?
        sut.onNavigate = { output = $0 }
        sut.selectedTab = .mockExam

        sut.goToExamTapped()

        if case .navigateToExam(let tab) = output {
            #expect(tab == .mockExam)
        } else {
            Issue.record("Expected navigateToExam")
        }
    }

    // MARK: - 비동기 로딩

    @Test("viewDidLoad() 성공 → availableDays 설정")
    func viewDidLoad_setsAvailableDays() async {
        let service = MockMistakeNoteService()
        service.completedDaysResult = .success(
            CompletedDailyDaysResponse(code: 1, msg: "ok", data: .init(days: ["Day1", "Day2"]))
        )
        service.clipsResult = .success(ClipsResponse(code: 1, msg: "ok", data: []))
        let sut = makeSUT(service: service)

        await sut.viewDidLoad()

        #expect(sut.availableDays == ["Day1", "Day2"])
        #expect(sut.selectedDay == "Day1")
        #expect(!sut.isLoading)
    }

    @Test("viewDidLoad() 실패 → errorMessage 설정")
    func viewDidLoad_setsErrorMessage_onFailure() async {
        let service = MockMistakeNoteService()
        service.completedDaysResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)

        await sut.viewDidLoad()

        #expect(sut.errorMessage != nil)
        #expect(!sut.isLoading)
    }
}
