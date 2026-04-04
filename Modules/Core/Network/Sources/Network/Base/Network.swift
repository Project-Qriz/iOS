//
//  Network.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation
import QRIZUtils

public protocol Network: Sendable {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

public actor NetworkImpl: Network {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let keychain: KeychainManager
    private let decoder = JSONDecoder()
    private let notifier: SessionEventNotifier
    private let authKey = HTTPHeaderField.authorization.rawValue
    private var isRefreshing = false
    
    // MARK: - Initialization

    public init(
        session: URLSession = .shared,
        notifier: SessionEventNotifier = SessionEventNotifierImpl(),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.session = session
        self.keychain = keychain
        self.notifier = notifier
    }
    
    // MARK: - Methods

    public func send<T: Request>(_ request: T) async throws -> T.Response {
        let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
        let needsAuth = urlRequest.value(forHTTPHeaderField: authKey) != nil
        let (data, response) = try await session.data(for: urlRequest)
        
        do {
            try validate(response: response, data: data)
            saveTokens(from: data, response: response)
            return try decode(T.Response.self, from: data)
        } catch let NetworkError.unAuthorizedError(detailCode: code)
                    where needsAuth && !isRefreshing && code == 3 {
            return try await refreshAndRetry(urlRequest, responseType: T.Response.self)
        } catch {
            let networkError = mapToNetworkError(error)
            logAPIError(networkError, request: urlRequest)
            throw networkError
        }
    }
}

private extension NetworkImpl {
    
    /// Access Token 갱신 후 재요청
    func refreshAndRetry<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        do {
            try await refreshAccessToken()
            return try await retryRequest(request, responseType: responseType)
        } catch {
            handleRefreshFailure()
            throw error
        }
    }
    
    /// Access Token 갱신
    func refreshAccessToken() async throws {
        let accessToken = keychain.retrieveToken(forKey: TokenKey.accessToken.rawValue)
        let refreshToken = keychain.retrieveToken(forKey: TokenKey.refreshToken.rawValue)
        
        guard let unwrappedRefreshToken = refreshToken else {
            throw NetworkError.unAuthorizedError(detailCode: nil)
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        let request = RefreshTokenRequest(accessToken: accessToken ?? "", refreshToken: unwrappedRefreshToken)
        let response: RefreshTokenResponse = try await self.send(request)
        
        // 새로운 Refresh Token이 있으면 저장
        if let newRefreshToken = response.data?.refreshToken {
            _ = keychain.save(token: newRefreshToken, forKey: TokenKey.refreshToken.rawValue)
        }
    }
    
    /// 갱신된 Access Token으로 재요청
    func retryRequest<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        guard let accessToken = keychain.retrieveToken(forKey: TokenKey.accessToken.rawValue) else {
            throw NetworkError.unAuthorizedError(detailCode: nil)
        }
        
        var retryRequest = request
        retryRequest.setValue(accessToken, forHTTPHeaderField: authKey)
        
        let (data, response) = try await session.data(for: retryRequest)
        
        try validate(response: response, data: data)
        saveTokens(from: data, response: response)
        return try decode(responseType, from: data)
    }
    
    /// Refresh 실패 시 토큰 삭제 및 세션 만료 알림
    func handleRefreshFailure() {
        keychain.deleteToken(forKey: TokenKey.accessToken.rawValue)
        keychain.deleteToken(forKey: TokenKey.refreshToken.rawValue)
        notifier.notify(.expired)
    }
    
    /// 응답에서 토큰 추출 및 저장
    func saveTokens(from data: Data, response: URLResponse) {
        saveAccessTokenIfPresent(in: response)
        saveRefreshTokenIfPresent(from: data)
    }
    
    /// Access Token 저장 (응답 헤더)
    func saveAccessTokenIfPresent(in response: URLResponse) {
        guard
            let httpResponse = response as? HTTPURLResponse,
            let token = httpResponse.value(forHTTPHeaderField: authKey),
            !token.isEmpty
        else { return }
        
        _ = keychain.save(token: token, forKey: TokenKey.accessToken.rawValue)
    }
    
    /// Refresh Token 저장 (응답 Body)
    func saveRefreshTokenIfPresent(from data: Data) {
        guard let body = try? decoder.decode(RefreshTokenBody.self, from: data),
              let refreshToken = body.data?.refreshToken else { return }
        _ = keychain.save(token: refreshToken, forKey: TokenKey.refreshToken.rawValue)
    }
    
    /// HTTP 상태 코드 검증
    func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        switch httpResponse.statusCode {
        case 200..<300: return
        case 401:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.unAuthorizedError(detailCode: errorResponse?.detailCode)
        case 400..<500:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            throw NetworkError.clientError(
                httpStatus: httpResponse.statusCode,
                serverCode: errorResponse?.code,
                message: errorResponse?.msg ?? "클라이언트 에러입니다."
            )
        case 500..<600:
            throw NetworkError.serverError(httpStatus: httpResponse.statusCode)
        default:
            throw NetworkError.unknownError
        }
    }
    
    /// JSON → Response 디코딩 메서드
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw NetworkError.jsonDecodingError }
    }
    
    /// API 에러 Analytics 로깅
    private func logAPIError(_ error: NetworkError, request: URLRequest) {
        let endpoint = request.url?.path ?? "unknown"
        let event: AnalyticsEvent?
        switch error {
        case .clientError(let status, _, let message):
            event = .apiError(endpoint: endpoint, statusCode: status, message: message)
        case .serverError(let status):
            event = .apiError(endpoint: endpoint, statusCode: status, message: "서버 에러")
        default:
            event = nil
        }
        guard let event else { return }
        Task { @MainActor in AnalyticsManager.shared.log(event) }
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
}

/// Refresh Token을 추출용 디코딩 모델입니다.
private struct RefreshTokenBody: Decodable {
    let data: DataField?
    
    struct DataField: Decodable {
        let refreshToken: String?
    }
}
