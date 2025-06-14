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
    var body: Encodable? { get }
}

extension Request {
    var baseURL: URL {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
              let baseURL = URL(string: baseURLString)
        else {
            print("BaseURL is not valid")
            return URL(string: "")!
        }
        return baseURL
    }
    var query: QueryItems { [:] }
    var headers: HTTPHeader { [:] }
    var body: Encodable? { nil }
    
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
        case .post, .patch:
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
        let bodyData: Data? = {
            guard let encodableBody = request.body else { return nil }
            return try? JSONEncoder().encode(encodableBody)
        }()
        return try makeURLRequest(httpBody: bodyData)
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


