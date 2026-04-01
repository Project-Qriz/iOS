import UIKit
import QRIZUtils
import Network
import DesignSystem
import Conceptbook
import Onboarding
import Daily
import Exam

@MainActor
final class HomeCoordinatorImpl: HomeCoordinator, NavigationGuard {

    // MARK: - Properties

    weak var delegate: HomeCoordinatorDelegate?
    weak var examDelegate: (any ExamSelectionDelegate)?
    private(set) weak var navigationController: UINavigationController?
    private let examService: ExamScheduleService
    private let examTestService: ExamService
    private let dailyService: DailyService
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    private let weeklyService: WeeklyRecommendService
    private(set) var homeVM: HomeViewModel?
    var needsRefresh: Bool = false
    var childCoordinators: [Coordinator] = []
    private var onboardingCoordinator: (any OnboardingCoordinator)?
    var isNavigating: Bool = false

    // MARK: - Initialization

    init(
        examService: ExamScheduleService,
        examTestService: ExamService,
        dailyService: DailyService,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService,
        weeklyService: WeeklyRecommendService
    ) {
        self.examService = examService
        self.examTestService = examTestService
        self.dailyService = dailyService
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
        self.weeklyService = weeklyService
    }

    // MARK: - Methods

    func start() -> UIViewController {
        let viewModel = HomeViewModel(
            examScheduleService: examService,
            dailyService: dailyService,
            weeklyService: weeklyService
        )
        homeVM = viewModel
        let homeVC = HomeViewController(viewModel: viewModel)
        homeVC.coordinator = self

        let navi = UINavigationController(rootViewController: homeVC)
        navigationController = navi
        return navi
    }

    func showExamSelectionSheet() {
        guardNavigation {
            let vc = self.makeExamScheduleSelectionViewController()
            self.navigationController?.present(vc, animated: true)
        }
    }

    func showExamScheduleSelectionSheet(from viewController: UIViewController) {
        guardNavigation {
            let vc = self.makeExamScheduleSelectionViewController()
            viewController.present(vc, animated: true)
        }
    }

    private func makeExamScheduleSelectionViewController() -> ExamScheduleSelectionViewController {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: examService)
        viewModel.delegate = examDelegate ?? self

        let vc = ExamScheduleSelectionViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            let fit = UISheetPresentationController.Detent.custom(identifier: .init("fit")) { context in
                min(540, context.maximumDetentValue)
            }
            sheet.detents = [fit]
            sheet.selectedDetentIdentifier = .init("fit")
        }
        return vc
    }

    func handleExamScheduleUpdate() {
        if navigationController?.tabBarController?.selectedIndex == 0 {
            homeVM?.reloadExamSchedule()
        } else {
            needsRefresh = true
        }
    }

    func showOnboarding() {
        guard let navi = navigationController else { return }
        guardNavigation {
            var onboarding = makeOnboardingCoordinator(
                navigationController: navi,
                onboardingService: self.onboardingService,
                userInfoService: self.userInfoService
            )
            onboarding.delegate = self
            self.onboardingCoordinator = onboarding
            self.childCoordinators.append(onboarding)
            _ = onboarding.start()
        }
    }

    func showExam() {
        guard let navi = navigationController else { return }
        guardNavigation {
            var exam = makeExamCoordinator(
                navigationController: navi,
                examService: self.examTestService
            )
            exam.delegate = self
            self.childCoordinators.append(exam)
            _ = exam.start()
        }
    }

    func showDaily(day: Int, type: DailyLearnType) {
        guard let navi = navigationController else { return }
        guardNavigation {
            var daily = makeDailyCoordinator(
                navigationController: navi,
                dailyService: self.dailyService,
                day: day,
                type: type
            )
            daily.delegate = self
            self.childCoordinators.append(daily)
            _ = daily.start()
        }
    }

    func showResetAlert(confirm: @escaping () -> Void) {
        let alert = TwoButtonCustomAlertViewController(
            title: "플랜을 초기화 할까요?",
            description: "지금까지의 플랜이 초기화되며,\nDay1부터 다시 시작됩니다.",
            confirmAction: UIAction { [weak self] _ in
                confirm()
                self?.navigationController?.dismiss(animated: true)
            },
            cancelAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        navigationController?.present(alert, animated: true)
    }

    func showDaySelectAlert(totalDays: Int, selectedDay: Int, todayIndex: Int?) {
        let viewModel = DaySelectBottomSheetViewModel(
            totalDays: totalDays,
            initialSelected: selectedDay,
            todayIndex: todayIndex
        )
        let vc = DaySelectBottomSheetViewController(viewModel: viewModel)

        guard let homeVC = navigationController?.viewControllers.first as? HomeViewController else { return }

        vc.onDaySelected = { [weak homeVC, weak vc] day in
            homeVC?.handleDaySelected(day)
            vc?.dismiss(animated: true)
        }

        if let sheet = vc.sheetPresentationController {
            let small = UISheetPresentationController.Detent.custom(identifier: .init("small")) { _ in 275 }
            sheet.detents = [small]
            sheet.selectedDetentIdentifier = small.identifier
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        navigationController?.present(vc, animated: true)
    }

    func showConceptPDF(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let conceptPDFVC = makeConceptPDFViewController(chapter: chapter, conceptItem: conceptItem)
            self.navigationController?.pushViewController(conceptPDFVC, animated: true)
        }
    }
}

// MARK: - ExamSelectionDelegate

extension HomeCoordinatorImpl: ExamSelectionDelegate {
    func didUpdateExamSchedule() {
        homeVM?.reloadExamSchedule()
    }
}

// MARK: - OnboardingCoordinatorDelegate

extension HomeCoordinatorImpl: OnboardingCoordinatorDelegate {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        onboardingCoordinator = nil
        navigationController?.popToRootViewController(animated: true)
        homeVM?.reloadExamSchedule()
    }
}

// MARK: - ExamCoordinatorDelegate

extension HomeCoordinatorImpl: ExamCoordinatorDelegate {
    func didQuitExam(_ coordinator: any ExamCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
    }

    func moveFromExamToConcept(_ coordinator: any ExamCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
        delegate?.moveToConcept()
    }
}

// MARK: - DailyCoordinatorDelegate

extension HomeCoordinatorImpl: DailyCoordinatorDelegate {
    func didQuitDaily(_ coordinator: any DailyCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
    }

    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
        delegate?.moveToConcept()
    }
}
