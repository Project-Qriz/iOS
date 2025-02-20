//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    func start() -> UIViewController
}
