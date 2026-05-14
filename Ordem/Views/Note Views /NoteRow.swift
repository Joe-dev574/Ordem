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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
            Text(note.content.prefix(80) + (note.content.count > 80 ? "…" : ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(note.lastModified.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
