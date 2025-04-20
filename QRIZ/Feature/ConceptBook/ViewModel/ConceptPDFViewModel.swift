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
    private let pdfService: PDFService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "ConceptPDFViewModel")
    
    // MARK: - Initialize
    
    init(chapter: Chapter, conceptItem: ConceptItem, pdfService: PDFService = PDFServiceImpl()) {
        self.chapter = chapter
        self.conceptItem = conceptItem
        self.pdfService = pdfService
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
            let networkError = NetworkError.invalidURL(message: conceptItem.url)
            logger.error("Invalid URL for : \(networkError.description, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
            return
        }
        
        Task { await self.performLoadPDF(from: url) }
    }
    
    private func performLoadPDF(from url: URL) async {
        do {
            let data = try await pdfService.fetchPDF(from: url)
            outputSubject.send(.pdfLoaded(data))
            
        } catch let error as NetworkError {
            logger.error("PDF fetch error: \(error.description, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: error.errorMessage))
            
        } catch {
            logger.error("Unhandled error fetching PDF for concept: \(String(describing: error), privacy: .public)")
            outputSubject.send(.showErrorAlert(title: NetworkError.unknownError.errorMessage))
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
