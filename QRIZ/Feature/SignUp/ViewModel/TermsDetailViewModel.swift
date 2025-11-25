//
//  TermsDetailViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/18/25.
//

import Foundation
import Combine
import os.log

final class TermsDetailViewModel {
    
    // MARK: - Properties
    
    private let term: TermItem
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "TermsDetailVM")
    
    // MARK: - Initialize
    
    init(termItem: TermItem) {
        self.term = termItem
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    self.outputSubject.send(.configureTitle(self.term.title))
                    self.loadPDF()
                    
                case .dismissButtonTapped:
                    self.outputSubject.send(.dismissModal)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func loadPDF() {
        guard let url = Bundle.main.url(
            forResource: term.pdfName, withExtension: "pdf") else {
            logger.error("PDF not found: \(self.term.pdfName, privacy: .public)")
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
        case pdfLoaded(Data)
        case showErrorAlert(String)
        case dismissModal
    }
}
