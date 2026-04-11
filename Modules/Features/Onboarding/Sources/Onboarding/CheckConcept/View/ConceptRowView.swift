import SwiftUI
import DesignSystem

struct ConceptRowView: View {

    // MARK: - Properties

    let title: String
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                checkboxIcon
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.coolNeutral800)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.customBlue100.opacity(0.7), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
    }
}

// MARK: - Content

private extension ConceptRowView {

    var checkboxIcon: some View {
        Image(uiImage: isSelected ? .checkboxOnIcon : .checkboxOffIcon)
            .resizable()
            .frame(width: 24, height: 24)
    }
}
