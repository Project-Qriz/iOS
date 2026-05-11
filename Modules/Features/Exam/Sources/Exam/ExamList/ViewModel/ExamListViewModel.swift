//
//  ExamListViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import Foundation
import Combine
import QRIZUtils
import QRIZNetwork

@MainActor
final class ExamListViewModel {

    // MARK: - Enums

    enum Input {
        case viewDidLoad
        case reloadList
        case filterButtonClicked
        case filterItemSelected(filterType: ExamListFilterType)
        case otherAreaClicked
        case cancelButtonClicked
        case examClicked(examId: Int)
    }

    enum Output {
        case fetchFailed
        case setCollectionViewItem(examList: [ExamListDataInfo])
        case selectFilterItem(filterType: ExamListFilterType)
        case setFilterItemsVisibility(isVisible: Bool)
        case moveToExamView(examId: Int)
        case cancelExamListView
    }

    // MARK: - Properties

    private var filterSelected: ExamListFilterType = .total
    private var examList: [ExamListDataInfo] = []
    private var isFilterItemsPresented: Bool = false

    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var fetchTask: Task<Void, Never>?

    private let examService: any ExamService

    // MARK: - Initialization

    init(examService: any ExamService) {
        self.examService = examService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .reloadList:
                filterSelected = .total
                output.send(.selectFilterItem(filterType: .total))
                fetchData()
            case .filterButtonClicked:
                handleFilterButtonClicked()
            case .filterItemSelected(let filterType):
                handleFilterItemSelected(filterType)
            case .otherAreaClicked:
                handleOtherAreaClicked()
            case .cancelButtonClicked:
                output.send(.cancelExamListView)
            case .examClicked(let examId):
                output.send(.moveToExamView(examId: examId))
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    private func fetchData() {
        let currentFilter = filterSelected
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await examService.getExamList(filterType: currentFilter)
                guard !Task.isCancelled else { return }
                examList = response.data
                output.send(.setCollectionViewItem(examList: examList))
                output.send(.selectFilterItem(filterType: currentFilter))
            } catch {
                guard !Task.isCancelled else { return }
                output.send(.fetchFailed)
            }
        }
    }

    private func handleFilterButtonClicked() {
        isFilterItemsPresented.toggle()
        output.send(.setFilterItemsVisibility(isVisible: isFilterItemsPresented))
    }

    private func handleFilterItemSelected(_ filterType: ExamListFilterType) {
        guard filterSelected != filterType else { return }
        filterSelected = filterType
        isFilterItemsPresented = false
        output.send(.setFilterItemsVisibility(isVisible: false))
        fetchData()
    }

    private func handleOtherAreaClicked() {
        guard isFilterItemsPresented else { return }
        isFilterItemsPresented = false
        output.send(.setFilterItemsVisibility(isVisible: false))
    }
}
