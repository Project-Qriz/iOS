//
//  EmailSendService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/4/25.
//

import Foundation

protocol EmailSendService {
    func sendEmail(_ email: String) async throws -> EmailSendResponse
}

final class EmailSendServiceImpl: EmailSendService {
    private let network: Network
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    func sendEmail(_ email: String) async throws -> EmailSendResponse {
        let request = EmailSendRequest(email: email)
        return try await network.send(request)
    }
}
