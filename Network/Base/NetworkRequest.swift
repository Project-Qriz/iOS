//
//  NetworkRequest.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation

typealias QueryItems = [String: String]
typealias HTTPHeader = [String: String]

protocol Request {
    associatedtype Response: Decodable
    
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var query: QueryItems { get }
    var headers: HTTPHeader { get }
}

extension Request {
    /// 임시 URL입니다.
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var query: QueryItems { [:] }
    var headers: HTTPHeader { [:] }
    
    var endpoint: URL {
        return baseURL.appendingPathComponent(path)
    }
}


final class RequestFactory<T: Request> {
    
    private let request: T
    private var urlComponents: URLComponents?
    
    init(request: T) {
        self.request = request
        self.urlComponents = URLComponents(url: request.endpoint, resolvingAgainstBaseURL: true)
    }
    
    func urlRequestRepresentation() throws -> URLRequest {
        switch request.method {
        case .get, .delete:
            return try makeGetRequest()
        case .post:
            return try makePostRequest()
        }
    }
    
    private func makeGetRequest() throws -> URLRequest {
        if request.query.isEmpty == false {
            urlComponents?.queryItems = request.query.map {
                URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        return try makeURLRequest()
    }
    
    private func makePostRequest() throws -> URLRequest {
        let body = try JSONSerialization.data(withJSONObject: request.query, options: [])
        return try makeURLRequest(httpBody: body)
    }
    
    private func makeURLRequest(httpBody: Data? = nil) throws -> URLRequest {
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL(message: "URL 생성에 실패했습니다. endpoint: \(request.endpoint), query: \(request.query)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        urlRequest.httpBody = httpBody
        return urlRequest
    }
}


