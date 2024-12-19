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
    /** 클라이언트 에러*/ case clientError(code: Int, message: String)
    /** 서버 에러*/ case serverError
    /** 알 수 없는 에러*/ case unknownError
}

extension NetworkError {
    var description: String {
        switch self {
        case .invalidURL(let message): return "유효하지 않은 URL입니다. \(message)"
        case .urlEncodingError: return "URL Encoding 에러입니다."
        case .jsonDecodingError: return "JSON Decoding 에러입니다."
        case .unAuthorizedError: return "접근 권한이 없습니다."
        case .clientError(let code, let message): return "클라이언트 에러 code: \(code), message:\(message)"
        case .serverError: return "서버 에러."
        case .unknownError: return "알 수 없는 오류입니다."
        }
    }
}
