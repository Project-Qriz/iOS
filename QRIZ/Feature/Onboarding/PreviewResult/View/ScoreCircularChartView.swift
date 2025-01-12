//
//  SwiftUIView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct ScoreCircularChartView: View {
    
    @StateObject var previewScoresData: PreviewScoresData

    var body: some View {
        VStack(spacing: 8) {
            Text("예상 점수")
                .font(.system(size: 18))
                .foregroundColor(.coolNeutral500)
            
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 45))
                    .foregroundColor(.customBlue700)
                createTrimmedCircle(subject1Score: previewScoresData.subject1Score)
                createTrimmedCircle(subject1Score: previewScoresData.subject1Score, subject2Score: previewScoresData.subject2Score)
                Text("\(previewScoresData.expectScore)점")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(expectScoreColor(score: previewScoresData.expectScore))
            }
            .frame(width: 125, height: 125)
            
            Spacer(minLength: 12)
            
            HStack {
                Spacer()
                
                VStack {
                    HStack {
                        Circle()
                            .foregroundColor(.customBlue700)
                            .frame(width: 14, height: 14)
                        
                        Text("1과목")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.coolNeutral700)
                    }
                    Text("\(Int(previewScoresData.subject1Score * 100))점")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 8)
                
                Divider()

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 8)
                
                VStack {
                    HStack {
                        Circle()
                            .foregroundColor(.customBlue400)
                            .frame(width: 14, height: 14)
                        
                        Text("2과목")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.coolNeutral700)
                    }
                    Text("\(Int(previewScoresData.subject2Score * 100))점")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }

                Spacer()
            }
        }
        .background(.white)
        .padding(EdgeInsets(top: 24, leading: 50, bottom: 24, trailing: 50))
    }
    
    private func expectScoreColor(score: Int) -> Color {
        score == 100 ? .customBlue500 : .coolNeutral800
    }
    
    private func createTrimmedCircle(subject1Score: CGFloat, subject2Score: CGFloat = -1.0) -> some View {
        subject2Score == -1.0 ?
        Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score)
            .stroke(style: StrokeStyle(lineWidth: 45, lineCap: .butt, lineJoin: .round))
            .foregroundColor(.customBlue400)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: 1.0 - subject1Score)
        : Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score - subject2Score)
            .stroke(style: StrokeStyle(lineWidth: 45, lineCap: .butt, lineJoin: .round))
            .foregroundColor(.coolNeutral300)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: subject1Score)
    }
}

#Preview {
    ScoreCircularChartView(previewScoresData: PreviewScoresData())
}
