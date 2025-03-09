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
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 45))
                    .foregroundStyle(.customBlue800)
                createTrimmedCircle(subject1Score: previewScoresData.subject1Score)
                createTrimmedCircle(subject1Score: previewScoresData.subject1Score, subject2Score: previewScoresData.subject2Score)
                VStack {
                    Text("총점수")
                        .font(.system(size: 14, weight: .regular))
                    Text("\(Int((previewScoresData.subject1Score + previewScoresData.subject2Score) * 100))점")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.coolNeutral800)
            }
            .frame(width: 125, height: 125)
            
            Spacer(minLength: 12)
            
            HStack {
                Spacer()
                
                VStack {
                    HStack {
                        Circle()
                            .foregroundStyle(.customBlue700)
                            .frame(width: 14, height: 14)
                        
                        Text("1과목")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.coolNeutral700)
                    }
                    Text("\(Int(previewScoresData.subject1Score * 100))점")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }
                
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(width: 8)
                
                Divider()

                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(width: 8)
                
                VStack {
                    HStack {
                        Circle()
                            .foregroundStyle(.customBlue400)
                            .frame(width: 14, height: 14)
                        
                        Text("2과목")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.coolNeutral700)
                    }
                    Text("\(Int(previewScoresData.subject2Score * 100))점")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }

                Spacer()
            }
        }
        .background(.white)
        .padding(EdgeInsets(top: 24, leading: 50, bottom: 24, trailing: 50))
    }
    
    private func createTrimmedCircle(subject1Score: CGFloat, subject2Score: CGFloat = -1.0) -> some View {
        subject2Score == -1.0 ?
        Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score)
            .stroke(style: StrokeStyle(lineWidth: 45, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.customBlue500)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: 1.0 - subject1Score)
        : Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score - subject2Score)
            .stroke(style: StrokeStyle(lineWidth: 45, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.coolNeutral400)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: subject1Score)
    }
}

#Preview {
    ScoreCircularChartView(previewScoresData: PreviewScoresData())
}
