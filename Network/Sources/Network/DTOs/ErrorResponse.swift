//
//  ErrorResponse.swift
//  QRIZ
//
//  Created by 김세훈 on 3/24/25.
//

import Foundation

public struct ErrorResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let reason: String?
    public let detailCode: Int?
}
