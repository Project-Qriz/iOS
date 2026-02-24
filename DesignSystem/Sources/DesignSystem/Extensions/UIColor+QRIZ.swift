//
//  UIColor+QRIZ.swift
//  DesignSystem
//
//  Created by 김세훈 on 2/24/26.
//

import UIKit

public extension UIColor {

    // MARK: - CoolNeutral

    static let coolNeutral100 = color(named: "coolNeutral100")
    static let coolNeutral200 = color(named: "coolNeutral200")
    static let coolNeutral300 = color(named: "coolNeutral300")
    static let coolNeutral400 = color(named: "coolNeutral400")
    static let coolNeutral500 = color(named: "coolNeutral500")
    static let coolNeutral600 = color(named: "coolNeutral600")
    static let coolNeutral700 = color(named: "coolNeutral700")
    static let coolNeutral800 = color(named: "coolNeutral800")

    // MARK: - CustomBlue

    static let customBlue50 = color(named: "customBlue50")
    static let customBlue100 = color(named: "customBlue100")
    static let customBlue200 = color(named: "customBlue200")
    static let customBlue300 = color(named: "customBlue300")
    static let customBlue400 = color(named: "customBlue400")
    static let customBlue500 = color(named: "customBlue500")
    static let customBlue600 = color(named: "customBlue600")
    static let customBlue700 = color(named: "customBlue700")
    static let customBlue800 = color(named: "customBlue800")
    static let customBlue900 = color(named: "customBlue900")

    // MARK: - CustomMint

    static let customMint50 = color(named: "customMint50")
    static let customMint100 = color(named: "customMint100")
    static let customMint200 = color(named: "customMint200")
    static let customMint300 = color(named: "customMint300")
    static let customMint400 = color(named: "customMint400")
    static let customMint500 = color(named: "customMint500")
    static let customMint600 = color(named: "customMint600")
    static let customMint700 = color(named: "customMint700")
    static let customMint800 = color(named: "customMint800")

    // MARK: - CustomRed

    static let customRed500 = color(named: "customRed500")
}

private extension UIColor {
    static func color(named name: String) -> UIColor {
        UIColor(named: name, in: .module, compatibleWith: nil) ?? .systemPink
    }
}
