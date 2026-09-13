import SwiftUI
import DesignSystem

/// 홈 화면 위에 dim 배경과 함께 뜨는 리뷰 요청 팝업.
struct ReviewRequestPopupView: View {
    let onPostpone: () -> Void
    let onReview: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    HStack(spacing: 12) {
                        Image(uiImage: .developerProfile)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("훈")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.coolNeutral800)
                            Text("개발자")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.coolNeutral600)
                        }
                    }

                    Spacer()

                    Button(action: onPostpone) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.coolNeutral500)
                    }
                }

                Text("안녕하세요! Qriz로 시험 준비, 잘 되고 계신가요?\n짧은 리뷰 한 줄이 큰 힘이 돼요!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.coolNeutral800)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    Button(action: onPostpone) {
                        Text("다음 기회에")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(Color.coolNeutral800)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.coolNeutral200, lineWidth: 1)
                            )
                    }

                    Button(action: onReview) {
                        Text("쓸게요!")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.customBlue500)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 32)
        }
    }
}
