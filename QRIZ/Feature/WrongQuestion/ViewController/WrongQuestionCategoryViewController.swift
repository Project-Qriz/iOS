//
//  WrongQuestionCategoryViewController.swift
//  QRIZ
//
//  Created by 이창현 on 1/31/25.
//

import UIKit
import Combine

fileprivate class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let minimumSpacing: CGFloat = 4
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}

final class WrongQuestionCategoryViewController: UIViewController {
    
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 선택"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    private let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        button.backgroundColor = .white
        return button
    }()
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("적용하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .customBlue500
        button.layer.cornerRadius = 8
        return button
    }()
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral200
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var startProcess: () -> Void = { }
    private var completion: () -> Void = { }
    private var stateArr: [[WrongQuestionCategoryCellState]] = []

    // sample data of conceptSet
    private var conceptSet: Set<String> = {
        var set = Set<String>()
        let arr = ConceptCategory.getAllConceptList()
        for row in arr {
            for elem in row {
                set.insert(elem)
            }
        }
        set.remove("식별자")
        set.remove("데이터 모델의 이해")
        set.remove("엔터티")
        set.remove("관계")
        return set
    }()
    private let sectionTitles: [String] = [
        "데이터 모델링의 이해",
        "데이터 모델과 SQL",
        "SQL 기본",
        "SQL 활용",
        "관리 구문"
    ]
    private let items: [[String]] = {
        var arr: [[String]] = ConceptCategory.getAllConceptList()
        for i in 0..<arr.count { arr[i].insert("전체", at: 0) }
        return arr
    }()
    
    private var viewModel: WrongQuestionCategoryViewModel!
    private let input: PassthroughSubject<WrongQuestionCategoryViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(_ starter: @escaping () -> Void, _ completion: @escaping () -> Void) {
        // set will be given by argument -> init(conceptSet: Set<String>, _ starter: @escaping () -> Void, _ completion: @escaping () -> Void)
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .pageSheet
        self.startProcess = starter
        self.completion = completion
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: WrongQuestionCategoryViewController")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setStateArr(conceptSet: conceptSet)
        self.viewModel = WrongQuestionCategoryViewModel(stateArr: stateArr)
        configureSheetPresentation()
        addViews()
        setCollectionView()
        bind()
        addButtonsAction()
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .setCellState(let section, let item, let isAvailable, let isClicked):
                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? WrongQuestionCategoryCollectionViewCell else { return }
                    cell.setState(isAvailable: isAvailable, isClicked: isClicked)
                    stateArr[section][item].isAvailable = isAvailable
                    stateArr[section][item].isClicked = isClicked
                case .submitSuccess:
                    print("Submit Success")
                case .submitFail:
                    print("Submit Failed")
                }
            }
            .store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startProcess()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completion()
    }
    
    private func configureSheetPresentation() {
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.preferredCornerRadius = 32.0
            sheetPresentationController.largestUndimmedDetentIdentifier = .large
        }
    }
    
    private func addButtonsAction() {
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
    }
    
    private func setCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout()
        collectionView.register(WrongQuestionCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "WrongQuestionCategoryCollectionViewCell")
        collectionView.register(WrongQuestionCategoryReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "WrongQuestionCategoryReusableView")
    }
    
    private func layout() -> UICollectionViewFlowLayout {
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        
        return layout
    }
    
    @objc private func cancelButtonAction() {
        self.dismiss(animated: true)
        // coordinator
    }
    
    @objc private func submitButtonAction() {
        self.dismiss(animated: true)
        // Coordinator & network
    }
    
    private func setStateArr(conceptSet: Set<String>) {
        for row in items {
            var arr: [WrongQuestionCategoryCellState] = []
            var count: Int = 0
            for elem in row {
                if conceptSet.contains(elem) {
                    arr.append(WrongQuestionCategoryCellState())
                    count += 1
                } else {
                    arr.append(WrongQuestionCategoryCellState(isAvailable: false))
                }
            }
            if count > 0 {
                arr[0].isAvailable = true
                arr[0].isClicked = true
            }
            stateArr.append(arr)
        }
    }
}

// MARK: - CollectionView DataSource
extension WrongQuestionCategoryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WrongQuestionCategoryCollectionViewCell", for: indexPath)
                as? WrongQuestionCategoryCollectionViewCell else { return UICollectionViewCell() }

        let section = indexPath.section
        let item = indexPath.item

        let cellText = items[section][item]

        cell.configure(cellText, isAvailable: true, isClicked: false)
        cell.setState(isAvailable: stateArr[section][item].isAvailable, isClicked: stateArr[section][item].isClicked)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WrongQuestionCategoryReusableView.identifier, for: indexPath) as? WrongQuestionCategoryReusableView else {
                return UICollectionReusableView(frame: .zero)
            }
            header.configure(sectionTitles[indexPath.item])
            return header
        }

        return UICollectionReusableView(frame: .zero)
    }
}

// MARK: - CollectionView Delegate
extension WrongQuestionCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = getLabelSize(indexPath)
        let height = 40.0

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        input.send(.cellClicked(section: indexPath.section, item: indexPath.item))
    }
    
    private func getLabelSize(_ indexPath: IndexPath) -> CGFloat {
        let label = UILabel()
        label.text = items[indexPath.section][indexPath.item]
        label.numberOfLines = 1
        let size = label.sizeThatFits(CGSize(width: collectionView.frame.width, height: 40))
        return (size.width + 23)
    }
}

// MARK: - Auto Layout
extension WrongQuestionCategoryViewController {
    private func addViews() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(cancelButton)
        self.view.addSubview(submitButton)
        self.view.addSubview(grabberView)
        self.view.addSubview(collectionView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            cancelButton.widthAnchor.constraint(equalToConstant: 14),
            cancelButton.heightAnchor.constraint(equalToConstant: 14),
            
            submitButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            submitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            submitButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 48),
            
            grabberView.widthAnchor.constraint(equalToConstant: 46),
            grabberView.heightAnchor.constraint(equalToConstant: 4),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            collectionView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18)
        ])
    }
}
