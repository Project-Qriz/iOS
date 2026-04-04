//
//  TestHelpers.swift
//  ConceptbookTests
//

import Foundation

func waitForMainQueue() async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        RunLoop.main.perform { continuation.resume() }
    }
}
