//
//  SignUpFlowViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 3/13/25.
//

import Foundation
import QRIZNetwork

@MainActor
final class SignUpFlowViewModel {
    
    // MARK: - Properties
    
    private let signUpService: SignUpService
    
    private var email: String = ""
    private var name: String = ""
    private var id: String = ""
    private var password: String = ""
    private var over14Confirmed: Bool = false
    private var agreedTermIds: [Int] = []
    
    // MARK: - Initialization
    
    init(signUpService: SignUpService) {
        self.signUpService = signUpService
    }
    
    // MARK: - Methods
    
    func updateEmail(_ newEmail: String) {
        self.email = newEmail
    }
    
    func updateName(_ newName: String) {
        self.name = newName
    }
    
    func updateID(_ newID: String) {
        self.id = newID
    }
    
    func updatePassword(_ newPassword: String) {
        self.password = newPassword
    }

    func updateOver14Confirmed(_ confirmed: Bool) {
        self.over14Confirmed = confirmed
    }

    func updateAgreedTermIds(_ ids: [Int]) {
        self.agreedTermIds = ids
    }

    func join() async throws -> JoinResponse {
        try await signUpService.join(
            username: id,
            password: password,
            nickname: name,
            email: email,
            over14Confirmed: over14Confirmed,
            agreedTermIds: agreedTermIds
        )
    }
}
