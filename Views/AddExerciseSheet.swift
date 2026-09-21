//
//  AddExerciseSheet.swift
//  Fitnes
//
//  Dialogové okno pro vyhledání cviku z načtené JSON databáze nebo vytvoření vlastního cviku.
//  Čistě textové zobrazení bez obrázků cviků.
//

import SwiftUI

/// Modal pro přidání nového cviku do vybraného tréninku
struct AddExerciseSheet: View {
    let targetDay: WorkoutDay
    let onAddDatabaseExercise: (DatabaseExercise, Double, Int, Int) -> Void
    let onAddCustomExercise: (String, String, Double, Int, Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var pickerVM = ExercisePickerViewModel()
    
    @State private var isCustomMode: Bool = false
    @State private var selectedDatabaseExercise: DatabaseExercise?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Přepínač režimu: Výběr z databáze vs. Vlastní cvik
                Picker("Režim přidání", selection: $isCustomMode) {
                    Text("Z databáze cviků").tag(false)
                    Text("Vlastní cvik").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                if !isCustomMode {
                    databaseSelectionView
                } else {
                    customExerciseView
                }
            }
            .navigationTitle("Přidat cvik do \(targetDay.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Výběr z načtené databáze
    private var databaseSelectionView: some View {
        VStack(spacing: 0) {
            // Textové vyhledávací pole
            HStack {
                TextField("Hledat cvik (např. Dřep, Bench, Záda...)", text: $pickerVM.searchText)
                    .textFieldStyle(.plain)
                    .padding(8)
                
                if !pickerVM.searchText.isEmpty {
                    Button(action: { pickerVM.searchText = "" }) {
                        Text("✕")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Textové kategorie (Scroll)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pickerVM.availableCategories, id: \.self) { category in
                        Button(action: {
                            pickerVM.selectedCategory = category
                        }) {
                            Text(category)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(pickerVM.selectedCategory == category ? Color.blue : Color(.systemGray5))
                                .foregroundColor(pickerVM.selectedCategory == category ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Textový seznam vyfiltrovaných cviků
            List {
                if pickerVM.filteredExercises.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Nenalezen žádný cvik")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Zkuste upravit vyhledávání nebo přepnout na 'Vlastní cvik'.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(pickerVM.filteredExercises) { exercise in
                        Button(action: {
                            selectedDatabaseExercise = exercise
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(exercise.category)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }
                                
                                Text("Zapojené svaly: \(exercise.musclesSummary)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let equipment = exercise.equipment {
                                    Text("Vybavení: \(equipment)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(item: $selectedDatabaseExercise) { exercise in
            configureExerciseSheet(exerciseName: exercise.name, category: exercise.category) {
                onAddDatabaseExercise(
                    exercise,
                    pickerVM.initialWeightKg,
                    pickerVM.initialSets,
                    pickerVM.initialReps
                )
                dismiss()
            }
        }
    }
    
    // MARK: - Formulář pro vlastní cvik
    private var customExerciseView: some View {
        Form {
            Section(header: Text("Informace o cviku")) {
                TextField("Název cviku (např. Tlaky s jednoručkami)", text: $pickerVM.customExerciseName)
                
                Picker("Kategorie", selection: $pickerVM.customCategory) {
                    Text("Hrudník").tag("Hrudník")
                    Text("Záda").tag("Záda")
                    Text("Nohy").tag("Nohy")
                    Text("Ramena").tag("Ramena")
                    Text("Paže").tag("Paže")
                    Text("Střed těla").tag("Střed těla")
                    Text("Vlastní").tag("Vlastní")
                }
            }
            
            Section(header: Text("Výchozí tréninkové parametry")) {
                NumberInputRow(
                    title: "Plánovaná váha",
                    unit: "kg",
                    value: $pickerVM.initialWeightKg,
                    step: 2.5
                )
                
                IntegerInputRow(
                    title: "Počet sérií",
                    label: "sérií",
                    value: $pickerVM.initialSets,
                    minValue: 1,
                    maxValue: 20
                )
                
                IntegerInputRow(
                    title: "Plánovaná opakování",
                    label: "reps",
                    value: $pickerVM.initialReps,
                    minValue: 1,
                    maxValue: 100
                )
            }
            
            Section {
                Button(action: {
                    onAddCustomExercise(
                        pickerVM.customExerciseName,
                        pickerVM.customCategory,
                        pickerVM.initialWeightKg,
                        pickerVM.initialSets,
                        pickerVM.initialReps
                    )
                    dismiss()
                }) {
                    Text("Přidat do tréninku")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(pickerVM.isCustomExerciseValid ? .blue : .secondary)
                }
                .disabled(!pickerVM.isCustomExerciseValid)
            }
        }
    }
    
    // MARK: - Konfigurace parametrů před vložením vybraného cviku
    private func configureExerciseSheet(exerciseName: String, category: String, onConfirm: @escaping () -> Void) -> some View {
        NavigationStack {
            Form {
                Section(header: Text("Cvik")) {
                    Text(exerciseName)
                        .font(.headline)
                    Text("Kategorie: \(category)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Nastavení tréninkových parametrů")) {
                    NumberInputRow(
                        title: "Plánovaná váha",
                        unit: "kg",
                        value: $pickerVM.initialWeightKg,
                        step: 2.5
                    )
                    
                    IntegerInputRow(
                        title: "Počet sérií",
                        label: "sérií",
                        value: $pickerVM.initialSets,
                        minValue: 1,
                        maxValue: 20
                    )
                    
                    IntegerInputRow(
                        title: "Plánovaná opakování",
                        label: "reps",
                        value: $pickerVM.initialReps,
                        minValue: 1,
                        maxValue: 100
                    )
                }
            }
            .navigationTitle("Nastavit parametry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zpět") {
                        selectedDatabaseExercise = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vložit do tréninku") {
                        onConfirm()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
