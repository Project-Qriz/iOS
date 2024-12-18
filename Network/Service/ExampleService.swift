//
//  ExampleService.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation
import Combine

protocol ExampleServiceProtocol {
    func fetchData() -> AnyPublisher<ExampleResponse, NetworkError>
    func fetchDataAsync() async -> Result<ExampleResponse, NetworkError>
}

final class ExampleService: ExampleServiceProtocol {
    
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchData() -> AnyPublisher<ExampleResponse, NetworkError> {
        let request = ExampleRequest()
        return network.send(request)
    }
    
    func fetchDataAsync() async -> Result<ExampleResponse, NetworkError> {
        do {
            let request = ExampleRequest()
            let response = try await network.sendAsync(request)
            return .success(response)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    func fetchDataAsync() async throws -> ExampleResponse {
        let request = ExampleRequest()
        return try await network.sendAsync(request)
    }
}
