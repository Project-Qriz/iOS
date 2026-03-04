//
//  Coordinator.swift
//  QRIZUtils
//

import UIKit

@MainActor
public protocol Coordinator: AnyObject {
    func start() -> UIViewController
}
