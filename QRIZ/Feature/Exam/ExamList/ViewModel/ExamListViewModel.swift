//
//  ExamListViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import Foundation
import Combine

final class ExamListViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case filterSelected(filterType: ExamListFilterType)
        case cancelButtonClicked
        case examClicked(idx: Int)
    }
    
    enum Output {
        case fetchFailed
        case setCollectionViewItem(examList: [ExamListDataInfo])
        case selectFilterItem(filterType: ExamListFilterType)
        case moveToExamView(examId: Int)
        case cancelExamListView
    }
    
    // MARK: - Properties
    private var filterSelected: ExamListFilterType = .total
    private var examList: [ExamListDataInfo] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let examService: ExamService
    
    // MARK: - Initializers
    init(examService: ExamService) {
        self.examService = examService
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .filterSelected(let filterType):
                self.filterSelected = filterType
                fetchData()
            case .cancelButtonClicked:
                output.send(.cancelExamListView)
            case .examClicked(let idx):
                setExamToPresent(clickedIdx: idx)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task {
            do {
                let response = try await examService.getExamList(filterType: filterSelected)
                examList = response.data
                output.send(.setCollectionViewItem(examList: examList))
                output.send(.selectFilterItem(filterType: filterSelected))
            } catch {
                output.send(.fetchFailed)
            }
        }
    }
    
    private func setExamToPresent(clickedIdx: Int) {
        let sessionText = examList[clickedIdx].session
        guard let session = Int(sessionText.replacingOccurrences(of: "회차", with: "")) else { return }
        output.send(.moveToExamView(examId: session))
    }
}
