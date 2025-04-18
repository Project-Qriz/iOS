//
//  ChapterDetailViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import Foundation
import Combine

final class ChapterDetailViewModel {
    
    // MARK: - Properties
    
    private let chapter: Chapter
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(chapter: Chapter) {
        self.chapter = chapter
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    self.outputSubject.send(.configureChapter(self.chapter))
                case .conceptTapped(let concept):
                    self.outputSubject.send(.navigateToConceptDetail(concept))
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChapterDetailViewModel {
    enum Input {
        case viewDidLoad
        case conceptTapped(String)
    }
    
    enum Output {
        case configureChapter(Chapter)
        case navigateToConceptDetail(String)
    }
}
