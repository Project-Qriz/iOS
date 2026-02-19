//
//  HTTPHeaderField.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

import Foundation

public enum HTTPHeaderField: String , Sendable {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case acceptType = "Accept"
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
}

public enum ContentType: String , Sendable {
    case json = "application/json"
}
