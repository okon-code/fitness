//
//  MainView.swift
//  Fitnes
//
//  Hlavní navigační zobrazení s TabView pro Trénink A a Trénink B a tlačítkem pro sdílení.
//

import SwiftUI

/// Hlavní zobrazení aplikace s 2 záložkami pro Trénink A a Trénink B
struct MainView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selectedDay) {
                // Záložka 1: Trénink A
                WorkoutDayView(day: .workoutA, viewModel: viewModel)
                    .tabItem {
                        Label("Trénink A", systemImage: "a.circle.fill")
                    }
                    .tag(WorkoutDay.workoutA)
                
                // Záložka 2: Trénink B
                WorkoutDayView(day: .workoutB, viewModel: viewModel)
                    .tabItem {
                        Label("Trénink B", systemImage: "b.circle.fill")
                    }
                    .tag(WorkoutDay.workoutB)
            }
            .navigationTitle("Silový Trénink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Tlačítko pro sdílení aplikace s kamarádem (vyvolá UIActivityViewController)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.isShareSheetPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Sdílet")
                                .font(.subheadline)
                        }
                    }
                    .accessibilityLabel("Sdílet aplikaci a trénink s kamarádem")
                }
                
                // Tlačítko pro rychlé přidání cviku do aktuální záložky
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.isAddExerciseSheetPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Přidat cvik")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }
            // Dialog pro přidání cviku
            .sheet(isPresented: $viewModel.isAddExerciseSheetPresented) {
                AddExerciseSheet(
                    targetDay: viewModel.selectedDay,
                    onAddDatabaseExercise: { dbExercise, weightKg, sets, reps in
                        viewModel.addExercise(
                            to: viewModel.selectedDay,
                            databaseExercise: dbExercise,
                            weightKg: weightKg,
                            sets: sets,
                            reps: reps
                        )
                    },
                    onAddCustomExercise: { name, category, weightKg, sets, reps in
                        viewModel.addCustomExercise(
                            to: viewModel.selectedDay,
                            name: name,
                            category: category,
                            weightKg: weightKg,
                            sets: sets,
                            reps: reps
                        )
                    }
                )
            }
            // Nativní systémové menu UIActivityViewController pro sdílení
            .sheet(isPresented: $viewModel.isShareSheetPresented) {
                ShareSheet(activityItems: [viewModel.shareMessage()])
            }
        }
    }
}

#Preview {
    MainView()
}
