//
//  OnboardingViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

class CheckConceptViewController: UIViewController {
    
    private let checkConceptTitleLabel: UILabel = OnboardingTitleLabel(labelText: "아는 개념을 체크해주세요!", fontSize: 24, numberOfLines: 1)
    private let checkConceptSubTitleLabel: UILabel = OnboardingSubtitleLabel("체크하신 결과를 토대로\n추후 진행할 테스트의 레벨이 조정됩니다! ")
    private let checkListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    private let checkDoneButton = OnboardingButton("선택완료")
    
    private let viewModel: CheckConceptViewModel = CheckConceptViewModel()
    private let input: PassthroughSubject<CheckConceptViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        self.navigationItem.hidesBackButton = true
        checkListCollectionView.dataSource = self
        checkListCollectionView.delegate = self
        checkListCollectionView.register(CheckListCell.self, forCellWithReuseIdentifier: CheckListCell.identifier)
        bind()
        addViews()
        addButtonAction()
        setNavigationItem()
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToNextPage:
                    // if selected 'no nothing' -> pushViewController(HomeViewController)
                    self.navigationController?.pushViewController(BeginTestViewController(), animated: true)
                case .checkboxToOn(let idx):
                    changeCheckboxState(idx: idx, nextState: .on)
                case .checkboxToOff(let idx):
                    changeCheckboxState(idx: idx, nextState: .off)
                case .setDoneButtonState(let isActive):
                    checkDoneButtonHandler(isActive: isActive)
                case .requestFailed:
                    print("REQUEST FAIL") // handle error
                }
            }
            .store(in: &subscriptions)
    }
    
    private func checkDoneButtonHandler(isActive: Bool) {
        isActive ? checkDoneButton.setButtonState(isActive: true) : checkDoneButton.setButtonState(isActive: false)
    }
    
    private func addButtonAction() {
        checkDoneButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.didDoneButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func setNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelOnboarding))
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func cancelOnboarding() {
        // coordinator role
        self.dismiss(animated: true)
    }
    
    private func addViews() {
        self.view.addSubview(checkConceptTitleLabel)
        self.view.addSubview(checkConceptSubTitleLabel)
        self.view.addSubview(checkListCollectionView)
        self.view.addSubview(checkDoneButton)
        
        checkConceptTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkConceptSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        checkDoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkConceptTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            checkConceptTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            checkConceptTitleLabel.topAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25),
            checkConceptTitleLabel.heightAnchor.constraint(equalToConstant: 76),
            checkConceptSubTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            checkConceptSubTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            checkConceptSubTitleLabel.topAnchor.constraint(equalTo: checkConceptTitleLabel.bottomAnchor, constant: 12),
            checkConceptSubTitleLabel.heightAnchor.constraint(equalToConstant: 48),
            checkListCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            checkListCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            checkListCollectionView.topAnchor.constraint(equalTo: checkConceptSubTitleLabel.bottomAnchor, constant: 40),
            checkListCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            checkDoneButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            checkDoneButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            checkDoneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            checkDoneButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        self.view.bringSubviewToFront(checkDoneButton)
        checkDoneButton.setButtonState(isActive: false)
    }
}

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
        let nextState: CheckBoxState = isSelected ? .on : .off
        cell.configure(SurveyCheckList.list[indexPath.item])
        cell.toggleCheckbox(nextState)
        return cell
    }
}

extension CheckConceptViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.input.send(.someCheckboxClicked(idx: indexPath.item))
    }
    
    func changeCheckboxState(idx: Int, nextState: CheckBoxState) {
        let indexPath = IndexPath(item: idx, section: 0)
        guard let selectedCell = self.checkListCollectionView.cellForItem(at: indexPath) as? CheckListCell else { return }
        selectedCell.toggleCheckbox(nextState)
//        self.checkListCollectionView.
    }
}

