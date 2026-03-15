//
//  ProblemDetailView.swift
//  MistakeNote
//
//  Created by Claude on 12/30/25.
//

import SwiftUI
import DesignSystem
import Network
import QRIZUtils

public struct ProblemDetailView: View {

    @ObservedObject public var viewModel: ProblemDetailViewModel

    public init(viewModel: ProblemDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.customBlue50.ignoresSafeArea()
            contentGroup
        }
    }
}

// MARK: - View Sections
private extension ProblemDetailView {

    @ViewBuilder
    var contentGroup: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if let data = viewModel.problemDetail {
            mainScrollView(data: data)
        }
    }

    func mainScrollView(data: DailyResultDetailEntity) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                // 헤더 카드 (과목, 시험 정보 등)
                ProblemHeaderCardView(data: data.headerData)
                    .padding(.bottom, 16)

                // 문제 섹션
                VStack(spacing: 8) {
                    ProblemQuestionSectionView(data: data.questionData)

                    ProblemResultView(
                        correctAnswer: data.answer,
                        userAnswer: data.checked ?? 0
                    )
                }

                // 풀이 및 개념 섹션
                VStack(spacing: 12) {
                    ProblemSolutionView(
                        keyConcepts: data.keyConcepts,
                        solutionText: data.solution
                    )

                    ProblemKeyConceptsView(
                        keyConcepts: data.keyConcepts,
                        subject: data.title,
                        onConceptTap: { viewModel.conceptTapped(concept: $0) }
                    )
                }

                // 하단 액션 버튼
                learnButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Subviews
private extension ProblemDetailView {

    var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(Color.coolNeutral600))
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                viewModel.retry()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(Color.customBlue500))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var learnButton: some View {
        Button(action: { viewModel.learnButtonTapped() }) {
            Text("학습하러 가기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(Color.customBlue500))
                .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProblemDetailView(
            viewModel: ProblemDetailViewModel {
                let service = DailyServiceImpl()
                let response = try await service.getDailyResultDetail(dayNumber: 1, questionId: 1)
                return response.data.toEntity()
            }
        )
    }
}
