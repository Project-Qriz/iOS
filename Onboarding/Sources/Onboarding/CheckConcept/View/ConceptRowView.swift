import SwiftUI
import DesignSystem

struct ConceptRowView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? Color(.customBlue500) : Color(.coolNeutral400))
                    .font(.system(size: 20))

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.coolNeutral800))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color(.customBlue100).opacity(0.7), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
    }
}
