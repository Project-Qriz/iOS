//
//  ExampleRequest.swift
//  QRIZ
//
//  Created by KSH on 12/18/24.
//

import Foundation

struct ExampleRequest: Request {
    typealias Response = ExampleResponse
    
    var path: String { "/todos/1" }
    var method: HTTPMethod { .get }
}
