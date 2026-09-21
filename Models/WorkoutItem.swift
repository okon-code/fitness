//
//  WorkoutItem.swift
//  Fitnes
//
//  Datový model pro konkrétní cvik zařazený v tréninkovém plánu.
//

import Foundation

/// Model položky tréninku představující konkrétní cvik a jeho parametry (váha, série, opakování).
struct WorkoutItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var exerciseId: String
    var name: String
    var category: String
    var weightKg: Double
    var targetSets: Int
    var targetReps: Int
    var notes: String
    var isCompleted: Bool
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        exerciseId: String,
        name: String,
        category: String,
        weightKg: Double = 60.0,
        targetSets: Int = 3,
        targetReps: Int = 10,
        notes: String = "",
        isCompleted: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.weightKg = weightKg
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.notes = notes
        self.isCompleted = isCompleted
        self.lastUpdated = lastUpdated
    }
    
    /// Inicializace z položky externí databáze cviků
    init(from databaseExercise: DatabaseExercise, weightKg: Double = 50.0, targetSets: Int = 3, targetReps: Int = 10) {
        self.id = UUID()
        self.exerciseId = databaseExercise.id
        self.name = databaseExercise.name
        self.category = databaseExercise.category
        self.weightKg = weightKg
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.notes = ""
        self.isCompleted = false
        self.lastUpdated = Date()
    }
    
    /// Formátovaný textový přehled parametrů (např. "3 série × 10 opakováni @ 80.0 kg")
    var summaryText: String {
        let weightFormatted = String(format: "%.1f", weightKg).replacingOccurrences(of: ".0", with: "")
        return "\(targetSets) série × \(targetReps) reps @ \(weightFormatted) kg"
    }
    
    /// Formátovaný popis váhy s jednotkou kg
    var weightFormattedString: String {
        let weightString = String(format: "%.1f", weightKg).replacingOccurrences(of: ".0", with: "")
        return "\(weightString) kg"
    }
}
