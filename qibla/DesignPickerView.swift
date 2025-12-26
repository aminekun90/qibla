//
//  DesignPickerView.swift
//  qibla
//
//  Created by amine on 29/12/2025.
//


import SwiftUI

struct DesignPickerView: View {
    // This connects to the AppStorage key used in CompassDialView
    @AppStorage("selectedCompassStyle") private var selectedStyle: CompassStyle = .classic
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(CompassStyle.allCases) { style in
                        Button {
                            // Using an animation here makes the CompassDialView 
                            // in the background transition smoothly
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedStyle = style
                            }
                        } label: {
                            HStack(spacing: 15) {
                                // Mini Preview Icon based on the theme
                                themeIcon(for: style)
                                
                                Text(style.rawValue)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedStyle == style {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Available Designs")
                } footer: {
                    Text("Select a theme to change the look and feel of your compass dial.")
                }
            }
            .navigationTitle("Compass Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    // Helper to show a small icon representing the theme vibe
    @ViewBuilder
    private func themeIcon(for style: CompassStyle) -> some View {
        ZStack {
            Circle()
                .fill(themeColor(for: style).opacity(0.2))
                .frame(width: 32, height: 32)
            
            Image(systemName: themeSymbol(for: style))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(themeColor(for: style))
        }
    }
    
    private func themeColor(for style: CompassStyle) -> Color {
        switch style {
        case .classic: return .white
        case .minimal: return .red
        case .tactical: return .green
        case .glass: return .blue
        }
    }
    
    private func themeSymbol(for style: CompassStyle) -> String {
        switch style {
        case .classic: return "number"
        case .minimal: return "minus"
        case .tactical: return "scope"
        case .glass: return "square.stack.3d.up"
        }
    }
}

// Preview provider for Xcode
#Preview {
    DesignPickerView()
        .preferredColorScheme(.dark)
}
