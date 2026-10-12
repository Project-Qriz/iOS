//
//  UserInfoManager+UserInfo.swift
//  QRIZ
//

import QRIZUtils

public extension UserInfoManager {
    /// 서버 응답의 사용자 정보로 로컬 사용자 정보를 갱신한다.
    func update(from user: UserInfo) {
        update(
            name: user.name,
            userId: user.userId,
            email: user.email,
            previewTestStatus: user.previewTestStatus,
            provider: user.provider
        )
    }
}
