//
//  ConceptBookViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import Combine

final class ConceptBookViewController: UIViewController {
    
    // MARK: - Enumsc
    
    enum Attributes {
        static let navigationTitle = "개념서"
    }
    
    // MARK: - Properties
    
    weak var coordinator: ConceptBookCoordinator?
    let rootView: ConceptBookMainView
    private let conceptBookVM: ConceptBookViewModel
    private let inputSubject = PassthroughSubject<ConceptBookViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(conceptBookVM: ConceptBookViewModel) {
        self.conceptBookVM = conceptBookVM
        self.rootView = ConceptBookMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: Attributes.navigationTitle)
        bind()
        inputSubject.send(.viewDidLoad)
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let cardViewTapped = rootView.chapterTappedPublisher.map { ConceptBookViewModel.Input.cardViewTapped($0) }

        let input = inputSubject
            .merge(with: cardViewTapped)
            .eraseToAnyPublisher()

        let output = conceptBookVM.transform(input: input)

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .subjectsLoaded(let subjects):
                    self.rootView.configure(with: subjects)
                    
                case .navigateToChapterDetailView(let chapter):
                    self.coordinator?.showChapterDetailView(chapter: chapter)
                }
            }
            .store(in: &cancellables)
    }
}
