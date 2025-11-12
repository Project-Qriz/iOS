//
//  HTTPHeaderField.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

import Foundation

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case acceptType = "Accept"
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
}

enum ContentType: String {
    case json = "application/json"
}
