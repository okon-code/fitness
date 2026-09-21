//
//  ExerciseDatabaseService.swift
//  Fitnes
//
//  Služba pro bezpečné načítání a dekódování databáze cviků z lokálního JSON souboru.
//

import Foundation

/// Výčtový typ chyb při načítání a zpracování databáze cviků
enum DatabaseServiceError: LocalizedError, Equatable {
    case fileNotFound(String)
    case unreadableData
    case decodingFailed(String)
    case validationFailed(String)
    case emptyDatabase
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON soubor '\(filename).json' nebyl nalezen v Bundle aplikace."
        case .unreadableData:
            return "Obsah souboru s databází cviků nelze přečíst."
        case .decodingFailed(let message):
            return "Chyba při dekódování JSON databáze cviků: \(message)"
        case .validationFailed(let reason):
            return "Integrita databáze cviků je porušena: \(reason)"
        case .emptyDatabase:
            return "Databáze cviků neobsahuje žádné platné položky."
        }
    }
}

/// Třída zajišťující bezpečné načtení a správu externí databáze cviků
final class ExerciseDatabaseService: ObservableObject {
    static let shared = ExerciseDatabaseService()
    
    @Published private(set) var loadedExercises: [DatabaseExercise] = []
    @Published private(set) var lastError: DatabaseServiceError?
    
    init() {
        // Pokusíme se automaticky načíst databázi při inicializaci
        loadExercisesFromBundle()
    }
    
