//
//  ThemeMiniPreview.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/14/26.
//

import SwiftUI
import SwiftData




struct ThemeWorkspacePreview: View {
    let theme: WorkspaceTheme

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<5, id: \.self) { i in
                    HStack(spacing: 6) {
                        Image(systemName: sidebarIcons[i])
                            .foregroundStyle(theme.tint)
                            .font(.caption.weight(.semibold))
                        Text(sidebarLabels[i])
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(theme.primaryTextColor)
                        Spacer()
                    }
                    .padding(.horizontal, 6)
                }
                Spacer()
            }
            .frame(width: 72)
            .background(theme.surfaceColor(.sidebar))

            // List
            VStack(spacing: 0) {
                theme.surfaceColor(.list)
                    .overlay(alignment: .top) {
                        VStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(theme.surfaceColor(.card))
                                    .frame(height: 18)
                                    .padding(.horizontal, 6)
                            }
                        }
                        .padding(.top, 8)
                    }
            }
            .frame(width: 98)

            // Detail
            VStack(alignment: .leading, spacing: 10) {
                theme.surfaceColor(.detail)
                    .overlay {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sample Note Title")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.primaryTextColor)

                            Text("This is how your note will look with this theme.")
                                .font(.caption)
                                .foregroundStyle(theme.secondaryTextColor)
                                .lineLimit(3)

                            Spacer()

                            HStack(spacing: 4) {
                                Circle().fill(theme.tint).frame(width: 5, height: 5)
                                Text("Project / Folder")
                                    .font(.caption2)
                                    .foregroundStyle(theme.secondaryTextColor)
                            }
                        }
                        .padding(14)
                    }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 118)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
    }

    private let sidebarIcons = ["sun.horizon", "house", "checklist", "note.text", "calendar"]
    private let sidebarLabels = ["Today", "Home", "All Tasks", "Notes", "Calendar"]
}
