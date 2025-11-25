//
//  MyPageViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/9/25.
//

import Foundation
import Combine
import os

final class MyPageViewModel {
    
    // MARK: - Properties
    
    private let userName: String
    private let myPageService: MyPageService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "MyPageViewModel")
    
    // MARK: - Initialize
    
    init(userName: String, myPageService: MyPageService) {
        self.userName = userName
        self.myPageService = myPageService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    self.fetchVersion()
                    
                case .didTapProfile:
                    self.outputSubject.send(.navigateToSettingsView)
                    
                case .didTapResetPlan:
                    self.outputSubject.send(.showResetAlert)
                    
                case .didConfirmResetPlan:
                    Task { await self.performReset() }
                    
                case .didTapRegisterExam:
                    self.outputSubject.send(.showExamSchedule)
                    
                case .didTapTermsOfService:
                    self.outputSubject.send(.showTermsDetail(termItem: TermItem(
                        title: "서비스 이용약관",
                        pdfName: "TermsOfService",
                        isAgreed: false)))
                    
                case .didTapPrivacyPolicy:
                    self.outputSubject.send(.showTermsDetail(termItem:TermItem(
                        title: "개인정보 처리방침",
                        pdfName: "PrivacyPolicy",
                        isAgreed: false)))
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func fetchVersion() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let version = try await myPageService.fetchVersion()
                outputSubject.send(.setupView(userName: userName, version: "\(version.data.versionInfo)"))
                
            } catch let error as NetworkError {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                outputSubject.send(.setupView(userName: userName, version: version))
                logger.error("NetworkError(fetchVersion): \(error.description, privacy: .public)")
                
            } catch {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                outputSubject.send(.setupView(userName: userName, version: version))
                logger.error("Unhandled error(fetchVersion): \(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    @MainActor
    private func performReset() async {
        let title = "초기화할 수 없습니다."
        
        do {
            let response = try await myPageService.resetPlan()
            outputSubject.send(.resetSucceeded(message: response.msg))
            
        } catch let error as NetworkError  {
            outputSubject.send(.showErrorAlert(title: title, description: error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert(title: title, description: "잠시 후 다시 시도해주세요."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension MyPageViewModel {
    enum Input {
        case viewDidLoad
        case didTapProfile
        case didTapResetPlan
        case didConfirmResetPlan
        case didTapRegisterExam
        case didTapTermsOfService
        case didTapPrivacyPolicy
    }
    
    enum Output {
        case setupView(userName: String, version: String)
        case navigateToSettingsView
        case showResetAlert
        case resetSucceeded(message: String)
        case showErrorAlert(title: String, description: String? = nil)
        case showExamSchedule
        case showTermsDetail(termItem: TermItem)
    }
}
