//
//  TestRequest.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Foundation
@testable import Network

struct TestResponse: Decodable, Sendable {
    let message: String
}

struct TestRequest: Request, Sendable {
    typealias Response = TestResponse

    var baseURL: URL { URL(string: "https://test.example.com")! }
    var path: String = "/api/test"
    var method: HTTPMethod = .get
    var query: QueryItems = [:]
    var headers: HTTPHeader = [:]
    var body: Encodable? { nil }
}

struct AuthenticatedTestRequest: Request, Sendable {
    typealias Response = TestResponse

    var baseURL: URL { URL(string: "https://test.example.com")! }
    var path: String = "/api/protected"
    var method: HTTPMethod = .get
    var query: QueryItems = [:]
    var body: Encodable? { nil }

    var headers: HTTPHeader {
        [HTTPHeaderField.authorization.rawValue: "test-access-token"]
    }
}
