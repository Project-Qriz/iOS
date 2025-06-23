//
//  TabBarCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/24/25.
//

import UIKit

@MainActor
protocol TabBarCoordinator: Coordinator {
    var delegate: TabBarCoordinatorDelegate? { get set }
}

@MainActor
protocol TabBarCoordinatorDelegate: AnyObject {
    func didLogout(_ coordinator: TabBarCoordinator)
}

@MainActor
protocol TabBarCoordinatorDependency {
    var homeCoordinator: HomeCoordinator { get }
    var conceptBookCoordinator: ConceptBookCoordinator { get }
    var mistakeNoteCoordinator: MistakeNoteCoordinator { get }
    var myPageCoordinator: MyPageCoordinator { get }
}

@MainActor
final class TabBarCoordinatorDependencyImpl: TabBarCoordinatorDependency {
    
    private let examService: ExamScheduleService
    private let examTestService: ExamService
    private let dailyService: DailyService
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    private let myPageService: MyPageService
    private let accountRecoveryService: AccountRecoveryService
    
    private lazy var _homeCoordinator = HomeCoordinatorImpl(
        examService: examService,
        examTestService: examTestService,
        dailyService: dailyService,
        onboardingService: onboardingService,
        userInfoService: userInfoService
    )
    
    var homeCoordinator: HomeCoordinator {
        _homeCoordinator
    }
    
    private lazy var _conceptBookCoordinator = ConceptBookCoordinatorImpl()
    
    var conceptBookCoordinator: ConceptBookCoordinator {
        _conceptBookCoordinator
    }
    
    private lazy var _mistakeNoteCoordinator = MistakeNoteCoordinatorImpl()
    
    var mistakeNoteCoordinator: MistakeNoteCoordinator {
        _mistakeNoteCoordinator
    }
    
    private lazy var _myPageCoordinator = MyPageCoordinatorImpl(
        examService: examService,
        myPageService: myPageService,
        accountRecoveryService: accountRecoveryService
    )
    
    var myPageCoordinator: MyPageCoordinator {
        _myPageCoordinator
    }
    
    init(
        examService: ExamScheduleService,
        examTestService: ExamService,
        dailyService: DailyService,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService,
        myPageService: MyPageService,
        accountRecoveryService: AccountRecoveryService
    ) {
        self.examService = examService
        self.examTestService = examTestService
        self.dailyService = dailyService
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
        self.myPageService = myPageService
        self.accountRecoveryService = accountRecoveryService
    }
}

@MainActor
final class TabBarCoordinatorImpl: TabBarCoordinator {
    
    weak var delegate: TabBarCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    private let dependency: TabBarCoordinatorDependency
    private var tabBarController: UITabBarController?
    private let homeCoordinator: HomeCoordinatorImpl
    private let myPageCoordinator: MyPageCoordinatorImpl
    
    init(dependency: TabBarCoordinatorDependency) {
        self.dependency = dependency
        
        guard
            let home = dependency.homeCoordinator as? HomeCoordinatorImpl,
            let my = dependency.myPageCoordinator as? MyPageCoordinatorImpl
        else {
            fatalError("TabBar 의존성 주입 오류: 예상한 Coordinator 타입이 아닙니다‼️")
        }
        
        self.homeCoordinator = home
        self.myPageCoordinator = my
    }
    
    func start() -> UIViewController {
        homeCoordinator.examDelegate = self
        myPageCoordinator.examDelegate = self
        myPageCoordinator.delegate = self
        
        var viewControllers: [UIViewController] = [
            homeCoordinator.start(),
            dependency.conceptBookCoordinator.start(),
            dependency.mistakeNoteCoordinator.start(),
            myPageCoordinator.start()
        ]
        setupTabBarItems(for: &viewControllers)
        
        let tabBar = UITabBarController()
        configureTabBarController(tabBar)
        tabBar.viewControllers = viewControllers
        
        childCoordinators = [
            homeCoordinator,
            dependency.conceptBookCoordinator,
            dependency.mistakeNoteCoordinator,
            myPageCoordinator
        ]
        return tabBar
    }
    
    private func configureTabBarController(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .customBlue500
        tabBarController.tabBar.unselectedItemTintColor = .coolNeutral500
        tabBarController.tabBar.layer.borderColor = UIColor.customBlue100.cgColor
        tabBarController.tabBar.layer.borderWidth = 1.0
        tabBarController.tabBar.layer.masksToBounds = true
    }
    
    private func setupTabBarItems(for viewControllers: inout [UIViewController]) {
        guard viewControllers.count >= 4 else { return }
        
        viewControllers[0].tabBarItem = UITabBarItem(
            title: "홈",
            image: .home,
            selectedImage: nil
        )
        viewControllers[1].tabBarItem = UITabBarItem(
            title: "개념서",
            image: .conceptBook,
            selectedImage: .selectedConceptBook
        )
        viewControllers[2].tabBarItem = UITabBarItem(
            title: "오답노트",
            image: .mistakeNote,
            selectedImage: .selectedMistakeNote
        )
        viewControllers[3].tabBarItem = UITabBarItem(
            title: "마이",
            image: .myPage,
            selectedImage: nil
        )
    }
    
    func logout() {
        delegate?.didLogout(self)
    }
}

@MainActor
extension TabBarCoordinatorImpl: HomeCoordinatorDelegate {
    func moveToConcept() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
}

// MARK: - ExamSelectionDelegate

extension TabBarCoordinatorImpl: ExamSelectionDelegate {
    func didUpdateExamSchedule() {
        if let tabBar = homeCoordinator.navigationController?.tabBarController,
           tabBar.selectedIndex == 0 {
            homeCoordinator.homeVM?.reloadExamSchedule()
        } else {
            homeCoordinator.needsRefresh = true
        }
    }
}

// MARK: - MyPageCoordinatorDelegate

extension TabBarCoordinatorImpl: MyPageCoordinatorDelegate {
    func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator) {
        logout()
    }
}
