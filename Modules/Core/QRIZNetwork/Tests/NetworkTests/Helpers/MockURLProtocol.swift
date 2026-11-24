//
//  MockURLProtocol.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Foundation

final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// 동시 요청 테스트에서 여러 로딩 스레드가 동시에 append하므로 락으로 보호한다.
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _capturedRequests: [URLRequest] = []

    static var capturedRequests: [URLRequest] {
        get { lock.withLock { _capturedRequests } }
        set { lock.withLock { _capturedRequests = newValue } }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.withLock { Self._capturedRequests.append(request) }

        guard let handler = Self.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }
}
