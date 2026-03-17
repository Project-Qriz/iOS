import SwiftUI
import DesignSystem
import QRIZUtils

private let sections: [(title: String, range: Range<Int>)] = [
    ("데이터 모델링의 이해", 0..<5),
    ("데이터 모델과 SQL", 5..<10),
    ("SQL 기본", 10..<18),
    ("SQL 활용", 18..<26),
    ("SQL 명령어", 26..<30),
]

struct CheckConceptView: View {
    @ObservedObject var viewModel: CheckConceptViewModel
    @State private var expandedSections: Set<Int> = Set(0..<5)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("아는 개념을 체크해주세요!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 48)
                .padding(.horizontal, 24)

            Text("체크하신 결과를 토대로\n추후 진행할 테스트의 레벨이 조정됩니다!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 20)
                .padding(.horizontal, 24)

            // 전체 해제 버튼
            Button(action: { viewModel.didTapNone() }) {
                HStack {
                    Image(systemName: viewModel.selectedSet.isEmpty ? "checkmark.square.fill" : "square")
                        .foregroundColor(viewModel.selectedSet.isEmpty ? Color(.customBlue500) : Color(.coolNeutral400))
                        .font(.system(size: 20))
                    Text("전체 해제")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.coolNeutral800))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
                .background(Color.white)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 32)

            Divider()
                .background(Color(.customBlue100))
                .frame(height: 2)
                .padding(.horizontal, 18)
                .padding(.top, 16)

            // 전체 선택 + 폴드
            HStack {
                Button(action: { viewModel.didTapAll() }) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedSet_isAll ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedSet_isAll ? Color(.customBlue500) : Color(.coolNeutral400))
                            .font(.system(size: 20))
                        Text("전체 선택")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.coolNeutral800))
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                Button(action: { toggleAllSections() }) {
                    Image(systemName: expandedSections.isEmpty ? "chevron.down" : "chevron.up")
                        .foregroundColor(Color(.coolNeutral600))
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 60)
            .padding(.top, 16)

            // 개념 목록
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sections.indices, id: \.self) { sectionIdx in
                        let section = sections[sectionIdx]
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
                                        title: SurveyCheckList.list[globalIdx],
                                        isSelected: viewModel.selectedSet.contains(globalIdx)
                                    ) {
                                        viewModel.didTapConcept(idx: globalIdx)
                                    }
                                }
                            },
                            label: {
                                Text(section.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(.coolNeutral700))
                                    .padding(.leading, 24)
                            }
                        )
                        .padding(.horizontal, 18)
                        .accentColor(Color(.coolNeutral600))
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color(.customBlue50))

            Spacer(minLength: 0)

            // 완료 버튼
            Button(action: { viewModel.didTapDone() }) {
                ZStack {
                    Text(viewModel.isLoading ? "" : "선택완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.isDoneButtonEnabled ? .white : Color(.coolNeutral500))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(viewModel.isDoneButtonEnabled ? Color(.customBlue500) : Color(.coolNeutral200))
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
        .background(Color(.customBlue50))
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

    private var selectedSet_isAll: Bool {
        viewModel.selectedSet.count == SurveyCheckList.list.count
    }

    private func toggleAllSections() {
        if expandedSections.isEmpty {
            expandedSections = Set(0..<sections.count)
        } else {
            expandedSections.removeAll()
        }
    }
}
