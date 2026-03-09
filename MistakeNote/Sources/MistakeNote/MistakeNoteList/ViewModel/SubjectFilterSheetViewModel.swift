//
//  SubjectFilterSheetViewModel.swift
//  MistakeNote
//
//  Created by Claude on 2/6/26.
//

import Foundation
import QRIZUtils

public final class SubjectFilterSheetViewModel: ObservableObject {

    // MARK: - Input

    public enum Input {
        case resetTapped
    }

    // MARK: - Published Properties

    @Published public var selectedSubject: Subject
    @Published public var selectedConcepts: Set<String>

    // MARK: - Properties

    public let availableConcepts: Set<String>
    private let initialSelectedConcepts: Set<String>

    // MARK: - Computed Properties

    public var hasSelections: Bool {
        !selectedConcepts.isEmpty
    }

    public var hasChanges: Bool {
        selectedConcepts != initialSelectedConcepts
    }

    public var availableChapters: [Chapter] {
        let normalizedAvailableConcepts = Set(availableConcepts.map { normalizeConceptName($0) })
        return selectedSubject.chapters.filter { chapter in
            chapter.concepts.contains { normalizedAvailableConcepts.contains(normalizeConceptName($0)) }
        }
    }

    // MARK: - Initializer

    public init(
        availableConcepts: Set<String>,
        initialSubject: Subject = .one,
        initialSelectedConcepts: Set<String> = []
    ) {
        self.availableConcepts = availableConcepts
        self.selectedSubject = initialSubject
        self.initialSelectedConcepts = initialSelectedConcepts
        self.selectedConcepts = initialSelectedConcepts
    }

    // MARK: - Methods

    public func send(_ input: Input) {
        switch input {
        case .resetTapped:
            selectedConcepts.removeAll()
        }
    }

    public func normalizeConceptName(_ name: String) -> String {
        name.replacingOccurrences(of: " ", with: "")
    }
}
