//
//  ConceptPDFViewController.swift
//  Conceptbook
//
//  Created by 김세훈 on 4/19/25.
//

import UIKit
import DesignSystem
import Combine
import PDFKit
import QRIZUtils

final class ConceptPDFViewController: UIViewController {

    // MARK: - Properties

    private let rootView: ConceptPDFMainView
    private let conceptPDFVM: ConceptPDFViewModel
    private var cancellables = Set<AnyCancellable>()
    private let inputSubject = PassthroughSubject<ConceptPDFViewModel.Input, Never>()

    // MARK: - Initialization

    init(conceptPDFViewModel: ConceptPDFViewModel) {
        self.conceptPDFVM = conceptPDFViewModel
        self.rootView = ConceptPDFMainView()
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        inputSubject.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBar.defaultBackButtonStyle(systemImageName: "xmark")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBar.defaultBackButtonStyle()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    // MARK: - Methods

    private func bind() {
        let output = conceptPDFVM.transform(input: inputSubject.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .configureHeader(let subject, let chapterTitle, let conceptName):
                    self.setNavigationBarTitle(title: conceptName, textColor: .coolNeutral800)
                    self.rootView.configure(subject: subject, chapter: chapterTitle)

                case .pdfLoaded(let data):
                    guard let document = PDFDocument(data: data) else {
                        self.showOneButtonAlert(with: "문서를 불러올 수 없습니다. 다시 시도해 주세요.", storingIn: &cancellables)
                        return
                    }
                    self.rootView.configure(document: document)

                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
    }
}
