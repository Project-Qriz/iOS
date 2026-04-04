import SwiftUI
import DesignSystem

struct PreviewResultIncorrectRankView: View {
    
    // MARK: - Properties
    
    let rank: Int
    let topic: [String]
    let incorrectNum: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top) {
            if isTopRank {
                rankBadge
                Spacer(minLength: 8)
            }
            topicList
        }
    }
}

// MARK: - Content

private extension PreviewResultIncorrectRankView {
    
    var rankBadge: some View {
        Text("\(rank)위")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(rankColors.textColor)
            .frame(width: 33, height: 28)
            .background(rankColors.bgColor)
            .cornerRadius(4)
    }
    
    var topicList: some View {
        VStack(spacing: 4) {
            ForEach(topic, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.system(size: 16, weight: isTopRank ? .bold : .regular))
                    Spacer()
                    Text("\(incorrectNum)문제")
                        .font(.system(size: 14, weight: .regular))
                }
                .foregroundStyle(rankColors.topicTextColor)
                .frame(height: 28)
            }
        }
    }
    
    var isTopRank: Bool {
        rank < 3
    }
    
    var rankColors: RankColors {
        RankColors.colors(for: rank)
    }
}

// MARK: - RankColors

private extension PreviewResultIncorrectRankView {
    
    struct RankColors {
        let textColor: Color
        let bgColor: Color
        let topicTextColor: Color
        
        static func colors(for rank: Int) -> RankColors {
            switch rank {
            case 1:
                return RankColors(
                    textColor: Color.customBlue500,
                    bgColor: Color.customBlue100,
                    topicTextColor: Color.coolNeutral700
                )
            case 2:
                return RankColors(
                    textColor: Color.coolNeutral500,
                    bgColor: Color.coolNeutral100,
                    topicTextColor: Color.coolNeutral600
                )
            case 3:
                return RankColors(
                    textColor: .white,
                    bgColor: .white,
                    topicTextColor: Color.coolNeutral500
                )
            default:
                return RankColors(
                    textColor: .clear,
                    bgColor: .clear,
                    topicTextColor: .clear
                )
            }
        }
    }
}

#Preview {
    PreviewResultIncorrectRankView(
        rank: 1,
        topic: ["Test"],
        incorrectNum: 1
    )
}
