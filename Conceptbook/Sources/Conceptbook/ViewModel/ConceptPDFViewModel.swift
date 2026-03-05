//
//  ConceptPDFViewModel.swift
//  Conceptbook
//
//  Created by 김세훈 on 4/19/25.
//

import Foundation
import Combine
import OSLog
import QRIZUtils

@MainActor
final class ConceptPDFViewModel {

    // MARK: - Properties

    private let chapter: Chapter
    private let conceptItem: ConceptItem
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "ConceptPDFViewModel")

    // MARK: - Initialization

    init(chapter: Chapter, conceptItem: ConceptItem) {
        self.chapter = chapter
        self.conceptItem = conceptItem
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    let subjectName = QRIZUtils.Subject.from(chapter: chapter)?.displayName ?? ""
                    self.outputSubject.send(
                        .configureHeader(
                            subject: subjectName,
                            chapter: chapter.cardTitle,
                            concept: conceptItem.title
                        )
                    )
                    Task { await self.loadPDF() }
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func loadPDF() async {
        guard let pdfURL = Bundle.main.url(
            forResource: conceptItem.fileName,
            withExtension: "pdf"
        ) else {
            logger.error("PDF resource not found in bundle: \(self.conceptItem.fileName, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: "문서를 찾을 수 없습니다."))
            return
        }

        do {
            let data = try await readData(from: pdfURL)
            outputSubject.send(.pdfLoaded(data))
        } catch {
            logger.error("Error loading PDF data: \(error.localizedDescription, privacy: .public)")
            outputSubject.send(.showErrorAlert(title: "문서 불러오기에 실패했습니다."))
        }
    }

    private nonisolated func readData(from url: URL) async throws -> Data {
        try Data(contentsOf: url)
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
