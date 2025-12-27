//
//  ErrorResponse.swift
//  QRIZ
//
//  Created by 김세훈 on 3/24/25.
//

import Foundation

struct ErrorResponse: Decodable {
    let code: Int
    let msg: String
    let reason: String?
    let detailCode: Int?
}
