//
//  MockAccountRecoveryService.swift
//  QRIZTests
//
//  Created by 김세훈 on 4/6/25.
//

import Foundation
@testable import QRIZ

// Dummy: 동작하지 않는 객체, 단순 전달용
// Stub: 최소 기능만 구현된 대체 객체
// Fake: 실제 로직과 유사하나 단순화된 객체
// Spy: 호출 기록까지 가능한 Stub
// Mock: 행위 기반 테스트용 객체, 시나리오 검증

final class MockAccountRecoveryService: AccountRecoveryService {
    
    var shouldThrowError: Bool = false // findID 호출 시 에러를 여부를 결정하는 프로퍼티
    var findIDCallCount: Int = 0 // findID 메서드가 몇 번 호출되었는지 기록하는 프로퍼티
    
    // findID 성공 시 반환할 기본 데이터
    var findIDSuccessResponse: FindIDResponse = FindIDResponse(code: 200, msg: "이메일 발송 성공")
    
    func findID(email: String) async throws -> FindIDResponse {
        findIDCallCount += 1
        
        if shouldThrowError {
            throw NetworkError.clientError(code: 400, message: "테스트 클라이언트 에러")
        } else {
            return findIDSuccessResponse
        }
    }
    
    func findPassword(email: String) async throws -> FindPasswordResponse {
        return FindPasswordResponse(code: 200, msg: "비밀번호 찾기 성공")
    }
    
    func verifyPasswordReset(authNumber: String) async throws -> VerifyPasswordResetResponse {
        return VerifyPasswordResetResponse(code: 200, msg: "인증번호 검증 성공")
    }
    
    func resetPassword(password: String) async throws -> PasswordResetResponse {
        return PasswordResetResponse(code: 200, msg: "비밀번호 재설정 성공", data: nil)
    }
}
