//
//  SubItemInfo.swift
//  QRIZ
//

import QRIZUtils

public struct SubItemInfo: Decodable, Sendable {
    public let subItem: String
    public let score: Double

    public func toEntity() -> SubItemInfoEntity {
        SubItemInfoEntity(subItem: subItem, score: score)
    }
}
