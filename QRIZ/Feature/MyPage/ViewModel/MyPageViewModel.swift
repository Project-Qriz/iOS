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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "MyPageViewModel")
    
    // MARK: - Initialize
    
    init(userName: String, myPageService: MyPageService = MyPageServiceImpl()) {
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
    
    // 백엔드 수정중
    private func fetchVersion() {
        outputSubject.send(.setupView(userName: userName, version: "2.1.2"))
    }
    
    @MainActor
    private func performReset() async {
        do {
            let response = try await myPageService.resetPlan()
            outputSubject.send(.resetSucceeded(message: response.msg))
            
        } catch let error as NetworkError  {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("플랜 초기화에 실패했습니다."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension MyPageViewModel {
    enum Input {
        case viewDidLoad
        case didTapResetPlan
        case didConfirmResetPlan
        case didTapRegisterExam
        case didTapTermsOfService
        case didTapPrivacyPolicy
    }
    
    enum Output {
        case setupView(userName: String, version: String)
        case showResetAlert
        case resetSucceeded(message: String)
        case showErrorAlert(String)
        case showExamSchedule
        case showTermsDetail(termItem: TermItem)
    }
}
