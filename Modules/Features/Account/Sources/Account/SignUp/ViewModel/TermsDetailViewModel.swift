//
//  TermsDetailViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/18/25.
//

import Foundation
import Combine
import os

@MainActor
public final class TermsDetailViewModel {

    // MARK: - Properties

    private let term: TermItem
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.make(category: "TermsDetailViewModel")

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init(termItem: TermItem) {
        self.term = termItem
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:
            outputSubject.send(.configureTitle(term.title))
            if let documentUrl = term.documentUrl, let url = URL(string: documentUrl) {
                outputSubject.send(.showWebDocument(url))
            } else {
                loadPDF()
            }

        case .dismissButtonTapped:
            outputSubject.send(.dismissModal)
        }
    }

    private func loadPDF() {
        guard let pdfName = term.pdfName,
              let url = Bundle.main.url(forResource: pdfName, withExtension: "pdf") else {
            logger.error("PDF not found for term: \(self.term.title, privacy: .public)")
            outputSubject.send(.showErrorAlert("문서를 찾을 수 없습니다."))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            outputSubject.send(.pdfLoaded(data))
        } catch {
            logger.error("PDF load error: \(error.localizedDescription, privacy: .public)")
            outputSubject.send(.showErrorAlert("문서 불러오기에 실패했습니다."))
        }
    }
}

extension TermsDetailViewModel {
    enum Input {
        case viewDidLoad
        case dismissButtonTapped
    }

    enum Output {
        case configureTitle(String)
        case showWebDocument(URL)
        case pdfLoaded(Data)
        case showErrorAlert(String)
        case dismissModal
    }
}
