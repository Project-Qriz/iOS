//
//  OnboardingViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

final class CheckConceptViewController: UIViewController {
    
    // MARK: - Properties
    private let checkConceptTitleLabel: UILabel = OnboardingTitleLabel(labelText: "아는 개념을 체크해주세요!", fontSize: 22, numberOfLines: 1)
    private let checkConceptSubTitleLabel: UILabel = OnboardingSubtitleLabel("체크하신 결과를 토대로\n추후 진행할 테스트의 레벨이 조정됩니다! ")
    private let checkNoneButton: CheckAllOrNoneButton = .init(isAll: false)
    private let checkAllButton: CheckAllOrNoneButton = .init(isAll: true)
    private let foldButton: CheckListFoldButton = .init()
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()
    private let checkListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    private let checkDoneButton = OnboardingButton("선택완료")
    
    private let viewModel: CheckConceptViewModel = CheckConceptViewModel(onboardingService: OnboardingServiceImpl())
    private let input: PassthroughSubject<CheckConceptViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setCollectionView()
        bind()
        addViews()
        navigationController?.navigationBar.isHidden = true
        addButtonAction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addCustomShadow()
    }
    
    private func bind() {
        let mergedInput = Publishers.Merge3(input, checkNoneButton.input, checkAllButton.input)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToNextPage:
                    // if selected 'no nothing' -> pushViewController(HomeViewController)
                    self.navigationController?.pushViewController(BeginPreviewTestViewController(), animated: true)
                case .setAllAndNone(let numOfSelectedConcept, let checkNoneClicked):
                    checkNoneButton.checkboxHandler(numOfSelectedConcept: numOfSelectedConcept, checkNoneClicked: checkNoneClicked)
                    checkAllButton.checkboxHandler(numOfSelectedConcept: numOfSelectedConcept)
                case .checkboxToOn(let idx):
                    changeCheckboxState(idx: idx, isNextStateOn: true)
                case .checkboxToOff(let idx):
                    changeCheckboxState(idx: idx, isNextStateOn: false)
                case .setDoneButtonState(let isActive):
                    checkDoneButtonHandler(isActive: isActive)
                case .requestFailed:
                    self.showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setCollectionView() {
        checkListCollectionView.dataSource = self
        checkListCollectionView.delegate = self
        checkListCollectionView.register(CheckListCell.self, forCellWithReuseIdentifier: CheckListCell.identifier)
    }
    
    private func checkDoneButtonHandler(isActive: Bool) {
        checkDoneButton.setButtonState(isActive: isActive)
    }
    
    private func addButtonAction() {
        foldButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.foldButton.toggleImage()
            checkListCollectionView.isHidden.toggle()
            checkDoneButton.layer.masksToBounds.toggle()
        }), for: .touchUpInside)
        
        checkDoneButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.didDoneButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func addCustomShadow() {
        checkDoneButton.layer.masksToBounds = false
        checkDoneButton.layer.shadowColor = UIColor.customBlue100.cgColor
        checkDoneButton.layer.cornerRadius = 8
        checkDoneButton.layer.shadowOpacity = 0.7
        checkDoneButton.layer.shadowPath = UIBezierPath(rect: CGRect(x: checkListCollectionView.bounds.minX - 1,
                                                                     y: checkDoneButton.bounds.minY - 6,
                                                                     width: checkDoneButton.bounds.width + 2,
                                                                     height: checkDoneButton.bounds.height)).cgPath
    }
}

// MARK: - CollectionView DataSource
extension CheckConceptViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SurveyCheckList.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckListCell.identifier, for: indexPath) as? CheckListCell else {
            print("Failed to create CheckListCell")
            return UICollectionViewCell()
        }
        
        let isSelected = viewModel.selectedSet.contains(indexPath.item)
        cell.configure(SurveyCheckList.list[indexPath.item])
        cell.toggleCheckbox(isSelected)
        return cell
    }
}

// MARK: - CollectionView Delegate
extension CheckConceptViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.input.send(.someCheckboxClicked(idx: indexPath.item))
    }
    
    func changeCheckboxState(idx: Int, isNextStateOn: Bool) {
        let indexPath = IndexPath(item: idx, section: 0)
        guard let selectedCell = self.checkListCollectionView.cellForItem(at: indexPath) as? CheckListCell else { return }
        selectedCell.toggleCheckbox(isNextStateOn)
    }
}

// MARK: - Auto Layout
extension CheckConceptViewController {
    private func addViews() {
        self.view.addSubview(checkConceptTitleLabel)
        self.view.addSubview(checkConceptSubTitleLabel)
        self.view.addSubview(checkNoneButton)
        self.view.addSubview(checkAllButton)
        self.view.addSubview(foldButton)
        self.view.addSubview(dividerView)
        self.view.addSubview(checkListCollectionView)
        self.view.addSubview(checkDoneButton)
        
        checkConceptTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkConceptSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkNoneButton.translatesAutoresizingMaskIntoConstraints = false
        checkAllButton.translatesAutoresizingMaskIntoConstraints = false
        foldButton.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        checkListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        checkDoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkConceptTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            checkConceptTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 48),
            
            checkConceptSubTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            checkConceptSubTitleLabel.topAnchor.constraint(equalTo: checkConceptTitleLabel.bottomAnchor, constant: 20),
            
            checkNoneButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            checkNoneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            checkNoneButton.topAnchor.constraint(equalTo: checkConceptSubTitleLabel.bottomAnchor, constant: 32),
            checkNoneButton.heightAnchor.constraint(equalToConstant: 60),
            
            checkAllButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            checkAllButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            checkAllButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            checkAllButton.heightAnchor.constraint(equalToConstant: 60),
            
            foldButton.centerYAnchor.constraint(equalTo: checkAllButton.centerYAnchor),
            foldButton.trailingAnchor.constraint(equalTo: checkAllButton.trailingAnchor, constant: -16),
            foldButton.widthAnchor.constraint(equalToConstant: 40),
            foldButton.heightAnchor.constraint(equalToConstant: 40),
            
            dividerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            dividerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            dividerView.topAnchor.constraint(equalTo: checkNoneButton.bottomAnchor, constant: 16),
            dividerView.heightAnchor.constraint(equalToConstant: 2),
            
            checkListCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 42),
            checkListCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            checkListCollectionView.topAnchor.constraint(equalTo: checkAllButton.bottomAnchor, constant: 16),
            checkListCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -65),
            
            checkDoneButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            checkDoneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            checkDoneButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            checkDoneButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        checkDoneButton.setButtonState(isActive: false)
    }
}
