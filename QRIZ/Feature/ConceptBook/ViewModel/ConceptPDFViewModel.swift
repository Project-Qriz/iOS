//
//  ConceptPDFViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import Foundation
import Combine
import OSLog

final class ConceptPDFViewModel {
    
    // MARK: - Properties
    
    private let chapter: Chapter
    private let conceptItem: ConceptItem
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "ConceptPDFViewModel")
    
    // MARK: - Initialize
    
    init(chapter: Chapter, conceptItem: ConceptItem) {
        self.chapter = chapter
        self.conceptItem = conceptItem
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    let subjectName = Subject.from(chapter: chapter) == .one ? "1과목" : "2과목"
                    self.outputSubject.send(
                        .configureHeader(
                            subject: subjectName,
                            chapter: self.chapter.cardTitle,
                            concept: self.conceptItem.title
                        )
                    )
                    self.loadPDF()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Functions
    
    private func loadPDF() {
        guard let pdfURL = Bundle.main.url(
            forResource: conceptItem.fileName,
            withExtension: "pdf"
        ) else {
            logger.error("PDF resource not found in bundle: \(self.conceptItem.fileName, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: "문서를 찾을 수 없습니다."))
            return
        }
        
        do {
            let data = try Data(contentsOf: pdfURL)
            outputSubject.send(.pdfLoaded(data))
        } catch {
            logger.error("Error loading PDF data: \(error.localizedDescription, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: "문서 불러오기에 실패했습니다."))
        }
    }
}

extension ConceptPDFViewModel {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case configureHeader(subject: String, chapter: String, concept: String)
        case pdfLoaded(Data)
        case showErrorAlert(title: String)
    }
}
