//
//  HomeMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit
import Combine

final class HomeMainView: UIView {
    
    // MARK: - Properties
    
    private let examButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let entryTappedSubject = PassthroughSubject<Void, Never>()
    private let studyButtonTappedSubject = PassthroughSubject<Int, Never>()
    private let resetButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let dayHeaderTappedSubject = PassthroughSubject<Void, Never>()
    private let selectedIndexSubject = CurrentValueSubject<Int,Never>(0)
    private let programmaticScrollSubject = CurrentValueSubject<Bool, Never>(false)
    private let dayTapSubject = PassthroughSubject<Int, Never>()
    private let weeklyConceptTappedSubject = PassthroughSubject<Int, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var lastSelectedIndex = 0
    private var currentDailyPlans: [DailyPlan] = []
    private var currentEntryState: EntryCardState = .preview
    private var isPreviewLocked = true
    
    var examButtonTappedPublisher: AnyPublisher<Void, Never> {
        examButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var entryTappedPublisher: AnyPublisher<Void, Never> {
        entryTappedSubject.eraseToAnyPublisher()
    }
    
    var studyButtonTappedPublisher: AnyPublisher<Int, Never> {
        studyButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var resetButtonTappedPublisher: AnyPublisher<Void, Never> {
        resetButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var dayHeaderTappedPublisher: AnyPublisher<Void, Never> {
        dayHeaderTappedSubject.eraseToAnyPublisher()
    }
    
    var selectedIndexPublisher: AnyPublisher<Int,Never> {
        selectedIndexSubject.eraseToAnyPublisher()
    }
    
    var weeklyConceptTappedPublisher: AnyPublisher<Int, Never> {
        weeklyConceptTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var scheduleRegistration = UICollectionView.CellRegistration<ExamScheduleCardCell, HomeSectionItem> { [weak self] cell, _, item in
        guard case let .schedule(userName, status) = item else { return }
        cell.configure(
            userName: userName,
            statusText: {
                switch status {
                case .none: return "등록된 일정이 없어요."
                case .expired: return "등록했던 시험일이 지났어요."
                default: return ""
                }
            }()
        )
        cell.buttonTapPublisher
            .sink { [weak self] in self?.examButtonTappedSubject.send() }
            .store(in: &cell.cancellables)
    }
    
    private lazy var registeredRegistration = UICollectionView.CellRegistration<ExamScheduleRegisteredCell, HomeSectionItem> { [weak self] cell, _, item in
        guard case let .schedule(userName, .registered(dDay, detail)) = item else { return }
        cell.configure(userName: userName, dday: dDay, detail: detail)
        cell.buttonTapPublisher
            .sink { [weak self] in self?.examButtonTappedSubject.send() }
            .store(in: &cell.cancellables)
    }
    
    private lazy var entryRegistration = UICollectionView.CellRegistration<ExamEntryCardCell, HomeSectionItem> { [weak self] cell, _, item in
        guard case .entry(let state) = item else { return }
        cell.configure(state: state)
        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.didTapEntryCell)))
    }
    
    private lazy var dailyHeaderSupRegistration = UICollectionView.SupplementaryRegistration<DailyPlanHeaderView>(
        elementKind: UICollectionView.elementKindSectionHeader) { [weak self] view, _, _ in
            guard let self else { return }
            view.configure(day: self.selectedIndexSubject.value + 1, locked: isPreviewLocked)
            
            view.resetButtonTapPublisher
                .sink { [weak self] in
                    self?.resetButtonTappedSubject.send()
                }
                .store(in: &view.cancellables)
            
            view.dayButtonTapPublisher
                .sink { [weak self] in
                    self?.dayHeaderTappedSubject.send()
                }
                .store(in: &view.cancellables)
        }
    
    private lazy var dayRegistration = UICollectionView.CellRegistration<DayCardCell, HomeSectionItem> { [weak self] cell, indexPath, item in
        guard case .day(let n) = item else { return }
        let isSelected = indexPath.item == (self?.selectedIndexSubject.value ?? 0)
        cell.configure(day: n, isSelected: isSelected)
        
        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
        guard let self else { return }
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapDay(_:))))
    }
    
    private lazy var summaryRegistration = UICollectionView.CellRegistration<StudySummaryCell, HomeSectionItem> { cell, _, item in
        guard case .studySummary(let summary) = item else { return }
        cell.configure(summary: summary)
    }
    
    private lazy var studyCTASupRegistration = UICollectionView.SupplementaryRegistration<StudyCTAView>(
        elementKind: String(describing: StudyCTAView.self)) { _, _, _ in }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        
        cv.setCollectionViewLayout(
            HomeLayoutFactory.makeLayout(
                for: cv,
                selected: selectedIndexSubject,
                programmaticScroll: programmaticScrollSubject,
                isLocked: isPreviewLocked
            ),
            animated: false
        )
        cv.backgroundColor = .customBlue50
        cv.delegate = self
        cv.register(
            StudyCTAView.self,
            forSupplementaryViewOfKind: String(describing: StudyCTAView.self),
            withReuseIdentifier: String(describing: StudyCTAView.self)
        )
        return cv
    }()
    
    private lazy var weeklyRegistration = UICollectionView.CellRegistration<WeeklyConceptCell, HomeSectionItem>
    { [weak self] cell, _, item in
        guard case let .weeklyConcept(kind, list) = item, let self else { return }
        cell.configure(kind: kind, concepts: list)
        cell.conceptTappedPublisher
            .sink { [weak self] index in
                self?.weeklyConceptTappedSubject.send(index)
            }
            .store(in: &cell.cancellables)
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem> = {
        let ds = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                switch item {
                case .schedule(_, .registered):
                    return collectionView.dequeueConfiguredReusableCell(using: self.registeredRegistration, for: indexPath, item: item)
                case .schedule:
                    return collectionView.dequeueConfiguredReusableCell(using: self.scheduleRegistration, for: indexPath, item: item)
                case .entry:
                    return collectionView.dequeueConfiguredReusableCell(using: self.entryRegistration, for: indexPath, item: item)
                case .day:
                    return collectionView.dequeueConfiguredReusableCell(using: self.dayRegistration, for: indexPath, item: item)
                case .studySummary:
                    return collectionView.dequeueConfiguredReusableCell(using: self.summaryRegistration, for: indexPath, item: item)
                case .weeklyConcept:
                    return collectionView.dequeueConfiguredReusableCell(using: self.weeklyRegistration, for: indexPath, item: item)
                }
            }
        
        ds.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self, let section = HomeSection(rawValue: indexPath.section) else { return UICollectionReusableView() }
            
            if section == .dailyHeader && kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: self.dailyHeaderSupRegistration, for: indexPath)
            }
            
            if section == .studySummary && kind == String(describing: StudyCTAView.self) {
                let footer = collectionView.dequeueConfiguredReusableSupplementary(using: self.studyCTASupRegistration, for: indexPath)
                
                self.configureCTA(self.currentEntryState, selected: self.selectedIndexSubject.value)
                footer.tapPublisher
                    .sink { [weak self] in
                        guard let self else { return }
                        self.studyButtonTappedSubject.send(self.selectedIndexSubject.value)
                    }
                    .store(in: &footer.cancellables)
                return footer
            }
            return UICollectionReusableView()
        }
        
        return ds
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = [
            scheduleRegistration,
            registeredRegistration,
            entryRegistration,
            dailyHeaderSupRegistration,
            dayRegistration,
            summaryRegistration,
            studyCTASupRegistration,
            weeklyRegistration
        ]
        addSubviews()
        setupConstraints()
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
    }
    
    private func bind() {
        selectedIndexSubject
            .removeDuplicates()
            .sink { [weak self] newIndex in
                guard let self, newIndex != lastSelectedIndex else { return }
                
                updateDaySelectorUI(from: lastSelectedIndex, to: newIndex)
                lastSelectedIndex = newIndex
                updateDailyHeaderView(day: newIndex + 1)
                configureCTA(currentEntryState, selected: newIndex)
                
                if !programmaticScrollSubject.value {
                    scrollTo(index: newIndex, animated: true)
                }
            }
            .store(in: &cancellables)
        
        dayTapSubject
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink(receiveValue: scrollToDay(_:))
            .store(in: &cancellables)
    }
    
    @MainActor
    func apply(_ state: HomeState) {
        currentEntryState  = state.entryState
        currentDailyPlans = state.dailyPlans
        let previewLocked = (state.entryState == .preview)
        
        rebuildLayoutIfNeeded(isLocked: previewLocked)
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(
            [.schedule(userName: state.userName, status: state.examStatus)],
            toSection: .examSchedule
        )
        snapshot.appendItems(
            [.entry(state.entryState)],
            toSection: .examEntry
        )
        
        if previewLocked {
            snapshot.appendItems(
                [.studySummary(StudySummary(id: -1, dailyPlans: []))],
                toSection: .studySummary
            )
        } else {
            snapshot.appendItems(
                state.dailyPlans.enumerated().map { .day($0.offset + 1) },
                toSection: .daySelector
            )
            snapshot.appendItems(
                state.dailyPlans.map { .studySummary(StudySummary(id: $0.id, dailyPlans: [$0])) },
                toSection: .studySummary
            )
        }
        
        snapshot.appendItems(
            [.weeklyConcept(kind: state.recommendationKind, list: state.weeklyConcepts)],
            toSection: .weeklyConcept
        )
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if state.selectedIndex != selectedIndexSubject.value {
            selectedIndexSubject.send(state.selectedIndex)
        }
    }
    
    private func updateDailyHeaderView(day: Int) {
        let headerIndexPath = IndexPath(item: 0, section: HomeSection.dailyHeader.rawValue)
        if let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: headerIndexPath
        ) as? DailyPlanHeaderView {
            header.configure(day: day, locked: isPreviewLocked)
        }
    }
    
    private func configureCTA(_ entryState: EntryCardState, selected index: Int) {
        guard entryState != .preview else { ctaFooter()?.isHidden = true; return }
        guard index < currentDailyPlans.count, let footer = ctaFooter() else { return }
        
        let plan = currentDailyPlans[index]
        let enabled = !plan.plannedSkills.isEmpty
        let isReview = plan.reviewDay || plan.comprehensiveReviewDay
        footer.configure(enabled: enabled, isReview: isReview)
    }
    
    private func ctaFooter() -> StudyCTAView? {
        collectionView.supplementaryView(
            forElementKind: String(describing: StudyCTAView.self),
            at: IndexPath(item: 0, section: HomeSection.studySummary.rawValue)
        ) as? StudyCTAView
    }
    
    private func rebuildLayoutIfNeeded(isLocked newValue: Bool) {
        guard newValue != isPreviewLocked else { return }
        isPreviewLocked = newValue
        collectionView.setCollectionViewLayout(
            HomeLayoutFactory.makeLayout(
                for: collectionView,
                selected: selectedIndexSubject,
                programmaticScroll: programmaticScrollSubject,
                isLocked: isPreviewLocked),
            animated: false)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapEntryCell() {
        entryTappedSubject.send()
    }
    
    @objc
    private func didTapDay(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view?.superview as? UICollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else { return }
        dayTapSubject.send(indexPath.item)
    }
    
    private func scrollTo(index: Int, animated: Bool) {
        programmaticScrollSubject.send(true)
        
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: HomeSection.studySummary.rawValue),
            at: .centeredHorizontally,
            animated: animated
        )
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: HomeSection.daySelector.rawValue),
            at: .centeredHorizontally,
            animated: animated
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.programmaticScrollSubject.send(false)
        }
    }
    
    private func updateDaySelectorUI(from old: Int, to new: Int) {
        let oldIdx = IndexPath(item: old, section: HomeSection.daySelector.rawValue)
        (collectionView.cellForItem(at: oldIdx) as? DayCardCell)?.configure(day: old + 1, isSelected: false)
        let newIdx = IndexPath(item: new, section: HomeSection.daySelector.rawValue)
        (collectionView.cellForItem(at: newIdx) as? DayCardCell)?.configure(day: new + 1, isSelected: true)
    }
    
    private func scrollToDay(_ index: Int) {
        selectedIndexSubject.send(index)
        scrollTo(index: index, animated: true)
    }
}

// MARK: - Layout Setup

extension HomeMainView {
    private func addSubviews() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate

extension HomeMainView: UICollectionViewDelegate {
    // 프로그램이 호출한 스크롤이 끝났을 때
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        programmaticScrollSubject.send(false)
    }
    
    // 사용자가 드래그로 스크롤하고 감속이 끝났을 때
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        programmaticScrollSubject.send(false)
    }
}
