//
//  Network.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation
import Combine

protocol Network {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

final class NetworkImpl: Network {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let keychain: KeychainManager
    private let decoder = JSONDecoder()
    private let notifier: SessionEventNotifier
    private let authKey = HTTPHeaderField.authorization.rawValue
    
    // MARK: - Initialize
    
    init(
        session: URLSession = .shared,
        notifier: SessionEventNotifier = SessionEventNotifierImpl(),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.session = session
        self.keychain = keychain
        self.notifier = notifier
    }
    
    // MARK: - Functions
    
    func send<T: Request>(_ request: T) async throws -> T.Response {
        try await send(request, shouldRetry: true)
    }
}

private extension NetworkImpl {
    func send<T: Request>(_ request: T, shouldRetry: Bool) async throws -> T.Response {
        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
        let needsRetry = urlRequest.value(forHTTPHeaderField: authKey) != nil
        
        let (data, response) = try await session.data(for: urlRequest)
        saveAccessTokenIfPresent(in: response)
        
        do {
            try validate(response, data)
            return try decode(T.Response.self, from: data)
        } catch NetworkError.unAuthorizedError where shouldRetry && needsRetry {
            return try await retry(urlRequest, responseType: T.Response.self)
        } catch {
            throw mapToNetworkError(error)
        }
    }
    
    /// 401 응답 시 재요청 메서드
    func retry<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        guard let token = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) else {
            keychain.deleteToken(forKey: HTTPHeaderField.accessToken.rawValue)
            notifier.notify(.expired)
            throw NetworkError.unAuthorizedError
        }
        
        var retried = request
        retried.setValue(token, forHTTPHeaderField: authKey)
        
        let (data, response) = try await session.data(for: retried)
        saveAccessTokenIfPresent(in: response)

        do {
            try validate(response, data)
            return try decode(responseType, from: data)
        } catch NetworkError.unAuthorizedError {
            keychain.deleteToken(forKey: HTTPHeaderField.accessToken.rawValue)
            notifier.notify(.expired)
            throw NetworkError.unAuthorizedError
        }
    }
    
    /// 응답 헤더에 토큰 존재 시 저장 메서드
    func saveAccessTokenIfPresent(in response: URLResponse) {
        guard
            let http = response as? HTTPURLResponse,
            let bearer = http.value(forHTTPHeaderField: authKey),
            bearer.isEmpty == false
        else { return }
        _ = keychain.save(token: bearer, forKey: HTTPHeaderField.accessToken.rawValue)
    }
    
    /// HTTP 상태코드 검증 메서드
    func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        switch http.statusCode {
        case 200..<300: return
        case 401:
            throw NetworkError.unAuthorizedError
        case 400..<500:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            
            throw NetworkError.clientError(
                httpStatus: http.statusCode,
                serverCode: errorResponse?.code,
                message: errorResponse?.msg ?? "클라이언트 에러입니다."
            )
        case 500..<600:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknownError
        }
    }
    
    /// JSON → Response 디코딩 메서드
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw NetworkError.jsonDecodingError }
    }
    
    /// Error 매핑
    func mapToNetworkError(_ error: Error) -> NetworkError {
        switch error {
        case let networkError as NetworkError: return networkError
        case let urlError as URLError: return .invalidURL(message: urlError.localizedDescription)
        case is DecodingError: return .jsonDecodingError
        default: return .unknownError
        }
    }
}
