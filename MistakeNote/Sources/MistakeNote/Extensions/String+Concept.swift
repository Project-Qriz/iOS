//
//  String+Concept.swift
//  MistakeNote
//

extension String {
    /// 개념 이름 정규화 — 공백 제거하여 비교 시 사용
    func normalizingConcept() -> String {
        replacingOccurrences(of: " ", with: "")
    }
}
