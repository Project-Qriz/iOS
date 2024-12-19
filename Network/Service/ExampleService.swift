//
//  ExampleService.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation
import Combine

protocol ExampleServiceProtocol {
    func fetchData() async throws -> ExampleResponse
}

final class ExampleService: ExampleServiceProtocol {
    
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchData() async throws -> ExampleResponse {
        let request = ExampleRequest()
        return try await network.send(request)
    }
}
