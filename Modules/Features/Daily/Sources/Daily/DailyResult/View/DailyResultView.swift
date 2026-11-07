//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine
import DesignSystem
import ExamKit

struct DailyResultView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: DailyResultViewModel
    @StateObject private var bridge = DailyResultExamKitBridge()

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                DailyResultScoreView(
                    resultScoresData: viewModel.resultScoresData,
                    resultDetailData: viewModel.resultDetailData,
                    dailyLearnType: viewModel.dailyTestType,
                    onDetailTap: viewModel.didTapResultDetail
                )
                Spacer(minLength: 16)
                TestResultGradesListView(
                    resultGradeListData: viewModel.resultGradeListData,
                    onProblemTap: bridge.problemTap
                )
                TestResultFooterView(
                    resultScoresData: viewModel.resultScoresData,
                    input: bridge.conceptTap
                )
            }
            .background(Color.customBlue50)
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("시험 결과")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.coolNeutral700)
            }
        }
        .alert("오류", isPresented: isErrorPresented) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onReceive(bridge.conceptTap) { viewModel.didTapConcept() }
        .onReceive(bridge.problemTap) { viewModel.didTapProblem(questionId: $0) }
        .onAppear(perform: viewModel.onViewDidLoad)
    }
}

// MARK: - Private

private extension DailyResultView {
    var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

// MARK: - Bridge

private final class DailyResultExamKitBridge: ObservableObject {
    let conceptTap = PassthroughSubject<Void, Never>()
    let problemTap = PassthroughSubject<Int, Never>()
}

// MARK: - Hosting Controller

/// 이 화면은 X 버튼을 직접 관리하므로 QRIZNavigationController가 관여하지 않는다.
///
/// X 버튼은 SwiftUI `.toolbar`가 아니라 UIKit `navigationItem`에 설치한다.
/// 공유 glass 배경을 숨기는 `ToolbarContent` 확장은 `#available` 분기 때문에
/// Release 아카이브에서 링크 오류(`buildLimitedAvailability`)를 일으킨다.
///
/// `UIHostingController`(SwiftUI 타입)에 직접 조건부 확장으로 채택하면, DesignSystem도 SwiftUI도
/// 아닌 제3의 모듈(Daily)에서 선언하는 "retroactive conformance"가 되어 컴파일러 경고가 뜬다.
/// 대신 이 모듈 소유의 서브클래스에 채택한다.
final class DailyResultHostingController: UIHostingController<DailyResultView>, ManagesOwnLeadingBarItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setGlassCloseButton(tintColor: .coolNeutral800) { [weak self] in
            self?.rootView.viewModel.didTapCancel()
        }
    }
}
