//
//  WorkoutDay.swift
//  Fitnes
//
//  Definice tréninkových dnů a jejich plánování.
//

import Foundation

/// Identifikace a konfigurace tréninkových dnů pro split trénink.
enum WorkoutDay: String, CaseIterable, Identifiable, Codable {
    case workoutA = "workout_a"
    case workoutB = "workout_b"
    
    var id: String { rawValue }
    
    /// Uživatelsky přívětivý název tréninku
    var title: String {
        switch self {
        case .workoutA:
            return "Trénink A"
        case .workoutB:
            return "Trénink B"
        }
    }
    
    /// Podtitul zaměření tréninku
    var focus: String {
        switch self {
        case .workoutA:
            return "Dřepy / Bench Press / Přítahy"
        case .workoutB:
            return "Mrtvý tah / Tlaky nad hlavu / Shyby"
        }
    }
    
    /// Doporučené dny v týdnu pro tento tréninkový split
    var scheduledDaysDescription: String {
        switch self {
        case .workoutA:
            return "Pondělí, Pátek"
        case .workoutB:
            return "Středa"
        }
    }
    
    /// Vyhodnotí, zda je dnešní den doporučeným dnem pro daný trénink
    var isTodayScheduled: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // 1: Neděle, 2: Pondělí, 3: Úterý, 4: Středa, 5: Čtvrtek, 6: Pátek, 7: Sobota
        switch self {
        case .workoutA:
            return weekday == 2 || weekday == 6 // Pondělí nebo Pátek
        case .workoutB:
            return weekday == 4 // Středa
        }
    }
    
    /// Textová indikace dnešního statusu
    var todayStatusBadge: String {
        if isTodayScheduled {
            return "Dnes na plánu"
        } else {
            return "Plán: \(scheduledDaysDescription)"
        }
    }
}
