import UIKit
import QRIZUtils
import Network
import Daily
import Conceptbook

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol HomeCoordinator: Coordinator {
    var delegate: HomeCoordinatorDelegate? { get set }
    var examDelegate: (any ExamSelectionDelegate)? { get set }
    var needsRefresh: Bool { get set }
    func handleExamScheduleUpdate()
    func showExamScheduleSelectionSheet(from viewController: UIViewController)
    func showExamSelectionSheet()
    func showOnboarding()
    func showExam()
    func showDaily(day: Int, type: DailyLearnType)
    func showResetAlert(confirm: @escaping () -> Void)
    func showDaySelectAlert(totalDays: Int, selectedDay: Int, todayIndex: Int?)
    func showConceptPDF(chapter: Chapter, conceptItem: ConceptItem)
}

@MainActor
public protocol ExamSelectionDelegate: AnyObject {
    func didUpdateExamSchedule()
}

@MainActor
public protocol HomeCoordinatorDelegate: AnyObject {
    func moveToConcept()
}

@MainActor
public func makeHomeCoordinator(
    examService: any ExamScheduleService,
    examTestService: any ExamService,
    dailyService: any DailyService,
    onboardingService: any OnboardingService,
    userInfoService: any UserInfoService,
    weeklyService: any WeeklyRecommendService,
    adService: any AdService
) -> any HomeCoordinator {
    HomeCoordinatorImpl(
        examService: examService,
        examTestService: examTestService,
        dailyService: dailyService,
        onboardingService: onboardingService,
        userInfoService: userInfoService,
        weeklyService: weeklyService,
        adService: adService
    )
}

