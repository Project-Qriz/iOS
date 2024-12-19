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

final class NetworkImp: Network {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func send<T>(_ request: T) async throws -> T.Response where T: Request {
        do {
            let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
            let (data, response) = try await session.data(for: urlRequest)
            
            try validate(response)
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch let error {
            throw mapToNetworkError(error)
        }
    }
}

extension NetworkImp {
    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        switch httpResponse.statusCode {
        case 200..<300: return
        case 400..<500: throw NetworkError.clientError(
            code: httpResponse.statusCode,
            message: "클라이언트 에러입니다."
        )
        case 500..<600: throw NetworkError.serverError
        default: throw NetworkError.unknownError
        }
    }
    
    private func mapToNetworkError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        if let urlError = error as? URLError {
            return .invalidURL(message: urlError.localizedDescription)
        }
        
        if error is DecodingError {
            return .jsonDecodingError
        }
        
        return .unknownError
    }
}


// MARK: - Combine

//func send<T>(_ request: T) -> AnyPublisher<T.Response, NetworkError> where T: Request {
//    guard let urlRequest = try? RequestFactory(request: request).urlRequestRepresentation() else {
//        return Fail(error: NetworkError.invalidURL(message: "URL 생성에 실패했습니다."))
//            .eraseToAnyPublisher()
//    }
//    
//    return session.dataTaskPublisher(for: urlRequest)
//        .tryMap { data, response in
//            try self.validate(response)
//            return data
//        }
//        .decode(type: T.Response.self, decoder: JSONDecoder())
//        .mapError { self.mapToNetworkError($0) }
//        .eraseToAnyPublisher()
//}

