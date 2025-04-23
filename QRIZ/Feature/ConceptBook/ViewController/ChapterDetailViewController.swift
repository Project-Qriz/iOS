//
//  ChapterDetailViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import UIKit
import Combine

final class ChapterDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: ConceptBookCoordinator?
    let rootView: ChapterDetailMainView
    private let chapterDetailVM: ChapterDetailViewModel
    private let inputSubject = PassthroughSubject<ChapterDetailViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(chapterDetailVM: ChapterDetailViewModel) {
        self.chapterDetailVM = chapterDetailVM
        self.rootView = ChapterDetailMainView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBar.defaultBackButtonStyle()
        appearance.backgroundColor = .customBlue50
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let apearance = UINavigationBar.defaultBackButtonStyle()
        navigationController?.navigationBar.standardAppearance   = apearance
        navigationController?.navigationBar.scrollEdgeAppearance = apearance
        navigationController?.navigationBar.compactAppearance    = apearance
    }
    
    // MARK: - Functions
    
    private func bind() {
        let conceptTapped = rootView.menuListView.tappedPublisher.map { ChapterDetailViewModel.Input.conceptTapped($0) }
        
        let input = inputSubject
            .merge(with: conceptTapped)
            .eraseToAnyPublisher()
        
        chapterDetailVM.transform(input: input)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .configureChapter(let chapter, let items):
                    self.rootView.configure(with: chapter, items: items)
                    
                case .navigateToConceptPDFView(let chapter, let conceptItem):
                    self.coordinator?.showConceptPDFView(chapter: chapter, conceptItem: conceptItem)
                }
            }
            .store(in: &cancellables)
    }
}
