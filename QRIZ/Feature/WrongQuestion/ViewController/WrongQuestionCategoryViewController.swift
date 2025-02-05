//
//  WrongQuestionCategoryViewController.swift
//  QRIZ
//
//  Created by 이창현 on 1/31/25.
//

import UIKit
import Combine

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
    
    private enum Section: String, CaseIterable {
        case DataModeling = "데이터 모델링의 이해"
        case DataModelAndSQL = "데이터 모델과 SQL"
        case SQLBasic = "SQL 기본"
        case SQLAdvanced = "SQL 활용"
        case SQLCommands = "관리 구문"
    }
    private let items: [[String]] = {
        var arr: [[String]] = ConceptCategory.getAllConceptList()
        for i in 0..<arr.count { arr[i].insert("전체", at: 0) }
        return arr
    }()
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: WrongQuestionCategoryViewController")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureSheetPresentation()
        addViews()
        addButtonsAction()
        setCollectionView()
    }
    
    private func configureSheetPresentation() {
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.preferredCornerRadius = 32.0
            //            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.largestUndimmedDetentIdentifier = .none
        }
    }
    
    private func addButtonsAction() {
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
    }
    
    private func setCollectionView() {
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout()
    }
    
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
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

        let item = items[indexPath.section][indexPath.item]
        cell.configure(item)

        return cell
    }
}

// MARK: - CollectionView Delegate


// MARK: - Auto Layout
extension WrongQuestionCategoryViewController {
    private func addViews() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(cancelButton)
        self.view.addSubview(submitButton)
        self.view.addSubview(grabberView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        
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
            grabberView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
}
