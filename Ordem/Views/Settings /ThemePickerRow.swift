//
//  ThemePickerRow.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/14/26.
//
import SwiftUI


struct ThemePickerRow: View {
    @AppStorage("workspaceTheme") private var workspaceThemeRawValue = WorkspaceTheme.HAZ.rawValue
    @State private var showPicker = false
    
    private var currentTheme: WorkspaceTheme {
        WorkspaceTheme(rawValue: workspaceThemeRawValue) ?? .HAZ
    }
    
    var body: some View {
        Button {
            showPicker = true
        } label: {
            HStack {
                Label("Theme", systemImage: "paintpalette")
                Spacer()
                Text(currentTheme.title)
                    .foregroundStyle(.secondary)
                Circle()
                    .fill(currentTheme.tint)
                    .frame(width: 22, height: 22)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            ThemePickerView()
        }
    }
}
