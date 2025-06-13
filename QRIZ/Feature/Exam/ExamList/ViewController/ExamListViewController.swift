//
//  ExamListViewController.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import UIKit
import Combine

final class ExamListViewController: UIViewController {
    
    // MARK: - Properties
    private let listCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    private let examListFilterButton: ExamListFilterButton = .init()
    private let examListFilterItemsView: ExamListFilterItemsView = .init()
    private let customClearView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private var examList: [ExamListDataInfo] = []
    
    private let viewModel: ExamListViewModel
    private let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: ExamCoordinator?
    
    // MARK: - Initializers
    init(viewModel: ExamListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListViewController")
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setNavigationItems()
        setCollectionViewDataSourceAndDelegate()
        addViews()
        bind()
        input.send(.viewDidLoad)
        addClearViewAction()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func bind() {
        let mergedInput = input.merge(with: examListFilterButton.input, examListFilterItemsView.input)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed:
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                case .setCollectionViewItem(let examList):
                    self.examList = examList
                    listCollectionView.reloadData()
                    listCollectionView.setContentOffset(.zero, animated: false)
                case .selectFilterItem(let filterType):
                    examListFilterItemsView.setItemSelected(selectedType: filterType)
                    examListFilterButton.setText(filterType: filterType)
                case .setFilterItemsVisibility(let isVisible):
                    examListFilterItemsView.isHidden = !isVisible
                    customClearView.isHidden = !isVisible
                case .moveToExamView(let examId):
                    coordinator?.showExamSummary(examId: examId)
                case .cancelExamListView:
                    tabBarController?.tabBar.isHidden = false
                    if let coordinator = coordinator {
                        coordinator.delegate?.didQuitExam(coordinator)
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "모의고사"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        self.navigationItem.titleView = titleView
        
        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(xmark, for: .normal)
        button.addTarget(self, action: #selector(cancelView), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func cancelView() {
         input.send(.cancelButtonClicked)
    }
    
    private func setCollectionViewDataSourceAndDelegate() {
        listCollectionView.register(ExamListCell.self, forCellWithReuseIdentifier: ExamListCell.identifier)
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
    }
    
    private func addClearViewAction() {
        customClearView.isUserInteractionEnabled = true
        customClearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendOtherAreaClicked)))
    }
    
    @objc private func sendOtherAreaClicked() {
        input.send(.otherAreaClicked)
    }
}

extension ExamListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        examList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExamListCell.identifier, for: indexPath) as? ExamListCell else {
            return UICollectionViewCell()
        }
        cell.configure(examInfo: examList[indexPath.item])
        return cell
    }
}

extension ExamListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        input.send(.examClicked(idx: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - Auto Layout
extension ExamListViewController {
    private func addViews() {
        self.view.addSubview(listCollectionView)
        self.view.addSubview(examListFilterButton)
        self.view.addSubview(customClearView)
        self.view.addSubview(examListFilterItemsView)
        
        listCollectionView.translatesAutoresizingMaskIntoConstraints = false
        examListFilterButton.translatesAutoresizingMaskIntoConstraints = false
        customClearView.translatesAutoresizingMaskIntoConstraints = false
        examListFilterItemsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            examListFilterButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 24),
            examListFilterButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            examListFilterButton.widthAnchor.constraint(equalToConstant: 90),
            examListFilterButton.heightAnchor.constraint(equalToConstant: 32),
            
            examListFilterItemsView.topAnchor.constraint(equalTo: examListFilterButton.bottomAnchor, constant: 8),
            examListFilterItemsView.leadingAnchor.constraint(equalTo: examListFilterButton.leadingAnchor),
            
            listCollectionView.topAnchor.constraint(equalTo: examListFilterButton.bottomAnchor, constant: 24),
            listCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            listCollectionView.leadingAnchor.constraint(equalTo: examListFilterButton.leadingAnchor),
            listCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            
            customClearView.topAnchor.constraint(equalTo: self.view.topAnchor),
            customClearView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            customClearView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            customClearView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}
