//
//  ConceptPDFViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import Foundation
import Combine
import PDFKit

final class ConceptPDFViewModel {
    
    // MARK: - Properties
    
    private let chapter: Chapter
    private let conceptItem: ConceptItem
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
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
        guard let url = URL(string: conceptItem.url) else {
            outputSubject.send(.showError("잘못된 URL입니다."))
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, let doc = PDFDocument(data: data) {
                DispatchQueue.main.async {
                    self.outputSubject.send(.pdfLoaded(doc))
                }
            } else {
                DispatchQueue.main.async {
                    let msg = error?.localizedDescription ?? "PDF 로드에 실패했습니다."
                    self.outputSubject.send(.showError(msg))
                }
            }
        }.resume()
    }
}

extension ConceptPDFViewModel {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case configureHeader(subject: String, chapter: String, concept: String)
        case pdfLoaded(PDFDocument)
        case showError(String)
    }
}
