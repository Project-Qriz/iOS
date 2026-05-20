import SwiftUI
import DesignSystem
import QRIZUtils

struct PlanOptionCard: View {

    // MARK: - Properties

    let option: PlanOption
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Image(uiImage: option.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                Text(option.dayLabel)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.coolNeutral800)

                Text(option.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.coolNeutral600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.customBlue500 : Color.clear, lineWidth: 1.5)
            )
            .qrizCardShadow(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        PlanOptionCard(option: .sevenDay, isSelected: true, onTap: {})
        PlanOptionCard(option: .fourteenDay, isSelected: false, onTap: {})
        PlanOptionCard(option: .thirtyDay, isSelected: false, onTap: {})
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 24)
    .background(Color.coolNeutral100)
}
