//
//  HTTPMethod.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

import Foundation

public enum HTTPMethod: String , Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
