//
//  NumberInputRow.swift
//  Fitnes
//
//  Znovupoužitelná vstupní komponenta pro zadávání vah v kg, počtu sérií a opakování.
//

import SwiftUI

/// Řádek pro úpravu číselné hodnoty s explicitním označením jednotky (např. kg) a rychlými tlačítky
struct NumberInputRow: View {
    let title: String
    let unit: String
    @Binding var value: Double
    let step: Double
    let minValue: Double
    let maxValue: Double
    let formatDecimals: Int
    
    @State private var textValue: String = ""
    @FocusState private var isFieldFocused: Bool
    
    init(
        title: String,
        unit: String = "",
        value: Binding<Double>,
        step: Double = 2.5,
        minValue: Double = 0.0,
        maxValue: Double = 500.0,
        formatDecimals: Int = 1
    ) {
        self.title = title
        self.unit = unit
        self._value = value
        self.step = step
        self.minValue = minValue
        self.maxValue = maxValue
        self.formatDecimals = formatDecimals
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !unit.isEmpty {
                    Text("Jednotka: \(unit)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
            
            HStack(spacing: 12) {
                // Tlačítko pro snížení
                Button(action: decrement) {
                    Text("−")
                        .font(.title3.bold())
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                
                // Pole s hodnotou a explicitní jednotkou
                HStack(spacing: 4) {
                    TextField("", text: $textValue)
                        .keyboardType(.decimalPad)
                        .focused($isFieldFocused)
                        .font(.headline.monospacedDigit())
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 60)
                        .onChange(of: isFieldFocused) { focused in
                            if !focused {
                                syncFromText()
                            }
                        }
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 38)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFieldFocused ? Color.blue : Color.clear, lineWidth: 1.5)
                )
                
                // Tlačítko pro zvýšení
                Button(action: increment) {
                    Text("+")
                        .font(.title3.bold())
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            syncToText()
        }
        .onChange(of: value) { _ in
            if !isFieldFocused {
                syncToText()
            }
        }
    }
    
    private func increment() {
        let next = min(maxValue, value + step)
        value = (next * 100).rounded() / 100
        syncToText()
    }
    
    private func decrement() {
        let prev = max(minValue, value - step)
        value = (prev * 100).rounded() / 100
        syncToText()
    }
    
    private func syncToText() {
        if formatDecimals == 0 || value.truncatingRemainder(dividingBy: 1) == 0 {
            textValue = String(format: "%.0f", value)
        } else {
            textValue = String(format: "%.\(formatDecimals)f", value)
        }
    }
    
    private func syncFromText() {
        let cleaned = textValue.replacingOccurrences(of: ",", with: ".")
        if let parsed = Double(cleaned) {
            let clamped = min(maxValue, max(minValue, parsed))
            value = clamped
            syncToText()
        } else {
            syncToText()
        }
    }
}

/// Speciální řádek pro celočíselné hodnoty (série a opakování)
struct IntegerInputRow: View {
    let title: String
    let label: String
    @Binding var value: Int
    let minValue: Int
    let maxValue: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button(action: decrement) {
                    Text("−")
                        .font(.title3.bold())
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                
                HStack(spacing: 4) {
                    Text("\(value)")
                        .font(.headline.monospacedDigit())
                        .frame(minWidth: 45)
                    
                    if !label.isEmpty {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Button(action: increment) {
                    Text("+")
                        .font(.title3.bold())
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func increment() {
        if value < maxValue {
            value += 1
        }
    }
    
    private func decrement() {
        if value > minValue {
            value -= 1
        }
    }
}
