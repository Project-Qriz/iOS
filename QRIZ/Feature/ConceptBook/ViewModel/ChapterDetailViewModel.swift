//
//  ChapterDetailViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import Foundation
import Combine

typealias ConceptItem = (title: String, fileName: String)

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
                    let items = self.chapter.conceptItems
                    self.outputSubject.send(.configureChapter(chapter: self.chapter,conceptItems: items))
                    
                case .conceptTapped(let conceptItem):
                    self.outputSubject.send(.navigateToConceptPDFView(self.chapter, conceptItem))
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChapterDetailViewModel {
    enum Input {
        case viewDidLoad
        case conceptTapped(ConceptItem)
    }
    
    enum Output {
        case configureChapter(chapter: Chapter, conceptItems: [ConceptItem])
        case navigateToConceptPDFView(Chapter, ConceptItem)
    }
}
