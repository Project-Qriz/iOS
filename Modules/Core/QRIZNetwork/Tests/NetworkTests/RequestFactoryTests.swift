//
//  RequestFactoryTests.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Testing
import Foundation
@testable import QRIZNetwork

@Suite("RequestFactory 테스트")
struct RequestFactoryTests {

    @Test("GET 요청 시 쿼리 파라미터 추가")
    func getRequestWithQuery() throws {
        var request = TestRequest()
        request.method = .get
        request.query = ["page": "1", "size": "10"]

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        let url = urlRequest.url!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []
        let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })

        #expect(queryDict["page"] == "1")
        #expect(queryDict["size"] == "10")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("POST 요청 시 바디 JSON 인코딩")
    func postRequestWithBody() throws {
        let request = PostTestRequest(bodyData: ["key": "value"])

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.httpBody != nil)

        let decoded = try JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: String]
        #expect(decoded["key"] == "value")
    }

    @Test("헤더 설정")
    func headersApplied() throws {
        var request = TestRequest()
        request.headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer token123"
        ]

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
    }

    @Test("DELETE 요청 시 쿼리 파라미터 추가")
    func deleteRequestWithQuery() throws {
        var request = TestRequest()
        request.method = .delete
        request.query = ["id": "42"]

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        #expect(urlRequest.httpMethod == "DELETE")
        #expect(urlRequest.url!.absoluteString.contains("id=42"))
    }

    @Test("PATCH 요청 시 바디 JSON 인코딩")
    func patchRequestWithBody() throws {
        let request = PatchTestRequest(bodyData: ["name": "updated"])

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        #expect(urlRequest.httpMethod == "PATCH")
        #expect(urlRequest.httpBody != nil)

        let decoded = try JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: String]
        #expect(decoded["name"] == "updated")
    }

    @Test("빈 쿼리 시 queryItems 미포함")
    func emptyQueryNoQueryItems() throws {
        var request = TestRequest()
        request.method = .get
        request.query = [:]

        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()

        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!
        #expect(components.queryItems == nil)
    }
}

// MARK: - 테스트용 Request

private struct PostTestRequest: Request, Sendable {
    typealias Response = TestResponse

    var baseURL: URL { URL(string: "https://test.example.com")! }
    var path: String { "/api/test" }
    var method: HTTPMethod { .post }
    var query: QueryItems { [:] }
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }

    let bodyData: [String: String]
    var body: Encodable? { bodyData }
}

private struct PatchTestRequest: Request, Sendable {
    typealias Response = TestResponse

    var baseURL: URL { URL(string: "https://test.example.com")! }
    var path: String { "/api/test" }
    var method: HTTPMethod { .patch }
    var query: QueryItems { [:] }
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }

    let bodyData: [String: String]
    var body: Encodable? { bodyData }
}
