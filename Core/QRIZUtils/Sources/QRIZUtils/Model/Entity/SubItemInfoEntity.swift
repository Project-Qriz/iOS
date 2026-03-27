//
//  SubItemInfoEntity.swift
//  QRIZUtils
//
//  Created by 김세훈 on 2/22/26.
//

public struct SubItemInfoEntity: Sendable {
    public let subItem: String
    public let score: Double

    public init(subItem: String, score: Double) {
        self.subItem = subItem
        self.score = score
    }
}
