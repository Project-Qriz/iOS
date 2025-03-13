//
//  SignUpFlowViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 3/13/25.
//

import Foundation

final class SignUpFlowViewModel {
    
    // MARK: - Properties
    
    private var name: String = ""
    
    // MARK: - Functions
    
    func updateName(_ newName: String) {
        self.name = newName
    }
}
