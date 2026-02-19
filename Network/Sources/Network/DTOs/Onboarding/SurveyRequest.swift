//
//  SurveyRequest.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

public struct SurveyRequest: Request , Sendable {
    
    // MARK: - Properties
    public typealias Response = SurveyResponse

    public let path = "/api/v1/survey"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let keyConcepts: [String]

    public var body: Encodable? {
        [
            "keyConcepts": keyConcepts
        ]
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    public init(accessToken: String, keyConcepts: [String]) {
        self.accessToken = accessToken
        self.keyConcepts = keyConcepts
    }
}

public struct SurveyResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: [SurveyResponseData]
    
    public struct SurveyResponseData: Decodable , Sendable {
        public let userId: Int
        public let skillId: Int?
        public let checked: Bool
        public let knowsNothing: Bool
    }
}
