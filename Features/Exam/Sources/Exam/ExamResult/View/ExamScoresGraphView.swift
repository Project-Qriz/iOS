//
//  ExamScoresGraphView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem
import Charts
import QRIZUtils

struct ExamScoresGraphView: View {

    // MARK: - Properties

    @ObservedObject var scoreGraphData: ScoreGraphData

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            headerRow
            scoreUnitLabel
            if scoreGraphData.filterType == .byTotalScore {
                totalHistoryChart
                    .aspectRatio(1, contentMode: .fit)
            } else {
                subjectHistoryChart
                    .aspectRatio(1, contentMode: .fit)
                subjectLegend
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

// MARK: - Subviews

private extension ExamScoresGraphView {

    var headerRow: some View {
        HStack {
            Text("점수 변동")
                .foregroundStyle(Color.coolNeutral800)
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
                        .foregroundStyle(Color.coolNeutral800)
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 9, height: 5)
                        .foregroundStyle(Color.coolNeutral800)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    var scoreUnitLabel: some View {
        HStack {
            Text("(점수)")
                .foregroundStyle(Color.coolNeutral400)
                .font(.system(size: 12, weight: .regular))
            Spacer()
        }
    }

    var subjectLegend: some View {
        HStack(spacing: 6) {
            Spacer()
            ForEach(Self.legendItems, id: \.label) { item in
                Circle()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(item.color)
                Text(item.label)
                    .foregroundStyle(Color.coolNeutral500)
                    .font(.system(size: 14, weight: .regular))
            }
            Spacer()
        }
    }

    var totalHistoryChart: some View {
        let graphData = scoreGraphData.totalScores
        return Chart(Array(graphData.enumerated()), id: \.element.id) { index, item in
            let isLast = index == graphData.count - 1
            LineMark(
                x: .value("Index", index),
                y: .value("Score", item.score)
            )
            .lineStyle(StrokeStyle(lineWidth: 4))
            .foregroundStyle(Self.subject1Color)
            .symbol(.circle)

            PointMark(
                x: .value("Index", index),
                y: .value("Score", item.score)
            )
            .foregroundStyle(isLast ? Self.highlightedColor : .white)
            .symbolSize(isLast ? 20 : 12)
        }
        .chartXAxis { totalXAxis(graphData: graphData) }
        .chartYScale(domain: 0...100)
        .chartYAxis { sharedYAxis }
        .chartLegend(.hidden)
    }

    var subjectHistoryChart: some View {
        let combinedData = scoreGraphData.indexedSubject1Scores + scoreGraphData.indexedSubject2Scores
        return Chart(combinedData) { item in
            LineMark(
                x: .value("Index", item.index),
                y: .value("Score", item.score)
            )
            .lineStyle(StrokeStyle(lineWidth: 4))
            .foregroundStyle(item.type == Self.subject1TypeIdentifier ? Self.subject1Color : Self.subject2Color)
            .symbol(.circle)

            PointMark(
                x: .value("Index", item.index),
                y: .value("Score", item.score)
            )
            .foregroundStyle(.white)
            .symbolSize(12)
        }
        .chartXAxis { subjectXAxis }
        .chartYScale(domain: 0...100)
        .chartYAxis { sharedYAxis }
        .chartLegend(.hidden)
    }

    @AxisContentBuilder
    func totalXAxis(graphData: [GraphData]) -> some AxisContent {
        AxisMarks(preset: .aligned, values: Array(graphData.indices)) { value in
            if let index = value.as(Int.self) {
                let item = graphData[index]
                let isHighlighted = index == graphData.count - 1
                AxisGridLine().foregroundStyle(Self.gridColor)
                AxisTick().foregroundStyle(Self.gridColor)
                AxisValueLabel {
                    Text(item.date.graphText)
                        .foregroundStyle(isHighlighted ? Self.highlightedColor : Self.unHighlightedColor)
                        .font(.system(size: 12, weight: isHighlighted ? .bold : .medium))
                }
            }
        }
    }

    @AxisContentBuilder
    var subjectXAxis: some AxisContent {
        AxisMarks(preset: .aligned, values: scoreGraphData.indexedSubject1Scores.map { $0.index }) { value in
            if let idx = value.as(Int.self), idx < scoreGraphData.subject1Scores.count {
                let dateValue = scoreGraphData.subject1Scores[idx].date
                let isHighlighted = idx == scoreGraphData.indexedSubject1Scores.count - 1
                AxisGridLine().foregroundStyle(Self.gridColor)
                AxisTick().foregroundStyle(Self.gridColor)
                AxisValueLabel {
                    Text(dateValue.graphText)
                        .foregroundStyle(isHighlighted ? Self.highlightedColor : Self.unHighlightedColor)
                        .font(.system(size: 12, weight: isHighlighted ? .bold : .medium))
                }
            }
        }
    }

    @AxisContentBuilder
    var sharedYAxis: some AxisContent {
        AxisMarks(preset: .extended, position: .leading, values: .stride(by: 20)) { _ in
            AxisGridLine().foregroundStyle(Self.gridColor)
            AxisTick().foregroundStyle(Self.gridColor)
            AxisValueLabel()
                .foregroundStyle(Self.axisLabelColor)
                .font(.system(size: 12, weight: .medium))
        }
    }
}

// MARK: - Constants

private extension ExamScoresGraphView {
    static let subject1Color: Color = .coolNeutral600
    static let subject2Color: Color = .customBlue500
    static let highlightedColor: Color = .customBlue500
    static let unHighlightedColor: Color = .coolNeutral600
    static let gridColor: Color = .coolNeutral200
    static let axisLabelColor: Color = .coolNeutral600
    static let subject1TypeIdentifier = "1과목"
    static let subject2TypeIdentifier = "2과목"
    static let legendItems: [(color: Color, label: String)] = [
        (subject1Color, subject1TypeIdentifier),
        (subject2Color, subject2TypeIdentifier)
    ]
}
