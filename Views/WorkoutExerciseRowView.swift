//
//  WorkoutExerciseRowView.swift
//  Fitnes
//
//  Čistě textový řádek cviku s dynamickým číslováním a rozbalovacím detailem pro váhy (kg), série a opakování.
//  UPOZORNĚNÍ: ZÁKAZ JAKÝCHKOLIV OBRÁZKŮ CVIKŮ A IKON DLE SPECIFIKACE.
//

import SwiftUI

/// Čistě textový řádek cviku v tréninkovém plánu
struct WorkoutExerciseRowView: View {
    let itemNumber: Int
    @Binding var item: WorkoutItem
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hlavní viditelná hlavička řádku (vždy viditelná)
            Button(action: onToggleExpand) {
                HStack(alignment: .top, spacing: 14) {
                    // Dynamické číslování (1, 2, 3...)
                    Text("\(itemNumber)")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())
                    
                    // Textové informace o cviku
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            // Textový indikátor rozbalení (čistě textový symbol)
                            Text(isExpanded ? "▲ Skrýt" : "▼ Upravit")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.08))
                                .clipShape(Capsule())
                        }
                        
                        // Textový přehled kategorie a plánovaných parametrů
                        HStack(spacing: 8) {
                            Text(item.category)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .foregroundColor(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            Text(item.summaryText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Rozbalovací detail: Vstupní pole pro váhu (kg), série a opakování
            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nastavení parametrů cviku:")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    // 1. Pole pro váhu s explicitním označením v kilogramech ("kg")
                    NumberInputRow(
                        title: "Váha zátěže",
                        unit: "kg",
                        value: $item.weightKg,
                        step: 2.5,
                        minValue: 0.0,
                        maxValue: 500.0,
                        formatDecimals: 1
                    )
                    
                    // 2. Počet sérií a plánovaná opakování vedle sebe
                    HStack(spacing: 16) {
                        IntegerInputRow(
                            title: "Počet sérií",
                            label: "sérií",
                            value: $item.targetSets,
                            minValue: 1,
                            maxValue: 20
                        )
                        
                        IntegerInputRow(
                            title: "Plánovaná opakování",
                            label: "reps",
                            value: $item.targetReps,
                            minValue: 1,
                            maxValue: 100
                        )
                    }
                    
                    // 3. Volitelné textové poznámky k provedení
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Poznámky k technice / pauzy:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Např. pauza 90s, stopka dole, pásek...", text: $item.notes)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Akční lišta rozbaleného detailu
                    HStack {
                        Button(role: .destructive, action: onDelete) {
                            Text("Odstranit cvik ze seznamu")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Button(action: onToggleExpand) {
                            Text("Hotovo")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(14)
                .background(Color(.systemGroupedBackground).opacity(0.6))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.22), value: isExpanded)
    }
}
