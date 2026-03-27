//
//  HTTPHeaderField.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

public enum HTTPHeaderField: String, Sendable {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case acceptType = "Accept"
}

public enum TokenKey: String, Sendable {
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
}

public enum ContentType: String, Sendable {
    case json = "application/json"
}
