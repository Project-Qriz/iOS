//
//  ConceptPDFViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import UIKit
import Combine
import PDFKit

final class ConceptPDFViewController: UIViewController {
    
    // MARK: - Enums
    private enum Attributes {
        static let loadErrorMessage = "문서를 불러올 수 없습니다. 다시 시도해 주세요."
    }
    
    // MARK: - UI
    
    let rootView: ConceptPDFMainView
    private let conceptPDFVM: ConceptPDFViewModel
    private var cancellables = Set<AnyCancellable>()
    private let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()
    
    // MARK: - Initialize
    
    init(conceptPDFViewModel: ConceptPDFViewModel) {
        self.conceptPDFVM = conceptPDFViewModel
        self.rootView = ConceptPDFMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let output = conceptPDFVM.transform(input: inputSubject.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .configureHeader(let subject, let chapterTitle, let conceptName):
                    self.setNavigationBarTitle(title: conceptName)
                    self.rootView.configHeader(subject: subject, chapter: chapterTitle)
                    
                case .pdfLoaded(let data):
                    guard let document = PDFDocument(data: data) else {
                        self.showOneButtonAlert(with: Attributes.loadErrorMessage, storingIn: &cancellables)
                        return
                    }
                    
                    self.rootView.configPDF(document: document)
                    
                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
    }
}
