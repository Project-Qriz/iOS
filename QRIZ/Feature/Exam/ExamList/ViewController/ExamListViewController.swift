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
    
    private var examList: [ExamListDataInfo] = []
    
    private let viewModel: ExamListViewModel
    private let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: ExamListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
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
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
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
                case .selectFilterItem(let filterType):
                    print("")
                case .moveToExamView(let examId):
                    print("EXAMID: \(examId)")
                case .cancelExamListView:
                    self.dismiss(animated: true)
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
        print(examList[indexPath.item])
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
        
        listCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            listCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            listCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            listCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            listCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
        ])
    }
}
