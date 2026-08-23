import SwiftUI
import DesignSystem

struct AgeConfirmationRowView: View {
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(isChecked ? Color.customBlue500 : Color.coolNeutral200)
                .frame(width: 20, height: 20)
                .onTapGesture(perform: onToggle)

            Text("만 14세 이상입니다")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.coolNeutral600)

            Spacer()
        }
    }
}
