//
//  PDFService.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import Foundation

protocol PDFService {
    func fetchPDF(from url: URL) async throws -> Data
}

final class PDFServiceImpl: PDFService {
    func fetchPDF(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidURL(message: url.absoluteString)
        }
        return data
    }
}
