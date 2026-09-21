//
//  WorkoutViewModel.swift
//  Fitnes
//
//  Hlavní ViewModel pro správu stavu tréninků, dynamického číslování, editaci a sdílení.
//

import Foundation
import Combine
import SwiftUI

/// Hlavní ViewModel spravující stav tréninkových plánů a interakce uživatele
final class WorkoutViewModel: ObservableObject {
    @Published var workoutA: [WorkoutItem] = []
    @Published var workoutB: [WorkoutItem] = []
    @Published var selectedDay: WorkoutDay = .workoutA
    
    /// Množina identifikátorů rozbalených cviků (pro zobrazení/skrytí detailu vah a opakování)
    @Published var expandedItemIds: Set<UUID> = []
    
    /// Stavy zobrazení sheetů a dialogů
    @Published var isAddExerciseSheetPresented: Bool = false
    @Published var isShareSheetPresented: Bool = false
    @Published var statusMessage: String?
    
    private let storageService: WorkoutStorageService
    
    init(storageService: WorkoutStorageService = .shared) {
        self.storageService = storageService
        loadWorkouts()
    }
    
    // MARK: - Načítání a ukládání
    
    /// Načtení tréninků ze stálého úložiště
    func loadWorkouts() {
        let loaded = storageService.loadWorkouts()
        self.workoutA = loaded.workoutA
        self.workoutB = loaded.workoutB
    }
    
    /// Uložení změn do stálého úložiště
    func persistChanges() {
        _ = storageService.saveWorkouts(workoutA: workoutA, workoutB: workoutB)
    }
    
    // MARK: - Přístup k datům pro konkrétní den
    
    /// Získá seznam cviků pro daný tréninkový den
    func items(for day: WorkoutDay) -> [WorkoutItem] {
        switch day {
        case .workoutA:
            return workoutA
        case .workoutB:
            return workoutB
        }
    }
    
    /// Získá index a dynamické číslo cviku (1-based)
    func dynamicIndex(for itemId: UUID, in day: WorkoutDay) -> Int {
        let list = items(for: day)
        if let index = list.firstIndex(where: { $0.id == itemId }) {
            return index + 1
        }
        return 1
    }
    
    // MARK: - Operace se cviky (Přidávání, Mazání, Přesouvání)
    
    /// Přidání cviku z databáze
    func addExercise(
        to day: WorkoutDay,
        databaseExercise: DatabaseExercise,
        weightKg: Double,
        sets: Int,
        reps: Int
    ) {
        let newItem = WorkoutItem(
            exerciseId: databaseExercise.id,
            name: databaseExercise.name,
            category: databaseExercise.category,
            weightKg: weightKg,
            targetSets: sets,
            targetReps: reps,
            notes: ""
        )
        
        switch day {
        case .workoutA:
            workoutA.append(newItem)
        case .workoutB:
            workoutB.append(newItem)
        }
        
        // Automaticky rozbalíme nově přidaný cvik pro okamžitou kontrolu
        expandedItemIds.insert(newItem.id)
        persistChanges()
    }
    
    /// Přidání vlastního uživatelského cviku
    func addCustomExercise(
        to day: WorkoutDay,
        name: String,
        category: String,
        weightKg: Double,
        sets: Int,
        reps: Int
    ) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        let newItem = WorkoutItem(
            exerciseId: UUID().uuidString,
            name: cleanName,
            category: category.isEmpty ? "Vlastní" : category,
            weightKg: weightKg,
            targetSets: sets,
            targetReps: reps,
            notes: ""
        )
        
        switch day {
        case .workoutA:
            workoutA.append(newItem)
        case .workoutB:
            workoutB.append(newItem)
        }
        
        expandedItemIds.insert(newItem.id)
        persistChanges()
    }
    
    /// Smazání cviku podle indexu (pro SwiftUI .onDelete)
    func deleteExercise(at offsets: IndexSet, from day: WorkoutDay) {
        switch day {
        case .workoutA:
            workoutA.remove(atOffsets: offsets)
        case .workoutB:
            workoutB.remove(atOffsets: offsets)
        }
        persistChanges()
    }
    
    /// Smazání konkrétního cviku podle UUID
    func deleteExercise(withId id: UUID, from day: WorkoutDay) {
        switch day {
        case .workoutA:
            workoutA.removeAll { $0.id == id }
        case .workoutB:
            workoutB.removeAll { $0.id == id }
        }
        expandedItemIds.remove(id)
        persistChanges()
    }
    
    /// Změna pořadí cviků v seznamu (pro SwiftUI .onMove)
    func moveExercise(from source: IndexSet, to destination: Int, in day: WorkoutDay) {
        switch day {
        case .workoutA:
            workoutA.move(fromOffsets: source, toOffset: destination)
        case .workoutB:
            workoutB.move(fromOffsets: source, toOffset: destination)
        }
        persistChanges()
    }
    
    /// Aktualizace parametrů cviku (váha v kg, série, opakování)
    func updateItem(_ updatedItem: WorkoutItem, in day: WorkoutDay) {
        switch day {
        case .workoutA:
            if let index = workoutA.firstIndex(where: { $0.id == updatedItem.id }) {
                workoutA[index] = updatedItem
            }
        case .workoutB:
            if let index = workoutB.firstIndex(where: { $0.id == updatedItem.id }) {
                workoutB[index] = updatedItem
            }
        }
        persistChanges()
    }
    
    // MARK: - Správa rozbalovacího detailu
    
    /// Přepne stav rozbalení pro konkrétní cvik
    func toggleExpand(for itemId: UUID) {
        if expandedItemIds.contains(itemId) {
            expandedItemIds.remove(itemId)
        } else {
            expandedItemIds.insert(itemId)
        }
    }
    
    /// Ověří, zda je daný cvik rozbalený
    func isExpanded(_ itemId: UUID) -> Bool {
        return expandedItemIds.contains(itemId)
    }
    
    // MARK: - Sdílení aplikace s kamarádem
    
    /// Vygeneruje formátovaný text pro sdílení aplikace a aktuálního tréninkového plánu
    func shareMessage() -> String {
        let activePlan = selectedDay == .workoutA ? workoutA : workoutB
        var text = "💪 Cvičím podle aplikace Silový Trénink!\n\n"
        text += "Můj aktuální \(selectedDay.title):\n"
        
        for (index, item) in activePlan.enumerated() {
            text += "\(index + 1). \(item.name) – \(item.targetSets) série × \(item.targetReps) reps @ \(item.weightFormattedString)\n"
        }
        
        text += "\nZkus tuto aplikaci pro přehledné plánování sérií a vah bez rušivých obrázků!"
        return text
    }
}
