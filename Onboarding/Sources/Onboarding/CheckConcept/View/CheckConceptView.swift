import SwiftUI
import DesignSystem

struct CheckConceptView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: CheckConceptViewModel
    @State private var expandedSections: Set<Int> = Set(0..<5)

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
                Image(systemName: viewModel.selectedSet.isEmpty ? "checkmark.square.fill" : "square")
                    .foregroundColor(viewModel.selectedSet.isEmpty ? Color.customBlue500 : Color.coolNeutral400)
                    .font(.system(size: 20))
                Text("전체 해제")
                    .font(.system(size: 14))
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
            .frame(height: 2)
            .padding(.horizontal, 18)
            .padding(.top, 16)
    }

    var selectAllRow: some View {
        HStack {
            Button(action: { viewModel.didTapAll() }) {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isAllSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(viewModel.isAllSelected ? Color.customBlue500 : Color.coolNeutral400)
                        .font(.system(size: 20))
                    Text("전체 선택")
                        .font(.system(size: 14))
                        .foregroundColor(Color.coolNeutral800)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button(action: { toggleAllSections() }) {
                Image(systemName: expandedSections.isEmpty ? "chevron.down" : "chevron.up")
                    .foregroundColor(Color.coolNeutral600)
                    .font(.system(size: 16))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 60)
        .padding(.top, 16)
    }

    var conceptList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections.indices, id: \.self) { sectionIdx in
                    let section = viewModel.sections[sectionIdx]
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSections.contains(sectionIdx) },
                            set: { expanded in
                                if expanded { expandedSections.insert(sectionIdx) }
                                else { expandedSections.remove(sectionIdx) }
                            }
                        ),
                        content: {
                            ForEach(section.range, id: \.self) { globalIdx in
                                ConceptRowView(
                                    title: viewModel.title(for: globalIdx),
                                    isSelected: viewModel.selectedSet.contains(globalIdx),
                                    action: { viewModel.didTapConcept(at: globalIdx) }
                                )
                            }
                        },
                        label: {
                            Text(section.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.coolNeutral700)
                                .padding(.leading, 24)
                        }
                    )
                    .padding(.horizontal, 18)
                    .accentColor(Color.coolNeutral600)
                }
            }
            .padding(.bottom, 80)
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

// MARK: - Private Methods

private extension CheckConceptView {

    func toggleAllSections() {
        if expandedSections.isEmpty {
            expandedSections = Set(0..<viewModel.sections.count)
        } else {
            expandedSections.removeAll()
        }
    }
}
