//
//  View+Shadow.swift
//  DesignSystem
//
//  Created by 김세훈 on 5/2/26.
//

import SwiftUI

public extension View {

    @ViewBuilder
    func qrizCardShadow(isSelected: Bool = false) -> some View {
        if isSelected {
            self.shadow(
                color: Color(red: 0.063, green: 0.110, blue: 0.239).opacity(0.32),
                radius: 5,
                x: 0,
                y: 1
            )
        } else {
            self.shadow(
                color: Color(red: 0.094, green: 0.106, blue: 0.145).opacity(0.20),
                radius: 3,
                x: 0,
                y: 1
            )
        }
    }
}
