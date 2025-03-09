//
//  IncorrectRankView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct IncorrectRankView: View {
    
    var rank: Int = 0
    var topic: String = ""
    var incorrectNum: Int = 0
    
    var body: some View {
        HStack(spacing: 8) {
            
            Text("\(rank)위")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(RankColors.colors(for: rank).textColor)
                .frame(width: 33, height: 28)
                .background(RankColors.colors(for: rank).bgColor)
                .cornerRadius(4)
            
            Text("\(topic)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(RankColors.colors(for: rank).topicTextColor)
            
            Spacer()
            
            Text("\(incorrectNum)문제")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(RankColors.colors(for: rank).topicTextColor)
        }
        
    }
    
    private struct RankColors {
        let textColor: Color
        let bgColor: Color
        let topicTextColor: Color
        
        static func colors(for rank: Int) -> RankColors {
            switch rank {
            case 1:
                return RankColors(
                    textColor: .customBlue500,
                    bgColor: .customBlue100,
                    topicTextColor: .customBlue500
                )
            case 2:
                return RankColors(
                    textColor: .coolNeutral500,
                    bgColor: .coolNeutral100,
                    topicTextColor: .coolNeutral600
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
    IncorrectRankView()
}
