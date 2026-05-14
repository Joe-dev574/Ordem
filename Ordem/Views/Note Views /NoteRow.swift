//
//  NoteRow.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/13/26.
//

import SwiftUI

// MARK: - Note Row
struct NoteRow: View {
    let note: Note

    @AppStorage("workspaceTheme") private var themeRawValue = WorkspaceTheme.HAZ.rawValue
    private var theme: WorkspaceTheme { WorkspaceTheme(rawValue: themeRawValue) ?? .HAZ }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
                .foregroundStyle(theme.primaryTextColor)
            Text(note.content.prefix(80) + (note.content.count > 80 ? "…" : ""))
                .font(.subheadline)
                .foregroundStyle(theme.secondaryTextColor)
                .lineLimit(2)
            Text(note.lastModified.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(theme.tertiaryTextColor)
        }
        .padding(.vertical, 4)
    }
}
