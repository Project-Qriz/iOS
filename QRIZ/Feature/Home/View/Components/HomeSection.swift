//
//  HomeSection.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit
import Combine

struct StudySummary: Equatable, Hashable {
    let id: Int
    let dailyPlans: [DailyPlan]
}

enum HomeSection: Int, CaseIterable {
    case examSchedule
    case examEntry
    case dailyHeader
    case daySelector
    case studySummary
    case weeklyConcept
}

enum HomeSectionItem: Hashable {
    case schedule(userName: String, status: ExamStatus)
    case entry(EntryCardState)
    case day(Int)
    case studySummary(StudySummary)
    case weeklyConcept(kind: RecommendationKind, list: [WeeklyConcept])
}

enum HomeLayoutFactory {
    
    private enum Metric {
        static let examScheduleHeight: CGFloat = 364.0
        static let examScheduleTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 40.0
        
        static let examEntryHeight: CGFloat = 106.0
        
        static let dailyHeaderHeight: CGFloat = 24.0
        
        static let daySelectorSpacing: CGFloat = 8.0
        static let daySelectorHeightRatio: CGFloat = 0.6
        
        static let studySummaryHeight: CGFloat = 245.0
        static let studySummaryTopOffset: CGFloat = 16.0
        static let interItemSpacing: CGFloat = 12.0
        static let ctaFooterHeight: CGFloat = 48.0
        
        static let weeklyConceptHeight: CGFloat = 252.0
    }
    
    // MARK: - Functions
    
    private static func examSchedule() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examScheduleHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.examScheduleTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    private static func examEntry() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examEntryHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.verticalSpacing,
            leading: Metric.horizontalSpacing,
            bottom: Metric.verticalSpacing,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    private static func dailyHeader() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Metric.dailyHeaderHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private static func daySelector(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let inset = Metric.horizontalSpacing
        let spacing = Metric.daySelectorSpacing
        let totalWidth = env.container.effectiveContentSize.width - inset * 2
        let itemWidth = (totalWidth - spacing * 2) / 3
        let itemHeight = itemWidth * Metric.daySelectorHeightRatio
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .init(top: 19, leading: inset, bottom: 8, trailing: inset)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private static func studySummary(
        env: NSCollectionLayoutEnvironment,
        cv: UICollectionView,
        selected: CurrentValueSubject<Int,Never>,
        programmaticScroll: CurrentValueSubject<Bool,Never>,
        isLocked: Bool
    ) -> NSCollectionLayoutSection {
        let inset = Metric.horizontalSpacing
        let totalWidth = env.container.effectiveContentSize.width - inset * 2
        let size = NSCollectionLayoutSize(
            widthDimension: .absolute(totalWidth),
            heightDimension: .estimated(Metric.studySummaryHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Metric.interItemSpacing
        
        let showFooter = !isLocked
        
        section.contentInsets = .init(
            top: Metric.studySummaryTopOffset,
            leading: inset,
            bottom: Metric.studySummaryTopOffset,
            trailing: inset
        )
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { [weak cv] visibleItems, contentOffset, _ in
            guard let cv = cv, !programmaticScroll.value else { return }
            let centerX = contentOffset.x + cv.bounds.width * 0.5
            let summaryItems = visibleItems.filter { $0.indexPath.section == HomeSection.studySummary.rawValue }
            guard let closest = summaryItems.min(by: { abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX) }) else { return }

            let newIndex = closest.indexPath.item
            guard newIndex != selected.value else { return }
            selected.send(newIndex)

            programmaticScroll.send(true)
            cv.scrollToItem(at: IndexPath(item: newIndex, section: HomeSection.daySelector.rawValue), at: .centeredHorizontally, animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                programmaticScroll.send(false)
            }
        }
        
        if showFooter {
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(Metric.ctaFooterHeight)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: String(describing: StudyCTAView.self),
                alignment: .bottom)
            section.boundarySupplementaryItems = [footer]
        }
        
        return section
    }
    
    private static func weeklyConcept() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.weeklyConceptHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.verticalSpacing,
            leading: Metric.horizontalSpacing,
            bottom: Metric.verticalSpacing,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    static func makeLayout(
        for cv: UICollectionView,
        selected: CurrentValueSubject<Int,Never>,
        programmaticScroll: CurrentValueSubject<Bool,Never>,
        isLocked: Bool
    ) -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { index, env in
            guard let section = HomeSection(rawValue: index) else { return nil }
            switch section {
            case .examSchedule: return examSchedule()
            case .examEntry: return examEntry()
            case .dailyHeader: return dailyHeader()
            case .daySelector: return daySelector(env: env)
            case .studySummary:
                return studySummary(
                    env: env,
                    cv: cv,
                    selected: selected,
                    programmaticScroll: programmaticScroll,
                    isLocked: isLocked
                )
            case .weeklyConcept: return weeklyConcept()
            }
        }
    }
}
