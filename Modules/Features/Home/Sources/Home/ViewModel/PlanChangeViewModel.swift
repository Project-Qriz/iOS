//
//  PlanChangeViewModel.swift
//  Home

import Foundation
import Combine
import os.log
import QRIZNetwork
import QRIZUtils

@MainActor
protocol PlanChangeDelegate: AnyObject {
    func planChangeDidComplete()
    func planChangeDidRequestReset()
    func planChangeDidDismiss()
}

@MainActor
final class PlanChangeViewModel {

    // MARK: - Input / Output

    enum Input {
        case viewDidLoad
        case selectPlan(PlanOption)
        case tapConfirm
        case tapReset
        case tapResetConfirmed
        case tapDismiss
    }

    enum Output {
        case applyCurrentPlan(PlanOption?)
        case applyAvailablePlans([PlanOption])
        case applySelection(PlanOption?)
        case setConfirmEnabled(Bool)
        case setLoading(Bool)
        case showResetAlert
        case showAlert(title: String, description: String)
        case showError(String)
    }

    // MARK: - Properties

    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var currentPlan: PlanOption?
    private var selectedPlan: PlanOption?
    private var isLoading = false

    private var isConfirmEnabled: Bool {
        guard let selected = selectedPlan, let current = currentPlan else { return false }
        return !isLoading && selected != current
    }

    private let logger = Logger.make(category: "PlanChangeViewModel")
    private let dailyService: any DailyService
    weak var delegate: (any PlanChangeDelegate)?

    // MARK: - Initialization

    init(dailyService: any DailyService) {
        self.dailyService = dailyService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .viewDidLoad:
                    Task { await self.loadAvailablePlans() }
                case .selectPlan(let plan):
                    self.selectedPlan = plan
                    self.outputSubject.send(.applySelection(plan))
                    self.outputSubject.send(.setConfirmEnabled(self.isConfirmEnabled))
                case .tapConfirm:
                    guard self.isConfirmEnabled, let plan = self.selectedPlan else { return }
                    Task { await self.changePlan(plan) }
                case .tapReset:
                    self.outputSubject.send(.showResetAlert)
                case .tapResetConfirmed:
                    Task { await self.resetPlan() }
                case .tapDismiss:
                    self.delegate?.planChangeDidDismiss()
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Private

    private func loadAvailablePlans() async {
        setLoading(true)
        do {
            let response = try await dailyService.getChangeavailablePlans()
            currentPlan = PlanOption(rawValue: response.data.currentPlanType)
            let available = response.data.availablePlanTypes.compactMap { PlanOption(rawValue: $0) }
            outputSubject.send(.applyCurrentPlan(currentPlan))
            outputSubject.send(.applyAvailablePlans(available))
            outputSubject.send(.setConfirmEnabled(isConfirmEnabled))
        } catch {
            outputSubject.send(.showError("잠시 후 다시 시도해주세요."))
        }
        setLoading(false)
    }

    private func resetPlan() async {
        setLoading(true)
        do {
            _ = try await dailyService.resetPlan()
            delegate?.planChangeDidRequestReset()
            return
        } catch NetworkError.clientError(_, _, let message) {
            logger.error("NetworkError(resetPlan): \(message, privacy: .public)")
            outputSubject.send(.showAlert(title: "초기화할 수 없습니다.", description: message))
        } catch let error as NetworkError {
            logger.error("NetworkError(resetPlan): \(error.debugDescription, privacy: .public)")
            outputSubject.send(.showError(error.errorMessage))
        } catch {
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
            outputSubject.send(.showError("잠시 후 다시 시도해주세요."))
        }
        setLoading(false)
    }

    private func changePlan(_ plan: PlanOption) async {
        setLoading(true)
        do {
            _ = try await dailyService.changePlan(planType: plan.planType)
            delegate?.planChangeDidComplete()
            return
        } catch let error as NetworkError {
            logger.error("NetworkError(changePlan): \(error.debugDescription, privacy: .public)")
            outputSubject.send(.showError(error.errorMessage))
        } catch {
            logger.error("Unhandled error(changePlan): \(error.localizedDescription, privacy: .public)")
            outputSubject.send(.showError("잠시 후 다시 시도해주세요."))
        }
        setLoading(false)
    }

    private func setLoading(_ loading: Bool) {
        isLoading = loading
        outputSubject.send(.setLoading(loading))
        outputSubject.send(.setConfirmEnabled(isConfirmEnabled))
    }
}
