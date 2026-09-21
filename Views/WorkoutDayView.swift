//
//  WorkoutDayView.swift
//  Fitnes
//
//  Zobrazení konkrétního tréninkového dne (Trénink A / B) s dynamicky číslovaným seznamem cviků.
//

import SwiftUI

/// Zobrazení pro konkrétní tréninkový den (Trénink A nebo Trénink B)
struct WorkoutDayView: View {
    let day: WorkoutDay
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Textový informační pruh o naplánovaných dnech
            headerInfoBanner
            
            // Seznam cviků nebo prázdný stav
            if currentItems.isEmpty {
                emptyStateView
            } else {
                exerciseListView
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Aktuální seznam cviků
    private var currentItems: [WorkoutItem] {
        viewModel.items(for: day)
    }
    
    // MARK: - Informační banner o dni cvičení
    private var headerInfoBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.title)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(day.focus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Indikace dne cvičení
                Text(day.todayStatusBadge)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(day.isTodayScheduled ? Color.green.opacity(0.15) : Color.blue.opacity(0.12))
                    .foregroundColor(day.isTodayScheduled ? .green : .blue)
                    .clipShape(Capsule())
            }
            
            HStack {
                Text("Počet cviků: \(currentItems.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Rozklikněte cvik pro úpravu vah a sérií")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
    
    // MARK: - Seznam cviků s dynamickým číslováním
    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // Dynamické číslování 1, 2, 3...
                ForEach(Array(currentItems.enumerated()), id: \.element.id) { index, item in
                    let itemBinding = Binding<WorkoutItem>(
                        get: {
                            if day == .workoutA {
                                return viewModel.workoutA[index]
                            } else {
                                return viewModel.workoutB[index]
                            }
                        },
                        set: { updatedItem in
                            viewModel.updateItem(updatedItem, in: day)
                        }
                    )
                    
                    WorkoutExerciseRowView(
                        itemNumber: index + 1,
                        item: itemBinding,
                        isExpanded: viewModel.isExpanded(item.id),
                        onToggleExpand: {
                            viewModel.toggleExpand(for: item.id)
                        },
                        onDelete: {
                            viewModel.deleteExercise(withId: item.id, from: day)
                        }
                    )
                }
                
                // Tlačítko pro přidání dalšího cviku na konci seznamu
                Button(action: {
                    viewModel.isAddExerciseSheetPresented = true
                }) {
                    HStack(spacing: 8) {
                        Text("+")
                            .font(.title3.bold())
                        Text("Přidat další cvik")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Zobrazení při prázdném tréninku
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Žádné cviky v \(day.title)")
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            Text("Tento tréninkový den zatím neobsahuje žádné cviky. Klikněte na tlačítko níže a vyberte cviky z databáze nebo vytvořte vlastní.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                viewModel.isAddExerciseSheetPresented = true
            }) {
                Text("Přidat první cvik")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}
