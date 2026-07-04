import UIKit
import SwiftUI
import QRIZUtils
import QRIZNetwork
import ExamKit
import DailyInterface

@MainActor
final class DailyCoordinatorImpl: DailyNavigating, NavigationGuard {

    // MARK: - Properties

    weak var delegate: DailyCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var dailyLearnViewController: DailyLearnViewController?
    private var dailyLearnViewModel: DailyLearnViewModel?
    // DailyResultView는 @ObservedObject로 ViewModel을 참조하므로 소유권이 없음.
    // 코디네이터가 강한 참조를 유지해 조기 해제를 방지함.
    private var dailyResultViewModel: DailyResultViewModel?
    private let service: any DailyService
    private let day: Int
    private let type: DailyLearnType
    private let adService: any AdService

    // MARK: - NavigationGuard

    var isNavigating: Bool = false

    // MARK: - Initializer

    init(
        navigationController: UINavigationController,
        dailyService: any DailyService,
        day: Int,
        type: DailyLearnType,
        adService: any AdService
    ) {
        self.navigationController = navigationController
        self.service = dailyService
        self.day = day
        self.type = type
        self.adService = adService
    }

    // MARK: - Coordinator

    // navigationController는 빈 상태로 주입받아야 함.
    // start() 호출 시 DailyLearn이 push되며, 반환된 navigationController를 caller가 present/push함.
    func start() -> UIViewController {
        showDailyLearn()
        return navigationController
    }

    // MARK: - DailyNavigating

    func showDailyLearn() {
        guardNavigation {
            let vm = DailyLearnViewModel(day: self.day, type: self.type, dailyService: self.service)
            let vc = DailyLearnViewController(dailyLearnViewModel: vm)
            self.dailyLearnViewController = vc
            self.dailyLearnViewModel = vm
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        guard let vc = delegate?.conceptPDFViewController(chapter: chapter, conceptItem: conceptItem) else { return }
        guardNavigation {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyTest() {
        guardNavigation {
            self.adService.loadInterstitialAd()
            let vm = DailyTestViewModel(day: self.day, dailyService: self.service)
            let vc = DailyTestViewController(viewModel: vm)
            vc.coordinator = self
            vc.hidesBottomBarWhenPushed = true
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyResult() {
        adService.showInterstitialAd(from: navigationController) { [weak self] in
            guard let self else { return }
            self.guardNavigation {
                let vm = DailyResultViewModel(dailyTestType: self.type, day: self.day, dailyService: self.service, userInfo: .shared)
                vm.delegate = self
                self.dailyResultViewModel = vm
                let vc = UIHostingController(rootView: DailyResultView(viewModel: vm))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }

    func showResultDetail(resultDetailData: ResultDetailData) {
        guardNavigation {
            let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
            let vc = TestResultDetailViewController(viewModel: vm)
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showProblemExplanation(questionId: Int) {
        // service, day를 값으로 캡처해 ProblemDetailViewModel의 async 클로저가 self를 retain하지 않도록 함
        guardNavigation { [service = self.service, day = self.day] in
            let viewModel = ProblemDetailViewModel {
                let response = try await service.getDailyResultDetail(
                    dayNumber: day,
                    questionId: questionId
                )
                return response.data.toEntity()
            }
            let vc = ProblemDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func quitDaily() {
        guard
            let dailyLearnVC = dailyLearnViewController,
            let dailyLearnVM = dailyLearnViewModel
        else { return }
        guard navigationController.popToViewController(dailyLearnVC, animated: true) != nil else { return }
        dailyLearnVM.reloadData()
    }

    func finishDaily() {
        delegate?.didQuitDaily(self)
    }
}

// MARK: - DailyResultViewModelDelegate

extension DailyCoordinatorImpl: DailyResultViewModelDelegate {
    func didRequestQuitDaily() {
        quitDaily()
    }

    func didRequestMoveToConcept() {
        navigationController.tabBarController?.tabBar.isHidden = false
        delegate?.moveFromDailyToConcept(self)
    }

    func didRequestShowResultDetail(_ data: ResultDetailData) {
        showResultDetail(resultDetailData: data)
    }

    func didRequestShowProblemDetail(questionId: Int) {
        showProblemExplanation(questionId: questionId)
    }
}

// MARK: - ProblemDetailCoordinating

extension DailyCoordinatorImpl: ProblemDetailCoordinating {
    func navigateToConceptTab() {
        delegate?.moveFromDailyToConcept(self)
    }

    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