    /// Bezpečně načte databázi cviků z přibaleného JSON souboru v Bundle
    @discardableResult
    func loadExercisesFromBundle(filename: String = "exercises") -> Result<[DatabaseExercise], DatabaseServiceError> {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            // Pokud soubor v Bundle není (např. při testování v Preview nebo před přidáním do Xcode Targetu),
            // použijeme integrovanou bezpečnou zálohu a zalogujeme chybu.
            let error = DatabaseServiceError.fileNotFound(filename)
            self.lastError = error
            let fallback = fallbackExercises()
            self.loadedExercises = fallback
            return .success(fallback)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let exercises = try decodeAndValidate(from: data)
            self.loadedExercises = exercises
            self.lastError = nil
            return .success(exercises)
        } catch let serviceError as DatabaseServiceError {
            self.lastError = serviceError
            self.loadedExercises = fallbackExercises()
            return .failure(serviceError)
        } catch {
            let wrappedError = DatabaseServiceError.decodingFailed(error.localizedDescription)
            self.lastError = wrappedError
            self.loadedExercises = fallbackExercises()
            return .failure(wrappedError)
        }
    }
    
    /// Bezpečné dekódování a validace integrity načtených dat
    func decodeAndValidate(from data: Data) throws -> [DatabaseExercise] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        let exercises: [DatabaseExercise]
        do {
            exercises = try decoder.decode([DatabaseExercise].self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            let debug = "Chybí povinný klíč '\(key.stringValue)' na cestě: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
            throw DatabaseServiceError.decodingFailed(debug)
        } catch DecodingError.typeMismatch(let type, let context) {
            let debug = "Neshoda datového typu '\(type)' na cestě: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
            throw DatabaseServiceError.decodingFailed(debug)
        } catch DecodingError.valueNotFound(let value, let context) {
            let debug = "Chybí hodnota pro typ '\(value)' na cestě: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
            throw DatabaseServiceError.decodingFailed(debug)
        } catch DecodingError.dataCorrupted(let context) {
            let debug = "Poškozená JSON data: \(context.debugDescription)"
            throw DatabaseServiceError.decodingFailed(debug)
        } catch {
            throw DatabaseServiceError.decodingFailed(error.localizedDescription)
        }
        
        // Validace integrity dat
        guard !exercises.isEmpty else {
            throw DatabaseServiceError.emptyDatabase
        }
        
        var seenIds = Set<String>()
        for exercise in exercises {
            // 1. Kontrola neprázdného ID a názvu
            guard !exercise.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DatabaseServiceError.validationFailed("Nalezen cvik s prázdným identifikátorem (ID).")
            }
            guard !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DatabaseServiceError.validationFailed("Cvik s ID '\(exercise.id)' má prázdný název.")
            }
            
            // 2. Kontrola unikátnosti ID
            if seenIds.contains(exercise.id) {
                throw DatabaseServiceError.validationFailed("Duplicitní identifikátor cviku: '\(exercise.id)'.")
            }
            seenIds.insert(exercise.id)
        }
        
        return exercises
    }
    
    /// Vyhledávání cviků podle zadaného textu a kategorie
    func searchExercises(query: String, category: String? = nil) -> [DatabaseExercise] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return loadedExercises.filter { exercise in
            let matchesCategory: Bool
            if let category = category, !category.isEmpty, category != "Všechny" {
                matchesCategory = exercise.category.caseInsensitiveCompare(category) == .orderedSame
            } else {
                matchesCategory = true
            }
            
            if !matchesCategory { return false }
            
            if cleanQuery.isEmpty { return true }
            
            let nameMatch = exercise.name.lowercased().contains(cleanQuery)
            let categoryMatch = exercise.category.lowercased().contains(cleanQuery)
            let muscleMatch = exercise.primaryMuscles.contains { $0.lowercased().contains(cleanQuery) } ||
                              exercise.secondaryMuscles.contains { $0.lowercased().contains(cleanQuery) }
            
            return nameMatch || categoryMatch || muscleMatch
        }
    }
    
    /// Získání všech unikátních kategorií
    var categories: [String] {
        let unique = Set(loadedExercises.map(\.category))
        return ["Všechny"] + unique.sorted()
    }
    
    /// Záložní vestavěná databáze základních silových cviků (zajišťuje 100% funkčnost i bez externího souboru)
    private func fallbackExercises() -> [DatabaseExercise] {
        return [
            DatabaseExercise(
                id: "squat_barbell",
                name: "Dřep s velkou činkou (Barbell Squat)",
                category: "Nohy",
                primaryMuscles: ["Kvadricepsy", "Hýždě"],
                secondaryMuscles: ["Hamstringy", "Spodní záda", "Střed těla"],
                equipment: "Velká činka",
                instructions: ["Postavte se s činkou na zádech s nohama na šířku ramen.", "Pomalu klesejte do dřepu až do paralelní polohy.", "S výdechem se dynamicky zvedněte zpět do výchozí pozice."]
            ),
            DatabaseExercise(
                id: "bench_press_barbell",
                name: "Bench Press (Tlak na lavičce)",
                category: "Hrudník",
                primaryMuscles: ["Prsní svaly"],
                secondaryMuscles: ["Tricepsy", "Přední ramena"],
                equipment: "Velká činka, Lavička",
                instructions: ["Lehněte si na rovnou lavičku, uchopte činku o něco šířeji než ramena.", "Spouštějte činku řízeně k dolní části hrudníku.", "Dynamickým tlakem vytlačte činku nahoru."]
            ),
            DatabaseExercise(
                id: "barbell_row",
                name: "Přítahy v předklonu (Barbell Row)",
                category: "Záda",
                primaryMuscles: ["Široký sval zádový", "Mezilopatkové svaly"],
                secondaryMuscles: ["Bicepsy", "Zadní ramena"],
                equipment: "Velká činka",
                instructions: ["Předkloňte se s rovnými zády a podsaženým pasem.", "Přitahujte osu k pasu za stálé aktivace lopatek.", "Spouštějte činku plynule dolů."]
            ),
            DatabaseExercise(
                id: "overhead_press",
                name: "Tlak nad hlavu (Overhead Press / OHP)",
                category: "Ramena",
                primaryMuscles: ["Deltové svaly (ramena)"],
                secondaryMuscles: ["Tricepsy", "Horní část prsou", "Střed těla"],
                equipment: "Velká činka",
                instructions: ["Uchopte činku na úrovni klíčních kostí.", "Tlakem vytlačte činku přímo nad hlavu až do propnutí paží.", "Řízeně spusťte zpět."]
            ),
            DatabaseExercise(
                id: "deadlift_barbell",
                name: "Mrtvý tah (Barbell Deadlift)",
                category: "Záda & Nohy",
                primaryMuscles: ["Hamstringy", "Hýždě", "Vzpřimovače páteře"],
                secondaryMuscles: ["Lats", "Trapézy", "Předloktí"],
                equipment: "Velká činka",
                instructions: ["Postavte se k ose na šířku boků.", "Uchopte činku s rovnými zády a zpevněným středem.", "Zvedněte činku tahem těla podél holení a napřimte se v bocích."]
            ),
            DatabaseExercise(
                id: "pull_ups",
                name: "Shyby nadhmatem / podhmatem (Pull-ups)",
                category: "Záda",
                primaryMuscles: ["Široký sval zádový"],
                secondaryMuscles: ["Bicepsy", "Zadní ramena"],
                equipment: "Hrazda",
                instructions: ["Zavěste se na hrazdu plným úchopem.", "Přitáhněte se hrudníkem k hrazdě.", "Spusťte se plynule do plného visení."]
            ),
            DatabaseExercise(
                id: "dips_parallel_bars",
                name: "Dipy na bradlech (Parallel Bar Dips)",
                category: "Hrudník & Paže",
                primaryMuscles: ["Tricepsy", "Spodní hrudník"],
                secondaryMuscles: ["Přední ramena"],
                equipment: "Bradla",
                instructions: ["Vzepřete se na bradlech s propnutými pažemi.", "Spouštějte tělo ohnutím v loktech do úhlu 90 stupňů.", "Vytlačte se zpět do horní pozice."]
            ),
            DatabaseExercise(
                id: "barbell_curl",
                name: "Bicepsový zdvih s velkou činkou",
                category: "Paže",
                primaryMuscles: ["Bicepsy"],
                secondaryMuscles: ["Předloktí"],
                equipment: "Velká činka / EZ osa",
                instructions: ["Stůjte vzpřímeně s činkou v podhmatu.", "Ohýbáním v loktech zvedejte činku k hrudníku bez švihu.", "Pomalým pohybem spusťte dolů."]
            ),
            DatabaseExercise(
                id: "skull_crushers",
                name: "Francouzský tlak vleže (Skull Crushers)",
                category: "Paže",
                primaryMuscles: ["Tricepsy"],
                secondaryMuscles: ["Předloktí"],
                equipment: "EZ osa, Lavička",
                instructions: ["Lehněte si na lavičku, držte osu svisle nad čelem.", "Ohýbáním v loktech spouštějte osu k čelu.", "Izolovaným tlakem tricepsů narovnejte paže."]
            ),
            DatabaseExercise(
                id: "calf_raises",
                name: "Výpony ve stoji (Calf Raises)",
                category: "Nohy",
                primaryMuscles: ["Lýtka"],
                secondaryMuscles: ["Hlezenní stabilizátory"],
                equipment: "Činky / Stroj na výpony",
                instructions: ["Stoupněte si na špičky nohou na stupínek.", "Zvedněte paty maximálně vysoko.", "Spusťte paty pod úroveň stupínku pro plné protažení."]
            ),
            DatabaseExercise(
                id: "plank_hold",
                name: "Plank (Prkno pro střed těla)",
                category: "Střed těla",
                primaryMuscles: ["Přímý a šikmý břišní sval"],
                secondaryMuscles: ["Hluboký stabilizační systém (Core)"],
                equipment: "Podložka",
                instructions: ["Zaujměte pozici na předloktích a špičkách nohou.", "Držte tělo v jedné přímce a zpevněte břicho a hýždě."]
            )
        ]
    }
}
