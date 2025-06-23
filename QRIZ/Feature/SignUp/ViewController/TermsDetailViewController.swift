//
//  TermsDetailViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 5/18/25.
//

import UIKit
import Combine
import PDFKit

@MainActor
protocol TermsDetailDismissible: AnyObject {
    func dismissTermsDetail()
}

final class TermsDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    weak var dismissDelegate: TermsDetailDismissible?
    private let rootView: TermsDetailMainView
    private let viewModel: TermsDetailViewModel
    private let inputSubject = PassthroughSubject<TermsDetailViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: TermsDetailViewModel) {
        self.rootView = TermsDetailMainView()
        self.viewModel = viewModel
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
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let dismissButtonTapped = rootView.dismissButtonTappedPublisher.map { TermsDetailViewModel.Input.dismissButtonTapped }
        
        let input = dismissButtonTapped
            .merge(with: inputSubject)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .configureTitle(let title):
                    self.rootView.updateTitle(title)

                case .pdfLoaded(let data):
                    guard let document = PDFDocument(data: data) else {
                        self.showOneButtonAlert(with: "문서를 불러올 수 없습니다.", storingIn: &cancellables)
                        return
                    }
                    self.rootView.configPDF(document: document)

                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)

                case .dismissModal:
                    self.dismissDelegate?.dismissTermsDetail()
                }
            }
            .store(in: &cancellables)
    }
}
