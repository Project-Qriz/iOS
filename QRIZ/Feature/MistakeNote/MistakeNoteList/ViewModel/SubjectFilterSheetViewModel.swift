//
//  SubjectFilterSheetViewModel.swift
//  QRIZ
//
//  Created by Claude on 2/6/26.
//

import Foundation

final class SubjectFilterSheetViewModel: ObservableObject {

    // MARK: - Input

    enum Input {
        case resetTapped
    }

    // MARK: - Published Properties

    @Published var selectedSubject: Subject
    @Published var selectedConcepts: Set<String>

    // MARK: - Properties

    let availableConcepts: Set<String>
    private let initialSelectedConcepts: Set<String>

    // MARK: - Computed Properties

    var hasSelections: Bool {
        !selectedConcepts.isEmpty
    }

    var hasChanges: Bool {
        selectedConcepts != initialSelectedConcepts
    }

    var availableChapters: [Chapter] {
        let normalizedAvailableConcepts = Set(availableConcepts.map { normalizeConceptName($0) })
        return selectedSubject.chapters.filter { chapter in
            chapter.concepts.contains { normalizedAvailableConcepts.contains(normalizeConceptName($0)) }
        }
    }

    // MARK: - Initializer

    init(
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

    func send(_ input: Input) {
        switch input {
        case .resetTapped:
            selectedConcepts.removeAll()
        }
    }

    func normalizeConceptName(_ name: String) -> String {
        name.replacingOccurrences(of: " ", with: "")
    }
}
