//
//  OnboardingImageView.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingImageView: UIImageView {

    init(_ imageName: String) {
        super.init(frame: .zero)
        self.image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingImageView")
    }
}
