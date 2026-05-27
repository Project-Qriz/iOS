//
//  SubItemInfo.swift
//  QRIZ
//

import QRIZUtils

public struct SubItemInfo: Decodable, Sendable {
    public let subItem: String
    public let score: Double

    public init(subItem: String, score: Double) {
        self.subItem = subItem
        self.score = score
    }

    public func toEntity() -> SubItemInfoEntity {
        SubItemInfoEntity(subItem: subItem, score: score)
    }
}
