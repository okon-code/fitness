//
//  WorkoutStorageService.swift
//  Fitnes
//
//  Služba pro bezpečné perzistentní ukládání a načítání tréninkových plánů.
//

import Foundation

/// Struktura reprezentující celkový uložený stav tréninkových plánů
struct PersistedWorkoutData: Codable {
    var workoutA: [WorkoutItem]
    var workoutB: [WorkoutItem]
    var schemaVersion: Int
    
    init(workoutA: [WorkoutItem], workoutB: [WorkoutItem], schemaVersion: Int = 1) {
        self.workoutA = workoutA
        self.workoutB = workoutB
        self.schemaVersion = schemaVersion
    }
}

/// Třída pro bezpečné ukládání a načítání dat tréninků ze souborového systému (Documents directory)
final class WorkoutStorageService {
    static let shared = WorkoutStorageService()
    
    private let fileName = "workout_plans.json"
    
    /// Cesta k souboru s daty v uživatelské složce dokumentů
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    /// Bezpečně uloží data tréninků do JSON souboru
    func saveWorkouts(workoutA: [WorkoutItem], workoutB: [WorkoutItem]) -> Result<Void, Error> {
        let payload = PersistedWorkoutData(workoutA: workoutA, workoutB: workoutB)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(payload)
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
            return .success(())
        } catch {
            print("[WorkoutStorageService] Chyba při ukládání tréninků: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// Bezpečně načte uložená data tréninků nebo vrátí výchozí plán
    func loadWorkouts() -> (workoutA: [WorkoutItem], workoutB: [WorkoutItem]) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Pokud soubor ještě neexistuje, vrátíme výchozí doporučený split
            let defaults = defaultWorkouts()
            _ = saveWorkouts(workoutA: defaults.workoutA, workoutB: defaults.workoutB)
            return defaults
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decoded = try decoder.decode(PersistedWorkoutData.self, from: data)
            return (workoutA: decoded.workoutA, workoutB: decoded.workoutB)
        } catch {
            print("[WorkoutStorageService] Chyba při načítání souboru, použita výchozí data: \(error.localizedDescription)")
            return defaultWorkouts()
        }
    }
    
    /// Výchozí vzorový plán pro Trénink A a Trénink B
    private func defaultWorkouts() -> (workoutA: [WorkoutItem], workoutB: [WorkoutItem]) {
        let planA = [
            WorkoutItem(
                exerciseId: "squat_barbell",
                name: "Dřep s velkou činkou (Barbell Squat)",
                category: "Nohy",
                weightKg: 80.0,
                targetSets: 3,
                targetReps: 5,
                notes: "Hloubka pod paralelní úroveň, pauza dole 1s"
            ),
            WorkoutItem(
                exerciseId: "bench_press_barbell",
                name: "Bench Press (Tlak na lavičce)",
                category: "Hrudník",
                weightKg: 65.0,
                targetSets: 3,
                targetReps: 5,
                notes: "Zatažené lopatky, stopka na hrudníku"
            ),
            WorkoutItem(
                exerciseId: "barbell_row",
                name: "Přítahy v předklonu (Barbell Row)",
                category: "Záda",
                weightKg: 55.0,
                targetSets: 3,
                targetReps: 8,
                notes: "Pevný trup v úhlu 45 stupňů"
            ),
            WorkoutItem(
                exerciseId: "dips_parallel_bars",
                name: "Dipy na bradlech (Parallel Bar Dips)",
                category: "Hrudník & Paže",
                weightKg: 0.0,
                targetSets: 3,
                targetReps: 10,
                notes: "Vlastní váha těla"
            )
        ]
        
        let planB = [
            WorkoutItem(
                exerciseId: "deadlift_barbell",
                name: "Mrtvý tah (Barbell Deadlift)",
                category: "Záda & Nohy",
                weightKg: 100.0,
                targetSets: 3,
                targetReps: 5,
                notes: "Rovná záda, osa těsně u nohou"
            ),
            WorkoutItem(
                exerciseId: "overhead_press",
                name: "Tlak nad hlavu (Overhead Press / OHP)",
                category: "Ramena",
                weightKg: 42.5,
                targetSets: 3,
                targetReps: 5,
                notes: "Zpevněné břicho a hýždě"
            ),
            WorkoutItem(
                exerciseId: "pull_ups",
                name: "Shyby na hrazdě (Pull-ups)",
                category: "Záda",
                weightKg: 0.0,
                targetSets: 3,
                targetReps: 8,
                notes: "Plný rozsah pohybu"
            ),
            WorkoutItem(
                exerciseId: "barbell_curl",
                name: "Bicepsový zdvih s velkou činkou",
                category: "Paže",
                weightKg: 30.0,
                targetSets: 3,
                targetReps: 10,
                notes: "Bez švihu tělem"
            )
        ]
        
        return (workoutA: planA, workoutB: planB)
    }
}
