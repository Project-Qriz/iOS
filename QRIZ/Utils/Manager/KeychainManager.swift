//
//  KeychainManager.swift
//  QRIZ
//
//  Created by 김세훈 on 3/31/25.
//

import Foundation

protocol KeychainManager {
    func save(token: String, forKey key: String) -> Bool
    func retrieveToken(forKey key: String) -> String?
    func deleteToken(forKey key: String)
}

final class KeychainManagerImpl: KeychainManager {
    
    func save(token: String, forKey key: String) -> Bool {
        guard let data = token.data(using: .utf8) else {
            return false
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, // 키체인 GenericPassword 형식으로 저장
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary) // 중복 방지
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieveToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any, // 반환값으로 저장된 데이터를 포함시키는 요청
            kSecMatchLimit as String: kSecMatchLimitOne // 하나만 가져오도록 요청
        ]
        var item: CFTypeRef? // CFTypeRef - 객체의 모든 타입을 포괄할 수 있는 포인터 타입
        let status = SecItemCopyMatching(query as CFDictionary, &item) // 해당 키체인 조회
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }
    
    func deleteToken(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
