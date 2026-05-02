//
//  View+Shadow.swift
//  DesignSystem
//
//  Created by 김세훈 on 5/2/26.
//

import SwiftUI

public extension View {

    func qrizCardShadow() -> some View {
        self.shadow(
            color: Color(red: 0.094, green: 0.106, blue: 0.145).opacity(0.20),
            radius: 3,
            x: 0,
            y: 1
        )
    }
}
