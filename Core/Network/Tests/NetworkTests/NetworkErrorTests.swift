//
//  NetworkErrorTests.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Testing
@testable import Network

@Suite("NetworkError 테스트")
struct NetworkErrorTests {

    @Test("debugDescription 각 케이스 출력 확인")
    func debugDescriptions() {
        #expect(NetworkError.invalidURL(message: "test").debugDescription.contains("유효하지 않은 URL"))
        #expect(NetworkError.urlEncodingError.debugDescription.contains("URL Encoding"))
        #expect(NetworkError.jsonDecodingError.debugDescription.contains("JSON Decoding"))
        #expect(NetworkError.unAuthorizedError(detailCode: 3).debugDescription.contains("접근 권한"))
        #expect(NetworkError.clientError(httpStatus: 400, serverCode: 100, message: "에러").debugDescription.contains("HTTP 400"))
        #expect(NetworkError.serverError.debugDescription.contains("서버 에러"))
        #expect(NetworkError.unknownError.debugDescription.contains("알 수 없는"))
    }

    @Test("errorMessage 사용자 안내 메시지 확인")
    func errorMessages() {
        #expect(NetworkError.invalidURL(message: "test").errorMessage == "네트워크 연결을 확인해 주세요.")
        #expect(NetworkError.urlEncodingError.errorMessage == "요청 처리 중 문제가 발생했습니다.")
        #expect(NetworkError.jsonDecodingError.errorMessage == "데이터 처리 중 문제가 발생했습니다.")
        #expect(NetworkError.unAuthorizedError(detailCode: 3).errorMessage == "세션이 만료되어 다시 시도합니다.")
        #expect(NetworkError.unAuthorizedError(detailCode: nil).errorMessage == "접근 권한이 없습니다.")
        #expect(NetworkError.clientError(httpStatus: 400, serverCode: nil, message: "테스트 에러").errorMessage == "테스트 에러")
        #expect(NetworkError.serverError.errorMessage == "서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요.")
        #expect(NetworkError.unknownError.errorMessage == "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.")
    }
}
