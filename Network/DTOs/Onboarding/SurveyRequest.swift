//
//  SurveyRequest.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

struct SurveyRequest: Request {
    typealias Response = SurveyResponse
    private let keyChainManager: KeychainManagerImpl = .init()
    
    var path = "/api/v1/survey"
    var method: HTTPMethod = .post
    var keyConcepts: [String]
    var query: QueryItems {
        [
            "keyConcepts": keyConcepts
        ]
    }
    
    var headers: HTTPHeader {
        let accessToken = keyChainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("SurveyRequest received empty accessToken")}
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct SurveyResponse: Decodable {
    let code: Int
    let msg: String
    let data: [SurveyResponseData]
    
    struct SurveyResponseData: Decodable {
        let user_id: Int
        let skill_id: Int
        let checked: Bool
        let knowsNothing: Bool
    }
}
