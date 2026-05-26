//
//  UIImage+QRIZ.swift
//  DesignSystem
//
//  Created by 김세훈 on 2/24/26.
//

import UIKit

public extension UIImage {

    // MARK: - Login

    static let chekmarkGreen = image(named: "chekmark_green")
    static let eyeIcon = image(named: "eye")
    static let eyeSlashIcon = image(named: "eyeSlash")
    static let homeReset = image(named: "homeReset")
    static let loginLogo = image(named: "loginLogo")

    // MARK: - SocialLogin

    static let appleLogo = image(named: "appleLogo")
    static let googleLogo = image(named: "googleLogo")
    static let kakaoLogo = image(named: "kakaoLogo")

    // MARK: - Home

    static let ellipsisIcon = image(named: "ellipsis")
    static let homeLogo = image(named: "homeLogo")
    static let lockIcon = image(named: "lock")
    static let mockExam = image(named: "MockExam")
    static let pencilIcon = image(named: "pencil")

    // MARK: - Exam

    static let examSummary = image(named: "examSummary")

    // MARK: - MyPage

    static let examRegister = image(named: "examRegister")
    static let resetIcon = image(named: "reset")

    // MARK: - Onboarding

    static let planIcon7Day = image(named: "planIcon7Day")
    static let planIcon14Day = image(named: "planIcon14Day")
    static let planIcon30Day = image(named: "planIcon30Day")
    static let planIcon7DayDisabled = image(named: "planIcon7DayDisabled")
    static let planIcon14DayDisabled = image(named: "planIcon14DayDisabled")
    static let planIcon30DayDisabled = image(named: "planIcon30DayDisabled")
    static let checkboxOffIcon = image(named: "checkboxOffIcon")
    static let checkboxOnIcon = image(named: "checkboxOnIcon")
    static let checkboxSomeIcon = image(named: "checkboxSomeIcon")
    static let onboarding1 = image(named: "onboarding1")
    static let onboarding2 = image(named: "onboarding2")
    static let onboarding3 = image(named: "onboarding3")

    // MARK: - Splash

    static let splashBottom = image(named: "splashBottom")
    static let splashLogo = image(named: "splashLogo")

    // MARK: - TabBar

    static let conceptBookTab = image(named: "conceptBook")
    static let homeTab = image(named: "home")
    static let mistakeNoteTab = image(named: "mistakeNote")
    static let myPageTab = image(named: "myPage")
    static let selectedConceptBook = image(named: "selectedConceptBook")
    static let selectedMistakeNote = image(named: "selectedMistakeNote")

    // MARK: - Textbook

    static let dataModelAndSQL = image(named: "dataModelAndSQL")
    static let managementStatements = image(named: "managementStatements")
    static let sqlAdvanced = image(named: "sqlAdvanced")
    static let sqlBasics = image(named: "sqlBasics")
    static let understandingDataModeling = image(named: "understandingDataModeling")
}

public extension UIImage {
    static func designSystemImage(named name: String) -> UIImage? {
        UIImage(named: name, in: .module, compatibleWith: nil)
    }
}

private extension UIImage {
    static func image(named name: String) -> UIImage {
        UIImage(named: name, in: .module, compatibleWith: nil) ?? UIImage()
    }
}
