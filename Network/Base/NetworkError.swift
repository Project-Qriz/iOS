//
//  NetworkError.swift
//  QRIZ
//
//  Created by KSH on 12/15/24.
//

import Foundation

enum NetworkError: Error {
    /** URL 생성 실패 */ case invalidURL(message: String)
    /** URL Encoding 에러*/ case urlEncodingError
    /** JSON Decoding 에러*/ case jsonDecodingError
    /** 토큰 만료 시 에러*/ case unAuthorizedError
    /** 클라이언트 에러*/ case clientError(httpStatus: Int, serverCode:Int?, message: String)
    /** 서버 에러*/ case serverError
    /** 알 수 없는 에러*/ case unknownError
}

extension NetworkError {
    /// 디버그용 출력 메시지입니다.
    var description: String {
        switch self {
        case .invalidURL(let message): return "유효하지 않은 URL입니다. \(message)"
        case .urlEncodingError: return "URL Encoding 에러입니다."
        case .jsonDecodingError: return "JSON Decoding 에러입니다."
        case .unAuthorizedError: return "접근 권한이 없습니다."
        case .clientError(let httpStatus, let serverCode, let message):
            return "HTTP \(httpStatus), 서버 코드: \(serverCode.map(String.init) ?? "nil"), 메시지: \(message)"
        case .serverError: return "서버 에러."
        case .unknownError: return "알 수 없는 오류입니다."
        }
    }
    
    /// 사용자 안내용 출력 메시지입니다.
    var errorMessage: String {
        switch self {
        case .clientError(_, _, let message): return message
        case .invalidURL: return "요청한 데이터에 문제가 있습니다."
        case .urlEncodingError: return "요청 처리 중 문제가 발생했습니다."
        case .jsonDecodingError: return "데이터 처리 중 문제가 발생했습니다."
        case .unAuthorizedError: return "접근 권한이 없습니다."
        case .serverError: return "서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요."
        case .unknownError: return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주세요."

        }
    }
}
