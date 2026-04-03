//
//  NetworkRequest.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation

public typealias QueryItems = [String: String]
public typealias HTTPHeader = [String: String]

public protocol Request: Sendable {
    associatedtype Response: Decodable & Sendable
    
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var query: QueryItems { get }
    var headers: HTTPHeader { get }
    var body: Encodable? { get }
}

extension Request {
    public var baseURL: URL {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
              let baseURL = URL(string: baseURLString)
        else {
            #if DEBUG
            return URL(string: "https://test.example.com")!
            #else
            fatalError("Info.plist에 유효한 BaseURL이 설정되어 있지 않습니다.")
            #endif
        }
        return baseURL
    }
    public var query: QueryItems { [:] }
    public var headers: HTTPHeader { [:] }
    public var body: Encodable? { nil }

    public var endpoint: URL {
        return baseURL.appendingPathComponent(path)
    }
}


public struct RequestFactory<T: Request> {

    private let request: T
    private let encoder = JSONEncoder()

    public init(request: T) {
        self.request = request
    }

    public func urlRequestRepresentation() throws -> URLRequest {
        var urlComponents = URLComponents(url: request.endpoint, resolvingAgainstBaseURL: true)

        switch request.method {
        case .get, .delete:
            if !request.query.isEmpty {
                urlComponents?.queryItems = request.query.map {
                    URLQueryItem(name: $0.key, value: $0.value)
                }
            }
            return try makeURLRequest(from: urlComponents)
        case .post, .patch:
            let bodyData = try request.body.map { try encoder.encode($0) }
            return try makeURLRequest(from: urlComponents, httpBody: bodyData)
        }
    }

    private func makeURLRequest(from urlComponents: URLComponents?, httpBody: Data? = nil) throws -> URLRequest {
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL(message: "URL 생성에 실패했습니다. endpoint: \(request.endpoint)")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        urlRequest.httpBody = httpBody
        return urlRequest
    }
}
