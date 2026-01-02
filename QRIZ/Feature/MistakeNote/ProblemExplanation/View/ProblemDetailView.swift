//
//  ProblemDetailView.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

struct ProblemDetailView: View {

    @ObservedObject var viewModel: ProblemDetailViewModel

    var body: some View {
            ZStack {
                Color.customBlue50.ignoresSafeArea()
                contentGroup
            }
            .navigationTitle("오답노트")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task { await viewModel.fetchProblemDetail() }
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

    func mainScrollView(data: DailyResultDetail) -> some View {
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
                        subject: data.title
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
                .foregroundColor(Color(.coolNeutral600))
                .multilineTextAlignment(.center)
            
            Button("다시 시도") {
                Task { await viewModel.fetchProblemDetail() }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(.customBlue500))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var learnButton: some View {
        Button(action: { /* 학습 동작 */ }) {
            Text("학습하러 가기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(.customBlue500))
                .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProblemDetailView(
            viewModel: ProblemDetailViewModel(
                service: DailyServiceImpl(),
                questionId: 1,
                dayNumber: 1
            )
        )
    }
}
