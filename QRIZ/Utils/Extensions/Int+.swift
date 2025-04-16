//
//  Int+.swift
//  QRIZ
//
//  Created by ch on 4/16/25.
//

import Foundation

extension Int {
    // 테스트 화면에서 타이머에 시간을 제공하기 위한 extension 입니다.
    var formattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
