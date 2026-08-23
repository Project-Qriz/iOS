import SwiftUI
import DesignSystem

struct TermRowView: View {
    let title: String
    let isChecked: Bool
    let onToggle: () -> Void
    let onDetailTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(isChecked ? Color.customBlue500 : Color.coolNeutral200)
                .frame(width: 20, height: 20)
                .onTapGesture(perform: onToggle)

            Text("\(title) 동의")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.coolNeutral600)

            Text("(필수)")
                .font(.system(size: 14))
                .foregroundColor(Color.customRed500)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(Color.coolNeutral600)
                .frame(width: 20, height: 20)
                .onTapGesture(perform: onDetailTap)
        }
    }
}
