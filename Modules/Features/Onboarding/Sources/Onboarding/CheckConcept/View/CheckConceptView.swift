import SwiftUI
import DesignSystem
import Network
import QRIZUtils

struct CheckConceptView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: CheckConceptViewModel
    @State private var isExpanded: Bool = true

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            clearAllButton
            divider
            selectAllRow
            conceptList
            Spacer(minLength: 0)
            doneButton
        }
        .background(Color.customBlue50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "오류",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Content

private extension CheckConceptView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("아는 개념을 체크해주세요!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            Text("체크하신 결과를 토대로\n추후 진행할 테스트의 레벨이 조정됩니다!")
                .font(.system(size: 16))
                .foregroundColor(Color.coolNeutral500)
                .lineSpacing(4)
        }
        .padding(.top, 48)
        .padding(.horizontal, 24)
    }

    var clearAllButton: some View {
        Button(action: { viewModel.didTapNone() }) {
            HStack {
                Image(uiImage: viewModel.selectedSet.isEmpty ? .checkboxOnIcon : .checkboxOffIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("모든 개념을 처음 봐요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.coolNeutral800)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.white)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.top, 32)
    }

    var divider: some View {
        Divider()
            .background(Color.customBlue100)
            .frame(height: 1)
            .padding(.horizontal, 18)
            .padding(.top, 16)
    }

    var selectAllRow: some View {
        HStack {
            Button(action: { viewModel.didTapAll() }) {
                HStack(spacing: 12) {
                    Image(uiImage: viewModel.isAllSelected ? .checkboxOnIcon : (viewModel.selectedSet.isEmpty ? .checkboxOffIcon : .checkboxSomeIcon))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("전부 아는 개념이에요!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.coolNeutral800)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(Color.coolNeutral600)
                    .font(.system(size: 16))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    var conceptList: some View {
        ScrollView {
            if isExpanded {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.allConceptIndices, id: \.self) { idx in
                        ConceptRowView(
                            title: viewModel.title(for: idx),
                            isSelected: viewModel.selectedSet.contains(idx),
                            action: { viewModel.didTapConcept(at: idx) }
                        )
                    }
                }
                .padding(.leading, 30)
                .padding(.bottom, 80)
            }
        }
        .background(Color.customBlue50)
    }

    var doneButton: some View {
        Button(action: { viewModel.didTapDone() }) {
            ZStack {
                Text("선택완료")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(viewModel.isDoneButtonEnabled ? .white : Color.coolNeutral500)
                    .opacity(viewModel.isLoading ? 0 : 1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.isDoneButtonEnabled ? Color.customBlue500 : Color.coolNeutral200)
                    .cornerRadius(8)

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .disabled(!viewModel.isDoneButtonEnabled || viewModel.isLoading)
        .padding(.horizontal, 18)
        .padding(.bottom, 30)
    }
}

// MARK: - Preview

private struct PreviewOnboardingService: OnboardingService {
    func sendSurvey(keyConcepts: [String]) async throws {}
    func getPreviewTestList() async throws -> PreviewTestListResponse { fatalError() }
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse { fatalError() }
    func analyzePreview() async throws -> AnalyzePreviewResponse { fatalError() }
}

#Preview {
    CheckConceptView(
        viewModel: CheckConceptViewModel(
            onboardingService: PreviewOnboardingService(),
            onNavigate: { _ in }
        )
    )
}
