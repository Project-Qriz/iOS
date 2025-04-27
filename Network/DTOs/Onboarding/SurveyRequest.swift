//
//  SurveyRequest.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

struct SurveyRequest: Request {
    
    // MARK: - Properties
    typealias Response = SurveyResponse
    private let accessToken: String
    
    var path = "/api/v1/survey"
    var method: HTTPMethod = .post
    var keyConcepts: [String]
    var body: Encodable? {
        [
            "keyConcepts": keyConcepts
        ]
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, keyConcepts: [String]) {
        self.accessToken = accessToken
        self.keyConcepts = keyConcepts
    }
}

struct SurveyResponse: Decodable {
    let code: Int
    let msg: String
    let data: [SurveyResponseData]
    
    struct SurveyResponseData: Decodable {
        let userId: Int
        let skillId: Int
        let checked: Bool
        let knowsNothing: Bool
    }
}
