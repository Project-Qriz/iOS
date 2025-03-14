//
//  IncorrectRankView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct PreviewResultIncorrectRankView: View {
    
    //    @State var rank: Int = 0
    //    @State var topic: [String] = [""]
    //    @State var incorrectNum: Int = 0
    
    @Binding var rank: Int
    @Binding var topic: [String]
    @Binding var incorrectNum: Int
    
    var body: some View {
        HStack(alignment: .top) {
            if rank < 3 {
                Text("\(rank)위")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(RankColors.colors(for: rank).textColor)
                    .frame(width: 33, height: 28)
                    .background(RankColors.colors(for: rank).bgColor)
                    .cornerRadius(4)
                
                
                Spacer(minLength: 8)
            }
            
            VStack(spacing: 4) {
                ForEach(topic, id: \.self) { item in
                    HStack {
                        Text("\(item)")
                            .font(.system(size: 16, weight: rank < 3 ? .bold : .regular))
                        Spacer()
                        
                        Text("\(incorrectNum)문제")
                            .font(.system(size: 14, weight: .regular))
                    }
                    .foregroundStyle(RankColors.colors(for: rank).topicTextColor)
                    .frame(height: 28)
                }
            }
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
                    topicTextColor: .coolNeutral700
                )
            case 2:
                return RankColors(
                    textColor: .coolNeutral500,
                    bgColor: .coolNeutral100,
                    topicTextColor: .coolNeutral600
                )
            case 3:
                return RankColors(
                    textColor: .white,
                    bgColor: .white,
                    topicTextColor: .coolNeutral500
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
    PreviewResultIncorrectRankView(rank: .constant(1),
                                   topic: .constant(["Test"]),
                                   incorrectNum: .constant(1))
}
