//
//  SocialWithdrawRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 9/2/25.
//

import Foundation
import QRIZUtils

public struct SocialWithdrawRequest: Request , Sendable {
    public typealias Response = SocialWithdrawResponse
    
    private let socialLoginType: SocialLogin
    private let accessToken: String
    public var path: String { "/api/auth/social/\(socialLoginType.rawValue)/withdraw" }
    public let method: HTTPMethod = .delete
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(socialLoginType: SocialLogin, accessToken: String) {
        self.socialLoginType = socialLoginType
        self.accessToken = accessToken
    }
}

public struct SocialWithdrawResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
}
