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
            
            if scoreGraphData.filterType == .byTotalScore {
                totalHistoryGraphView()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                subjectHistoryGraphView()
                    .aspectRatio(1, contentMode: .fit)
            }
            
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
    func subjectHistoryGraphView() -> some View {
        
        let combinedData = scoreGraphData.indexedSubject1Scores + scoreGraphData.indexedSubject2Scores
        
        Chart(combinedData) { item in
            LineMark(
                x: .value("Index", item.index),
                y: .value("Score", item.score)
            )
            .lineStyle(StrokeStyle(lineWidth: 4))
            .foregroundStyle(item.type == "1과목" ? subject1Color : subject2Color)
            .foregroundStyle(by: .value("Type", item.type))
            .symbol(.circle)
            
            PointMark(
                x: .value("Index", item.index),
                y: .value("Score", item.score)
            )
            .foregroundStyle(.white)
            .symbolSize(12)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: scoreGraphData.indexedSubject1Scores.map { $0.index }) { value in
                if let idx = value.as(Int.self) {
                    if idx < scoreGraphData.subject1Scores.count {
                        let dateValue = scoreGraphData.subject1Scores[idx].date
                        let isHighlighted = (
                            dateValue == scoreGraphData.subject1Scores[scoreGraphData.subject1Scores.count - 1].date
                        )
                        AxisGridLine().foregroundStyle(gridColor)
                        AxisTick().foregroundStyle(gridColor)
                        AxisValueLabel {
                            Text(dateValue.graphText)
                                .foregroundStyle(isHighlighted ? highlightedColor : unHighlightedColor)
                                .font(.system(size: 12, weight: .medium))
                        }
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

    
    @ViewBuilder
    func totalHistoryGraphView() -> some View {
        
        let graphData = scoreGraphData.totalScores
        
        Chart(Array(graphData.enumerated()), id: \.element.date) { index, item in
            let isLast = index == graphData.count - 1
            
            LineMark(
                x: .value("Index", index),
                y: .value("Score", item.score)
            )
            .lineStyle(StrokeStyle(lineWidth: 4))
            .foregroundStyle(subject1Color)
            .symbol(.circle)
            
            PointMark(
                x: .value("Index", index),
                y: .value("Score", item.score)
            )
            .foregroundStyle(isLast ? highlightedColor : .white)
            .symbolSize(isLast ? 20 : 12)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: Array(graphData.indices)) { value in
                if let index = value.as(Int.self) {
                    let item = graphData[index]
                    let isHighlighted = (
                        index == graphData.count - 1
                    )
                    AxisGridLine().foregroundStyle(gridColor)
                    AxisTick().foregroundStyle(gridColor)
                    AxisValueLabel {
                        Text(item.date.graphText)
                            .foregroundStyle(isHighlighted ? highlightedColor : unHighlightedColor)
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
