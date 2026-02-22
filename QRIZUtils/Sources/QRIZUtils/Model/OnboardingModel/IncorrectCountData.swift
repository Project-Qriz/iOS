//
//  IncorrectCountData.swift
//  QRIZUtils
//
//  Created by ch on 12/29/24.
//

import Foundation

public struct IncorrectCountData: Identifiable {
    public var id: Int = 0
    public var incorrectCount: Int = 0
    public var topic: [String] = []

    public init(id: Int = 0, incorrectCount: Int = 0, topic: [String] = []) {
        self.id = id
        self.incorrectCount = incorrectCount
        self.topic = topic
    }
}
