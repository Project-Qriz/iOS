//
//  ResultDetailHostingController.swift
//  ExamKit
//

import UIKit
import SwiftUI

public final class ResultDetailHostingController: UIHostingController<ResultDetailView> {
    public override init(rootView: ResultDetailView) {
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
