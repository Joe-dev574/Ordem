//
//  ThemeCard.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/14/26.
//
import SwiftUI



 struct ThemeCard: View {
    let theme: WorkspaceTheme
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ThemeWorkspacePreview(theme: theme)
                    .frame(height: 118)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? theme.tint : Color.white.opacity(0.1), lineWidth: isSelected ? 2.5 : 1)
                    )
                    .shadow(color: isHovered ? theme.tint.opacity(0.2) : .black.opacity(0.15), radius: 10, y: 5)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(theme.title)
                            .font(.headline.weight(.semibold))
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.tint)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    Text(theme.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 18).fill(.regularMaterial))
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovered)
        .onHover { isHovered = $0 }
    }
}
