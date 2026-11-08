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

// MARK: - Hosting Controller

/// X 버튼을 직접 관리하므로 QRIZNavigationController가 뒤로가기를 설치하지 않는다. (retroactive conformance 회피용 서브클래스)
final class PreviewResultHostingController: UIHostingController<PreviewResultView>, ManagesOwnLeadingBarItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setGlassCloseButton(tintColor: .coolNeutral800) { [weak self] in
            self?.rootView.viewModel.didTapClose()
        }
    }
}
