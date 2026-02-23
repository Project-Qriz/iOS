//
//  NetworkImplTests.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Testing
import Foundation
@testable import Network

@Suite("NetworkImpl 테스트", .serialized)
struct NetworkImplTests {

    private let mockKeychain = MockKeychainManager()
    private let mockNotifier = MockSessionEventNotifier()

    init() {
        MockURLProtocol.reset()
        mockKeychain.reset()
        mockNotifier.reset()
    }

    private func makeSUT() -> NetworkImpl {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        return NetworkImpl(
            session: session,
            notifier: mockNotifier,
            keychain: mockKeychain
        )
    }

    private func makeResponse(
        url: URL = URL(string: "https://test.example.com/api/test")!,
        statusCode: Int,
        headers: [String: String]? = nil,
        body: Data = Data()
    ) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )!
        return (response, body)
    }

    // MARK: - 성공 케이스

    @Test("200 응답 시 정상 디코딩")
    func successResponse() async throws {
        let sut = makeSUT()
        let json = #"{"message": "success"}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 200, body: json)
        }

        let response = try await sut.send(TestRequest())
        #expect(response.message == "success")
    }

    @Test("200 응답 시 Authorization 헤더의 Access Token 저장")
    func saveAccessTokenFromHeader() async throws {
        let sut = makeSUT()
        let json = #"{"message": "ok"}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(
                statusCode: 200,
                headers: ["Authorization": "new-access-token"],
                body: json
            )
        }

        _ = try await sut.send(TestRequest())

        #expect(mockKeychain.storage["accessToken"] == "new-access-token")
        #expect(mockKeychain.saveCallCount == 1)
    }

    @Test("200 응답 시 빈 Authorization 헤더는 저장하지 않음")
    func emptyAuthorizationHeaderNotSaved() async throws {
        let sut = makeSUT()
        let json = #"{"message": "ok"}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(
                statusCode: 200,
                headers: ["Authorization": ""],
                body: json
            )
        }

        _ = try await sut.send(TestRequest())

        #expect(mockKeychain.storage["accessToken"] == nil)
    }

    @Test("200 응답 시 Body의 Refresh Token 저장")
    func saveRefreshTokenFromBody() async throws {
        let sut = makeSUT()
        let json = #"{"message": "ok", "data": {"refreshToken": "new-refresh-token"}}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 200, body: json)
        }

        _ = try await sut.send(TestRequest())

        #expect(mockKeychain.storage["refreshToken"] == "new-refresh-token")
    }

    // MARK: - 에러 케이스

    @Test("400 응답 시 clientError 발생 및 서버 메시지 포함")
    func clientError() async throws {
        let sut = makeSUT()
        let errorJson = #"{"code": 400, "msg": "잘못된 요청", "reason": null, "detailCode": null}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 400, body: errorJson)
        }

        await #expect {
            _ = try await sut.send(TestRequest())
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .clientError(let status, _, let message) = networkError
            else { return false }
            return status == 400 && message == "잘못된 요청"
        }
    }

    @Test("401 응답 시 detailCode가 3이 아니면 바로 unAuthorizedError")
    func unauthorizedWithoutDetailCode3() async throws {
        let sut = makeSUT()
        let errorJson = #"{"code": 401, "msg": "인증 실패", "reason": null, "detailCode": 1}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 401, body: errorJson)
        }

        await #expect {
            _ = try await sut.send(TestRequest())
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .unAuthorizedError(let detailCode) = networkError
            else { return false }
            return detailCode == 1
        }
    }

    @Test("500 응답 시 serverError 발생")
    func serverError() async throws {
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 500)
        }

        await #expect {
            _ = try await sut.send(TestRequest())
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .serverError = networkError
            else { return false }
            return true
        }
    }

    @Test("디코딩 실패 시 jsonDecodingError 발생")
    func decodingError() async throws {
        let sut = makeSUT()
        let invalidJson = #"not json"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 200, body: invalidJson)
        }

        await #expect {
            _ = try await sut.send(TestRequest())
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .jsonDecodingError = networkError
            else { return false }
            return true
        }
    }

    @Test("네트워크 연결 실패 시 URLError 전파")
    func networkConnectionFailure() async throws {
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        await #expect {
            _ = try await sut.send(TestRequest())
        } throws: { error in
            guard let urlError = error as? URLError else { return false }
            return urlError.code == .notConnectedToInternet
        }
    }

    // MARK: - 토큰 갱신

    @Test("인증 없는 요청에 401이 와도 토큰 갱신 시도하지 않음")
    func noRefreshForUnauthenticatedRequest() async throws {
        let sut = makeSUT()
        let errorJson = #"{"code": 401, "msg": "만료", "reason": null, "detailCode": 3}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 401, body: errorJson)
        }

        // TestRequest는 Authorization 헤더가 없음 → needsAuth = false → 갱신 안 함
        await #expect(throws: NetworkError.self) {
            _ = try await sut.send(TestRequest())
        }

        // 요청이 1번만 발생 (갱신 시도 없음)
        #expect(MockURLProtocol.capturedRequests.count == 1)
    }

    @Test("401 detailCode=3 시 토큰 갱신 후 재시도")
    func refreshAndRetry() async throws {
        let sut = makeSUT()
        mockKeychain.storage["accessToken"] = "old-token"
        mockKeychain.storage["refreshToken"] = "valid-refresh"

        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1

            if requestCount == 1 {
                let errorJson = #"{"code": 401, "msg": "만료", "reason": null, "detailCode": 3}"#.data(using: .utf8)!
                return self.makeResponse(statusCode: 401, body: errorJson)
            }

            if requestCount == 2 {
                let refreshJson = #"{"code": 200, "msg": "ok", "reason": null, "detailCode": null, "data": {"rotated": false, "refreshExpiry": null, "refreshToken": null}}"#.data(using: .utf8)!
                return self.makeResponse(
                    url: request.url!,
                    statusCode: 200,
                    headers: ["Authorization": "refreshed-token"],
                    body: refreshJson
                )
            }

            let json = #"{"message": "retried"}"#.data(using: .utf8)!
            return self.makeResponse(statusCode: 200, body: json)
        }

        let response = try await sut.send(AuthenticatedTestRequest())
        #expect(response.message == "retried")
        #expect(requestCount == 3)

        // 2번째 요청이 refresh 엔드포인트인지 확인
        let refreshRequest = MockURLProtocol.capturedRequests[1]
        #expect(refreshRequest.url?.path.contains("token/refresh") == true)

        // 3번째 요청에 갱신된 토큰이 있는지 확인
        let retryRequest = MockURLProtocol.capturedRequests[2]
        #expect(retryRequest.value(forHTTPHeaderField: "Authorization") == "refreshed-token")
    }

    @Test("401 토큰 갱신 실패 시 토큰 삭제 및 세션 만료 알림")
    func refreshFailureNotifiesExpired() async throws {
        let sut = makeSUT()
        mockKeychain.storage["accessToken"] = "old-token"
        mockKeychain.storage["refreshToken"] = "invalid-refresh"

        var requestCount = 0
        MockURLProtocol.requestHandler = { _ in
            requestCount += 1

            if requestCount == 1 {
                let errorJson = #"{"code": 401, "msg": "만료", "reason": null, "detailCode": 3}"#.data(using: .utf8)!
                return self.makeResponse(statusCode: 401, body: errorJson)
            }

            let errorJson = #"{"code": 401, "msg": "refresh 실패", "reason": null, "detailCode": null}"#.data(using: .utf8)!
            return self.makeResponse(statusCode: 401, body: errorJson)
        }

        await #expect(throws: NetworkError.self) {
            _ = try await sut.send(AuthenticatedTestRequest())
        }

        #expect(mockKeychain.storage["accessToken"] == nil)
        #expect(mockKeychain.storage["refreshToken"] == nil)
        #expect(mockKeychain.deleteCallCount == 2)
        #expect(mockNotifier.notifiedEvents == [.expired])
    }

    @Test("refreshToken이 없으면 갱신 시도 시 바로 에러")
    func noRefreshTokenAvailable() async throws {
        let sut = makeSUT()
        mockKeychain.storage["accessToken"] = "old-token"
        // refreshToken 없음

        let errorJson = #"{"code": 401, "msg": "만료", "reason": null, "detailCode": 3}"#.data(using: .utf8)!
        MockURLProtocol.requestHandler = { _ in
            self.makeResponse(statusCode: 401, body: errorJson)
        }

        await #expect {
            _ = try await sut.send(AuthenticatedTestRequest())
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .unAuthorizedError = networkError
            else { return false }
            return true
        }

        // 토큰 삭제 및 세션 만료 확인
        #expect(mockNotifier.notifiedEvents == [.expired])
    }
}
