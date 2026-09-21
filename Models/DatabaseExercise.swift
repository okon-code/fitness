//
//  DatabaseExercise.swift
//  Fitnes
//
//  Datový model pro načítání cviků z externí JSON databáze (Free Exercise DB).
//

import Foundation

/// Model cviku z externí databáze (JSON).
/// Reprezentuje čistě textovou definici cviku bez závislosti na obrázcích.
struct DatabaseExercise: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let equipment: String?
    let instructions: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case primaryMuscles = "primary_muscles"
        case secondaryMuscles = "secondary_muscles"
        case equipment
        case instructions
    }
    
    /// Pomocná vlastnost pro formátované textové zobrazení zapojených svalů
    var musclesSummary: String {
        let allMuscles = primaryMuscles + secondaryMuscles
        if allMuscles.isEmpty {
            return category
        }
        return allMuscles.joined(separator: ", ")
    }
}
