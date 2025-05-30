//
//  ExamScoresGraphView.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import SwiftUI
import Charts

struct ExamScoresGraphView: View {
    
    @ObservedObject var scoreGraphData: ScoreGraphData
    private let totalColor: Color = .coolNeutral600
    private let subject1Color: Color = .coolNeutral600
    private let subject2Color: Color = .customBlue500
    private let highlightedColor: Color = .customBlue500
    private let unHighlightedColor: Color = .coolNeutral600
    private let gridColor: Color = .coolNeutral200
    private let axisLabelColor: Color = .coolNeutral600
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("점수 변동")
                    .foregroundStyle(.coolNeutral800)
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                Menu {
                    ForEach(ScoreGraphFilterType.allCases, id: \.self) { type in
                        Button {
                            scoreGraphData.filterType = type
                        } label: {
                            Text(type.rawValue)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(scoreGraphData.filterType.rawValue)
                            .foregroundColor(.coolNeutral800)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 9, height: 5)
                            .foregroundColor(.coolNeutral800)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            Spacer(minLength: 8)
            
            HStack {
                Text("(점수)")
                    .foregroundStyle(.coolNeutral400)
                    .font(.system(size: 12, weight: .regular))
                Spacer()
            }
            
            graphView()
                .aspectRatio(1, contentMode: .fit)
            
            if scoreGraphData.filterType == .bySubject {
                HStack(spacing: 6) {
                    Spacer()
                    
                    ForEach([subject1Color, subject2Color].indices, id: \.self) {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundStyle($0 == 0 ? subject1Color : subject2Color)
                        
                        Text("\($0 + 1)과목")
                            .foregroundColor(Color.coolNeutral500)
                            .font(.system(size: 14, weight: .regular))
                    }

                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

extension ExamScoresGraphView {
    @ViewBuilder
    func graphView() -> some View {
        let graphData = (
            scoreGraphData.filterType == .byTotalScore ?
            scoreGraphData.totalScores : scoreGraphData.subjectScores)
        
        Chart(graphData, id: \.date) {
            let isLast = $0.date == graphData.last!.date && scoreGraphData.filterType == .byTotalScore
            
            LineMark(
                x: .value("Date", $0.date),
                y: .value("Score", $0.score)
            )
            .lineStyle(StrokeStyle(lineWidth: 4))
            .foregroundStyle($0.type == "2과목" ? subject2Color: subject1Color)
            .foregroundStyle(by: .value("\($0.type)", $0.type))
            .symbol(.circle)
            
            PointMark(
                x: .value("Date", $0.date),
                y: .value("Score", $0.score)
            )
            .foregroundStyle(isLast ? highlightedColor : .white)
            .symbolSize(isLast ? 20 : 12)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { value in
                AxisGridLine().foregroundStyle(gridColor)
                AxisTick().foregroundStyle(gridColor)
                AxisValueLabel() {
                    if let dateValue = value.as(Date.self) {
                        let isHighlighted = (
                            dateValue == graphData.last!.date &&
                            scoreGraphData.filterType == .byTotalScore)
                        
                        Text(dateValue.graphText)
                            .foregroundStyle(
                                isHighlighted ? highlightedColor : unHighlightedColor)
                            .font(.system(size: 12, weight: isHighlighted ? .bold : .medium))
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(preset: .extended, position: .leading, values: .stride(by: 20)) { value in
                AxisGridLine().foregroundStyle(gridColor)
                AxisTick().foregroundStyle(gridColor)
                AxisValueLabel()
                    .foregroundStyle(axisLabelColor)
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .chartLegend(.hidden)
    }
}


#Preview {
    ExamScoresGraphView(scoreGraphData: ScoreGraphData())
}
