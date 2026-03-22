import SwiftUI
import DesignSystem

struct PreviewResultView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: PreviewResultViewModel

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            scrollContent
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("시험 결과")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.coolNeutral700)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button { viewModel.didTapClose() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.coolNeutral800)
                }
            }
        }
        .alert("오류", isPresented: isErrorPresented) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.onViewDidLoad() }
    }
}

// MARK: - Content

private extension PreviewResultView {

    var scrollContent: some View {
        VStack {
            PreviewResultScoreView(previewScoresData: viewModel.previewScoresData)
                .background(.white)
            Color.clear.frame(height: 16)
            PreviewResultConceptView(previewConceptsData: viewModel.previewConceptsData)
                .background(.white)
        }
        .background(contentBackgroundColor)
    }

    var contentBackgroundColor: Color {
        viewModel.previewConceptsData.incorrectCountDataArr.count >= 2 ? Color.customBlue50 : .white
    }

    var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}
