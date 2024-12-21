//
//  ExampleResponse.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation

struct ExampleResponse: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
