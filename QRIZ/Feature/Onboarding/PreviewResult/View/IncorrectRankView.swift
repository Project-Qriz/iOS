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
                .font(rankTextFont(rank))
                .foregroundColor(rankTextColor(rank))
                .frame(width: 33, height: 28)
                .background(rankBgColor(rank))
                .cornerRadius(4)
            
            Text("\(topic)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(topicTextColor(rank))
            
            Spacer()
            
            Text("\(incorrectNum)문제")
                .font(.system(size: 16))
                .foregroundColor(rankTextColor(rank))
        }
        
    }
    
    private func rankTextColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return .customBlue500
        case 2:
            return .coolNeutral500
        default:
            return .clear
        }
    }
    
    private func rankTextFont(_ rank: Int) -> Font {
        switch rank {
        case 1:
            return .system(size: 12, weight: .bold)
        case 2:
            return .system(size: 12)
        default:
            return .system(size: 0)
        }
    }
    
    private func rankBgColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return .customBlue200
        case 2:
            return .coolNeutral200
        default:
            return .clear
        }
    }
    
    private func topicTextColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return .customBlue500
        case 2:
            return .coolNeutral600
        default:
            return .clear
        }
    }
}

#Preview {
    IncorrectRankView()
}
