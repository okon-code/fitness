//
//  ExercisePickerViewModel.swift
//  Fitnes
//
//  ViewModel pro vyhledávání, filtrování a výběr cviků z externí JSON databáze.
//

import Foundation
import Combine

/// ViewModel spravující stav dialogu pro výběr cviku do tréninku
final class ExercisePickerViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "Všechny"
    @Published var customExerciseName: String = ""
    @Published var customCategory: String = "Vlastní"
    @Published var initialWeightKg: Double = 60.0
    @Published var initialSets: Int = 3
    @Published var initialReps: Int = 10
    
    private let databaseService: ExerciseDatabaseService
    
    init(databaseService: ExerciseDatabaseService = .shared) {
        self.databaseService = databaseService
    }
    
    /// Získá seznam všech dostupných kategorií cviků
    var availableCategories: [String] {
        return databaseService.categories
    }
    
    /// Filtrovaný seznam cviků podle vyhledávacího textu a kategorie
    var filteredExercises: [DatabaseExercise] {
        return databaseService.searchExercises(
            query: searchText,
            category: selectedCategory == "Všechny" ? nil : selectedCategory
        )
    }
    
    /// Indikace, zda je zadán platný vlastní cvik pro vytvoření
    var isCustomExerciseValid: Bool {
        return !customExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Obnovení hodnot po uložení
    func resetForm() {
        searchText = ""
        customExerciseName = ""
        initialWeightKg = 60.0
        initialSets = 3
        initialReps = 10
    }
}
