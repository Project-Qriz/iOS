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
        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
        let needsRetry = urlRequest.value(forHTTPHeaderField: authKey) != nil
        
        let (data, response) = try await session.data(for: urlRequest)
        saveAccessTokenIfPresent(in: response)
        
        do {
            try validate(response, data)
            return try decode(T.Response.self, from: data)
        } catch let NetworkError.unAuthorizedError(detailCode: detail) where needsRetry {
            if detail == 3 {
                try await refreshAccessToken()
            }
            return try await retry(urlRequest, responseType: T.Response.self)
        } catch {
            throw mapToNetworkError(error)
        }
    }
}

private extension NetworkImpl {
    /// 401 응답 시 재요청 메서드
    private func retry<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        guard let token = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) else {
            notifier.notify(.expired)
            throw NetworkError.unAuthorizedError(detailCode: 5)
        }
        
        var retried = request
        retried.setValue(token, forHTTPHeaderField: authKey)
        
        let (data, response) = try await session.data(for: retried)
        saveAccessTokenIfPresent(in: response)

        do {
            try validate(response, data)
            return try decode(responseType, from: data)
        } catch NetworkError.unAuthorizedError(let detail) {
            keychain.deleteToken(forKey: HTTPHeaderField.accessToken.rawValue)
            notifier.notify(.expired)
            throw NetworkError.unAuthorizedError(detailCode: detail)
        }
    }
    
    private func refreshAccessToken() async throws {
        guard let refresh = keychain.retrieveToken(forKey: HTTPHeaderField.refreshToken.rawValue) else {
            notifier.notify(.expired)
            throw NetworkError.unAuthorizedError(detailCode: 5)
        }

        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = RefreshTokenRequest(accessToken: access, refreshToken: refresh)
        let response: RefreshTokenResponse = try await self.send(request)
        
        if let newRefresh = response.data?.refreshToken {
            _ = keychain.save(token: newRefresh, forKey: HTTPHeaderField.refreshToken.rawValue)
        }
    }
    
    /// 서버에서  AccessToken과 RefreshToken을 추출하여 Keychain에 저장하는 메서드
    private func saveTokensIfPresent(data: Data, response: URLResponse) {
        saveAccessTokenIfPresent(in: response)
        saveRefreshTokenIfPresent(from: data)
    }
    
    /// 응답 헤더에 AccessToken이 포함되어 있다면 Keychain에 저장
    private func saveAccessTokenIfPresent(in response: URLResponse) {
        guard
            let http = response as? HTTPURLResponse,
            let bearer = http.value(forHTTPHeaderField: authKey),
            bearer.isEmpty == false
        else { return }
        _ = keychain.save(token: bearer, forKey: HTTPHeaderField.accessToken.rawValue)
    }
    
    /// 응답 body에서 RefreshToken을 추출하여 Keychain에 저장
    private func saveRefreshTokenIfPresent(from data: Data) {
        guard
            let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let dataField = body["data"] as? [String: Any],
            let refreshToken = dataField[HTTPHeaderField.refreshToken.rawValue] as? String
        else { return }
        
        _ = keychain.save(token: refreshToken, forKey: HTTPHeaderField.refreshToken.rawValue)
    }
    
    /// HTTP 상태코드 검증 메서드
    private func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        switch http.statusCode {
        case 200..<300: return
        case 401:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            let detail = errorResponse?.code
            throw NetworkError.unAuthorizedError(detailCode: detail)
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
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw NetworkError.jsonDecodingError }
    }
    
    /// Error 매핑
    private func mapToNetworkError(_ error: Error) -> NetworkError {
        switch error {
        case let networkError as NetworkError: return networkError
        case let urlError as URLError: return .invalidURL(message: urlError.localizedDescription)
        case is DecodingError: return .jsonDecodingError
        default: return .unknownError
        }
    }
    
    /// detailCode 추출
    private func extractDetailCode(from data: Data) -> Int? {
        let errorBody = try? decoder.decode(ErrorResponse.self, from: data)
        return errorBody?.code
    }
}
