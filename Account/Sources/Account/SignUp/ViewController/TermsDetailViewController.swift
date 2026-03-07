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
public protocol TermsDetailDismissible: AnyObject {
    func dismissTermsDetail()
}

public final class TermsDetailViewController: UIViewController {

    // MARK: - Properties

    public weak var dismissDelegate: TermsDetailDismissible?
    private let rootView: TermsDetailMainView
    private let viewModel: TermsDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(viewModel: TermsDetailViewModel) {
        self.rootView = TermsDetailMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func loadView() {
        self.view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.send(.viewDidLoad)
    }

    // MARK: - Methods

    private func bind() {
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .configureTitle(let title):
                    rootView.updateTitle(title)

                case .pdfLoaded(let data):
                    guard let document = PDFDocument(data: data) else {
                        showOneButtonAlert(with: "문서를 불러올 수 없습니다.", storingIn: &cancellables)
                        return
                    }
                    rootView.configPDF(document: document)

                case .showErrorAlert(let message):
                    showOneButtonAlert(with: message, storingIn: &cancellables)

                case .dismissModal:
                    dismissDelegate?.dismissTermsDetail()
                }
            }
            .store(in: &cancellables)

        rootView.dismissButtonTappedPublisher
            .sink { [weak self] in self?.viewModel.send(.dismissButtonTapped) }
            .store(in: &cancellables)
    }
}
