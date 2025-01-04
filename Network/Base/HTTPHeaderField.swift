//
//  HTTPHeaderField.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

import Foundation

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authentication = "Authorization"
    case refreshToken = "Refresh-Token"
    case acceptType = "Accept"
}

enum ContentType: String {
    case json = "Application/json"
}
