//
//  SubjectFilterSheetViewModel.swift
//  MistakeNote
//
//  Created by Claude on 2/6/26.
//

import Foundation
import QRIZUtils

@MainActor
public final class SubjectFilterSheetViewModel: ObservableObject {

    // MARK: - Properties

    @Published public var selectedSubject: Subject
    @Published public var selectedConcepts: Set<String>

    public let availableConcepts: Set<String>

    public var hasSelections: Bool {
        !selectedConcepts.isEmpty
    }

    public var hasChanges: Bool {
        selectedConcepts != initialSelectedConcepts
    }

    public var availableChapters: [Chapter] {
        let normalizedAvailableConcepts = Set(availableConcepts.map { $0.normalizingConcept() })
        return selectedSubject.chapters.filter { chapter in
            chapter.concepts.contains { normalizedAvailableConcepts.contains($0.normalizingConcept()) }
        }
    }

    private let initialSelectedConcepts: Set<String>

    // MARK: - Initialization

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

    public func reset() {
        selectedConcepts.removeAll()
    }
}
