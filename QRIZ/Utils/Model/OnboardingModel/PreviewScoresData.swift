//
//  PreviewScoresData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class PreviewScoresData: ObservableObject {
    @Published var subject1Score: CGFloat = 0
    @Published var subject2Score: CGFloat = 0
    @Published var expectScore: Int = 0
}
