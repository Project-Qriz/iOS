//
//  ConceptItem.swift
//  QRIZUtils
//
//  Created by Claude on 2/16/26.
//

import Foundation

public struct ConceptItem: Hashable {
    public let title: String
    public let fileName: String

    public init(title: String, fileName: String) {
        self.title = title
        self.fileName = fileName
    }
}
